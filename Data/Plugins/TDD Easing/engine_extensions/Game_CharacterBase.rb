#==============================================================================
# ** Game_Picture EXTENSION
#------------------------------------------------------------------------------
# Version: 1.0.0
# Author: Galenmereth / Tor Damian Design
#
# Extended for: TDD Easing Script
# ===============================
# ADD INFO
#
# How to use:
# ===========
# ADD HOW TO
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
$imported = {} if $imported.nil?
# Is TDD Ease installed?
raise "You need the TDD Easing Script to use this extension!" unless 	$imported["TDD Easing Core"] || (Plugins && Plugins.has_plugin?("TDD Easing Core"))
$imported["TDD Easing Core<-Game_CharacterBase"] = true

class Game_CharacterBase
	@easing = false

	def ease_moveto_char(char, duration, easing = :linear)
		char = @interpreter.get_character(char)
		ease_moveto(char.x, char.y, duration, easing)
	end

	def ease_moveto(x, y, duration, easing = :linear)
		x = @real_x + x.to_i if x.is_a? String
		y = @real_y + y.to_i if y.is_a? String
		@wait_count = duration - 1
		@easing = true
		easing_container = {
			x: @real_x,
			y: @real_y
		}
		target_attributes = {
			x: x,
			y: y
		}
		Ease.to(easing_container, duration, target_attributes, {
			easing: easing,
			observers: [self],
			call_on_update: :ease_moveto_update,
			call_on_complete: :ease_moveto_complete
			})
	end

	def ease_moveto_update(ease_obj)
		easing_container = ease_obj[:target]
		@real_x = easing_container[:x]
		@real_y = easing_container[:y]
		increase_steps
	end

	def ease_moveto_complete(ease_obj)
		@x = @real_x
		@y = @real_y
		@easing = false
	end

	def ease_opacity(opacity, duration, easing = :linear)
		opacity = @opacity + opacity.to_i if opacity.is_a? String
		@wait_count = duration - 1
		@easing = true
		easing_container = {opacity: @opacity}
		target_attributes = {opacity: opacity}
		Ease.to(easing_container, duration, target_attributes, {
			easing: easing,
			observers: [self],
			call_on_update: :ease_opacity_update,
			call_on_complete: :ease_opacity_complete
			})
	end

	def ease_opacity_update(ease_obj)
		@opacity = ease_obj[:target][:opacity]
	end

	def ease_opacity_complete(ease_obj)
		@easing = false
	end

	def easing?
		@easing
	end

	#--------------------------------------------------------------------------
  # * OVERWRITE Frame Update
  #--------------------------------------------------------------------------
  def update
    update_animation
    return update_jump if jumping?
    return update_move if moving? && !easing?
    return update_stop
  end
end