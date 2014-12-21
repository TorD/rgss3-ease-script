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
