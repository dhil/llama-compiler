(* A thin wrapper around the Lambda module from compiler-libs *)

module type LAMBDA_PRIMITIVES = sig
  type nonrec t = Lambda.primitive

  val add_int : t
end

module type LAMBDA_WRAPPER = sig
  type t = Lambda.lambda
  type program = Lambda.program
  module Primitives : LAMBDA_PRIMITIVES

  val int : int -> Lambda.structured_constant
  val const : Lambda.structured_constant -> t
  val var : Ident.t -> t
  val func : ?kind:[`Tupled | `Curried] -> Ident.t list -> t -> t
  val apply : t -> t list -> t
  val prim : Primitives.t -> t list -> t

  val transl_path : Env.t -> Path.t -> t
  val program : ?globals:Ident.Set.t -> main_module_block_size:int -> module_ident:Ident.t -> t -> Lambda.program
end

module LambdaWrapper : LAMBDA_WRAPPER
