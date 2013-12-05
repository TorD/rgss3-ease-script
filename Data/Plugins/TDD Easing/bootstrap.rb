Plugins.register("TDD Easing Core")
Plugins.load_files(:path => "engine_extensions", :order => %w(scene_base_extensions))
Plugins.load_files
Plugins.load_files(:path => "easing_addons")
Plugins.load_files(:path => "engine_functionality_addons")