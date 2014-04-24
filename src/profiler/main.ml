open Printf
  
open Adt
  
open Parser
  
open Symresolver
  
let filename = "/home/prgohite/ocaml-c-profiler/profile.data"
  
let appname = "/home/prgohite/ocaml-c-profiler/sample"
  
let db = Parser.parse_profile_data filename
  
let symtbl = SymResolver.build_symbol appname
  
let string_of_parseentry (e : parseentry) =
  Printf.printf "%s %s[%x] %d %d (%Ld %Ld)\n"
    (Parser.string_of_rectype e.ftype) (SymResolver.lookup symtbl e.faddress)
    e.faddress e.proc_id e.thread_id e.t_sec e.t_nsec
  
let _ = Parser.fold (fun e -> string_of_parseentry e) db
  
