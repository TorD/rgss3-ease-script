module Easing
	CUBIC_IN 			= "cubic_in"
	CUBIC_OUT 		= "cubic_out"
	CUBIC_IN_OUT 	= "cubic_in_out"

	def self.cubic_in(t, b, c, d)
		t /= d.to_f
		return c*t*t*t + b
	end

	def self.cubic_out(t, b, c, d)
		t /= d.to_f
		t -= 1
		return c*(t*t*t + 1) + b
	end

	def self.cubic_in_out(t, b, c, d)
		t /= d.to_f/2
		return c/2*t*t*t + b if t < 1
		t -= 2
		return c/2*(t*t*t + 2) + b
	end
end