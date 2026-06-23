# Chapter 02 — Computer Performance

> 🌱 **Starting from zero?** Don't worry — this chapter looks like maths, but it's really just a few simple "recipes" (formulas) plus the common sense of *which* one to use. We'll meet every formula slowly: first an everyday comparison, then plain English, *then* the symbols — and we'll explain what each symbol means and what units pop out the other end. Work through it top to bottom.
>
> ⏱️ Take about 2 hours. This is a **final-exam carryover topic** — examiners love it because it's easy to ask precise number questions. Time spent here pays off twice.

---

## 🤔 First, why does this chapter exist?

You hear phrases like *"this CPU is 3 GHz"* or *"it does 2000 MIPS"* and assume bigger means faster. But here's the catch: **those numbers can lie.** A computer with a higher clock speed can finish a real job *slower*. A machine that posts more "MIPS" can be the slower one.

So how do you actually tell which computer is faster, *fairly*? That's the whole point of this chapter. We build one honest formula that measures real work, learn why the popular shortcuts mislead, and learn the rules for combining many test results into one number without cheating.

By the end you'll be able to, in your own words:
- explain **why** designers ran out of clock speed and turned to **multiple cores**,
- use the **CPU performance equation** `T = Ic × CPI × τ` to find time (or work backwards to find a missing CPI/time),
- compute an **average CPI** from a mix of instruction types,
- explain why **MIPS** is a misleading score,
- use **Amdahl's Law** to find the *most* speedup you can ever get from parallelism,
- pick the **right kind of average** (arithmetic / harmonic / geometric) for the data,
- state **Little's Law**.

---

## 🗺️ The big picture (one paragraph)

Performance = how fast a machine does *real work*. You can attack it two ways: make each instruction faster (higher clock, caches, pipelining) or do many things at once (multiple cores). But you can't trust clock speed or MIPS alone — they fool you. So we use a precise **performance equation**, we bound parallel gains with **Amdahl's Law**, and we compare machines fairly with **SPEC benchmarks** averaged by the **right kind of mean**.

```text
        WHY                  HOW (single core)        HOW (parallel)        MEASURE IT
   ┌───────────┐         ┌────────────────────┐    ┌──────────────┐    ┌───────────────┐
   │ apps need │         │ ↑clock, ↑cache,    │    │ multicore /  │    │ CPU eqn, MIPS │
   │ more power │ ──────▶│ pipeline, ISA      │    │ MIC / GPGPU  │ ──▶│ SPEC + means  │
   │ (video,AI) │         │ (limited by power, │    │ (Amdahl caps │    │ (right mean!) │
   └───────────┘         │  RC delay, memory) │    │  the gain)   │    └───────────────┘
                          └────────────────────┘    └──────────────┘
```

Read it left to right: apps demand more power → designers speed up one core, but hit walls → so they add more cores, but Amdahl caps that → and we measure it all carefully. The rest of the chapter just fills in each box.

---

## 1. Why we keep chasing more performance

Think about your phone. Every year the apps want more: HD video calls, games, photo filters, voice assistants, AI. Each new app needs more raw computing muscle than the last — so designers are *forced* to keep making chips faster. A laptop today is more powerful than a room-sized mainframe of decades ago.

The demanding jobs that push the limits:

| Driver | Example workloads |
|---|---|
| Compute-hungry desktop | 3-D rendering, speech recognition, video, simulation |
| Transaction/database servers | client/server networks, online transaction processing (OLTP) |
| Cloud at scale | high-volume, high-rate services for millions of users |

> 🧠 **Memory hook:** "More watts of work" — every new app demands more raw compute, which forces architects to keep innovating.

---

## 2. Speed isn't enough — you need *balance*

**Analogy first.** Imagine a Formula-1 race car (a super-fast CPU) stuck on a muddy dirt road (slow memory). The car can't show its speed — it's only as fast as the road lets it go. Speeding up the engine alone is pointless if everything around it can't keep up.

