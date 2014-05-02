open Parsedb
open Parser
open Symresolver
open Callstats
open Callgraph
open Threadstats

let appname = ref ""
let datafile = ref "./profile.data"

let set_appname arg = appname := arg

let set_datafile arg = datafile := arg

let main =
	let speclist =
		[ ("-n", (Arg.Set_string appname), "Target application path");
		  ("-d", (Arg.Set_string datafile),
			"Profile data file (default: ./profile.data)") ] in
	let usage_msg = "OCAML C Application Profiler:"
	in
	(Arg.parse speclist print_endline usage_msg;
		if (Sys.file_exists !appname) <> true
		then
			(let _ =
					Printf.printf
						"Invalid application path, Application '%s' not found\n" !appname
				in exit 0)
		else ();
		
		if (Sys.file_exists !datafile) <> true
		then
			(let _ =
					Printf.printf "Invalid profile datafile path, file '%s' not found\n"
						!datafile
				in exit 0)
		else
			(* Start parsing *)
			(let parsedb = Parser.parse_profile !datafile in
				(* Build Symbol Table *)
				let symboltbl = SymResolver.build_symbol !appname
				in
				(* Generate Reports *)
				let open ParseDb
				in
				(ThreadStats.gen_report parsedb.threadstats;
				 CallStats.gen_report symboltbl parsedb.callstats;
				 CallGraph.gen_report symboltbl parsedb.callgraph;
					)))

let () = main
  
