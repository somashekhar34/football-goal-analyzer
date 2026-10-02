#!/usr/bin/env python3
"""
VAST Batch Video Upload Script
Uploads multiple videos to your team's VAST S3 bucket through the VSS API
"""

import os
import sys
import json
import time
import glob
import requests
from pathlib import Path
from typing import Dict, List, Optional

class Colors:
    BLUE = '\033[0;34m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    RED = '\033[0;31m'
    NC = '\033[0m'  # No Color

def log_info(msg: str):
    print(f"{Colors.BLUE}ℹ{Colors.NC} {msg}")

def log_success(msg: str):
    print(f"{Colors.GREEN}✓{Colors.NC} {msg}")

def log_warn(msg: str):
    print(f"{Colors.YELLOW}⚠{Colors.NC} {msg}")

def log_error(msg: str):
    print(f"{Colors.RED}✗{Colors.NC} {msg}")

class VASTUploader:
    def __init__(self, config_path: Optional[str] = None):
        self.config = self.load_config(config_path)
        self.backend = self.config['INGRESS_URL']
        self.token = None
        self.max_upload_mb = 100
        self.scenarios = []

    def load_config(self, config_path: Optional[str] = None) -> Dict[str, str]:
        """Load team configuration from /config/*.config"""
        if config_path:
            config_files = [config_path]
        else:
            config_files = list(Path('/config').glob('*.config'))

        if not config_files:
            log_error("No team config found in /config/")
            log_warn("This script must be run on the VAST VM during the hackathon")
            sys.exit(1)

        if len(config_files) > 1:
            log_error("Multiple team configs found. Please specify which one to use.")
            sys.exit(1)

        config_file = config_files[0]
        log_success(f"Found config: {config_file}")

        # Parse bash-style config file
        config = {}
        with open(config_file) as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, value = line.split('=', 1)
                    config[key] = value.strip('"').strip("'")

        required = ['INGRESS_URL', 'USERNAME', 'PASSWORD']
        for req in required:
            if req not in config:
                log_error(f"Missing required config: {req}")
                sys.exit(1)

        return config

    def authenticate(self):
        """Authenticate with VAST backend"""
        log_info("Authenticating with VAST backend...")

        url = f"{self.backend}/api/v1/auth/login"
        payload = {
            "username": self.config['USERNAME'],
            "password": self.config['PASSWORD']
        }

        try:
            response = requests.post(url, json=payload)
            response.raise_for_status()
            data = response.json()
            self.token = data.get('access_token')

            if not self.token:
                log_error("Authentication failed: No token received")
                sys.exit(1)

            log_success("Authenticated successfully")
        except Exception as e:
            log_error(f"Authentication failed: {e}")
            sys.exit(1)

    def get_upload_config(self):
        """Fetch upload limits and available scenarios"""
        log_info("Fetching upload configuration...")

        headers = {"Authorization": f"Bearer {self.token}"}

        try:
            # Get max upload size
            config_resp = requests.get(f"{self.backend}/api/v1/config", headers=headers)
            config_resp.raise_for_status()
            config_data = config_resp.json()
            self.max_upload_mb = config_data.get('max_upload_size_mb', 100)

            # Get available scenarios
            ingest_resp = requests.get(f"{self.backend}/api/v1/metadata/ingest-config", headers=headers)
            ingest_resp.raise_for_status()
            ingest_data = ingest_resp.json()
            self.scenarios = ingest_data.get('analysis_scenarios', [])

            log_success(f"Max upload size: {self.max_upload_mb}MB")
            log_info(f"Available scenarios: {', '.join(self.scenarios)}")
        except Exception as e:
            log_warn(f"Could not fetch config: {e}")

    def upload_video(self, video_path: str, **kwargs) -> Dict:
        """Upload a single video"""
        video_path = Path(video_path)

        if not video_path.exists():
            log_error(f"Video file not found: {video_path}")
            return {"success": False, "error": "File not found"}

        # Check file size
        file_size_mb = video_path.stat().st_size / (1024 * 1024)

        if file_size_mb > self.max_upload_mb:
            log_error(f"File too large: {file_size_mb:.1f}MB (max: {self.max_upload_mb}MB)")
            return {"success": False, "error": "File too large"}

        log_info(f"Uploading: {video_path.name} ({file_size_mb:.1f}MB)")

        # Prepare form data
        files = {'file': open(video_path, 'rb')}
        data = {
            'is_public': str(kwargs.get('is_public', True)).lower()
        }

        # Optional fields
        optional_fields = ['tags', 'camera_id', 'capture_type', 'location',
                          'scenario', 'custom_prompt', 'allowed_users']
        for field in optional_fields:
            if field in kwargs and kwargs[field]:
                data[field] = kwargs[field]

        # Upload
        headers = {"Authorization": f"Bearer {self.token}"}
        url = f"{self.backend}/api/v1/videos/upload"

        try:
            response = requests.post(url, headers=headers, files=files, data=data)
            files['file'].close()
            response.raise_for_status()
            result = response.json()

            if result.get('success'):
                log_success(f"✓ {video_path.name} → {result.get('object_key', 'uploaded')}")
                return result
            else:
                log_error(f"✗ {video_path.name}: {result.get('message', 'Upload failed')}")
                return result
        except Exception as e:
            files['file'].close()
            log_error(f"✗ {video_path.name}: {e}")
            return {"success": False, "error": str(e)}

    def batch_upload(self, video_pattern: str, **kwargs):
        """Upload multiple videos matching a pattern"""
        video_files = glob.glob(video_pattern)

        if not video_files:
            log_error(f"No videos found matching: {video_pattern}")
            return

        log_info(f"Found {len(video_files)} video(s) to upload")
        print()

        results = []
        for i, video_file in enumerate(video_files, 1):
            print(f"[{i}/{len(video_files)}] ", end="")
            result = self.upload_video(video_file, **kwargs)
            results.append({
                'file': video_file,
                'result': result
            })
            time.sleep(1)  # Rate limiting

        # Summary
        print()
        log_info("Upload Summary:")
        successful = sum(1 for r in results if r['result'].get('success'))
        failed = len(results) - successful

        print(f"  Total:      {len(results)}")
        print(f"  Successful: {successful}")
        print(f"  Failed:     {failed}")

        if failed > 0:
            print("\nFailed uploads:")
            for r in results:
                if not r['result'].get('success'):
                    print(f"  - {Path(r['file']).name}: {r['result'].get('error', 'Unknown error')}")

def main():
    import argparse

    parser = argparse.ArgumentParser(
        description='Batch upload videos to VAST team S3 bucket',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  # Upload all MP4 files in current directory
  python3 batch_upload_vast.py "*.mp4" --scenario sports

  # Upload specific videos with metadata
  python3 batch_upload_vast.py "football_*.mp4" --scenario sports --camera football_cam-1 --tags "goals,highlights"

  # Upload with custom prompt
  python3 batch_upload_vast.py "clips/*.mp4" --prompt "Describe passing sequences and goals"

  # Upload as private videos
  python3 batch_upload_vast.py "private/*.mp4" --private
        '''
    )

    parser.add_argument('pattern', help='Video file pattern (e.g., "*.mp4", "videos/*.mov")')
    parser.add_argument('--scenario', default='sports', help='Analysis scenario (default: sports)')
    parser.add_argument('--prompt', help='Custom analysis prompt (overrides scenario)')
    parser.add_argument('--camera', dest='camera_id', help='Camera ID')
    parser.add_argument('--location', help='Location name')
    parser.add_argument('--capture-type', dest='capture_type', default='sports', help='Capture type (default: sports)')
    parser.add_argument('--tags', help='Comma-separated tags')
    parser.add_argument('--private', action='store_true', help='Make videos private')
    parser.add_argument('--config', help='Path to team config file')

    args = parser.parse_args()

    # Build upload kwargs
    upload_kwargs = {
        'is_public': not args.private,
        'capture_type': args.capture_type
    }

    if args.prompt:
        upload_kwargs['custom_prompt'] = args.prompt
    else:
        upload_kwargs['scenario'] = args.scenario

    for field in ['camera_id', 'location', 'tags']:
        value = getattr(args, field, None)
        if value:
            upload_kwargs[field] = value

    # Initialize uploader and run
    uploader = VASTUploader(config_path=args.config)
    uploader.authenticate()
    uploader.get_upload_config()

    print()
    uploader.batch_upload(args.pattern, **upload_kwargs)

if __name__ == '__main__':
    main()
