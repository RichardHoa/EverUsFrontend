# EverUs — Cloud Implementation Plan (5 Features)

This plan covers two repositories:

- **Frontend (Flutter client)**: `/Users/linux/Documents/CODE/EverUs` (app code under `flutter-project/everus/`)
- **Backend (FastAPI, raw SQL/psycopg2)**: `/Users/linux/Documents/CODE/EverUsBackend`

Both repos need changes for features 1, 2, and 3. Features 4 and 5 are frontend-only.

---

## 0. Cross-cutting rules for whoever implements this

### 0.1 Testing is REQUIRED for backend work — this overrides the backend repo's own "no tests" rule

`EverUsBackend/.agents/AGENTS.md` and `EverUsBackend/rules` currently instruct assistants not to write, create, modify, or run any tests, and not to run unsandboxed terminal commands. **The project owner has explicitly overridden this instruction for this plan.** For every backend change below:

1. **Write the test first** (red), for the specific behavior being changed — repository method, service function, or endpoint. Only then write the implementation code (green), then refactor if needed. Do not write implementation code before its test exists.
2. **Spin up a real local Postgres** to run these tests against (no mocking the DB layer — this codebase is raw SQL via psycopg2, so a real database is the only meaningful way to verify a query is correct). Suggested approach:
   ```bash
   docker run --name everus-test-pg -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=everus_test -p 5433:5432 -d postgres:16
   ```
   Point a test-only `DATABASE_URL` (e.g. `postgresql://postgres:postgres@localhost:5433/everus_test`) at it, then run the project's own migration tool against it before testing:
   ```bash
   DATABASE_URL=postgresql://postgres:postgres@localhost:5433/everus_test python scripts/migrate.py --up
   ```
3. Add `pytest` (and `psycopg2`-compatible fixtures, e.g. a `conftest.py` that creates/drops a fresh schema or wraps each test in a transaction rollback) to `requirements.txt` if not already present.
4. Structure tests under a new `tests/` directory mirroring `app/` (e.g. `tests/db/repositories/test_preference_repo.py`, `tests/services/test_questionnaire_service.py`, `tests/api/test_preferences.py`), consistent with the existing `app/<layer>/<domain>.py` split.
5. Every new repository method, service function, and endpoint added in this plan needs at least one test exercising it against the local Postgres instance. Modified query logic (district → distance) needs tests covering both the old behavior's removal and the new behavior's correctness.

### 0.2 Migration convention — do NOT create a new migration file

This project's migration tool (`scripts/migrate.py`) applies each numbered file pair (`NNNN_name.up.sql` / `NNNN_name.down.sql`) as one whole unit and tracks it by version number in `schema_migrations`. The project owner will **manually run a full reset** (drop schema, re-run `migrate.py --up` from scratch) after this code is complete — so new tables should be added by **appending new `CREATE TABLE IF NOT EXISTS` statements to the existing `migrations/0006_add_slug_to_invitations.up.sql`**, with matching `DROP TABLE IF EXISTS` statements appended to `migrations/0006_add_slug_to_invitations.down.sql`. Do not create `0007_*` files. Follow the existing style in that directory: UUID PKs via `uuid_generate_v4()`, `TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP`, explicit `ON DELETE CASCADE`/`SET NULL` on foreign keys, `CREATE INDEX IF NOT EXISTS idx_<table>_<cols>` after each table.

### 0.3 Guest / device identity — new concept, needed by features 1 and 3

There is currently no anonymous/guest identity concept anywhere in the backend (confirmed: no `device_id` column, no guest table). Both feature 1 (likes/dislikes) and feature 3 (questionnaire) need guests (no account) to persist data server-side. Introduce this once, shared by both:

- Client generates a random UUID once per install, stores it locally (reuse the existing `shared_preferences`-based session infra in `auth_helper.dart` as a pattern), and sends it as a header, e.g. `X-Device-Id`, on relevant requests.
- New tables (preferences, questionnaire responses) get **both** `user_id UUID NULL REFERENCES users(id) ON DELETE CASCADE` and `device_id VARCHAR(64) NULL`, with an application-level (not DB-level) rule that exactly one of the two identifies a given row at write time, preferring `user_id` when a valid JWT is present (reuse `get_optional_user_id` from `app/api/deps.py`).
- **Merge on login**: when a previously-guest device logs in or signs up, the client should send its `X-Device-Id` alongside the auth call (or as a follow-up authenticated call), and the backend should reassign any preference/questionnaire rows where `device_id = X` to the newly authenticated `user_id`, then null out `device_id` on those rows. Add this as a small step inside `AuthService.sign_in` / `sign_up` / `google_sign_in` (or a dedicated `POST /auth/merge-device` call made right after login) — write a test for the merge logic specifically (guest likes a place, then logs in, then the like is attributed to their account).
- Per the product decision: **guests can like/dislike places and submit the questionnaire, but cannot edit/retake the questionnaire once submitted.** Only logged-in users get a "re-open questionnaire" entry point.

