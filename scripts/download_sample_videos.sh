#!/bin/bash

###############################################################################
# Download Sample Football Videos
# Downloads free, royalty-free football videos from Pexels/Pixabay
###############################################################################

echo "🎬 Football Video Downloader"
echo "======================================"
echo ""
echo "This script helps you download FREE football videos from:"
echo "  • Pixabay (royalty-free, no attribution)"
echo "  • Pexels (royalty-free, no attribution)"
echo "  • Mixkit (royalty-free, no watermark)"
echo ""

# Create videos directory
mkdir -p ../videos
cd ../videos

echo "📋 Recommended Sources:"
echo ""
echo "1. Pixabay Soccer Goals:"
echo "   https://pixabay.com/videos/search/soccer%20goal/"
echo ""
echo "2. Pexels Soccer Goals:"
echo "   https://www.pexels.com/search/videos/soccer%20goal/"
echo ""
echo "3. Mixkit Football:"
echo "   https://mixkit.co/free-stock-video/football/"
echo ""
echo "4. Videezy Soccer Match:"
echo "   https://www.videezy.com/free-video/soccer-match"
echo ""

echo "📝 Manual Download Instructions:"
echo "======================================"
echo ""
echo "For each site:"
echo "  1. Click the link above (open in browser)"
echo "  2. Browse videos and find ones with:"
echo "     - Goals being scored"
echo "     - Passing sequences visible"
echo "     - Under 1 minute duration"
echo "  3. Click 'Download' → Select size (720p or 1080p)"
echo "  4. Save to: $(pwd)"
echo "  5. Rename to: football_goal_001.mp4, football_goal_002.mp4, etc."
echo ""

echo "✅ What to Look For:"
echo "  - Clear goal moments"
echo "  - Visible passing before goals"
echo "  - Good quality (720p minimum)"
echo "  - Short clips (10-30 seconds ideal)"
echo "  - Total: 5-10 clips for demo"
echo ""

echo "🎯 Recommended Videos to Download:"
echo "======================================"
echo ""
echo "From Pixabay:"
echo "  - Search: 'soccer goal celebration'"
echo "  - Search: 'football players passing'"
echo "  - Search: 'soccer match highlight'"
echo ""
echo "From Pexels:"
echo "  - Search: 'soccer goal'"
echo "  - Search: 'football team playing'"
echo "  - Look for: short clips with action"
echo ""

echo "⏱️  Estimated Time: 10-15 minutes to download 5-10 clips"
echo ""

read -p "Open Pixabay in browser? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Opening Pixabay..."
    open "https://pixabay.com/videos/search/soccer%20goal/" 2>/dev/null || \
    xdg-open "https://pixabay.com/videos/search/soccer%20goal/" 2>/dev/null || \
    echo "Please open: https://pixabay.com/videos/search/soccer%20goal/"
fi

echo ""
read -p "Open Pexels in browser? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Opening Pexels..."
    open "https://www.pexels.com/search/videos/soccer%20goal/" 2>/dev/null || \
    xdg-open "https://www.pexels.com/search/videos/soccer%20goal/" 2>/dev/null || \
    echo "Please open: https://www.pexels.com/search/videos/soccer%20goal/"
fi

echo ""
echo "📦 After downloading:"
echo "  1. Rename videos: football_goal_001.mp4, etc."
echo "  2. Upload to Google Drive:"
echo "     https://drive.google.com/drive/folders/1ec09ZiC1PzC0aOEXg-dxSNEeHMlFnSKj"
echo "  3. Share link with teammate"
echo "  4. On VM, teammate downloads and uploads to VAST"
echo ""
echo "✅ Videos will be saved to: $(pwd)"
echo ""
echo "Happy downloading! ⚽"
