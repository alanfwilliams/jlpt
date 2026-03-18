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

## Task 16 — Dark Mode Support

**Priority:** LOW | **Effort:** Medium | **Category:** UX

**Problem:** The app has no dark mode. Users studying at night are exposed to a
bright white interface, which causes eye strain. Most modern browsers and OSes
expose a `prefers-color-scheme` media query that apps should respect.

**Files:**
- `index.html` — `<style>` block, App component

**Implementation:**
1. Add a `@media (prefers-color-scheme: dark)` block to the `<style>` tag that
   overrides background, text, border, and card colors
2. Add a manual toggle button in the header that overrides the OS preference,
   stored as `jlpt_theme` in localStorage (`'light'` | `'dark'` | `'auto'`)
3. Apply the theme class (`data-theme="dark"`) to `<body>` so CSS can scope rules
4. Ensure PHASE_COLORS remain readable in dark mode (lighten if needed using CSS
   `filter: brightness()`)
5. Add a test: verify `jlpt_theme` persisted value is read back on reload

---

## Task 17 — Add Lesson Completion Confirmation for Typing Exercises

**Priority:** LOW | **Effort:** Low | **Category:** UX / Quality

**Problem:** When a user finishes all exercises in a lesson that contains
typing exercises, there is no visual confirmation of the answer before the
lesson is marked complete. The final answer just disappears. This can feel
abrupt, especially on correct answers that are only partial matches
(e.g. accepted via the `/` alternative).

**Files:**
- `index.html` — `DayView` component, exercise rendering logic

**Implementation:**
1. After the last exercise answer is submitted, show a 1-second "✓ Correct!"
   or "✗ Incorrect" flash on the final card before advancing to the
   completion screen
2. Reuse the existing `feedback` state pattern already used for per-exercise
   feedback; add a `finishDelay` flag that gates the `onComplete()` call
3. Ensure the delay is skipped if the user presses Enter again (impatient
   fast-typers should not be blocked)
4. Add tests: mock `onComplete` callback, verify it is not called before
   the delay, and is called after

---

## Task 18 — Add Lesson Notes / Personal Annotations

**Priority:** LOW | **Effort:** Low | **Category:** UX / Learning

**Problem:** Users cannot attach personal notes to a lesson day. When reviewing
tricky grammar points or remembering mnemonics, there is no way to record
thoughts alongside the lesson content. Notes live in separate apps and are
disconnected from the course flow.

**Files:**
- `index.html` — `DayView` component

**Implementation:**
1. Add a collapsible "Notes" section at the bottom of `DayView` below the
   vocab/char cards
2. Use a `<textarea>` that saves on every `onChange` to
   `jlpt_note_<dayNum>` in localStorage via `safeSave`
3. Load note text on mount with a `useState` initializer reading localStorage
4. Show a small badge on the day-number header if a note exists (non-empty)
5. In Overview, render a dot indicator on calendar cells that have notes
6. Add tests: verify note is saved and loaded correctly for a given day key

---

## Task 19 — Progressive Lesson Unlock Indicator

**Priority:** LOW | **Effort:** Low | **Category:** UX / Motivation

**Problem:** The Overview calendar shows all 1,720 days at once, which can feel
overwhelming. Users have no visual distinction between days they are "eligible"
to study (up to the current streak day + 1) versus future locked days.

**Files:**
- `index.html` — Overview component, calendar cell rendering
- `index.html` — CSS for locked cell style

**Implementation:**
1. Define "unlocked" days as days 1 through `max(dayNum, max(completed)+1)`.
   Days beyond that range are "locked".
2. Add a `.locked` CSS class to calendar cells beyond the unlocked range:
   reduced opacity (0.35), `cursor: default`, no hover highlight.
3. Suppress the `onClick` handler for locked cells so clicking does nothing.
4. Add a `title="Not yet unlocked"` tooltip on locked cells.
5. Add tests: verify locked/unlocked boundary logic for a fixture completed set.

---

## Completed Tasks

| Date | Task | Summary |
|------|------|---------|
| 2026-03-08 | Task 1 — Add React Error Boundary and Crash Recovery | Added `ErrorBoundary` class wrapping `<App>` in `index.html`; wraps crash in a recoverable UI with Reload and Reset buttons; 2 new tests in `run-tests.js` (107 total). |
| 2026-03-08 | Task 2 — Handle localStorage Quota/Disabled Errors | Added `storageAvailable()` and `safeSave()` to `lib.js`; replaced all direct `localStorage.setItem` calls in `index.html` and `lib.js` with `safeSave`; added `storage-save-error` event dispatch; wired warning banner in App component; 3 new tests (110 total). |
| 2026-03-09 | Task 3 — Add Accessibility Attributes | Added `aria-label` to all TTS speak buttons; added `aria-live="polite"` + `role="status"` to exercise feedback; added `tabIndex`, `onKeyDown` (Enter/Space) to both review card components; added `role="progressbar"` + `aria-value*` to progress bar; added `title` to nav prev/next buttons; added `role="button"`, `tabIndex`, `aria-label`, `onKeyDown` to overview calendar cells; added `role="navigation"` to view-buttons container. 110 tests still passing. |
| 2026-03-10 | Task 4 — Sanitize SVG before DOM injection | Added `sanitizeSvg()` to `lib.js` (strips script tags, on* event attrs, foreignObject, javascript: hrefs, external use-element refs); wired into SVG loader in `index.html`; added Content-Security-Policy meta tag; 7 new tests (117 total). |
| 2026-03-12 | Task 5 — Graceful SVG Network Failure Handling | Added `sessionStorage` caching to `loadStrokeOrderSvg`; added 2-retry logic (1s/2s delays); extracted `fetchStroke` helper in `CharCard`; error state now shows character in large font + "Stroke order unavailable" + Retry button; 3 new tests (120 total). |
| 2026-03-14 | Task 6 — Runtime Curriculum Validation | Added `validateCurriculum()` to `lib.js` (checks array type, length=1720, required fields, day-number integrity at spot positions); wired into App render in `index.html` to show error UI on failure; 5 new tests (125 total). |
| 2026-03-15 | Task 7 — Consolidate Duplicate Review Button Styles | Added `:root` CSS custom properties for grade button colors (`--btn-again/hard/good/easy`) and level colors (`--level-n5/n4/n3/n2/n1`); removed duplicate `.review-btns`/`.review-btn` CSS block; added `.review-btns--3` modifier for ReviewView 3-column layout; added `LEVEL_COLORS` lookup object referencing `PHASE_COLORS` to replace ternary chain. 125 tests still passing. |
| 2026-03-16 | Task 8 — Add TTS Rate and Voice Controls | Added `window._ttsRate` global read by `speak()`; added `speechRate` React state in `App` (default 0.85) persisted to `jlpt_tts_rate`; added `useEffect` syncing state to `window._ttsRate`; added `<select>` dropdown in header with 0.5×/0.75×/0.85×/1.0×/1.25× options; added `.tts-rate-label` and `.tts-rate-select` CSS. 125 tests still passing. |
| 2026-03-17 | Task 9 — Add Export/Import Progress | Added `exportProgress()` and `validateProgressData()` to `lib.js`; added Export/Import buttons to app header in `index.html`; export downloads `jlpt-progress-YYYY-MM-DD.json` with version field; import validates structure, confirms overwrite, writes to localStorage, and reloads; added `.data-btn` CSS; 7 new tests (132 total). |
