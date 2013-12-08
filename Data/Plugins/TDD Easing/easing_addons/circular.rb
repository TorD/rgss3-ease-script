#==============================================================================
# ** Easing EXTENSION
#------------------------------------------------------------------------------
# Extended for: TDD Easing Script
# ===============================
# This extension adds 3 new easing methods to the Easing module:
# * CIRC_IN
# * CIRC_OUT
# * CIRC_IN_OUT
#
# How to use:
# ===========
# Use Game_Picture.easing = Easing::CIRC_IN (or any of the other three methods
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
  CIRC_IN     = "circ_in"
  CIRC_OUT    = "circ_out"
  CIRC_IN_OUT = "circ_in_out"

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