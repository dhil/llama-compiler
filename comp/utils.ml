let gensym =
  let counter = ref (-1) in
  fun () ->
    incr counter; !counter

module IntMap = Map.Make(struct type t = int
                                let compare = Pervasives.compare
                         end)
