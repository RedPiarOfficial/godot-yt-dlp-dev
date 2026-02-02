# 🛠 Godot-Yt-Dlp-Dev Development Plan

Here are the tasks for improving the plugin. If you want to help, feel free to create an issue or a pull request!

## 🟥 High Priority (To be done soon)
- [ ]  **Stable progress parsing**: Switch to parsing standard output if the JSON template continues to fail indownload_audio.

## 🟨 Medium Priority (New features)
- [ ] **Download queue**: Implement a manager that allows adding up to 10 videos to a list and downloading them one by one.

## 🟩 Low Priority (Improvements & nice-to-haves)
- [ ] **Built-in UI**: A ready-made Node for quick integration of a download window into any game.
- [ ] **Playlist support:**: Logic for batch downloading all videos from a single link.

## ✅ Завершено
- [x] Base architecture `YtCore`.
- [x] Video search via `YtSearch`.
- [x] Video interactions via `YtVideo` (e.g. download, download_audio, etc.)
- [x] Information extraction via `YtInfo`
- [x] Signal system via the `YtEvents` singleton.
