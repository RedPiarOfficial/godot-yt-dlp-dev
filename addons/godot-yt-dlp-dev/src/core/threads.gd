extends Node
class_name YtThreadManager

# Делаем это статическим свойством, чтобы доступ был глобальным через YtThreadManager
static var data: Dictionary = {
	"threads": [] # Список словарей: {"id": String, "thread": Thread, "name": String}
}

## Создает и запускает уникальный поток
static func create_thread(callable: Callable, unique_name: String = "Thread1") -> Thread:
	# 1. Проверяем, не занято ли имя
	for th in data["threads"]:
		if unique_name == th["name"]:
			var existing_thread = th["thread"]
			if existing_thread.is_alive():
				push_error("YtThreadManager: Thread '%s' is still busy!" % unique_name)
				return null
			else:
				# Если поток завершился, но еще в списке — очищаем его перед новым запуском
				_clean_thread_by_name(unique_name)
				break
				
	var thread: Thread = Thread.new()
	
	# Запускаем callable
	var error = thread.start(callable)
	
	if error != OK:
		push_error("YtThreadManager: Failed to start thread '%s'" % unique_name)
		return null

	# Сохраняем данные. Используем строковый ID для надежного сравнения
	data["threads"].append({
		"id": str(thread.get_id()), 
		"thread": thread, 
		"name": unique_name
	})
	
	return thread

## Закрывает поток, который вызвал эту функцию
static func close_thread() -> void:
	var current_id = str(OS.get_thread_caller_id())
	var thread_to_close: Thread = null
	var index_to_remove: int = -1

	# Ищем поток в нашем списке по ID вызвавшего
	for i in range(data["threads"].size()):
		if data["threads"][i]["id"] == current_id:
			thread_to_close = data["threads"][i]["thread"]
			index_to_remove = i
			break

	if thread_to_close:
		# Удаляем из списка ДО завершения, чтобы имя освободилось сразу
		data["threads"].remove_at(index_to_remove)
		
		# Безопасно завершаем через основной поток (deferred)
		# Используем лямбду, чтобы передать ссылку на объект потока
		var finish_task = func(t: Thread):
			if t and t.is_started():
				t.wait_to_finish()
				# print("YtThreadManager: Thread closed safely.")
		
		finish_task.call_deferred(thread_to_close)
	else:
		push_warning("YtThreadManager: close_thread() called from a thread not managed by YtThreadManager (ID: %s)" % current_id)

## Внутренняя функция очистки (если имя совпало, но поток мертв)
static func _clean_thread_by_name(unique_name: String):
	for i in range(data["threads"].size()):
		if data["threads"][i]["name"] == unique_name:
			var t = data["threads"][i]["thread"]
			if t.is_started():
				t.wait_to_finish()
			data["threads"].remove_at(i)
			return
