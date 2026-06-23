# Chapter 10 — Pipelining

> 🌱 **Starting from zero?** Perfect. This chapter assumes you've never heard the word "pipeline" used about a computer. We'll start with doing laundry, build up slowly, and only bring in the technical words and formulas once the picture is already in your head. Read top to bottom, slowly.
>
> ⏱️ Take about 2 hours. This chapter is **numbers-heavy and heavily examined** — the formulas and the three hazard types come up again and again, so go slow on those.

---

## 🤔 First, why does this chapter exist?

Imagine you have a CPU that runs one instruction at a time. It picks up an instruction, figures out what it means, fetches the data, does the maths, writes the answer back — and *only then* picks up the next instruction. That works, but it's wasteful: while the CPU is doing the maths, the part that fetches instructions is sitting idle. While it's fetching, the maths unit is idle. Most of the chip is doing nothing at any given moment.

**Pipelining is the trick that keeps all the parts busy at once.** It's one of the single biggest reasons modern CPUs are fast. So this chapter answers: *how do we overlap instructions so the whole chip works as a team instead of one part at a time — and what gets in the way when we try?*

By the end you'll be able to, in your own words:
- explain pipelining using an everyday assembly-line / laundry comparison, and name the **6 stages** (FI, DI, CO, FO, EI, WO),
- draw and read a **space-time diagram** (the picture showing overlap),
- use the **performance formulas** (cycles, speedup, efficiency, throughput) and explain why speedup can never beat the number of stages,
- spot and fix the **three kinds of hazard** (structural, data, control),
- describe how CPUs **deal with branches**, including the **2-bit predictor**.

---

## 1. The core idea: an assembly line for instructions

Let's start with laundry. Say washing one load takes 4 steps: **Wash → Dry → Fold → Store**, each step taking the same amount of time.

The slow way: you wash a load, dry it, fold it, put it away — *then* start the next load. While the dryer runs, your washer sits empty. Wasteful.

The smart way: the moment the first load moves from washer to dryer, you start washing the *second* load. Now the washer and dryer are both busy. Keep doing this and every machine is working on a different load at the same time.

```text
   Laundry (4 stages):  Wash -> Dry -> Fold -> Store
   Load A: Wash Dry  Fold Store
   Load B:      Wash Dry  Fold Store
   Load C:           Wash Dry  Fold Store
   => 4 loads finish in 7 time-slots instead of 16
```

A CPU pipeline is exactly this idea applied to instructions. We chop the work of running an instruction into separate **stages**, each with its own dedicated hardware. While the "execute" stage works on instruction 1, the "fetch" stage is already grabbing instruction 2, and so on — every stage works on a different instruction at the same moment.

That's the whole concept. The technical name is **pipelining**, and each step is a **stage**.

> 🧠 **Memory hook:** *"Same total work per instruction, but more instructions in flight."* You don't make any single load of laundry finish faster — you just stop letting machines sit idle.

