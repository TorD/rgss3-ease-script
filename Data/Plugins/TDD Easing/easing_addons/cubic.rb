module Easing
	CUBIC_IN 			= "cubic_in"
	CUBIC_OUT 		= "cubic_out"
	CUBIC_IN_OUT 	= "cubic_in_out"

	def self.cubic_in(t, b, c, d)
		t /= d.to_f
		return c*t*t*t + b
	end
end