open Syntax

module Examples = struct
  open Lam
  let add =
    (abs "x" (fun x ->
      abs "y" (fun y ->
        papp plus [var x; var y])))


  let two_plus_forty =
    (app
       (app add (int 2))
       (int 40))

  let print_two_plus_forty =
    (papp print_int [two_plus_forty])

end

let _ =
  Backend.initialise ~includes:[Sys.getcwd ()] ();
  let comp_env = Backend.initial_env () in
  let module_ident = Ident.create_persistent "Llama_Program" in
  let module Transl = Translate.Transl(LambdaIr.LambdaWrapper) in
  let lambda = Transl.translate_program module_ident comp_env Examples.print_two_plus_forty in
  try
    Backend.compile module_ident lambda "a.out"
  with
  | e ->
     Printf.eprintf "unhandled error: %s\n%s%!" (Printexc.to_string e) (Printexc.get_backtrace ())

