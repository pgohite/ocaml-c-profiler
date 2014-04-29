open Int64
  
open Util
  
open Hashtbl
  
open Callstats
  
open Tidstats
 
open Util

type rectype = | FEnter | FExit

type switch = { i_switch : int; v_switch : int }

type parseentry =
  { ftype : rectype; faddress : string; callsite : string; proc_id : string;
    thread_id : string; t_sec : int64; t_nsec : int64; u_sec : int64;
    u_usec : int64; v_switch : int; i_switch : int
  }

type callentry_e =
  { faddress : string; proc_id : int; thread_id : int;
    start_time : Util.time; stop_time : Util.time; start_ptime : Util.time;
    stop_ptime : Util.time; start_switch : switch; stop_switch : switch
  }
	
type elt =
  { 
		key : string; sibling : callgraph_t; child : callgraph_t; state : bool;
		time : int64
  }
	
and callgraph_t = Leaf | Node of elt

type tidtable_t = (int, TidStats.t) Hashtbl.t

type callstats_t = (string, CallStats.t) Hashtbl.t

type calltable_t = (string, callentry_e) Hashtbl.t

type profiledb =
  { 
		calltable : calltable_t;
	  callstats : callstats_t; 
		tidtable : tidtable_t;
    calltree : callgraph_t;
  }
