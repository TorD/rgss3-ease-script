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
class Scene_Base
	alias_method :tdd_easing_scene_update_basic_extension, :update_basic
	def update_basic
		update_easing
		tdd_easing_scene_update_basic_extension
	end

	# New method; updates active easing each frame
	def update_easing
		Ease.update
	end
end
class Game_Picture
	@@easing_method = Easing::LINEAR
	@@easing_method_temp = @@easing_method
	@@easing_attributes = %w(
		x
		y
		zoom_x
		zoom_y
		opacity
		blend_type
		duration)
	
	attr_accessor		:easing_obj

	alias_method :easing_game_picture_initialize_extension, :initialize
	def initialize(number)
		easing_game_picture_initialize_extension(number)
		@easing_obj = {}
	end

	# Aliased
	alias_method :easing_game_picture_move_extension, :move
	def move(origin, x, y, zoom_x, zoom_y, opacity, blend_type, duration)
    easing_game_picture_move_extension(origin, x, y, zoom_x, zoom_y, opacity, blend_type, duration)

    attributes = {}
    @@easing_attributes.each do |attr|
    	@easing_obj[attr] = instance_variable_get("@#{attr}")
    	attributes[attr] = eval(attr)
    end

		Ease.to(@easing_obj, duration, attributes, {
			:easing => easing_method,
			:observers => [self]})
  end

  def ease_update(ease_obj)
  	#puts @easing_obj
  	update_move(ease_obj)
  end

  def ease_complete(ease_obj)
  	update_move(ease_obj)
  end

  # Overwrite (should be empty; all methods should use easing)
  def update
  	return
  	#update_tone_change
  	#update_rotate
  end

  # Overwrite
	def update_move(ease_obj)
		@@easing_attributes.each do |attr|
			self.instance_variable_set("@#{attr}", @easing_obj[attr])
		end
	end

	# Static method
	def self.easing=(easing_method)
		@@easing_method_temp = easing_method
	end

	def self.easing_default=(easing_method)
		@@easing_method = easing_method
	end

	private
	def easing_method
		e = @@easing_method_temp
		@@easing_method_temp = @@easing_method
		e
	end
end
module Easing
	CUBIC_IN 			= "cubic_in"
	CUBIC_OUT 		= "cubic_out"
	CUBIC_IN_OUT 	= "cubic_in_out"

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
module Easing
	ELASTIC_IN			= "elastic_in"
	ELASTIC_OUT			= "elastic_out"
	ELASTIC_IN_OUT	= "elastic_in_out"

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


module Easing
	QUAD_IN				= "quad_ease_in"
	QUAD_OUT			= "quad_ease_out"
	QUAD_IN_OUT 	= "quad_ease_in_out"

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
