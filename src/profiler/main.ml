open Printf
  
open Adt
  
open Parser
  
open Symresolver

open Callstats

  
let filename = "/home/prgohite/ocaml-c-profiler/profile.data"
let appname = "/home/prgohite/ocaml-c-profiler/sample"
  
(* Parse profile data *)
let parsedb = Parser.parse_profile filename
 
(* Build Symbol Table *) 
let symboltbl = SymResolver.build_symbol appname
 
let string_of_callstats (k : string) (v : callstats_e) =
  Printf.printf "%-20s\tCount = %-5d \t Avg Time = %Ld \t Total Time = %Ld\n"
    (SymResolver.lookup symboltbl (int_of_string k)) v.count
		(Int64.div v.time (Int64.of_int v.count)) v.time

let _ = let _ = CallStats.print_header in 
   Hashtbl.iter (fun k v -> string_of_callstats k v) parsedb.callstats

  
