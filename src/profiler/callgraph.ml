open Int64
  
open Symresolver
  
open Util
  
module CallGraph =
  struct
    type elt =
      { 
				key : string; sibling : t; child : t; state : bool; time : int64
      }

      and t =
      | Leaf | Node of elt
    
    let empty = Leaf
		
    let insert (ctree : t) (key : string) (time : int64) (entry : bool) =
      let rec __insert (graph : t) =
        match graph with
        | Leaf -> 			Printf.printf "Adding to Leaf\n";
            Node
              {
                key = key;
                sibling = Leaf;
                child = Leaf;
                state = true;
                time = 0L;
              }
							
        | Node e ->
					  Printf.printf "Adding to Node\n";
            if e.key = key
            then Node { (e) with state = false; time = time; }
            else
              if e.state = true
              then Node { (e) with child = __insert e.child; }
              else Node { (e) with sibling = __insert e.sibling; }
      in __insert ctree
      
    let gen_report symboltbl (ctree : t) =
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
      in gen_callgraph "" ctree
      
  end
  
