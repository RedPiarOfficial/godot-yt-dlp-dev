extends Node

# Use a short video for quick tests
const TEST_URL = "https://www.youtube.com/watch?v=jNQXAC9IVRw" # Me at the zoo (19 sec)
var SAVE_PATH = OS.get_user_data_dir() + "/test_video.mp4"

func _ready():
	print("🟢 --- STARTING COMPREHENSIVE PLUGIN TEST ---")
	_connect_signals()
	
	# Start the test chain
	test_1_search_function()

# --- 1. SEARCH TEST ---
func test_1_search_function():
	print("\n[TEST 1] Checking search (YtSearch)...")
	# Emulate a search
	YtSearch.search("Godot Engine", 3)
	
	# Wait for completion via signal (or timeout as a fallback)
	await YtEvents.search_completed
	print("✅ [TEST 1] Search completed successfully.")
	
	# Move to the next test with a small delay
	await get_tree().create_timer(1.0).timeout
	test_2_info_concurrency()

# --- 2. INFO + CONCURRENCY TEST ---
func test_2_info_concurrency():
	print("\n[TEST 2] Checking YtInfo and protection against double calls...")
	
	# 1. Start Info retrieval
	print(" -> Request 1: Get Info (should succeed)")
	YtInfo.get_info(TEST_URL)
	
	# 2. Immediately try (while the first is still running) to request Qualities
	# Since in info.gd both methods use the thread name 'YtInfo',
	# the second call should be rejected by the manager.
	print(" -> Request 2: Get Qualities (should be rejected)")
	YtInfo.get_qualities(TEST_URL)
	
	# Wait for the first request to finish
	await YtEvents.info_processed
	print("✅ [TEST 2] Info data received. Check the console above: there should be an error about the YtInfo thread being busy.")
	
	await get_tree().create_timer(1.0).timeout
	test_3_thumbnail_blocking()

# --- 3. VIDEO THREAD BLOCKING TEST ---
func test_3_thumbnail_blocking():
	print("\n[TEST 3] Checking blocking in YtVideo...")
	print(" -> Starting Thumbnail download...")
	YtVideo.get_thumbnail(TEST_URL)
	
	# Try to start another video operation while the image is downloading
	# In video.gd both download and get_thumbnail use the name 'YtVideo'
	print(" -> Trying to start another get_thumbnail() simultaneously (should be blocked)...")
	YtVideo.get_thumbnail(TEST_URL)
	
	await YtEvents.get_thumbnail
	print("✅ [TEST 3] Thumbnail received. A second download should NOT have started.")

	await get_tree().create_timer(1.0).timeout
	test_4_full_download()

# --- 4. FULL DOWNLOAD TEST ---
func test_4_full_download():
	print("\n[TEST 4] Real video download...")
	
	# Remove old file if it exists
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	
	# Start download
	YtVideo.download(TEST_URL, SAVE_PATH, "240") # Low quality for speed
	
	# This await will only trigger if thread and signal logic is correct
	await YtEvents.download_completed
	
	if FileAccess.file_exists(SAVE_PATH):
		print("✅ [TEST 4] File successfully downloaded: ", SAVE_PATH)
	else:
		push_error("❌ [TEST 4] Signal received, but the file is missing!")

	print("\n🎉 ALL TESTS COMPLETED!")

# --- UTILITY FUNCTIONS ---
func _connect_signals():
	# Connect logging for better visibility of the process
	YtEvents.search_collector.connect(func(data): print("   [Search] Found: ", str(data).left(20) + "..."))
	YtEvents.info_processed.connect(func(data): print("   [Info] Metadata received: ", data.get("title", "No Title")))
	YtEvents.download_progressed.connect(func(data): print("   [Dl] %s | %s" % [data.percent, data.speed]))
	YtEvents.error_occurred.connect(func(msg): push_error("   [Error Event]: " + msg))
