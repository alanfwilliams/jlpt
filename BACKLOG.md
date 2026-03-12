# BACKLOG.md — Improvement Tasks for Future Agents

This document captures prioritized, actionable improvement tasks identified
through a comprehensive code analysis. Each task includes the problem, affected
files/lines, and a concrete implementation plan.

**Ground rules for agents working on these tasks:**
- Run `node .claude/hooks/run-tests.js` before and after every change
- Add tests in `tests.html` for any new logic
- Keep the zero-dependency, no-build-step constraint
- Do not add npm packages or bundlers
- All JS must work without transpilation (no JSX, no ES modules)

---

## Task 1 — Add React Error Boundary and Crash Recovery

**Priority:** HIGH | **Effort:** Low | **Category:** Reliability

**Problem:** No error boundary exists. If any React component throws, the entire
app goes blank with no recovery path. Users must hard-refresh and may not
understand what happened.

**Files:**
- `index.html` — wrap App component (around line 1295)

**Implementation:**
1. Add an `ErrorBoundary` class component before the App definition:
   ```js
   class ErrorBoundary extends React.Component {
     constructor(props) { super(props); this.state = { hasError: false, error: null }; }
     static getDerivedStateFromError(error) { return { hasError: true, error: error }; }
     componentDidCatch(error, info) { console.error('App crash:', error, info); }
     render() {
       if (this.state.hasError) {
         return React.createElement('div', { style: { padding: 40, textAlign: 'center' } },
           React.createElement('h2', null, 'Something went wrong'),
           React.createElement('p', null, this.state.error && this.state.error.message),
           React.createElement('button', { onClick: function() { location.reload(); } }, 'Reload'),
           React.createElement('button', { onClick: function() { localStorage.clear(); location.reload(); } }, 'Reset all data')
         );
       }
       return this.props.children;
     }
   }
   ```
2. Wrap `<App />` in `<ErrorBoundary>` in the `ReactDOM.createRoot` call
3. Add a test: render ErrorBoundary with a child that throws, assert fallback UI appears

---

## Task 2 — Handle localStorage Quota/Disabled Errors

**Priority:** HIGH | **Effort:** Low | **Category:** Data Safety

**Problem:** `lsSave` (line ~309-312) and `srsSave` (line ~472-476) silently
catch exceptions. If localStorage is full or disabled, users lose progress with
no warning.

**Files:**
- `index.html` — `lsSave`, `srsSave`, and all `localStorage.setItem` calls

**Implementation:**
1. Create a `safeSave(key, value)` helper that wraps `localStorage.setItem` in
   try/catch and returns `{ ok: boolean, error: string|null }`
2. On failure, show a non-blocking notification bar at the top of the page:
   "Unable to save progress — storage may be full or disabled"
3. Add a `storageAvailable()` check at app startup; show a persistent warning
   if localStorage is not available
4. Replace all direct `localStorage.setItem` calls with `safeSave`
5. Add test: mock `localStorage.setItem` to throw, verify `safeSave` returns error

---



## Task 6 — Runtime Curriculum Validation

**Priority:** MEDIUM | **Effort:** Low | **Category:** Reliability

**Problem:** Tests validate curriculum structure, but no runtime check exists.
If `curriculum.js` is corrupted or partially loaded, the app silently breaks.

**Files:**
- `index.html` — App component init
- `lib.js` — add `validateCurriculum()` function

**Implementation:**
1. Add `validateCurriculum()` in `lib.js`:
   - Check `curriculum.length === 1720`
   - Spot-check first/last/boundary days have required fields
   - Return `{ valid: boolean, error: string }`
2. Call at App mount; if invalid, render an error message instead of the app
3. Add test for `validateCurriculum` with valid and corrupted data

---

## Task 7 — Consolidate Duplicate Review Button Styles

**Priority:** LOW | **Effort:** Low | **Category:** Code Quality

**Problem:** Review button styles are defined in two places (lines ~157-160 and
~181-185) with slightly different values. The SRS grade buttons also have
hardcoded inline styles.

**Files:**
- `index.html` — `<style>` block

