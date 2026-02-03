# godot-yt-dlp-dev
A simple API for downloading videos from YouTube (and other websites).

![Godot v4.x](https://img.shields.io/badge/Godot-v4.5+-478cbf?logo=godot-engine&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)
![Version](https://img.shields.io/badge/Version-1.0.0-blue)

**Godot yt-dlp dev** is a convenient wrapper (API) around the popular **yt-dlp** utility for **Godot Engine 4**. The plugin allows you to download video and audio, retrieve media information, search content on YouTube and other platforms directly from your game or application.

> [!IMPORTANT]
> The plugin automatically downloads the required binaries (**yt-dlp** and **ffmpeg**) when the `YtDlp.setup()` command is executed.

---

## ✨ Features
- 📥 Video downloading with quality selection (1080p, 720p, etc.).
- 🎵 Audio extraction (mp3 and other formats).
- ℹ️ Metadata retrieval (video info, available formats).
- 🔍 Video search by query.
- 🖼 Thumbnail downloading.
- 🧵 Asynchronous execution: all operations run in threads and do not block the main game loop.

---

## 📦 Installation & Setup
1. Copy the `addons/godot-yt-dlp-dev` folder into your project.
2. Open **Project → Project Settings → Plugins** and enable the plugin.

### Initial Setup
Before using any functionality, you must initialize the plugin so it can download or update the required executables (**yt-dlp** and **ffmpeg**).

```gdscript
func _ready():
    # Connect to the setup completion signal
    YtDlp.setup_completed.connect(_on_setup_completed)

    # Start setup process
    YtDlp.setup()

func _on_setup_completed():
    print("Yt-dlp is ready to use!")
```

---

## 🚀 Usage
The plugin provides several singletons (Autoloads): `YtDlp`, `YtVideo`, `YtInfo`, `YtSearch`, and `YtEvents`.

### 1. Video Downloading (YtVideo)
Use the `download` method to download a video. Progress and results are delivered via `YtEvents` signals.

```gdscript
func download_video(url: String):
    # Subscribe to progress and completion
    YtEvents.download_progressed.connect(_on_progress)
    YtEvents.download_completed.connect(_on_completed)

    # download(url, save_path, quality)
    # Quality: 'best' or a number (e.g. '1080')
    YtVideo.download(url, OS.get_user_data_dir() + '/downloads/%(title)s.%(ext)s', "1080")

func _on_progress(data: Dictionary):
    # data contains: percent, speed, eta
    print("Downloaded: %s, Speed: %s" % [data['percent'], data['speed']])

func _on_completed(data: Dictionary):
    print("Download completed!")
```

### 2. Audio Downloading

```gdscript
# download_audio(url, path, format, audio_quality)
YtVideo.download_audio("https://youtu.be/...", OS.get_user_data_dir() + "/track.mp3", "mp3", 0)
```

---

### 3. Video Information & Formats (YtInfo)
To retrieve available video resolutions before downloading:

```gdscript
func get_video_qualities(url: String):
    YtEvents.quality_processed.connect(func(qualities): print(qualities))
    YtInfo.get_qualities(url)
    # Returns an array of strings: ["1080p", "720p", "480p", ...]
```

To retrieve full JSON information about a video:

```gdscript
YtInfo.get_info(url) # Result will be emitted via YtEvents.info_processed
```

---

### 4. Search (YtSearch)
Search for videos.

```gdscript
func search_youtube(query: String):
    YtEvents.search_collector.connect(_on_search_result)
    # search(query, result_count, service)
    YtSearch.search(query, 5, "yt")

func _on_search_result(json_string: String):
    var data = JSON.parse_string(json_string)
    print("Found: ", data.get("title"))
```

---

### 5. Low-Level Access (YtCore)
If you need to execute a specific `yt-dlp` command that is not available through the high-level singletons, use `YtCore.execute`. This is a universal method for custom requests.

```gdscript
# Example: Get a list of all available formats (without downloading)
var args = ["--list-formats"]
var result = YtCore.execute("URL_HERE", args, false) # stream = false for instant result
print(result)
```

---

## 📡 API Reference

### YtDlp Singleton
Manages dependency installation.
- `setup()` – Starts downloading/updating binaries.
- `is_setup() -> bool` – Returns `true` if setup is completed.
- Signals: `setup_completed`, `_update_completed`.

### YtVideo Singleton
Media-related methods.
- `download(url: String, path: String, quality: String = 'best', args: Array = [...])`
- `download_audio(url: String, path: String, format: String = 'mp3', quality: int = 0)`
- `get_thumbnail(url: String, args: Array = [...])` – Requests thumbnail URL.

### YtInfo Singleton
Metadata retrieval methods.
- `get_info(url: String)` – Full video data dump.
- `get_qualities(url: String)` – List of available video heights (1080, 720, etc.).

### YtEvents Singleton (Signals)
Central event hub. Connect to it to receive responses.

| Signal | Description |
| :--- | ---: |
| download_progressed | Download progress |
| download_completed | Download completed |
| download_logs | Logs |
| info_processed | Full video information |
| quality_processed | Available qualities |
| search_collector | Single search result |
| search_logs | Logs |
| get_thumbnail | Thumbnail URL |
| error_occurred | Error message |

---

## ⚙️ Configuration & Dependencies
The plugin stores executable files in the user data directory (`user://`).

- **Windows**: `yt-dlp.exe`, `ffmpeg.exe`, `ffprobe.exe`
- **Linux/macOS**: `yt-dlp_linux` / `yt-dlp_macos` (automatically granted `chmod +x` permissions)

> [!NOTE]
> On Windows, the plugin automatically downloads and extracts **FFmpeg**, which is required to merge video and audio streams when downloading high-quality formats.

---

## ⚠️ Known Limitations
Functionality depends on **yt-dlp** updates. If YouTube changes its API, run `setup()` to update the binary.

---

## 🤝 Want to Contribute?
The **Godot yt-dlp dev** project is open to ideas and improvements! Pull Requests for new features or bug fixes are welcome.

### Possible TODOs
- **Download Queue**: Queue system to download dozens of videos sequentially.
- **Built-in UI**: Ready-made Node for quick integration of a download window into any game.
- **Playlist Support**: Batch downloading all videos from a single playlist link.

> If you have an idea not listed above, create an **Issue** and we’ll discuss its implementation.

