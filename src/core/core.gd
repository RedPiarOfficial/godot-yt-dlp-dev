extends Node
class_name YtCore

static func execute(url: String, args: Array, stream: bool = false):
	var ytdlp_path = YtUtils.get_ytdlp_path()

	if not len(args):
		push_error('args is empty!')
		return {'Type': 'Error', 'msg': 'args is empty!'}
		
	args.insert(0, url)
		
	if stream:
		_Internal._run_with_stream(ytdlp_path, args)
	else:
		return _Internal._run_without_stream(ytdlp_path, args)
		
class _Internal:
	static func _run_without_stream(ytdlp_path: String, args: Array):
		var json = JSON.new()
		var output = []
		var exit_code = OS.execute(ytdlp_path, args, output)
		if exit_code == 0:
			var error = json.parse(str(output[0].strip_edges()))
			if error == OK and typeof(json.data) == TYPE_DICTIONARY:
				return json.data
			elif output[0]:
				return {'data': str(output[0].strip_edges())}
			else:
				push_error('[Error] Data been not received')
				return {'Type': 'Error', 'msg': 'Data been not received'}
		else:
			push_error('[Error]: ' + str(exit_code) + ' code')
			return {'Type': 'Error', 'msg': str(exit_code) + ' code'}
			
	static func _run_with_stream(ytdlp_path, args):
		var process_info = OS.execute_with_pipe(ytdlp_path, args)
		var pipe = process_info['stdio']
		var pid = process_info["pid"]
		
		while pipe.is_open():
			var line = pipe.get_line().strip_edges()
			if line.is_empty():
				if not OS.is_process_running(pid):
					break
				OS.delay_msec(10)
				continue
			YtEvents.line_received.emit.call_deferred(line)
		pipe.close()
		YtEvents.line_received.emit.call_deferred(JSON.stringify({'type': 'completed'}))
