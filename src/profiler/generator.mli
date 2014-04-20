module type GENERATOR =
sig
  type t
  type elt
  val empty : t
  val is_empty : t -> bool
  val insert : elt -> t -> t
  val fold : (elt -> 'a -> 'a) -> 'a -> t -> 'a
  val gen_report t -> unit
end
