(* OCAML C Profiler *)
(* May 2014, Pravin Gohite (pravin.gohite@gmail.com) *)

open Util
open Int64

module ThreadStats =
struct
	type elt =
		{
			tid : string;
			pid : string;
			start_time : Util.time;
			stop_time : Util.time;
			invoked : int;
			lifetime : int64
		}
	
	type t = (string, elt) Hashtbl.t
	
	let empty =
		{
			tid = ""; pid = ""; 
			start_time = Util.new_time;
			stop_time = Util.new_time;
			invoked = 0; lifetime = 0L;
		}
		
	(* Update Invoke count for thread *)
	let invoked (tstats : t) (tid : string) : unit =
		try
			let value = Hashtbl.find tstats tid
			in
			Hashtbl.replace tstats tid
				{ (value) with invoked = value.invoked + 1; }
		with | Not_found -> ()
	
	(* Update  start time for thread *)	
	 let start (tstats : t) (tid : string) (pid : string) (time : Util.time) : unit =
		  try let _ = Hashtbl.find tstats tid in ()
		  with Not_found -> 
			Hashtbl.replace tstats tid { empty with tid = tid; pid = pid; start_time = time}

		(* Update stop time for thread *)
	  let stop (tstats : t) (tid : string) (time : Util.time) : unit =
		try
			let value = Hashtbl.find tstats tid
			in
			Hashtbl.replace tstats tid
				{ (value) with stop_time = time; }
		with | Not_found -> ()
	
	(* Printable string of a callstat entry *)
	let string_of_record (r : elt) : unit =
		Printf.printf "%-10s \t %-10s \t %-5d \t\t %Ld uSec\n" r.pid r.tid r.invoked
			(Util.time_diff r.start_time r.stop_time)
	
	(* Generate callstat report *)
	let gen_report (tstats : t) : unit =
		let _ =
			Printf.printf "%s"
				("\n\n------------------------" ^
					" Thread Analysis Report " ^
					"-------------------------\n");
			Printf.printf "PID \t\t TID \t\t Invoked \t Lifetime";
			Printf.printf "%s"
				("\n-------------------------" ^
					"--------------------------" ^
					"----------------------\n") in
		let _ = Hashtbl.iter (fun _ v -> string_of_record v) tstats in ()
end