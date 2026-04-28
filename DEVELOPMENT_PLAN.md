# 🚀 Math Learning App - Development Plan

**Version:** 1.0  
**Created:** February 12, 2026  
**Based on:** REQUIREMENTS_v2.md

---

## 📋 Table of Contents

1. [Development Phases Overview](#-1-development-phases-overview)
2. [Technical Architecture](#-2-technical-architecture)
3. [Database Schema](#-3-database-schema)
4. [Phase 1: Foundation & Authentication](#-phase-1-foundation--authentication-weeks-1-3)
5. [Phase 2: Core Worksheet System](#-phase-2-core-worksheet-system-weeks-4-7)
6. [Phase 3: Handwriting Recognition](#-phase-3-handwriting-recognition-weeks-8-10)
7. [Phase 4: Progress & Gamification](#-phase-4-progress--gamification-weeks-11-13)
8. [Phase 5: Parent Dashboard & Settings](#-phase-5-parent-dashboard--settings-weeks-14-15)
9. [Phase 6: Mini-Games](#-phase-6-mini-games-weeks-16-18)
10. [Phase 7: Subscription & Payments](#-phase-7-subscription--payments-weeks-19-20)
11. [Phase 8: Testing & Polish](#-phase-8-testing--polish-weeks-21-24)
12. [Phase 9: Deployment](#-phase-9-deployment-weeks-25-26)
13. [Risk Assessment](#-risk-assessment)
14. [Tech Stack Details](#-tech-stack-details)

---

## 📊 1. Development Phases Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        DEVELOPMENT TIMELINE (26 WEEKS)                       │
├─────────────────────────────────────────────────────────────────────────────┤
│ Phase 1: Foundation & Auth        ████████░░░░░░░░░░░░░░░░░░  Weeks 1-3     │
│ Phase 2: Core Worksheet System    ░░░░░░░░████████████░░░░░░  Weeks 4-7     │
│ Phase 3: Handwriting Recognition  ░░░░░░░░░░░░░░░░████████░░  Weeks 8-10    │
│ Phase 4: Progress & Gamification  ░░░░░░░░░░░░░░░░░░░░████░░  Weeks 11-13   │
│ Phase 5: Parent Dashboard         ░░░░░░░░░░░░░░░░░░░░░░████  Weeks 14-15   │
│ Phase 6: Mini-Games               ░░░░░░░░░░░░░░░░░░░░░░░░██  Weeks 16-18   │
│ Phase 7: Subscription & Payments  ░░░░░░░░░░░░░░░░░░░░░░░░░█  Weeks 19-20   │
│ Phase 8: Testing & Polish         ░░░░░░░░░░░░░░░░░░░░░░░░░░  Weeks 21-24   │
│ Phase 9: Deployment               ░░░░░░░░░░░░░░░░░░░░░░░░░░  Weeks 25-26   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Summary Table

| Phase | Description | Duration | Key Deliverables |
|-------|-------------|----------|------------------|
| 1 | Foundation & Auth | 3 weeks | Project setup, Supabase, login/register, child profiles |
| 2 | Core Worksheet | 4 weeks | Question engine, worksheet UI, timer, submission flow |
| 3 | Handwriting | 3 weeks | Drawing canvas, ML recognition, answer validation |
| 4 | Gamification | 3 weeks | Levels, rewards, calendar, performance tracking |
| 5 | Parent Dashboard | 2 weeks | Reports, level unlock, settings |
| 6 | Mini-Games | 3 weeks | 3 games (Flappy, Balloon, Platformer) |
| 7 | Payments | 2 weeks | RevenueCat, subscriptions, trial logic |
| 8 | Testing | 4 weeks | QA, bug fixes, performance optimization |
| 9 | Deployment | 2 weeks | Store submissions, launch |

**Total Estimated Duration:** 26 weeks (~6 months)

---

## 🏗️ 2. Technical Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              SYSTEM ARCHITECTURE                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────┐     ┌─────────────┐     ┌─────────────────────────────────────┐
│   ANDROID   │     │     iOS     │     │           FLUTTER APP               │
│    App      │     │    App      │     │  ┌─────────────────────────────┐    │
└──────┬──────┘     └──────┬──────┘     │  │     Presentation Layer      │    │
       │                   │            │  │  - Screens/Pages            │    │
       └─────────┬─────────┘            │  │  - Widgets                  │    │
                 │                      │  │  - State Management (Bloc)  │    │
                 ▼                      │  └─────────────────────────────┘    │
┌─────────────────────────────────┐     │  ┌─────────────────────────────┐    │
│        FLUTTER FRAMEWORK        │     │  │      Business Logic         │    │
│  - Single Codebase              │     │  │  - Question Generator       │    │
│  - Material/Cupertino UI        │     │  │  - Scoring Engine           │    │
│  - Platform Channels            │     │  │  - Level Progression        │    │
└─────────────────────────────────┘     │  └─────────────────────────────┘    │
                 │                      │  ┌─────────────────────────────┐    │
                 ▼                      │  │       Data Layer            │    │
┌─────────────────────────────────┐     │  │  - Repositories             │    │
│      EXTERNAL SERVICES          │     │  │  - Models                   │    │
│                                 │     │  │  - Supabase Client          │    │
│  ┌───────────┐  ┌───────────┐   │     │  └─────────────────────────────┘    │
│  │ Supabase  │  │ RevenueCat│   │     └─────────────────────────────────────┘
│  │           │  │           │   │
│  │ - Auth    │  │ - IAP     │   │     ┌─────────────────────────────────────┐
│  │ - DB      │  │ - Subs    │   │     │         ML/HANDWRITING              │
│  │ - Storage │  │           │   │     │  ┌─────────────────────────────┐    │
│  └───────────┘  └───────────┘   │     │  │   On-Device ML Kit          │    │
│                                 │     │  │   - Digital Ink Recognition │    │
│  ┌───────────┐                  │     │  │   - Custom TFLite Model     │    │
│  │ Firebase  │                  │     │  └─────────────────────────────┘    │
│  │ ML Kit    │                  │     └─────────────────────────────────────┘
│  └───────────┘                  │
└─────────────────────────────────┘
```

### Folder Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── themes/
│       ├── app_theme.dart
│       └── app_colors.dart
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── level_config.dart
│   │   └── strings/
│   │       ├── en.dart
│   │       └── ms.dart
│   ├── errors/
│   │   └── failures.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   └── helpers.dart
│   └── services/
│       ├── supabase_service.dart
│       ├── auth_service.dart
│       └── storage_service.dart
│
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── child_model.dart
│   │   ├── worksheet_model.dart
│   │   ├── question_model.dart
│   │   ├── submission_model.dart
│   │   ├── level_model.dart
│   │   └── reward_model.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── child_repository.dart
│   │   ├── worksheet_repository.dart
│   │   ├── progress_repository.dart
│   │   └── subscription_repository.dart
│   └── datasources/
│       ├── remote/
│       │   └── supabase_datasource.dart
│       └── local/
│           └── shared_prefs_datasource.dart
│
├── domain/
│   ├── entities/
│   ├── usecases/
│   │   ├── auth/
│   │   ├── worksheet/
│   │   └── progress/
│   └── repositories/
│
├── presentation/
│   ├── blocs/
│   │   ├── auth/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   ├── worksheet/
│   │   ├── progress/
│   │   └── settings/
│   ├── screens/
│   │   ├── splash/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   ├── child_selection/
│   │   ├── level_map/
│   │   ├── worksheet/
│   │   │   ├── worksheet_screen.dart
│   │   │   ├── question_page.dart
│   │   │   └── widgets/
│   │   ├── results/
│   │   ├── correction/
│   │   ├── tutorial/
│   │   ├── games/
│   │   │   ├── games_hub_screen.dart
│   │   │   ├── flappy_bird/
│   │   │   ├── balloon_pop/
│   │   │   └── platformer/
│   │   ├── calendar/
│   │   ├── performance/
│   │   ├── parent_dashboard/
│   │   ├── settings/
│   │   └── subscription/
│   └── widgets/
│       ├── common/
│       ├── drawing_canvas.dart
│       ├── timer_widget.dart
│       └── question_widgets/
│
├── features/
│   ├── handwriting/
│   │   ├── drawing_canvas.dart
│   │   ├── stroke_processor.dart
│   │   └── recognition_service.dart
│   └── question_generator/
│       ├── question_generator.dart
│       ├── generators/
│       │   ├── tracing_generator.dart
│       │   ├── arithmetic_generator.dart
│       │   ├── fraction_generator.dart
│       │   ├── algebra_generator.dart
│       │   └── geometry_generator.dart
│       └── validators/
│           └── answer_validator.dart
│
└── games/
    ├── flappy_bird/
    ├── balloon_pop/
    └── platformer/
```

---

## 🗄️ 3. Database Schema

### Supabase Tables

```sql
-- =====================================================
-- 1. USERS (Parents) - Managed by Supabase Auth
-- =====================================================
-- Uses built-in auth.users table
-- Additional profile data below

CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    display_name TEXT,
    parent_password TEXT NOT NULL, -- Hashed, for unlocking levels
    preferred_language TEXT DEFAULT 'en' CHECK (preferred_language IN ('en', 'ms')),
    subscription_status TEXT DEFAULT 'trial' CHECK (subscription_status IN ('trial', 'active', 'expired', 'cancelled')),
    trial_start_date TIMESTAMPTZ DEFAULT NOW(),
    trial_end_date TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '30 days'),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 2. CHILDREN (Child profiles under parent account)
-- =====================================================
CREATE TABLE public.children (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    avatar_url TEXT,
    current_level INTEGER DEFAULT 1,
    total_stars INTEGER DEFAULT 0,
    total_badges INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 3. LEVELS (Curriculum definition)
-- =====================================================
CREATE TABLE public.levels (
    id INTEGER PRIMARY KEY,
    phase INTEGER NOT NULL,
    phase_name TEXT NOT NULL,
    topic TEXT NOT NULL,
    description TEXT,
    tutorial_video_url TEXT,
    question_type TEXT NOT NULL, -- 'tracing', 'number_writing', 'arithmetic', 'fraction', 'algebra', 'geometry'
    difficulty INTEGER DEFAULT 1,
    config JSONB, -- Level-specific configuration for question generation
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 4. CHILD LEVEL PROGRESS (Which levels unlocked/completed)
-- =====================================================
CREATE TABLE public.child_level_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id UUID NOT NULL REFERENCES public.children(id) ON DELETE CASCADE,
    level_id INTEGER NOT NULL REFERENCES public.levels(id),
    status TEXT DEFAULT 'locked' CHECK (status IN ('locked', 'unlocked', 'in_progress', 'completed')),
    best_score INTEGER DEFAULT 0,
    attempts INTEGER DEFAULT 0,
    unlocked_by TEXT CHECK (unlocked_by IN ('progression', 'parent')),
    unlocked_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(child_id, level_id)
);

-- =====================================================
-- 5. WORKSHEETS (Daily worksheet instances)
-- =====================================================
CREATE TABLE public.worksheets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id UUID NOT NULL REFERENCES public.children(id) ON DELETE CASCADE,
    level_id INTEGER NOT NULL REFERENCES public.levels(id),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    status TEXT DEFAULT 'not_started' CHECK (status IN ('not_started', 'in_progress', 'submitted', 'correcting', 'completed')),
    questions JSONB NOT NULL, -- Array of generated questions with answers
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(child_id, date) -- One worksheet per child per day
);

-- =====================================================
-- 6. SUBMISSIONS (Worksheet submission records)
-- =====================================================
CREATE TABLE public.submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    worksheet_id UUID NOT NULL REFERENCES public.worksheets(id) ON DELETE CASCADE,
    submission_number INTEGER DEFAULT 1, -- 1 = first submission, 2+ = corrections
    answers JSONB NOT NULL, -- Child's submitted answers
    score INTEGER NOT NULL, -- Number correct out of 100
    percentage DECIMAL(5,2) NOT NULL,
    time_taken_seconds INTEGER NOT NULL,
    is_first_submission BOOLEAN DEFAULT FALSE,
    incorrect_questions JSONB, -- Array of question indices that were wrong
    submitted_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 7. DAILY RECORDS (Calendar tracking)
-- =====================================================
CREATE TABLE public.daily_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id UUID NOT NULL REFERENCES public.children(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    worksheet_id UUID REFERENCES public.worksheets(id),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'missed')),
    first_submission_score INTEGER,
    final_score INTEGER,
    time_spent_seconds INTEGER,
    correction_attempts INTEGER DEFAULT 0,
    stars_earned INTEGER DEFAULT 0,
    streak_day INTEGER, -- Which day of the streak this was
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(child_id, date)
);

-- =====================================================
-- 8. REWARDS & ACHIEVEMENTS
-- =====================================================
CREATE TABLE public.achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    name_ms TEXT NOT NULL, -- Bahasa Malaysia
    description TEXT NOT NULL,
    description_ms TEXT NOT NULL,
    icon_url TEXT,
    type TEXT CHECK (type IN ('badge', 'milestone', 'streak')),
    requirement_type TEXT, -- 'worksheets_completed', 'streak_days', 'level_completed', etc.
    requirement_value INTEGER,
    stars_reward INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.child_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id UUID NOT NULL REFERENCES public.children(id) ON DELETE CASCADE,
    achievement_id UUID NOT NULL REFERENCES public.achievements(id),
    earned_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(child_id, achievement_id)
);

-- =====================================================
-- 9. GAME TOKENS & ACCESS
-- =====================================================
CREATE TABLE public.game_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id UUID NOT NULL REFERENCES public.children(id) ON DELETE CASCADE,
    game_type TEXT NOT NULL CHECK (game_type IN ('flappy_bird', 'balloon_pop', 'platformer')),
    tokens_available INTEGER DEFAULT 0,
    total_earned INTEGER DEFAULT 0,
    last_played_at TIMESTAMPTZ,
    high_score INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(child_id, game_type)
);

-- =====================================================
-- 10. SUBSCRIPTIONS (RevenueCat sync)
-- =====================================================
CREATE TABLE public.subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    revenuecat_customer_id TEXT,
    product_id TEXT,
    status TEXT DEFAULT 'none' CHECK (status IN ('none', 'trial', 'active', 'expired', 'cancelled')),
    plan_type TEXT CHECK (plan_type IN ('monthly', 'yearly')),
    started_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- INDEXES for performance
-- =====================================================
CREATE INDEX idx_children_parent ON public.children(parent_id);
CREATE INDEX idx_child_level_progress_child ON public.child_level_progress(child_id);
CREATE INDEX idx_worksheets_child_date ON public.worksheets(child_id, date);
CREATE INDEX idx_submissions_worksheet ON public.submissions(worksheet_id);
CREATE INDEX idx_daily_records_child_date ON public.daily_records(child_id, date);

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.children ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.child_level_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.worksheets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_records enable ROW LEVEL SECURITY;

-- Parents can only access their own data
CREATE POLICY "Users can view own profile" ON public.user_profiles
    FOR ALL USING (auth.uid() = id);

CREATE POLICY "Parents can manage own children" ON public.children
    FOR ALL USING (parent_id = auth.uid());

CREATE POLICY "Access own children's progress" ON public.child_level_progress
    FOR ALL USING (child_id IN (SELECT id FROM public.children WHERE parent_id = auth.uid()));

CREATE POLICY "Access own children's worksheets" ON public.worksheets
    FOR ALL USING (child_id IN (SELECT id FROM public.children WHERE parent_id = auth.uid()));

CREATE POLICY "Access own children's submissions" ON public.submissions
    FOR ALL USING (worksheet_id IN (
        SELECT w.id FROM public.worksheets w 
        JOIN public.children c ON w.child_id = c.id 
        WHERE c.parent_id = auth.uid()
    ));

CREATE POLICY "Access own children's daily records" ON public.daily_records
    FOR ALL USING (child_id IN (SELECT id FROM public.children WHERE parent_id = auth.uid()));
```

### Entity Relationship Diagram

```
┌─────────────────┐       ┌─────────────────┐
│  user_profiles  │       │   achievements  │
│─────────────────│       │─────────────────│
│ id (PK)         │       │ id (PK)         │
│ email           │       │ name            │
│ parent_password │       │ description     │
│ subscription    │       │ type            │
│ language        │       │ requirement     │
└────────┬────────┘       └────────┬────────┘
         │                         │
         │ 1:N                     │ N:M
         ▼                         ▼
┌─────────────────┐       ┌─────────────────┐
│    children     │◄──────│child_achievements│
│─────────────────│       └─────────────────┘
│ id (PK)         │
│ parent_id (FK)  │       ┌─────────────────┐
│ name            │       │     levels      │
│ current_level   │       │─────────────────│
│ total_stars     │       │ id (PK)         │
│ current_streak  │       │ phase           │
└────────┬────────┘       │ topic           │
         │                │ config          │
         │ 1:N            └────────┬────────┘
         ▼                         │
┌─────────────────┐                │
│child_level_prog │◄───────────────┘
│─────────────────│
│ child_id (FK)   │
│ level_id (FK)   │
│ status          │
│ best_score      │
└────────┬────────┘
         │
         │ 1:N
         ▼
┌─────────────────┐       ┌─────────────────┐
│   worksheets    │──────►│  submissions    │
│─────────────────│  1:N  │─────────────────│
│ id (PK)         │       │ worksheet_id(FK)│
│ child_id (FK)   │       │ answers         │
│ level_id (FK)   │       │ score           │
│ questions       │       │ time_taken      │
│ date            │       └─────────────────┘
└────────┬────────┘
         │
         │ 1:1
         ▼
┌─────────────────┐
│  daily_records  │
│─────────────────│
│ child_id (FK)   │
│ date            │
│ worksheet_id    │
│ status          │
└─────────────────┘
```

---

## 🔨 Phase 1: Foundation & Authentication (Weeks 1-3)

### Week 1: Project Setup & Configuration

| Task | Description | Priority |
|------|-------------|----------|
| 1.1 | Create Flutter project with proper folder structure | High |
| 1.2 | Setup Supabase project (create account, project, get keys) | High |
| 1.3 | Configure Flutter packages (pubspec.yaml) | High |
| 1.4 | Setup environment variables (.env) | High |
| 1.5 | Create base theme (colors, typography, app theme) | Medium |
| 1.6 | Setup localization (English + Bahasa Malaysia) | Medium |
| 1.7 | Configure code analysis (lint rules) | Low |

**Key Packages:**
```yaml
dependencies:
  flutter_bloc: ^8.1.3
  supabase_flutter: ^2.0.0
  go_router: ^12.0.0
  shared_preferences: ^2.2.0
  flutter_secure_storage: ^9.0.0
  equatable: ^2.0.5
  intl: ^0.18.0
  flutter_localizations:
    sdk: flutter
  json_annotation: ^4.8.0
  freezed_annotation: ^2.4.0
  
dev_dependencies:
  build_runner: ^2.4.0
  freezed: ^2.4.0
  json_serializable: ^6.7.0
  flutter_lints: ^3.0.0
```

### Week 2: Authentication System

| Task | Description | Priority |
|------|-------------|----------|
| 2.1 | Create Supabase database tables (run SQL schema) | High |
| 2.2 | Implement AuthService (Supabase Auth wrapper) | High |
| 2.3 | Create AuthBloc (state management) | High |
| 2.4 | Build Splash Screen | High |
| 2.5 | Build Login Screen (email/password) | High |
| 2.6 | Build Registration Screen | High |
| 2.7 | Password reset flow | Medium |
| 2.8 | Session persistence (auto-login) | High |
| 2.9 | Error handling & validation | High |

**Deliverables:**
- [ ] User can register with email/password
- [ ] User can login
- [ ] User can reset password
- [ ] Session persists across app restarts
- [ ] Parent password setup for level unlocking

### Week 3: Child Profile Management

| Task | Description | Priority |
|------|-------------|----------|
| 3.1 | Create Child model & repository | High |
| 3.2 | Build Add Child screen | High |
| 3.3 | Build Child Selection screen | High |
| 3.4 | Avatar selection/upload | Medium |
| 3.5 | Edit/Delete child profile | Medium |
| 3.6 | Child switching logic | High |
| 3.7 | Create ChildBloc for state management | High |

**Deliverables:**
- [ ] Parent can create child profiles
- [ ] Parent can select which child to use
- [ ] Parent can edit/delete child profiles
- [ ] Multiple children supported per account

---

## 🔨 Phase 2: Core Worksheet System (Weeks 4-7)

### Week 4: Question Generation Engine

| Task | Description | Priority |
|------|-------------|----------|
| 4.1 | Design Question model | High |
| 4.2 | Create base QuestionGenerator abstract class | High |
| 4.3 | Implement TracingGenerator (Levels 1-8) | High |
| 4.4 | Implement SequenceGenerator (Level 9) | High |
| 4.5 | Create level configuration system | High |
| 4.6 | Question randomization with seed | Medium |
| 4.7 | Answer validation logic | High |

**Question Types Architecture:**
```dart
abstract class QuestionGenerator {
  List<Question> generate(int count, LevelConfig config);
  bool validateAnswer(Question question, dynamic userAnswer);
}

class TracingGenerator extends QuestionGenerator { }
class ArithmeticGenerator extends QuestionGenerator { }
class FractionGenerator extends QuestionGenerator { }
class AlgebraGenerator extends QuestionGenerator { }
class GeometryGenerator extends QuestionGenerator { }
```

### Week 5: Arithmetic Question Generators

| Task | Description | Priority |
|------|-------------|----------|
| 5.1 | Implement AdditionGenerator (Levels 10-13) | High |
| 5.2 | Implement SubtractionGenerator (Levels 14-16) | High |
| 5.3 | Implement MultiplicationGenerator (Levels 17-18) | High |
| 5.4 | Implement DivisionGenerator (Levels 19-20) | High |
| 5.5 | Difficulty scaling within levels | Medium |
| 5.6 | Ensure no duplicate questions in worksheet | High |

### Week 6: Worksheet UI & Timer

| Task | Description | Priority |
|------|-------------|----------|
| 6.1 | Build Home Dashboard screen | High |
| 6.2 | Build Level Map screen (show all phases/levels) | High |
| 6.3 | Create Worksheet screen layout | High |
| 6.4 | Build Question Page widget | High |
| 6.5 | Implement page navigation (swipe/buttons) | High |
| 6.6 | Build Timer widget (15-minute countdown) | High |
| 6.7 | Timer persistence on background | Medium |
| 6.8 | Auto-submit on timer end | High |

### Week 7: Submission & Results Flow

| Task | Description | Priority |
|------|-------------|----------|
| 7.1 | Create WorksheetBloc for state management | High |
| 7.2 | Implement submission logic | High |
| 7.3 | Build Results Screen (score display) | High |
| 7.4 | Highlight incorrect answers | High |
| 7.5 | Build Correction Screen | High |
| 7.6 | Implement correction flow (until 100%) | High |
| 7.7 | Save first submission vs corrections | High |
| 7.8 | Database sync for submissions | High |

**Deliverables:**
- [ ] Questions generated for Levels 1-20
- [ ] 10-page worksheet with 10 questions each
- [ ] 15-minute timer
- [ ] Results displayed after submission
- [ ] Correction flow for wrong answers
- [ ] First submission score recorded separately

---

## 🔨 Phase 3: Handwriting Recognition (Weeks 8-10)

### Week 8: Drawing Canvas

| Task | Description | Priority |
|------|-------------|----------|
| 8.1 | Create DrawingCanvas widget | High |
| 8.2 | Implement touch/stylus input capture | High |
| 8.3 | Stroke recording & storage | High |
| 8.4 | Undo/Redo functionality | Medium |
| 8.5 | Clear canvas button | High |
| 8.6 | Line thickness/color options | Low |
| 8.7 | Canvas for different question types | High |

### Week 9: ML Recognition Integration

| Task | Description | Priority |
|------|-------------|----------|
| 9.1 | Integrate Google ML Kit (Digital Ink Recognition) | High |
| 9.2 | Configure ML models for numbers (0-9) | High |
| 9.3 | Configure models for operators (+, -, ×, ÷, =) | High |
| 9.4 | Configure models for variables (x, y) | Medium |
| 9.5 | Stroke preprocessing | High |
| 9.6 | Recognition confidence thresholds | High |

### Week 10: Answer Validation & Tracing

| Task | Description | Priority |
|------|-------------|----------|
| 10.1 | Tracing accuracy detection (dot connection) | High |
| 10.2 | Number writing validation | High |
| 10.3 | Multi-digit answer parsing | High |
| 10.4 | Fraction input recognition | High |
| 10.5 | Algebraic expression parsing | Medium |
| 10.6 | Tolerance settings for recognition | Medium |
| 10.7 | Fallback for unrecognized inputs | High |

**Deliverables:**
- [ ] Children can draw answers on screen
- [ ] System recognizes handwritten numbers
- [ ] Tracing levels validate path accuracy
- [ ] Multi-digit and fraction answers supported
- [ ] Clear feedback on recognition

---

## 🔨 Phase 4: Progress & Gamification (Weeks 11-13)

### Week 11: Level Progression System

| Task | Description | Priority |
|------|-------------|----------|
| 11.1 | Implement level unlock logic (95% pass) | High |
| 11.2 | Create ProgressBloc | High |
| 11.3 | Level status tracking (locked/unlocked/completed) | High |
| 11.4 | Parent manual unlock feature | High |
| 11.5 | Phase completion tracking | Medium |
| 11.6 | Level map visual states | High |

### Week 12: Calendar & Performance Tracking

| Task | Description | Priority |
|------|-------------|----------|
| 12.1 | Build Calendar View screen | High |
| 12.2 | Daily record tracking | High |
| 12.3 | Streak calculation logic | High |
| 12.4 | Build Performance Reports screen | High |
| 12.5 | Charts/graphs for progress | Medium |
| 12.6 | Weekly/monthly statistics | Medium |
| 12.7 | Missed day handling | High |

### Week 13: Rewards System

| Task | Description | Priority |
|------|-------------|----------|
| 13.1 | Implement star/coin earning | High |
| 13.2 | Create achievements system | High |
| 13.3 | Badge display UI | Medium |
| 13.4 | Level-up celebration animations | Medium |
| 13.5 | Streak reward bonuses | Medium |
| 13.6 | Game token earning | High |

**Deliverables:**
- [ ] Levels unlock at 95% score
- [ ] Calendar shows daily completion
- [ ] Streaks tracked and displayed
- [ ] Stars/coins earned for completion
- [ ] Achievement badges awarded
- [ ] Performance graphs available

---

## 🔨 Phase 5: Parent Dashboard & Settings (Weeks 14-15)

### Week 14: Parent Dashboard

| Task | Description | Priority |
|------|-------------|----------|
| 14.1 | Build Parent Dashboard screen | High |
| 14.2 | Child progress overview | High |
| 14.3 | Historical scores view | High |
| 14.4 | Level unlock interface | High |
| 14.5 | Password verification for unlock | High |
| 14.6 | Re-lock level feature | Medium |
| 14.7 | Per-child reports | High |

### Week 15: Settings & Tutorial Videos

| Task | Description | Priority |
|------|-------------|----------|
| 15.1 | Build Settings screen | High |
| 15.2 | Language switcher (EN/BM) | High |
| 15.3 | Change password flow | Medium |
| 15.4 | Build Tutorial Video player screen | High |
| 15.5 | Video integration (from Supabase Storage) | High |
| 15.6 | Video access before worksheet | High |
| 15.7 | Notification settings (future) | Low |

**Deliverables:**
- [ ] Parent can view all children's progress
- [ ] Parent can unlock/lock levels
- [ ] Language switching works
- [ ] Tutorial videos play before levels
- [ ] Settings persist

---

## 🔨 Phase 6: Mini-Games (Weeks 16-18)

### Week 16: Games Hub & Flappy Bird

| Task | Description | Priority |
|------|-------------|----------|
| 16.1 | Build Games Hub screen | High |
| 16.2 | Game token display/deduction | High |
| 16.3 | Implement Flappy Bird game | High |
| 16.4 | Flappy Bird physics | High |
| 16.5 | Obstacle generation | High |
| 16.6 | Score tracking | High |
| 16.7 | High score leaderboard | Medium |

### Week 17: Balloon Pop & Platformer

| Task | Description | Priority |
|------|-------------|----------|
| 17.1 | Implement Balloon Pop game | High |
| 17.2 | Balloon spawning logic | High |
| 17.3 | Tap detection & pop animation | High |
| 17.4 | Implement Platformer game | High |
| 17.5 | Character movement & jumping | High |
| 17.6 | Platform/obstacle design | High |
| 17.7 | Game completion state | High |

### Week 18: Game Polish & Integration

| Task | Description | Priority |
|------|-------------|----------|
| 18.1 | Game pause/resume functionality | Medium |
| 18.2 | Sound effects (optional) | Low |
| 18.3 | Game over screens | High |
| 18.4 | Return to app flow | High |
| 18.5 | Token economy balancing | Medium |
| 18.6 | Testing all games | High |

**Deliverables:**
- [ ] 3 working mini-games
- [ ] Games unlock with tokens
- [ ] Tokens earned from worksheets
- [ ] High scores tracked
- [ ] Smooth game experience

---

## 🔨 Phase 7: Subscription & Payments (Weeks 19-20)

### Week 19: RevenueCat Integration

| Task | Description | Priority |
|------|-------------|----------|
| 19.1 | Setup RevenueCat account | High |
| 19.2 | Configure products (monthly/yearly) | High |
| 19.3 | Integrate RevenueCat SDK | High |
| 19.4 | Implement purchase flow | High |
| 19.5 | Restore purchases | High |
| 19.6 | Subscription status sync to Supabase | High |

### Week 20: Trial & Paywall Logic

| Task | Description | Priority |
|------|-------------|----------|
| 20.1 | Build Subscription screen | High |
| 20.2 | Trial period tracking (30 days) | High |
| 20.3 | Paywall display after trial | High |
| 20.4 | Grace period handling | Medium |
| 20.5 | Subscription expiry handling | High |
| 20.6 | Receipt validation | High |

**Deliverables:**
- [ ] 1-month free trial works
- [ ] Monthly & yearly subscriptions purchasable
- [ ] Paywall blocks access after trial expires
- [ ] Restore purchases works
- [ ] Subscription status persists

---

## 🔨 Phase 8: Testing & Polish (Weeks 21-24)

### Week 21-22: Advanced Question Generators

| Task | Description | Priority |
|------|-------------|----------|
| 21.1 | Implement FractionGenerator (Levels 21-22) | High |
| 21.2 | Implement AlgebraGenerator (Levels 23-37) | High |
| 21.3 | Implement RootsGenerator (Levels 38-42) | Medium |
| 21.4 | Implement PolynomialGenerator (Levels 43-45) | Medium |
| 21.5 | Implement FactorizationGenerator (Levels 46-53) | Medium |
| 21.6 | Implement GeometryGenerator (Levels 54+) | Medium |

### Week 23-24: QA & Bug Fixes

| Task | Description | Priority |
|------|-------------|----------|
| 23.1 | End-to-end testing all flows | High |
| 23.2 | Device compatibility testing | High |
| 23.3 | Performance optimization | High |
| 23.4 | Memory leak fixes | High |
| 23.5 | UI/UX polish | High |
| 23.6 | Localization review (EN/BM) | High |
| 23.7 | Edge case handling | High |
| 23.8 | Crash analytics integration | Medium |
| 24.1 | Beta testing with real users | High |
| 24.2 | Feedback incorporation | High |
| 24.3 | Final bug fixes | High |
| 24.4 | Performance profiling | Medium |

---

## 🔨 Phase 9: Deployment (Weeks 25-26)

### Week 25: Store Preparation

| Task | Description | Priority |
|------|-------------|----------|
| 25.1 | Create App Store Connect account | High |
| 25.2 | Create Google Play Console account | High |
| 25.3 | Prepare app icons (all sizes) | High |
| 25.4 | Create screenshots for stores | High |
| 25.5 | Write store descriptions (EN/BM) | High |
| 25.6 | Privacy policy & terms | High |
| 25.7 | Age rating questionnaire | High |
| 25.8 | Build release APK & IPA | High |

### Week 26: Submission & Launch

| Task | Description | Priority |
|------|-------------|----------|
| 26.1 | Submit to App Store | High |
| 26.2 | Submit to Google Play | High |
| 26.3 | Address review feedback | High |
| 26.4 | Production environment setup | High |
| 26.5 | Monitoring setup | Medium |
| 26.6 | Launch! 🚀 | High |

---

## ⚠️ Risk Assessment

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Handwriting recognition accuracy | High | Medium | Use ML Kit, allow tolerance, provide fallback |
| 54+ levels content creation | High | Medium | Prioritize Phase 1-8 first, add others iteratively |
| App Store rejection | High | Low | Follow guidelines strictly, test thoroughly |
| Performance on low-end devices | Medium | Medium | Optimize rendering, lazy loading |
| Subscription platform issues | Medium | Low | Use RevenueCat (handles complexity) |
| Tutorial video delivery | Medium | Medium | Use CDN, compress videos, offline cache |
| Scope creep | High | High | Stick to MVP, defer future phases |

---

## 🛠️ Tech Stack Details

### Frontend (Flutter)
| Package | Purpose |
|---------|---------|
| flutter_bloc | State management |
| go_router | Navigation |
| supabase_flutter | Backend integration |
| purchases_flutter | RevenueCat SDK |
| google_mlkit_digital_ink_recognition | Handwriting ML |
| video_player | Tutorial videos |
| fl_chart | Performance graphs |
| flame | Game engine (mini-games) |
| shared_preferences | Local storage |
| flutter_secure_storage | Secure data |
| intl | Localization |

### Backend (Supabase)
| Service | Purpose |
|---------|---------|
| Auth | User authentication |
| Database (PostgreSQL) | All app data |
| Storage | Tutorial videos, avatars |
| Realtime | Future: live features |
| Edge Functions | Complex server logic |

### Third-Party Services
| Service | Purpose |
|---------|---------|
| RevenueCat | Subscription management |
| Firebase Crashlytics | Crash reporting |
| Firebase Analytics | Usage analytics |

---

## 📝 Development Checklist Summary

### MVP (Minimum Viable Product) - Weeks 1-15
- [ ] Authentication (register, login, child profiles)
- [ ] Levels 1-20 working (Phases 1-6)
- [ ] Handwriting recognition
- [ ] Worksheet flow (10 pages, 100 questions, 15 min)
- [ ] Auto-marking & corrections
- [ ] Level progression (95% to advance)
- [ ] Calendar & streak tracking
- [ ] Parent dashboard
- [ ] Basic rewards (stars)
- [ ] Tutorial video support
- [ ] Bilingual (EN/BM)

### Full Product - Weeks 16-26
- [ ] Mini-games (3)
- [ ] Subscription & payments
- [ ] Advanced levels (21-54+)
- [ ] Full achievement system
- [ ] Polish & optimization
- [ ] Store deployment

---

## 📅 Milestone Checkpoints

| Week | Milestone | Demo |
|------|-----------|------|
| 3 | Auth & Profiles Complete | Login, create child, select child |
| 7 | Worksheet MVP | Complete Level 1 worksheet |
| 10 | Handwriting Works | Draw answers, get recognition |
| 13 | Gamification Complete | Earn stars, see calendar |
| 15 | Parent Features Done | Dashboard, unlock levels |
| 18 | Games Playable | Play all 3 mini-games |
| 20 | Payments Working | Subscribe, trial works |
| 24 | Beta Ready | Full app testable |
| 26 | Launch! 🚀 | App live on stores |

---

*Development plan prepared for Math Learning App*  
*Last updated: February 12, 2026*
