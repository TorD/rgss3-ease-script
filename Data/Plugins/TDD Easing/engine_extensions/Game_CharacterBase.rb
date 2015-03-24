#==============================================================================
# ** Game_CharacterBase EXTENSION
#------------------------------------------------------------------------------
# Version:  1.0.3
# Date:     07/31/2014
# Author:   Galenmereth / Tor Damian Design
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
raise "You need the TDD Easing Script to use this extension!" unless  $imported["TDD Easing Core"] || (Plugins && Plugins.has_plugin?("TDD Easing Core"))
$imported["TDD Easing Core<-Game_CharacterBase"] = true

class Game_CharacterBase
  @easing = false
  #--------------------------------------------------------------------------
  # * NEW Move Character To Other Character
  # Params:
  # =======
  # - char (integer)
  #     An integer noting the character to move to.
  #     -1 -> player
  #     0 -> the current object calling this method
  #     1-x -> event id on the current map
  # - frames (integer)
  #     How many frames the easing should last for
  # - easing (:symbol or "string")
  #     The easing method to apply. Default is :linear
  #--------------------------------------------------------------------------
  def ease_moveto_char(char_id, frames, easing = :linear)
    if char_id == -1
      char = $game_player
    elsif char_id == 0
      char = self
    else
      char = $game_map.events[char_id]
    end
    
    if char
      ease_moveto(char.x, char.y, frames, easing)
    else
      raise "No event with ID #{char_id} found"
    end
  end

  #--------------------------------------------------------------------------
  # * NEW Move To Position
  # Params:
  # =======
  # - x (integer or "string")
  #     The x position to move to.
  #     if integer then absolute X position on map
  #     if string then relative to current position. Examples:
  #       "0" -> 0 from current x pos
  #       "-5" -> -5 from current x pos
  #       "5" or "+5" -> +5 from current x pos
  # - y (integer or "string")
  #     The y position to move to. Same rules as x param
  # - frames (integer)
  #     How many frames the easing should last for
  #  - easing (:symbol or "string")
  #     The easing method to apply. Default is :linear
  #--------------------------------------------------------------------------
  def ease_moveto(x, y, frames, easing = :linear)
    x = @real_x + x.to_i if x.is_a? String
    y = @real_y + y.to_i if y.is_a? String
    @wait_count = frames - 1
    @easing = true
    easing_container = {
      x: @real_x,
      y: @real_y
    }
    target_attributes = {
      x: x,
      y: y
    }
    TDD::Ease.to(easing_container, frames, target_attributes, {
      easing: easing,
      observers: [self],
      call_on_update: :ease_moveto_update,
      call_on_complete: :ease_moveto_complete
      })
  end

  #--------------------------------------------------------------------------
  # * NEW Ease To Opacity
  # Params:
  # =======
  # - opacity (integer or "string")
  #     Target opacity to ease to. If string, then relative to current opacity
  #     value. See ease_moveto's x param for more on how to use relative
  #     string values.
  # - frames (integer)
  #     How many frames the easing should last for
  #  - easing (:symbol or "string")
  #     The easing method to apply. Default is :linear
  #--------------------------------------------------------------------------
  def ease_opacity(opacity, frames, easing = :linear)
    opacity = @opacity + opacity.to_i if opacity.is_a? String
    @wait_count = frames - 1
    @easing = true
    easing_container = {opacity: @opacity}
    target_attributes = {opacity: opacity}
    TDD::Ease.to(easing_container, frames, target_attributes, {
      easing: easing,
      observers: [self],
      call_on_update: :ease_opacity_update,
      call_on_complete: :ease_opacity_complete
      })
  end

  #--------------------------------------------------------------------------
  # * NEW Update Display Position (used by ease_moveto ease)
  #--------------------------------------------------------------------------
  def ease_moveto_update(ease_obj)
    last_real_x = @real_x
    last_real_y = @real_y
    easing_container = ease_obj.target
    @real_x = easing_container[:x]
    @real_y = easing_container[:y]
    increase_steps
    update_scroll(last_real_x, last_real_y) if self.instance_of? Game_Player
  end

  #--------------------------------------------------------------------------
  # * NEW Finalize And Update Map Position (used by ease_moveto ease)
  #--------------------------------------------------------------------------
  def ease_moveto_complete(ease_obj)
    @x = @real_x
    @y = @real_y
    @easing = false
  end

  #--------------------------------------------------------------------------
  # * NEW Update Opacity (used by ease_opacity ease)
  #--------------------------------------------------------------------------
  def ease_opacity_update(ease_obj)
    @opacity = ease_obj.target[:opacity]
  end

  #--------------------------------------------------------------------------
  # * NEW Finalize Opacity Ease (used by ease_opacity ease)
  #--------------------------------------------------------------------------
  def ease_opacity_complete(ease_obj)
    @easing = false
  end

  #--------------------------------------------------------------------------
  # * NEW Check If Easing?
  #--------------------------------------------------------------------------
  def easing?
    @easing
  end

  #--------------------------------------------------------------------------
  # * ALIAS Moving?
  #--------------------------------------------------------------------------
  alias :tdd_easing_moving? :moving?
  def moving?
    return easing? ? false : tdd_easing_moving?
  end

end