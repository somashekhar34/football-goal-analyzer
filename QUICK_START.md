# 🚀 Quick Start - What To Do Now

## ✅ What's Done

- [x] GitHub repo created: https://github.com/somashekhar34/football-goal-analyzer
- [x] Project structure set up
- [x] Upload scripts ready
- [x] Documentation complete
- [x] Code pushed to GitHub

## 📋 Your Next Steps (Local Machine)

### Step 1: Upload Videos to Cloud Storage

Choose OneDrive OR Google Drive to share videos with your teammate:

#### Option A: OneDrive

1. Go to https://onedrive.live.com
2. Sign in with your Microsoft account
3. Create folder: `VAST-Football-Videos`
4. Upload your football videos (the ones you want to analyze)
5. Right-click folder → **Share** → **Copy link**
6. Edit `VIDEOS.md` in this repo and paste the link
7. Commit and push:
   ```bash
   git add VIDEOS.md
   git commit -m "Add OneDrive link for videos"
   git push
   ```

#### Option B: Google Drive

1. Go to https://drive.google.com
2. Create folder: `VAST-Football-Videos`
3. Upload your videos
4. Right-click → **Share** → **Copy link**
5. Edit `VIDEOS.md` and paste link
6. Commit and push (same as above)

### Step 2: Prepare Your Videos

If you have football videos locally:

```bash
# Copy them to the videos folder (for reference)
cp /path/to/your/videos/*.mp4 videos/

# List what you have
ls -lh videos/

# Compress if needed (>100MB)
ffmpeg -i large_video.mp4 -vcodec h264 compressed.mp4
```

### Step 3: Update HANDOFF.md

Edit `docs/HANDOFF.md` and fill in:
- Your name
- Today's date
- Any notes for your teammate
- Video count and details

```bash
# Open in editor
open docs/HANDOFF.md
# Or: code docs/HANDOFF.md
```

### Step 4: Share with Teammate

Send your teammate:

1. **GitHub Repo**: https://github.com/somashekhar34/football-goal-analyzer
2. **Video Link**: (from VIDEOS.md)
3. **Handoff Doc**: docs/HANDOFF.md

Message template:
```
Hey! I've set up our VAST hackathon project:

🔗 GitHub: https://github.com/somashekhar34/football-goal-analyzer
📹 Videos: [link from VIDEOS.md]
📝 Instructions: See docs/HANDOFF.md

Everything's ready for you to deploy on the VM!
The docs have step-by-step instructions.

Let me know if you need anything! 🚀
```

## 👥 For Your Teammate (On VM)

They should:

1. Clone the repo on VM
2. Download videos from your shared link
3. Upload videos to VAST using the scripts
4. Build the analyzer in Cursor
5. Deploy and demo

Full instructions in: **docs/VM_DEPLOYMENT.md**

## 📊 What You Built

### Files Created:

```
football-goal-analyzer/
├── README.md                      # Project overview
├── VIDEOS.md                      # Video sharing instructions
├── QUICK_START.md                 # This file
│
├── scripts/
│   ├── upload_to_vast.sh         # Upload single video to VAST
│   ├── batch_upload_vast.py      # Batch upload multiple videos
│   └── vast_api.py                # Python wrapper for VAST API
│
├── docs/
│   ├── HANDOFF.md                 # Teammate handoff document
│   └── VM_DEPLOYMENT.md           # VM deployment guide
│
├── src/                           # For application code (empty)
├── videos/                        # For video files
└── .gitignore                     # Git ignore (videos, credentials, etc.)
```

### What Each Script Does:

**`upload_to_vast.sh`**
- Uploads one video at a time
- Interactive prompts for metadata
- Progress monitoring

**`batch_upload_vast.py`**
- Uploads multiple videos matching a pattern
- Automated batch processing
- Summary reports

**`vast_api.py`**
- Python wrapper for VAST API
- Easy-to-use functions for search, upload, analysis
- Ready to use in your app

## 💡 Project Idea Recap

**Football Goal Analyzer** - AI-powered analysis of goals and passing sequences

Features:
1. Search all football videos for goals
2. Analyze 10 seconds before each goal
3. Count passes in buildup
4. Classify: counter-attack vs buildup play
5. Display results in web interface
6. Show statistics and charts

## 🎯 Success Metrics

By end of hackathon:
- ✅ Videos uploaded and indexed in VAST
- ✅ Can search for "goal with passes"
- ✅ Working pass count analysis
- ✅ Web interface deployed
- ✅ Can demo live

## ❓ Troubleshooting

### Cursor Credits Issue on VM
- Request credits: https://forms.gle/AVta9RRTmfdeUNX26
- Ask on Cosmos Community

### Can't Access VM
- Check team assignment
- Verify you've joined Cosmos Community
- Contact organizers

### Videos Too Large
Use ffmpeg to compress:
```bash
ffmpeg -i input.mp4 -vcodec h264 -crf 28 output.mp4
```

### Need Help
- Cosmos Community: https://community.vastdata.com
- GitHub Issues: https://github.com/somashekhar34/football-goal-analyzer/issues

## 🎬 What's Next

1. **Now (you)**: Upload videos to OneDrive/Google Drive
2. **Now (you)**: Update VIDEOS.md with link
3. **Now (you)**: Share repo with teammate
4. **Later (teammate)**: Clone repo on VM
5. **Later (teammate)**: Upload videos to VAST
6. **Later (teammate)**: Build and deploy app
7. **End of day**: Demo your Football Goal Analyzer!

---

**Everything is ready! Upload your videos and share with your teammate! 🎯⚽**

**GitHub Repo**: https://github.com/somashekhar34/football-goal-analyzer
