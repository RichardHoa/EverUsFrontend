# 💖 EverUs (DateMate)

> **"Advanced Mathematics meets Date Night."**  
> EverUs is a beautiful, interactive couple recommendation app that uses linear algebra matching to find, guide, and save your perfect date experiences.

---

## 🌟 What is EverUs?

EverUs helps you and your partner choose, experience, and remember your date nights. Instead of arguing about what to do, EverUs asks for your preferences (across **5 distinct dimensions**) and matches you with one of **6 highly detailed, custom-tailored date journeys**. 

### 🧬 The Core Features
*   **Vector Matching Algorithm**: Uses **Least Squares Projection** (Linear Algebra) to match your preferences (Romance, Adventure, Creativity, Indoor, Energy), budget, and relationship stage with the perfect date.
*   **Interactive Results Dashboard**:
    *   **Spider Graph (Radar Chart)**: Interactive visualization comparing your ideal vector against the date's vector. Hover over nodes to see alignment percentages!
    *   **Live Preference Breakdown**: Real-time slider adjustments with side-by-side bar charts.
    *   **Dynamic List**: Click any of the 6 dates to see how it aligns with your preferences.
*   **Interactive Heart Mascot (`HeartMascot`)**: An animated mascot that stands by you, reacting to your clicks, task completions, and photo uploads with **6 distinct emotional states** (idle, happy, excited, love, thinking, celebrating) and funny/loving comments.
*   **Immersive Date Flows**: Every date features custom themes, unique background music, multi-level check-ins, and photo upload memory books.
*   **Resilient Design**: Saves your completed date memories directly in your browser's Local Storage if no database is connected, or syncs automatically with **Supabase** when configured!

---

## 🎨 The 6 Date Journeys

| Date Journey | Theme | Primary Color | Best Suited For |
| :--- | :--- | :--- | :--- |
| 🍳 **Cooking Show** | Warm & Cozy | Orange (`#E8764F`) | Couples who love cooking, food challenges, and picnics. |
| ⏳ **Time Traveler** | Nostalgic Retro | Brown (`#8B6F47`) | Exploring childhood memories, vintage book/music shops, and writing future letters. |
| 🧩 **Silent Lego** | Cool & Creative | Blue (`#4A90E2`) | Communicating and building creative Lego pieces in complete silence. |
| 🗺️ **Mystery Mapper** | Active Exploration | Green (`#2ECC71`) | Finding secret spots and coordinate-hunting in your city. |
| 👗 **Fashion Flip** | Playful Roleplay | Red (`#E74C3C`) | Stepping outside your comfort zone, picking outfits for each other, and roleplaying new personas. |
| 🫶 **Blind Trust** | Intimate & Sensory | Deep Rose (`#C41E3A`) | Blindfold sensory dining, coordinate guiding, and sharing deep sunset reflections. |

---

## 🚀 How to Download & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/anhthu906/EverUs.git
   ```

2. **Navigate into the folder:**
   ```bash
   cd EverUs
   ```

3. **Install the dependencies:**
   ```bash
   npm install
   ```
   *(Or run `npm i`)*

4. **Start the development server:**
   ```bash
   npm run dev
   ```

Open `http://localhost:5173` in your web browser.

---

## 🛠 Tech Stack Used
*   **Frontend**: React 18 + TypeScript + Vite
*   **Styling**: Tailwind CSS
*   **Graphics**: SVG filters for interactive Radar charts and mascot rendering.
*   **Audio**: HTML5 Audio Player (loops previews seamlessly).
*   **Database**: Supabase Client SDK (PostgreSQL).
