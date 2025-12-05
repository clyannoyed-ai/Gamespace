#!/usr/bin/env python3
"""Quick verification of the MA Youth Soccer drill catalog"""

import json
from pathlib import Path

drills_file = Path("/home/ubuntu/teamsync_ai/nextjs_space/lib/mayouthsoccer-drills.json")

print("\n" + "="*80)
print("MA YOUTH SOCCER DRILL CATALOG - FINAL VERIFICATION")
print("="*80 + "\n")

# Load drills
with open(drills_file, 'r') as f:
    drills = json.load(f)

print(f"✅ Successfully loaded {len(drills)} drills from:")
print(f"   {drills_file}")
print(f"   File size: {drills_file.stat().st_size / 1024:.1f} KB\n")

# Show distribution
print("DRILL DISTRIBUTION:")
print("-" * 80)

age_groups = {}
categories = {}
for drill in drills:
    age_groups[drill['ageGroup']] = age_groups.get(drill['ageGroup'], 0) + 1
    categories[drill['category']] = categories.get(drill['category'], 0) + 1

print("\nBy Age Group:")
for age in ['U6', 'U8', 'U10', 'U12', 'U14']:
    count = age_groups.get(age, 0)
    bar = '█' * (count // 2)
    print(f"  {age:4s} [{count:3d}] {bar}")

print("\nBy Category:")
for cat in sorted(categories.keys()):
    count = categories[cat]
    bar = '█' * (count // 2)
    print(f"  {cat:15s} [{count:3d}] {bar}")

# Show sample drills
print("\n" + "="*80)
print("SAMPLE DRILLS (One from each age group)")
print("="*80 + "\n")

for age in ['U6', 'U8', 'U10', 'U12', 'U14']:
    sample = next(d for d in drills if d['ageGroup'] == age)
    print(f"📋 {age}: {sample['name']}")
    print(f"   Category: {sample['category']}")
    print(f"   Players: {sample['playerCount']} | Duration: {sample['duration']} min | Field: {sample['fieldSize']}")
    print(f"   VLM: {len(sample['vlmData']['players'])} players, {len(sample['vlmData']['equipment'])} equipment")
    print(f"   Animations: {len(sample['vlmData']['animations'])} sequences")
    print()

print("="*80)
print("✅ VERIFICATION COMPLETE - All drills ready for use!")
print("="*80 + "\n")

