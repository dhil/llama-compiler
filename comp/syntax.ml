(** Abstract syntax for the Untyped Lambda Calculus endowed with integers and primitives **)

type var = int
type binder = var * string
let fresh_binder name = (Utils.gensym (), name)


type t = Int of int
         | Var of var
         | Abs of binder * t
         | App of t * t
         | PrimApp of primitive * t list
and primitive = Print_Int
                | Plus


module Lam: sig
  val int : int -> t
  val var : var -> t
  val abs : string -> (var -> t) -> t
  val app : t -> t -> t
  val papp : primitive -> t list -> t
  val print_int : primitive
  val plus : primitive
end = struct
  let int n = Int n
  let var x = Var x
  let abs x_name body =
    let b = fresh_binder x_name in
    Abs (b, body (fst b))
  let app f x = App (f, x)
  let papp prim args = PrimApp (prim, args)
  let print_int = Print_Int
  let plus = Plus
end



