module type GENERATOR =
sig
  type t
  val empty -> t
	val gen_report 'a ->  'a -> unit
end