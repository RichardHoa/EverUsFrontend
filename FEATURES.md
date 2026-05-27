# DateMate — Advanced Features & Architecture

## Overview
DateMate is a sophisticated couple recommendation system using Linear Algebra (Least Squares projection) to match user preferences with date activities. The interface features real-time interactivity, animated mascot, dynamic theming, and background music.

---

## Key Features

### 1. **Preference Matcher (Side-by-Side Layout)**
- **Location**: Left panel on matcher view
- **Sliders**: 5 preference dimensions (Romance, Adventure, Creativity, Indoor, Energy) with visual feedback
- **Budget Range**: Dynamic input for VND currency
- **Relationship Stage**: 4-stage selector (Talking, 1–3M, 3–6M, 6M+)
- **Music Toggle**: Enable/disable background activity-specific music
- **Real-time Updates**: Instant visual feedback on slider changes

### 2. **Results Dashboard (Live Right Panel)**
- **Top Match Card**: Gradient header with activity emoji, name, and match percentage in circular gauge
- **Dimension Breakdown**: Side-by-side bar chart showing activity vs user preference alignment
- **Spider Graph (Radar Chart)**:
  - Ideal (dashed yellow reference line)
  - Activity vector (solid gradient-filled polygon)
  - User preference vector (lighter rose polygon)
  - Interactive hover states reveal dimension details
  - Shows percentage alignment per dimension
- **Activity Ranking**: All 6 activities ranked with percentages, budget, and duration
- **Smooth Selection**: Click any activity to instantly swap the analysis

### 3. **Dynamic Color Theming**
Each activity has a unique color palette that applies throughout its flow:
- **Cooking (🍳)**: Warm oranges/golds → `#E8764F` primary
- **Time Traveler (⏳)**: Nostalgic browns → `#8B6F47` primary
- **Silent Lego (🧩)**: Cool blues → `#4A90E2` primary
- **Mystery Mapper (🗺️)**: Nature greens → `#2ECC71` primary
- **Fashion Flip (👗)**: Bold reds → `#E74C3C` primary
- **Blind Trust (🫶)**: Deep rose → `#C41E3A` primary

Theme affects: buttons, progress bars, borders, backgrounds, spider graph fills.

### 4. **Animated Heart Mascot**
- **Emotion States**:
  - `idle`: Neutral expression (○ ○ and ─)
  - `happy`: Smiling (◠ ◠ and ︶)
  - `excited`: Wide eyes (O O and ︶) with pulse animation
  - `love`: Heart eyes (♥ ♥ and ⌣)
  - `thinking`: Confused (?  . and ◡)
  - `celebrating`: Stars eyes (★ ★) with bounce animation

- **Features**:
  - Stick arms and bouncing legs
  - Comment bubble with auto-fade (3-second duration)
  - Smooth scaling and transition animations
  - Responsive to user actions (task completion, photo upload)
  - Context-aware comments (funny/loving based on state)

### 5. **Smooth Transitions & Glow Effects**
- **Page Transitions**: Fade + slide-up animations (0.3–0.5s)
- **Glow Effects**:
  - SVG filter on spider graph polygons
  - Color shift on button hover
  - Shadow expansion on activity card selection
- **State Changes**: 
  - Emotion changes trigger mascot scale/pulse
  - Progress bar fills with duration easing
  - Dimension bars animate in on spider graph
  - Task checkboxes toggle with color change

### 6. **Background Music Integration**
- **Per-Activity Tracks**: Each activity has a Spotify-like preview URL
- **Toggle Button**: Music icon in top-right of matcher and activity flow
- **Auto-Play**: Begins on activity intro, respects toggle state
- **Loop**: Seamless looping during entire date experience
- **Visual Feedback**: Button color changes when enabled (golden yellow)

### 7. **Checkbox Bug Fix**
- **Root Cause**: Previous version didn't isolate task state per level
- **Solution**: Task state now uses `tasks[currentLevel][taskIndex]`
- **Verification**: Toggling task in Level 1 no longer affects Level 2

