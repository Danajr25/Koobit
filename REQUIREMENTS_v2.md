# 📱 Math Learning App for Kids - Product Requirements Document (PRD)

**Document Version:** 2.1  
**Last Updated:** February 27, 2026  
**Status:** Draft / Client Review

---

## 🎯 1. Project Overview

**App Name (Working Title):** TO BE NAMED

**Concept:** A digital Kumon-style daily mathematics learning application for children. The app focuses on handwriting-based answers, automatic marking, structured daily practice, and motivation through rewards and mini-games.

**Supported Platforms:**
- Android
- iOS

**Frontend Framework:** Flutter  
**Backend:** Supabase  
**Connectivity Requirement:** Online only

---

## 👶 2. Target Users

### 2.1 Primary Users
- Children who are able to hold a pencil firmly and write
- No strict age limitation
- Progression is based on ability, not age

### 2.2 Secondary Users
- Parents or guardians
- Responsible for account management, monitoring progress, and unlocking levels

**Note:** Children of different ages may be placed at the same level depending on skill level.

---

## 🌐 3. Language Support

The application will support the following languages:
- English
- Bahasa Malaysia (BM)

Users can switch languages at any time within the app settings.

---

## 📚 4. Curriculum Structure

The curriculum consists of **54+ progressive levels** (with more planned), grouped into learning phases.

---

### Phase 1: Hand Coordination & Number Recognition (Levels 1-8)

| Level | Topic | Description |
|-------|-------|-------------|
| 1 | Line Tracing | Connect dots using straight lines |
| 2 | Curve Tracing | Connect dots using curved lines |
| 3 | Number Tracing (1–10) | Trace numbers using dotted guides |
| 4 | Number Writing (1–10) | Write numbers without guides |
| 5 | Number Tracing (11–50) | Trace two-digit numbers |
| 6 | Number Writing (11–50) | Write numbers independently |
| 7 | Number Tracing (51–100) | Trace larger numbers |
| 8 | Number Writing (51–100) | Write numbers independently |

---

### Phase 2: Number Sequences (Level 9)

| Level | Topic | Description |
|-------|-------|-------------|
| 9 | Counting & Sequences | Fill in missing numbers |

---

### Phase 3: Addition (Levels 10-13)

| Level | Topic | Description |
|-------|-------|-------------|
| 10 | Addition (+1, +2) | Single-digit addition |
| 11 | Addition (+3 to +5) | Single-digit addition |
| 12 | Addition (+6 to +9) | Single-digit addition |
| 13 | Addition (2-digit) | Two-digit addition |

---

### Phase 4: Subtraction (Levels 14-16)

| Level | Topic | Description |
|-------|-------|-------------|
| 14 | Subtraction (-1 to -5) | Single-digit subtraction |
| 15 | Subtraction (-6 to -9) | Larger single-digit subtraction |
| 16 | Subtraction (2-digit) | Two-digit subtraction |

---

### Phase 5: Multiplication (Levels 17-18)

| Level | Topic | Description |
|-------|-------|-------------|
| 17 | Multiplication (×1 to ×5) | Basic multiplication tables |
| 18 | Multiplication (×6 to ×12) | Advanced multiplication tables |

---

### Phase 6: Division (Levels 19-20)

| Level | Topic | Description |
|-------|-------|-------------|
| 19 | Division (÷1 to ÷5) | Basic division |
| 20 | Division (÷6 to ÷12) | Advanced division |

---

### Phase 7: Fractions (Levels 21-22)

| Level | Topic | Description | Details |
|-------|-------|-------------|---------|
| 21 | Fractions Basics | Recognize and write basic fractions | Improper fractions & mixed numbers. E.g., LCM of (36,72)=12. Introduce improper fractions (8/3), convert improper to mixed number & vice versa |
| 22 | Fraction Operations | Comprehensive fraction work | **Includes:** 1) Decimal fractions (1/10, 1/100, 1/1000), 2) Non-decimal fractions, 3) Fraction to decimal conversion, 4) Decimal to fraction conversion, 5) Fraction and whole numbers, 6) Fraction to percentage (¾ × 100 = 75%), 7) Word problems, 8) Addition/subtraction of fractions, 9) Decimal multiply/divide whole numbers (4.8 × 8, 4.8/8) |

---

### Phase 8: Pre-Algebra - Signed Numbers & Linear Equations (Levels 23-32)

