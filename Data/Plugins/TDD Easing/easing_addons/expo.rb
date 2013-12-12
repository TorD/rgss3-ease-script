#==============================================================================
# ** Easing EXTENSION
#------------------------------------------------------------------------------
# Extended for: TDD Easing Script
# ===============================
# This extension adds 3 new easing methods to the Easing module:
# * EXPO_IN
# * EXPO_OUT
# * EXPO_IN_OUT
#
# How to use:
# ===========
# Use Game_Picture.easing = Easing::EXPO_IN (or any of the other three methods
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
  EXPO_IN     = "expo_in"
  EXPO_OUT    = "expo_out"
  EXPO_IN_OUT = "expo_in_out"

  def self.expo_in(t, b, c, d)
    return (t==0) ? b : c * (2**(10 * (t/d.to_f - 1))) + b
  end

  def self.expo_out(t, b, c, d)
    return (t==d) ? b+c : c * (-(2**(-10 * t/d.to_f)) + 1) + b
  end

  def self.expo_in_out(t, b, c, d)
    c = c.to_f
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