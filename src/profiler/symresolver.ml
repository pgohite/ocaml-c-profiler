  module SymResolver =
  struct
    exception InvalidSymbol
      
    let split lst =
      List.filter (fun s -> s <> "") (Str.split (Str.regexp_string ":") lst)
      
    let build_symbol (filename : string) =
      let symtbl = Hashtbl.create 50 in
      let ic =
        Unix.open_process_in
          ("objdump  -t -j .text " ^
             (filename ^ (" | grep ' g ' " ^ "| awk '{print $1 \":\" $6}'")))
      in
        ((try
            while true do
              let line = input_line ic
              in
                match try Some (split line) with | _ -> None with
                | None -> ()
                | Some ([ key; value ]) ->
                    Hashtbl.replace symtbl (int_of_string ("0x" ^ key)) value
                | Some lst -> raise InvalidSymbol
              done
          with | End_of_file -> ignore (Unix.close_process_in ic));
         symtbl)
      
    let lookup tbl sym =
      try Hashtbl.find tbl sym with | Not_found -> string_of_int sym
      
  end