| Level | Topic | Description | Examples |
|-------|-------|-------------|----------|
| 23 | Intro to Variables | Learn method equations, simplifying algebra expressions | a - b = c → a = c + b |
| 24 | Linear Equations (Basic) | One-step equations (each type at least 1 week) | All operations: a+5=8, a-5=8, 5a=8, a/5=8 |
| 25 | Linear Equations (Advanced) | Multi-step equations | Two-step: 3x + 5 = 20 → 3x = 15 → x = 5 |
| 26 | Variables on Both Sides | Move variables to one side | Kumon rule: move x first, numbers later |
| 27 | Linear Equations with Brackets | Distributive Law | Expand brackets, solve. Brackets on both sides |
| 28 | Linear Equations with Fractions | Kumon-style fractions | Clearing fractions using LCM, multiply everything |
| 29 | Negative Coefficients | Handle negative coefficients | Solve normally, handle signs last |
| 30 | Literal Equations | Two or more variables | Standard: 3X + 4Y = 7, solve for X. Advanced has division/multiplication |
| 31 | Simultaneous Equations (2 variables) | Introduction, elimination methods | 1) Substitution: X + Y = 10, X=6, 2) Elimination with coefficients, 3) Elimination by multiplying, 4) With fractions |
| 32 | Simultaneous Equations (3-4 variables) | Extended simultaneous equations | Same as 2 variables but with additional steps |

---

### Phase 8 (Continued): Inequalities & Signed Number Operations (Levels 33-36)

| Level | Topic | Description | Sub-levels |
|-------|-------|-------------|------------|
| 33 | Addition/Subtraction of Positive & Negative Numbers | Signed number basics | Part 1 (G21-30): Basic intro (+3)+(-5). Part 2 (G31-40): Different signs (-8)-(-2). Part 3 (G41-50): Larger sets (-12)+(+15)-(+3). Part 4 (G51-60): Final mastery 20-(+25)+(-5) |
| 34 | Multiplication of +ve and -ve numbers | Signed multiplication | Rules for sign combinations |
| 35 | Division of +ve and -ve numbers | Signed division | Rules for sign combinations |
| 36 | Four Operations of +ve and -ve numbers | Combined operations | 1) Whole numbers, 2) Fractions |
| 37 | Inequalities | Compare values (>, <) | **Level 1:** One-step (add, subtract, multiply, multiply -ve sign flips). **Level 2:** Two-step with negative coefficient. **Level 3:** Variables on both sides. **Level 4:** Compound inequalities & intersection. **Level 5:** Inequalities with fractions |

---

### Phase 9: Square Roots, Cubes & Indices (Levels 38-42)

| Level | Topic | Description | Examples |
|-------|-------|-------------|----------|
| 38 | Introducing Powers of 2 | Square/power basics | x² = x × x, 2² = 2 × 2 = 4. Include table of squares. Brackets (a)², (2)². Addition/subtraction. Variables: (x+1)², (x-2)² |
| 39 | Introducing Square Roots | Square root basics | √9 = 3×3. Include table of square roots. Perfect squares, addition/subtraction, multiplication/division, fraction square roots, non-perfect square roots (√50 = √25×2 = 5√2) |
| 40 | Introduction to Cubic/Power of 3 | Cube basics | Application exactly same as square |
| 41 | Introduction to Cube Root | Cube root basics | Application same as square root |
| 42 | Introduction to Indices | Index laws | a) Power of 0 = 1, b) Multiplication, c) Division, d) Link to roots, e) Power of a power: (2²)³ = 2⁶, f) Negative indices: a⁻¹ = 1/a, g) Fractional indices |

---

### Phase 10: Monomials & Polynomials (Levels 43-45)

| Level | Topic | Description | Examples |
|-------|-------|-------------|----------|
| 43 | Monomials (one term) | Monomial operations | **Step 1:** Addition (x + x = 2x), Subtraction (3x - x = 2x), Multiplying (x × x = x²), Division (x²/x¹ = x). **Step 2:** Combined (x + 2 + 2x = 2 + 3x). **Advanced:** Same variable (3x² × 4x³ = 12x⁵), Multiple variables (2a²b × 5ab³), Negative signs (-2x)(3x²), Dividing monomials, Power of monomial (2x³)² = 4x⁶ |
| 44 | Polynomials (two or more terms) | Polynomial operations | **Basic:** Addition (x² + x), Subtraction (x² - x), Multiplication x(x + 2) = x² + 2x. **Combining mono & poly:** (x-5)(x+2). **Higher level:** 4x² + 3x - 2 + 5x² - x + 7. **Advanced multiplication:** (4x + -3)(5x² + -2x + -1) |
| 45 | Multiplication using Formulas | Three key formulas | 1) (a + b)² 2) (a - b)² 3) a² - b² = (a + b)(a - b). Examples: (x + 2)², (x - 2)², x² - 4 = (x + 2)(x - 2). *May add cube formulas later |

