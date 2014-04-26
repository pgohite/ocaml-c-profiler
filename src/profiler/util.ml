open Int64

module Util =
  struct
    type time = { sec : int64; usec : int64 }
    
		let get_time_nsec s ns =  { sec = s ; usec = Int64.div ns 1000L }
		let get_time_usec s us =  { sec = s ; usec = us }
		
    (* Return time diff in miliseconds *)
    let time_diff (t1 : time) (t2 : time) : int64 =
      let eval1 = (Int64.add (Int64.mul t1.sec 1000000L) t1.usec) in
			let eval2 = (Int64.add (Int64.mul t2.sec 1000000L) t2.usec) in
	    let t = Int64.sub eval2 eval1 in
			if (Int64.compare t 0L) > 0 then Int64.div t 1000L else 0L
 end
  
