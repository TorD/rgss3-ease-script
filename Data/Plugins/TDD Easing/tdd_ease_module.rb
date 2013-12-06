module Ease
	@@easings = []

	# Available opts:
	# 	:easing => Easing method, use Easing::METHOD (default is Easing::LINEAR)
	#   :observers => Array of observer classes. Must respond to the following methods:
	# 		ease_update(ease_obj)
	# 		ease_complete(ease_obj)
	def self.to(target, frames, attributes={}, opts={})
		register_ease(:to, target, frames, attributes, opts)
	end

	def self.from(target, frames, attributes={}, opts={})
		register_ease(:from, target, frames, attributes, opts)
	end

	def self.update
		@@easings.each_with_index do |ease, index|
			target = ease[:target]
			ease[:attributes].each_pair do |attribute, value|
				attribute_origin = ease[:attributes_origin][attribute]
				case ease[:method]
				when :to
					from = attribute_origin
					to = value
				when :from
					from = value
					to = attribute_origin
				end
				target[attribute] = Easing.send(ease[:easing], ease[:frame], from, to - from, ease[:frames])
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
	def self.register_ease(method, target, frames, attributes, opts)

		attributes_origin = {}
		attributes.each_pair do |attr, value|
			case method
			when :to
				attributes_origin[attr] = target[attr]
			when :from
				attributes_origin[attr] = value
				attributes[attr] = target[attr]
			end
		end

		ease_obj = {
			:target => target,
			:attributes => attributes,
			:attributes_origin => attributes_origin,
			:method => method,
			:frame => 0,
			:frames => frames,
			# Default options from opts follow
			:easing => Easing::LINEAR,
			:observers => []
		}.merge(opts)

		@@easings << ease_obj
	end

end