---

### Phase 11: Factorization (Levels 46-53)

| Level | Topic | Description | Examples |
|-------|-------|-------------|----------|
| 46 | Greatest Common Factor | GCF extraction | 1 number: 6 + 9, GCF = 3 → 3(2 + 3). Coefficient: 2a, coefficient is 2. Numbers & variable: 4x + 8 = 4(x + 2). Variables: 6x + 9x = 3x(2 + 3). Multiple variables: 6xy + 9x²y = 3xy(2 + 3x). *First 2 weeks: strengthen single number factoring |
| 47 | Simple Trinomials (a = 1) | ax² + bx + c where a=1 | Find coefficients, find multiplication for c and addition for b. Pre-trinomial for b & c first. Example: x² + 5x + 6, c = 6, find two numbers |
| 48 | Advanced Trinomials (a ≠ 1) | ax² + bx + c where a≠1 | Example: 2x² + 7x + 3, a × c = 6. Solution: (2x + y)(x + z). Addition no -, minus at b, minus at c |
| 49 | Factorization - Difference of Perfect Squares | a² - b² formula | a² - b² = (a - b)(a + b). Example: x² - 9 = (x - 3)(x + 3), x = 3 or x = -3. Start with x² first, then 4x² and so on |
| 50 | Perfect Square Trinomial | Formula application | **Formula 1:** a² + 2ab + b² = (a + b)². **Formula 2:** a² - 2ab + b² = (a - b)². First identify if a² and b² are perfect squares. Example: x² + 6x + 9, x² = x·x, 9 = 3², = (x + 3)² |
| 51 | Sum/Difference of Cubes | Cube formulas | **Formula 1:** a³ + b³ = (a + b)(a² - ab + b²). **Formula 2:** a³ - b³ = (a - b)(a² + ab + b²) |
| 52 | Factorize by Grouping | 4-term polynomials | General: ax + ay + bx + by = (ax + ay) + (bx + by) = a(x + y) + b(x + y) = (a + b)(x + y). Example: x² + xy + 2x + 2y = x(x + y) + 2(x + y) = (x + 2)(x + y) |
| 53 | Factorization & Division (Combined) | Combined techniques | Examples shown in pictures |

---

### Phase 11 (Continued): Quadratic Equations (Levels 54-55)

| Level | Topic | Description |
|-------|-------|-------------|
| 54 | Intro to Quadratic Equations | ax² + bx + c = 0. Same concept as factorization. Find what is x. Start with simple questions |
| 55 | Graph of Quadratic Functions | Graphing parabolas |
| 56 | Max and Min of Quadratic Functions | Finding vertex/extrema |

---

### Phase 12: Pythagorean Theorem (Levels 57-61)

| Level | Topic | Description | Details |
|-------|-------|-------------|---------|
| 57 | Introduction to Pythagorean Theorem | Basic theorem | Show right angle triangle, label a, b, c (hypotenuse = longest). **Formula:** a² + b² = c². Memorize perfect square triangles |
| 58 | Solving with Perfect Squares | Find c (hypotenuse) | a² + b² = c². After mastering c, proceed to find a/b: c² - a²/b² = a²/b², then square root |
| 59 | Non-Perfect Square Problems | Calculate c with calculation | Not memorized but by calculation |
| 60 | Word Problems | Pythagoras word problems | Solving real-world problems |
| 61 | Algebraic Pythagoras | Combined algebra + geometry | Combine both concepts |
| 62 | Introduction to Distance | Distance formula | Formula: √[(x₂-x₁)² + (y₂-y₁)²] |

---

### Future Phases (To Be Updated)

| Phase | Topic | Status |
|-------|-------|--------|
| 13 | Tangents | Planned |
| 14 | Areas | Planned |
| 15 | Volumes | Planned |
| 16 | Velocity & Distance | Planned |
| 17 | Points and Lines | Planned |
| 18 | Circles | Planned |
| 19 | Loci | Planned |
| 20 | Regions | Planned |
| 21 | Trigonometric | Planned |
| 22 | Sine and Cosine Rules | Planned |
| 23 | Area of Triangles | Planned |
| 24 | Arithmetic Sequence | Planned |
| 25 | Integration | Planned |
| 26 | Calculus | Planned |

---

## 📝 5. Daily Worksheet Structure

