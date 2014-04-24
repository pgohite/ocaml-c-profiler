module CallStats =
struct
	type key : string
	
  type value = 
	  {
		  count      : int;
		  totaltime  : int;
	  }
	
	type t = elt list
	
	let empty = []
	
	let is_empty lst = (List.length lst = 0)
	
	let insert lst name cnt time = {name = name; count = cnt; totaltime = time} :: lst
	
	let insert_record lst e = e :: lst
	
	let fold = List.fold_left
	
	let print_header =
		Printf.printf "Function\tCount\tTotal Time\n";
		Printf.printf "======================================================================" 
		
	let record_to_string e =
    Printf.sprintf "%s\t%d\t%d\n" e.name e.count e.totaltime
		
	let rec gen_report lst =
    match lst with
    | [] -> Printf.printf "Empty Call Stats"
		| [hd] -> Printf.printf "%s" (record_to_string hd)
		| hd :: tl ->
        let _ = Printf.printf "%s" (record_to_string hd) in
			  gen_report tl
  
	let insert ht e =
		match e with
		| 
	let rec build symtbl graph =
		match graph with
		| Leaf -> []
end