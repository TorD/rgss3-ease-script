#==============================================================================
# ** TDD Ease Module
#------------------------------------------------------------------------------
# Version:  1.0.1
# Date:     08/12/2013
# Author:   Galenmereth / Tor Damian Design
#
# Changelog
# =========
# Introduced the TDD module namespace and Ease_Object instead of using a hash
# 
# Description
# ===========
# This module is used to apply an easing algorithm to an object's parameters
# over X amount of frames. Easing methods can be extended through adding
# static methods to the Easing module. The default easing method is
# Easing::LINEAR and is identical to the default easing provided in VXAce
#
# How to use in event editor:
# ===========================
# Included with this script is an extension to the Game_Picture class that lets
# you change the easing method of the event editor commands Move Picture and
# Tint Picture.
#
# Before calling Move Picture and Tint Picture for a picture in the event editor,
# make a script call like this:
#   Game_Picture.easing = Easing::ELASTIC_OUT
# This will set the easing method to the ELASTIC_OUT algorithm. When you erase
# any picture, the easing method is reset to the default (Easing::LINEAR by
# default)
#
# You can provide different easing methods for different events as well, by
# setting Game_Picture.easing between each call. It is remembered for each
# event call the moment it starts.
#
# If you wish to set the default easing, you use:
#   Game_Picture.easing_default = Easing::QUAD_IN
#
# This is the list of included easing methods (the part that go after Easing::)
#
# * LINEAR (default, and like the default in VXAce)
#
# * BACK_IN
# * BACK_IN_OUT
# * BACK_OUT
#
# * BOUNCE_IN
# * BOUNCE_IN_OUT
# * BOUNCE_OUT
#
# * CIRC_IN
# * CIRC_IN_OUT
# * CIRC_OUT
#
# * CUBIC_IN
# * CUBIC_IN_OUT
# * CUBIC_OUT
#
# * ELASTIC_IN
# * ELASTIC_IN_OUT
# * ELASTIC_OUT
#
# * EXPO_IN
# * EXPO_IN_OUT
# * EXPO_OUT
#
# * QUAD_IN
# * QUAD_IN_OUT
# * QUAD_OUT
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

#/////////////////////////////////////////////////////////////////////////
#// DANGER - BELOW IS ARCANE UNLESS YOU KNOW WHAT YOU'RE DOING - DANGER //
#/////////////////////////////////////////////////////////////////////////