| Specification | Details |
|---------------|---------|
| Pages per worksheet | 10 pages |
| Questions per page | 10 |
| Total questions | 100 |
| Time limit | 15 minutes |
| Passing score | 95% (95/100) |
| Frequency | One worksheet per day |

---

## ✍️ 6. Handwriting Input & Auto-Marking

### 6.1 Input Method
- Children write directly on the screen using finger or stylus
- Handwriting recognition supports:
  - Numbers (0–9)
  - Operators (+, −, ×, ÷, =)
  - Fractions (stacked format)
  - Variables (x, y)
  - Square root symbols
  - Exponents/indices

### 6.2 Auto-Marking Flow
1. Child completes worksheet within the time limit
2. Submission occurs automatically or manually
3. **First submission score is permanently recorded**
4. System auto-marks all answers
5. Incorrect answers are visually highlighted
6. Child performs corrections
7. Corrections continue until 100% accuracy is achieved
8. Original score and correction attempts are both stored

---

## 📈 7. Progression Rules

### 7.1 Level Advancement
- A score of **95% or higher** is required to unlock the next level
- Failed attempts do not unlock progression
- Child must retry until the passing score is achieved

### 7.2 Level Locking
- All levels are locked by default except Level 1
- Locked levels cannot be accessed by the child
- Parents can manually unlock levels using a password

---

## 📅 8. Calendar & Performance Tracking

### 8.1 Calendar View
- Monthly calendar display
- Daily status indicators:
  - ✅ Completed
  - ❌ Missed
  - 🔄 In progress

### 8.2 Performance Records

**Daily Metrics:**
- Completion date
- Level attempted
- First submission score
- Time taken
- Number of correction attempts
- Final corrected score

**Overall Metrics:**
- Current level
- Total worksheets completed
- Average score
- Consecutive-day streak
- Time spent (daily / weekly / monthly)

---

## 🎁 9. Rewards & Motivation System

### 9.1 Reward Conditions
- Worksheet completed within 15 minutes

### 9.2 Reward Types
- Virtual currency (coins or stars)
- Achievement badges
- Mini-game access tokens

### 9.3 Motivation Features
- Daily streak tracking
- Level-up celebrations
- Achievement animations

---

## 🎮 10. Mini-Games

### 10.1 Game Overview

The app features **3 unique educational games**, each with **10 progressive levels** and an **item collection system** to increase engagement and motivation.

| Game | Theme | Description |
|------|-------|-------------|
| **Math Builder** | City Building | Build a city/kingdom by solving math problems |
| **Number Pet Adventure** | Virtual Pet | Raise a pet that evolves as you progress |
| **Space Math Explorer** | Space Travel | Travel through planets solving math challenges |

---

### 10.2 Game Level System

Each game has 10 levels that unlock based on worksheet progression:

| Game Level | Unlocks When | Difficulty |
|------------|--------------|------------|
| Level 1 | Free (default) | Very Easy |
| Level 2-3 | Complete Worksheet Level 1-2 | Easy |
| Level 4-5 | Complete Worksheet Level 3-4 | Medium |
| Level 6-7 | Complete Worksheet Level 5-6 | Medium-Hard |
| Level 8-9 | Complete Worksheet Level 7-8 | Hard |
| Level 10 | Complete Worksheet Level 9-10 | Expert |

---

### 10.3 Item System

Players earn items by completing game levels. Items can be used strategically in future levels.

| Item | Effect | How to Earn |
|------|--------|-------------|
| 🛡️ Shield | Ignore 1 wrong answer | Complete any game level |
| ⏱️ Time Boost | +10 seconds to timer | Complete levels under par time |
| 💡 Hint | Reveal correct answer once | Complete levels with 100% accuracy |
| ⭐ Double Points | 2x score for entire level | Complete Level 5 or 10 of any game |

**Item Rules:**
- Items are earned only (cannot be purchased)
- Items carry over between sessions (saved to database)
- Items are shared across all games
- Limited use encourages strategic thinking

---

### 10.4 Game Details

#### 🏗️ Game 1: Math Builder

**Concept:** Kids build structures by answering math questions correctly.

| Level | What They Build | Item Earned |
|-------|-----------------|-------------|
| 1-2 | Houses | Building Blocks |
| 3-4 | School | Speed Boost |
| 5-6 | Hospital | Shield |
| 7-8 | Castle | Double Points |
| 9-10 | Spaceship | Unlock new world theme |

---

#### 🐾 Game 2: Number Pet Adventure

**Concept:** Raise a virtual pet that evolves as you solve math problems.

