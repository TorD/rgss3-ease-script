#==============================================================================
# ** Easing EXTENSION
#------------------------------------------------------------------------------
# Extended for: TDD Easing Script
# ===============================
# This extension adds 3 new easing methods to the Easing module:
# * CUBIC_IN
# * CUBIC_OUT
# * CUBIC_IN_OUT
#
# How to use:
# ===========
# Use Game_Picture.easing = Easing::CUBIC_IN (or any of the other three methods
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
  CUBIC_IN      = "cubic_in"
  CUBIC_OUT     = "cubic_out"
  CUBIC_IN_OUT  = "cubic_in_out"

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
    c = c.to_f
    t /= d.to_f/2
    return c/2*t*t*t + b if t < 1
    t -= 2
    return c/2*(t*t*t + 2) + b
  end
end