open Adt
  
open Int64
  
open Util
  
module Parser =
  struct
    type t = Adt.parseentry
    
    (* Split profile data record *)
    let split = Str.split (Str.regexp_string ":")
      
    let string_of_rectype t =
      match t with | FEnter -> "--->" | FExit -> "<---"
      
    let string_of_parseentry symt (e : parseentry) =
      Printf.printf "%s %s %s %s (%Ld %Ld)\n" (string_of_rectype e.ftype)
        e.faddress e.proc_id e.thread_id e.t_sec e.t_nsec
      
    let rec fold f lst =
      match lst with | [] -> () | hd :: tl -> let _ = f hd in fold f tl
      
    (* Find call stats for given key *)
    let get_callstats (prfdb : profiledb) (key : string) =
      if Hashtbl.mem prfdb.callstats key
      then 
				Hashtbl.find prfdb.callstats key
      else 
				{ time = 0L; count = 0; }
      
    let insert_record (prfdb : profiledb) (r : parseentry) : profiledb =
      (* Build key for calltable, function address, callsite and thread_id*)
      (* creates unique entry for each call in excecution *)
      let ct_key = r.faddress ^ (r.callsite ^ r.thread_id)
      in
        match r.ftype with
        | FEnter ->
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
            let _ = Hashtbl.add prfdb.calltable ct_key ct_value in prfdb
        | FExit -> (* We must have a calltable entry for this function *)
            if Hashtbl.mem prfdb.calltable ct_key
            then (* Get or create callstats entry *)
	            (let curr_callstats = get_callstats prfdb r.faddress in
               (* Get entry of enter event *)
               let curr_callentry = Hashtbl.find prfdb.calltable ct_key in
               (* Get time of enter event *)
               let stop_time = Util.get_time_nsec r.t_sec r.t_nsec in
               (* Get time diff of between enter and exit event *)
               let time =
                 Util.time_diff stop_time curr_callentry.start_time in
               (* Increament time and count for this function *)
               let new_callstats =
                 {
                   time = Int64.add curr_callstats.time time;
                   count = curr_callstats.count + 1;
                 } in
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
               let _ =
                 Hashtbl.replace prfdb.calltable ct_key new_callentry in
               let _ =
                 Hashtbl.replace prfdb.callstats r.faddress new_callstats
               in prfdb)
            else
              (* This is unexpected, every function call must have a corresponding*)
              (* enter event *)
              (let _ =
                 Printf.printf
                   "Error: Found callentry without enter event!!\n"
               in prfdb)
      
    (* Parse one line in profile data and return callentry *)
    let parse_line (line : string) : parseentry option =
      match try Some (split line) with | _ -> None with
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
      let prfdb : profiledb =
        { calltable = Hashtbl.create 100; callstats = Hashtbl.create 100; } in
      let ic = open_in filename in
      let rec parse in_ch db =
        try
          let line = input_line in_ch
          in
            match parse_line line with
            | None -> parse in_ch db
            | Some e -> parse in_ch (insert_record db e)
        with | End_of_file -> let _ = close_in in_ch in db
      in 
			parse ic prfdb
  end
  
