#==============================================================================
# ** Scene_Base EXTENSION
#------------------------------------------------------------------------------
# Version: 1.0.0
# Author: Galenmereth / Tor Damian Design
#
# Extended for: TDD Easing Script
# ===============================
# This calls update on the new Ease module, so that all applied easings are
# updated each frame tick. Nothing else.
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
class Scene_Base
  #--------------------------------------------------------------------------
  # * ALIAS Frame Update
  # Comments:
  #   Ease.update is called first so that the actual drawing performed by the
  #   original update_basic calls are performed after attributes have been
  #   set by active easing procedures.
  #--------------------------------------------------------------------------
  alias_method :tdd_easing_scene_update_basic_extension, :update_basic
  def update_basic
    TDD::Ease.update
    tdd_easing_scene_update_basic_extension
  end
end