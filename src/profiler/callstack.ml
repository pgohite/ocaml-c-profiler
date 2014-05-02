(* This module implements callstack functionality. During parsing of profile*)
(* data we build a temporary call stack to emulate runtime graph *)
open Util
  
module CallStack =
  struct
    type elt =
      { stack : (string * int) list; index : int; start_time : Util.time;
        stop_time : Util.time; ptime : Util.time; invoked : int
      }
    
    type t = (int, elt) Hashtbl.t
    
    let empty =
      {
        stack = [];
        index = 0;
        start_time = Util.new_time;
        stop_time = Util.new_time;
        ptime = Util.new_time;
        invoked = 0;
      }
      
    let string_of_callstack cstack tid =
      let value =
        try let value = Hashtbl.find cstack tid in value
        with | Not_found -> empty in
      let rec helper stack =
        match stack with
        | [] -> Printf.sprintf "| [], %d" value.index
        | (k, i) :: tl -> Printf.sprintf "(%s, %d) | %s " k i (helper tl)
      in Printf.sprintf "[stack %x] %s\n" tid (helper value.stack)
      
    (* Get a unique call index for thread *)
    let get_index (cstack : t) (tid : int) : int =
      try let value = Hashtbl.find cstack tid in value.index
      with | Not_found -> 0
      
    (* Push a function to call stack for given thread *)
    let push (cstack : t) (tid : int) (faddr : string) (t : Util.time) :
      unit =
      let value =
        try let value = Hashtbl.find cstack tid in value
        with | Not_found -> { (empty) with start_time = t; }
      in
        match value.stack with
        | [] ->
            Hashtbl.replace cstack tid
              { (value) with stack = [ (faddr, 1) ]; index = 1; }
        | (k, i) :: tl ->
            Hashtbl.replace cstack tid
              {
                (value)
                with
                stack = (faddr, (value.index + 1)) :: value.stack;
                index = value.index + 1;
              }
      
    let pop (cstack : t) (tid : int) (t : Util.time) : (string * int) =
      let value =
        try let value = Hashtbl.find cstack tid in value
        with | Not_found -> empty
      in
        match value.stack with
        | [] -> ("", 0)
        | (k, i) :: tl ->
            (Hashtbl.replace cstack tid
               { (value) with stack = tl; stop_time = t; };
             (k, i))
      
    let invoked (cstack : t) (tid : int) : unit =
      try
        let value = Hashtbl.find cstack tid
        in
          Hashtbl.replace cstack tid
            { (value) with invoked = value.invoked + 1; }
      with | Not_found -> ()
      
    (* Printable string of a callstat entry *)
    let string_of_record (k : int) (v : elt) : unit =
      Printf.printf "%-10d \t %-10d \t %Ld \n" k v.invoked
        (Util.time_diff v.start_time v.stop_time)
      
    (* Generate callstat report *)
    let gen_report (cstack : t) : unit =
      let _ =
        Printf.printf "%s"
          ("\n----------------------------------------" ^
           " Thread Analysis Report " ^
           "------------------------------------------\n");
				Printf.printf "PID \t TID \t Invoked \t Lifetime";
			  Printf.printf "%s"
          ("\n----------------------------------------" ^
					 "--------------------------" ^
           "------------------------------------------\n") in
      let _ = Hashtbl.iter (fun k v -> string_of_record k v) cstack in ()
      
  end
  
