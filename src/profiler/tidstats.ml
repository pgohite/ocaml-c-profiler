module TidStats =
  struct
    type t = { stack : (string * int) list; index : int }
    
    let empty = { stack = []; index = 0; }
      
    let debug = true
      
    let debug_print str = if debug = true then Printf.printf str else ()
      
    let string_of_stack tidtbl tid =
      let value =
        try let value = Hashtbl.find tidtbl tid in value
        with | Not_found -> empty in
      let rec helper stack =
        match stack with
        | [] -> Printf.sprintf "| [], %d" value.index
        | (k, i) :: tl -> Printf.sprintf "(%s, %d) | %s " k i (helper tl)
      in Printf.sprintf "[stack %x] %s\n" tid (helper value.stack)
      
    let stack_push tidtbl tid key =
      let value =
        try let value = Hashtbl.find tidtbl tid in value
        with | Not_found -> empty
      in
        match value.stack with
        | [] ->
            (Hashtbl.replace tidtbl tid { stack = [ (key, 1) ]; index = 1; };
             1)
        | (k, i) :: tl ->
            (Hashtbl.replace tidtbl tid
               {
                 stack = (key, (value.index + 1)) :: value.stack;
                 index = value.index + 1;
               };
             (* Printf.printf "Add: %s" (string_of_stack tidtbl tid); *)
             value.index + 1)
      
    let stack_pop tidtbl tid =
      let value =
        try let value = Hashtbl.find tidtbl tid in value
        with | Not_found -> empty
      in
        match value.stack with
        | [] -> ("", 0)
        | (k, i) :: tl ->
            (Hashtbl.replace tidtbl tid { (value) with stack = tl; };
             (* Printf.printf "Remove: %s" (string_of_stack tidtbl tid); *)
             (k, i))
      
  end
  