**Implementation:**
1. Audit all `.review-btn` and grade button styles
2. Consolidate into a single CSS class hierarchy
3. Remove duplicate declarations
4. Extract hardcoded level colors (line ~1253: N5=#e91e8c, etc.) into CSS custom
   properties that reference the `PHASE_COLORS` constants

---

## Task 8 — Add TTS Rate and Voice Controls

**Priority:** LOW | **Effort:** Low | **Category:** UX

**Problem:** TTS rate is hardcoded to 0.85 (line ~322). Learners at different
levels need different speeds. No voice selection is available.

**Files:**
- `index.html` — `speak()` function (line ~316-333), App header

**Implementation:**
1. Add a `speechRate` state (default 0.85) persisted to localStorage
2. Add a small dropdown or slider in the header: 0.5x / 0.75x / 1.0x / 1.25x
3. Pass `speechRate` to `utterance.rate` in the `speak()` function
4. Optionally enumerate available Japanese voices and let user pick

---

## Task 9 — Add Export/Import Progress

**Priority:** LOW | **Effort:** Medium | **Category:** UX

**Problem:** All progress is in localStorage with no backup mechanism. Users
lose everything if they clear browser data.

**Files:**
- `index.html` — add Export/Import buttons to Overview or header

**Implementation:**
1. Add "Export Progress" button that:
   - Collects all `jlpt_*` keys from localStorage
   - Creates a JSON blob with version field
   - Triggers a file download (`jlpt-progress-YYYY-MM-DD.json`)
2. Add "Import Progress" button that:
   - Opens a file picker for `.json`
   - Validates the structure
   - Confirms overwrite with user
   - Writes to localStorage and reloads
3. Add tests for the export/import data format validation

---

## Task 10 — Input Validation Hardening in checkTyping

**Priority:** LOW | **Effort:** Low | **Category:** Quality

**Problem:** `checkTyping()` (lib.js line ~449-461) doesn't handle edge cases:
excessively long input, Unicode normalization differences, or mixed-script input.

**Files:**
- `lib.js` — `normAns`, `checkTyping`

**Implementation:**
1. Add max-length guard (200 chars) — reject as incorrect
2. Apply Unicode NFC normalization in `normAns`
3. Add tests for: very long input, combining characters, fullwidth/halfwidth
   romaji equivalents

---

## Task 11 — Add Daily Review Cap

**Priority:** MEDIUM | **Effort:** Low | **Category:** UX / SRS

**Problem:** The review deck has no limit. On days when many cards are due
(e.g. after a break), users face an overwhelming queue with no sense of
when it will end. This can cause burnout and drop-off.

**Files:**
- `index.html` — ReviewMode component, App state

**Implementation:**
1. Add a `reviewCap` setting (default: 50) persisted to localStorage
2. Slice `srsDueCards()` to at most `reviewCap` cards before starting the session
3. Show "X cards remaining today" counter in the review header
4. After finishing the capped session, show "Daily limit reached — come back tomorrow"
   with a count of remaining due cards
5. Add a settings toggle to temporarily raise or disable the cap
6. Add tests: verify srsDueCards result is sliced correctly at cap boundary

---

## Task 12 — Keyboard Navigation for Day View

**Priority:** MEDIUM | **Effort:** Low | **Category:** UX / Accessibility

**Problem:** Users can only navigate between days by clicking the prev/next buttons.
Keyboard users (and power users) have no way to move between days with arrow keys,
or jump to a specific day using a number input.

**Files:**
- `index.html` — App component, keyboard event handling

**Implementation:**
1. Add a `keydown` listener on `window` in the App component (cleanup in useEffect return)
2. ArrowLeft / ArrowRight → decrement / increment `dayNum` (clamped to 1–1720)
3. Add `title="Previous day (←)"` and `title="Next day (→)"` to nav buttons
4. Add a small "Jump to day" input in the Overview header that calls `setDayNum`
5. Add tests: simulate keydown events and verify dayNum transitions

---

## Task 13 — Add Keyboard Shortcut Reference Panel

**Priority:** LOW | **Effort:** Low | **Category:** UX / Accessibility

**Problem:** Keyboard shortcuts now exist (arrow keys for review cards, Enter/Space
to flip) but are undiscoverable. Users with keyboards have no indication these
shortcuts exist.

**Files:**
- `index.html` — App component, DayView nav-bar, ReviewMode

**Implementation:**
1. Add a small "?" button in the top-right header that toggles a keyboard
   shortcuts modal/popover
2. The modal lists: Arrow keys = prev/next day (if implemented), Enter/Space =
   flip review card, Tab = move between interactive elements
3. Store dismissed state in localStorage so it auto-shows once on first visit
4. Add `aria-label="Keyboard shortcuts"` and `aria-haspopup="dialog"` to the
   button, and `role="dialog"` to the panel

---

## Task 14 — Show SRS Statistics Dashboard

**Priority:** MEDIUM | **Effort:** Low | **Category:** UX / Motivation

**Problem:** Users have no visibility into their SRS deck health. They can't see
how many cards they have total, how many are mature vs. new, or their retention
rate over time. This makes it hard to gauge progress beyond the day counter.

**Files:**
- `index.html` — Overview component or a new `StatsPanel` component

**Implementation:**
1. Add a `srsStats(srs)` function to `lib.js`:
   - Returns `{ total, new_, learning, mature, dueToday, avgEF }` where
     `new_` = cards with interval 0, `learning` = interval 1–20,
     `mature` = interval > 20
2. Render a small stats row in the Overview (above the calendar grid) showing
   these counts as pill badges
3. Add a "retention" indicator: percentage of reviews in the last 30 days
   that had quality ≥ 3 (requires logging review outcomes — store in localStorage
   as a rolling window of `{ date, grade }` entries, capped at 500 entries)
4. Add tests for `srsStats`: verify counts from a fixture SRS object

---

## Task 15 — Add Streak Counter and Streak Freeze

**Priority:** MEDIUM | **Effort:** Low | **Category:** UX / Motivation

**Problem:** The app has no streak tracking. Daily learners have no visible
indication of their consecutive-day streak, which is a key motivation driver
in language learning apps. Users who miss a day have no forgiveness mechanism.

**Files:**
- `index.html` — App component, Overview, header area
- `lib.js` — add `computeStreak(completedSet)` helper

**Implementation:**
1. Add `computeStreak(completedDays)` in `lib.js`:
   - `completedDays` is the Set of completed day numbers
   - Determine today's calendar day from `new Date()`
   - Walk backwards from today counting consecutive days that have a completed
     lesson; stop at the first gap
   - Return `{ current: number, longest: number }`
2. Persist `longestStreak` and `streakFreezes` (integer, default 1) to localStorage
3. Show a streak badge in the header: "🔥 5" (current streak)
4. On the day after a missed day, if `streakFreezes > 0`, auto-apply one freeze
   and show a "Streak saved by freeze!" toast for 3 seconds
5. Add tests for `computeStreak` with fixture completed-day sets

---

## Completed Tasks

| Date | Task | Summary |
|------|------|---------|
| 2026-03-08 | Task 1 — Add React Error Boundary and Crash Recovery | Added `ErrorBoundary` class wrapping `<App>` in `index.html`; wraps crash in a recoverable UI with Reload and Reset buttons; 2 new tests in `run-tests.js` (107 total). |
| 2026-03-08 | Task 2 — Handle localStorage Quota/Disabled Errors | Added `storageAvailable()` and `safeSave()` to `lib.js`; replaced all direct `localStorage.setItem` calls in `index.html` and `lib.js` with `safeSave`; added `storage-save-error` event dispatch; wired warning banner in App component; 3 new tests (110 total). |
| 2026-03-09 | Task 3 — Add Accessibility Attributes | Added `aria-label` to all TTS speak buttons; added `aria-live="polite"` + `role="status"` to exercise feedback; added `tabIndex`, `onKeyDown` (Enter/Space) to both review card components; added `role="progressbar"` + `aria-value*` to progress bar; added `title` to nav prev/next buttons; added `role="button"`, `tabIndex`, `aria-label`, `onKeyDown` to overview calendar cells; added `role="navigation"` to view-buttons container. 110 tests still passing. |
| 2026-03-10 | Task 4 — Sanitize SVG before DOM injection | Added `sanitizeSvg()` to `lib.js` (strips script tags, on* event attrs, foreignObject, javascript: hrefs, external use-element refs); wired into SVG loader in `index.html`; added Content-Security-Policy meta tag; 7 new tests (117 total). |
| 2026-03-12 | Task 5 — Graceful SVG Network Failure Handling | Added `sessionStorage` caching to `loadStrokeOrderSvg`; added 2-retry logic (1s/2s delays); extracted `fetchStroke` helper in `CharCard`; error state now shows character in large font + "Stroke order unavailable" + Retry button; 3 new tests (120 total). |