**Plain English.** Modern processors use lots of clever tricks to push more instructions through — but if the **memory, bus, or I/O** can't feed the CPU fast enough, the CPU just sits idle waiting. So designers must **balance** the whole path, not just the CPU.

**The jargon (the speed-up tricks):** *pipelining, branch prediction, superscalar execution, data-flow analysis, speculative execution.* You don't need the details now — just know they're techniques to push more instructions through per second.

```text
   CPU  ───fast───┐
                  ├── if memory/bus/I-O can't keep up → CPU idles (imbalance)
   MEMORY ─slow──┘   Fix: caches, wider buses, DMA, multiple memory banks
```

> 🧠 **Memory hook:** A race car (CPU) on a dirt road (slow memory) goes nowhere — **balance** the whole path.

---

## 3. Three ways to go faster — and the walls they hit

**Three ways to boost speed:**
1. **Faster hardware** — shrink the transistors (gates) so you can fit more of them, run a higher clock, and shorten the distance signals travel.
2. **Bigger/faster caches** — keep more data close to the CPU so it waits less.
3. **Better organisation/architecture** — do more in parallel.

**But shrinking the transistors hits real physical walls:**

| Problem | Why it limits us (plain English) |
|---|---|
| **Power density** | Pack more switching logic + a faster clock into a tiny area → more heat per square millimetre than you can cool. The chip would melt. |
| **RC delay** | Make wires thinner and closer → resistance (R) and capacitance (C) both rise → signals travel *slower*, not faster. |
| **Memory latency/throughput** | Memory speed has lagged far behind CPU speed for decades, so the CPU keeps waiting on data. |

> ⚠️ **Exam trap:** The reason the industry pivoted to **multicore** is the **power wall** (heat), helped along by **RC delay** and **memory lag**. You simply *can't* keep cranking the clock without melting the chip — so instead of one faster core, they put several cores side by side.

---

## 4. Multicore, MIC, and GPGPU — doing things in parallel

Once you can't make one core much faster, you add *more* cores. Three flavours:

- **Multicore** — a handful of *identical* general-purpose cores on one chip (like several normal CPUs glued together).
- **MIC (Many Integrated Core)** — a *very large* number of cores → huge potential, but writing software that keeps them all busy is **hard**.
- **GPU / GPGPU** — cores built to do the *same simple operation on lots of data at once* (originally for graphics pixels). Used as **vector processors** for repetitive maths. "GPGPU" = general-purpose GPU = using a graphics chip for ordinary number-crunching.

```text
 single core  ──▶  multicore (few GP cores)  ──▶  MIC (many cores)  ──▶  GPU (1000s, SIMD/vector)
   simple SW          modest parallelism            big SW challenge        graphics + repetitive math
```

> ⚠️ **Exam trap:** More cores does **not** mean proportional speedup. The part of the program that can't be parallelised caps the whole thing — that's **Amdahl's Law** (§9).

---

## 5. Clock speed & clock cycle time — the recipe `τ = 1/f`

**Analogy first.** A clock inside the CPU ticks like a metronome — *tick, tick, tick* — at a steady beat. Every tick lets the CPU do a little step of work. The **frequency** is how many ticks per second; the **cycle time** is how long one tick lasts. Faster metronome (more ticks/sec) = shorter gap between ticks. They're just two ways of describing the same beat.

**The recipe (introduce the formula slowly):**

```text
   τ = 1 / f
```

- **f** = clock **frequency**, measured in **hertz (Hz)** = ticks per second. (1 MHz = 10⁶ Hz, 1 GHz = 10⁹ Hz.)
- **τ** (the Greek letter "tau") = **clock cycle time** = how long one tick lasts, in **seconds**.
- They are **reciprocals**: flip one to get the other.

**Tiny example:** if f = 2 GHz, then τ = 1 / (2 × 10⁹) = 0.5 × 10⁻⁹ s = **0.5 ns**. (1 ns = a nanosecond = 10⁻⁹ s.)

