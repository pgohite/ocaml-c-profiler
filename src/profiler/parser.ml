open Parsedb
open Int64
open Util

module Parser =
struct

	(* Parse one line in profile data and return callentry *)
	let parse_line (line : string) : ParseDb.parseentry_e option =
		let open ParseDb in
		match try Some (Util.split line) with | _ -> None with
		| None -> None
		| Some
		([ "E"; func; callsite; pid; tid; tsec; nsec; usec; uusec; vsw; isw
		])
		->
				Some
				{
					ftype = FEnter;
					faddress = func;
					callsite = callsite;
					proc_id = pid;
					thread_id = tid;
					t_sec = Int64.of_string tsec;
					t_nsec = Int64.of_string nsec;
					u_sec = Int64.of_string usec;
					u_usec = Int64.of_string uusec;
					v_switch = int_of_string vsw;
					i_switch = int_of_string isw;
				}
		| Some
		([ "X"; func; callsite; pid; tid; tsec; nsec; usec; uusec; vsw; isw
		])
		->
				Some
				{
					ftype = FExit;
					faddress = func;
					callsite = callsite;
					proc_id = pid;
					thread_id = tid;
					t_sec = Int64.of_string tsec;
					t_nsec = Int64.of_string nsec;
					u_sec = Int64.of_string usec;
					u_usec = Int64.of_string uusec;
					v_switch = int_of_string vsw;
					i_switch = int_of_string isw;
				}
		| _ -> None
	
	(* Parse given profile data and convert it into a parseentry list *)
	let parse_profile (filename : string) =	
		(* Prase database to store result of parsing *)
		let parsedb : ParseDb.t = ParseDb.empty in
	
		(* Start parsing line by line *)
		let ic = open_in filename in
		let rec parse in_ch db =
			try
				let line = input_line in_ch
				in
				match parse_line line with
				| None -> parse in_ch db
				| Some e -> parse in_ch (ParseDb.insert_record db e)
			with | End_of_file -> let _ = close_in in_ch in db
		in parse ic parsedb
	
end
