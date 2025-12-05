import requests
from bs4 import BeautifulSoup
import json
import re
from urllib.parse import urljoin
import os

# Fetch the webpage
url = "https://www.soccerdrive.com/posts/3-plus-2-v-3-plus-2-rondo"
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
}

print(f"Fetching drill from: {url}")
response = requests.get(url, headers=headers)
response.raise_for_status()

soup = BeautifulSoup(response.content, 'html.parser')

# Initialize drill data structure
drill_data = {
    "drill_name": None,
    "objective": None,
    "organization": None,
    "player_actions": None,
    "coaching_points": None,
    "duration": None,
    "age_group": None,
    "field_size": None,
    "player_format": None,
    "diagram_image_url": None
}

# Extract title
title_tag = soup.find('h1')
if title_tag:
    drill_data["drill_name"] = title_tag.get_text(strip=True)
    print(f"Found title: {drill_data['drill_name']}")

# Look for the main content area
content_area = soup.find('div', class_=re.compile(r'post|content|article|entry', re.I))
if not content_area:
    content_area = soup

# Extract sections by looking for headings and their content
all_text = content_area.get_text(separator='\n', strip=True)

# Try to find specific sections
sections = {
    'objective': r'(?:Objective|Purpose|Goal)[\s:]+(.+?)(?=\n(?:[A-Z][a-z]+:|$))',
    'organization': r'(?:Organization|Setup|Set[- ]up)[\s:]+(.+?)(?=\n(?:[A-Z][a-z]+:|$))',
    'player_actions': r'(?:Instructions?|Description|How to Play|Player Actions?)[\s:]+(.+?)(?=\n(?:[A-Z][a-z]+:|$))',
    'coaching_points': r'(?:Coaching Points?|Key Points?|Tips?)[\s:]+(.+?)(?=\n(?:[A-Z][a-z]+:|$))',
}

for key, pattern in sections.items():
    match = re.search(pattern, all_text, re.IGNORECASE | re.DOTALL)
    if match:
        drill_data[key] = match.group(1).strip()
        print(f"Found {key}: {drill_data[key][:100]}...")

# Extract metadata from text
duration_match = re.search(r'(?:Duration|Time)[\s:]+(\d+(?:-\d+)?\s*(?:min|minutes?))', all_text, re.IGNORECASE)
if duration_match:
    drill_data["duration"] = duration_match.group(1)
    print(f"Found duration: {drill_data['duration']}")

age_match = re.search(r'(?:Age|Age Group)[\s:]+([U\d\-\s]+|[\d\-]+\s*years?)', all_text, re.IGNORECASE)
if age_match:
    drill_data["age_group"] = age_match.group(1).strip()
    print(f"Found age group: {drill_data['age_group']}")

field_match = re.search(r'(?:Field|Area|Grid)[\s:]+(\d+\s*[x×]\s*\d+\s*(?:yards?|meters?|m)?)', all_text, re.IGNORECASE)
if field_match:
    drill_data["field_size"] = field_match.group(1)
    print(f"Found field size: {drill_data['field_size']}")

# Extract player format from title or text
player_format_match = re.search(r'(\d+\s*\+\s*\d+\s*v\s*\d+\s*\+\s*\d+)', drill_data["drill_name"] or all_text, re.IGNORECASE)
if player_format_match:
    drill_data["player_format"] = player_format_match.group(1)
    print(f"Found player format: {drill_data['player_format']}")

# Find diagram image
image_found = False
for img in soup.find_all('img'):
    img_src = img.get('src', '')
    img_alt = img.get('alt', '').lower()
    
    # Skip small images, icons, logos
    if any(skip in img_src.lower() for skip in ['logo', 'icon', 'avatar', 'profile']):
        continue
    
    # Look for diagram-like images
    if any(keyword in img_alt for keyword in ['diagram', 'drill', 'rondo', 'field']) or \
       any(keyword in img_src.lower() for keyword in ['diagram', 'drill', 'rondo']):
        full_url = urljoin(url, img_src)
        drill_data["diagram_image_url"] = full_url
        print(f"Found diagram image: {full_url}")
        
        # Download the image
        try:
            img_response = requests.get(full_url, headers=headers)
            img_response.raise_for_status()
            
            # Determine extension
            ext = 'jpg'
            content_type = img_response.headers.get('content-type', '')
            if 'png' in content_type:
                ext = 'png'
            elif 'jpeg' in content_type or 'jpg' in content_type:
                ext = 'jpg'
            elif '.png' in img_src.lower():
                ext = 'png'
            
            img_path = f'/home/ubuntu/soccerdrive_rondo_diagram.{ext}'
            with open(img_path, 'wb') as f:
                f.write(img_response.content)
            print(f"Downloaded diagram to: {img_path}")
            image_found = True
            break
        except Exception as e:
            print(f"Failed to download image: {e}")

# If no specific diagram found, try to get the first substantial image
if not image_found:
    print("No specific diagram found, looking for first substantial image...")
    for img in soup.find_all('img'):
        img_src = img.get('src', '')
        if img_src and not any(skip in img_src.lower() for skip in ['logo', 'icon', 'avatar', 'profile', 'button']):
            full_url = urljoin(url, img_src)
            drill_data["diagram_image_url"] = full_url
            print(f"Found image: {full_url}")
            
            try:
                img_response = requests.get(full_url, headers=headers)
                img_response.raise_for_status()
                
                ext = 'jpg'
                content_type = img_response.headers.get('content-type', '')
                if 'png' in content_type:
                    ext = 'png'
                
                img_path = f'/home/ubuntu/soccerdrive_rondo_diagram.{ext}'
                with open(img_path, 'wb') as f:
                    f.write(img_response.content)
                print(f"Downloaded image to: {img_path}")
                image_found = True
                break
            except Exception as e:
                print(f"Failed to download image: {e}")

# If still no specific sections found, try to extract from paragraphs
if not drill_data["organization"] and not drill_data["player_actions"]:
    print("Extracting from paragraphs...")
    paragraphs = content_area.find_all(['p', 'div'], class_=re.compile(r'text|content|description', re.I))
    if not paragraphs:
        paragraphs = content_area.find_all('p')
    
    all_paragraphs = []
    for p in paragraphs:
        text = p.get_text(strip=True)
        if len(text) > 50:  # Substantial content
            all_paragraphs.append(text)
    
    if all_paragraphs:
        # First substantial paragraph is often organization
        if not drill_data["organization"] and len(all_paragraphs) > 0:
            drill_data["organization"] = all_paragraphs[0]
        
        # Second is often instructions
        if not drill_data["player_actions"] and len(all_paragraphs) > 1:
            drill_data["player_actions"] = all_paragraphs[1]
        
        # Look for coaching points
        if not drill_data["coaching_points"]:
            for p in all_paragraphs:
                if any(keyword in p.lower() for keyword in ['coach', 'key point', 'tip', 'focus']):
                    drill_data["coaching_points"] = p
                    break

# Save to JSON
output_path = '/home/ubuntu/soccerdrive_rondo_drill.json'
with open(output_path, 'w', encoding='utf-8') as f:
    json.dump(drill_data, f, indent=2, ensure_ascii=False)

print(f"\n✓ Drill data saved to: {output_path}")
print(f"\nExtracted data summary:")
for key, value in drill_data.items():
    if value:
        preview = str(value)[:100] + "..." if len(str(value)) > 100 else str(value)
        print(f"  {key}: {preview}")
    else:
        print(f"  {key}: [NOT FOUND]")

