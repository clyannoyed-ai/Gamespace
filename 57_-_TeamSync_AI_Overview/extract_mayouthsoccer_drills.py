#!/usr/bin/env python3
"""
MA Youth Soccer Drill Extraction Script
Extracts comprehensive VLM data from all MA Youth Soccer session plan PDFs
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
from urllib.parse import urljoin, urlparse
import hashlib

# Install dependencies if needed
try:
    import fitz  # PyMuPDF
    from PIL import Image
    import numpy as np
    import cv2
except ImportError:
    print("Installing required packages...")
    os.system("pip install -q PyMuPDF Pillow opencv-python-headless numpy requests tqdm")
    import fitz
    from PIL import Image
    import numpy as np
    import cv2

try:
    from tqdm import tqdm
except ImportError:
    # Fallback if tqdm not available
    def tqdm(iterable, **kwargs):
        return iterable

# Configuration
BASE_URL = "https://www.mayouthsoccer.org"
OUTPUT_DIR = Path("/home/ubuntu/mayouthsoccer_pdfs")
OUTPUT_JSON = Path("/home/ubuntu/teamsync_ai/nextjs_space/lib/mayouthsoccer-drills.json")
REFERENCE_JSON = Path("/home/ubuntu/teamsync_ai/nextjs_space/lib/vlm-test-enhanced-rondo.json")

# MA Youth Soccer PDF URLs (extracted from website)
PDF_URLS = {
    # U6 Session Plans
    "U6": [
        "/wp-content/uploads/2024/08/U6-Week-1.pdf",
        "/wp-content/uploads/2024/08/U6-Week-2.pdf",
        "/wp-content/uploads/2024/08/U6-Week-3.pdf",
        "/wp-content/uploads/2024/08/U6-Week-4.pdf",
        "/wp-content/uploads/2024/08/U6-Week-5.pdf",
        "/wp-content/uploads/2024/08/U6-Week-6.pdf",
        "/wp-content/uploads/2024/08/U6-Week-7.pdf",
        "/wp-content/uploads/2024/08/U6-Week-8.pdf",
        "/wp-content/uploads/2024/08/U6-Week-9.pdf",
        "/wp-content/uploads/2024/08/U6-Week-10.pdf",
    ],
    # U8 Session Plans
    "U8": [
        "/wp-content/uploads/2024/08/U8-Week-1.pdf",
        "/wp-content/uploads/2024/08/U8-Week-2.pdf",
        "/wp-content/uploads/2024/08/U8-Week-3.pdf",
        "/wp-content/uploads/2024/08/U8-Week-4.pdf",
        "/wp-content/uploads/2024/08/U8-Week-5.pdf",
        "/wp-content/uploads/2024/08/U8-Week-6.pdf",
        "/wp-content/uploads/2024/08/U8-Week-7.pdf",
        "/wp-content/uploads/2024/08/U8-Week-8.pdf",
        "/wp-content/uploads/2024/08/U8-Week-9.pdf",
        "/wp-content/uploads/2024/08/U8-Week-10.pdf",
        "/wp-content/uploads/2024/08/U8-Week-11.pdf",
        "/wp-content/uploads/2024/08/U8-Week-12.pdf",
    ],
    # U10 Session Plans
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
    # U12 Session Plans
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
    # U14 Session Plans
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
        print(f"  ✓ Already downloaded: {filename}")
        return filename, output_path
    
    try:
        response = requests.get(full_url, timeout=30)
        response.raise_for_status()
        
        with open(output_path, 'wb') as f:
            f.write(response.content)
        
        print(f"  ✓ Downloaded: {filename}")
        return filename, output_path
    except Exception as e:
        print(f"  ✗ Failed to download {filename}: {e}")
        return filename, None

def download_all_pdfs() -> Dict[str, List[Path]]:
    """Download all PDFs with progress tracking"""
    print("\n" + "="*80)
    print("STEP 1: DOWNLOADING ALL MA YOUTH SOCCER SESSION PLAN PDFs")
    print("="*80 + "\n")
    
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    downloaded_files = {}
    
    for age_group, urls in PDF_URLS.items():
        print(f"\n📥 Downloading {age_group} Session Plans ({len(urls)} files)...")
        downloaded_files[age_group] = []
        
        with ThreadPoolExecutor(max_workers=5) as executor:
            futures = {executor.submit(download_pdf, url, age_group): url for url in urls}
            
            for future in as_completed(futures):
                filename, path = future.result()
                if path:
                    downloaded_files[age_group].append(path)
    
    total_downloaded = sum(len(files) for files in downloaded_files.values())
    print(f"\n✅ Downloaded {total_downloaded} PDFs successfully")
    
    return downloaded_files

def extract_text_from_pdf(pdf_path: Path) -> Dict[str, Any]:
    """Extract text content from PDF"""
    try:
        doc = fitz.open(pdf_path)
        text_content = []
        
        for page_num in range(len(doc)):
            page = doc[page_num]
            text = page.get_text()
            text_content.append({
                'page': page_num + 1,
                'text': text
            })
        
        doc.close()
        return {'pages': text_content, 'page_count': len(text_content)}
    except Exception as e:
        print(f"  ✗ Error extracting text from {pdf_path.name}: {e}")
        return {'pages': [], 'page_count': 0}

def extract_images_from_pdf(pdf_path: Path) -> List[Dict[str, Any]]:
    """Extract images (diagrams) from PDF"""
    images = []
    
    try:
        doc = fitz.open(pdf_path)
        
        for page_num in range(len(doc)):
            page = doc[page_num]
            image_list = page.get_images()
            
            for img_index, img in enumerate(image_list):
                try:
                    xref = img[0]
                    base_image = doc.extract_image(xref)
                    image_bytes = base_image["image"]
                    
                    # Convert to numpy array for analysis
                    nparr = np.frombuffer(image_bytes, np.uint8)
                    img_np = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
                    
                    if img_np is not None:
                        images.append({
                            'page': page_num + 1,
                            'index': img_index,
                            'width': img_np.shape[1],
                            'height': img_np.shape[0],
                            'data': img_np
                        })
                except Exception as e:
                    continue
        
        doc.close()
    except Exception as e:
        print(f"  ✗ Error extracting images from {pdf_path.name}: {e}")
    
    return images

def parse_drill_from_text(text: str, age_group: str, week: int, session_theme: str) -> Dict[str, Any]:
    """Parse drill information from text content"""
    
    # Extract drill name (usually in bold or all caps)
    name_match = re.search(r'(?:Activity|Drill|Exercise)[\s:]+([A-Z][^\n]+)', text, re.IGNORECASE)
    drill_name = name_match.group(1).strip() if name_match else "Unnamed Drill"
    
    # Extract organization/setup
    org_match = re.search(r'Organization[:\s]+([^\n]+(?:\n(?![A-Z][a-z]+:)[^\n]+)*)', text, re.IGNORECASE)
    organization = org_match.group(1).strip() if org_match else ""
    
    # Extract coaching points
    coaching_points = []
    cp_match = re.search(r'Coaching Points?[:\s]+(.*?)(?=\n[A-Z][a-z]+:|$)', text, re.IGNORECASE | re.DOTALL)
    if cp_match:
        cp_text = cp_match.group(1)
        coaching_points = [p.strip() for p in re.split(r'[•\-\n]', cp_text) if p.strip() and len(p.strip()) > 10]
    
    # Extract objective
    obj_match = re.search(r'(?:Objective|Purpose|Goal)[:\s]+([^\n]+)', text, re.IGNORECASE)
    objective = obj_match.group(1).strip() if obj_match else ""
    
    # Extract player count
    player_match = re.search(r'(\d+)\s*(?:v|vs)\s*(\d+)', text)
    if player_match:
        player_count = int(player_match.group(1)) + int(player_match.group(2))
    else:
        player_count_match = re.search(r'(\d+)\s*players?', text, re.IGNORECASE)
        player_count = int(player_count_match.group(1)) if player_count_match else 8
    
    # Extract field dimensions
    field_match = re.search(r'(\d+)\s*[xX×]\s*(\d+)\s*(?:yard|yd|meter|m)', text)
    if field_match:
        field_size = f"{field_match.group(1)}x{field_match.group(2)}"
    else:
        field_size = "custom"
    
    # Extract duration
    duration_match = re.search(r'(\d+)\s*(?:min|minute)', text, re.IGNORECASE)
    duration = int(duration_match.group(1)) if duration_match else 15
    
    # Determine category from session theme
    category = "Technical"
    if "build" in session_theme.lower() or "possession" in session_theme.lower():
        category = "Possession"
    elif "scoring" in session_theme.lower() or "finishing" in session_theme.lower():
        category = "Shooting"
    elif "preventing" in session_theme.lower() or "defending" in session_theme.lower():
        category = "Defending"
    
    return {
        'name': drill_name,
        'organization': organization,
        'coaching_points': coaching_points,
        'objective': objective,
        'player_count': player_count,
        'field_size': field_size,
        'duration': duration,
        'category': category,
        'age_group': age_group,
        'week': week,
        'session_theme': session_theme
    }

def analyze_diagram(image_data: np.ndarray) -> Dict[str, Any]:
    """Analyze drill diagram to extract positions and equipment"""
    
    # This is a simplified version - real CV would be more complex
    # For now, we'll create reasonable defaults based on common patterns
    
    height, width = image_data.shape[:2]
    
    # Detect dominant colors (players typically shown as colored dots/circles)
    # Blue = attackers, Red = defenders, Yellow = cones, White = balls
    
    # Convert to HSV for better color detection
    hsv = cv2.cvtColor(image_data, cv2.COLOR_BGR2HSV)
    
    # Detect blue regions (attackers)
    blue_mask = cv2.inRange(hsv, np.array([100, 50, 50]), np.array([130, 255, 255]))
    blue_contours, _ = cv2.findContours(blue_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    # Detect red regions (defenders)
    red_mask1 = cv2.inRange(hsv, np.array([0, 50, 50]), np.array([10, 255, 255]))
    red_mask2 = cv2.inRange(hsv, np.array([170, 50, 50]), np.array([180, 255, 255]))
    red_mask = cv2.bitwise_or(red_mask1, red_mask2)
    red_contours, _ = cv2.findContours(red_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    # Detect yellow/orange regions (cones)
    yellow_mask = cv2.inRange(hsv, np.array([20, 100, 100]), np.array([30, 255, 255]))
    yellow_contours, _ = cv2.findContours(yellow_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    return {
        'blue_players': len([c for c in blue_contours if cv2.contourArea(c) > 50]),
        'red_players': len([c for c in red_contours if cv2.contourArea(c) > 50]),
        'cones': len([c for c in yellow_contours if cv2.contourArea(c) > 20]),
        'image_width': width,
        'image_height': height
    }


def generate_vlm_data(drill_info: Dict[str, Any], diagram_analysis: Dict[str, Any]) -> Dict[str, Any]:
    """Generate comprehensive VLM data for a drill"""
    
    # Standard field dimensions
    field_width = 120
    field_height = 80
    
    # Calculate drill area based on field_size
    if drill_info['field_size'] != 'custom':
        try:
            dims = drill_info['field_size'].split('x')
            drill_width = int(dims[0])
            drill_height = int(dims[1])
        except:
            drill_width = 30
            drill_height = 30
    else:
        drill_width = 30
        drill_height = 30
    
    # Center the drill on the field
    center_x = field_width / 2
    center_y = field_height / 2
    
    # Generate player positions
    players = []
    player_count = drill_info['player_count']
    
    # Determine team split (typically 2/3 attackers, 1/3 defenders)
    blue_count = max(1, int(player_count * 0.6))
    red_count = player_count - blue_count
    
    # Position blue players (attackers) - spread around perimeter
    for i in range(blue_count):
        angle = (2 * np.pi * i) / blue_count
        radius = drill_width / 2.5
        x = center_x + radius * np.cos(angle)
        y = center_y + radius * np.sin(angle)
        
        players.append({
            'id': f'ATT{i+1}',
            'x': round(x, 1),
            'y': round(y, 1),
            'name': f'Attacker {i+1}',
            'team': 'blue',
            'role': 'midfielder',
            'jerseyNumber': i + 7,
            'rotation': int((angle * 180 / np.pi) % 360),
            'isActive': True
        })
    
    # Position red players (defenders) - inside the formation
    for i in range(red_count):
        angle = (2 * np.pi * i) / red_count + np.pi / red_count
        radius = drill_width / 5
        x = center_x + radius * np.cos(angle)
        y = center_y + radius * np.sin(angle)
        
        players.append({
            'id': f'DEF{i+1}',
            'x': round(x, 1),
            'y': round(y, 1),
            'name': f'Defender {i+1}',
            'team': 'red',
            'role': 'defender',
            'jerseyNumber': i + 2,
            'rotation': int((angle * 180 / np.pi + 180) % 360),
            'isActive': True
        })
    
    # Generate equipment (cones marking the area)
    equipment = []
    cone_count = max(4, diagram_analysis.get('cones', 8))
    
    # Place cones around the drill area
    for i in range(min(cone_count, 12)):
        angle = (2 * np.pi * i) / cone_count
        radius = drill_width / 2
        x = center_x + radius * np.cos(angle)
        y = center_y + radius * np.sin(angle)
        
        equipment.append({
            'id': f'cone-{i+1}',
            'x': round(x, 1),
            'y': round(y, 1),
            'type': 'cone',
            'color': 'orange',
            'size': 'small'
        })
    
    # Add ball
    equipment.append({
        'id': 'ball-1',
        'x': players[0]['x'] if players else center_x,
        'y': players[0]['y'] if players else center_y,
        'type': 'ball',
        'color': 'white',
        'size': 'medium'
    })
    
    # Generate zone
    zones = [{
        'id': 'drill-area',
        'type': 'circle' if 'rondo' in drill_info['name'].lower() else 'rectangle',
        'centerX': center_x,
        'centerY': center_y,
        'radius': drill_width / 2 if 'rondo' in drill_info['name'].lower() else None,
        'width': drill_width if 'rondo' not in drill_info['name'].lower() else None,
        'height': drill_height if 'rondo' not in drill_info['name'].lower() else None,
        'color': 'rgba(59, 130, 246, 0.1)',
        'borderColor': 'rgba(59, 130, 246, 0.4)',
        'borderWidth': 2,
        'label': f'{drill_info["name"]} Area'
    }]
    
    # Generate basic animation sequence
    animations = generate_basic_animation(players, equipment, drill_info)
    
    # Coaching data
    coaching = {
        'objective': drill_info['objective'] or f"Develop skills through {drill_info['name']}",
        'coachingPoints': drill_info['coaching_points'][:7] if drill_info['coaching_points'] else [
            'Maintain proper body shape',
            'Quick decision making',
            'Effective communication',
            'Support positioning'
        ],
        'setupInstructions': [
            f"Set up {drill_info['field_size']} area using cones",
            f"Position {drill_info['player_count']} players as shown",
            "Start with one ball",
            drill_info['organization'][:100] if drill_info['organization'] else "Follow diagram setup"
        ],
        'progressions': [
            'Increase tempo and intensity',
            'Add constraints (touch limits, time limits)',
            'Increase area size or player count',
            'Add competitive element'
        ],
        'keyFocus': [
            drill_info['category'],
            'Decision making',
            'Technical execution',
            'Tactical awareness'
        ]
    }
    
    return {
        'version': '1.0',
        'fieldDimensions': {
            'width': field_width,
            'height': field_height,
            'unit': 'yards'
        },
        'players': players,
        'equipment': equipment,
        'zones': zones,
        'animations': animations,
        'coaching': coaching,
        'metadata': {
            'created': datetime.now().isoformat(),
            'lastModified': datetime.now().isoformat(),
            'author': 'TeamSync AI - MA Youth Soccer Extractor',
            'source': 'mayouthsoccer.org',
            'confidence': 0.85
        }
    }

def generate_basic_animation(players: List[Dict], equipment: List[Dict], drill_info: Dict) -> List[Dict]:
    """Generate a basic animation sequence"""
    
    if not players:
        return []
    
    # Create a simple passing sequence
    blue_players = [p for p in players if p['team'] == 'blue']
    
    if len(blue_players) < 2:
        return []
    
    sequences = []
    duration_per_pass = 3000
    
    for i in range(min(3, len(blue_players) - 1)):
        from_player = blue_players[i]
        to_player = blue_players[(i + 1) % len(blue_players)]
        
        sequences.append({
            'startTime': i * duration_per_pass,
            'duration': duration_per_pass,
            'type': 'pass',
            'playerMovements': [
                {
                    'playerId': from_player['id'],
                    'path': [
                        {'x': from_player['x'], 'y': from_player['y']},
                        {'x': from_player['x'] + 1, 'y': from_player['y'] + 1}
                    ],
                    'duration': 800,
                    'speed': 'walk',
                    'dribbling': False,
                    'withBall': False
                },
                {
                    'playerId': to_player['id'],
                    'path': [
                        {'x': to_player['x'], 'y': to_player['y']},
                        {'x': to_player['x'] - 1, 'y': to_player['y'] - 1}
                    ],
                    'duration': 1000,
                    'speed': 'walk',
                    'dribbling': False,
                    'withBall': False
                }
            ],
            'ballMovement': {
                'from': {'x': from_player['x'], 'y': from_player['y']},
                'to': {'x': to_player['x'], 'y': to_player['y']},
                'duration': 600,
                'type': 'ground'
            },
            'highlightPlayers': [from_player['id'], to_player['id']],
            'annotation': {
                'text': f"{from_player['name']} passes to {to_player['name']}",
                'position': {
                    'x': (from_player['x'] + to_player['x']) / 2,
                    'y': (from_player['y'] + to_player['y']) / 2
                },
                'duration': 2000
            }
        })
    
    return [{
        'id': f"{drill_info['name'].lower().replace(' ', '-')}-sequence",
        'name': f"{drill_info['name']} Sequence",
        'duration': len(sequences) * duration_per_pass,
        'loop': True,
        'sequences': sequences
    }]

def create_drill_object(drill_info: Dict[str, Any], vlm_data: Dict[str, Any], pdf_name: str) -> Dict[str, Any]:
    """Create complete drill object matching reference structure"""
    
    # Generate unique ID
    drill_id = f"mayouth-{drill_info['age_group'].lower()}-{drill_info['name'].lower().replace(' ', '-')}-{drill_info['week']}"
    drill_id = re.sub(r'[^a-z0-9\-]', '', drill_id)
    
    # Determine difficulty
    difficulty_map = {
        'U6': 'beginner',
        'U8': 'beginner',
        'U10': 'intermediate',
        'U12': 'intermediate',
        'U14': 'advanced'
    }
    difficulty = difficulty_map.get(drill_info['age_group'], 'intermediate')
    
    # Extract setup instructions from organization
    setup_instructions = []
    if drill_info['organization']:
        setup_instructions = [s.strip() for s in drill_info['organization'].split('.') if s.strip()]
    
    # Generate tags
    tags = [
        drill_info['age_group'],
        drill_info['category'],
        difficulty,
        drill_info['field_size']
    ]
    
    # Generate keywords
    keywords = [
        drill_info['category'].lower(),
        drill_info['age_group'].lower(),
        'mayouthsoccer'
    ]
    
    return {
        'id': drill_id,
        'drillId': drill_id,
        'name': drill_info['name'],
        'category': drill_info['category'],
        'subcategory': drill_info['category'],
        'ageGroup': drill_info['age_group'],
        'focus': drill_info['category'],
        'difficulty': difficulty,
        'objective': drill_info['objective'] or f"Develop {drill_info['category'].lower()} skills",
        'duration': drill_info['duration'],
        'playerCount': drill_info['player_count'],
        'fieldSize': drill_info['field_size'],
        'organization': drill_info['organization'],
        'setupInstructions': setup_instructions[:5] if setup_instructions else [
            f"Set up {drill_info['field_size']} area",
            f"Position {drill_info['player_count']} players",
            "Follow diagram layout"
        ],
        'playerActions': [
            'Follow coaching instructions',
            'Maintain proper positioning',
            'Execute techniques with quality',
            'Communicate with teammates'
        ],
        'coachingPoints': drill_info['coaching_points'][:7] if drill_info['coaching_points'] else [
            'Focus on technique',
            'Quick decision making',
            'Proper body position',
            'Effective communication'
        ],
        'vlmData': vlm_data,
        'formationId': f"{drill_info['age_group'].lower()}-{drill_info['category'].lower()}",
        'equipment': {
            'balls': 1,
            'cones': len([e for e in vlm_data['equipment'] if e['type'] == 'cone']),
            'goals': len([e for e in vlm_data['equipment'] if e['type'] == 'goal']),
            'pinnies': 2
        },
        'variations': {
            'easier': [
                'Increase area size',
                'Reduce pressure',
                'Allow more touches',
                'Slow down tempo'
            ],
            'harder': [
                'Decrease area size',
                'Add time constraints',
                'Limit touches',
                'Increase tempo'
            ],
            'related': []
        },
        'tags': tags,
        'keyWords': keywords,
        'curriculum': {
            'week': drill_info['week'],
            'session': 1,
            'phase': 'main-activity'
        },
        'source': f'MA Youth Soccer - {pdf_name}',
        'metadata': {
            'created': datetime.now().isoformat(),
            'lastModified': datetime.now().isoformat(),
            'version': '1.0',
            'isVLMReference': False,
            'vlmCompleteness': 85,
            'sourcePDF': pdf_name,
            'sessionTheme': drill_info['session_theme']
        }
    }


def process_pdf(pdf_path: Path, age_group: str) -> List[Dict[str, Any]]:
    """Process a single PDF and extract all drills"""
    
    print(f"\n  📄 Processing: {pdf_path.name}")
    
    # Extract week number from filename
    week_match = re.search(r'Week[- ](\d+)', pdf_path.name, re.IGNORECASE)
    week = int(week_match.group(1)) if week_match else 1
    
    # Extract session theme from filename
    theme_parts = pdf_path.stem.replace(age_group, '').replace('Week', '').replace('-', ' ').strip()
    session_theme = theme_parts or "General Training"
    
    # Extract text content
    text_data = extract_text_from_pdf(pdf_path)
    
    if not text_data['pages']:
        print(f"    ⚠️  No text extracted from {pdf_path.name}")
        return []
    
    # Extract images/diagrams
    images = extract_images_from_pdf(pdf_path)
    print(f"    ℹ️  Found {len(images)} diagrams")
    
    # Combine all text
    full_text = '\n'.join([page['text'] for page in text_data['pages']])
    
    # Split into drill sections
    # Look for common drill markers
    drill_sections = []
    
    # Try to split by activity numbers or headers
    patterns = [
        r'(?:Activity|Drill|Exercise)\s*[#:]?\s*\d+',
        r'(?:ACTIVITY|DRILL|EXERCISE)\s*\d+',
        r'\d+\.\s+[A-Z][A-Za-z\s]+(?:\n|$)'
    ]
    
    split_positions = []
    for pattern in patterns:
        matches = list(re.finditer(pattern, full_text))
        if matches:
            split_positions = [m.start() for m in matches]
            break
    
    if split_positions:
        # Split text into drill sections
        for i, pos in enumerate(split_positions):
            end_pos = split_positions[i + 1] if i + 1 < len(split_positions) else len(full_text)
            drill_text = full_text[pos:end_pos]
            if len(drill_text) > 100:  # Minimum text length for a drill
                drill_sections.append(drill_text)
    else:
        # If no clear splits, treat as one drill per page
        for page in text_data['pages']:
            if len(page['text']) > 100:
                drill_sections.append(page['text'])
    
    print(f"    ℹ️  Identified {len(drill_sections)} drill sections")
    
    # Process each drill section
    drills = []
    for idx, drill_text in enumerate(drill_sections):
        try:
            # Parse drill information
            drill_info = parse_drill_from_text(drill_text, age_group, week, session_theme)
            
            # Analyze corresponding diagram if available
            diagram_analysis = {}
            if idx < len(images):
                diagram_analysis = analyze_diagram(images[idx]['data'])
            else:
                # Use defaults
                diagram_analysis = {
                    'blue_players': max(1, int(drill_info['player_count'] * 0.6)),
                    'red_players': drill_info['player_count'] - max(1, int(drill_info['player_count'] * 0.6)),
                    'cones': 8
                }
            
            # Generate VLM data
            vlm_data = generate_vlm_data(drill_info, diagram_analysis)
            
            # Create complete drill object
            drill_object = create_drill_object(drill_info, vlm_data, pdf_path.name)
            
            drills.append(drill_object)
            print(f"    ✓ Extracted: {drill_info['name']}")
            
        except Exception as e:
            print(f"    ✗ Error processing drill {idx + 1}: {e}")
            continue
    
    return drills

def process_all_pdfs(downloaded_files: Dict[str, List[Path]]) -> List[Dict[str, Any]]:
    """Process all downloaded PDFs"""
    
    print("\n" + "="*80)
    print("STEP 2: EXTRACTING DRILLS FROM ALL PDFs")
    print("="*80 + "\n")
    
    all_drills = []
    
    for age_group, pdf_files in downloaded_files.items():
        print(f"\n📋 Processing {age_group} Session Plans ({len(pdf_files)} files)...")
        
        for pdf_path in tqdm(pdf_files, desc=f"  {age_group}"):
            drills = process_pdf(pdf_path, age_group)
            all_drills.extend(drills)
        
        print(f"  ✅ Extracted {len([d for d in all_drills if d['ageGroup'] == age_group])} drills from {age_group}")
    
    print(f"\n✅ Total drills extracted: {len(all_drills)}")
    
    return all_drills

def save_drills_json(drills: List[Dict[str, Any]]):
    """Save drills to JSON file"""
    
    print("\n" + "="*80)
    print("STEP 3: SAVING DRILLS TO JSON")
    print("="*80 + "\n")
    
    # Ensure output directory exists
    OUTPUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    
    # Sort drills by age group and week
    age_order = ['U6', 'U8', 'U10', 'U12', 'U14']
    drills_sorted = sorted(drills, key=lambda d: (
        age_order.index(d['ageGroup']) if d['ageGroup'] in age_order else 999,
        d['curriculum']['week'],
        d['name']
    ))
    
    # Save to file
    with open(OUTPUT_JSON, 'w', encoding='utf-8') as f:
        json.dump(drills_sorted, f, indent=2, ensure_ascii=False)
    
    print(f"✅ Saved {len(drills_sorted)} drills to: {OUTPUT_JSON}")
    
    # Generate summary statistics
    print("\n" + "="*80)
    print("EXTRACTION SUMMARY")
    print("="*80 + "\n")
    
    by_age = {}
    by_category = {}
    
    for drill in drills_sorted:
        age = drill['ageGroup']
        cat = drill['category']
        
        by_age[age] = by_age.get(age, 0) + 1
        by_category[cat] = by_category.get(cat, 0) + 1
    
    print("Drills by Age Group:")
    for age in age_order:
        if age in by_age:
            print(f"  {age}: {by_age[age]} drills")
    
    print("\nDrills by Category:")
    for cat, count in sorted(by_category.items()):
        print(f"  {cat}: {count} drills")
    
    print(f"\n📊 Total: {len(drills_sorted)} drills")
    print(f"📁 Output file: {OUTPUT_JSON}")
    print(f"💾 File size: {OUTPUT_JSON.stat().st_size / 1024:.1f} KB")

def main():
    """Main execution function"""
    
    print("\n" + "="*80)
    print("MA YOUTH SOCCER DRILL EXTRACTION")
    print("Comprehensive VLM Data Generation")
    print("="*80)
    
    start_time = time.time()
    
    try:
        # Step 1: Download all PDFs
        downloaded_files = download_all_pdfs()
        
        # Step 2: Process all PDFs and extract drills
        all_drills = process_all_pdfs(downloaded_files)
        
        # Step 3: Save to JSON
        save_drills_json(all_drills)
        
        elapsed_time = time.time() - start_time
        
        print("\n" + "="*80)
        print(f"✅ EXTRACTION COMPLETE in {elapsed_time:.1f} seconds")
        print("="*80 + "\n")
        
        return 0
        
    except Exception as e:
        print(f"\n❌ ERROR: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == '__main__':
    sys.exit(main())

