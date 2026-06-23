# 📘 Computer Systems & Organization — 1-Week Study Pack

> Built from your own lecture slides (Stallings, *Computer Organization and Architecture*, 11e).
> Goal: **learn the whole module in 7 days**, ~2 focused hours per chapter.

---

## 🏁 Preparing for the FINAL? START HERE FIRST

The final is **mostly the second half (Ch 05–12)** with **first-half carryover** (cache & performance), in the **same MCQ style** as the midterm. Two files are tuned to it:

| File | What it is |
|------|-----------|
| **`00-FINAL-FOCUS.md`** | Scope & per-chapter weighting, the exam's question style, the **second-half numerical archetypes** (Hamming, disk/RAID, pipeline, addressing, Amdahl), high-frequency concepts, and the traps that cost marks. |
| **`FINAL-MOCK-EXAM.md`** | A **38-question mock** weighted to Ch 05–12 + carryover, with fully worked answers. Sit it closed-book under a ~70-min timer. |

**Highest-yield to drill:** Hamming SEC (05) ▸ Disk/RAID (06) ▸ Addressing modes (08) ▸ Pipeline formulas (10) ▸ Flynn + MESI (11).

> 📎 **Carryover drill:** the older `00-MIDTERM-FOCUS.md` and `MIDTERM-MOCK-EXAM.md` cover the **first-half** material — keep them for the **cache hex-split** and **performance reverse-solve** questions the final is likely to recycle.

---

## 🧭 How to use this pack

Every chapter folder has **4 files**. Use them *in this order*:

| Order | File | What it's for | When |
|------:|------|---------------|------|
| 1 | `notes.md` | Teach yourself the concepts — visual, with worked examples & exam tricks | First pass (~75 min) |
| 2 | `exercises.md` | Practice problems with full worked solutions | Same day (~30 min) |
| 3 | `mcq.md` | 15 self-test MCQs (answers hidden behind ▸ toggles) | End of session (~15 min) |
| 4 | `review.md` | 1-page condensed cheat sheet — *no teaching, pure recall* | Day before exam |

> 💡 **Interactive tip:** the notes & MCQs use collapsible `▸ Answer` toggles. View the files in **VS Code preview** (`Ctrl+Shift+V`), GitHub, Obsidian, or any markdown viewer so they expand on click — don't just read raw text.

### The proven loop for each chapter (≈2 h)
```text
1. Read notes.md top-to-bottom         ~45 min   ← understand
2. Re-draw every ASCII diagram by hand  ~10 min   ← visual memory
3. Do exercises.md (try BEFORE peeking) ~30 min   ← apply
4. Take the mcq.md test, mark yourself  ~15 min   ← test
5. Skim review.md, note weak spots      ~10 min   ← consolidate
6. Cover the answer, recite the recap    ~5 min    ← active recall
```

---

## 🗓️ The 7-Day Plan

> ~2 chapters/day. Heavy/numerical chapters get a day to themselves.

| Day | Chapters | Theme | Watch out for |
|----:|----------|-------|---------------|
| **1** | `01-Introduction`, `02-Performance` | Foundations + the math of speed | Amdahl's Law, performance equation (numerical!) |
| **2** | `03-Computer-Function-Interconnection`, `04-Cache-Memory` | How a CPU runs + the memory that feeds it | Cache mapping bit-fields (the #1 exam skill) |
| **3** | `05-Internal-Memory`, `06-External-Memory` | RAM/ROM + disks/RAID | Hamming code, disk access-time, RAID levels |
| **4** | `07-Input-Output` | Talking to the outside world | Programmed vs Interrupt vs DMA |
| **5** | `08-Instruction-Set-Architecture` | The biggest chapter — give it space | Addressing modes & effective-address calc |
| **6** | `09-CISC-vs-RISC`, `10-Pipelining` | CPU design philosophy + speedup | Pipeline speedup formula, hazards |
| **7** | `11-Parallel-Processing`, `12-Multicore-Computers` | Many processors + **full revision** | Flynn's taxonomy, MESI; then `MASTER-CHEATSHEET.md` |

> 🔁 **Spaced repetition:** at the start of each day, spend 5 min reciting the previous day's `review.md`. On Day 7, do a full pass of `MASTER-CHEATSHEET.md` and re-attempt any MCQ you got wrong.

---

## 🧠 Universal exam techniques (work for every chapter)

- **Active recall beats re-reading.** After each section, close the file and say it out loud. If you can't, you don't know it yet.
- **Draw the diagram.** Most marks in this module come from labelled diagrams (instruction cycle, cache mapping, pipeline space-time, MESI). Practise drawing them from memory.
- **Learn formulas as a recipe, not a string.** Know *what each symbol means* and *what units come out* — see `02` and `04` and `10`.
- **Mnemonics are in every `notes.md`** under `> 🧠 Memory hook`. Collect them; they're your fastest recall path.
- **Read the `> ⚠️ Exam trap` callouts** — they are exactly where students lose marks.
- **Numerical chapters (02, 04, 06, 10, 12):** practise until the method is automatic. Speed matters in exams.
- **Descriptive chapters (01, 09, 11):** prepare *compare/contrast tables* — examiners love "distinguish X from Y".

---

## 📚 Core resources (used throughout)

| Resource | Best for | Link |
|----------|----------|------|
| Stallings, *COA* 11e (your textbook) | Authoritative depth | publisher / library |
| **Neso Academy** — COA playlist | Clear lectured walk-throughs | https://www.youtube.com/playlist?list=PLBlnK6fEyqRgLLlzdgiTUKULKJPYc0A4q |
| **Gate Smashers** — COA playlist | Fast exam-focused explanations | https://www.youtube.com/playlist?list=PLxCzCOWd7aiHMonh3G6QNKq53C6oNXGrX |
| **GeeksforGeeks** — COA | Quick text + solved problems | https://www.geeksforgeeks.org/computer-organization-and-architecture/ |
| **TutorialsPoint** — COA | Concise reference | https://www.tutorialspoint.com/computer_organization/ |
| **Ben Eater** (YouTube) | *Seeing* a CPU/bus work in hardware (Ch 01, 03, 08) | https://www.youtube.com/@BenEater |

*(Per-concept links are inside each chapter's `notes.md` → 📚 Resources section.)*

---

## ✅ Progress tracker

- [ ] Day 1 — Ch 01, 02
- [ ] Day 2 — Ch 03, 04
- [ ] Day 3 — Ch 05, 06
- [ ] Day 4 — Ch 07
- [ ] Day 5 — Ch 08
- [ ] Day 6 — Ch 09, 10
- [ ] Day 7 — Ch 11, 12 + full revision
- [ ] Final: scored ≥ 80% on every `mcq.md`

> When every box is ticked and every MCQ set is green, you're exam-ready. Good luck — you've got this. 💪