---

## Feature 1 — Like / Dislike per location

### Goal
Each location card in the date planner (main and backup) gets like/dislike buttons. Preferences persist server-side (per user or per guest device). Disliked places are never chosen as the primary/main option for a stage, but may still appear as a backup option, with their score penalized like any other ranking factor (no hard "always sort last" rule — this was explicitly decided against).

### Backend changes (`EverUsBackend`)

1. **Migration** (append to `migrations/0006_add_slug_to_invitations.up.sql` / `.down.sql`):
   ```sql
   CREATE TABLE IF NOT EXISTS user_place_preferences (
       id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
       user_id UUID NULL REFERENCES users(id) ON DELETE CASCADE,
       device_id VARCHAR(64) NULL,
       place_id INT NOT NULL REFERENCES places(id) ON DELETE CASCADE,
       preference VARCHAR(10) NOT NULL CHECK (preference IN ('like', 'dislike')),
       created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
       updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
       CONSTRAINT uq_pref_user_place UNIQUE (user_id, place_id),
       CONSTRAINT uq_pref_device_place UNIQUE (device_id, place_id),
       CONSTRAINT chk_pref_identity CHECK (user_id IS NOT NULL OR device_id IS NOT NULL)
   );
   CREATE INDEX IF NOT EXISTS idx_user_place_preferences_user ON user_place_preferences(user_id);
   CREATE INDEX IF NOT EXISTS idx_user_place_preferences_device ON user_place_preferences(device_id);
   ```
   (down migration: `DROP TABLE IF EXISTS user_place_preferences;`)

2. **New repository** `app/db/repositories/preference_repo.py` (`PreferenceRepository extends BaseRepository`): `upsert_preference(user_id, device_id, place_id, preference)` (INSERT ... ON CONFLICT DO UPDATE on whichever unique constraint applies), `delete_preference(...)` (un-like/un-dislike), `get_preferences_for_identity(user_id, device_id) -> dict[place_id, preference]`, `reassign_device_to_user(device_id, user_id)` (for the merge-on-login flow in §0.3).

3. **New service** `app/services/preference_service.py` wrapping the repo, taking `get_optional_user_id` + `X-Device-Id` header to resolve identity.

4. **New endpoints**, file `app/api/preferences.py`, prefix `/api/preferences`:
   - `PUT /api/preferences/{place_id}` — body `{ "preference": "like" | "dislike" }`, upserts.
   - `DELETE /api/preferences/{place_id}` — clears a preference.
   - `GET /api/preferences` — returns all of the caller's preferences (used by the client to render like/dislike state on cards).
   Register the router in `app/main.py`.

5. **Ranking changes** in the planner pipeline:
   - `app/services/planner/optimizer.py` (`evaluate_best_combination`): before scoring combinations, fetch the caller's preferences (via the new repo) and **hard-exclude any place marked `dislike` from being selected as a stage's `chosen_place`** (filter it out of the primary-candidate set for that stage, not the whole candidate pool).
   - `app/services/planner/candidate_matcher.py` (`build_stage_options`, `backup_rank_key`): disliked places remain eligible for the backup list, but their contribution to score/tiering should include a penalty term (e.g. treat disliked places as if they were one rating-tier lower, or subtract a fixed penalty from whatever score currently drives tier/shuffle placement) so they tend to rank lower among backups — without a hard override forcing them strictly last.
   - Write tests for: a disliked place never appears as `options[0]` for its stage; a disliked place can still appear in `options[1:]`; a liked place is unaffected.

### Frontend changes (`flutter-project/everus`)

1. **`lib/screens/date_planner/widgets/date_planner_results.dart`**:
   - In `_buildLocationCard` (line ~791), remove the "Mở bản đồ" `ElevatedButton.icon` (lines ~886-908).
   - Add like/dislike buttons (icon buttons, e.g. `Icons.thumb_up`/`Icons.thumb_up_outlined` and `Icons.thumb_down`/`Icons.thumb_down_outlined` reflecting current state) calling a new controller method, e.g. `controller.setPreference(stage, opt, preference)`, which calls the new `PUT /api/preferences/{place_id}` endpoint and updates local state to re-render the icon as filled/outlined.
   - Wrap the card's non-button area in a `GestureDetector`/`InkWell` `onTap` that calls `launchUrl(Uri.parse(opt.mapsUrl))` (the same call the removed button used) — apply this to **backup cards only**, not the main card, per the confirmed decision.
   - Keep "Đặt làm chính" on backup cards as-is.