$imported = {} if $imported.nil?
$imported["TDD Easing Core"] = true
module TDD
  module Ease
    @@easings = []
    
    #--------------------------------------------------------------------------
    # * Ease Parameters To Given Attribute Values
    # Params:
    # =======
    # - target (Object)
    #     An object which has the attributes listed in attributes and which 
    #     you want to effect with an easing FROM its current values TO
    #     the values given in the attributes hash
    # - frames (Integer)
    #     The amount of frames to apply the easing over
    # - attributes (Hash)
    #     Hash of attributes and target values for the attributes you wish to
    #     affect on the target object
    # - options (Hash)
    #     Hash of optional options:
    #       :easing           =>  Easing method to use (default = Easing::LINEAR)
    #       :observers        =>  Array of observer objects (default = nil)
    #       :call_on_update   =>  Method to call on observers every update tick
    #                             (default = false)
    #       :call_on_complete =>  Method to call on observers when easing is
    #                             complete (default = false)
    # Example:
    # ========
    # target_obj = {:x => 0, :y => 0}
    # target_attributes = {:x => 250, :y => 100}
    # options = {
    #   :easing         => Easing::BOUNCE_IN,
    #   :observers      => [self],
    #   :call_on_update => :update (can also be writtens as "update")
    # }
    # TDD::Ease.to(target_obj, 60, target_attributes, options)
    # 
    # This would ease the movement of target_object from 0x and 0y to 250x and
    # 100y over 60 frames (1 second) using the Easing::BOUNCE_IN easing method.
    # Every easing update (each frame) would call the method update on the
    # observer objects (self, in this case).
    #
    # Comments:
    # =========
    # Depending on how your objects or classes are set up, you may need to use
    # an "intermediary" object (like the target_obj hash in the example) to
    # hold the attributes, then apply the values form this "intermediary" object
    # to the attributes of the class when the :call_on_update method is called.
    # The reason for this is that you may not necessarily want the easing
    # function to write directly to a caller class. Look at the Game_Picture
    # extension for an example of this necessity, where I didn't want to make
    # any of the read-only attributes writable to implement easing.
    #--------------------------------------------------------------------------
    def self.to(target, frames, attributes={}, options={})
      register_ease(:to, target, frames, attributes, options)
    end

    #--------------------------------------------------------------------------
    # * Ease Parameters From Given Attribute Values To Current Attribute Values
    # Params:
    # =======
    # - target (Object)
    #     An object which has the attributes listed in attributes and which 
    #     you want to effect with an easing FROM its current values TO
    #     the values given in the attributes hash
    # - frames (Integer)
    #     The amount of frames to apply the easing over
    # - attributes (Hash)
    #     Hash of attributes and target values for the attributes you wish to
    #     affect on the target object
    # - options (Hash)
    #     Hash of optional options:
    #       :easing           =>  Easing method to use (default = Easing::LINEAR)
    #       :observers        =>  Array of observer objects (default = nil)
    #       :call_on_update   =>  Method to call on observers every update tick
    #                             (default = false)
    #       :call_on_complete =>  Method to call on observers when easing is
    #                             complete (default = false)
    # Example:
    # ========
    # target_obj = {:x => 0, :y => 0}
    # origin_attributes = {:x => 250, :y => 100}
    # options = {
    #   :easing         => Easing::BOUNCE_IN,
    #   :observers      => [self],
    #   :call_on_update => :update (can also be writtens as "update")
    # }
    # TDD::Ease.to(target_obj, 60, origin_attributes, options)
    # 
    # This would ease the movement of target_object from 250x and 100y to 0x and
    # 0y over 60 frames (1 second) using the Easing::BOUNCE_IN easing method.
    # Every easing update (each frame) would call the method update on the
    # observer objects (self, in this case).
    #
    # You might scratch your head and wonder "well, gosh, what's the point of this
    # when we already have the to method?"
    # This method is useful in instances where it's easier or more convenient to place
    # an object where you want it to end up, then set it to ease from an origin
    # point.
    #
    # Comments:
    # =========
    # Look at comments for the "to" method
    #--------------------------------------------------------------------------
    def self.from(target, frames, attributes={}, options={})
      register_ease(:from, target, frames, attributes, options)
    end

    #--------------------------------------------------------------------------
    # * Updates All Easings Every Engine Frame Tick
    #
    # Comments:
    # =========
    # Called by Scene_Base when the extension is in place for it.
    #--------------------------------------------------------------------------
    def self.update
      @@easings.each_with_index do |ease, index|
        target = ease.target
        ease.attributes.each_pair do |attribute, value|
          attribute_origin = ease.attributes_origin[attribute]
          case ease.method
          when :to
            from = attribute_origin
            to = value
          when :from
            from = value
            to = attribute_origin
          end
          # Move instantly if frames is 1
          if ease.frames == 1
            target[attribute] = to
          else
            target[attribute] = Easing.send(ease.easing, ease.frame, from, to - from, ease.frames)
          end
        end

        ease.observers.each{|o| o.send(ease.call_on_update, ease)} if ease.call_on_update

        ease.frame += 1
        if ease.frame > ease.frames
          @@easings.delete_at(index)
          ease.observers.each{|o| o.send(ease.call_on_complete, ease)} if ease.call_on_complete
        end
      end
    end

    private
    #--------------------------------------------------------------------------
    # * Register An Ease Object in Queue
    #--------------------------------------------------------------------------
    def self.register_ease(method, target, frames, attributes, options)
      @@easings << TDD::Ease_Object.new(method, target, frames, attributes, options)
    end

  end
