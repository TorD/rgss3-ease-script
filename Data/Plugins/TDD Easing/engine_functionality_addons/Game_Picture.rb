class Game_Picture
	# Overwrite
	def move(origin, x, y, zoom_x, zoom_y, opacity, blend_type, duration)
    @origin = origin
    @target_x = x.to_f
    @target_y = y.to_f
    @target_zoom_x = zoom_x.to_f
    @target_zoom_y = zoom_y.to_f
    @target_opacity = opacity.to_f
    @blend_type = blend_type
    @duration = duration
  end

  # Overwrite
	def update_move
		
	end
end