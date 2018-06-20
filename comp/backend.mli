
val initialise : ?includes:string list -> unit -> unit
val initial_env : unit -> Env.t

val compile : Ident.t -> Lambda.program -> string -> unit