end
#==============================================================================
# ** TDD Ease Object
#------------------------------------------------------------------------------
# Version:  1.0.0
# Date:     08/12/2013
# Author:   Galenmereth / Tor Damian Design
# 
# Description
# ===========
# This object is used to store the easing info for each active ease in the
# system
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
module TDD
  class Ease_Object
    attr_reader   :method
    attr_reader   :target
    attr_reader   :frames
    attr_reader   :attributes
    attr_reader   :attributes_origin

    attr_accessor :frame
    
    def initialize(method, target, frames, attributes={}, options={})
      @method     = method
      @target     = target
      @frames     = frames
      @attributes = attributes
      @options    = default_options.merge(options)

      # Current frame starts at 0
      @frame = 0

      # Set origin of attributes for ease depending on method
      @attributes_origin = {}
      @attributes.each_pair do |attr, val|
        case method
        when :to
          @attributes_origin[attr] = target[attr]
        when :from
          @attributes_origin[attr] = value
          attributes[attr] = target[attr]
        end
      end
    end

    def easing
      @options[:easing]
    end

    def observers
      @options[:observers]
    end

    def call_on_update
      @options[:call_on_update]
    end

    def call_on_complete
      @options[:call_on_complete]
    end

    private
    def default_options
      {
        :easing => Easing::LINEAR,
        :observers => [],
        :call_on_update => false,
        :call_on_complete => false
      }
    end
  end
end
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
#==============================================================================
# ** Easing EXTENSION
#------------------------------------------------------------------------------
# Extended for: TDD Easing Script
# ===============================
# This extension adds 3 new easing methods to the Easing module:
# * BOUNCE_IN
# * BOUNCE_OUT
# * BOUNCE_IN_OUT
#
# How to use:
# ===========
# Use Game_Picture.easing = Easing::BOUNCE_IN (or any of the other three methods
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
  BOUNCE_IN     = "bounce_in"
  BOUNCE_OUT    = "bounce_out"
  BOUNCE_IN_OUT = "bounce_in_out"

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
    t /= d.to_f/2
    return c/2*t*t*t + b if t < 1
    t -= 2
    return c/2*(t*t*t + 2) + b
  end
end
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
  LINEAR      = "linear"

  # t = Current time (frame)
  # b = Start value
  # c = Desired change in value
  # d = Duration total (frames)
  # Returns: Value modified by t
  def self.linear(t, b, c, d)
    return c*t/d.to_f + b
  end
end
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
#==============================================================================
# ** Scene_Base EXTENSION
#------------------------------------------------------------------------------
# Version:  1.0.1
# Date:     08/12/2013
# Author:   Galenmereth / Tor Damian Design
#
# Extended for: TDD Easing Script
# ===============================
# This calls update on the new Ease module, so that all applied easings are
# updated each frame tick. Nothing else.
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
class Scene_Base
  #--------------------------------------------------------------------------
  # * ALIAS Frame Update
  # Comments:
  #   Ease.update is called first so that the actual drawing performed by the
  #   original update_basic calls are performed after attributes have been
  #   set by active easing procedures.
  #--------------------------------------------------------------------------
  alias_method :tdd_easing_scene_update_basic_extension, :update_basic
  def update_basic
    TDD::Ease.update
    tdd_easing_scene_update_basic_extension
  end
end
#==============================================================================
# ** Game_CharacterBase EXTENSION
#------------------------------------------------------------------------------
# Version:  1.0.0
# Date:     08/12/2013
# Author:   Galenmereth / Tor Damian Design
#
# Extended for: TDD Easing Script
# ===============================
# ADD INFO
#
# How to use:
# ===========
# ADD HOW TO
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
$imported = {} if $imported.nil?
# Is TDD Ease installed?
raise "You need the TDD Easing Script to use this extension!" unless  $imported["TDD Easing Core"] || (Plugins && Plugins.has_plugin?("TDD Easing Core"))
$imported["TDD Easing Core<-Game_CharacterBase"] = true