2. **`lib/screens/date_planner/date_planner_controller.dart`**: add `setPreference`/`clearPreference` methods and a local cache (`Map<int placeId, String? preference>`) so card state persists across rebuilds within a session; fetch existing preferences via `GET /api/preferences` when the results screen loads.

3. **Models**: add a `preference` field (nullable string) to `LocationOption` in `lib/models/date_plan.dart`, or track it separately keyed by place id — whichever is simpler given how `options` are rebuilt.

---

## Feature 2 — Distance-based matching (replace district)

### Goal
Remove district/quận-huyện entirely. User picks gần (≤5km) / xa (5-15km) / tuỳ hứng (re-rolled fresh, resolves randomly to gần or xa on every generation). App requests the user's location (with manual-address fallback). Matching becomes proximity-based, applied uniformly to every category — no citywide exception; `places.district` becomes unused by the algorithm.

### Backend changes (`EverUsBackend`)

1. **Schema change to `DatePlannerInput`** (`app/schemas/date_planner.py`): replace `area: str` with:
   ```python
   userLatitude: float
   userLongitude: float
   distancePreference: Literal["gan", "xa"]   # client has already resolved "tuy_hung" to one of these before sending
   ```
2. **`app/db/repositories/location_repo.py`** (`get_candidate_places_by_keyword`): replace the `WHERE p.district = %s` / citywide-exception logic entirely with a distance calculation against `(userLatitude, userLongitude)` using `places.latitude`/`places.longitude` (already present). Use a Haversine formula in SQL (or reuse whatever geodesic approach `app/services/geo_service.py` already uses for stage-to-stage transit distance, for consistency) to compute distance in km, then filter:
   - `gan`: `distance_km <= 5`
   - `xa`: `distance_km > 5 AND distance_km <= 15`
   Order by `distance_km ASC` as a primary tiebreaker alongside the existing `rating DESC NULLS LAST, rating_count DESC NULLS LAST`. Uniform for every category — remove the `is_citywide_keyword` branch and its relaxed-district logic from `app/core/constants.py`/`candidate_matcher.py` call sites.
