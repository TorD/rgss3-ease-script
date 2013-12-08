#==============================================================================
# ** Easing EXTENSION
#------------------------------------------------------------------------------
# Extended for: TDD Easing Script
# ===============================
# This extension adds 3 new easing methods to the Easing module:
# * QUAD_IN
# * QUAD_OUT
# * QUAD_IN_OUT
#
# How to use:
# ===========
# Use Game_Picture.easing = Easing::QUAD_IN (or any of the other three methods
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
  QUAD_IN       = "quad_ease_in"
  QUAD_OUT      = "quad_ease_out"
  QUAD_IN_OUT   = "quad_ease_in_out"

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