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

## Task 3 — Add Accessibility Attributes

**Priority:** HIGH | **Effort:** Medium | **Category:** Accessibility

**Problem:** No `aria-label`, `role`, or `tabindex` attributes on interactive
elements. Screen reader users cannot navigate the app.

**Files:**
- `index.html` — all React component `createElement` calls

**Implementation (incremental — can be split across multiple PRs):**
1. **Speak buttons:** Add `aria-label="Listen to pronunciation"` to all TTS buttons
2. **Quiz buttons:** Add `role="button"` and `aria-label` with the answer text
3. **Feedback messages:** Add `aria-live="polite"` to exercise result text
4. **Navigation:** Add `role="navigation"` to header, `role="main"` to content area
5. **Review cards:** Make card flippable via Enter/Space key (add `tabIndex={0}`
   and `onKeyDown` handler)
6. **Overview calendar:** Add `aria-label` to day cells with day number and status
7. Verify with a screen reader or axe-core

---

## Task 4 — Sanitize SVG in dangerouslySetInnerHTML

**Priority:** MEDIUM | **Effort:** Low | **Category:** Security

**Problem:** Line ~579 uses `dangerouslySetInnerHTML` for stroke order SVGs
fetched via `fetch()`. While currently fetched from a known source, this is a
latent XSS vector.

**Files:**
- `index.html` — `CharCard` component (line ~579), `loadStrokeOrderSvg` (line ~343)

**Implementation:**
1. Add a `sanitizeSvg(raw)` function that:
   - Parses with DOMParser
   - Removes `<script>`, `on*` attributes, `<foreignObject>`, `<use>` with external hrefs
   - Returns the cleaned SVG string
2. Call `sanitizeSvg` on the fetch result before passing to `dangerouslySetInnerHTML`
3. Add a Content-Security-Policy `<meta>` tag to `index.html`:
   ```html
   <meta http-equiv="Content-Security-Policy" content="default-src 'self' https://cdnjs.cloudflare.com; script-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com; style-src 'self' 'unsafe-inline';">
   ```
4. Add tests: pass SVG with `<script>` tag, verify it is stripped

---

## Task 5 — Graceful SVG Network Failure Handling

**Priority:** MEDIUM | **Effort:** Low | **Category:** UX

**Problem:** `loadStrokeOrderSvg` (line ~343-350) has a `.catch()` that sets
error state but provides no retry, no fallback visual, and no caching.

**Files:**
- `index.html` — `loadStrokeOrderSvg` function, `CharCard` component

**Implementation:**
1. Add retry logic: 2 retries with 1s/2s delays
2. Cache successful SVGs in `sessionStorage` (key: character code point)
3. On final failure, show the character in large font with text "Stroke order
   unavailable" instead of a blank area
4. Add a "Retry" button in the error state

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

## Completed Tasks

| Date | Task | Summary |
|------|------|---------|
| 2026-03-08 | Task 1 — Add React Error Boundary and Crash Recovery | Added `ErrorBoundary` class wrapping `<App>` in `index.html`; wraps crash in a recoverable UI with Reload and Reset buttons; 2 new tests in `run-tests.js` (107 total). |
