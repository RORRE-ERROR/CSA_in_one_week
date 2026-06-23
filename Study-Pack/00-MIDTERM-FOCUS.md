# 🎯 Midterm / First-Half Exam Focus (WIA1003)

> Built by reverse-engineering the **real Midterm Test (22 April 2026)**.
> The final/resit is expected to ask the **same style** of questions on the same first-half material.
> Use this file to know *what* to drill and *how the questions are framed* — then sit `MIDTERM-MOCK-EXAM.md`.

---

## ✅ Confirmed scope (first half of the course)

The midterm drew **every** question from these chapters:

| Chapter | In scope? | Weight on the real paper |
|---------|-----------|--------------------------|
| `01-Introduction` | ✅ | Light — 2 Qs (performance techniques, transistor shrink → RC delay) |
| `02-Performance` | ✅ **heavy** | 4+ Qs — all numerical (exec time, CPI, reverse-solve) |
| `03-Computer-Function-Interconnection` | ✅ **heavy** | 5 Qs — instruction cycle, PC/IR, interrupts (Figs 3.5 / 3.7 / 3.9) |
| `04-Cache-Memory` | ✅ **heaviest** | 7+ Qs — mapping bit-fields, EAT, locality, write policy, "what is a tag" |
| `07-Input-Output` (interrupt-driven I/O & DMA only) | ✅ partial | 1–2 Qs — DMA defining trait, why interrupts exist |
| `05, 06, 08–12` | ❌ second half | Not tested at midterm |

> **Bottom line:** master **Cache (04)** and **Performance (02)** first — together they were ~½ the paper. Then **Computer Function (03)**. `01` and the **interrupt/DMA** parts of `07` are quick wins.

---

## 🧪 Exam format (what the paper looks like)

- **All multiple-choice.** 25 questions, 1 hour, **1 attempt, no review afterwards**, time pressure is real (~2 min/Q).
- **4 or 5 options** (A–D or A–E). When there are 5, **"None of the answers is correct"** is almost always present — and is sometimes the right answer (it was for *locality* and *who manages the cache*).
- **Scenario-framed**, not bare definitions: *"You are evaluating two processors A and B…", "A high-performance workstation has…"*. Read the whole stem; some numbers are **deliberate distractors**.
- **Stallings figures appear verbatim** — Fig **3.5** (program execution trace), Fig **3.7** (program flow with/without interrupts), Fig **3.9** (instruction cycle with interrupts). Know how to *read* them.
- **Hexadecimal** addresses for cache mapping — you must split a hex address into TAG/SET/WORD and give the answer **back in hex**.

---

## 🔁 The 6 question archetypes (and how to attack each)

### 1. Performance — straight execution time
*"50 MHz, 1000 instructions, CPI 3.5 → time?"*
Recipe: `T = Ic × CPI / f`. Watch the **units** (MHz → 10⁶, GHz → 10⁹; answer in ns/µs/ms).

### 2. Performance — **reverse-solve** for an unknown
*"Processor B must be 20% faster than A — what CPI?"* / *"What memory-op CPI hits an 8.5 s target?"*
Recipe: compute the **target total cycles** (`cycles = T × f`), turn into target average CPI (`= cycles / Ic`), then solve the mix equation for the one unknown term. **"20% faster" = 0.8 × the time, not 1.2×.**

### 3. Performance — instruction-mix optimisation
*"ALU count −50%, Branch −25% → new CPI and new exec time?"*
Recipe: convert %→counts, apply the changes, **recompute total cycles AND the new instruction total**. New CPI = newCycles / **newIc**; new time = newCycles / f. ⚠️ Time uses the **new** cycle count — a classic distractor reuses the old one.

### 4. Cache — split a hex address
*"24-bit address FFFFF8, 4 B blocks, 4-way, find TAG & SET in hex."*
Recipe: `w = log₂(block)`, `#lines = cache/block`, `#sets = #lines / k`, `set bits = log₂(#sets)`, `tag = n − w − setbits`. Write the address in binary, slice off WORD (low bits) then SET, what's left is TAG; convert each slice back to hex.