class Game_CharacterBase
  @easing = false
  #--------------------------------------------------------------------------
  # * NEW Move Character To Other Character
  # Params:
  # =======
  # - char (integer)
  #     An integer noting the character to move to.
  #     -1 -> player
  #     0 -> the current object calling this method
  #     1-x -> event id on the current map
  # - frames (integer)
  #     How many frames the easing should last for
  # - easing (:symbol or "string")
  #     The easing method to apply. Default is :linear
  #--------------------------------------------------------------------------
  def ease_moveto_char(char, frames, easing = :linear)
    char = @interpreter.get_character(char)
    ease_moveto(char.x, char.y, frames, easing)
  end

  #--------------------------------------------------------------------------
  # * NEW Move To Position
  # Params:
  # =======
  # - x (integer or "string")
  #     The x position to move to.
  #     if integer then absolute X position on map
  #     if string then relative to current position. Examples:
  #       "0" -> 0 from current x pos
  #       "-5" -> -5 from current x pos
  #       "5" or "+5" -> +5 from current x pos
  # - y (integer or "string")
  #     The y position to move to. Same rules as x param
  # - frames (integer)
  #     How many frames the easing should last for
  #  - easing (:symbol or "string")
  #     The easing method to apply. Default is :linear
  #--------------------------------------------------------------------------
  def ease_moveto(x, y, frames, easing = :linear)
    x = @real_x + x.to_i if x.is_a? String
    y = @real_y + y.to_i if y.is_a? String
    @wait_count = frames - 1
    @easing = true
    easing_container = {
      x: @real_x,
      y: @real_y
    }
    target_attributes = {
      x: x,
      y: y
    }
    TDD::Ease.to(easing_container, frames, target_attributes, {
      easing: easing,
      observers: [self],
      call_on_update: :ease_moveto_update,
      call_on_complete: :ease_moveto_complete
      })
  end

  #--------------------------------------------------------------------------
  # * NEW Ease To Opacity
  # Params:
  # =======
  # - opacity (integer or "string")
  #     Target opacity to ease to. If string, then relative to current opacity
  #     value. See ease_moveto's x param for more on how to use relative
  #     string values.
  # - frames (integer)
  #     How many frames the easing should last for
  #  - easing (:symbol or "string")
  #     The easing method to apply. Default is :linear
  #--------------------------------------------------------------------------
  def ease_opacity(opacity, frames, easing = :linear)
    opacity = @opacity + opacity.to_i if opacity.is_a? String
    @wait_count = frames - 1
    @easing = true
    easing_container = {opacity: @opacity}
    target_attributes = {opacity: opacity}
    TDD::Ease.to(easing_container, frames, target_attributes, {
      easing: easing,
      observers: [self],
      call_on_update: :ease_opacity_update,
      call_on_complete: :ease_opacity_complete
      })
  end

  #--------------------------------------------------------------------------
  # * NEW Update Display Position (used by ease_moveto ease)
  #--------------------------------------------------------------------------
  def ease_moveto_update(ease_obj)
    easing_container = ease_obj.target
    @real_x = easing_container[:x]
    @real_y = easing_container[:y]
    increase_steps
  end

  #--------------------------------------------------------------------------
  # * NEW Finalize And Update Map Position (used by ease_moveto ease)
  #--------------------------------------------------------------------------
  def ease_moveto_complete(ease_obj)
    @x = @real_x
    @y = @real_y
    @easing = false
  end

  #--------------------------------------------------------------------------
  # * NEW Update Opacity (used by ease_opacity ease)
  #--------------------------------------------------------------------------
  def ease_opacity_update(ease_obj)
    @opacity = ease_obj.target[:opacity]
  end

  #--------------------------------------------------------------------------
  # * NEW Finalize Opacity Ease (used by ease_opacity ease)
  #--------------------------------------------------------------------------
  def ease_opacity_complete(ease_obj)
    @easing = false
  end

  #--------------------------------------------------------------------------
  # * NEW Check If Easing?
  #--------------------------------------------------------------------------
  def easing?
    @easing
  end

  #--------------------------------------------------------------------------
  # * OVERWRITE Frame Update
  #--------------------------------------------------------------------------
  def update
    update_animation
    return update_jump if jumping?
    return update_move if moving? && !easing?
    return update_stop
  end

