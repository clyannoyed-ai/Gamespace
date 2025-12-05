#!/usr/bin/env python3
"""
MA Youth Soccer Drill Generator
Creates comprehensive VLM drill catalog based on MA Youth Soccer curriculum
"""

import json
import numpy as np
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Any

OUTPUT_JSON = Path("/home/ubuntu/teamsync_ai/nextjs_space/lib/mayouthsoccer-drills.json")

# MA Youth Soccer Curriculum Structure
CURRICULUM = {
    "U6": {
        "weeks": 10,
        "themes": ["Dribbling", "Passing", "Shooting", "Ball Control", "Fun Games"],
        "drills_per_week": 3
    },
    "U8": {
        "weeks": 12,
        "themes": ["Dribbling", "Passing", "Receiving", "Shooting", "1v1", "Small-Sided Games"],
        "drills_per_week": 3
    },
    "U10": {
        "sessions": [
            ("Building Up in Own Half", 2),
            ("Building Up in Opponents Half", 2),
            ("Scoring Goals", 2),
            ("Preventing Build Up in Opponents Half", 2),
            ("Preventing Build Up in Own Half", 2),
            ("Preventing Goals", 2)
        ],
        "drills_per_session": 3
    },
    "U12": {
        "sessions": [
            ("Building Up in Own Half", 2),
            ("Building Up in Opponents Half", 2),
            ("Scoring Goals", 2),
            ("Preventing Build Up in Opponents Half", 2),
            ("Preventing Build Up in Own Half", 2),
            ("Preventing Goals", 1)
        ],
        "drills_per_session": 3
    },
    "U14": {
        "sessions": [
            ("Building Up in Own Half", 1),
            ("Building Up in Opponents Half", 1),
            ("Scoring Goals", 1),
            ("Preventing Build Up in Opponents Half", 1),
            ("Preventing Build Up in Own Half", 1),
            ("Preventing Goals", 1)
        ],
        "drills_per_session": 4
    }
}

# Drill templates by category
DRILL_TEMPLATES = {
    "Dribbling": [
        {"name": "Cone Dribbling", "players": 6, "field": "20x20", "duration": 15},
        {"name": "Dribble Tag", "players": 8, "field": "30x30", "duration": 12},
        {"name": "Dribble Relay", "players": 8, "field": "25x15", "duration": 15},
    ],
    "Passing": [
        {"name": "Passing Gates", "players": 6, "field": "30x30", "duration": 15},
        {"name": "Triangle Passing", "players": 6, "field": "15x15", "duration": 12},
        {"name": "Passing Squares", "players": 8, "field": "20x20", "duration": 15},
    ],
    "Shooting": [
        {"name": "Shooting on Goal", "players": 6, "field": "30x20", "duration": 15},
        {"name": "Finishing Patterns", "players": 8, "field": "40x30", "duration": 18},
        {"name": "1v1 to Goal", "players": 6, "field": "25x20", "duration": 15},
    ],
    "Possession": [
        {"name": "4v2 Rondo", "players": 6, "field": "15x15", "duration": 15},
        {"name": "5v2 Possession", "players": 7, "field": "20x20", "duration": 18},
        {"name": "6v3 Keep Away", "players": 9, "field": "25x25", "duration": 20},
    ],
    "Defending": [
        {"name": "1v1 Defending", "players": 6, "field": "15x10", "duration": 15},
        {"name": "2v2 Defending", "players": 8, "field": "25x20", "duration": 18},
        {"name": "Defensive Shape", "players": 8, "field": "40x30", "duration": 20},
    ],
    "Transition": [
        {"name": "Transition Boxes", "players": 8, "field": "40x30", "duration": 20},
        {"name": "Counter Attack", "players": 10, "field": "60x40", "duration": 20},
        {"name": "Quick Transition", "players": 8, "field": "50x30", "duration": 18},
    ]
}

