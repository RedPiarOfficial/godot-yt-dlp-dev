extends Node

signal setup_completed
signal _update_completed

const Downloader = preload("res://addons/godot-yt-dlp-dev/src/downloader.gd")

const yt_dlp_sources: Dictionary = {
	"Linux": "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux",
	"Windows": "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe",
	"macOS": "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_macos",
}
const ffmpeg_sources: Dictionary = {
	"Windows": "https://github.com/yt-dlp/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
}

var _downloader: Downloader
var _thread: Thread = Thread.new()
var _is_setup: bool = false


func is_setup() -> bool:
	return _is_setup

func setup() -> void:
	_downloader = Downloader.new()
	var executable_name: String = "yt-dlp.exe" if OS.get_name() == "Windows" else "yt-dlp"

	if not FileAccess.file_exists("user://%s" % executable_name):
		# Download new yt-dlp binary
		_downloader.download(yt_dlp_sources[OS.get_name()], "user://%s" % executable_name)
		await _downloader.download_completed
	else:
		# Update existing yt-dlp
		_thread.start(_update_yt_dlp.bind(executable_name))
		await _update_completed
		# Wait for the next idle frame to join thread
		await (Engine.get_main_loop() as SceneTree).process_frame
		_thread.wait_to_finish()

	if OS.get_name() == "Windows":
		await _setup_ffmpeg()
	else:
		OS.execute("chmod", PackedStringArray(["+x", OS.get_user_data_dir() + "/yt-dlp"]))

	_is_setup = true
	setup_completed.emit()


func _setup_ffmpeg() -> void:
	if FileAccess.file_exists("user://ffmpeg.exe") and FileAccess.file_exists("user://ffprobe.exe"):
		return
	
	const ffmpeg_release_filepath = "user://ffmpeg-release.zip";
	_downloader.download(ffmpeg_sources["Windows"], ffmpeg_release_filepath)
	await _downloader.download_completed
	
	var zip_reader := ZIPReader.new()
	var error := zip_reader.open(ffmpeg_release_filepath)
	if error != OK:
		push_error(self, "Couldn't extract ffmpeg release: %s" % error_string(error))
		return
	
	var filepaths := Array(zip_reader.get_files()).filter(
		func(s): return s.contains('bin/ffmpeg') or s.contains('bin/ffprobe')
	)
	
	for f in filepaths:
		var filename := f.get_file() as String
		var file := FileAccess.open("user://%s" % filename, FileAccess.WRITE)
		file.store_buffer(zip_reader.read_file(f))
		file.close()
	
	DirAccess.remove_absolute(ProjectSettings.globalize_path(ffmpeg_release_filepath))

func _update_yt_dlp(filename: String) -> void:
	OS.execute("%s/%s" % [OS.get_user_data_dir(), filename], ["--update"])
	_thread_finished.call_deferred(_update_completed)

func _thread_finished(name: Signal) -> void:
	if name != null:
		name.emit()
