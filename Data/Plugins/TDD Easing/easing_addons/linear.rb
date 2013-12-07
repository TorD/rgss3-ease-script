#==============================================================================
# ** Easing EXTENSION
#------------------------------------------------------------------------------
# Extended for: TDD Easing Script
# ===============================
# This extension adds the LINEAR easing method to the Easing module. This is the
# default easing method, which is identical to the default easing performed in
# VXAce
#
# How to use:
# ===========
# Use Game_Picture.easing = Easing::LINEAR (or any of the other three methods
# listed above) to apply before performing moving or tinting of the Game_Picture
# class.
#
# Credit:
# =======
# - Galenmereth / Tor Damian Design
#
# License:
# ========
# Free for non-commercial and commercial use. Credit greatly appreciated but
# not required. Share script freely with everyone, but please retain this
# description area unless you change the script completely. Thank you.
#==============================================================================
module Easing
	LINEAR 			= "linear"

	# t = Current time (frame)
	# b = Start value
	# c = Desired change in value
	# d = Duration total (frames)
	# Returns: Value modified by t
	def self.linear(t, b, c, d)
		return c*t/d.to_f + b
	end
end