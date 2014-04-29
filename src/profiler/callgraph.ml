open Int64
  
open Symresolver
  
open Util
  
open Adt
  
module CallGraph =
  struct
    type t = Adt.callgraph_t
    
    let empty = Leaf
      
    let insert (prfdb : profiledb) (key : string) (time : int64)
               (entry : bool) =
      let rec __insert (graph : t) =
        match graph with
        | Leaf ->
            Node
              {
                key = key;
                sibling = Leaf;
                child = Leaf;
                state = true;
                time = 0L;
              }
        | Node e ->
            if e.key = key
            then Node { (e) with state = false; time = time; }
            else
              if e.state = true
              then Node { (e) with child = __insert e.child; }
              else Node { (e) with sibling = __insert e.sibling; }
      in __insert prfdb.calltree
      
    let gen_report symboltbl prfdb =
      let _ =
        Printf.printf "%s"
          ("\n------------------------------------------" ^
             (" Call Graph Report " ^
                "------------------------------------------------\n")) in
      let rec gen_callgraph indent graph =
        match graph with
        | Leaf -> ()
        | Node e ->
            let faddress = List.hd (Util.split e.key) in
            let fname = SymResolver.lookup symboltbl (int_of_string faddress)
            in
              (Printf.printf "%s|\n" indent;
               Printf.printf "%sx--> %s [%Ld uSec]\n" indent fname e.time;
               gen_callgraph (indent ^ "|    ") e.child;
               gen_callgraph indent e.sibling)
      in gen_callgraph "" prfdb.calltree
      
  end
  
