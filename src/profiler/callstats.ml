open Int64 
open Symresolver
  
module CallStats =
  struct
    type elt = { time : int64; count : int }
    
    type t = (string, elt) Hashtbl.t
    
    let empty = { time = 0L; count = 0; }
      
    let singleton time count = { time = time; count = count; }
      
		let add cs time count =
			  singleton (Int64.add cs.time time) (cs.count + 1)

    (* Find call stats for given key *)
    let get_callstats (cstats : t) (key : string) =
      if Hashtbl.mem cstats key then Hashtbl.find cstats key else empty
      
    (* Printable string of a callstat entry *)
    let string_of_record symboltbl (k : string) (v : elt) : unit =
      Printf.printf
        "%-20s : Count: [%5d], Total Time: %10Ld uSec, Average Time: %10Ld uSec\n"
        (SymResolver.lookup symboltbl (int_of_string k)) v.count v.time
        (Int64.div v.time (Int64.of_int v.count))
      
    (* Generate callstat report *)
    let gen_report symboltbl (cstats : t) : unit =
      let _ =
        Printf.printf "%s"
          ("\n\n------------------------------------------" ^
             (" Call Statistic Report " ^
                "------------------------------------\n")) in
      let _ = Hashtbl.iter (fun k v -> string_of_record symboltbl k v) cstats
      in ()
      
  end
  
