(* OCAML C Profiler *)
(* May 2014, Pravin Gohite (pravin.gohite@gmail.com) *)


open Util
  
module CallStack =
  struct
    type elt =
      {
				 stack : (string * int) list; index : int
      }
    
    type t = (int, elt) Hashtbl.t
    
    let empty =
      {
        stack = [];
        index = 0;
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
    let push (cstack : t) (tid : int) (faddr : string)  :  unit =
      let value =
        try let value = Hashtbl.find cstack tid in value
        with | Not_found -> empty
      in
        match value.stack with
        | [] ->
            Hashtbl.replace cstack tid
              { stack = [ (faddr, 1) ]; index = 1; }
        | (k, i) :: tl ->
            Hashtbl.replace cstack tid
              {
                stack = (faddr, (value.index + 1)) :: value.stack;
                index = value.index + 1;
              }
      
    let pop (cstack : t) (tid : int) : (string * int) =
      let value =
        try let value = Hashtbl.find cstack tid in value
        with | Not_found -> empty
      in
        match value.stack with
        | [] -> ("", 0)
        | (k, i) :: tl ->
            (Hashtbl.replace cstack tid
               { (value) with stack = tl;};
             (k, i))
  end
  
