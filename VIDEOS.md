# Video Storage & Sharing

Since video files are too large for Git, we're using cloud storage for sharing.

## 📹 Video Collection

### Option 1: Microsoft OneDrive
**Upload your football videos here, then share the link with your team**

Instructions:
1. Go to https://onedrive.live.com
2. Sign in with your Microsoft account
3. Create folder: `VAST-Football-Videos`
4. Upload your football goal videos
5. Right-click folder → Share → Copy link
6. Paste link below:

**OneDrive Link**: `[PASTE YOUR LINK HERE]`

### Option 2: Google Drive
Alternative if you prefer Google Drive

Instructions:
1. Go to https://drive.google.com
2. Create folder: `VAST-Football-Videos`
3. Upload your videos
4. Right-click folder → Share → Copy link
5. Paste link below:

**Google Drive Link**: https://drive.google.com/drive/folders/1ec09ZiC1PzC0aOEXg-dxSNEeHMlFnSKj

## 📦 Video Naming Convention

Use this naming pattern for easy identification:

```
football_<type>_<passcount>_<number>.mp4

Examples:
- football_goal_3passes_001.mp4
- football_goal_5passes_002.mp4
- football_buildup_7passes_001.mp4
- football_counterattack_2passes_001.mp4
```

## 📋 Video Inventory

Track uploaded videos here:

| Filename | Duration | Type | Pass Count | Notes |
|----------|----------|------|------------|-------|
| `football_goal_3passes_001.mp4` | 0:15 | Goal | 3 | Quick buildup |
| `football_goal_5passes_002.mp4` | 0:20 | Goal | 5 | Tiki-taka style |
| ... | ... | ... | ... | ... |

## 🔽 For Teammates: How to Download

1. Click the OneDrive/Google Drive link above
2. Download the entire folder or select specific videos
3. Place videos in the `videos/` directory
4. On VAST VM, use the upload scripts in `scripts/` to upload to VAST

## 💾 Recommended Videos

For the hackathon, focus on:
- **Short clips**: 10-30 seconds each
- **Clear goals**: With visible buildup play
- **Multiple passes**: 3+ passes before goal
- **Good quality**: 720p or better
- **Total size**: Keep under 500MB for easy sharing

## 🎯 Quick Upload to Cloud

### Using OneDrive CLI (optional)
```bash
# Install rclone
brew install rclone

# Configure OneDrive
rclone config

# Upload videos folder
rclone copy videos/ onedrive:VAST-Football-Videos
```

### Using Google Drive CLI (optional)
```bash
# Install gdrive
brew install gdrive

# Authenticate
gdrive about

# Upload folder
gdrive upload --recursive videos/
```

## 📝 Notes

- Don't commit videos to Git (too large, already in .gitignore)
- Share cloud link with teammates via Discord/Slack/Email
- Keep original videos as backup
- Compressed versions OK if under size limit

---

**Last Updated**: [Add date when you upload]
**Uploaded By**: [Your name]
**Video Count**: [Number of videos]
**Total Size**: [Total size in MB]
