extends Node

var _thread = Thread.new()
func get_info(url: String):
	if url.is_empty() or not url.begins_with('http'):
		push_error('url empty or url not http(s)')
		return
		
	_thread.start(_get_info.bind(url))
	
func _get_info(url):
	var data = YtCore.execute(url, ["--dump-json", "--no-playlist", "--skip-download", "--no-warnings"])
	if data.find_key('Type'):
		_send_error.call_deferred(data['msg'])
		return
	_info_load.call_deferred(data)
	
func _info_load(data: Dictionary):
	_thread.wait_to_finish()
	YtEvents.info_processed.emit.call_deferred(data)

func get_qualities(url: String):
	_thread.start(_get_qualities.bind(url))
	
func _get_qualities(url: String):
	var data = YtCore.execute(url, ["--dump-json", "--no-playlist", "--skip-download", "--no-warnings"])
	if data.find_key('Type'):
		_send_error.call_deferred(data['msg'])
		return

	var quality_selector = []
	var valid_heights = []
	for f in data['formats']:
		var h = f.get("height", 0)
		var vcodec = f.get("vcodec", "none")
		var acodec = f.get("acodec", "none")
		if vcodec != "none" and h >= 144 and f.get("ext") != "mhtml":
			if not h in valid_heights:
				valid_heights.append(h)
	valid_heights.sort()
	valid_heights.reverse()
	for height in valid_heights:
		quality_selector.append(str(height) + "p")
		
	_qualities_load.call_deferred(quality_selector)
	
func _qualities_load(data: Array):
	_thread.wait_to_finish()
	YtEvents.quality_processed.emit.call_deferred(data)
	
func _send_error(msg: String):
	_thread.wait_to_finish()
	YtEvents.error_occurred.emit.call_deferred(msg)
