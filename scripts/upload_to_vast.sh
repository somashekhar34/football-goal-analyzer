#!/bin/bash

###############################################################################
# VAST Video Upload Script
# Uploads videos to your team's VAST S3 bucket through the VSS API
# This will trigger the DataEngine pipeline for automatic processing
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }

###############################################################################
# Step 1: Load Team Configuration
###############################################################################

log_info "Loading team configuration..."

# Find the team config file
TEAM_CONFIGS=($(find /config -maxdepth 1 -type f -name '*.config' 2>/dev/null | sort))

if [ ${#TEAM_CONFIGS[@]} -eq 0 ]; then
    log_error "No team config found in /config/"
    log_warn "This script must be run on the VAST VM during the hackathon"
    exit 1
elif [ ${#TEAM_CONFIGS[@]} -gt 1 ]; then
    log_error "Multiple team configs found. Please specify which one to use."
    exit 1
fi

TEAM_CONFIG="${TEAM_CONFIGS[0]}"
log_success "Found config: $TEAM_CONFIG"

# Load the configuration
set -a
source "$TEAM_CONFIG"
set +a

# Validate required variables
if [ -z "$INGRESS_URL" ] || [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    log_error "Missing required config: INGRESS_URL, USERNAME, or PASSWORD"
    exit 1
fi

BACKEND="$INGRESS_URL"
log_success "Backend URL: $BACKEND"

###############################################################################
# Step 2: Authenticate
###############################################################################

log_info "Authenticating with VAST backend..."

AUTH_RESPONSE=$(curl -s -X POST "$BACKEND/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"}")

TOKEN=$(echo "$AUTH_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('access_token', ''))" 2>/dev/null)

if [ -z "$TOKEN" ]; then
    log_error "Authentication failed"
    echo "$AUTH_RESPONSE"
    exit 1
fi

log_success "Authenticated successfully"

###############################################################################
# Step 3: Get Upload Limits and Options
###############################################################################

log_info "Fetching upload configuration..."

CONFIG_RESPONSE=$(curl -s "$BACKEND/api/v1/config" -H "Authorization: Bearer $TOKEN")
MAX_UPLOAD_MB=$(echo "$CONFIG_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('max_upload_size_mb', 100))" 2>/dev/null)

INGEST_CONFIG=$(curl -s "$BACKEND/api/v1/metadata/ingest-config" -H "Authorization: Bearer $TOKEN")
SCENARIOS=$(echo "$INGEST_CONFIG" | python3 -c "import sys,json; print(', '.join(json.load(sys.stdin).get('analysis_scenarios', [])))" 2>/dev/null)

log_success "Max upload size: ${MAX_UPLOAD_MB}MB"
log_info "Available scenarios: $SCENARIOS"

###############################################################################
# Step 4: Video Selection
###############################################################################

if [ $# -eq 0 ]; then
    log_error "No video file specified"
    echo ""
    echo "Usage: $0 <video_file> [options]"
    echo ""
    echo "Options:"
    echo "  --scenario <name>        Analysis scenario (sports, nhl, general, traffic, etc.)"
    echo "  --prompt <text>          Custom analysis prompt (overrides scenario)"
    echo "  --camera <id>            Camera ID (e.g., football_cam-1)"
    echo "  --location <name>        Location name"
    echo "  --capture-type <type>    Capture type (e.g., sports, traffic)"
    echo "  --tags <tags>            Comma-separated tags"
    echo "  --private                Make video private (default: public)"
    echo ""
    echo "Examples:"
    echo "  $0 football_goals.mp4 --scenario sports --camera football_cam-1"
    echo "  $0 hockey_game.mp4 --scenario nhl --location arena --tags 'goals,highlights'"
    echo "  $0 custom.mp4 --prompt 'Describe passing sequences and goals'"
    exit 1
fi

VIDEO_PATH="$1"
shift

# Check if file exists
if [ ! -f "$VIDEO_PATH" ]; then
    log_error "Video file not found: $VIDEO_PATH"
    exit 1
fi

# Get file info
FILE_NAME=$(basename "$VIDEO_PATH")
FILE_SIZE_MB=$(du -m "$VIDEO_PATH" | cut -f1)

log_success "Video: $FILE_NAME (${FILE_SIZE_MB}MB)"

# Check size
if [ "$FILE_SIZE_MB" -gt "$MAX_UPLOAD_MB" ]; then
    log_error "File too large: ${FILE_SIZE_MB}MB (max: ${MAX_UPLOAD_MB}MB)"
    exit 1
fi

###############################################################################
# Step 5: Parse Arguments
###############################################################################

IS_PUBLIC="true"
SCENARIO="sports"  # Default to sports
CUSTOM_PROMPT=""
CAMERA_ID=""
LOCATION=""
CAPTURE_TYPE="sports"
TAGS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --scenario)
            SCENARIO="$2"
            shift 2
            ;;
        --prompt)
            CUSTOM_PROMPT="$2"
            shift 2
            ;;
        --camera)
            CAMERA_ID="$2"
            shift 2
            ;;
        --location)
            LOCATION="$2"
            shift 2
            ;;
        --capture-type)
            CAPTURE_TYPE="$2"
            shift 2
            ;;
        --tags)
            TAGS="$2"
            shift 2
            ;;
        --private)
            IS_PUBLIC="false"
            shift
            ;;
        *)
            log_warn "Unknown option: $1"
            shift
            ;;
    esac
