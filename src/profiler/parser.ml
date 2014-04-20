open Str
 
type rectype = Enter | Exit

type callentry =
  {
		ftype     : rectype;
		faddress  : string;
		callsite  : string;
		proc_id   : int;
		thread_id : int;
		t_sec     : string;
		t_nsec    : string;
		u_sec     : string;
		u_usec    : string;
		v_switch  : int;
		i_switch  : int; 
  }

type callgraph =  | Root of callentry
                  | Sibling of (callgraph * callentry) 
                  | Child of   (callgraph * callentry)
									  		
let regex_entry_exit = Str.regexp "[E|X]"

(* Split profile data record *)
let split = Str.split (Str.regexp_string ":")


                  
let ftype_to_string t =
 match t with
 | Enter -> "Enter"
 | Exit -> "Exit"


let record_to_string r =
  Printf.printf "[%s] function = %s\n" (ftype_to_string r.ftype) r.faddress
	
let parse_line (line: string) =
		match try Some(split line) with _ -> None with
	  | None -> None
		| Some ["E";func;callsite;pid;tid;tsec;nsec;usec;uusec;vsw;isw] ->
			Some { ftype = Enter; faddress = func; callsite = callsite;
			       proc_id = int_of_string tid; thread_id = int_of_string tid;
						 t_sec = tsec; t_nsec = nsec; u_sec   = usec; u_usec = uusec;
						 v_switch = int_of_string vsw; i_switch = int_of_string isw} 
		| Some ["X";func;callsite;pid;tid;tsec;nsec;usec;uusec;vsw;isw] ->
			Some { ftype = Exit; faddress = func; callsite = callsite;
			       proc_id = int_of_string tid; thread_id = int_of_string tid;
						 t_sec = tsec; t_nsec = nsec; u_sec   = usec; u_usec = uusec;
						 v_switch = int_of_string vsw; i_switch = int_of_string isw} 
		| _ -> None

let cg = Nil

let parse_profile_data filename =
  let ic = open_in filename in
  let rec parse in_ch cg =
  try
    let line = input_line in_ch in
		match parse_line line with
		| None -> parse in_ch
		| Some r -> 
			(match r.ftype with
			 | Enter -> Child of (cg, r); parse in_ch
			 | Exit ->  Sibling of (cg, r); parse in_ch)
  
  with End_of_file ->
    close_in in_ch
  in
  
  parse ic
