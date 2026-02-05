extends Node

func search(query: String, max: int = 5, service: String = 'yt', args: Array = ["--no-warnings", "--dump-json", "--flat-playlist"]):
	YtThreadManager.create_thread(_searching.bind(query, max, service, args), 'YtSearch')
	
func _searching(query, max, service, args):
	# 1. Подключаем сборщик строк БЕЗОПАСНО через call_deferred
	# (так как мы в потоке, а YtEvents в Main Thread)
	(func(): 
		if not YtEvents.line_received.is_connected(_line_collector):
			YtEvents.line_received.connect(_line_collector)
	).call_deferred()

	# 2. Запускаем выполнение
	YtCore.execute(service + 'search' + str(max) + ':' + query, args, true)
	
	# 3. Отключаем сборщик после завершения
	(func(): 
		if YtEvents.line_received.is_connected(_line_collector):
			YtEvents.line_received.disconnect(_line_collector)
	).call_deferred()

	# 4. Закрываем поток и уведомляем о конце
	YtThreadManager.close_thread()
	YtEvents.search_completed.emit.call_deferred()
	
func _line_collector(line):
	# Сначала чистим строку от лишних пробелов
	var clean_line = str(line).strip_edges()
	if clean_line.is_empty(): return

	var json = JSON.new()
	var error = json.parse(clean_line)
	
	if error == OK and typeof(json.data) == TYPE_DICTIONARY:
		# Если это валидный JSON (результат поиска), шлем данные
		YtEvents.search_collector.emit.call_deferred(json.data)
	else:
		# Если это просто текст (логи), шлем в логи
		YtEvents.search_logs.emit.call_deferred(clean_line)
