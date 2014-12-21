$imported = {} if $imported.nil?
$imported["TDD Easing Core"] = true
module TDD
  # Summary:: This static class is used to apply an easing algorithm to an object's parameters over X amount of frames.  
  #           Easing methods can be extended through adding static methods to the Easing module. The default easing method
  #           is Easing::LINEAR and is identical to the default easing provided in VXAce
  #
  # Version:: 1.0.8
  # Date::    12/21/2014
  # Author::  Galenmereth / Tor Damian Design <post@tordamian.com>
  #
  # License:: Free for non-commercial and commercial use. Credit greatly appreciated but not required.
  #           Share script freely with everyone, but please retain this description area unless you change
  #           the script completely. Thank you.
  #
  #== Changelog
  # 1.0.8::  * Added {complete_easings_for} with options.
  #          * Fixed overwrite bug, so that it checks for pointer uniqueness when comparing two
  #            easing targets.
  # 1.0.7::  * Added :overwrite option for {to}, {from} and {register_ease} called :overwrite, 
  #            which will overwrite any other easings for the given target(s).
  #          * Added new public method: {clear_easings_for}. See its documentation
  #          * Moved the performing of an ease frame animation into separate method: {perform_ease_for}.
  #
  # 1.0.6:: Added support to use non-Hash objects directly as targets of easing. 
  #         This is fully backwards compatible. Also added documentation for the delay option.
  #
  # 1.0.5:: Added support for a delay in options hash.
  #         This makes the easing wait the specified x amount of frames before starting.
  #
  # 1.0.4:: TDD Ease Object updated. {from} now works as intended. 
  #         Fixed attribute origin setting to remove method check, since that is done in the easing module already.
  #
  # 1.0.3:: Fixed @interpreter bug in Game_CharacterBase extension
  #
  # 1.0.2:: Introduced the TDD module namespace and Ease_Object instead of using a hash
  class Ease
    class << self
      @@easings=[]
      
      # Ease parameters *to* given attribute values from target's current attribute values
      #
      # @param (Object, Array) target
      #   An Object (or an Array of objects) which has the attributes listed in attributes and which 
      #   you want to effect with an easing FROM its current values TO
      #   the values given in the attributes hash
      #
      # @param (Integer) frames
      #   The amount of frames to apply the easing over
      #
      # @param (Hash) attributes
      #   Hash of attributes and target values for the attributes you wish to affect on the target object
      #
      # @param (Hash) options
      #   Options Hash
      #
      # @option options [Easing] :easing (Easing::LINEAR)
      #   Easing method to use
      # @option options [Integer] :delay (0)
      #   Delay (in frames) before starting the ease.
      # @option options [Array] :observers (nil)
      #   Array of observer objects (default = nil)
      # @option options [Symbol, String, Boolean] :call_on_update (false)
      #   Method to call on :observers every update tick
      # @option options [Symbol, String, Boolean] :call_on_complete (false)
      #   Method to call on :observers when easing is complete
      #
      # @return (Ease_Object) ease_object - The created Ease_Object
      #
      # @see from
      #
      # @example Setting up an ease
      #   target_obj = {:x => 0, :y => 0}
      #   target_attributes = {:x => 250, :y => 100}
      #   options = {
      #     :easing         => Easing::BOUNCE_IN,
      #     :observers      => [self],
      #     :call_on_update => :update (can also be writtens as "update")
      #   }
      #   TDD::Ease.to(target_obj, 60, target_attributes, options)
      #   
      #   This would ease the movement of target_object from 0x and 0y to 250x and
      #   100y over 60 frames (1 second) using the Easing::BOUNCE_IN easing method.
      #   Every easing update (each frame) would call the method update on the
      #   observer objects (self, in this case).
      #
      # @note 
      #   Depending on how your objects or classes are set up, you may need to use
      #   an "intermediary" object (like the target_obj hash in the example) to
      #   hold the attributes, then apply the values form this "intermediary" object
      #   to the attributes of the class when the :call_on_update method is called.
      #   The reason for this is that you may not necessarily want the easing
      #   function to write directly to a caller class. Look at the Game_Picture
      #   extension for an example of this necessity, where I didn't want to make
      #   any of the read-only attributes writable to implement easing.
      def to(target, frames, attributes={}, options={})
        register_ease(:to, target, frames, attributes, options)
      end

      # Ease parameters *from* given attribute values to target's current attribute values 
      #
      # @return (see to)
      # @param (see to)
      #
      # @note Functions like to, except eases *from* given attributes values *to* current target attribute values
      #
      # @see to
      def from(target, frames, attributes={}, options={})
        register_ease(:from, target, frames, attributes, options)
      end

      # Updates easings every engine / Scene frame tick
      #
      # @note
      #   Called by Scene_Base when the extension is in place for it.
      def update
        @@easings.each do |ease|
          # Skip to wait for delay option if present
          if ease.delay > 0
            ease.delay -= 1
            next
          end
          
          # Delete other easings if overwrite set
          self.overwrite_other_easings(ease) if ease.overwrite

          # Perform ease calculations
          perform_ease_for(ease)
        end
      end

      # Perform ease for Ease_Object
      #
      # @param (Ease_Object) ease   The Ease_Object to advance the animation 1 frame tick
      def perform_ease_for(ease)
        # Initial setup of origin attributes
        ease.setup

        # Set local target var
        target = ease.target

        begin
          # Perform easing
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
              value = to
            else
              value = Easing.send(ease.easing, ease.frame, from, to - from, ease.frames)
            end

            # Set the attribute on the target
            if target.is_a? Hash
              target[attribute] = value
            else
              target.send("#{attribute}=", value)
            end
          end

          ease.observers.each{|o| o.send(ease.call_on_update, ease)} if ease.call_on_update

          ease.frame += 1
          if ease.frame > ease.frames
            @@easings.delete(ease)
            ease.observers.each{|o| o.send(ease.call_on_complete, ease)} if ease.call_on_complete
          end
        rescue
          # Do not attempt to animate disposed items
          clear_easings_for(target: target) if target.class.method_defined?("disposed?") && target.disposed?
        end
      end

      # Register an Ease_Object in queue
      #
      # @param (Symbol) method (:to, :from) - The method to use
      # @param (see to)
      # @return (see to)
      def register_ease(method, target, frames, attributes, options)
        if target.is_a? Array
          target.each{|target| self.register_ease(method, target, frames, attributes, options)}
          return
        end
        
        ease = TDD::Ease_Object.new(method, target, frames, attributes, options)
        
        # Perform initial ease this frame if no delay
        perform_ease_for(ease) if ease.delay == 0 && method == :from

        # Delete other easings for same target if applicable
        self.overwrite_other_easings(ease) if ease.overwrite && ease.delay == 0

        # Add to easings array
        @@easings.push(ease)

      end

      # Overwrite other ease queues for Ease_Objects with the same target
      # 
      # @param (Ease_Object) ease   The Ease_Object to search for like targets
      #
      # @note Overwrites (deletes) other Ease_Objects with the same target
      def overwrite_other_easings(ease)
        return unless ease.overwrite

        # Turn off overwrite from now for this ease
        ease.overwrite = false

        # Remove other ease with same target
        @@easings.each do |ease_to_delete|
          @@easings.delete(ease_to_delete) if ease_to_delete.target.equal?(ease.target) && ease_to_delete != ease
        end
      end

      # Clear all active easings for a target object
      #
      # @param (Hash) args    Options Hash
      # @option args [Object] :target - The target Object to clear easings for
      # @option args [Boolean] :perform_complete_call (false) - Whether to perform the complete call on each Ease_Object or not
      def clear_easings_for(args={})
        args = {
          :target                => nil,
          :perform_complete_call => false
        }.merge(args)

        @@easings.each do |ease|
          @@easings.delete(ease) if ease.target.equal?(args[:target])
          if args[:perform_complete_call]
            ease.observers.each{|o| o.send(ease.call_on_complete, ease)} if ease.call_on_complete
          end
        end
      end

      # Complete easings for a target (or an array of targets). Skips directly to the last "frame" of transition.
      #
      # @param [Object, Array] target The target Object to complete easings for, or an Array of target Objects to complete easings for.
      # @param [Boolean] perform_complete_call Whether to call the :call_on_complete optional method on the target(s)
      def complete_easings_for(target, perform_complete_call=false)
        if target.is_a? Array
          target.each{|t| complete_easings_for(t, perform_complete_call)}
        else
          @@easings.select{|e| e.target == target}.each do |ease|
            ease.frames = 1
            perform_ease_for(ease)
          end
        end
      end
    end
  end
