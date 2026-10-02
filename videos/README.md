# Videos Directory

## 📹 Place Your Football Videos Here

This directory is for your football video files.

### Supported Formats
- `.mp4` (recommended)
- `.mov`
- `.avi`
- `.mkv`
- `.webm`

### Naming Convention

Use descriptive names:
```
football_goal_<passcount>passes_<number>.mp4
```

Examples:
- `football_goal_3passes_001.mp4`
- `football_goal_5passes_002.mp4`
- `football_buildup_7passes_001.mp4`

### File Size

Keep files under 100MB for easy upload to VAST.

To compress larger videos:
```bash
ffmpeg -i large_video.mp4 -vcodec h264 -acodec mp2 compressed.mp4
```

### Where to Get Videos

**Important**: Don't use YouTube or copyrighted videos!

Check [../VIDEOS.md](../VIDEOS.md) for:
- Shared OneDrive/Google Drive link
- Download instructions
- Video inventory

### Git Ignore

Videos are automatically ignored by git (.gitignore).
Share videos via OneDrive/Google Drive instead.

---

**Ready to upload?** See `../scripts/` for upload tools.
