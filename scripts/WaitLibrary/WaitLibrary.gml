///@func Waiter(time);
function Waiter(_f) constructor {
	f_max = _f;
	f_curr = _f;
	is_done = false;
	
	static wait = function() {
		if (is_done) return false;
		
		if (f_curr <= 0) {
			is_done = true;
			return true;
		}
			
		f_curr--;
	}
	
	static reset = function() {
		f_curr = f_max;
		is_done = false;
	}
	
	static overwrite = function(_f) {
		f_max = _f;
		f_curr = _f;
		is_done = false;
	}
}



