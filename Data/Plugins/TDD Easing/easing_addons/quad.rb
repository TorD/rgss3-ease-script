module Easing
	QUAD_IN				= "quad_ease_in"
	QUAD_OUT			= "quad_ease_out"
	QUAD_IN_OUT 	= "quad_ease_in_out"

	def self.quad_ease_in(t, b, c, d)
		t /= d.to_f
		return c*t*t + b
	end

	def self.quad_ease_out(t, b, c, d)
		t /= d.to_f
		return -c * t*(t-2) + b;
	end

	def self.quad_ease_in_out(t, b, c, d)
		t /= d.to_f/2
		return c/2*t*t + b if t < 1
		t -= 1
		return -c/2 * (t*(t-2) - 1) + b
	end
end