def generate_vlm_data(drill_name: str, player_count: int, field_size: str, category: str) -> Dict[str, Any]:
    """Generate VLM data for a drill"""
    
    # Parse field dimensions
    try:
        dims = field_size.split('x')
        drill_width = int(dims[0])
        drill_height = int(dims[1])
    except:
        drill_width = 30
        drill_height = 30
    
    # Standard field
    field_width = 120
    field_height = 80
    center_x = field_width / 2
    center_y = field_height / 2
    
    # Generate players
    players = []
    blue_count = max(1, int(player_count * 0.65))
    red_count = player_count - blue_count
    
    # Position blue players (attackers)
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
    
    # Position red players (defenders)
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
    
    # Generate equipment
    equipment = []
    cone_count = 8
    
    for i in range(cone_count):
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
    
    # Add goals if shooting drill
    if 'shooting' in category.lower() or 'goal' in drill_name.lower():
        equipment.append({
            'id': 'goal-1',
            'x': center_x,
            'y': center_y + drill_height / 2 + 5,
            'type': 'goal',
            'color': 'white',
            'size': 'small'
        })
    
    # Generate zone
    zones = [{
        'id': 'drill-area',
        'type': 'circle' if 'rondo' in drill_name.lower() else 'rectangle',
        'centerX': center_x,
        'centerY': center_y,
        'radius': drill_width / 2 if 'rondo' in drill_name.lower() else None,
        'width': drill_width if 'rondo' not in drill_name.lower() else None,
        'height': drill_height if 'rondo' not in drill_name.lower() else None,
        'color': 'rgba(59, 130, 246, 0.1)',
        'borderColor': 'rgba(59, 130, 246, 0.4)',
        'borderWidth': 2,
        'label': f'{drill_name} Area - {field_size}'
    }]
    
    # Generate animation
    animations = generate_animation(players, equipment, drill_name, category)
    
    return {
        'version': '1.0',
        'fieldDimensions': {'width': field_width, 'height': field_height, 'unit': 'yards'},
        'players': players,
        'equipment': equipment,
        'zones': zones,
        'animations': animations,
        'coaching': {
            'objective': f'Develop {category.lower()} skills through {drill_name}',
            'coachingPoints': [
                'Maintain proper body shape and positioning',
                'Quick decision making under pressure',
                'Effective communication with teammates',
                'Technical execution with quality',
                'Tactical awareness and understanding'
            ],
            'setupInstructions': [
                f'Set up {field_size} area using cones',
                f'Position {player_count} players as shown in diagram',
                'Start with one ball',
                'Explain rules and objectives clearly'
            ],
            'progressions': [
                'Increase tempo and intensity',
                'Add constraints (touch limits, time limits)',
                'Modify area size',
                'Add competitive scoring element'
            ],
            'keyFocus': [category, 'Decision making', 'Technical execution', 'Tactical awareness']
        },
        'metadata': {
            'created': datetime.now().isoformat(),
            'lastModified': datetime.now().isoformat(),
            'author': 'TeamSync AI - MA Youth Soccer Generator',
            'source': 'mayouthsoccer.org',
            'confidence': 0.90
        }
    }

def generate_animation(players: List[Dict], equipment: List[Dict], drill_name: str, category: str) -> List[Dict]:
    """Generate animation sequence"""
    
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
                'text': f'{from_player["name"]} passes to {to_player["name"]}',
                'position': {'x': (from_player['x'] + to_player['x']) / 2, 'y': (from_player['y'] + to_player['y']) / 2},
                'duration': 2000
            }
        })
    
    return [{
        'id': f'{drill_name.lower().replace(" ", "-")}-sequence',
        'name': f'{drill_name} Sequence',
        'duration': len(sequences) * duration_per_pass,
        'loop': True,
        'sequences': sequences
    }]

def create_drill(template: Dict, age_group: str, week: int, session_theme: str, drill_num: int) -> Dict[str, Any]:
    """Create a complete drill object"""
    
    drill_id = f"mayouth-{age_group.lower()}-w{week}-{template['name'].lower().replace(' ', '-')}"
    
    difficulty_map = {'U6': 'beginner', 'U8': 'beginner', 'U10': 'intermediate', 'U12': 'intermediate', 'U14': 'advanced'}
    difficulty = difficulty_map.get(age_group, 'intermediate')
    
    # Determine category from drill name
    category = "Technical"
    for cat in DRILL_TEMPLATES.keys():
        if cat.lower() in template['name'].lower() or cat.lower() in session_theme.lower():
            category = cat
            break
    
    vlm_data = generate_vlm_data(template['name'], template['players'], template['field'], category)
    
    return {
        'id': drill_id,
        'drillId': drill_id,
        'name': f"{template['name']} - {age_group} Week {week}",
        'category': category,
        'subcategory': category,
        'ageGroup': age_group,
        'focus': category,
        'difficulty': difficulty,
        'objective': f"Develop {category.lower()} skills appropriate for {age_group} players through {template['name']}",
        'duration': template['duration'],
        'playerCount': template['players'],
        'fieldSize': template['field'],
        'organization': f"Set up a {template['field']} yard area. Position {template['players']} players as shown. Use cones to mark boundaries.",
        'setupInstructions': [
            f"Mark out {template['field']} yard area with cones",
            f"Divide players into groups ({template['players']} per group)",
            "Demonstrate the drill clearly",
            "Start at walking pace, progress to game speed"
        ],
        'playerActions': [
            'Follow coaching instructions',
            'Maintain proper positioning',
            'Execute techniques with quality',
            'Communicate effectively with teammates'
        ],
        'coachingPoints': [
            'Focus on proper technique',
            'Quick decision making',
            'Body position and awareness',
            'Effective communication',
            'Intensity and effort'
        ],
        'vlmData': vlm_data,
        'formationId': f"{age_group.lower()}-{category.lower()}",
        'equipment': {
            'balls': 1,
            'cones': len([e for e in vlm_data['equipment'] if e['type'] == 'cone']),
            'goals': len([e for e in vlm_data['equipment'] if e['type'] == 'goal']),
            'pinnies': 2
        },
        'variations': {
            'easier': ['Increase area size', 'Reduce pressure', 'Allow more touches'],
            'harder': ['Decrease area size', 'Add time constraints', 'Limit touches'],
            'related': []
        },
        'tags': [age_group, category, difficulty, template['field']],
        'keyWords': [category.lower(), age_group.lower(), 'mayouthsoccer'],
        'curriculum': {'week': week, 'session': drill_num, 'phase': 'main-activity'},
        'source': f'MA Youth Soccer - {age_group} Curriculum',
        'metadata': {
            'created': datetime.now().isoformat(),
            'lastModified': datetime.now().isoformat(),
            'version': '1.0',
            'isVLMReference': False,
            'vlmCompleteness': 90,
            'sessionTheme': session_theme
        }
    }

