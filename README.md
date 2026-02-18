# 日本語 N5/N4 Course

A free, self-contained interactive Japanese course from zero to JLPT N4 level.
**No install. No account. Just open `index.html` in any browser.**

🔗 **Live:** [alanfwilliams.github.io/jlpt-n5](https://alanfwilliams.github.io/jlpt-n5)

---

## What's inside

| Feature | Details |
|---|---|
| **N5 + N4 curriculum** | Complete N5 (365 days) + N4 content (30+ days and growing) |
| **Spaced repetition (SRS)** | SM-2 algorithm, same as Anki — cards scheduled automatically |
| **Text-to-speech** | Native browser Japanese voice on every vocab word |
| **Listening exercises** | Hear a word, pick the meaning |
| **Quiz mode** | Multiple choice + typing, lesson content blurred so you can't cheat |
| **Progress saved** | localStorage — your place is remembered between sessions |
| **Kanji stroke order** | Toggle to show/hide stroke order diagrams (N5 kanji + expanding) |
| **Offline** | Works without internet after first load |

## How to use

1. Open `index.html` in Chrome, Edge, or Safari (Firefox works but TTS quality varies)
2. Study the day's content
3. Click **Start Quiz** to test yourself
4. Use the **Review** tab daily for spaced-repetition flashcards
5. Click **✓ Mark Complete** when done

## Publishing to GitHub Pages

```bash
git init
git add index.html README.md
git commit -m "Initial commit: N5 365-day course"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/jlpt-n5.git
git push -u origin main
```

Then in your repo: **Settings → Pages → Source: Deploy from branch → main / root → Save**

Your site will be live at `https://YOUR_USERNAME.github.io/jlpt-n5` within a minute.

## Curriculum overview

### N5 Course (Days 1-365)
- **Days 1–14** — Hiragana (all 46 characters)
- **Days 15–28** — Katakana (all 46 characters)
- **Days 29–84** — Foundations (numbers, particles, basic sentences)
- **Days 85–140** — Core N5 Vocabulary (~200 words)
- **Days 141–182** — Essential Verbs (て-form, ます-form, conjugation)
- **Days 183–252** — Grammar Patterns (particles, conditionals, keigo)
- **Days 253–308** — Kanji (all ~100 N5 kanji)
- **Days 309–365** — Review & JLPT Test Prep

### N4 Course (Days 366+, expanding)
- **Days 366–395** — N5 Review & Bridge Grammar (30 days) 
- **Future content** — N4 Vocabulary, Verbs, Grammar, Kanji, Test Prep (~500+ more days)
- 🚧 **N4 curriculum is currently being developed** — contributions welcome!

## Browser compatibility

| Browser | Lessons | TTS | Speech recognition |
|---|---|---|---|
| Chrome / Edge | ✅ | ✅ | ✅ |
| Safari | ✅ | ✅ | ✅ |
| Firefox | ✅ | ⚠️ limited | ❌ |

## License

MIT — free to use, share, and modify.
