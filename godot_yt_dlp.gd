@tool
extends EditorPlugin


const AUTOLOAD_NAME = "YtDlp"


func _enter_tree():
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/godot-yt-dlp-dev/src/yt_dlp.gd")
	add_autoload_singleton('YtEvents', 'res://addons/godot-yt-dlp-dev/src/PluginEvents.gd')
	add_autoload_singleton('YtInfo', 'res://addons/godot-yt-dlp-dev/src/functions/info.gd')
	add_autoload_singleton('YtVideo', 'res://addons/godot-yt-dlp-dev/src/functions/video.gd')
	add_autoload_singleton('YtSearch', 'res://addons/godot-yt-dlp-dev/src/functions/search.gd')
func _exit_tree():
	remove_autoload_singleton(AUTOLOAD_NAME)
	remove_autoload_singleton('YtEvents')
	remove_autoload_singleton('YtInfo')
	remove_autoload_singleton('YtVideo')
	remove_autoload_singleton('YtSearch')