end
#==============================================================================
# ** TDD Ease Object
#------------------------------------------------------------------------------
# Version:  1.0.5
# Date:     12/21/2014
# Author:   Galenmereth / Tor Damian Design
# 
# Changelog
# =========
# 1.0.5 - Made the :frames attribute an accessor for read and write
# 1.0.4 - Added support for non-Hash target objects. Fully backwards compatible
# 1.0.3 - Added delay access method
# 1.0.2 - :from now works as intended. Fixed attribute origin setting to remove
#         method check, since that is done in the easing module already.
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
    attr_reader   :attributes
    attr_reader   :attributes_origin
    attr_reader   :setup_complete

    attr_accessor :frames
    attr_accessor :frame
    attr_accessor :overwrite
    
    def initialize(method, target, frames, attributes={}, options={})
      @method     = method
      @target     = target
      @frames     = frames
      @attributes = attributes
      @options    = default_options.merge(options)

      # Current frame starts at 0
      @frame = 0

      # Set overwrite attribute
      @overwrite = @options[:overwrite]

      # Setup if no delay
      setup if delay == 0

      return self
    end

    def easing
      @options[:easing]
    end

    def delay
      @options[:delay] || 0
    end

    def delay=(value)
      @options[:delay] = value
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

    def setup
      return if setup_complete?

      # Set origin of attributes for ease
      @attributes_origin = {}
      @attributes.each_pair do |attr, val|
        if target.is_a? Hash
          @attributes_origin[attr] = target[attr]
        else
          @attributes_origin[attr] = target.send(attr)
        end
      end

      # Setup complete
      @setup_complete = true
    end

    def setup_complete?
      @setup_complete
    end

    private
    def default_options
      {
        :easing           => Easing::LINEAR,
        :observers        => [],
        :delay            => 0,
        :overwrite        => false,
        :call_on_update   => false,
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
    c = c.to_f
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
    c = c.to_f
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
    c = c.to_f
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
    c=c.to_f
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
    c=c.to_f
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
    c=c.to_f
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
  QUAD_IN       = "quad_in"
  QUAD_OUT      = "quad_out"
  QUAD_IN_OUT   = "quad_in_out"

  def self.quad_in(t, b, c, d)
    t /= d.to_f
    return c*t*t + b
  end

  def self.quad_out(t, b, c, d)
    c = c.to_f
    t /= d.to_f
    return -c * t*(t-2) + b;
  end

  def self.quad_in_out(t, b, c, d)
    c = c.to_f
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
# Version:  1.0.3
# Date:     07/31/2014
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
  @@interpreter = Game_Interpreter.new
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
    char = @@interpreter.get_character(char)
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
    last_real_x = @real_x
    last_real_y = @real_y
    easing_container = ease_obj.target
    @real_x = easing_container[:x]
    @real_y = easing_container[:y]
    increase_steps
    update_scroll(last_real_x, last_real_y) if self.instance_of? Game_Player
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
  # * ALIAS Moving?
  #--------------------------------------------------------------------------
  alias :tdd_easing_moving? :moving?
  def moving?
    return easing? ? false : tdd_easing_moving?
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
