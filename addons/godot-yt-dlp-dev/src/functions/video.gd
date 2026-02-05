extends Node

var regex = RegEx.new()

func _ready() -> void:
	regex.compile("(?<percent>\\d+\\.\\d+)%.*at\\s+(?<speed>[\\d\\.]+\\w+/s)\\s+ETA\\s+(?<eta>[\\d:]+)")

func download(url: String, path: String, quality: String = 'best', args: Array = ["--no-overwrites", "--no-warnings", "--merge-output-format", "mp4", "--encoding", "utf-8"]):
	var query_data = [
		"--newline",
		"-f", apply_quality(quality),
		"-o", path
	]
	query_data.append_array(args)
	if not YtEvents.line_received.is_connected(_collect_lines):
		YtEvents.line_received.connect(_collect_lines)
	YtThreadManager.create_thread(_download.bind(url, query_data), 'YtVideo')
	
func _download(url, data):
	YtCore.execute(url, data, true)
	YtThreadManager.close_thread()
	
func apply_quality(quality: String) -> String: 
		var q
		if quality == 'best':
			q = 'bestvideo+bestaudio/best'
		elif quality.is_valid_int():
			q = "bestvideo[height<=" + quality + "]+bestaudio/best"
		else:
			push_error('Invalid quality. Example: best, 1080, 240')
			
		return q if q != null else ""

func _collect_lines(data: String):
	var clean_data = data.strip_edges()
	if clean_data.is_empty():
		return

	if clean_data.begins_with("{"):
		var json_data = JSON.parse_string(clean_data)
		if json_data is Dictionary and json_data.get("type") == "completed":
			YtEvents.download_completed.emit.call_deferred({"completed": true})
			return

	var result = regex.search(clean_data)
	if result:
		var percent = result.get_string("percent")
		var speed = result.get_string("speed")
		var eta = result.get_string("eta")
		YtEvents.download_progressed.emit.call_deferred({
			"percent": float(percent),
			"speed": speed,
			"eta": eta
		})
	else:
		# 3. Если не подошло ни то, ни другое — это просто лог
		YtEvents.download_logs.emit.call_deferred(data)

func download_audio(url: String, path: String, format: String = 'mp3', quality: int = 0):
	var audio_args = [
		"--extract-audio",
		"--audio-format", format,
		"--audio-quality", str(quality),
		"--no-playlist",
		"-o", path,
		"--encoding", "utf-8"
	]
	if not YtEvents.line_received.is_connected(_collect_lines):
		YtEvents.line_received.connect(_collect_lines)
	YtThreadManager.create_thread(_download_audio.bind(url, audio_args), 'YtVideo')

func _download_audio(url, args):
	YtCore.execute(url, args, true)
	YtThreadManager.close_thread()

func get_thumbnail(url: String, args: Array = ["--no-warnings"]):
	var query_data = ["--get-thumbnail"]
	query_data.append_array(args)
	YtThreadManager.create_thread(_get_thumbnail.bind(url, query_data), 'YtVideo:thumb')
	
func _get_thumbnail(url, args):
	var data = YtCore.execute(url, args)
	YtThreadManager.close_thread()
	YtEvents.get_thumbnail.emit.call_deferred(data)