```text
   f = 2 GHz  ⇒ τ = 1/(2×10⁹) = 0.5 ns
   one tick:  ┌─┐   ┌─┐   ┌─┐
              │ │___│ │___│ │___   period τ
```

| Quantity | Symbol | Unit | Relation |
|---|---|---|---|
| Clock frequency / rate | f | Hz (GHz = 10⁹) | f = 1/τ |
| Clock cycle time | τ | seconds (ns) | τ = 1/f |

> 🧠 **Memory hook:** **f and τ are reciprocals** — flip one to get the other.

> ✍️ **Check yourself:** A 3.2 GHz CPU has what cycle time?
> <details><summary>Reveal answer</summary>τ = 1/(3.2×10⁹) = 0.3125 ns ≈ 312.5 ps (picoseconds).</details>

---

## 6. The CPU performance equation — the recipe `T = Ic × CPI × τ`

This is **the single most important formula in the chapter.** Memorise it.

**Analogy first.** Suppose you're painting a fence. The total time = (how many planks) × (brush-strokes per plank) × (time per brush-stroke). Computer time works exactly the same way:

> total time = (how many instructions) × (clock cycles each instruction needs) × (time per clock cycle)

**The recipe — what each symbol means:**

```text
 ┌──────────────────────────────────────────────────────────┐
 │   CPU time  =  Ic  ×  CPI  ×  τ                            │
 │                                                            │
 │            =  Ic  ×  CPI  /  f      (since τ = 1/f)        │
 └──────────────────────────────────────────────────────────┘
```

- **T** (CPU time) = answer, in **seconds**.
- **Ic** = **instruction count** = how many instructions the program actually executes (a plain count, no units).
- **CPI** = **cycles per instruction** = on average, how many clock ticks each instruction needs (units: cycles/instruction).
- **τ** = clock cycle time = seconds per tick (= 1/f).

**Why the units work out (always sanity-check this):**

```text
   seconds  =  (instructions) × (cycles/instruction) × (seconds/cycle)
                      Ic              CPI                    τ
   → "instructions" cancels, "cycles" cancels, leaving SECONDS. ✓
```

If your units *don't* cancel down to seconds, you made a mistake somewhere.

**Tiny example:** Ic = 1000 instructions, CPI = 2, τ = 0.5 ns → T = 1000 × 2 × 0.5×10⁻⁹ = 1 × 10⁻⁶ s = 1 microsecond. (Bigger worked examples below in §🔬.)

**Who controls each factor (Table 2.1)** — this is a favourite exam table:

```text
   ┌─────────────────────────┬─────┬─────┬───────┐
   │ System attribute        │ Ic  │ CPI │ clock │
   ├─────────────────────────┼─────┼─────┼───────┤
   │ Instruction set arch.   │  X  │  X  │       │
   │ Compiler technology     │  X  │  X  │       │
   │ Processor implementation│     │  X  │   X   │
   │ Cache & memory hierarchy│     │  X  │   X   │
   └─────────────────────────┴─────┴─────┴───────┘
```

In words: the **instruction set** and the **compiler** affect how many instructions you run (Ic) and how many cycles each takes (CPI). The **processor design** and the **cache/memory** affect CPI and the clock speed.

**A refinement (for completeness):** real CPIs include waiting on memory:
`CPI = CPI_exec + (memory accesses per instruction) × miss rate × miss penalty`.
And the **total number of cycles** = `Ic × CPI`; multiply that by τ to get time.

> 🧠 **Memory hook:** **"I See Pie Times Tau"** → I-c · C-P-I · τ.

> ⚠️ **Exam trap:** To compare two designs *fairly* you must use the **same program** (the same real task). Changing the instruction set can change Ic *and* CPI at the same time, so you can't just compare one factor in isolation.

> 💡 **Working backwards (the exam loves this).** The equation has four quantities (T, Ic, CPI, τ). If you know any three, you can solve for the fourth — just rearrange. The classic question: *"Processor B must finish 20% faster, i.e. in 0.8 × the time — what CPI does it need?"* You set T_B = 0.8 × T_A and solve for CPI_B. Worked fully in `exercises.md`. The trick is always: **write the time equation for each machine, set them in the required ratio, cancel what's equal, solve for the unknown.**

