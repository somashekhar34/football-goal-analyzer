# 🚀 VM Deployment Guide

Complete step-by-step guide for deploying on the VAST VM.

## Prerequisites

✅ VM access with team credentials
✅ Cursor credits loaded
✅ Videos downloaded from shared link

## Step 1: Access the VM

1. Go to the VAST workshop page (link provided during hackathon)
2. Click "Open Desktop"
3. Enter the passcode (provided during event)
4. Wait for VM to load

## Step 2: Clone the Repository

Open terminal on VM:

```bash
cd ~
git clone https://github.com/somashekhar34/football-goal-analyzer.git
cd football-goal-analyzer
```

## Step 3: Download Videos

### Option A: From OneDrive/Google Drive

1. Open browser on VM
2. Go to the link in [VIDEOS.md](../VIDEOS.md)
3. Download all videos
4. Move to `~/football-goal-analyzer/videos/`

### Option B: Transfer from Local Machine

If you have videos locally:
- Use VM's file upload feature
- Or use `scp` if available

## Step 4: Upload Videos to VAST

### Check Upload Scripts

```bash
cd ~/football-goal-analyzer/scripts
ls -la
```

You should see:
- `upload_to_vast.sh` - Single video upload
- `batch_upload_vast.py` - Batch upload
- `vast_api.py` - Python API wrapper

### Upload All Videos

```bash
# Make scripts executable
chmod +x upload_to_vast.sh batch_upload_vast.py

# Batch upload all football videos
python3 batch_upload_vast.py "../videos/football_*.mp4" \
  --scenario sports \
  --camera football_cam-1 \
  --tags "goals,passing,highlights" \
  --prompt "Describe: number of players, passing sequences with pass counts, goals, player formations, type of play"
```

### Wait for Processing

Videos will take 2-5 minutes to process. Monitor progress:

```bash
cd ~/vast-builders-challenge
agent
```

Then in Cursor:
```
Show me the dashboard stats
Are my uploaded videos indexed yet?
```

## Step 5: Verify Videos are Searchable

In Cursor:
```
Search for "goal" in my uploaded videos
Show me all videos with tag "goals"
List my uploaded football videos
```

## Step 6: Build the Football Analyzer

Now build the actual application. In Cursor:

```
I want to build a football goal analyzer web app.

Requirements:
1. Search all my football videos for goals
2. For each goal found, analyze the 10 seconds before it
3. Count the number of passes in the buildup
4. Classify as "counter-attack" (<3 passes) or "buildup play" (3+ passes)
5. Create a web interface that shows:
   - Video clip of the goal
   - Number of passes
   - Play type classification
   - Timestamp and description
6. Display statistics:
   - Total goals found
   - Counter-attacks vs buildup plays
   - Average passes per goal
   - Chart showing distribution

Use the search API to find goals, analyze the Cosmos descriptions to count passes,
and build a simple HTML/JS frontend with a Python backend.

Deploy it on Kubernetes at /app on my team's ingress URL.
```

## Step 7: Iterate and Improve

Once you have a basic version deployed:

### Add Features

```
Add a filter to show only buildup plays with 5+ passes
Add player count detection using YOLO results
Create a timeline view of all goals
```

### Improve Analysis

```
Improve the pass counting logic by:
1. Looking for specific pass-related keywords in Cosmos descriptions
2. Checking YOLO detections for player counts
3. Analyzing temporal sequences of segments
```

### Polish UI

```
Make the interface more visual:
- Add video thumbnails
- Show pass count as badges
- Color-code counter-attacks (red) vs buildup (green)
- Add filters and sorting
```

## Step 8: Prepare for Demo

### Test Everything

```bash
# Check deployment
curl https://your-team-url/app

# Test in browser
# Open: https://your-team-url/app
```

### Create Demo Script

What to show:
1. **Problem**: Hard to analyze football goals and passing patterns manually
2. **Solution**: AI-powered analysis of goals and buildup play
3. **Demo**:
   - Show uploaded videos in VAST UI
   - Run search: "goal with multiple passes"
   - Show our custom app
   - Highlight pass count feature
   - Show statistics
4. **Tech**: VAST + Cosmos + YOLO + our analysis logic

## Common Issues & Solutions

### Issue: Cursor Won't Start

**Solution**:
```bash
# Request credits
# Go to: https://forms.gle/AVta9RRTmfdeUNX26

# Or ask on Cosmos Community
```

### Issue: Upload Fails

**Solution**:
```bash
# Check team config
cat /config/*.config

# Verify backend
curl $INGRESS_URL/api/v1/config

# Check file size
ls -lh videos/
# Files should be < 100MB
```

### Issue: Videos Not Showing in Search

**Solution**:
- Wait 5 minutes for processing
- Check dashboard for indexing status
- Verify uploads succeeded (check object_key)

### Issue: Pass Counting Inaccurate

**Solution**:
- Refine the custom prompt to explicitly ask for pass counts
- Re-ingest videos with better prompt
- Improve parsing logic to extract numbers from descriptions

## Useful Commands

### Check Status
```bash
cd ~/vast-builders-challenge
agent
```

Then:
```
Show dashboard stats
List my videos
Search for "test query"
```

### View Logs
```bash
# If you deployed with Kubernetes
kubectl logs -l app=football-analyzer
```

### Update Code
```bash
cd ~/football-goal-analyzer
git pull
```

## Next Steps After Deployment

1. ✅ Test all features
2. ✅ Get feedback from team
3. ✅ Polish UI/UX
4. ✅ Prepare demo presentation
5. ✅ Document learnings
6. ✅ Submit project (use submission skill)

## Submission

When ready to submit:

```bash
cd ~/vast-builders-challenge
agent
```

```
Help me submit our project

Project details:
- Name: Football Goal Analyzer
- Description: AI-powered analysis of football goals and passing sequences
- Features: Goal detection, pass counting, play type classification
- GitHub: https://github.com/somashekhar34/football-goal-analyzer
```

---

**Good luck! You've got all the tools you need! 🚀⚽**
