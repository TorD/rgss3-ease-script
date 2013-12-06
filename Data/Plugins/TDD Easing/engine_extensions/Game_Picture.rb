class Game_Picture
	@@easing_method = Easing::LINEAR
	@@easing_method_temp = @@easing_method
	@@easing_attributes = %w(
		x
		y
		zoom_x
		zoom_y
		opacity
		duration)

	# Aliased
	alias_method :easing_game_picture_move_extension, :move
	def move(origin, x, y, zoom_x, zoom_y, opacity, blend_type, duration)
    easing_game_picture_move_extension(origin, x, y, zoom_x, zoom_y, opacity, blend_type, duration)

    attributes = {}
    easing_target = {}
    @@easing_attributes.each do |attr|
    	easing_target[attr] = instance_variable_get("@#{attr}")
    	attributes[attr] = eval(attr)
    end

		Ease.to(easing_target, duration, attributes, {
			:easing => easing_method,
			:observers => [self]})
  end

  def ease_update(ease_obj)
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
		easing_target = ease_obj[:target]
		@@easing_attributes.each do |attr|
			instance_variable_set("@#{attr}", easing_target[attr])
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