> ⚠️ **The most common misunderstanding:** pipelining does **not** speed up a single instruction. Instruction 1 still goes through all the stages, start to finish (in fact slightly *slower*, as we'll see). What improves is **throughput** — how many instructions *complete per unit of time* once the line is full.

> ✍️ **Check yourself:** Does pipelining make a single instruction finish faster?
> <details><summary>Reveal answer</summary>No — each instruction still passes through every stage (often slightly slower because of latch overhead, explained later). Pipelining increases <b>throughput</b> (instructions completed per unit time), <i>not</i> the time for any one instruction.</details>

---

## 2. The six stages of the pipeline

Stallings splits running an instruction into **6 stages**. Don't be scared by the abbreviations — each is just one small job:

| # | Stage (plain name) | Abbrev | What it actually does |
|---|-------|--------|--------|
| 1 | Fetch Instruction | **FI** | Go get the next instruction from memory |
| 2 | Decode Instruction | **DI** | Read it — what operation is this, and what does it need? |
| 3 | Calculate Operands | **CO** | Work out *where* the input data lives (its addresses) |
| 4 | Fetch Operands | **FO** | Go get that input data (if it's in a register, skip this) |
| 5 | Execute Instruction | **EI** | Actually do the operation (the maths/logic) |
| 6 | Write Operand | **WO** | Save the result back to memory |

Think of it as: *find the instruction → understand it → figure out where its data is → get the data → do the work → put the answer away.*

> 🧠 **Memory hook:** **"Five Dogs Chase Four Energetic Wolves"** → **F**I · **D**I · **C**O · **F**O · **E**I · **W**O.

> ⚠️ **Exam trap:** In the idealized diagrams, Stallings assumes **every stage takes the same amount of time**. That's what lets them overlap perfectly. In real life stages differ, and the **slowest stage sets the clock speed** for all of them (the line can only move as fast as its slowest station).

---

## 3. The space-time diagram (the picture of overlap)

To *see* the overlap, we draw a **space-time diagram** (also called a pipeline diagram). It's just a grid:
- **across the top:** clock cycles (time ticking forward),
- **down the side:** the instructions (I1, I2, I3…).

Each row shows one instruction marching through the six stages, each row starting one cycle later than the one above. Here's 9 instructions, no interruptions:

```text
        Clock cycle  -> 
Instr   1  2  3  4  5  6  7  8  9  10 11 12 13 14
 I1     FI DI CO FO EI WO
 I2        FI DI CO FO EI WO
 I3           FI DI CO FO EI WO
 I4              FI DI CO FO EI WO
 I5                 FI DI CO FO EI WO
 I6                    FI DI CO FO EI WO
 I7                       FI DI CO FO EI WO
 I8                          FI DI CO FO EI WO
 I9                             FI DI CO FO EI WO
                                            ^^ all 9 done at cycle 14
```

Read it in plain words:
- Cycles **1–6:** the pipeline is **filling up** — the first instruction is still working its way through, and not everything is busy yet (like the start of laundry day before all machines are running).
- After cycle 6: the line is full, and **one instruction finishes every single cycle**. That's the payoff.

How to count the total cycles without drawing the whole grid: the first instruction needs all **k** stages (here 6) to come out. After that, the remaining **(n − 1)** instructions each pop out one cycle later. So:

```text
total cycles = k + (n − 1)
```

For our example: 6 + (9 − 1) = **14 cycles**. Compare that to doing them one at a time: 9 × 6 = **54 cycles**. Big win.

> ✍️ **Check yourself:** How many cycles for 5 stages and 100 instructions?
> <details><summary>Reveal answer</summary>k + (n−1) = 5 + 99 = <b>104</b> cycles. One at a time would be 5 × 100 = 500.</details>

---

## 4. The performance formulas (go slow here — heavily examined)

This is the part exams love. Let's define the symbols in plain words first, then build the formulas.

- **k** = number of stages.
- **n** = number of instructions.
- **τ** (tau) = the delay of the **slowest stage**. The whole line can only tick as fast as its slowest station.
- **d** = **latch overhead** — a tiny extra cost each cycle. (A *latch* is a small holding register between stages; passing the work from one stage to the next costs a sliver of time. This is the reason a pipelined instruction is slightly *slower* end-to-end.)
- So the **cycle time** is `τ_cycle = τ_max + d`.

Now the formulas, built up one at a time:

```text
Time WITHOUT pipeline:   T1   = n * k * τ_cycle      (each instr takes all k cycles, one after another)
Time WITH pipeline:      Tk   = [k + (n-1)] * τ_cycle  (our cycle-count formula, times the cycle time)

                 T1        n*k*τ          n*k
  SPEEDUP  S  = ----  =  ----------- =  ---------
                 Tk      [k+(n-1)]τ     k + (n-1)

  THROUGHPUT  =  n / Tk          (how many instructions complete per unit time)
                                 -> approaches 1 / τ_cycle as n -> ∞ (one per cycle)

  EFFICIENCY  η  =  Speedup / k  =  n / [k + (n-1)]
                                 (what fraction of the pipeline slots are actually doing work)
```

In plain words:
- **Speedup (S)** = how many times faster the pipeline is than doing it one-at-a-time. The τ's cancel, so it simplifies to `nk / (k + n − 1)`.
- **Throughput** = instructions finished per unit time — basically "how fast does the conveyor belt deliver?"
- **Efficiency (η)** = how full the pipeline is. If half the slots are empty bubbles, efficiency is low.

**What happens as you run more and more instructions (n → ∞)?**

```text
  S -> k        (speedup can never exceed the number of stages)
  η -> 1        (100% busy)
  Throughput -> 1 per cycle
```

> ⚠️ **Exam trap (very common):** **Speedup is capped at k** — the number of stages. It is NOT unlimited. Why? Because the best you can ever do is finish one instruction per cycle, and a non-pipelined version took k cycles per instruction, so the most you can win is a factor of k. Adding more stages helps only up to a point: more stages means more latch overhead and bigger branch penalties.

> 🧠 **Memory hook:** Speedup = *"n-k over k-plus-n-minus-1"* = `nk / (k + n − 1)`.

> ✍️ **Check yourself:** 4-stage pipeline, very large n — what's the most speedup you can get?
> <details><summary>Reveal answer</summary>It approaches <b>4</b> (= k). Never more than the number of stages.</details>

---

## Now the bad news: things that break the overlap ("hazards")

The pretty diagram above assumed every instruction flows smoothly. Real programs interrupt the flow. A **hazard** is anything that forces the pipeline to pause and insert a **bubble** (a wasted, do-nothing cycle, also called a **stall**). There are exactly **three families** of hazard. Learn all three cold.

---

## 5. Hazard #1 — Structural (resource) hazard

**The everyday version:** you and your roommate both need the *one* washing machine at the same time. There's only one, so one of you has to wait.

**The CPU version:** two instructions need the **same piece of hardware in the same cycle** — for example, a single memory port that both the FI stage (fetching an instruction) and the FO stage (fetching operands) want at once, or one ALU, or one register write-port.

```text
        c1  c2  c3  c4  c5  c6
 I1     FI  DI  CO  FO  EI  WO
 I2         FI  DI  CO  FO  EI
 I3             FI  DI  CO  FO
 I4                 FI*           <- I4's FI clashes with I1's FO for memory
                    --- stall ---
 I4                     FI  DI ...   (delayed one cycle = bubble)
```

**Fixes (in plain words):** *get more of the resource.* Give instructions and data their own separate memory/cache (the **Harvard split**), add more register-file ports, or — if you can't — just **stall** and wait your turn.

> 🧠 **Memory hook:** Structural = *"two jobs, one tool."*

---

## 6. Hazard #2 — Data hazard (RAW / WAR / WAW)

**The everyday version:** you ask someone to read out a total before they've finished adding it up. The number isn't ready yet.

**The CPU version:** an instruction needs a value that an earlier instruction — *still moving through the pipe* — hasn't produced yet.

```text
 ADD R1, R2, R3   ; computes R1 (the result isn't ready until EI/WO)
 SUB R4, R1, R5   ; wants to read R1  <-- but ADD hasn't written R1 yet!
```

Here's the stall it causes (the bubbles are the waiting):

```text
        c1  c2  c3  c4  c5  c6  c7  c8
 ADD    FI  DI  CO  FO  EI  WO              (R1 valid only after WO @ c6)
 SUB        FI  DI  --  --  CO  FO  EI  WO   <- stalled 2 cycles
                    ^^^^^^^ bubbles: waiting for R1
```

There are **three flavours**, named by the *order* of the read and write that clash:

| Type | Name | The pattern | It's a hazard when… |
|------|------|---------|----------------|
| **RAW** | True dependency | **W**rite then **R**ead (you read what was just written) | the read happens before the write finishes — *the real, unavoidable one* |
| **WAR** | Antidependency | **R**ead then **W**rite | a later write finishes before the earlier read happens |
| **WAW** | Output dependency | **W**rite then **W**rite | the two writes complete in the wrong order |

> ⚠️ **Exam trap:** In a simple **in-order** pipeline (instructions run strictly in program order), **only RAW actually happens.** WAR and WAW only show up with **out-of-order execution / register renaming**. Know all three names, but understand which can occur where.

**Fixes (plain words):**
- **stall** — just wait (insert bubbles); simple but slow.
- **operand forwarding / bypassing** — the clever fix: route the result *straight from the ALU* to the next instruction the moment it's computed, instead of waiting for it to be written back. Like handing someone the answer directly instead of filing it first and making them look it up.
- **compiler reordering** — shuffle independent instructions in between to fill the gap.
- **register renaming** — fixes WAR/WAW by using extra hidden registers.

> 🧠 **Memory hook:** **R**ead **A**fter **W**rite = the order you *want* to happen, which is why RAW is called the *true* dependency.

> ✍️ **Check yourself:** `MOV R3,R5` then `MOV R5,R7` — which hazard?
> <details><summary>Reveal answer</summary>The first <i>reads</i> R5, the second <i>writes</i> R5 → <b>WAR (antidependency)</b>.</details>

---

## 7. Hazard #3 — Control (branch) hazard

**The everyday version:** you're driving and a fork is coming up, but you won't know which way to go until the last second. If you guess "straight ahead" and start driving that way, then find out you should've turned — you have to back up. The driving you already did was wasted.

**The CPU version:** a **conditional branch** (an "if" — jump somewhere if a condition holds) isn't *resolved* until late in the pipeline (around EI). But the pipeline kept busy in the meantime by fetching the instructions that come *right after* the branch — the "fall-through" path. If the branch turns out to be **taken** (it jumps somewhere else), all those fetched instructions are wrong and must be **flushed** (thrown away).

```text
        c1  c2  c3  c4  c5  c6  c7  c8  c9
 BR(taken) FI DI CO FO EI WO              <- target known only after EI (c5)
 I2        FI DI CO FO  x                  } fetched on the
 I3           FI DI CO  x                  } "fall-through" path,
 I4              FI DI  x                  } then THROWN AWAY (the penalty)
 I5                 FI  x
 TARGET                  FI DI CO FO EI WO  <- the correct stream finally starts
            <----- penalty = wasted cycles ----->
```

The **branch penalty** is the number of cycles lost fetching the wrong path (roughly the number of stages between FI and where the branch is resolved). An *untaken* branch usually costs nothing — you guessed "keep going straight" and you were right.

> 🧠 **Memory hook:** Control hazard = *"bet on the next address and sometimes lose."*

---

## 8. Dealing with branches — five techniques

Since branches are expensive, CPUs use tricks to reduce the penalty:

| Technique | The idea (plain words) | Notes |
|-----------|------|-------|
| **Multiple streams** | Build a second copy of the early stages and fetch *both* paths at once, then keep whichever was right | Costly; the two paths fight over resources |
| **Prefetch branch target** | Fetch the jump-target instructions *as well as* the fall-through, and hold them ready until the branch resolves | Used in the IBM 360/91 |
| **Loop buffer** | A tiny, fast memory holding the most recently fetched instructions — brilliant for tight loops that run the same code over and over | Like a mini instruction cache; sequential only |
| **Branch prediction** | *Guess* taken or not-taken and run with the guess | **Static** or **dynamic** — see §9 |
| **Delayed branch** | The compiler puts a genuinely useful instruction in the **delay slot** (the spot right after the branch), which *always* runs regardless of the branch outcome | Common in RISC / MIPS |

Two sub-families of prediction:
- **Static prediction** (ignores history — same guess every time): predict-never-taken, predict-always-taken, **predict-by-opcode**.
- **Dynamic prediction** (learns from what happened before): a **taken/not-taken switch**, or a **branch history table (BHT)** with 1- or 2-bit counters.

> ✍️ **Check yourself:** Which technique uses an instruction *delay slot*?
> <details><summary>Reveal answer</summary><b>Delayed branch</b> — the instruction right after the branch runs no matter what; the compiler fills that slot with useful work (or a NOP if it can't).</details>

---

## 9. Dynamic prediction — the 2-bit predictor

Here's the problem with the simplest possible predictor (a **1-bit predictor** that just remembers "what happened last time"): in a loop it's wrong **twice** — once when entering and once when exiting — because a single surprise immediately flips its guess.

The fix is a **2-bit saturating counter**. The idea in one line: *give it two strikes before it changes its mind.* One odd result (like the single not-taken at the end of a loop) isn't enough to flip a confident prediction, so loops predict correctly almost every time.

It has four states. Reading the diagram: **00** and **01** mean "predict NOT taken," **10** and **11** mean "predict TAKEN." A *taken* outcome nudges the state up (toward strong-taken); a *not-taken* outcome nudges it down. It "saturates" — it can't go above 11 or below 00.

```text
   States (prediction in [ ]):           T = branch Taken, N = Not taken

        T               T               T
   +-------->+     +-------->+     +-------->+
   |         |     |         |     |         |
 +-----------------+   +-----------------+
 | 00 Strong   N   |   | 01 Weak     N   |
 | [NOT TAKEN] |<--|---| [NOT TAKEN]     |
 +-------------+   N   +-----------------+
       ^   |  N (stay)        |  T
       |   |                  v
       |   |          +-----------------+   +-----------------+
       |   +--------->| 10 Weak     T   |-->| 11 Strong   T   |
       |       N      | [TAKEN]         | T | [TAKEN]    |<---+ T (stay)
       +--------------+-----------------+   +-----------------+
                                  ^   |  N
                                  |   +----> (back toward NOT TAKEN)
```

The rule in plain words:

```text
  Predict TAKEN  if state in {10,11};   Predict NOT TAKEN if state in {00,01}
  On TAKEN:     state++ (saturates at 11)
  On NOT TAKEN: state-- (saturates at 00)
```

> 🧠 **Memory hook:** *"Two strikes to change your mind."* One anomaly (like a loop exit) won't flip a confident prediction.

> ⚠️ **Exam trap:** A **branch history table (BHT)** is **dynamic** (it uses runtime history). **Predict-by-opcode** is **static** (decided ahead of time, no history). Don't mix them up.

---

## ✅ You now understand…

Take a breath. In plain terms, you can now:

1. Explain pipelining as an **assembly line for instructions** — overlap the stages so every part stays busy; it boosts **throughput**, not single-instruction speed.
2. Name the **6 stages**: FI, DI, CO, FO, EI, WO (*Five Dogs Chase Four Energetic Wolves*).
3. **Read and draw a space-time diagram** and count cycles with `k + (n − 1)`.
4. Use the formulas: **speedup** `S = nk/(k+n−1)`, **efficiency** `η = S/k`, **throughput** `n/Tk`, and know **speedup is capped at k**.
5. Identify the **three hazards** — structural (one tool, two jobs), data (RAW/WAR/WAW; only RAW in a simple in-order pipe), control (wrong path fetched after a branch).
6. List **branch-handling techniques** and explain the **2-bit predictor** (two strikes to flip).

If any of those feels shaky, re-read that section before moving on. When all six feel comfortable, do `exercises.md`, then `mcq.md`.

---

## 🎓 When you're revising for the exam

Everything above is the understanding. For the exam, keep these crisp:

- **Cycle count:** pipelined = `k + (n − 1)`; non-pipelined = `n·k`.
- **Speedup:** `S = nk / (k + n − 1)`, and always verify with `S = T1 / Tk`. As n → ∞, **S → k** (the hard cap; never higher).
- **Efficiency:** `η = S/k = n/(k+n−1) → 1`. **Throughput:** `n/Tk → 1 per cycle`.
- **Cycle time with latch overhead:** `τ_cycle = τ_max + d`.
- **With stalls:** `total cycles = k + (n − 1) + Σ stalls`, where Σ stalls = (number of hazards) × (penalty each).
- **Hazard taxonomy:** Structural = hardware clash; Data = RAW(true)/WAR(anti)/WAW(output); Control = branch flush. **Only RAW** in a simple in-order pipe.
- **Static vs dynamic prediction:** static = no history (never / always / by-opcode); dynamic = uses history (taken/not-taken switch, BHT, 2-bit counter).

> 🧠 **Mega-mnemonic:** **"FI-DI-CO-FO-EI-WO · S=nk/(k+n−1)≤k · Structural/Data/Control · 2 strikes to flip."**

### 🔬 Worked example (know this method cold)

**Setup:** 6-stage pipeline (FI DI CO FO EI WO), cycle time = 2 ns. Run **n = 30** instructions.

**Q1 — Non-pipelined time:**
```text
T1 = n * k * τ = 30 * 6 * 2 ns = 360 ns
```

**Q2 — Pipelined time (no hazards):**
```text
cycles = k + (n-1) = 6 + 29 = 35
Tk = 35 * 2 ns = 70 ns
```

**Q3 — Speedup:**
```text
S = nk / (k + n - 1) = (30*6) / 35 = 180/35 = 5.14
  (check: T1/Tk = 360/70 = 5.14)  ✔
```

**Q4 — Efficiency & throughput:**
```text
η = S / k = 5.14 / 6 = 0.857  (85.7% utilization)
Throughput = n / Tk = 30 / 70 ns = 0.4286 instr/ns ≈ 428 MIPS
```

**Q5 — Add branch penalty.** Suppose 20% of the 30 instructions are **taken branches**, each costing a **3-cycle penalty** (flush 3 wrong instructions).
```text
taken branches = 0.20 * 30 = 6
stall cycles   = 6 * 3 = 18
new cycles     = 35 + 18 = 53
T_branch       = 53 * 2 ns = 106 ns
S_effective    = T1 / T_branch = 360 / 106 = 3.40   (down from 5.14)
```
> Branches alone dropped speedup from 5.14 to 3.40 — *this* is why branch prediction matters.

**Q6 — Asymptote check (n → ∞, no hazards):** S → k = **6**. Our 5.14 is below 6 because the pipeline-fill cost (k−1 = 5 cycles) is significant when n is small.

### 🧷 One-page recap
```text
STAGES (6):  FI  DI  CO  FO  EI  WO
CYCLES:      pipelined = k+(n-1)      non-pipe = n*k
SPEEDUP:     S = nk/(k+n-1)   -> k as n->∞   (S ≤ k always!)
EFFICIENCY:  η = S/k = n/(k+n-1) -> 1
THROUGHPUT:  n/Tk -> 1 per cycle
WITH STALLS: cycles = k+(n-1)+ Σstalls

HAZARDS:
  Structural -> resource clash -> duplicate HW / stall
  Data       -> RAW(true)/WAR(anti)/WAW(output) -> forward, stall, rename
  Control    -> branch flush  -> predict / delay slot / prefetch target

BRANCHES: multiple streams · prefetch target · loop buffer ·
          prediction(static: never/always/opcode; dynamic: switch/BHT/2-bit) ·
          delayed branch
2-BIT PREDICTOR: 00,01 = predict N ; 10,11 = predict T ; needs 2 misses to flip
```

---

## 📚 Want to see/hear it explained another way?

- Stallings, *Computer Organization & Architecture* 11e — Ch. 14 "Processor Structure and Function" / Instruction Pipelining: https://www.pearson.com/en-us/subject-catalog/p/computer-organization-and-architecture/P200000003297
- Neso Academy — Pipelining playlist: https://www.youtube.com/playlist?list=PLBlnK6fEyqRgPLTKYaRhcMt8pVKl4crr6
- Gate Smashers — Pipelining & Hazards: https://www.youtube.com/playlist?list=PLxCzCOWd7aiHMonh3G6QNKq53C6oNXGrX
- GeeksforGeeks — Instruction Pipelining: https://www.geeksforgeeks.org/computer-organization-and-architecture-pipelining-set-1-execution-stages-and-throughput/
- GeeksforGeeks — Pipeline Hazards: https://www.geeksforgeeks.org/hazards-in-pipeline/
- TutorialsPoint — Pipelining: https://www.tutorialspoint.com/computer_organization_and_architecture/computer_organization_and_architecture_pipelining.htm