### 8. **Heart Rain Completion Effect**
- **Location**: Completion screen after date ends
- **Effect**: 30 floating hearts (♥) fall with randomized timing
- **Animation**: `fall` keyframe with Y-translation + rotation + opacity fade
- **Duration**: 2–4 seconds per heart with staggered delays
- **Layer**: Fixed positioning with `pointer-events-none` to avoid blocking

### 9. **Database Integration**
- **Table**: `date_completions` in Supabase
- **Fields**:
  - `activity_key`: identifier (e.g., "cooking")
  - `activity_name`: display name
  - `match_percentage`: 95 on successful completion
  - `user_vector`: [romance, adventure, creativity, indoor, energy] at time
  - `activity_vector`: activity's fixed vector
  - `completed_at`: timestamp of completion

- **Purpose**: Track which dates are popular, enable stats dashboard
- **RLS**: Public read/insert for MVP (auth-ready structure)
- **Indexing**: By activity_key and completed_at for analytics queries

### 10. **Algorithm: Least Squares Projection**
```
User Vector v = [romance, adventure, creativity, indoor, energy]
Activity Vector a_i = [a1, a2, a3, a4, a5]

Score_i = dot(v, a_i) + BudgetBonus + StageBonus

BudgetBonus = {
  80 if cost in [min, max]
  else max(-60, -|cost - midpoint|/midpoint × 60)
}

StageBonus = {
  50 if userStage >= minStage
  -40 otherwise
}

Normalize: pct = 50 + 50 × (score - minScore) / (maxScore - minScore)
```

---

## Component Structure

```
App (main router)
├── PreferenceMatcher (left panel)
│   ├── Slider controls (5)
│   ├── Budget inputs
│   ├── Stage buttons
│   └── Music toggle
├── ResultsDashboard (right panel)
│   ├── Top match card (gradient header)
│   ├── SpiderGraph (radar chart, interactive)
│   ├── Dimension bars
│   ├── Activity ranking list
│   └── HeartMascot (sticky sidebar)
├── ActivityFlow (intro → levels → ending)
│   ├── Intro screen (oath, secret, stats)
│   ├── Level layout (3-column)
│   │   ├── Context + tasks
│   │   ├── Photo upload
│   │   └── Progress bar
│   ├── HeartMascot (sticky right column)
│   └── Music player
└── Completion screen (heart rain + mascot)
```

---

## Styling & Responsive Design

- **Tailwind CSS**: Primary styling framework
- **Custom Animations**: `@layer utilities` in index.css
- **Grid Layout**: 2-column matcher view, 3-column activity view
- **Breakpoints**: Responsive to desktop (≥1024px primary, mobile fallback)
- **Color System**: CSS variables in theme objects, gradient overlays

---

## UX Enhancements

1. **Loading States**: Disabled button + spinner feedback on match computation
2. **Validation**: Photo upload required before level progression
3. **Progress Indication**: Animated progress bar (0–100%) based on level count
4. **Error Handling**: Try/catch on Supabase saves, fallback to completion
5. **Scroll Behavior**: Auto-scroll to top on page transitions, smooth scroll enabled
6. **Accessibility**: Semantic HTML, readable color contrast, focus states on buttons

---

## Performance Optimizations

- **Code Splitting**: React lazy loading not yet implemented (bundle ~323KB)
- **Image Optimization**: SVG graphs, no external images in critical path
- **Audio**: Single audio element with loop, not preloaded
- **Animations**: GPU-accelerated transforms, duration <500ms
- **Database**: Indexed queries, no N+1 issues (save only on completion)

---

## Future Enhancements

- [ ] User authentication (email/password via Supabase Auth)
- [ ] Save date memories as gallery with captions
- [ ] Share completion with partner via link
- [ ] Leaderboard of most popular activities
- [ ] Custom activity creation
- [ ] Rating system post-completion
- [ ] Calendar integration for scheduling dates
- [ ] AI-generated loving comments based on emotion state
