module Easing
	EXPO_IN			= "expo_in"
	EXPO_OUT		= "expo_out"
	EXPO_IN_OUT	= "expo_in_out"

	def self.expo_in(t, b, c, d)
		return (t==0) ? b : c * (2**(10 * (t/d.to_f - 1))) + b
	end

	def self.expo_out(t, b, c, d)
		return (t==d) ? b+c : c * (-(2**(-10 * t/d.to_f)) + 1) + b
	end

	def self.expo_in_out(t, b, c, d)
		d = d.to_f
		return b if t==0
		return b+c if t==d
		if (t/=d/2) < 1
			return c/2 * (2**(10 * (t - 1))) + b
		else
			return c/2 * (-(2**(-10 * (t-=1))) + 2) + b
		end
	end
end