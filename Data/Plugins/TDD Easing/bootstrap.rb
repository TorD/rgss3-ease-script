Plugins.register("TDD Easing Core")
Plugins.load_files
Plugins.load_files(:path => "easing_addons")
Plugins.load_files(:path => "engine_extensions", :order => %w(Scene_Base))