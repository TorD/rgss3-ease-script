module Easing
	BOUNCE_IN			= "bounce_in"
	BOUNCE_OUT		= "bounce_out"
	BOUNCE_IN_OUT	= "bounce_in_out"

	def self.bounce_in(t, b, c, d)
		return c - self::bounce_out(d-t, 0, c, d) + b
	end

	def self.bounce_out(t, b, c, d)
		if (t/=d.to_f) < (1/2.75)
			return c*(7.5625*t*t) + b
		elsif t < (2/2.75)
			return c*(7.5625*(t-=(1.5/2.75))*t + 0.75) + b
		elsif t < (2.5/2.75)
			return c*(7.5625*(t-=(2.25/2.75))*t + 0.9375) + b
		else
			return c*(7.5625*(t-=(2.625/2.75))*t + 0.984375) + b
		end
	end

	def self.bounce_in_out(t, b, c, d)
		if t < d.to_f/2
			return bounce_in(t*2, 0, c, d) * 0.5 + b
		else
			return bounce_out(t*2-d, 0, c, d) * 0.5 + c*0.5 + b
		end
	end
end