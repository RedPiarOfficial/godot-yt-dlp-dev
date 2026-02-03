extends Node

var _thread: Thread = Thread.new()
func download(url: String, path: String, quality: String = 'best', args: Array = ["--no-overwrites", "--no-warnings", "--merge-output-format", "mp4", "--encoding", "utf-8"]):
	var query_data = [
		"--newline",
		"--progress",
		"--progress-template", '{"type":"progress","percent":"%(progress._percent_str)s","speed":"%(progress._speed_str)s","eta":"%(progress._eta_str)s"}',
		"-f", apply_quality(quality),
		"-o", path
	]
	query_data.append_array(args)
	if YtEvents.line_received.get_connections().is_empty():
		YtEvents.line_received.connect.call_deferred(_collect_lines)
	_thread.start(_download.bind(url, query_data))
	
func _download(url, data):
	YtCore.execute(url, data, true)
	
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
	var json = JSON.new()
	var error = json.parse(str(data))
	var json_valid = null
	
	if error == OK:
		if typeof(json.data) == TYPE_DICTIONARY:
			json_valid = json.data

	if json_valid and json_valid.get('type') == 'progress':
		YtEvents.download_progressed.emit.call_deferred({'percent': json_valid['percent'], 'speed': json_valid['speed'], 'eta': json_valid['eta']})
	elif json_valid and json_valid.get('type') == 'completed':
		YtEvents.download_completed.emit.call_deferred({'completed': true})
	elif not json_valid:
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
	if YtEvents.line_received.get_connections().is_empty():
		YtEvents.line_received.connect.call_deferred(_collect_lines)
	_thread.start(_download_audio.bind(url, audio_args))

func _download_audio(url, args):
	YtCore.execute(url, args, true)
	
func get_thumbnail(url: String, args: Array = ["--no-warnings"]):
	var query_data = ["--get-thumbnail"]
	query_data.append_array(args)
	_thread.start(_get_thumbnail.bind(url, query_data))
	
func _get_thumbnail(url, args):
	var data = YtCore.execute(url, args)
	YtEvents.get_thumbnail.emit.call_deferred(data)