end
#==============================================================================
# ** Game_Picture EXTENSION
#------------------------------------------------------------------------------
# Version:  1.0.1
# Date:     08/12/2013
# Author:   Galenmereth / Tor Damian Design
#
# Extended for: TDD Easing Script
# ===============================
# This extension changes the default transition easing for Move Picture and
# Tint Picture, so that it uses the TDD Easing script motion instead.
#
# How to use:
# ===========
# Use Game_Picture.easing= to set an easing method before calling move or 
# start_tone_change, either through scripts or through the use of Move Picture
# and Tint Picture event calls. Look at self.easing and self.easing_default
# for more details
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
class Game_Picture
  # Global default easing method; can be set using Game_Picture.easing_default=
  @@easing_method_default = Easing::LINEAR

  # By default, the current easing method is set to the default
  @@easing_method = @@easing_method_default
  
  # List of variables to use for easing movement
  @@easing_move_attributes = %w(
    x
    y
    zoom_x
    zoom_y
    opacity
    duration)

  # List of variables to use for easing tone change
  @@easing_tint_attributes = %w(
    red
    green
    blue
    gray
    )

  #--------------------------------------------------------------------------
  # * ALIAS Move Picture
  #--------------------------------------------------------------------------
  alias_method :tdd_easing_move_extension, :move
  def move(origin, x, y, zoom_x, zoom_y, opacity, blend_type, duration)
    tdd_easing_move_extension(origin, x, y, zoom_x, zoom_y, opacity, blend_type, duration)

    target_attributes = {}
    easing_container = {}
    @@easing_move_attributes.each do |attr|
      easing_container[attr] = instance_variable_get("@#{attr}")
      target_attributes[attr] = eval(attr)
    end
    puts @easing_method
    TDD::Ease.to(easing_container, duration, target_attributes, {
      :easing => @@easing_method,
      :observers => [self],
      :call_on_update => :update_move
      })
  end

  #--------------------------------------------------------------------------
  # * ALIAS Start Changing Color Tone
  #--------------------------------------------------------------------------
  alias_method :tdd_easing_start_tone_change_extension, :start_tone_change
  def start_tone_change(tone, duration)
    tdd_easing_start_tone_change_extension(tone, duration)

    easing_container = {}
    target_attributes = {}
    @@easing_tint_attributes.each do |attr|
      easing_container[attr] = @tone.send(attr)
      target_attributes[attr] = @tone_target.send(attr)
    end

    TDD::Ease.to(easing_container, duration, target_attributes, {
      :easing => @@easing_method,
      :observers => [self],
      :call_on_update => :update_tone_change
      })
  end

  #--------------------------------------------------------------------------
  # * ALIAS Erase Picture
  # Comments:
  #   The class static variable @@easing_method is reset to
  #   @@easing_method_default upon erasure.
  #--------------------------------------------------------------------------
  alias_method :tdd_easing_erase_extension, :erase
  def erase
    tdd_easing_erase_extension
    @@easing_method = @@easing_method_default
  end

  #--------------------------------------------------------------------------
  # * OVERWRITE Frame Update
  # Comments:
  #   update_move and update_tone_change left commented out to make it clear
  #   that these have been disabled
  #--------------------------------------------------------------------------
  def update
    # update_move
    # update_tone_change
    update_rotate
  end

  #--------------------------------------------------------------------------
  # * ALIAS Update Picture Move
  # Comments:
  #   In case other scripts want to call update_move for any reason,
  #   I make it check for the ease_obj from the easing; if it's not there,
  #   it uses the default update_move method
  #-------------------------------------------------------------------------
  alias_method :tdd_easing_update_move_extension, :update_move
  def update_move(ease_obj = nil)
    unless ease_obj
      tdd_easing_update_move_extension
      return
    end
    easing_container = ease_obj.target
    @@easing_move_attributes.each do |attr|
      instance_variable_set("@#{attr}", easing_container[attr])
    end
  end

  #--------------------------------------------------------------------------
  # * ALIAS Update Color Tone Change
  # Comments:
  #   In case other scripts want to call update_tone_change for any reason,
  #   I make it check for the ease_obj from the easing; if it's not there,
  #   it uses the default update_tone_change method
  #--------------------------------------------------------------------------
  alias_method :tdd_easing_update_tone_change_extension, :update_tone_change
  def update_tone_change(ease_obj)
    unless ease_obj
      tdd_easing_update_tone_change_extension
      return
    end
    easing_container = ease_obj.target
    @@easing_tint_attributes.each do |attr|
      @tone.send("#{attr}=", easing_container[attr])
    end
  end

  #--------------------------------------------------------------------------
  # * NEW Static Method Set Easing
  #--------------------------------------------------------------------------
  def self.easing=(easing_method)
    @@easing_method = easing_method
  end

  #--------------------------------------------------------------------------
  # * NEW Static Method Set Easing Default for Game_Picture class
  #--------------------------------------------------------------------------
  def self.easing_default=(easing_method)
    @@easing_method_default = easing_method
  end
end
