# 🤝 Teammate Handoff Document

## 👋 Hi Teammate!

I've set up the initial project structure and prepared everything for you to deploy on the VAST VM.

## 📋 What's Been Done

✅ Created GitHub repo: https://github.com/somashekhar34/football-goal-analyzer
✅ Set up project structure
✅ Created upload scripts for VAST
✅ Collected/prepared football videos
✅ Documented everything

## 🎯 What You Need to Do

### 1. Get VM Access Working
- Make sure Cursor credits are loaded on VM
- If not, request credits: https://forms.gle/AVta9RRTmfdeUNX26
- Or ask on Cosmos Community

### 2. Clone This Repo on VM
```bash
cd ~
git clone https://github.com/somashekhar34/football-goal-analyzer.git
cd football-goal-analyzer
```

### 3. Download Videos
- Check [VIDEOS.md](../VIDEOS.md) for the OneDrive/Google Drive link
- Download videos to your local machine first
- Then upload to VM (or download directly on VM if possible)

### 4. Upload Videos to VAST
```bash
cd ~/football-goal-analyzer/scripts

# Upload single video
./upload_to_vast.sh ../videos/football_goal_001.mp4 \
  --scenario sports \
  --camera football_cam-1 \
  --prompt "Describe: number of players, passing sequences with pass counts, goals, player formations"

# Or batch upload all
python3 batch_upload_vast.py "../videos/*.mp4" \
  --scenario sports \
  --camera football_cam-1 \
  --tags "goals,passing,highlights" \
  --prompt "Describe: number of players, passing sequences with pass counts, goals, player formations"
```

### 5. Start Building in Cursor
```bash
cd ~/vast-builders-challenge
agent
```

Then ask Cursor:
```
I want to build a football goal analyzer.

First, show me all the sports videos I just uploaded.
Then search for goals and analyze the 10 seconds before each goal to count passes.
Build a simple web app that displays:
- Video clip of the goal
- Number of passes in buildup
- Timestamp
- Description

Deploy it on Kubernetes.
```

## 🎯 Our Project Goal

**Football Goal Analyzer with Passing Sequences**

Features:
1. Search all football videos for goals
2. Analyze 10 seconds before each goal
3. Count number of passes in buildup
4. Classify: counter-attack (<3 passes) vs buildup play (3+ passes)
5. Display results in web interface
6. Show video clips with pass count overlays

## 📁 Files You'll Need

### On VAST VM:
- `scripts/upload_to_vast.sh` - Upload individual videos
- `scripts/batch_upload_vast.py` - Batch upload
- `scripts/vast_api.py` - Python wrapper for VAST API (ready to use)
- `src/goal_analyzer.py` - Main analysis logic

### Documentation:
- `docs/VM_DEPLOYMENT.md` - Step-by-step VM deployment guide
- `docs/API_REFERENCE.md` - VAST API usage examples
- `VIDEOS.md` - Where to get the videos

## 🔑 Key Information

### Team Credentials
On the VM, credentials are in: `/config/team-X.config`

### Important Endpoints:
- Backend: `$INGRESS_URL` (from team config)
- Search API: `/api/v1/videos/search`
- Upload API: `/api/v1/videos/upload`
- Dashboard: Check VM page for Video Search & Summary link

### Custom Prompt for Football:
```
Describe each segment focusing on:
1. Number of visible players
2. Passing sequences with exact pass counts
3. Goal attempts and successful goals
4. Player formations and positioning
5. Type of play (counter-attack, buildup, set piece)
```

## 🐛 Troubleshooting

### If Cursor Won't Start:
```bash
# Check credits
/model

# Request credits
# Go to: https://forms.gle/AVta9RRTmfdeUNX26
```

### If Upload Fails:
```bash
# Run health check in Cursor
check that everything is working

# Check credentials
cat /config/*.config

# Verify backend is reachable
curl $INGRESS_URL/api/v1/config
```

### If Videos Won't Process:
- Wait 2-5 minutes after upload
- Check dashboard for indexing status
- Verify file size < max upload limit (usually 100MB)

## 💡 Development Tips

1. **Start Small**: Get one goal analyzed first, then scale
2. **Use Skills**: Let Cursor handle API calls via skills
3. **Test Searches**: Before building UI, test search queries
4. **Deploy Early**: Get basic version deployed, then iterate

## 📞 Contact

If you get stuck:
- **Cosmos Community**: https://community.vastdata.com
- **GitHub Issues**: https://github.com/somashekhar34/football-goal-analyzer/issues
- **Discord**: [Add your Discord if team uses it]

## ✅ Success Checklist

- [ ] VM access with Cursor credits working
- [ ] Repo cloned on VM
- [ ] Videos downloaded and uploaded to VAST
- [ ] Videos indexed and searchable (check dashboard)
- [ ] First search query working
- [ ] Basic web app deployed
- [ ] Can view results in browser
- [ ] Ready to demo!

## 🎬 Demo Script (End of Day)

When demoing:
1. Show the Video Search UI with our uploaded videos
2. Search: "goal with multiple passes in buildup"
3. Show our custom web app with pass count analysis
4. Explain the classification (counter-attack vs buildup)
5. Show statistics/charts if we built them

## 📝 Notes / Questions

[Add any notes here for your teammate]

---

**Handed off by**: [Your name]
**Date**: [Today's date]
**Status**: Ready for VM deployment
**Estimated time to deploy**: 1-2 hours

Good luck! You've got this! 🚀⚽
