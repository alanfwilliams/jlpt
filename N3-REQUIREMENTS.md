# JLPT N3 — Implementation Requirements

This document describes what needs to be built to extend the course from N4 (day 660) through JLPT N3 readiness.

---

## 1. Scope

JLPT N3 sits between the basic (N5/N4) and intermediate-advanced (N2/N1) levels. Learners must understand Japanese used in everyday situations and can to some extent follow Japanese used in a variety of contexts.

**Target additions:**

| Category | Approximate Count |
|----------|-------------------|
| Vocabulary | ~1,500 new words |
| Kanji | ~150–200 new kanji (total ~350 with N5+N4) |
| Grammar patterns | ~100–120 new patterns |
| Reading passages | Introduce short paragraph-level reading |

---

## 2. Curriculum phases

Extend `curriculum.js` with approximately 300 new days (days 661–960), organised into 6 new phases.

| Phase | Days | Name | Content |
|-------|------|------|---------|
| 15 | 661–690 | N4 Review | 30-day consolidation bridge to N3 |
| 16 | 691–770 | N3 Vocabulary | ~1,500 words across 80 days (~18 words/day) |
| 17 | 771–820 | N3 Verbs & Adjectives | Transitive/intransitive pairs, compound verbs, na/i-adjective patterns |
| 18 | 821–895 | N3 Grammar | ~120 grammar patterns across 75 days |
| 19 | 896–930 | N3 Kanji | ~170 new kanji across 35 days (~5 kanji/day) |
| 20 | 931–960 | N3 Test Prep | Mixed review, mock tests, reading practice |

### Phase constants to add

```javascript
// PHASE_COLORS
15: '#7f8c8d',   // N4 Review — grey
16: '#0984e3',   // N3 Vocabulary — bright blue
17: '#d63031',   // N3 Verbs & Adjectives — crimson
18: '#6c5ce7',   // N3 Grammar — violet
19: '#e17055',   // N3 Kanji — terracotta
20: '#00b894',   // N3 Test Prep — emerald

// PHASE_BG — lighter tints of the above

// PHASE_NAMES
15: 'N4 Review',
16: 'N3 Vocabulary',
17: 'N3 Verbs & Adjectives',
18: 'N3 Grammar',
19: 'N3 Kanji',
20: 'N3 Test Prep'
```

---

## 3. Lesson data structure

Each new day object follows the existing format:

```javascript
{
  day: 661,
  phaseNum: 15,
  phaseName: 'N4 Review',
  week: 95,              // continue sequential week numbering
  title: '...',
  intro: '...',
  type: 'vocab' | 'lesson' | 'grammar' | 'kanji' | 'review' | 'verbs' | 'reading',
  vocab: [[jp, reading, en], ...],    // always 3-element arrays
  chars: [[kanji, reading], ...],     // always 2-element arrays
  grammar: { pattern, meaning, example_jp, example_en },
  practice: '...',
  tip: '...'
}
```

### New `type` value: `"reading"`

N3 introduces paragraph-level reading comprehension. Add a `"reading"` type for days that focus on reading passages. The existing `type` field remains a string (never an array).

---

## 4. Vocabulary content (Phase 16)

### Categories to cover

N3 vocabulary spans significantly more abstract and contextual words than N4. Organise by topic clusters:

- **Daily life & routines** — 通勤 (commuting), 家事 (housework), 習慣 (habit)
- **Emotions & opinions** — 感動 (being moved), 不満 (dissatisfaction), 印象 (impression)
- **Work & society** — 経験 (experience), 責任 (responsibility), 関係 (relationship)
- **Nature & environment** — 環境 (environment), 季節 (season), 地震 (earthquake)
- **Health & body** — 症状 (symptoms), 治療 (treatment), 体調 (physical condition)
- **Media & communication** — 情報 (information), 報告 (report), 記事 (article)
- **Education & learning** — 研究 (research), 成績 (grades), 卒業 (graduation)
- **Travel & directions** — 観光 (sightseeing), 交通 (traffic), 出発 (departure)
- **Abstract concepts** — 原因 (cause), 結果 (result), 条件 (condition)
- **Adverbs & conjunctions** — たとえば (for example), やはり (as expected), つまり (in short)

### Vocab entry format

Same 3-element array as N5/N4:

```javascript
vocab: [
  ['経験', 'けいけん', 'experience'],
  ['責任', 'せきにん', 'responsibility'],
  ['環境', 'かんきょう', 'environment'],
]
```

---

## 5. Verb & adjective content (Phase 17)

### Key topics

- **Transitive/intransitive pairs** — 上げる/上がる, 下げる/下がる, 始める/始まる, 集める/集まる
- **Compound verbs** — 思い出す, 取り消す, 引き受ける, 見つける
- **Potential form** — 食べられる, 読める, 話せる
- **Passive form** — 食べられる, 読まれる, 言われる
- **Causative form** — 食べさせる, 読ませる, 行かせる
- **Causative-passive** — 食べさせられる, 行かせられる
- **Volitional form** — 食べよう, 行こう, しよう
- **na-adjective patterns** — 重要な, 正確な, 複雑な
- **i-adjective patterns** — 激しい, 素晴らしい, 恐ろしい

