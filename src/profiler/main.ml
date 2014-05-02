(* OCAML C Profiler *)
(* May 2014, Pravin Gohite (pravin.gohite@gmail.com) *)

open Parsedb
open Parser
open Symresolver
open Callstats
open Callgraph
open Threadstats
  
let depth = ref 32
  
let appname = ref ""
  
let datafile = ref "./profile.data"
  
let set_appname arg = appname := arg
  
let set_datafile arg = datafile := arg
  
let main =
	(* Command line arguments *)
	let usage_msg = "OCAML C Application Profiler:" in
  let speclist =
    [ ("-n", (Arg.Set_string appname), "Target application path");
      ("-p", (Arg.Set_string datafile), "Profile data file (default: ./profile.data)");
      ("-d", (Arg.Set_int depth), "Callgraph depth (Default : 32 )") ] in

    (* Prase arguments *)
    (Arg.parse speclist print_endline usage_msg;
	
	  (* Validate appname argument *)
     if (Sys.file_exists !appname) <> true
     then
       (let _ = Printf.printf "Invalid application path, Application '%s' not found\n" 
                 !appname in exit 0)
     else ();
		
	   (* Validate depth argument *)
     if !depth < 1 then
       (let _ = Printf.printf "Invalid Depth value '%d'\n" !depth in exit 0)
     else ();
	
	   (* Validate datafile argument *)	
     if (Sys.file_exists !datafile) <> true then
       (let _ = Printf.printf "Invalid profile datafile path, file '%s' not found\n" !datafile
        in exit 0)
     else ();
		
		(* Everything is fine. Start processing datafile *) 
    (let parsedb = Parser.parse_profile !datafile !depth in
			
    (* Build Symbol Table *)
     let symboltbl = SymResolver.build_symbol !appname in
       
		(* Generate Reports *)
     let open ParseDb in
     ThreadStats.gen_report parsedb.threadstats;
     CallStats.gen_report symboltbl parsedb.callstats;
     CallGraph.gen_report symboltbl parsedb.callgraph !depth))
  
let () = main
  