| Level | Pet Evolution | Item Earned |
|-------|---------------|-------------|
| 1-2 | Egg → Baby | Pet Food (cosmetic) |
| 3-4 | Baby → Child | Hint |
| 5-6 | Child → Teen | Shield |
| 7-8 | Teen → Adult | Time Boost |
| 9-10 | Adult → Legendary | New Pet Egg |

---

#### 🚀 Game 3: Space Math Explorer

**Concept:** Travel through planets, each planet represents harder math.

| Level | Planet | Item Earned |
|-------|--------|-------------|
| 1-2 | Moon | Fuel Cells (cosmetic) |
| 3-4 | Mars | Time Boost |
| 5-6 | Jupiter | Hint |
| 7-8 | Saturn | Shield |
| 9-10 | Galaxy X | New Spaceship Skin |

---

### 10.5 Game Access Rules

- Games are accessible after completing at least one worksheet
- All games share the same item inventory
- Kids can replay any unlocked level for practice
- High scores are tracked per level

---

## 🎬 11. Tutorial Videos

- **One tutorial video per level** (54+ total, expanding as curriculum grows)
- Videos explain problem-solving techniques for each level
- Videos are accessible before starting a worksheet

**Content Source:** Provided by client  
**Storage:** Supabase Storage or external CDN

---

## 👨‍👩‍👧 12. Parent Features

### 12.1 Parent Dashboard
- View child progress and level
- Review historical scores
- Monitor streaks and time spent

### 12.2 Level Management
- Manual level unlock (password protected)
- Ability to re-lock levels

### 12.3 Account Management
- Multiple child profiles per account
- Subscription management
- Password management

---

## 💳 13. Subscription Model

### 13.1 Trial
- One-month free trial
- Full feature access during trial

### 13.2 Paid Subscription
- Family plan (multiple children)
- Monthly and yearly billing options
- Pricing to be confirmed

### 13.3 Payment Integration
- Apple App Store In-App Purchases
- Google Play Store In-App Purchases

---

## 🗄️ 14. Data Storage Architecture

| Data Type | Storage |
|-----------|---------|
| User authentication | Supabase Auth |
| Child profiles | Supabase Database |
| Worksheet submissions | Supabase Database |
| Performance data | Supabase Database |
| Tutorial videos | Supabase Storage / CDN |
| Handwriting results | Local processing + DB storage |

**Estimated Data Usage:** ~365KB per child per year

---

## 📱 15. Key Application Screens

1. Splash Screen
2. Login / Registration
3. Child Profile Selection
4. Home Dashboard
5. Level Map (with phase groupings)
6. Worksheet Screen
7. Results Screen
8. Correction Screen
9. Tutorial Video Player
10. Mini-Games Hub
11. Mini-Game Screens
12. Calendar View
13. Performance Reports
14. Parent Dashboard
15. Settings
16. Subscription Screen

---

## ❓ 16. Items Pending Client Confirmation

1. Final application name
2. Subscription pricing
3. Video format and delivery method
4. Branding assets (logo, colors, mascot)
5. Handwriting recognition strictness
6. Streak definition rules
7. Age verification requirements
8. Privacy and child data compliance (COPPA / PDPA)
9. Level numbering finalization (some overlaps in current doc)

---

## 📊 Summary at a Glance

| Item | Specification |
|------|---------------|
| Platforms | Android + iOS |
| Tech Stack | Flutter + Supabase |
| Levels | 54+ (with more planned) |
| Phases | 12 complete + 14 planned |
| Math Range | Tracing → Calculus |
| Questions/Day | 100 (10 pages × 10) |
| Time Limit | 15 minutes |
| Pass Score | 95% |
| Languages | English + Bahasa Malaysia |
| Mini-Games | 3 games × 10 levels each (Math Builder, Number Pet, Space Explorer) + Item System |
| Trial | 1 month free |
| Subscription | Family plan, price TBD |
| Videos | Client provides |
| Questions | Auto-generated by system |

---

## 📅 Document History

| Date | Version | Notes |
|------|---------|-------|
| January 30, 2026 | 1.0 | Initial requirements document |
| February 12, 2026 | 2.0 | Major curriculum expansion: 25 → 54+ levels, added Phases 9-12, detailed fraction/algebra topics, added future phases 13-26 |
| February 27, 2026 | 2.1 | Games overhaul: Replaced 3 basic games with level-based games (Math Builder, Number Pet Adventure, Space Math Explorer) each with 10 levels + item collection system |

---

*Document prepared for client review*
