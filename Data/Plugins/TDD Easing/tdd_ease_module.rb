#==============================================================================
# ** TDD Ease Module
#------------------------------------------------------------------------------
# Version: 1.0.0
# Author: Galenmereth / Tor Damian Design
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