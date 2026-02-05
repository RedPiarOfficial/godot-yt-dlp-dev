extends Node
class_name YtUtils

static func get_ytdlp_path() -> String:
	var base_path = "user://"
	var file_name = ""
	
	match OS.get_name():
		"Windows":
			file_name = "yt-dlp.exe"
		"Linux", "FreeBSD", "NetBSD", "OpenBSD":
			file_name = "yt-dlp_linux"
		"macOS":
			file_name = "yt-dlp_macos"
		_:
			push_error("OS not supported")
			return ""

	var full_path = base_path + file_name
	
	if not FileAccess.file_exists(full_path):
		push_error("yt-dlp binary not found at: " + full_path)
		return ""

	var global_path = ProjectSettings.globalize_path(full_path)

	if OS.get_name() != "Windows":
		OS.execute("chmod", ["+x", global_path])
		
	return global_path