### Lesson structure

Each verb day should include:
- 3–5 new verbs or adjectives in `vocab`
- A `grammar` field showing the conjugation pattern being taught
- `practice` section with conjugation drills
- `tip` highlighting common mistakes or mnemonics

---

## 6. Grammar content (Phase 18)

### Key N3 grammar patterns (~120)

Organise into thematic groups across the 75 grammar days:

**Conditionals & hypotheticals**
- ～としたら / ～とすれば (supposing that)
- ～ないことには (unless)
- ～さえ～ば (if only / as long as)

**Cause & reason**
- ～おかげで (thanks to)
- ～せいで (because of — negative)
- ～以上 (since / given that)
- ～ことから (from the fact that)

**Contrast & concession**
- ～にもかかわらず (despite)
- ～くせに (even though — critical tone)
- ～一方で (on the other hand)
- ～ものの (although)

**Extent & degree**
- ～ほど (to the extent that)
- ～くらい / ぐらい (about / to the degree)
- ～ば～ほど (the more... the more...)

**Hearsay & appearance**
- ～ようだ / ～みたいだ (it seems)
- ～らしい (apparently)
- ～っぽい (seems like / -ish)
- ～とのことだ (I hear that)

**Time & sequence**
- ～うちに (while / before it's too late)
- ～たとたん (the moment that)
- ～次第 (as soon as)
- ～て以来 (ever since)

**Intention & decision**
- ～ことにする (decide to)
- ～ことになる (it has been decided that)
- ～つもりで (with the intention of)
- ～ようにする (make an effort to)

**Obligation & permission**
- ～わけにはいかない (cannot afford to)
- ～ざるを得ない (have no choice but to)
- ～べきだ (should)
- ～ことはない (there's no need to)

**Listing & examples**
- ～をはじめ (starting with)
- ～にかけて (from... through)
- ～にわたって (over / spanning)
- ～を中心に (centered around)

**Formal expressions**
- ～において (in / at — formal)
- ～に対して (toward / in contrast to)
- ～に関して (regarding)
- ～について (concerning)
- ～によると (according to)
- ～に基づいて (based on)

### Grammar entry format

Same as existing:

```javascript
grammar: {
  pattern: '～おかげで',
  meaning: 'thanks to ~',
  example_jp: '先生のおかげで日本語が上手になりました。',
  example_en: 'Thanks to my teacher, my Japanese improved.'
}
```

---

## 7. Kanji content (Phase 19)

### Target: ~170 new kanji

N3 introduces kanji with multiple readings and more abstract meanings. Group by theme:

- **People & roles** — 客, 婦, 届, 婚, 相, 係
- **Actions** — 届, 届, 預, 払, 届, 逃, 届
- **Nature** — 湖, 港, 島, 畑, 砂, 届
- **Emotions** — 悲, 届, 届, 届, 届, 届
- **Society** — 届, 届, 届, 届, 届, 届
- **Abstract** — 届, 届, 届, 届, 届, 届

Each kanji day teaches ~5 kanji using the `chars` field:

```javascript
chars: [
  ['届', 'とど(ける)'],
  ['届', 'とど(く)'],
  ...
]
```

### Multiple readings

N3 kanji often have both on'yomi and kun'yomi readings that are actively used. The `chars` format supports a single reading string — use the most common reading and introduce alternates in the `vocab` entries and `tip` text.

---

## 8. Reading comprehension (new feature)

### New lesson field: `passage`

Add an optional `passage` field for reading-focused days:

```javascript
{
  day: 935,
  type: 'reading',
  passage: {
    text_jp: '昨日、友達と一緒に映画を見に行きました。...',
    text_en: 'Yesterday, I went to see a movie with my friend. ...',
    questions: [
      {
        question_jp: '誰と映画を見に行きましたか。',
        question_en: 'Who did they go see a movie with?',
        answer: '友達'
      }
    ]
  }
}
```

### Implementation requirements

- Add `passage` rendering to `DayView` component in `index.html`
- Display Japanese text with furigana toggle (show/hide readings above kanji)
- Show comprehension questions after reading
- Add a `"reading"` exercise type to `buildExercises()` in `lib.js`
- Test coverage for passage rendering and reading exercises

---

## 9. Exercise system updates (`lib.js`)

### Existing exercise types (no changes needed)

- `mc` — multiple choice
- `typing` — type the answer
- `listen` — TTS listening comprehension

### New exercise types to add

| Type | Description | Implementation |
|------|-------------|----------------|
| `reading` | Read a passage, answer comprehension questions | Renders passage + MC/typing question |
| `conjugation` | Given a verb + target form, type the conjugation | New template in `buildExercises()` |
| `pair_match` | Match transitive/intransitive verb pairs | Drag-and-drop or sequential MC |
| `fill_blank` | Sentence with grammar slot, choose correct pattern | MC with sentence context |

### Changes to `buildExercises()`

- Increase exercise cap from 5 to 6–8 for N3 lessons (more content per day)
- Add generation logic for new exercise types
- Ensure `checkTyping()` handles longer answers with kanji input

---

## 10. SRS updates

### No structural changes needed

The existing SM-2 implementation (`srsReview`, `srsAddCards`, `srsDueCards`) handles N3 content without modification. Card IDs use the `cardId(type, day, idx)` format which scales to any day number.

### Tuning consideration

N3 has more content per day. Consider:
- Adjusting initial intervals for N3 kanji (they build on known N5/N4 kanji, so initial recall may be faster)
- Adding a "mature card" threshold to deprioritise well-known cards during review

---

## 11. UI updates (`index.html`)

### Overview calendar

- The `Overview` component grid already renders all days dynamically from the `curriculum` array — no structural changes needed
- Phase legend auto-extends if `PHASE_NAMES` is updated
- Verify the grid renders correctly at 960 days (currently 660)

### Progress bar

- Already calculates percentage from `completed.size / curriculum.length` — scales automatically

### UI string localisation

Add new `UI_STRINGS` entries for N3-introduced vocabulary:

```javascript
// Example additions
reading_passage: { en: 'Reading', ja: '読解', since: 935 },
conjugate:       { en: 'Conjugate', ja: '活用', since: 775 },
```

### Furigana toggle

- Add a toggle button above reading passages to show/hide furigana
- Render furigana using `<ruby>` / `<rt>` HTML tags
- Store preference in `localStorage`

---

## 12. Test updates (`tests.html`)

### Curriculum data integrity

Update existing integrity tests:
- Change expected total days from 660 to 960
- Add phase range assertions for phases 15–20
- Add week range assertions (weeks up to ~138)
- Validate `passage` field structure on `type: 'reading'` days

### New test modules

| Module | Tests |
|--------|-------|
| `buildExercises (N3 types)` | Verify `reading`, `conjugation`, `pair_match`, `fill_blank` exercise generation |
| `passage rendering` | Validate passage field structure, question/answer format |
| `furigana` | Test ruby tag generation from kanji + reading pairs |

### Regression protection

- Ensure all existing 92 tests continue to pass
- N5/N4 lesson data must remain untouched

---

## 13. Content authoring guidelines

To maintain consistency with the existing 660 days:

1. **`type` must be a string** — never an array (see day 85 bug)
2. **`vocab` entries must be 3-element arrays** — `[japanese, reading, english]` (see days 86–97 bug)
3. **`chars` entries must be 2-element arrays** — `[character, reading]` (see day 173 bug)
4. **`week` values must not exceed the actual week count** — calculate as `Math.ceil(day / 7)`
5. **Meaning fields must not be empty strings** — every vocab and char entry needs a valid English meaning (see days 253–308 bug)
6. **Grammar `example_jp` must use the taught pattern** — the example sentence should clearly demonstrate the grammar point
7. **`intro` text should reference prior knowledge** — connect new material to what was learned in N5/N4

---

## 14. File changes summary

| File | Changes |
|------|---------|
| `curriculum.js` | Add 300 new day objects (days 661–960), add phases 15–20 to `PHASE_COLORS`, `PHASE_BG`, `PHASE_NAMES` |
| `lib.js` | Add `reading`, `conjugation`, `pair_match`, `fill_blank` exercise types to `buildExercises()`; increase exercise cap |
| `index.html` | Add passage rendering in `DayView`, furigana toggle, reading exercise UI |
| `tests.html` | Update day count assertions, add phase 15–20 range checks, add new exercise type tests |
| `CLAUDE.md` | Update curriculum structure table, test coverage table, phase listing |

---

## 15. Implementation order

1. **Phase constants** — Add phases 15–20 to `PHASE_COLORS`, `PHASE_BG`, `PHASE_NAMES` in `curriculum.js`
2. **N4 Review days (661–690)** — Consolidation content mixing N5/N4 material
3. **N3 Vocabulary days (691–770)** — Core word lists by topic cluster
4. **N3 Verbs & Adjectives days (771–820)** — Conjugation forms, transitive/intransitive pairs
5. **N3 Grammar days (821–895)** — Grammar patterns with examples
6. **N3 Kanji days (896–930)** — ~170 new kanji with vocab context
7. **Reading comprehension** — Add `passage` field support to `lib.js` and `index.html`
8. **New exercise types** — Implement in `buildExercises()` and `DayView`
9. **N3 Test Prep days (931–960)** — Mixed review and mock exams
10. **Tests** — Update `tests.html` for all new content and features
11. **Documentation** — Update `CLAUDE.md` and `README.md`
