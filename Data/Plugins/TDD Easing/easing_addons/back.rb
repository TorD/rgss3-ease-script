module Easing
	BACK_IN			= "back_in"
	BACK_OUT		= "back_out"
	BACK_IN_OUT	= "back_in_out"

	SLING				= 1.70158 # This is the intensity of the back "sling" effect

	def self.back_in(t, b, c, d)
		s = SLING
		d = d.to_f
		return c*(t/=d)*t*((s+1)*t - s) + b
	end

	def self.back_out(t, b, c, d)
		s = SLING
		d = d.to_f
		return c*((t=t/d-1)*t*((s+1)*t + s) + 1) + b
	end

	def self.back_in_out(t, b, c, d)
		s = SLING
		d = d.to_f
		if ((t/=d/2) < 1)
			return c/2*(t*t*(((s*=(1.525))+1)*t - s)) + b
		else
			return c/2*((t-=2)*t*(((s*=(1.525))+1)*t + s) + 2) + b
		end
	end
end