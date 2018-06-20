open LambdaIr

(** Translation from Llama to Lambda **)
module Transl(Lambda : LAMBDA_WRAPPER) = struct
  module Idents = Utils.IntMap

  let lookup_builtin : Env.t -> string -> string -> Lambda.t =
    fun comp_env module_name fun_name ->
      let lfun, _ =
        Env.lookup_value
          (Longident.(Ldot (Lident module_name, fun_name)))
          comp_env
      in
      Lambda.transl_path comp_env lfun

  exception Unbound_variable of Syntax.var

  let lambda_of_llama : Env.t -> Syntax.t -> Lambda.t
    = fun comp_env expr ->
      let module Primitive = Lambda.Primitives in
      let open Syntax in
      let rec transl env = function
        | Int n ->
           Lambda.(const (int n))
        | Var x when not (Idents.mem x env) ->
           raise (Unbound_variable x)
        | Var x ->
           let ident = Idents.find x env in
           Lambda.var ident
        | Abs (b, body) ->
           let ident = Ident.create (snd b) in
           let env' = Idents.add (fst b) ident env in
           Lambda.func [ident] (transl env' body)
        | App (f, x) ->
           let f' = transl env f in
           let x' = transl env x in
           Lambda.apply f' [x']
        | PrimApp (p, xs) ->
           let xs' = List.map (transl env) xs in
           match p with
           | Print_Int ->
              let f = lookup_builtin comp_env "Llama_Builtins" "print_int_nl" in
              Lambda.apply f xs'
           | Plus ->
              Lambda.prim Primitive.add_int xs'
      in
      transl Utils.IntMap.empty expr

  let translate_program : Ident.t -> Env.t -> Syntax.t -> Lambda.program
    = fun module_ident comp_env expr ->
      let code = lambda_of_llama comp_env expr in
      Lambda.program
        ~main_module_block_size:0
        ~module_ident
        code
end
