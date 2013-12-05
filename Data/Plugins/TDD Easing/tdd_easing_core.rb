module Easing
	LINEAR 			= "linear"

	# t = Current time (frame)
	# b = Start value
	# c = Desired change in value
	# d = Duration total (frames)
	# Returns: Value modified by t
	def self.linear(t, b, c, d)
		return c*t/d + b
	end
end

module Ease
	@@easings = []

	def self.to(object, frames, attributes={}, opts={})
		register_ease(:to, object, frames, attributes, opts)
	end

	def self.from(object, frames, attributes={}, opts={})
		register_ease(:from, object, frames, attributes, opts)
	end

	def self.update
		@@easings.each_with_index do |ease, index|
			if ease[:frame] == ease[:frames]
				@@easings.delete_at(index)
				ease[:on_complete] if ease[:on_complete]
			end

			object = ease[:object]
			ease[:attributes].each_pair do |attribute, value|
				attribute_origin = ease[:attribute_origins][attribute]
				case ease[:method]
				when :to
					from = attribute_origin
					to = value
				when :from
					from = value
					to = attribute_origin
				end
				object[attribute] = Easing.send(ease[:easing], ease[:frame], from, to - from, ease[:frames])
				puts "#{attribute}: #{object[attribute]}"
			end

			ease[:frame] += 1
		end
	end

	private
	def self.register_ease(method, object, frames, attributes, opts)

		attribute_origins = {}
		attributes.each_pair do |attribute, value|
			attribute_origins[attribute] = object[attribute]
		end

		ease = {
			:object => object,
			:attributes => attributes,
			:attribute_origins => attribute_origins,
			:method => method,
			:frame => 0,
			:frames => frames,
			# Default options from opts follow
			:easing => Easing::LINEAR,
			:on_progress => nil,
			:on_complete => nil
		}.merge(opts)

		@@easings << ease
	end
end