(* OCAML C Profiler *)
(* May 2014, Pravin Gohite (pravin.gohite@gmail.com) *)

open Int64
open Util
open Hashtbl
open Callstats
open Callgraph
open Callstack
open Threadstats
  
module ParseDb =
  struct
    type rectype = | FEnter | FExit
    
    type switch = { i_switch : int; v_switch : int }
    
    type parseentry_e =
      { ftype : rectype; faddress : string; callsite : string;
        proc_id : string; thread_id : string; t_sec : int64; t_nsec : int64;
        u_sec : int64; u_usec : int64; v_switch : int; i_switch : int
      }
    
    type callentry_e =
      { faddress : string; proc_id : int; thread_id : int;
        start_time : Util.time; stop_time : Util.time;
        start_ptime : Util.time; stop_ptime : Util.time;
        start_switch : switch; stop_switch : switch
      }
    
    type t =
      { calltable : (string, callentry_e) Hashtbl.t; callstats : CallStats.t;
        callgraph : CallGraph.t; callstack : CallStack.t; 
				threadstats : ThreadStats.t;
				depth : int;
				last_tid : string
      }
    
    let max_thread = 16
      
    let max_callentry = 4096
      
    let new_db (depth : int) : t =
      {
        calltable = Hashtbl.create max_callentry;
        callstats = Hashtbl.create max_callentry;
        callgraph = CallGraph.empty;
        callstack = Hashtbl.create max_thread;
				threadstats = Hashtbl.create max_thread;
				depth = depth;
        last_tid = "";
      }
      
    (* Process parsed line and update parse database with processed        *)
    (* results                                                             *)
    let insert_record (db : t) (r : parseentry_e) : t =
      (* Build key for calltable, function address, callsite and thread_id *)
      (* creates unique entry for each call in excecution                  *)
      match r.ftype with
      | FEnter -> (* Push the function on thread stack *)
          (* Enteing function, push on to stack *)
          CallStack.push db.callstack (int_of_string r.thread_id) r.faddress;   
					(* Thread changed, update thread stats *) 
           if db.last_tid <> r.thread_id
           then 
						(ThreadStats.start db.threadstats r.thread_id r.proc_id
						                  (Util.get_time_nsec r.t_sec r.t_nsec);
						 ThreadStats.invoked db.threadstats r.thread_id);
					
           (* Get a thread wide unique integer to create entry key *)
           let idx =
             CallStack.get_index db.callstack (int_of_string r.thread_id) in
           (* Construct key for hashtable *)
           let ct_key =
             r.faddress ^
               (":" ^ (r.thread_id ^ (r.callsite ^ (string_of_int idx)))) in
           (* Construct value for hash table *)
           let ct_value =
             {
               faddress = r.faddress;
               proc_id = int_of_string r.proc_id;
               thread_id = int_of_string r.thread_id;
               start_time = Util.get_time_nsec r.t_sec r.t_nsec;
               stop_time = Util.get_time_nsec 0L 0L;
               start_ptime = Util.get_time_usec r.u_sec r.u_usec;
               stop_ptime = Util.get_time_usec 0L 0L;
               start_switch =
                 { i_switch = r.i_switch; v_switch = r.v_switch; };
               stop_switch = { i_switch = 0; v_switch = 0; };
             } in
           (* Add key, value pair to hash table *)
           let _ = Hashtbl.add db.calltable ct_key ct_value
           in
             {
               (db)
               with
               callgraph = CallGraph.insert db.callgraph ct_key 0L true db.depth;
               last_tid = r.thread_id;
             }
      | FExit -> (* We must have a calltable entry for this function *)
          let (fadd, idx) =
						ThreadStats.stop db.threadstats r.thread_id 
						                (Util.get_time_nsec r.t_sec r.t_nsec);
            CallStack.pop db.callstack (int_of_string r.thread_id) in
          let ct_key =
            r.faddress ^
              (":" ^ (r.thread_id ^ (r.callsite ^ (string_of_int idx))))
          in
            (* (Printf.printf "Searching for key %s tid-add %s \n" ct_key  *)
            (* fadd;                                                       *)
            if Hashtbl.mem db.calltable ct_key
            then (* Get or create callstats entry *)
              (let curr_callstats =
                 CallStats.get_callstats db.callstats r.faddress in
               (* Get entry of enter event *)
               let curr_callentry = Hashtbl.find db.calltable ct_key in
               (* Get time of enter event *)
               let stop_time = Util.get_time_nsec r.t_sec r.t_nsec in
               (* Get time diff of between enter and exit event *)
               let time =
                 Util.time_diff curr_callentry.start_time stop_time in
               (* Increament time and count for this function *)
               let new_callstats = CallStats.add curr_callstats time 1 in
               (* Update exit time stamp and resource usage *)
               let new_callentry =
                 {
                   (curr_callentry)
                   with
                   stop_time = stop_time;
                   stop_ptime = Util.get_time_usec r.u_sec r.u_usec;
                   stop_switch =
                     { i_switch = r.i_switch; v_switch = r.v_switch; };
                 } in
               (* Finally update new data to end return new database *)
               let _ = Hashtbl.replace db.calltable ct_key new_callentry in
               let _ = Hashtbl.replace db.callstats r.faddress new_callstats
               in
                 {
                   (db)
                   with
                   callgraph =
                     CallGraph.insert db.callgraph ct_key time false db.depth;
                   last_tid = r.thread_id;
                 })
            else
              (* This is unexpected, every function call must have a       *)
              (* corresponding enter event                                 *)
              (let _ =
                 Printf.printf
                   "Error: Found callentry without enter event!!\n"
               in db)
  end
  
