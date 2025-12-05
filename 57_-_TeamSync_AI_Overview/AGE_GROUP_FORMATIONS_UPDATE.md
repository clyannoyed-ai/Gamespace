
# Age-Group Formations & Bench Management Update

## Overview
Updated the TeamSync AI application to properly handle age-group-specific player counts and implement intelligent bench management. The system now automatically places the correct number of players on the field based on age group regulations and moves excess players to the bench.

## Key Changes

### 1. Age-Group Player Count Standards (lib/formations.ts)

**Updated AGE_GROUP_FORMATS** with proper youth soccer standards:

| Age Group | Format | Players on Field | Roster Range |
|-----------|--------|-----------------|--------------|
| U6        | 5v5    | 5 players       | 5-10 players |
| U8        | 7v7    | 7 players       | 7-14 players |
| U10       | 7v7    | 7 players       | 7-14 players |
| U12       | 9v9    | 9 players       | 9-18 players |
| U14       | 11v11  | 11 players      | 11-22 players|
| U16+      | 11v11  | 11 players      | 11-22 players|

**New Helper Functions:**
- `getMaxFieldPlayers(ageGroup)` - Returns the maximum number of players allowed on field
- `getRecommendedRosterSize(ageGroup)` - Returns the min/max recommended roster size

### 2. New U6 (5v5) Formations

Added three age-appropriate formations for U6 teams:

**1-2-1 U6 Basic** (Default)
- 1 Goalkeeper
- 2 Defenders
- 1 Midfielder
- 1 Forward
- Perfect for introducing young players to positions

**1-1-2 U6 Attacking**
- 1 Goalkeeper
- 1 Defender
- 1 Midfielder
- 2 Forwards
- Encourages offensive play and builds confidence

**1-2-1 U6 Diamond**
- 1 Goalkeeper
- 2 Defenders (wide)
- 1 Midfielder (center)
- 1 Forward
- Teaches spacing and shape fundamentals

### 3. Intelligent Formation Application

**Enhanced applyFormation() Function:**
- Validates formation matches age-group requirements
- Automatically places only the age-appropriate number of players on field
- Moves excess players to bench
- Provides clear feedback messages about field vs. bench composition

**Example Behavior:**
```
U6 Team with 8 players + 1-2-1 Formation = 
  → 5 players on field (per 5v5 rules)
  → 3 players on bench
  → Toast: "Formation applied! 5 players on field, 3 on bench for 5v5."
```

### 4. Visual Indicators

**Updated Player Count Badge:**
- Shows "X/Y On Field" (e.g., "5/5 On Field" for U6)
- Green background when at age-appropriate capacity
- Secondary color when under capacity
- Added age-group format badge (e.g., "5v5", "7v7", "9v9", "11v11")

**On-Screen Display:**
```
[4-4-2] [5/11 On Field] [6 On Bench] [11v11] [● LIVE]
  Purple   Green/Gray    Outline    Format  Status
```

### 5. Initial Team Loading

**Enhanced Team Member Pre-population:**
- Automatically places only age-appropriate number on field
- Remaining players start on bench
- Shows info toast: "Team loaded: X players on field, Y on bench (format)"
- Auto-opens formation selector when sufficient players are loaded

### 6. Formation Selector Integration

**Updated to Use Age-Group Context:**
- Now uses `getMaxFieldPlayers(ageGroup)` instead of current player count
- Ensures only age-appropriate formations are shown
- Prevents selection of formations that don't match the age group

### 7. Demo Team: Little Stars U6

**New Seed Data:**
Added "Little Stars U6" team to demonstrate bench management:

