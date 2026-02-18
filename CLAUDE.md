# CLAUDE.md — jlpt-n5

## Project overview

A free, self-contained, zero-dependency interactive Japanese course from zero to JLPT N5 in 365 days.
Everything runs in the browser with no build step and no installation required.

## Repository structure

```
jlpt-n5/
├── index.html          # Entire application — HTML, CSS, and JS in one file
├── README.md           # User-facing documentation
└── .nojekyll           # Disables Jekyll processing for GitHub Pages
```

## Running the app

Open `index.html` directly in a browser — no server needed.

```bash
# macOS
open index.html

# Linux
xdg-open index.html
```

## Tech stack

- **React 18** loaded from CDN (`cdnjs.cloudflare.com`) — no npm or bundler
- **Vanilla CSS** inlined in `<style>` tags
- **Web Speech API** for text-to-speech (Japanese voice)
- **localStorage** for progress persistence
- **No build step, no transpilation, no dependencies to install**

## Linting

HTML can be validated with:

```bash
npx html-validate index.html
```

## Tests

No automated test suite. The project is a single self-contained HTML file with no testable modules.
Manual verification: open `index.html` in Chrome/Edge/Safari and step through a lesson.

## Curriculum structure

| Days      | Phase                                              |
|-----------|----------------------------------------------------|
| 1–14      | Hiragana (46 characters)                           |
| 15–28     | Katakana (46 characters)                           |
| 29–84     | Foundations (numbers, particles, basic sentences)  |
| 85–140    | Core N5 Vocabulary (~200 words)                    |
| 141–182   | Essential Verbs (て-form, ます-form, conjugation)  |
| 183–252   | Grammar Patterns (particles, conditionals, keigo)  |
| 253–308   | Kanji (~100 N5 kanji)                              |
| 309–365   | Review & JLPT Test Prep                            |

## Key implementation notes

- All 365 day definitions live in `index.html` as a JavaScript `LESSONS` array
- The SM-2 spaced-repetition algorithm is implemented inline in a `useSRS` hook
- Quiz state, SRS card data, and completed-day flags are stored in `localStorage`
- The lesson view, overview calendar, and review flashcard deck are separate React components in the same file
- TTS is triggered via `window.speechSynthesis` using `lang: 'ja-JP'`

## Browser compatibility

| Browser       | Lessons | TTS          | Speech recognition |
|---------------|---------|--------------|--------------------|
| Chrome / Edge | Yes     | Yes          | Yes                |
| Safari        | Yes     | Yes          | Yes                |
| Firefox       | Yes     | Limited      | No                 |

## Deployment

Hosted on GitHub Pages — push to `main`, enable Pages from repo Settings (branch: main, root `/`).
Live URL pattern: `https://<username>.github.io/jlpt-n5`
