
(* Initialises the OCaml backend *)
let initialise ?(includes=[]) () =
  (*  Clflags.inlining_report := false;*)
  Clflags.include_dirs :=
    includes @ !Clflags.include_dirs; (* Paths for module lookup *)
  Clflags.nopervasives := false;      (* Whether to include the Pervasives module *)
  Clflags.dump_lambda := true;       (* Dump lambda ir *)
  Clflags.dump_clambda := false;      (* Dump clambda ir *)
  Clflags.dump_cmm := false;          (* Dump c-- code *)
  Clflags.keep_asm_file := false;
  Clflags.native_code := true;        (* Whether to use the native or byte code compilation pipeline *)
  Clflags.opaque := true;
  Compmisc.init_path true;            (* true for native code compilation *)
  Ident.reinit ()

let initial_env () =
  Compmisc.initial_env ()

let compile modident prog out =
  let ppf = Format.std_formatter in
  let init_env ((modname, _, _, _) as comp_unit) =
    Env.set_unit_name modname;
    Compilenv.reset ?packname:!Clflags.for_package modname;
    comp_unit
  in
  let simplify_lambda (modname, prog, cmxfile, cmifile) =
    let open Lambda in
    let prog =
      { prog with code = Simplif.simplify_lambda modname prog.code }
    in
    (modname, prog, cmxfile, cmifile)
  in
  let gen_cmifile (modname, prog, cmxfile, _) =
    let prefix = Misc.chop_extensions cmxfile in
    let _ = Env.save_signature ~deprecated:None [] modname cmxfile in
    let cmifile = Printf.sprintf "%s.cmi" prefix in
    (modname, prog, cmxfile, cmifile)
  in
  let save_cmxfile ((_, _, cmxfile, _) as comp_unit) =
    Compilenv.save_unit_info cmxfile;
    comp_unit
  in
  let asm_compile ((_, prog, cmxfile, _) as comp_unit) =
    let target_wo_ext = Misc.chop_extensions cmxfile in
    Asmgen.compile_implementation_clambda target_wo_ext ppf prog;
    comp_unit
  in
  let assemble_exec cmxs out =
    Asmlink.link ppf cmxs out
  in
  (* Pipeline *)
  let builtins_cmx =
    (* assumes the builtins exist in the current working directory *)
    Filename.concat (Sys.getcwd ()) "llama_Builtins.cmx"
  in
  let comp_unit =
    let modname = Ident.name modident in
    let basedir = Filename.dirname out in
    let cmxfile = Printf.sprintf "%s/%s.cmx" basedir (String.uncapitalize_ascii modname) in
    (modname, prog, cmxfile, "<none>")
  in
  let (_, _, cmxfile, _) =
    init_env comp_unit
    |> simplify_lambda
    |> gen_cmifile
    |> save_cmxfile
    |> asm_compile
  in
  assemble_exec [builtins_cmx; cmxfile] out
