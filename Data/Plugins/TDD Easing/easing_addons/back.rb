#==============================================================================
# ** Easing EXTENSION
#------------------------------------------------------------------------------
# Extended for: TDD Easing Script
# ===============================
# This extension adds 3 new easing methods to the Easing module:
# * BACK_IN
# * BACK_OUT
# * BACK_IN_OUT
#
# How to use:
# ===========
# Use Game_Picture.easing = Easing::BACK_IN (or any of the other three methods
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
  BACK_IN     = "back_in"
  BACK_OUT    = "back_out"
  BACK_IN_OUT = "back_in_out"

  # This is the intensity of the back "sling" effect. Higher = stronger
  SLING       = 1.70158

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