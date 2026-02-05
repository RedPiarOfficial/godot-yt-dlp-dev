extends Node

# Signals for stream function
signal line_received(data)

# Signals for YtVideo
signal download_completed(data: Dictionary)
signal download_progressed(data: Dictionary)
signal download_logs(msg: String)
signal get_thumbnail(data: String)

# Signals for YtInfo
signal info_processed(data: Dictionary)
signal quality_processed(data: Dictionary)

# Signals for YtSearch
signal search_collector
signal search_logs
signal search_completed

# Errors
signal error_occurred(msg: String)
