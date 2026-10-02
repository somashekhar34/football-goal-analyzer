#!/usr/bin/env python3
"""
VAST API Wrapper
Simple Python interface for VAST video search and analysis
Usage: python3 vast_api.py
"""

import os
import requests
from typing import Dict, List, Optional
from pathlib import Path

class VASTClient:
    """Client for VAST Video Search & Summary API"""

    def __init__(self, config_path: Optional[str] = None):
        """Initialize client with team config"""
        self.config = self._load_config(config_path)
        self.backend = self.config['INGRESS_URL']
        self.token = None
        self._authenticate()

    def _load_config(self, config_path: Optional[str] = None) -> Dict[str, str]:
        """Load team configuration"""
        if config_path:
            config_file = Path(config_path)
        else:
            # Look for config in /config/
            config_files = list(Path('/config').glob('*.config'))
            if not config_files:
                raise FileNotFoundError("No team config found in /config/")
            config_file = config_files[0]

        config = {}
        with open(config_file) as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, value = line.split('=', 1)
                    config[key] = value.strip('"').strip("'")

        return config

    def _authenticate(self):
        """Authenticate with VAST backend"""
        url = f"{self.backend}/api/v1/auth/login"
        payload = {
            "username": self.config['USERNAME'],
            "password": self.config['PASSWORD']
        }

        response = requests.post(url, json=payload)
        response.raise_for_status()
        self.token = response.json()['access_token']

    def _headers(self) -> Dict[str, str]:
        """Get authorization headers"""
        return {"Authorization": f"Bearer {self.token}"}

    def search(self, query: str, limit: int = 20, **filters) -> List[Dict]:
        """Search videos for query"""
        url = f"{self.backend}/api/v1/videos/search"
        params = {"query": query, "limit": limit, **filters}

        response = requests.get(url, headers=self._headers(), params=params)
        response.raise_for_status()
        return response.json().get('results', [])

    def find_goals(self) -> List[Dict]:
        """Find all goals"""
        return self.search("goal scored", limit=100)
