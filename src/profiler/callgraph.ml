(* OCAML C Profiler *)
(* May 2014, Pravin Gohite (pravin.gohite@gmail.com) *)

open Int64 
open Symresolver
open Util
  
module CallGraph =
  struct
    type elt =
      { key : string; sibling : t; child : t; state : bool; time : int64
      }

      and t =
      | Leaf | Node of elt
    
    let empty = Leaf
      
    let insert (ctree : t) (key : string) (time : int64) (entry : bool) (depth : int) =
      let rec __insert (graph : t) d =
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
              then
								if d < depth then 
								 Node { (e) with child = __insert e.child (d + 1); }
								else 
								 Node e
              else Node { (e) with sibling = __insert e.sibling d; }
      in __insert ctree 0
      
    let gen_report symboltbl (ctree : t) (depth : int) =
      let _ =
        Printf.printf "%s"
          ("\n\n------------------------------------------" ^
             (" Call Graph Report " ^
                "----------------------------------------\n")) in
      let rec gen_callgraph indent graph d =
        match graph with
        | Leaf -> ()
        | Node e ->
            let faddress = List.hd (Util.split e.key) in
            let fname = SymResolver.lookup symboltbl (int_of_string faddress)
            in
              (Printf.printf "%s|\n" indent;
               Printf.printf "%sx--> %s [%Ld uSec]\n" indent fname e.time;
							 if d < depth then 
								gen_callgraph (indent ^ "|    ") e.child (d+1);
               gen_callgraph indent e.sibling d)
      in gen_callgraph "" ctree 0
      
  end
  
