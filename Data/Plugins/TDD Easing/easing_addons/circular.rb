module Easing
	CIRC_IN			= "circ_in"
	CIRC_OUT		= "circ_out"
	CIRC_IN_OUT	= "circ_in_out"

	def self.circ_in(t, b, c, d)
		return -c * (Math.sqrt(1 - (t/=d.to_f)*t) - 1) + b
	end

	def self.circ_out(t, b, c, d)
		return c * Math.sqrt(1 - (t=t/d.to_f-1)*t) + b
	end

	def self.circ_in_out(t, b, c, d)
		d = d.to_f
		if (t/=d/2) < 1
			return -c/2 * (Math.sqrt(1 - t*t) - 1) + b
		else
			return c/2 * (Math.sqrt(1 - (t-=2)*t) + 1) + b
		end
	end
end