done

###############################################################################
# Step 6: Confirmation
###############################################################################

echo ""
log_info "Upload Summary:"
echo "  File:         $FILE_NAME"
echo "  Size:         ${FILE_SIZE_MB}MB"
echo "  Visibility:   $([ "$IS_PUBLIC" = "true" ] && echo "Public" || echo "Private")"
if [ -n "$CUSTOM_PROMPT" ]; then
    echo "  Prompt:       $CUSTOM_PROMPT"
else
    echo "  Scenario:     $SCENARIO"
fi
[ -n "$CAMERA_ID" ] && echo "  Camera ID:    $CAMERA_ID"
[ -n "$LOCATION" ] && echo "  Location:     $LOCATION"
[ -n "$CAPTURE_TYPE" ] && echo "  Capture Type: $CAPTURE_TYPE"
[ -n "$TAGS" ] && echo "  Tags:         $TAGS"
echo ""

read -p "Proceed with upload? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_warn "Upload cancelled"
    exit 0
fi

###############################################################################
# Step 7: Upload
###############################################################################

log_info "Uploading video to VAST..."

# Build curl command
CURL_CMD="curl -s -X POST \"$BACKEND/api/v1/videos/upload\" \
  -H \"Authorization: Bearer $TOKEN\" \
  -F \"file=@${VIDEO_PATH}\" \
  -F \"is_public=${IS_PUBLIC}\""

[ -n "$TAGS" ] && CURL_CMD="$CURL_CMD -F \"tags=${TAGS}\""
[ -n "$CAMERA_ID" ] && CURL_CMD="$CURL_CMD -F \"camera_id=${CAMERA_ID}\""
[ -n "$CAPTURE_TYPE" ] && CURL_CMD="$CURL_CMD -F \"capture_type=${CAPTURE_TYPE}\""
[ -n "$LOCATION" ] && CURL_CMD="$CURL_CMD -F \"location=${LOCATION}\""

if [ -n "$CUSTOM_PROMPT" ]; then
    CURL_CMD="$CURL_CMD -F \"custom_prompt=${CUSTOM_PROMPT}\""
else
    CURL_CMD="$CURL_CMD -F \"scenario=${SCENARIO}\""
fi

# Execute upload
UPLOAD_RESPONSE=$(eval "$CURL_CMD")

# Check response
SUCCESS=$(echo "$UPLOAD_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('success', False))" 2>/dev/null)
OBJECT_KEY=$(echo "$UPLOAD_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('object_key', ''))" 2>/dev/null)
MESSAGE=$(echo "$UPLOAD_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('message', ''))" 2>/dev/null)

if [ "$SUCCESS" = "True" ]; then
    log_success "Upload successful!"
    log_success "Object key: $OBJECT_KEY"
    log_info "$MESSAGE"
    echo ""
    log_info "Processing takes a few minutes. The video will be:"
    echo "  1. Segmented into clips"
    echo "  2. Analyzed by Cosmos and YOLO"
    echo "  3. Embedded and indexed for search"
    echo ""
    log_info "Check status at: $BACKEND"
else
    log_error "Upload failed"
    echo "$UPLOAD_RESPONSE"
    exit 1
fi

###############################################################################
# Step 8: Monitor (Optional)
###############################################################################

echo ""
read -p "Monitor indexing progress? (y/N) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Monitoring indexing progress (Ctrl+C to stop)..."
    echo ""

    PREV_COUNT=0
    for i in {1..30}; do
        sleep 10

        STATS=$(curl -s "$BACKEND/api/v1/dashboard/stats?scope=mine" \
            -H "Authorization: Bearer $TOKEN")

        TOTAL_SEGMENTS=$(echo "$STATS" | python3 -c "import sys,json; print(json.load(sys.stdin).get('total_segments', 0))" 2>/dev/null)

        if [ "$TOTAL_SEGMENTS" -gt "$PREV_COUNT" ]; then
            log_success "Indexed segments: $TOTAL_SEGMENTS (processing...)"
            PREV_COUNT=$TOTAL_SEGMENTS
        else
            echo -n "."
        fi
    done

    echo ""
    log_success "Monitoring complete. Check the dashboard for full details."
fi

log_success "Done! Your video is being processed by the VAST pipeline."
