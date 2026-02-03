extends Node

var _thread: Thread = Thread.new()

func search(query: String, max: int = 5, service: String = 'yt', args: Array = ["--no-warnings", "--dump-json", "--flat-playlist"]):
	_thread.start(_searching.bind(query, max, service, args))
	
func _searching(query, max, service, args):
	YtEvents.line_received.connect.call_deferred(_line_collector)
	YtCore.execute(service + 'search' + str(max) + ':' + query, args, true)
	
func _line_collector(line):
	var json = JSON.new()
	var error = json.parse(str(line))
	var json_valid = null
	
	if error == OK:
		if typeof(json.data) == TYPE_DICTIONARY:
			json_valid = json.data
	
	if json_valid:
		YtEvents.search_collector.emit.call_deferred(line)
	else:
		YtEvents.search_logs.emit.call_deferred(line)
