#==============================================================================
#
# TDD Ease Script -- Animation framework
# _____________________________________________________________________________
#
# + Author:   Galenmereth / Tor Damian Design
# + E-mail:   post@tordamian.com
# -----------------------------------------------------------------------------
# + Version:  10.0.11
# + Date:     03/30/2015
# -----------------------------------------------------------------------------
# + License:  Free for non-commercial and commercial use. Credit greatly
#             appreciated but not required. Share script freely with everyone,
#             but please retain this description and license. Thank you.
# _____________________________________________________________________________
#
# + Changelog:
#
# 1.0.11  Implemented :same functionality for overwriting other eases, only 
#         overwriting same attributes
#
# 1.0.10  Fixed a bug in overwrite_other_easings and register_ease that caused 
#         overwrite to not work as advertised.
#
# 1.0.9   Updated Game_CharacterBase extension to 1.0.4, fixing ease_moveto_char
#         problems when using event ids
#
# 1.0.8   Added {complete_easings_for} with options.
#         Fixed overwrite bug, so that it checks for pointer uniqueness when
#         comparing two easing targets.
#
# 1.0.7   Added :overwrite option for {to}, {from} and {register_ease} called
#         :overwrite, which will overwrite any other easings for the given
#         target(s). Added new public method: {clear_easings_for}. See its
#         documentation
#         Moved the performing of an ease frame animation into separate method:
#         {perform_ease_for}.
#
# 1.0.6   Added support to use non-Hash objects directly as targets of easing. 
#         This is fully backwards compatible. Also added documentation for the
#         delay option.
#
# 1.0.5   Added support for a delay in options hash.
#         This makes the easing wait the specified x amount of frames before
#         starting.
#
# 1.0.4   TDD Ease Object updated. {from} now works as intended. 
#         Fixed attribute origin setting to remove method check, since that is
#         done in the easing module already.
#
# 1.0.3   Fixed @interpreter bug in Game_CharacterBase extension
#
# 1.0.2   Introduced the TDD module namespace and Ease_Object instead of using
#         a hash
#==============================================================================
$imported = {} if $imported.nil?
$imported["TDD Easing Core"] = true
module TDD
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
      # @option ooptions [Boolean, Symbol] :overwrite (false)
      #   If ease should overwrite other eases on same target. If true, deletes other eases on target
      #   If :same, deletes only overlapping same attributes on target
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
          elsif ease.overwrite
            # Delete other easings for same target if applicable
            overwrite_other_easings(ease)
          end

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

          if ease.observers
            ease.observers.each{|o| o.send(ease.call_on_update, ease)} if ease.call_on_update
          else
            ease.call_on_update.call(ease) if ease.call_on_update
          end

          ease.frame += 1
          if ease.frame > ease.frames
            @@easings.delete(ease)
            if ease.observers
              ease.observers.each{|o| o.send(ease.call_on_complete, ease)} if ease.call_on_complete
            else
              ease.call_on_complete.call(ease) if ease.call_on_complete
            end
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
        
        # Perform actions immediately if no delay
        if ease.delay == 0
          # Delete other easings for same target if applicable
          overwrite_other_easings(ease) if ease.overwrite

          # Perform initial ease this frame if no delay
          perform_ease_for(ease) if method == :from
        end

        # Add to easings array
        @@easings.push(ease)
      end

      # Overwrite other ease queues for Ease_Objects with the same target
      # 
      # @param (Ease_Object) ease   The Ease_Object to search for like targets
      #
      # @note Overwrites overlapping attributes or deletes other Ease_Objects with the same target, depending on ease.overwrite value
      def overwrite_other_easings(ease)
        return unless ease.overwrite

        # Remove other ease with same target
        @@easings.reject{|e| e === ease}.each do |ease_to_overwrite|
          next unless ease_to_overwrite.target === ease.target

          # If overwrite method is set to :same, will only overwrite overlapping attributes
          if ease.overwrite.is_a?(Symbol) && ease.overwrite == :same
            ease_to_overwrite.attributes.delete_if{|k,v| ease.attributes.has_key?(k)}
          else
            @@easings.delete(ease_to_delete) if ease_to_delete.target === ease.target
          end
        end

        # Turn off overwrite from now for this ease
        ease.overwrite = false
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
          @@easings.delete(ease) if ease.target === args[:target]
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