**Starting 5 (On Field):**
1. Tommy Chen - Goalkeeper (#1)
2. Lily Smith - Defender (#2)
3. Jake Brown - Defender (#3)
4. Mia Davis - Midfielder (#4)
5. Max Wilson - Forward (#5)

**Bench Players (3):**
6. Emma Taylor - Defender (#6)
7. Lucas Moore - Midfielder (#7)
8. Zoe Anderson - Forward (#8)

## User Experience Flow

### Before Starting a Game/Practice:

1. **Select Team** → System detects age group (e.g., "Little Stars U6")
2. **Team Loads** → 5 players placed on field, 3 on bench
   - Toast: "Team loaded: 5 players on field, 3 on bench (5v5 format)"
3. **Formation Selector** → Shows only U6-appropriate formations (5v5)
4. **Apply Formation** → Players arranged in 1-2-1, 1-1-2, or diamond shape
5. **Visual Confirmation** → Badge shows "5/5 On Field" in green + "5v5" format

### During Game/Practice:

- **Substitution:** Long-press player → Swap with compatible bench player
- **Position Changes:** Drag players to reposition on field
- **Bench Management:** Click players to move between field and bench
- **Real-time Updates:** Player counts update automatically

## Technical Implementation

### Formation Validation
```typescript
const maxFieldPlayers = getMaxFieldPlayers(ageGroup);
if (formation.totalPlayers !== maxFieldPlayers) {
  toast.error(`Formation requires ${formation.totalPlayers} players, 
    but ${ageGroup} teams play ${ageGroupInfo.format} 
    (${maxFieldPlayers} on field)`);
  return;
}
```

### Player Distribution
```typescript
const shouldBeOnField = index < maxFieldPlayers;
// Only first 'maxFieldPlayers' players start on field
// Remaining players automatically assigned to bench
```

### Smart Formation Selector
```typescript
<FormationSelector
  playerCount={getMaxFieldPlayers(ageGroup)}  // Age-based, not current count
  onSelect={applyFormation}
  fieldSize={fieldSize}
/>
```

## Benefits

1. **Compliance:** Ensures teams follow official youth soccer format rules
2. **Clarity:** Coaches immediately see field vs. bench composition
3. **Flexibility:** Easy player rotation with smart substitution system
4. **Education:** Visual feedback helps coaches understand age-group requirements
5. **Automation:** System handles complex age-group logic automatically

## Testing

### To Test Bench Management:

1. Log in with `john@doe.com` / `johndoe123`
2. Navigate to Teams → "Little Stars U6"
3. Click "Start Game" → Select "Little Stars U6" team
4. Observe:
   - ✅ 5 players placed on field automatically
   - ✅ 3 players on bench
   - ✅ Badge shows "5/5 On Field" in green
   - ✅ Format badge shows "5v5"
5. Click "Choose Formation"
   - ✅ Only 5v5 formations shown (3 options)
6. Select "1-2-1 U6 Basic"
   - ✅ Toast: "Formation applied! 5 players on field, 3 on bench for 5v5."
   - ✅ Players arranged in goalkeeper + 2 defenders + 1 midfielder + 1 forward

### Test Other Age Groups:

- **Lightning FC U8** (7v7): 5 players → needs 2 more for full field
- **Thunder Strikers U12** (9v9): 8 players → needs 1 more for full field
- **Phoenix United U16** (11v11): 11 players → full field, no bench

## Files Modified

1. **lib/formations.ts**
   - Updated AGE_GROUP_FORMATS with roster ranges
   - Added getMaxFieldPlayers() helper
   - Added getRecommendedRosterSize() helper
   - Added 3 new U6 (5v5) formations

2. **components/dashboard/interactive-field.tsx**
   - Updated imports to include new helper functions
   - Enhanced applyFormation() with age-group validation
   - Updated initial team loading with bench placement
   - Added age-based visual indicators to badges
   - Updated FormationSelector to use age-group player count

3. **scripts/seed.ts**
   - Added "Little Stars U6" team with 8 players
   - Created realistic player roster with positions and jersey numbers
   - Updated seed summary to show 4 teams

## Summary

The system now intelligently manages player counts based on age group regulations:
- **U6 teams** play 5v5 (5 on field, rest on bench)
- **U8/U10 teams** play 7v7 (7 on field, rest on bench)
- **U12 teams** play 9v9 (9 on field, rest on bench)
- **U14/U16+ teams** play 11v11 (11 on field, rest on bench)

All formations are validated against age-group requirements, and the UI clearly displays field vs. bench composition with visual feedback. Coaches can easily manage substitutions and player rotation while maintaining compliance with youth soccer standards.
