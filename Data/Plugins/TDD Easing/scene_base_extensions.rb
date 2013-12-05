class Scene_Base
	alias_method :tdd_easing_scene_base_update, :update_basic
	def update
		update_easing
		tdd_easing_scene_base_update
	end

	# New method; updates active easing each frame
	def update_easing
		Ease.update
	end
end