open Int64
  
open Symresolver
  
module CallStats =
  struct
    type t = { time : int64; count : int }
    
    let empty = { time = 0L; count = 0; }
      
    let singleton time count = { time = time; count = count; }
      
    let string_of_record symboltbl (k : string) (v : t) : unit =
      Printf.printf
        "%-10s : Count: [%5d], Total Time: %10Ld uSec, Average Time: %10Ld uSec\n"
        (SymResolver.lookup symboltbl (int_of_string k)) v.count v.time
        (Int64.div v.time (Int64.of_int v.count))
      
    let gen_report symboltbl callstats =
      let _ =
        Printf.printf "%s"
          ("\n------------------------------------------" ^
             (" Call Statistic Report " ^
                "--------------------------------------------\n")) in
      let _ =
        Hashtbl.iter (fun k v -> string_of_record symboltbl k v) callstats
      in ()
      
  end
  
