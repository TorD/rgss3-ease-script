#==============================================================================
# ** Easing EXTENSION
#------------------------------------------------------------------------------
# Extended for: TDD Easing Script
# ===============================
# This extension adds 3 new easing methods to the Easing module:
# * ELASTIC_IN
# * ELASTIC_OUT
# * ELASTIC_IN_OUT
#
# How to use:
# ===========
# Use Game_Picture.easing = Easing::ELASTIC_IN (or any of the other three methods
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
  ELASTIC_IN      = "elastic_in"
  ELASTIC_OUT     = "elastic_out"
  ELASTIC_IN_OUT  = "elastic_in_out"

  def self.elastic_in(t, b, c, d)
    d=d.to_f
    s=1.70158
    p=0
    a=c
    return b if t==0
    return b+c if ((t/=d)==1)
    p=d*0.3 if p==0
    if a < c.abs
      a=c
      s=p/4
    else
      s = p/(2*Math::PI) * Math.asin(c/(a.nonzero? || 1))
    end
    return -(a*(2**(10*(t-=1))) * Math.sin( (t*d-s)*(2*Math::PI)/p )) + b
  end

  def self.elastic_out(t, b, c, d)
    d=d.to_f
    s=1.70158
    p=0
    a=c
    return b if t==0
    return b+c if ((t/=d)==1)
    p = d*0.3 if p==0
    if a < c.abs
      a=c
      s=p/4
    else
      s = p/(2*Math::PI) * Math.asin(c/(a.nonzero? || 1))
    end
    return a*(2**(-10*t)) * Math.sin( (t*d-s)*(2*Math::PI)/p ) + c + b
  end

  def self.elastic_in_out(t, b, c, d)
    d=d.to_f
    s=1.70158
    p=0
    a=c
    return b if t==0
    return b+c if ((t/=d/2)==2)
    p=d*(0.3*1.5) if p==0
    if a < c.abs
      a=c
      s=p/4
    else
      s = p/(2*Math::PI) * Math.asin(c/(a.nonzero? || 1))
    end
    return a*(2**(-10*(t-=1))) * Math.sin( (t*d-s)*(2*Math::PI)/p )*0.5 + c + b
  end

end

