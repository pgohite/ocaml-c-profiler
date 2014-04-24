open Adt
  
open Int64
  
module Parser =
  struct
    type t = Adt.parseentry
    
    let regex_entry_exit = Str.regexp "[E|X]"
      
    (* Split profile data record *)
    let split = Str.split (Str.regexp_string ":")
      
    let string_of_rectype t =
      match t with | FEnter -> "--->" | FExit -> "<---"
      
    let string_of_parseentry symt (e : parseentry) =
      Printf.printf "%s %d %d %d (%Ld %Ld)\n" (string_of_rectype e.ftype)
        e.faddress e.proc_id e.thread_id e.t_sec e.t_nsec
      
    let rec fold f lst =
      match lst with | [] -> () | hd :: tl -> let _ = f hd in fold f tl
      
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
              faddress = int_of_string func;
              callsite = callsite;
              proc_id = int_of_string tid;
              thread_id = int_of_string tid;
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
              faddress = int_of_string func;
              callsite = callsite;
              proc_id = int_of_string tid;
              thread_id = int_of_string tid;
              t_sec = Int64.of_string tsec;
              t_nsec = Int64.of_string nsec;
              u_sec = Int64.of_string usec;
              u_usec = Int64.of_string uusec;
              v_switch = int_of_string vsw;
              i_switch = int_of_string isw;
            }
      | _ -> None
      
    let parse_profile_data filename =
      let ic = open_in filename in
      let rec parse in_ch lst =
        try
          let line = input_line in_ch
          in
            match parse_line line with
            | None -> parse in_ch lst
            | Some e -> parse in_ch (e :: lst)
        with | End_of_file -> let _ = close_in in_ch in lst
      in parse ic []
      
  end
  
