module TDD
	class Ease_Object
		attr_reader		:method
		attr_reader		:target
		attr_reader		:frames
		attr_reader 	:attributes
		attr_reader		:attributes_origin

		attr_accessor	:frame
		
		def initialize(method, target, frames, attributes={}, options={})
			@method 		= method
			@target 		= target
			@frames 		= frames
			@attributes = attributes
			@options 		= default_options.merge(options)

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