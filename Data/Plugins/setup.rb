# OPTIONAL: This is an optional array of plugins that are to be loaded first, and in the specified order. All other plugins not mentioned here are loaded afterwards and alphabetically.
# You can leave this array empty.
PRIORITY_PLUGINS = [
]

# REQUIRED: This is the root plugin directory (the one this file resides in).
ROOT_PATH = "Plugins"

# We now require the Plugins module
load_script "Data/#{ROOT_PATH}/plugins_module.rb"

# REQUIRED: We set the above settings in the Plugins module
Plugins.root_path = ROOT_PATH                     

# REQUIRED: We load all the plugins found in the ROOT_PATH folder. The :order param includes the above specified PRIORITY_PLUGINS array.
# If you don't have any need for prioritizing plugins, simply call it without any params, like the line commented out below
# Plugins.load_plugins
Plugins.load_plugins(
  :path => "*",
  :order => PRIORITY_PLUGINS
  )

Plugins.package

load_script "Data/#{ROOT_PATH}/scripts.rb"