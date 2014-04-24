open Int64
	
	type rectype = FEnter | FExit
	
	type parseentry =
  {
		ftype      : rectype;
		faddress   : int;
		callsite   : string;
		proc_id    : int;
		thread_id  : int;
    t_sec      : int64;
		t_nsec     : int64;
		u_sec      : int64;
		u_usec     : int64;
		v_switch   : int;
		i_switch   : int; 
  }
	
 type callentry =
  {
		ftype      : rectype;
		faddress   : string;
		callsite   : string;
		proc_id    : int;
		thread_id  : int;
    start_sec  : int64;
		start_nsec : int64;
		stop_sec   : int64;
	  stop_nsec  : int64;
		u_sec      : int64;
		u_usec     : int64;
		v_switch   : int;
		i_switch   : int; 
  }
	
type callgraph =  | Leaf
                  | Sibling of (callgraph * parseentry) 
                  | Child of   (callgraph * parseentry)

