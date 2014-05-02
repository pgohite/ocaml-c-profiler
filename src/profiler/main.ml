open Printf
open Parsedb
open Parser
open Symresolver
open Callstats
open Callgraph
  
let filename = "/home/prgohite/ocaml-c-profiler/profile.data"
let appname = "/home/prgohite/ocaml-c-profiler/sample"
  
(* Parse profile data *)
let parsedb = Parser.parse_profile filename
 
(* Build Symbol Table *) 
let symboltbl = SymResolver.build_symbol appname
 
(* Generate Reports *)
open ParseDb
let _ = CallStats.gen_report symboltbl parsedb.callstats;
        CallGraph.gen_report symboltbl parsedb.callgraph;
()
