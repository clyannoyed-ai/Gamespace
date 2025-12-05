#!/usr/bin/env python3
"""
MA Youth Soccer Drill Extraction Script - Fixed SSL
"""

import os
import sys
import json
import re
import requests
from pathlib import Path
from typing import List, Dict, Any, Tuple
from datetime import datetime
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from urllib.parse import urljoin
import warnings

# Disable SSL warnings
warnings.filterwarnings('ignore', message='Unverified HTTPS request')

# Install dependencies
try:
    import fitz
    from PIL import Image
    import numpy as np
    import cv2
except ImportError:
    print("Installing required packages...")
    os.system("pip install -q PyMuPDF Pillow opencv-python-headless numpy requests")
    import fitz
    from PIL import Image
    import numpy as np
    import cv2

# Configuration
BASE_URL = "https://www.mayouthsoccer.org"
OUTPUT_DIR = Path("/home/ubuntu/mayouthsoccer_pdfs")
OUTPUT_JSON = Path("/home/ubuntu/teamsync_ai/nextjs_space/lib/mayouthsoccer-drills.json")

# MA Youth Soccer PDF URLs
PDF_URLS = {
    "U6": [f"/wp-content/uploads/2024/08/U6-Week-{i}.pdf" for i in range(1, 11)],
    "U8": [f"/wp-content/uploads/2024/08/U8-Week-{i}.pdf" for i in range(1, 13)],
    "U10": [
        "/wp-content/uploads/2024/08/U10-Building-Up-in-Own-Half-1.pdf",
        "/wp-content/uploads/2024/08/U10-Building-Up-in-Own-Half-2.pdf",
        "/wp-content/uploads/2024/08/U10-Building-Up-in-Opponents-Half-1.pdf",
        "/wp-content/uploads/2024/08/U10-Building-Up-in-Opponents-Half-2.pdf",
        "/wp-content/uploads/2024/08/U10-Scoring-Goals-1.pdf",
        "/wp-content/uploads/2024/08/U10-Scoring-Goals-2.pdf",
        "/wp-content/uploads/2024/08/U10-Preventing-Build-Up-in-Opponents-Half-1.pdf",
        "/wp-content/uploads/2024/08/U10-Preventing-Build-Up-in-Opponents-Half-2.pdf",
        "/wp-content/uploads/2024/08/U10-Preventing-Build-Up-in-Own-Half-1.pdf",
        "/wp-content/uploads/2024/08/U10-Preventing-Build-Up-in-Own-Half-2.pdf",
        "/wp-content/uploads/2024/08/U10-Preventing-Goals-1.pdf",
        "/wp-content/uploads/2024/08/U10-Preventing-Goals-2.pdf",
    ],
    "U12": [
        "/wp-content/uploads/2024/08/U12-Building-Up-in-Own-Half-1.pdf",
        "/wp-content/uploads/2024/08/U12-Building-Up-in-Own-Half-2.pdf",
        "/wp-content/uploads/2024/08/U12-Building-Up-in-Opponents-Half-1.pdf",
        "/wp-content/uploads/2024/08/U12-Building-Up-in-Opponents-Half-2.pdf",
        "/wp-content/uploads/2024/08/U12-Scoring-Goals-1.pdf",
        "/wp-content/uploads/2024/08/U12-Scoring-Goals-2.pdf",
        "/wp-content/uploads/2024/08/U12-Preventing-Build-Up-in-Opponents-Half-1.pdf",
        "/wp-content/uploads/2024/08/U12-Preventing-Build-Up-in-Opponents-Half-2.pdf",
        "/wp-content/uploads/2024/08/U12-Preventing-Build-Up-in-Own-Half-1.pdf",
        "/wp-content/uploads/2024/08/U12-Preventing-Build-Up-in-Own-Half-2.pdf",
        "/wp-content/uploads/2024/08/U12-Preventing-Goals-1.pdf",
    ],
    "U14": [
        "/wp-content/uploads/2024/08/U14-Building-Up-in-Own-Half-1.pdf",
        "/wp-content/uploads/2024/08/U14-Building-Up-in-Opponents-Half-1.pdf",
        "/wp-content/uploads/2024/08/U14-Scoring-Goals-1.pdf",
        "/wp-content/uploads/2024/08/U14-Preventing-Build-Up-in-Opponents-Half-1.pdf",
        "/wp-content/uploads/2024/08/U14-Preventing-Build-Up-in-Own-Half-1.pdf",
        "/wp-content/uploads/2024/08/U14-Preventing-Goals-1.pdf",
    ],
}

def download_pdf(url: str, age_group: str) -> Tuple[str, Path]:
    """Download a single PDF file"""
    full_url = urljoin(BASE_URL, url)
    filename = Path(url).name
    output_path = OUTPUT_DIR / age_group / filename
    
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    if output_path.exists():
        return filename, output_path
    
    try:
        response = requests.get(full_url, timeout=30, verify=False)
        response.raise_for_status()
        
        with open(output_path, 'wb') as f:
            f.write(response.content)
        
        return filename, output_path
    except Exception as e:
        print(f"  ✗ Failed: {filename} - {str(e)[:50]}")
        return filename, None

def download_all_pdfs() -> Dict[str, List[Path]]:
    """Download all PDFs"""
    print("\n" + "="*80)
    print("DOWNLOADING MA YOUTH SOCCER SESSION PLAN PDFs")
    print("="*80 + "\n")
    
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    downloaded_files = {}
    
    for age_group, urls in PDF_URLS.items():
        print(f"📥 {age_group}: {len(urls)} files...")
        downloaded_files[age_group] = []
        
        with ThreadPoolExecutor(max_workers=3) as executor:
            futures = {executor.submit(download_pdf, url, age_group): url for url in urls}
            
            for future in as_completed(futures):
                filename, path = future.result()
                if path:
                    downloaded_files[age_group].append(path)
                    print(f"  ✓ {filename}")
    
    total = sum(len(files) for files in downloaded_files.values())
    print(f"\n✅ Downloaded {total} PDFs\n")
    
    return downloaded_files

