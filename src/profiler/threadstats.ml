module ThreadStats = 
struct
	type elt =
	{
		tid          : int
		pid          : int
		invoked      : int
		lifetime     : int
		exectime     : int
		profiledtime : int
		cputime      : float
	}
	
	type t = list thread_record
	
	
end