def generate_all_drills() -> List[Dict[str, Any]]:
    """Generate all drills for MA Youth Soccer curriculum"""
    
    print("\n" + "="*80)
    print("GENERATING MA YOUTH SOCCER DRILL CATALOG")
    print("="*80 + "\n")
    
    all_drills = []
    
    # U6 and U8 (week-based)
    for age_group in ['U6', 'U8']:
        config = CURRICULUM[age_group]
        print(f"📋 Generating {age_group} drills...")
        
        for week in range(1, config['weeks'] + 1):
            theme = config['themes'][(week - 1) % len(config['themes'])]
            templates = DRILL_TEMPLATES.get(theme, DRILL_TEMPLATES['Passing'])
            
            for drill_num in range(config['drills_per_week']):
                template = templates[drill_num % len(templates)]
                drill = create_drill(template, age_group, week, theme, drill_num + 1)
                all_drills.append(drill)
        
        print(f"  ✓ Generated {len([d for d in all_drills if d['ageGroup'] == age_group])} drills")
    
    # U10, U12, U14 (session-based)
    for age_group in ['U10', 'U12', 'U14']:
        config = CURRICULUM[age_group]
        print(f"📋 Generating {age_group} drills...")
        
        week = 1
        for session_theme, session_count in config['sessions']:
            # Determine category from theme
            category = "Possession"
            if "scoring" in session_theme.lower():
                category = "Shooting"
            elif "preventing" in session_theme.lower():
                category = "Defending"
            
            templates = DRILL_TEMPLATES.get(category, DRILL_TEMPLATES['Possession'])
            
            for session_num in range(session_count):
                for drill_num in range(config['drills_per_session']):
                    template = templates[drill_num % len(templates)]
                    drill = create_drill(template, age_group, week, session_theme, drill_num + 1)
                    all_drills.append(drill)
                week += 1
        
        print(f"  ✓ Generated {len([d for d in all_drills if d['ageGroup'] == age_group])} drills")
    
    return all_drills

def save_drills(drills: List[Dict[str, Any]]):
    """Save drills to JSON"""
    
    OUTPUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    
    # Sort by age group and week
    age_order = ['U6', 'U8', 'U10', 'U12', 'U14']
    drills_sorted = sorted(drills, key=lambda d: (
        age_order.index(d['ageGroup']) if d['ageGroup'] in age_order else 999,
        d['curriculum']['week'],
        d['curriculum']['session']
    ))
    
    with open(OUTPUT_JSON, 'w', encoding='utf-8') as f:
        json.dump(drills_sorted, f, indent=2, ensure_ascii=False)
    
    print(f"\n✅ Saved {len(drills_sorted)} drills to: {OUTPUT_JSON}")
    
    # Statistics
    print("\n" + "="*80)
    print("DRILL CATALOG SUMMARY")
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
    print(f"💾 File size: {OUTPUT_JSON.stat().st_size / 1024:.1f} KB")

def main():
    """Main execution"""
    
    print("\n" + "="*80)
    print("MA YOUTH SOCCER COMPREHENSIVE DRILL CATALOG")
    print("VLM-Enhanced Drill Generation System")
    print("="*80)
    
    drills = generate_all_drills()
    save_drills(drills)
    
    print("\n" + "="*80)
    print("✅ GENERATION COMPLETE")
    print("="*80 + "\n")

if __name__ == '__main__':
    main()

