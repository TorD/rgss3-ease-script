#==============================================================================
# ** TDD Ease Module
#------------------------------------------------------------------------------
# Version:  1.0.6
# Date:     11/26/2014
# Author:   Galenmereth / Tor Damian Design
#
# Changelog
# =========
# 1.0.6   Added support to use non-Hash objects directly as targets of easing.
#         This is fully backwards compatible. Also added documentation for
#         the delay option.
# 1.0.5   Added support for a delay in options hash. This makes the easing wait
#         the specified x amount of frames before starting.
# 1.0.4   TDD Ease Object updated. :from now works as intended. Fixed attribute
#         origin setting to remove method check, since that is done in the 
#         easing module already.
# 1.0.3   Fixed @interpreter bug in Game_CharacterBase extension
# 1.0.2   Introduced the TDD module namespace and Ease_Object instead of using a hash
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
    class << self
      @@easings=[]
      
      ######
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
      ######
      def to(target, frames, attributes={}, options={})
        register_ease(:to, target, frames, attributes, options)
      end

      ######
      # Ease parameters *from* given attribute values to target's current attribute values 
      #
      # @return (see to)
      # @param (see to)
      #
      # @note Functions like to, except eases *from* given attributes values *to* current target attribute values
      #
      # @see to
      ######
      def from(target, frames, attributes={}, options={})
        register_ease(:from, target, frames, attributes, options)
      end

      ######
      # Updates easings every engine / Scene frame tick
      #
      # @note
      #   Called by Scene_Base when the extension is in place for it.
      ######
      def update
        @@easings.each do |ease|
          # Skip to wait for delay option if present
          if ease.delay > 0
            ease.delay -= 1
            next
          end
          
          # Delete other easings if overwrite set
          self.overwrite_other_easings(ease) if ease.overwrite
          
          # Set local target var
          target = ease.target

          # Do not attempt to animate disposed items
          next if target.class.method_defined?("disposed?") && target.disposed?

          # Perform ease calculations
          perform_ease_for(ease)
        end
      end

      ######
      # Perform ease for Ease_Object
      #
      # @param (Ease_Object) ease   The Ease_Object to advance the animation 1 frame tick
      ######
      def perform_ease_for(ease)
        # Initial setup of origin attributes
        ease.setup

        # Set local target var
        target = ease.target

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
      end

      ######
      # Register an Ease_Object in queue
      #
      # @param (Symbol) method (:to, :from) - The method to use
      # @param (see to)
      # @return (see to)
      ######
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

      ######
      # Overwrite other ease queues for Ease_Objects with the same target
      # 
      # @param (Ease_Object) ease   The Ease_Object to search for like targets
      #
      # @note Overwrites (deletes) other Ease_Objects with the same target
      ######
      def overwrite_other_easings(ease)
        return unless ease.overwrite

        # Turn off overwrite from now for this ease
        ease.overwrite = false

        # Remove other ease with same target
        @@easings.each do |ease_to_delete|
          @@easings.delete(ease_to_delete) if ease_to_delete.target == ease.target && ease_to_delete != ease
        end
      end

      ######
      # Clear all active easings for a target object
      #
      # @param (Hash) args    Options Hash
      # @option args [Object] :target - The target Object to clear easings for
      # @option args [Boolean] :perform_complete_call (false) - Whether to perform the complete call on each Ease_Object or not
      ######
      def clear_easings_for(args={})
        args = {
          :target                => nil,
          :perform_complete_call => false
        }.merge(args)

        @@easings.each do |ease|
          @@easings.delete(ease) if ease.target == args[:target]
          if args[:perform_complete_call]
            ease.observers.each{|o| o.send(ease.call_on_complete, ease)} if ease.call_on_complete
          end
        end
      end
    end
  end
end