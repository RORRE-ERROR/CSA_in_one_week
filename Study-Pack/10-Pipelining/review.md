# Chapter 10 — Pipelining · Quick Refresher

> 🌱 Read this in 5 minutes to refresh everything, or the day before the exam. Each idea is given in **plain words first**, then the exam wording / formula.

---

## The big ideas, in plain words

- **What pipelining is** = an **assembly line for instructions.** Chop the work of running an instruction into stages, each with its own hardware, so every stage works on a different instruction at the same time. Like a laundry line where the washer, dryer, and folder are all busy on different loads. *Exam wording:* it overlaps the stages of consecutive instructions to increase **throughput**.
- **What it does NOT do** = it doesn't make a single instruction finish faster (it's actually a touch slower per instruction, thanks to latch overhead). It improves **throughput** — instructions completed per unit time — not single-instruction **latency**.
- **The 6 stages** = find it → understand it → locate its data → get the data → do it → save it. *Exam wording:* **FI, DI, CO, FO, EI, WO** (Fetch/Decode Instruction, Calculate/Fetch Operand, Execute Instruction, Write Operand).
- **Counting cycles** = the pipe takes k cycles to fill, then spits out one instruction per cycle. *Formula:* pipelined = **k + (n − 1)**; non-pipelined = **n·k**.
- **Speedup** = how many times faster than one-at-a-time. *Formula:* **S = nk/(k+n−1)**, and it can never beat **k** (the number of stages) — that's the hard cap.
- **Hazards** = anything that interrupts the smooth flow and forces a wasted "bubble" cycle. Three families: **structural** (two jobs need one piece of hardware), **data** (an instruction needs a result that isn't ready yet — RAW/WAR/WAW), **control** (a branch made the CPU fetch the wrong instructions, which get thrown away).
- **Branches** = the CPU has to *guess* where to go next; if it guesses wrong it flushes the wasted work. It uses tricks (prefetching, loop buffers, and especially **prediction**) to guess well.
- **2-bit predictor** = "two strikes to change your mind" — one surprise (like a loop exit) isn't enough to flip a confident guess, so loops predict almost perfectly.

---

## Core formulas — at a glance
| Quantity | Formula | Limit (n→∞) |
|----------|---------|-------------|
| Pipelined cycles | `k + (n − 1)` | — |
| Non-pipelined cycles | `n · k` | — |
| **Speedup** | `S = nk / (k + n − 1) = T1/Tk` | **→ k** |
| **Efficiency** | `η = S / k = n / (k + n − 1)` | → 1 |
| **Throughput** | `n / Tk` | → 1 / cycle |
| Cycle time | `τ_max + d` (latch overhead d) | — |
| With stalls | cycles = `k + (n−1) + Σ stalls` | — |

> Speedup is **bounded by k** — never higher. k = number of stages.

## The six stages
```text
FI -> DI -> CO -> FO -> EI -> WO
Fetch  Decode  Calc    Fetch   Execute  Write
Instr  Instr   Operand Operand Instr    Operand
```
Mnemonic: **F**ive **D**ogs **C**hase **F**our **E**nergetic **W**olves.

## Hazard types & fixes
| Hazard | Plain words | Sub-types | Fix |
|--------|-------|-----------|-----|
| **Structural** | Two jobs, one tool (mem port, ALU) | — | Duplicate HW (split I/D cache), more ports, stall |
| **Data** | Needs an in-flight result | **RAW** (true), **WAR** (anti), **WAW** (output) | Forwarding/bypass, stall, reorder, register renaming |
| **Control** | Branch fetched the wrong path | taken / not-taken | Predict, delay slot, prefetch target, loop buffer, multiple streams |

```text
RAW: write-then-read  (only one in a simple in-order pipe)  <- TRUE dependency
WAR: read-then-write  (out-of-order only)                   <- ANTI dependency
WAW: write-then-write (out-of-order only)                   <- OUTPUT dependency
```

## Branch-handling methods
```text
Multiple streams     - duplicate stages, fetch both paths
Prefetch target      - grab target + fall-through, keep till resolved (IBM 360/91)
Loop buffer          - tiny fast store of recent sequential instrs; great for loops
Branch prediction    - guess outcome:
     STATIC  (no history): predict-never, predict-always, predict-by-opcode
     DYNAMIC (uses history): taken/not-taken switch, branch history table, 2-bit counter
Delayed branch       - compiler fills delay slot after branch (RISC/MIPS)
```

## 2-bit saturating predictor
```text
00 strong-NT | 01 weak-NT | 10 weak-T | 11 strong-T
predict T if state in {10,11}; predict N if {00,01}
T -> state++ (max 11);  N -> state-- (min 00)
Needs TWO consecutive misses to flip -> stable for loops
```

## Mini diagram to be able to draw
```text
        Clock cycle ->
 I1   FI DI CO FO EI WO
 I2      FI DI CO FO EI WO     <- each row starts one cycle later
 I3         FI DI CO FO EI WO     (the overlap = the whole point)
 ...fills in k cycles, then 1 instruction completes per cycle
```

## Memory aids
- **Stages:** Five Dogs Chase Four Energetic Wolves (FI DI CO FO EI WO).
- **Speedup:** "n-k over k-plus-n-minus-1" = `nk/(k+n−1)`, capped at k.
- **RAW = Read After Write = the order you want = the *true* hazard.**
- **2-bit predictor = "two strikes to change your mind."**

---

### ⭐ If you only revise 5 things
1. **Speedup `S = nk/(k+n−1)`**, and it **→ k** (the cap is the number of stages — never higher).
2. **Cycles = k + (n−1)** pipelined; **+ Σstalls** when hazards are present (non-pipelined = n·k).
3. **Three hazards:** structural (resource clash), data (RAW/WAR/WAW — only RAW in a simple in-order pipe), control (branch flush).
4. **Five branch techniques;** prediction splits into **static** (no history) vs **dynamic** (uses history: BHT, 2-bit counter).
5. **2-bit predictor** beats 1-bit because it needs **two misses to flip** — it avoids mispredicting on loop entry/exit.