### 5. Cache/Function — concept with a sneaky distractor
*"What is a tag?", "Define spatial locality", "Who manages the cache?", "Write-through's disadvantage?"*
These reward precise definitions. If every literal option is subtly wrong, **the answer is "None of the above."**

### 6. Figure-trace (instruction cycle & interrupts)
*Read Fig 3.5/3.7/3.9 and state what the PC/IR holds or what the CPU does on an interrupt.*
Know: **PC holds the address of the *next* instruction** and is **incremented right after each fetch**; on an interrupt the CPU **finishes the current instruction, saves context (PC + PSW), then loads the PC with the handler address.**

---

## ⚠️ Traps that cost marks (memorise these)

1. **Effective Access Time has two models — know which your examiner uses.**
   The midterm's accepted answer for *(500 ns memory, 50 ns cache, 90% hit)* was **95 ns**, i.e.
   `EAT = H·T_cache + (1−H)·T_memory = 0.9·50 + 0.1·500 = 95 ns`.
   The other common model `EAT = T_cache + (1−H)·T_memory = 50 + 50 = 100 ns` was the **wrong-answer distractor**.
   👉 For this course, default to **`H·Tc + (1−H)·Tm`**. (The `Tc + (1−H)·Tm` form in `04/exercises.md` P7–P8 is the *alternative* convention — see the note added there.)
2. **"20% faster" = ×0.8 execution time.** Not ÷1.2, not ×1.2.
3. **Cache is hardware-managed and transparent** to OS/compiler/user → "who manages the cache?" = *None of the above* unless an option literally says the cache controller/hardware.
4. **Spatial ≠ temporal.** Spatial = *nearby addresses*; temporal = *same address again soon*. Distractors swap them.
5. **PC after a fetch already points to the NEXT instruction** (it was incremented during fetch).
6. **Decreasing power density is NOT a performance technique** — it's the *problem* (the power wall). The techniques are: faster/shrunk logic gates, bigger/faster caches, and parallelism.
7. **Write-through's downside = heavy memory traffic** (every write hits memory), *not* circuit complexity or stale memory.
8. **DMA** = block transfer between I/O and memory **without tying up the CPU per word** (CPU only set-up + final interrupt).

---

## 📌 What to expect on the final, chapter by chapter

- **01** — 1–2 concept Qs: Moore's law consequence (shrinking → RC delay, higher resistance & capacitance), the list of performance-improvement techniques (and what is *not* one).
- **02** — 3–4 **numericals**: execution time, average CPI from a mix, reverse-solve a CPI for a speed target, optimisation → new CPI & time. Drill `02/exercises.md` + archetypes 1–3 above until automatic.
- **03** — instruction-cycle trace (Fig 3.5), function of PC/IR/MAR/MBR, why interrupts exist, what the CPU does on an interrupt (Fig 3.9), long vs short I/O wait (Fig 3.7).
- **04** — the bulk: TAG/LINE-or-SET/WORD splits in **hex**, direct vs associative vs set-associative, EAT (model above), locality definitions, replacement (LRU), write-through vs write-back, "what is a tag/line/block".
- **07 (partial)** — programmed vs interrupt-driven vs DMA; DMA's defining characteristic; cycle stealing only if they go deeper.

---

## 🗓️ Condensed first-half revision (≈3 focused sessions)

1. **Session A — Cache (04):** notes → all 11 exercises → mcq → the cache block of the mock exam. This is the highest-yield hour you can spend.
2. **Session B — Performance (02):** notes → exercises 1–10 → drill archetypes 1–3 → performance block of the mock.
3. **Session C — Function (03) + Intro (01) + I/O basics (07):** notes (03 §3–§7, 07 §4) → mcqs → remaining mock questions → re-read the **Traps** list above.
4. Finish by sitting **`MIDTERM-MOCK-EXAM.md`** closed-book under a 50-minute timer.

> Then run a full pass of `MASTER-CHEATSHEET.md` the night before. Good luck. 💪
