(* parser.ml *)
(* Parser for profile data*)
(* Pravin Gohite *)


type ftype = Enter | Exit

let parse_profile_data filename =
  let ic = open_in filename in
  let rec parse in_ch =
  try
    let line = input_line in_ch in 
    print_endline line;
    flush stdout;
    parse in_ch
  
  with End_of_file ->
    close_in in_ch
  in
  
  parse ic
