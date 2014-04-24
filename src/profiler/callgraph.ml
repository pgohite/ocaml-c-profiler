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
	
	
	let parse_line line
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