---

## 7. Average CPI — the recipe for a mix of instruction types

**Analogy first.** A shopping basket has cheap and expensive items. The *average* price per item isn't a simple guess — it's each price weighted by how many of that item you bought. Instructions are the same: an ADD might take 1 cycle, a branch 3 cycles. The average CPI weights each type by **how often it runs**.

**The recipe:**

```text
            Σ (CPIᵢ × Icᵢ)            Σ (CPIᵢ × fractionᵢ)
   CPI  =  ─────────────────   =     ── over all classes ──
                  Ic
```

- **CPIᵢ** = cycles for instruction class *i* (e.g. ALU = 1, branch = 3).
- **Icᵢ** = how many of that class ran; **fractionᵢ** = its share of the total (a percentage as a decimal, e.g. 50% = 0.5).
- "Σ" just means "add up over all the classes."
- The two forms are the same thing: divide the counts by Ic and you get the fractions.

**Tiny example:**

| Instr class | CPIᵢ | Fraction |
|---|---|---|
| ALU | 1 | 50% (0.50) |
| Load/Store | 2 | 30% (0.30) |
| Branch | 3 | 20% (0.20) |

→ CPI = 1(0.5) + 2(0.3) + 3(0.2) = 0.5 + 0.6 + 0.6 = **1.7 cycles/instruction** (worked fully in §🔬-B).

> ✍️ **Check yourself:** If you halve the branch CPI from 4 to 2, and branches are 25% of instructions, how much does the average CPI change?
> <details><summary>Reveal answer</summary>Only the branch term changes: it drops by 0.25 × (4 − 2) = <b>0.5 cycles</b>. The other classes are untouched.</details>

---

## 8. Why MIPS (and MHz) can fool you — the recipe `MIPS = f/(CPI×10⁶)`

**MIPS** = **m**illions of **i**nstructions **p**er **s**econd. **MFLOPS** = millions of floating-point operations per second.

**The recipe:**

```text
            Ic              f            clock rate (Hz)
   MIPS = ─────────  =  ───────────  =  ─────────────────
          T × 10⁶        CPI × 10⁶          CPI × 10⁶

   MFLOPS = (number of FP operations) / (T × 10⁶)
```

- The `× 10⁶` is just because MIPS counts in *millions*.
- **Watch the units:** if f is in GHz, that's 10⁹ Hz. So a 3 GHz, CPI 2 chip gives MIPS = 3×10⁹ / (2 × 10⁶) = 1500 MIPS.

**Why it misleads — the everyday version.** MIPS counts *how many instructions per second*, not *how much useful work*. It's like ranking workers by "tasks ticked off per hour" — someone who chops every job into tiny easy steps ticks off more boxes but may finish the real job *later* than someone doing fewer, bigger steps.

| Metric | What it measures | Why it can MISLEAD |
|---|---|---|
| **Clock (MHz/GHz)** | ticks/sec | ignores CPI and Ic — a higher clock can be *slower* per program |
| **MIPS** | instructions/sec | different instruction sets do different work per instruction; rewards lots of *cheap* instructions |
| **MFLOPS** | FP operations/sec | only counts floating-point work; ignores everything else |

> ⚠️ **Exam trap:** **MIPS rewards the wrong thing.** A machine that needs *more* simple instructions to do a job can post a *higher* MIPS while running the program *slower*. Always compare **execution time on the same real program** — that's exactly why SPEC benchmarks exist.

> 🧠 **Memory hook:** MIPS = "**M**eaningless **I**ndicator of **P**rocessor **S**peed."

---

## 9. Amdahl's Law — the speed limit on parallelism

**Analogy first.** You and 9 friends want to read a 100-page book faster by splitting it up. But suppose 10 pages can only be read by you (a foreword only you can understand). No matter how many friends help with the other 90 pages, *you* still have to read those 10 pages alone — that part sets a floor on the total time. Amdahl's Law puts a number on this.