3. **`app/services/planner/scheduler.py` / `candidate_matcher.py`**: remove any remaining references to `area`/district normalization (`app/utils/normalization.py`'s `normalize_district` becomes dead code — safe to delete once call sites are gone; confirm via grep before deleting).
4. Add a lightweight sanity check (not a full "enabled districts" allowlist — that concept is gone): if the user's coordinates are wildly outside any place's location (e.g. no candidates found within 15km for a normal stage), surface a clear "no places found near you" error rather than an empty/broken plan — mirrors today's `Exception('Khu vực ... chưa khả dụng')` pattern but distance-based.
5. Tests: candidate query returns only places within 5km for `gan`, within (5,15]km for `xa`; no category is exempted; ordering respects distance then rating.

### Frontend changes (`flutter-project/everus`)

1. **`lib/screens/date_planner/date_planner_controller.dart`**: delete `hcmcDistricts`, `enabledDistricts`, `findMatchingDistrict`, and the district-validation branch in `generatePlan()`. Replace the "which district" input step with:
   - A gần/xa/tuỳ hứng selector (3 options) in the date-planner form.
   - A geolocation request (use a geolocation package — none currently in `pubspec.yaml`; add e.g. `geolocator`) to get `userLatitude`/`userLongitude`. On permission denial, fall back to a manual address text field that gets geocoded — reuse `geocoding` package or a backend geocode endpoint if one exists; if not, add a minimal one, or geocode via the existing Google Maps integration already used for `mapsUrl` generation if feasible. (Flag for the implementer: check whether Google Geocoding API access already exists server-side before adding a new dependency.)
   - "Tuỳ hứng" resolves client-side to `gan` or `xa` at random **each time a plan is generated** (not cached/remembered) before sending `distancePreference` to the backend.
2. **`lib/utils/date_planner_generator.dart` / `lib/screens/date_planner/widgets/date_planner_form.dart`**: update the request payload to send `userLatitude`, `userLongitude`, `distancePreference` instead of `area`; update the form UI to replace the district picker with the gần/xa/tuỳ hứng selector.

---

## Feature 3 — Persist questionnaire answers, ask once

### Goal
Questionnaire answers move from CSV-file logging to a real DB table. Once answered, a user (or guest device) is never asked again — checked server-first when a durable identity exists, with the local flag only a fast-path cache. Logged-in users get a "re-open questionnaire" entry point on their profile page; guests cannot edit/retake.

### Backend changes (`EverUsBackend`)

1. **Migration** (append to the same `migrations/0006_*` files as feature 1):
   ```sql
   CREATE TABLE IF NOT EXISTS questionnaire_responses (
       id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
       user_id UUID NULL REFERENCES users(id) ON DELETE CASCADE,
       device_id VARCHAR(64) NULL,
       answers JSONB NOT NULL,
       free_text TEXT,
       client_timestamp TIMESTAMP WITH TIME ZONE,
       device_info VARCHAR(255),
       created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
       CONSTRAINT chk_qr_identity CHECK (user_id IS NOT NULL OR device_id IS NOT NULL)
   );
   CREATE INDEX IF NOT EXISTS idx_questionnaire_responses_user ON questionnaire_responses(user_id);
   CREATE INDEX IF NOT EXISTS idx_questionnaire_responses_device ON questionnaire_responses(device_id);
   ```
   (down: `DROP TABLE IF EXISTS questionnaire_responses;`)
2. **New repository** `app/db/repositories/questionnaire_repo.py`: `insert_response(...)`, `has_response_for_identity(user_id, device_id) -> bool`, `get_latest_response_for_identity(...)` (for pre-filling the edit flow), `update_response(...)` (logged-in users only).
3. **`app/services/questionnaire_service.py`**: replace the CSV-append logic in `save_response` entirely with a call to the new repo (per the decision to fully replace, not dual-write). Remove the CSV file writing code and the thread lock around it.
4. **`app/api/questionnaire.py`**: keep `POST /questionnaire/submit` (now writes to DB), add `GET /questionnaire/status` (returns `{ "answered": bool }` for the caller's identity — used by the client before deciding whether to show the questionnaire), and `PUT /questionnaire/submit` or similar for logged-in users editing their answers (must require a real `user_id`, not a device id — reject with 403 for guest-only identities per the "guests can't edit" rule).
5. Tests: submitting twice for the same guest device is still allowed at the DB level but the client won't call it again once `status` says answered; `status` returns true after a submission for both a logged-in user and a guest device; the edit endpoint rejects a device-only (no `user_id`) caller.

### Frontend changes (`flutter-project/everus`)

1. **`lib/utils/questionnaire_helper.dart`**: on app start, call `GET /questionnaire/status` (passing auth token if logged in, else `X-Device-Id`) as the source of truth; keep the existing `has_completed_couple_onboarding_v1` local flag purely as a fast-path cache to avoid a network round-trip on every launch — write it only after a server-confirmed "answered" state, and treat a cache miss/mismatch as "ask the server."
2. **`lib/screens/questionnaire_screen.dart`**: no major UI change needed; ensure it can run in "edit" mode (pre-filled from `GET`-ed prior answers) when opened from the profile page.
3. **Profile / settings**: add a "Chỉnh sửa câu trả lời" (edit answers) entry point in the logged-in profile view (`ProfileView`, referenced from `login_screen.dart`) that reopens `QuestionnaireScreen` pre-filled and submits via the new edit endpoint. Guests get no such entry point anywhere in the UI.

---

## Feature 4 — Loading animation

### Goal
Replace the fake progress-bar/percentage UI shown while a plan is generating with a looping playback of `animation.mp4` (11.5s, portrait 1184×2562, ~501KB, H.264). No percentage counter. Falls back to the existing spinner if the video fails.

### Steps (frontend only)

1. Move `animation.mp4` from the repo root into `flutter-project/everus/assets/videos/animation.mp4` (or similar), and register it under `flutter: assets:` in `pubspec.yaml`.
2. Add `video_player: ^2.x` to `pubspec.yaml` (confirmed as a new dependency — none exists today).
3. **`lib/screens/date_planner/widgets/date_planner_generating.dart`**: replace the `ValueListenableBuilder<double>` progress bar + `'${(progress * 100).toInt()}%'` text (line ~110) with a `VideoPlayerController.asset(...)` set to `setLooping(true)`, muted, autoplay, rendered full-bleed or centered per existing layout. On `VideoPlayerController` initialization error, fall back to rendering the existing `DatePlannerLoading` spinner widget instead (reuse it directly rather than duplicating spinner code).
4. **`lib/screens/date_planner/date_planner_controller.dart`**: the `_startProgressTimer()`/`_completeProgress()` simulated-progress machinery (lines ~189-220, `progressNotifier`) can be deleted entirely if nothing else consumes `progressNotifier` (grep to confirm) — the generating screen no longer needs a progress value, just a "still loading" boolean to know when to swap to the results screen. Keep whatever mechanism signals "the real API call has returned" so the loop-until-ready behavior (cut immediately, don't wait for the video loop to finish) works.

---

## Feature 5 — Icon reduction

### Goal
Cap icon usage at roughly 1-2 per screen (not 1-2 for the whole app) across the landing page, date planner, and every screen reachable from it. Keep only affordance-critical icons; replace or remove decorative/secondary ones.

### Scope, by current icon counts found in the repo (Material `Icons.*` usages, highest first)

- `lib/screens/date_planner/widgets/date_planner_results.dart` (18) — biggest target. Keep: the like/dislike icons from feature 1 (now essential) and one primary action icon (e.g. "Đặt làm chính" check icon, or the map-pin implied by the click-outside-to-map gesture). Remove/replace with text or plain layout: `Icons.sell`, `Icons.star` (consider a plain numeric rating instead of a star glyph), `Icons.assistant_navigation`, `Icons.keyboard_arrow_up/down` (the backup-expand toggle can use a text label like "Xem thêm" without a chevron, or keep one chevron only).
- `lib/screens/date_planner/widgets/date_planner_form.dart` (10) — reduce to 1-2 (e.g. keep one for the gần/xa/tuỳ hứng selector from feature 2 if a visual is helpful; drop the rest in favor of labeled buttons/text).
- `lib/screens/saved_plans_screen.dart` (8) — reduce similarly.
- `lib/widgets/activity_flow.dart` (7), `lib/screens/date_planner/widgets/date_planner_options_dialog.dart` (4), `lib/screens/landing/widgets/feature_action_cards.dart` (3), `lib/screens/landing/widgets/mini_love_counter.dart` (3), `lib/screens/date_planner_screen.dart` (3), `lib/screens/create_invite_screen.dart` (3), `lib/screens/questionnaire_screen.dart` (3) — trim each to 1-2 per the same rule.
- `lib/screens/landing_screen.dart` (2), `lib/widgets/everus_footer.dart` (2, app-wide bottom nav) — already at or near target; keep as-is unless one is clearly decorative.
- Emoji glyphs embedded in `Text` widgets (e.g. in `activity.dart`'s `DimensionInfo.icon` strings, `'🧭'`, `'💕'`, `'💸'`) are a separate mechanism from `Icons.*` and were not part of the counts above — decide per-screen whether they count against the same 1-2 budget (recommendation: treat them the same way, since visually they serve the same role as icons).

No backend changes for this feature.

---

## Summary of new/changed files

**Backend (`EverUsBackend`)**
- `migrations/0006_add_slug_to_invitations.up.sql` / `.down.sql` — append `user_place_preferences` and `questionnaire_responses` tables (+ indexes, drops).
- New: `app/db/repositories/preference_repo.py`, `app/services/preference_service.py`, `app/api/preferences.py`, `app/db/repositories/questionnaire_repo.py`.
- Modified: `app/schemas/date_planner.py`, `app/schemas/questionnaire.py`, `app/db/repositories/location_repo.py`, `app/services/planner/optimizer.py`, `app/services/planner/candidate_matcher.py`, `app/services/questionnaire_service.py`, `app/api/questionnaire.py`, `app/api/date_planner.py`, `app/services/auth_service.py` (device merge), `app/main.py` (router registration).
- Possibly deleted: district-related helpers in `app/utils/normalization.py`, `app/core/constants.py`'s citywide-keyword logic — only after confirming no other call sites via grep.
- New: `tests/` directory (pytest), local Postgres test setup, `requirements.txt` additions (`pytest`, etc.).

**Frontend (`flutter-project/everus`)**
- Modified: `date_planner_results.dart`, `date_planner_controller.dart`, `date_planner_generator.dart`, `date_planner_form.dart`, `date_planner_generating.dart`, `questionnaire_helper.dart`, `questionnaire_screen.dart`, `login_screen.dart` (profile entry point), `date_plan.dart` (model), `pubspec.yaml` (new deps: `video_player`, geolocation package, asset registration).
- Moved: `animation.mp4` → `flutter-project/everus/assets/videos/animation.mp4`.
- Icon trims across the files listed in Feature 5.
