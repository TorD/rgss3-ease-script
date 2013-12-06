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