**Plain English.** If only *part* of a program can be sped up, the part you *can't* speed up limits the whole thing. Even with infinite help, you can't go faster than the serial (unimprovable) part allows.

**The recipe:**

```text
 ┌────────────────────────────────────────────────────────┐
 │                              1                          │
 │  Speedup  =  ─────────────────────────────────          │
 │                 (1 − f)  +  f / k                       │
 └────────────────────────────────────────────────────────┘
```

- **f** = the **fraction** that benefits from the enhancement (e.g. parallelisable), as a decimal.
- **(1 − f)** = the fraction that does **not** benefit — the *serial* part.
- **k** = how many times faster you make the enhanced part (e.g. number of processors).
- **Speedup** = old time ÷ new time (no units, e.g. "2.5×").

**The ceiling (let k → ∞):**

```text
   As k → ∞ :   Speedup_max = 1 / (1 − f)   ← the SERIAL part caps you
```

**Tiny example:** f = 0.5 (half is parallelisable). Even with infinite processors, max speedup = 1/(1−0.5) = **2×**. Half the work never sped up, so you can at best double.

```text
 Speedup
  20 ┤                                   ........  f=0.95  (cap 20×)
  16 ┤                          .........
  12 ┤                  ........
   8 ┤            ......------------------------  f=0.90  (cap 10×)
   5 ┤      ..---/  ____________________________  f=0.75  (cap 4×)
   2 ┤  .--/__/----------------------------------  f=0.50  (cap 2×)
   1 ┼────┬────┬────┬────┬────┬────┬────┬────► k (processors)
      1    4    8   16   32   64  128  256
   Note: every curve FLATTENS — adding cores gives diminishing returns.
```

The diagram shows: as you add processors (move right), each curve rises but then **flattens** to its ceiling. More cores = less and less extra benefit.

> 🧠 **Memory hook:** "**The serial part is the ceiling.**" Even infinite cores can't beat 1/(1−f).

> ⚠️ **Exam trap:** If only **90%** is parallel, the *absolute max* speedup is **10×**, no matter how many cores. People wrongly expect 100 cores → 100×.

> ✍️ **Check yourself:** 95% of a program is parallelisable. Maximum possible speedup?
> <details><summary>Reveal answer</summary>1/(1−0.95) = 1/0.05 = <b>20×</b> (only with infinite processors).</details>

---

## 10. The three means — pick the right average

**Analogy first.** If you drive 30 km at 30 km/h and 30 km at 60 km/h, your *average speed* is **not** (30+60)/2 = 45. It's lower, because you spend more time at the slow speed. Averaging things wrongly gives wrong answers — so the *type* of data decides the *type* of average.

**The three recipes:**

```text
 Arithmetic:  AM = (1/n) Σ xᵢ                 — average of values/TIMES
 Harmonic:    HM = n / Σ(1/xᵢ)                 — average of RATES (e.g. MIPS, MFLOPS)
 Geometric:   GM = (Π xᵢ)^(1/n) = ⁿ√(x₁·…·xₙ)  — average of RATIOS / normalized scores
```

- **n** = how many numbers; **Σ** = "add them up"; **Π** = "multiply them together."
- **AM** = ordinary average (add, divide by n).
- **HM** = add the *reciprocals*, divide n by that. Used for rates.
- **GM** = multiply all values, take the n-th root. Used for normalised ratios.

| Mean | Use it for… | Why (plain English) |
|---|---|---|
| **Arithmetic** | execution **times** (absolute seconds) | total time = n × AM, which is meaningful |
| **Harmonic** | **rates** (MIPS, MFLOPS, throughput) | a rate is work/time; averaging rates correctly needs HM |
| **Geometric** | **normalised ratios** (SPEC speed/rate ratios) | the answer doesn't depend on which machine you picked as the reference |

