
# V1.1.0
[Core] Added a global YtThreadManager for safe thread management.

[Core] Implemented protection against race conditions and repeated launches of the same process.

[Fix] Fixed GDScript compilation errors that caused crashes when loading singletons.

[Fix] Fixed the “caller thread can't call is_connected” error; signal handling is now fully thread-safe.

[Optimization] Separated threads into logical channels: Search, Info, Info:qual, and Download. This allows searching for videos while another video is being downloaded.
