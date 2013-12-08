Plugins.register("TDD Easing Core")
Plugins.load_files(:order => %w(tdd_ease_object))
Plugins.load_files(:path => "easing_addons")
Plugins.load_files(:path => "engine_extensions", :order => %w(Scene_Base))