**A property worth memorising:** **HM ≤ GM ≤ AM** (they're equal only if all the values are identical).

> ⚠️ **Exam trap:** **Never average rates with the arithmetic mean**, and **never average normalised SPEC ratios with the arithmetic mean** — the "winner" would change depending on which reference machine you chose. SPEC uses the **geometric mean** of ratios precisely to avoid that bias.

> 🧠 **Memory hook:** **"Times → Arithmetic, Rates → Harmonic, Ratios → Geometric"** (T-A, R-H, R-G).

---

## 11. Benchmarks & SPEC — comparing machines fairly

A **benchmark** is a standard test program used to compare computers. A *good* one is **high-level (portable across machines)**, **representative** of real work in some domain, **easy to measure**, and **widely used**. **SPEC** (the System Performance Evaluation Corporation) is the industry group that maintains the most respected **benchmark suites**.

**SPEC CPU2017** — a processor-intensive suite (it tests compute, not disk/I-O): **20 integer + 23 floating-point** benchmarks in C, C++, and Fortran; over 11 million lines of code; most come in both a **rate** and a **speed** version.

| SPEC term | Meaning (plain English) |
|---|---|
| **Reference machine** | the baseline machine; its run time per benchmark is the "reference time" |
| **Ratio** | reference time ÷ your measured time (bigger = faster) |
| **Base metric** | the required result, using strict compile rules |
| **Peak metric** | an optimised compilation is allowed (tuned for best score) |
| **Speed metric** | time for **one** task (how fast at a single job) |
| **Rate metric** | how many tasks finish per unit time (**throughput**, uses many processors at once) |

The overall SPEC score = **geometric mean** of the per-benchmark ratios (see §10 for *why* GM).

> 🧠 **Memory hook:** **Speed = single race; Rate = how many races at once. Base = strict rules; Peak = tuned.**

---

## 12. Little's Law — counting what's "in the system"

**Analogy first.** Picture a coffee shop. If 2 customers walk in per minute, and each customer spends 5 minutes inside, then on average there are 2 × 5 = **10 customers** in the shop at any moment. That's Little's Law.

**The recipe:**

```text
   L = λ × W
```

- **L** = average number of items in the system (customers in the shop, requests in a server).
- **λ** (lambda) = average **arrival rate** (items per second).
- **W** = average **time** each item spends in the system (seconds).

It applies to queues, network buffers, pipelines — anything where things arrive, stay a while, then leave.

> 🧠 **Memory hook:** "Things inside = how fast they arrive × how long they stay."

---

## 🔬 Worked Examples

### A. CPU time from the equation
A program executes **Ic = 5 × 10⁹** instructions, average **CPI = 2.5**, on a **2 GHz** CPU. Find CPU time.
```text
 Step 1 — clock cycle time:   τ = 1/f = 1/(2×10⁹) = 0.5 ns = 0.5×10⁻⁹ s
 Step 2 — plug into T = Ic × CPI × τ:
          T = 5×10⁹ × 2.5 × 0.5×10⁻⁹ s
            = 5×10⁹ × 1.25×10⁻⁹            (multiply CPI × τ first)
            = 6.25 s
```
**CPU time = 6.25 seconds.** (Cross-check via cycles: N = Ic × CPI = 1.25×10¹⁰ cycles; ÷ f = 1.25×10¹⁰ / 2×10⁹ = 6.25 s. ✓)

### B. Average CPI from an instruction mix
| Class | CPIᵢ | Fraction |
|---|---|---|
| ALU | 1 | 0.50 |
| Load/Store | 2 | 0.30 |
| Branch | 3 | 0.20 |
```text
 CPI = (1 × 0.50) + (2 × 0.30) + (3 × 0.20)
     = 0.50 + 0.60 + 0.60
     = 1.70 cycles/instruction
```
**Average CPI = 1.7.**

### C. MIPS rating (and why it deceives)
Same CPU as B at **f = 2 GHz**, CPI = 1.7:
```text
 MIPS = f / (CPI × 10⁶) = 2×10⁹ / (1.7 × 10⁶) = 1176.5 MIPS
```
Now a **2nd machine** runs the *same task* but its instruction set needs **40% more instructions**, each cheaper at CPI = 1.0, same 2 GHz:
```text
 Machine 2 MIPS = 2×10⁹/(1.0×10⁶) = 2000 MIPS   ← higher!
 But compare time via cycles for the same task:
   M1 cycles = Ic·1.7 ;  M2 cycles = 1.4·Ic·1.0 = 1.4·Ic
   1.7·Ic  vs  1.4·Ic  → here M2 is actually FASTER, but if its
   instruction count had grown 80% (1.8·Ic·1.0 = 1.8·Ic), it'd be SLOWER
   while STILL posting 2000 MIPS.
```
**Lesson:** higher MIPS ≠ faster program. Compare **execution time**.

### D. Amdahl's Law — finite and infinite processors
80% of a program is parallelisable (**f = 0.8**).
```text
 With k = 4 processors:
   Speedup = 1 / [ (1−0.8) + 0.8/4 ] = 1 / [0.2 + 0.2] = 1/0.4 = 2.5×
 With k = 8:
   Speedup = 1 / [0.2 + 0.8/8] = 1 / [0.2 + 0.1] = 1/0.3 = 3.33×
 With k → ∞:
   Speedup_max = 1/(1−0.8) = 1/0.2 = 5×
```
**4 cores → 2.5×, 8 cores → 3.33×, ceiling = 5×.** Doubling cores (4→8) only gained 0.83× more — diminishing returns.

### E. Choosing the right mean
Three runs give **rates** 100, 200, 300 MIPS. The correct summary is the **harmonic mean** (they're rates):
```text
 HM = 3 / (1/100 + 1/200 + 1/300) = 3 / (0.01 + 0.005 + 0.00333)
    = 3 / 0.018333 = 163.6 MIPS
 (Arithmetic would wrongly give 200.)
```
For SPEC **ratios** 4.96, 7.29, 5.45 use the **geometric mean** (they're normalised ratios):
```text
 GM = (4.96 × 7.29 × 5.45)^(1/3) = (197.07)^(1/3) ≈ 5.82
```

### F. Amdahl with a hardware enhancement
A new unit makes the FP part (**f = 0.30** of run time) run **k = 10×** faster.
```text
 Speedup = 1 / [ (1−0.30) + 0.30/10 ] = 1/[0.70 + 0.03] = 1/0.73 = 1.37×
```
Only **1.37×** overall — because 70% of the work was untouched. *"Make the common case fast."*

---

## ✅ You now understand…

Take a breath — that's the whole chapter. In plain terms:

1. Apps keep demanding more power, so designers keep pushing performance — but you must **balance** the whole path, not just the CPU.
2. Making one core faster hit physical **walls** (power/heat, RC delay, slow memory) → the industry went **multicore** (then MIC, GPGPU).
3. Real performance comes from **`T = Ic × CPI × τ`** ("I See Pie Times Tau"), with **τ = 1/f**. Units must cancel to **seconds**.
4. **Average CPI** = sum of each class's CPI weighted by its fraction.
5. **MIPS and clock speed mislead** — always compare **execution time on the same real program**.
6. **Amdahl's Law:** Speedup = 1/[(1−f)+f/k]; the ceiling is **1/(1−f)** — the serial part is a hard limit.
7. **Pick the right mean:** Times→Arithmetic, Rates→Harmonic, Ratios→Geometric (SPEC uses GM).
8. **Little's Law:** L = λ × W.

If any of those feels shaky, re-read that section. When they feel comfortable, do `exercises.md`, then test yourself with `mcq.md`.

---

## 🎓 When you're revising for the exam

Everything above is the understanding. For the exam specifically, keep these crisp and ready:

**All the formulas, boxed:**
```text
 ┌──────────────────────────────────────────────────────────────┐
 │ Clock:      τ = 1/f                                            │
 │ CPU time:   T = Ic × CPI × τ = Ic × CPI / f                    │
 │ Cycles:     N = Ic × CPI                                       │
 │ Avg CPI:    CPI = Σ(CPIᵢ × Icᵢ)/Ic = Σ(CPIᵢ × fractionᵢ)       │
 │ MIPS:       MIPS = Ic/(T×10⁶) = f/(CPI×10⁶)                    │
 │ MFLOPS:     MFLOPS = (FP ops)/(T×10⁶)                          │
 │ Amdahl:     Speedup = 1/[(1−f) + f/k]   ;  max = 1/(1−f)       │
 │ Means: AM=(Σxᵢ)/n  HM=n/Σ(1/xᵢ)  GM=(Πxᵢ)^(1/n)               │
 │        Times→AM,  Rates→HM,  Ratios→GM     (HM ≤ GM ≤ AM)      │
 │ Little:     L = λ × W                                          │
 │ SPEC ratio: ref_time / measured_time   (overall = GM of ratios)│
 └──────────────────────────────────────────────────────────────┘
```

**Exam techniques:**
- **Unit-check everything:** seconds = (instr) × (cycles/instr) × (sec/cycle). If it doesn't cancel to seconds, you slipped.
- **MIPS = f/(CPI×10⁶):** convert GHz → ×10⁹ in the numerator; the ×10⁶ is for "millions."
- **Amdahl two-step:** (1) ceiling = 1/(1−f); (2) finite k = 1/[(1−f)+f/k]. Sanity check: the finite answer must be **less than** the ceiling.
- **Mean selection:** times → arithmetic; rates → harmonic; normalised ratios → geometric. Unsure? Ask "is the data a rate?" → if yes, harmonic.
- **Same-program rule:** only compare designs on identical real workloads.
- **Common pitfalls:** comparing MIPS across instruction sets; arithmetic mean on rates/ratios; expecting linear speedup from cores; forgetting τ = 1/f; mixing ns and s; forgetting GHz = 10⁹.

> 🧠 **Mega-mnemonic:** **"I See Pie times Tau"** (T = Ic·CPI·τ), **"serial part is the ceiling"** (Amdahl), **"T-A R-H R-G"** (mean rule), **MIPS = "Meaningless Indicator of Processor Speed."**

**Likely exam question (scenario, working backwards):** *"Processor B must be 20% faster than A (run in 0.8 × A's time) on the same program. A has Ic, CPI 2.0 at 2 GHz; B runs at 2 GHz with the same Ic. What CPI must B have?"*
<details><summary>Model answer</summary>

T_A = Ic × 2.0 / (2×10⁹). Require T_B = 0.8 × T_A, with B at the same f and same Ic.
Since f and Ic are identical, time ∝ CPI. So CPI_B = 0.8 × CPI_A = 0.8 × 2.0 = **1.6 cycles/instruction.**
(General method: write the time equation for each machine, set them in the required ratio, cancel the equal factors, solve for the unknown.)
</details>

---

## 📚 Want to see/hear it explained another way?

- **Stallings, COA 11e — Ch.2 (Performance Concepts):** https://www.pearson.com/en-us/subject-catalog/p/computer-organization-and-architecture/P200000003520
- **Neso Academy — Computer Organization & Architecture playlist:** https://www.youtube.com/playlist?list=PLBlnK6fEyqRgLLlzdgiTUKULKJPYc0A4q
- **Gate Smashers — Amdahl's Law:** https://www.youtube.com/watch?v=QkU5Sg_RJUo
- **Gate Smashers — CPU performance / clock & CPI:** https://www.youtube.com/results?search_query=gate+smashers+cpu+performance+cpi
- **GeeksforGeeks — Computer Organization (Performance, Amdahl, means):** https://www.geeksforgeeks.org/computer-organization-architecture-tutorials/
- **GeeksforGeeks — Amdahl's Law:** https://www.geeksforgeeks.org/computer-organization-amdahls-law-and-its-proof/
- **TutorialsPoint — Computer Organization:** https://www.tutorialspoint.com/computer_organization/index.htm
- **SPEC CPU2017 (official):** https://www.spec.org/cpu2017/
