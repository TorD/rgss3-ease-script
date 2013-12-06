module Easing
	LINEAR 			= "linear"

	# t = Current time (frame)
	# b = Start value
	# c = Desired change in value
	# d = Duration total (frames)
	# Returns: Value modified by t
	def self.linear(t, b, c, d)
		return c*t/d.to_f + b
	end
end

module Ease
	@@easings = []

	# Available opts:
	# 	:easing => Easing method, use Easing::METHOD (default is Easing::LINEAR)
	#   :observers => Array of observer classes. Must respond to the following methods:
	# 		ease_update(ease_obj)
	# 		ease_complete(ease_obj)
	def self.to(object, frames, attributes={}, opts={})
		register_ease(:to, object, frames, attributes, opts)
	end

	def self.from(object, frames, attributes={}, opts={})
		register_ease(:from, object, frames, attributes, opts)
	end

	def self.update
		@@easings.each_with_index do |ease, index|
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
			end

			ease[:frame] += 1
			if ease[:frame] > ease[:frames]
				@@easings.delete_at(index)
				ease[:observers].each{|o| o.send(:ease_complete, ease)}
			else
				ease[:observers].each{|o| o.send(:ease_update, ease)}
			end
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
			:observers => []
		}.merge(opts)

		@@easings << ease
	end

end