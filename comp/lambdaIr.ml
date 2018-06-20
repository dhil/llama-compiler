module type LAMBDA_PRIMITIVES = sig
  type nonrec t = Lambda.primitive

  val add_int : t
end

module LambdaPrimitives = struct
  open Lambda
  type nonrec t = primitive

  let add_int = Paddint
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

(* Lambda IR 4.06.x *)
module LambdaWrapper = struct
  module Primitives = LambdaPrimitives

  open Lambda
  type t = lambda
  type nonrec program = program

  let int n = Const_base (Asttypes.Const_int n)
  let const c = Lconst c
  let var id = Lvar id
  let func ?(kind=`Curried) params body =
    let lfun =
      { kind =
          (match kind with
          | `Curried -> Curried
          | `Tupled -> Tupled);
        params = params;
        body = body;
        attr = Lambda.default_function_attribute;
        loc = Location.none }
    in
    Lfunction lfun

  let apply f xs =
    let lapp =
      { ap_func = f;
        ap_args = xs;
        ap_loc = Location.none;
        ap_should_be_tailcall = false;
        ap_inlined = Default_inline;
        ap_specialised = Default_specialise }
    in
    Lapply lapp

  let prim p xs =
    Lprim (p, xs, Location.none)

  let transl_path env path =
    transl_value_path env path

  let program ?(globals=Ident.Set.empty) ~main_module_block_size ~module_ident code =
    { module_ident;
      main_module_block_size;
      required_globals = globals;
      code }
end
