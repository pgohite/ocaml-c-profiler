(* OCAML C Profiler *)
(* May 2014, Pravin Gohite (pravin.gohite@gmail.com) *)

module type GENERATOR =
sig
  type t
  val empty -> t
	val gen_report 'a ->  'a -> unit
end