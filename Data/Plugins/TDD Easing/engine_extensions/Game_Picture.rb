#==============================================================================
# ** Game_Picture EXTENSION
#------------------------------------------------------------------------------
# Extended for: TDD Easing Script
# ===============================
# This extension changes the default transition easing for Move Picture and
# Tint Picture, so that it uses the TDD Easing script motion instead.
#
# How to use:
# ===========
# Use Game_Picture.easing= to set an easing method before calling move or 
# start_tone_change, either through scripts or through the use of Move Picture
# and Tint Picture event calls. Look at self.easing and self.easing_default
# for more details
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
class Game_Picture
	# Global default easing method; can be set using Game_Picture.easing_default=
	@@easing_method_default = Easing::LINEAR

	# List of variables to use for easing movement
	@@easing_move_attributes = %w(
		x
		y
		zoom_x
		zoom_y
		opacity
		duration)

	# List of variables to use for easing tone change
	@@easing_tint_attributes = %w(
		red
		green
		blue
		gray
		)

	#--------------------------------------------------------------------------
  # * ALIAS Move Picture
  #--------------------------------------------------------------------------
	alias_method :tdd_easing_move_extension, :move
	def move(origin, x, y, zoom_x, zoom_y, opacity, blend_type, duration)
    tdd_easing_move_extension(origin, x, y, zoom_x, zoom_y, opacity, blend_type, duration)

    target_attributes = {}
    easing_container = {}
    @@easing_move_attributes.each do |attr|
    	easing_container[attr] = instance_variable_get("@#{attr}")
    	target_attributes[attr] = eval(attr)
    end
    puts @easing_method
		Ease.to(easing_container, duration, target_attributes, {
			:easing => @@easing_method,
			:observers => [self],
			:call_on_update => :update_move
			})
  end

  #--------------------------------------------------------------------------
  # * ALIAS Start Changing Color Tone
  #--------------------------------------------------------------------------
  alias_method :tdd_easing_start_tone_change_extension, :start_tone_change
  def start_tone_change(tone, duration)
  	tdd_easing_start_tone_change_extension(tone, duration)

  	easing_container = {}
  	target_attributes = {}
    @@easing_tint_attributes.each do |attr|
    	easing_container[attr] = @tone.send(attr)
    	target_attributes[attr] = @tone_target.send(attr)
    end

    Ease.to(easing_container, duration, target_attributes, {
    	:easing => @@easing_method,
    	:observers => [self],
    	:call_on_update => :update_tone_change
    	})
    puts "Tint: #{@@easing_method}"
  end

  #--------------------------------------------------------------------------
  # * ALIAS Erase Picture
  # Comments:
  # 	The class static variable @@easing_method is reset to
  # 	@@easing_method_default upon erasure.
  #--------------------------------------------------------------------------
  alias_method :tdd_easing_erase_extension, :erase
  def erase
  	tdd_easing_erase_extension
  	@@easing_method = @@easing_method_default
  end

  #--------------------------------------------------------------------------
  # * OVERWRITE Frame Update
  # Comments:
  # 	update_move and update_tone_change left commented out to make it clear
  # 	that these have been disabled
  #--------------------------------------------------------------------------
  def update
  	# update_move
  	# update_tone_change
  	update_rotate
  end

  #--------------------------------------------------------------------------
  # * ALIAS Update Picture Move
  # Comments:
  # 	In case other scripts want to call update_move for any reason,
  # 	I make it check for the ease_obj from the easing; if it's not there,
  # 	it uses the default update_move method
  #-------------------------------------------------------------------------
  alias_method :tdd_easing_update_move_extension, :update_move
	def update_move(ease_obj = nil)
		unless ease_obj
			tdd_easing_update_move_extension
			return
		end
		easing_container = ease_obj[:target]
		@@easing_move_attributes.each do |attr|
			instance_variable_set("@#{attr}", easing_container[attr])
		end
	end

	#--------------------------------------------------------------------------
  # * ALIAS Update Color Tone Change
  # Comments:
  # 	In case other scripts want to call update_tone_change for any reason,
  # 	I make it check for the ease_obj from the easing; if it's not there,
  # 	it uses the default update_tone_change method
  #--------------------------------------------------------------------------
  alias_method :tdd_easing_update_tone_change_extension, :update_tone_change
  def update_tone_change(ease_obj)
  	unless ease_obj
			tdd_easing_update_tone_change_extension
			return
		end
  	easing_container = ease_obj[:target]
  	@@easing_tint_attributes.each do |attr|
  		@tone.send("#{attr}=", easing_container[attr])
    end
  end

  #--------------------------------------------------------------------------
  # * NEW Static Method Set Easing
  #--------------------------------------------------------------------------
	def self.easing=(easing_method)
		@@easing_method = easing_method
	end

	#--------------------------------------------------------------------------
  # * NEW Static Method Set Easing Default for Game_Picture class
  #--------------------------------------------------------------------------
	def self.easing_default=(easing_method)
		@@easing_method_default = easing_method
	end
end