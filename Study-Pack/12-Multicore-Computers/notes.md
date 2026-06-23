# Chapter 12 — Multicore Computers

> 🌱 **Starting from zero?** Good — this chapter assumes you don't yet know *why* a modern processor has "4 cores" or "8 cores" printed on the box. We'll build the whole story step by step, using everyday comparisons before any technical words. Read it slowly, top to bottom.
>
> ⏱️ Take about 2 hours. The two big ideas to really nail are **Pollack's rule** and **Amdahl's Law** — we'll do both with full worked numbers.
>
> *Maps to Stallings COA 11e **Chapter 21**, "Multicore Computers".*

---

## 🤔 First, why does this chapter exist?

For decades, computers got faster the easy way: chip makers just cranked up the **clock speed** (how many times per second the chip "ticks") and made a single processor smarter and bigger. Then, around the mid-2000s, that trick stopped working. The chip would overheat, and making one core cleverer gave less and less extra speed.

So the industry made a big switch: instead of **one super-fast worker**, put **several ordinary workers** on the same chip. Each one is a **core** — a complete processor. A chip with several is a **multicore** chip.

This chapter answers three questions:
1. **Why** did we have to switch to multicore? (Three "walls" got in the way.)
2. **How** do we arrange multiple cores and their fast memory (caches) on a chip?
3. **What's the catch?** (Spoiler: extra cores only help if the *software* can split its work up — and there's a hard mathematical limit called **Amdahl's Law**.)

By the end you'll be able to, in your own words:
- explain **why** industry moved to multicore (the power wall, the ILP limit, and **Pollack's rule**),
- compare the three ways to use a chip's transistors: **superscalar, SMT, multicore**,
- apply **Amdahl's Law** and explain why adding cores hits a ceiling,
- describe how **caches** are arranged across cores (private vs shared),
- explain **heterogeneous** chips (ARM big.LITTLE, and CPU+GPU).

---

## 🗺️ The big picture in one diagram

```text
  One single fast core ran into 3 "walls":
  ┌──────────────┬───────────────┬────────────────┐
  │ POWER WALL   │  ILP LIMIT    │ MEMORY WALL     │
  │ too hot to   │ one program   │ memory is slow  │
  │ clock faster │ has limited   │ to fetch from   │
  │              │ parallelism   │                 │
  └──────┬───────┴───────┬───────┴───────┬─────────┘
         └───────────────┴───────────────┘
                         │
            Answer: use the transistors for
            MANY SIMPLER cores (Pollack's rule)
                         │
        ┌────────────────┼────────────────┐
   identical cores   private/shared    mixed core types
   (homogeneous)     cache layouts     (big.LITTLE, CPU+GPU)
                         │
          Software must be PARALLEL to benefit
                  → limited by Amdahl's Law
```

**In plain words:** the hardware story is "*more cores, simpler each*." The software story is "*splitting work across cores only pays off up to a hard limit*."

---

## 1. Why Multicore? (Power Wall, ILP Limits, Pollack's Rule)

Imagine a restaurant kitchen with **one super-chef**. To serve more meals you could keep pushing that one chef to work faster and faster — but three problems eventually stop you.

### Problem 1 — The Power Wall (the chef overheats)

The faster a chip "ticks," the more electrical power it burns, and that power turns into **heat**. The rough rule for the power a chip uses while working ("dynamic power") is:

```text
  Dynamic power  P ≈ C · V² · f
```

In plain words: power goes up with the **clock frequency f** (the ticking rate) and, worse, with the **square of the voltage V** (the electrical "push" you need to tick faster). Push both up and the heat explodes — you simply can't cool the chip. That's the **power wall**: you can't keep clocking higher.

> **Jargon unlocked:** *Frequency (f)* = clock ticks per second. *Voltage (V)* = electrical pressure. *Dynamic power* = the power burned doing actual work (separate from "leakage," which is power wasted even while idle).

### Problem 2 — The ILP limit (one recipe can only be split so much)

A single program is a list of instructions. Some of them can run at the same time (e.g. two independent additions), but most depend on earlier results. The amount of "do these at once" opportunity inside one program is called **Instruction-Level Parallelism (ILP)** — and it's *finite*. Building an ever-wider, ever-deeper single core to find more ILP gives **smaller and smaller returns**.

> **Jargon unlocked:** *ILP (Instruction-Level Parallelism)* = how many instructions from one program can be run simultaneously. Real code runs out of it quickly.

### Problem 3 — Complexity costs a lot for a little

Adding more logic to one core to squeeze out that last bit of ILP burns a lot of extra power and design effort for very little speedup.

### Pollack's Rule — the key number

Here's the punchline, named **Pollack's Rule**:

> **Performance increase ≈ √(increase in logic/complexity).**

In plain words: if you make a single core **twice** as complex (twice the transistors/logic), you get only about **1.4× the performance** (because √2 ≈ 1.4). The extra complexity is a *bad investment*.

But if you instead take that same pile of transistors and build **two simpler cores**, you could get up to **~2× the performance** (if the software can use both cores) — for similar power. **Replication is a good investment.**

> 🧠 **Memory hook:** *"Square-root one core, but double two cores."* Pollack says complexity is a bad deal; cloning is a good deal.

> ✍️ **Check yourself:** A core's complexity is increased 4×. By Pollack's rule, what is the single-core speedup?
> <details><summary>Reveal answer</summary>√4 = <b>2×</b> — only double the performance for 4× the logic and power. That's why we'd rather build ~4 simpler cores instead.</details>

---

## 2. Three ways to use the chip: Superscalar vs SMT vs Multicore

You've got a chip full of transistors. There are three different philosophies for using them to run programs faster. Stallings shows these as **Fig. 21.1**.

To picture it: each cycle (clock tick), a core has a few **issue slots** — empty "lanes" where it can start an instruction. Below, each row is one cycle, each box is one slot, and a **letter** marks which thread an instruction came from. **Blank box = a wasted slot** (no work started).

```text
(a) SUPERSCALAR          (b) SIMULTANEOUS         (c) MULTICORE
    (1 thread)               MULTITHREADING           (1 thread/core,
                             SMT (multiple             cores replicated)
                             threads, 1 core)
  Issue slots →           Issue slots →            Core1      Core2
  ┌──┬──┬──┬──┐           ┌──┬──┬──┬──┐           ┌──┬──┐    ┌──┬──┐
c │A │A │  │  │         c │A │B │A │C │         c │A │A │    │B │B │
y ├──┼──┼──┼──┤         y ├──┼──┼──┼──┤         y ├──┼──┤    ├──┼──┤
c │A │  │  │  │         c │B │B │C │A │         c │A │  │    │B │B │
l ├──┼──┼──┼──┤         l ├──┼──┼──┼──┤         l ├──┼──┤    ├──┼──┤
e │A │A │A │  │         e │A │A │C │C │         e │A │A │    │B │  │
  └──┴──┴──┴──┘           └──┴──┴──┴──┘           └──┴──┘    └──┴──┘
  blanks = wasted        fills slots from        true HARDWARE
  issue slots (no        SEVERAL threads →        parallelism: each
  ILP available)         high slot use            core runs a thread
```

In plain words:
- **(a) Superscalar** = *one wide worker*. A single core that can start several instructions per tick, but all from **one program (thread)**. Problem: when that one thread runs out of independent instructions (ILP), the extra slots sit **empty** (the blanks).
- **(b) SMT (Simultaneous Multithreading)** = *one worker juggling several jobs*. Same single core, but it pulls instructions from **several threads at once** to fill those empty slots. The core's parts are *shared*. (Intel calls this **Hyper-Threading**.)
- **(c) Multicore** = *several separate workers*. You **clone** whole cores; each runs its own thread. This is **genuine** parallel hardware.

> **Jargon unlocked:** A *thread* is one independent stream of instructions (roughly, one running task). *Throughput* = total work finished per second. *Latency* = how long one single task takes.

| Organisation | Threads | How it boosts use | Limit |
|---|---|---|---|
| **Superscalar** | 1 | Issue several instructions/cycle from one thread | Bounded by the **ILP** of that thread; empty slots |
| **SMT** | many | Fill empty slots with instructions from other threads (shared execution units) | One core's resources are shared/contended |
| **Multicore** | 1 per core | Replicate whole cores → real parallel execution | Needs **parallel software**; cache/memory contention |

> 🧠 **Memory hook:** **Superscalar = wide; SMT = sneaky fill; Multicore = clone.** Modern CPUs do **all three at once**: several cores, each with SMT, each superscalar.

> ✍️ **Check yourself:** Why does SMT improve **throughput** but not single-thread latency?
> <details><summary>Reveal answer</summary>SMT shares one core's execution units across several threads — it fills idle slots so total work per second rises (throughput up), but no single thread runs any faster (it may even slow down a little due to sharing/contention).</details>

---

## 3. Hardware performance issues: parallelism, complexity & power

Putting the last two sections together — here's the hardware trade-off in picture form:

```text
        Making ONE core more complex
   logic ↑ ───────────────────────────────►  performance ↑ (only √, Pollack)
                                              power ↑↑ (V²·f, very steep)

        Adding MORE cores (replication)
   cores ↑ ──────────────────────────────►   performance ↑ (closer to linear,
                                              IF software is parallel)
                                              power ↑ (gentler per unit of work)
```

Three things to take away:
- **Parallelism & complexity:** past a point, extra single-core complexity buys *little* speedup (Pollack) but *lots* of power.
- **Power:** dynamic power grows with V²·f, and "leakage" power grows too. Many **slower** cores at **lower voltage/frequency** can do the *same total work* for **less power**.
- **Memory:** more cores all want data at once, so they need more **memory bandwidth** (data-delivery rate). The slow path to off-chip memory becomes a bottleneck — which is why chips add a big **shared on-chip cache** (more on caches in §5).

> ⚠️ **Exam trap:** Multicore does **not** "use less power." It gives **better performance-per-watt** — more useful work per unit of power — by running several cores at lower frequency/voltage instead of one core flat-out.

---

## 4. Software performance issues — Amdahl's Law on Multicore

Here's the catch with multicore. All that parallel hardware is **useless if the software can't split its work up.** And even when it can, there's a hard mathematical ceiling. That ceiling is **Amdahl's Law**.

**Analogy:** suppose making a meal takes 1 hour. Some of it (chopping, mixing) can be done by helpers in parallel; but some of it (one pot must simmer for 15 minutes, start to finish) **cannot be sped up** by adding people. No matter how many helpers you hire, you can never finish in under 15 minutes. That fixed 15-minute part is the **serial fraction**, and it caps everything.

Let **f** = the fraction of the work that **can** run in parallel, and **N** = the number of cores:

```text
                       1
  Speedup(N) = ─────────────────────
                (1 − f) + f / N

  (1 − f) = the SERIAL part that no number of cores can speed up.

  As N → ∞ :   Speedup_max = 1 / (1 − f)     ← the hard CEILING
```

In plain words: the parallel part gets divided across N cores (the `f/N`), but the serial part `(1 − f)` stays stuck. As you add infinite cores, `f/N` shrinks to zero and you're left with `1/(1−f)` — the absolute best you can ever do.

**Speedup as you add cores (watch each curve flatten out):**

```text
Speedup
 16 |                                            ........ f=0.95 (ceiling 20)
    |                                  .......''''
 12 |                        ....''''''
    |                 ..'''''
  8 |            ..'''                 ________________ f=0.90 (ceiling 10)
    |        .-''        _______------'
  6 |      .'    ___-----'
    |    .'  __--'              ----------------------- f=0.75 (ceiling 4)
  4 |   /__-'         _____-----'
  2 | /_-'  _____-----' --------------------------------f=0.50 (ceiling 2)
  1 |//-----'
    +---+----+----+----+----+----+----+----+----+----► cores N
    1   2    4    8    16   32   64  128  256  512
```

Notice every curve **flattens**: past a point, doubling the cores adds almost nothing — the serial fraction takes over.

| Cores N | f=0.50 | f=0.75 | f=0.90 | f=0.95 |
|--------:|:------:|:------:|:------:|:------:|
| 1 | 1.00 | 1.00 | 1.00 | 1.00 |
| 2 | 1.33 | 1.60 | 1.82 | 1.90 |
| 4 | 1.60 | 2.29 | 3.08 | 3.48 |
| 8 | 1.78 | 2.91 | 4.71 | 5.93 |
| 16 | 1.88 | 3.37 | 6.40 | 9.14 |
| 64 | 1.97 | 3.77 | 8.77 | 15.42 |
| ∞ (ceiling) | **2.00** | **4.00** | **10.0** | **20.0** |

> ⚠️ **Exam trap:** The maximum speedup is capped at **1/(1−f)** *no matter how many cores you add*. With f = 0.90 you can **never** beat 10×, even with a million cores. Examiners love asking "max speedup as N → ∞."

> 🧠 **Memory hook:** *"The serial tail wags the parallel dog."* Shrinking the serial part `(1−f)` matters far more than adding cores.

> ✍️ **Check yourself:** A program is 80% parallel. What is the absolute maximum speedup?
> <details><summary>Reveal answer</summary>1/(1−0.8) = 1/0.2 = <b>5×</b>, no matter how many cores you throw at it.</details>

### Scalability & which apps actually benefit

- **Scalability** (Stallings Fig. 21.4): real workloads like databases only scale with cores **up to a point**; coordination traffic (cores keeping their data consistent, taking turns at locks) plus the serial fraction flatten the curve.
- **Effective applications for multicore** — the kinds of software that *do* gain:
  - **Multi-threaded native** apps — *thread-level parallelism*: a few processes, each split into many threads.
  - **Multi-process** apps — *process-level parallelism*: many separate single-threaded processes running at once.
  - **Java** apps — the JVM (Java's runtime) is *itself* multi-threaded (handles scheduling + memory management on different threads).
  - **Multi-instance** apps — run many copies, each isolated using **virtualization** (one machine pretending to be many).

### Threading granularity

> **Granularity** = the **smallest chunk of work** you bother to hand off to a separate thread.

- **Finer grain** (tiny chunks) → more places to parallelize, more flexibility — **but** the overhead of creating/scheduling/synchronizing all those threads eats into the gains.
- **Coarser grain** (big chunks) → low overhead, but rigid and fewer chances to parallelize.

```text
 Coarse grain ─────────────────────────────► Fine grain
 low overhead                                 high overhead
 less flexible                                more flexible
```

*Hybrid threading* (Fig. 21.5, the Valve game-engine example) **mixes** coarse and fine grain to get the best of both.

> ✍️ **Check yourself:** When does *very fine* granularity start to hurt?
> <details><summary>Reveal answer</summary>When the per-task overhead (creating/scheduling/synchronizing the thread) gets close to — or bigger than — the actual useful work in each tiny task. Then the system spends more time managing threads than computing.</details>

---

## 5. Multicore organisation variants (how caches are arranged)

Quick refresher: a **cache** is a small, very fast memory that sits close to a core and holds recently-used data, so the core doesn't have to wait for slow main memory. Caches come in levels: **L1** (smallest, fastest, right next to the core), then **L2**, then **L3** (bigger but slightly slower). When you have *several cores*, you have to decide which caches each core keeps to **itself (dedicated/private)** and which they **share**.

Stallings Fig. 21.6 shows four arrangements:

```text
(a) Dedicated L1 only          (b) Dedicated L1 + L2
 ┌────┐ ┌────┐ ┌────┐          ┌────┐ ┌────┐ ┌────┐
 │CPU │ │CPU │ │CPU │          │CPU │ │CPU │ │CPU │
 │ L1 │ │ L1 │ │ L1 │          │ L1 │ │ L1 │ │ L1 │
 └─┬──┘ └─┬──┘ └─┬──┘          │ L2 │ │ L2 │ │ L2 │  ← private L2 each
   └──────┼──────┘             └─┬──┘ └─┬──┘ └─┬──┘
       main memory               └──────┼──────┘
                                     main memory

(c) Dedicated L1/L2 + SHARED L3 (most common today)
 ┌────┐ ┌────┐ ┌────┐
 │CPU │ │CPU │ │CPU │
 │ L1 │ │ L1 │ │ L1 │   ← private L1 (fast, per-core)
 │ L2 │ │ L2 │ │ L2 │   ← private L2
 └─┬──┘ └─┬──┘ └─┬──┘
   └──────┼──────┘
   ┌──────┴──────┐
   │  SHARED L3  │       ← one big L3 for all cores
   └──────┬──────┘
       main memory

(d) Dedicated L1 + SHARED L2
 ┌────┐ ┌────┐ ┌────┐
 │CPU │ │CPU │ │CPU │
 │ L1 │ │ L1 │ │ L1 │
 └─┬──┘ └─┬──┘ └─┬──┘
   └──────┼──────┘
   ┌──────┴──────┐
   │  SHARED L2  │
   └──────┬──────┘
       main memory
```

In plain words: as you go (a) → (b) → (c) → (d), you add more cache and decide where to draw the "private vs shared" line. **(c) — private fast L1/L2 per core plus one big shared L3 — is the most common modern design** (e.g. Intel's chips).

**Why pick dedicated or shared? The trade-off:**

| Aspect | **Dedicated** (private) cache | **Shared** cache |
|---|---|---|
| Interference | None — the core owns it | Cores can evict each other's data |
| Capacity use | Fixed per core; may waste space | Flexible — a busy core can use more |
| Shared data | Each core keeps its own copy → needs **coherence** | One copy → less duplication, easier sharing |
| Coherence traffic | More (copies to keep consistent) | Less for the shared level |
| Latency | Lower (private, close) | Higher (cores must take turns) |

> 🧠 **Memory hook:** **L1 private (speed), L3 shared (capacity & sharing).** Private = fast and isolated; shared = flexible and good for sharing, but cores must arbitrate (take turns).

**Cache coherence — the "stale data" problem.** If two cores each keep their own copy of the same memory block and one core changes its copy, the other core's copy is now **wrong (stale)**. We need a scheme so cores never read out-of-date data. That scheme is **cache coherence**.

- **Hardware approaches:** **Directory** protocols (a central directory tracks who has copies) and **Snoopy** protocols (caches all "listen in" on a shared bus).
- **State models:** **MESI** (each cached block is tagged Modified / Exclusive / Shared / Invalid) and **MOESI**, which adds an **Owned** state — letting a core share *dirty* (modified) data with others **without writing it back to memory first**, saving traffic.
- ARM's **ACE** (AXI Coherency Extensions) supports directory *or* snoopy, and can keep **dissimilar** cores coherent — which is what makes big.LITTLE (§6) possible.

> ✍️ **Check yourself:** Why does arrangement (c) — shared L3 — dominate modern designs?
> <details><summary>Reveal answer</summary>Private L1/L2 give each core fast, contention-free access, while one big shared L3 lets cores flexibly share capacity and keep a single copy of shared data — cutting duplication and slow off-chip traffic. It's the best of both worlds.</details>

---

## 6. Heterogeneous Multicore (big.LITTLE, CPU+GPU / HSA)

So far we assumed all the cores are identical ("homogeneous"). But they don't have to be. **Heterogeneous multicore** puts **different kinds** of cores on the same chip — like a kitchen with both a fast expensive head chef *and* a slow cheap prep cook, and you use whichever fits the job.

There are two flavours:

- **Same instruction set, different build** — e.g. ARM **big.LITTLE**: a fast, power-hungry "**big**" core paired with a slow, efficient "**LITTLE**" core. Both understand the *same* instructions, so you can move a task between them; you pick based on how heavy the work is.
- **Different instruction set entirely** — e.g. **CPU + GPU** on one chip. The CPU handles ordinary serial, decision-heavy code; the **GPU** handles massively parallel number-crunching.

> **Jargon unlocked:** *ISA (Instruction Set Architecture)* = the set of instructions a core understands. Same ISA = code can move between cores; different ISA = each needs its own kind of code.

```text
ARM big.LITTLE                         CPU + GPU (HSA)
┌─────────────┐  ┌─────────────┐       ┌──────────┐  ┌──────────────────┐
│  big core   │  │ LITTLE core │       │   CPU    │  │       GPU        │
│ Cortex-A15  │  │  Cortex-A7  │       │ few fast │  │ hundreds of tiny  │
│ out-of-order│  │  in-order   │       │ cores    │  │ cores (throughput)│
│ high perf   │  │ low power   │       │ serial,  │  │ data-parallel,    │
│ high power  │  │ tiny power  │       │ branchy  │  │ SIMD/SIMT         │
└──────┬──────┘  └──────┬──────┘       └────┬─────┘  └────────┬─────────┘
       └── same ISA ────┘                   └─── shared virtual ───┘
        ACE cache coherence                  memory (HSA), coherent
   Heavy load → big core(s)                  caches, unified prog. model
   Light load → LITTLE core(s)
```

**HSA (Heterogeneous System Architecture)** is the framework that lets the CPU and GPU work together smoothly. Its key features:
- The entire **virtual memory space is visible to both CPU and GPU** (pages brought in as needed) — they can work on the same data without copying it back and forth.
- **Coherent memory** — CPU and GPU caches see an up-to-date view of each other's changes.
- A **unified programming interface** — so a normal CPU-centric program can tap the GPU's parallelism.
- Goal: combine the **CPU's serial strength + the GPU's parallel strength** seamlessly.

> 🧠 **Memory hook:** **big.LITTLE = same ISA, swap for power; CPU+GPU = different ISA, split by job.**

### GPU as a "throughput processor"

A GPU makes the opposite trade-off from a CPU. A CPU has a **few fast** cores (great for one task done quickly). A GPU has **hundreds of slow, simple** cores — terrible for one task, but great when you have *thousands of similar little tasks* (like shading every pixel). It trades **latency** (per-task speed) for **throughput** (total work per second).

**Table 21.1 — AMD A10-5800K operating parameters:**

| Metric | CPU | GPU |
|---|---:|---:|
| Clock (GHz) | 3.8 | 0.8 |
| Cores | 4 | 384 |
| FLOPS/core | 8 | 2 |
| **GFLOPS** | **121.6** | **614.4** |

*Check the maths:* GFLOPS = clock × cores × FLOPS-per-core.
- CPU = 3.8 × 4 × 8 = **121.6 GFLOPS**
- GPU = 0.8 × 384 × 2 = **614.4 GFLOPS**

So the GPU does about **5× the parallel work** of the CPU despite a much slower clock — that's the throughput-processor idea. (*FLOPS = floating-point operations per second; GFLOPS = billions of them.*)

> ⚠️ **Exam trap:** A GPU is **not** "faster" in general — each individual GPU core is slow. It only wins on **massively data-parallel** work; serial, branchy code still belongs on the CPU.

> ✍️ **Check yourself:** From Table 21.1, recompute the GPU GFLOPS.
> <details><summary>Reveal answer</summary>0.8 GHz × 384 cores × 2 FLOPS/core = <b>614.4 GFLOPS</b>.</details>

---

## 7. Real-world examples

```text
INTEL Core i7-5960X (Fig. 21.13)        ARM Cortex-A15 MPCore (Fig. 21.14)
 ┌───┬───┬───┬───┬───┬───┬───┬───┐       ┌────┬────┬────┬────┐
 │C0 │C1 │C2 │C3 │C4 │C5 │C6 │C7 │       │A15 │A15 │A15 │A15 │ up to 4 cores
 │L1 │L1 │L1 │L1 │L1 │L1 │L1 │L1 │       │ L1 │ L1 │ L1 │ L1 │
 │L2 │L2 │L2 │L2 │L2 │L2 │L2 │L2 │       └─┬──┴─┬──┴─┬──┴─┬──┘
 └─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┘         │ Snoop Control Unit (SCU) │
   └───┴───┴─┬─┴───┴───┴───┴───┘         ┌─┴────────── shared L2 ────┘
   ┌─────────┴─────────┐                 │ GIC (interrupt ctrl), DDI,
   │ 20MB SHARED L3     │                 │ duplicated tag RAMs, migratory
   └─────────┬─────────┘                 │ lines, MESI L1 coherence
       DDR4 memory ctrl                  └─ targets SoC/mobile
   8 cores, SMT (16 threads), big shared L3
```

- **Intel Core i7-5960X:** 8 cores, per-core L1/L2, **20 MB shared L3**, SMT (Hyper-Threading → 16 threads), built-in DDR4 memory controller. This is the classic arrangement **(c)** from §5.
- **ARM Cortex-A15 MPCore:** up to 4 A15 cores, a **Snoop Control Unit (SCU)** that keeps the L1 caches coherent (using MESI), a **GIC** (Generic Interrupt Controller, handling interrupt states Inactive/Pending/Active, plus inter-processor interrupts, timers, etc.), a **DDI**, **duplicated tag RAMs**, and **migratory lines** — all tricks to cut coherence traffic. Aimed at mobile/SoC (system-on-chip).
- **IBM z13** (Figs 21.16–21.17): a mainframe with a deep, multi-level cache hierarchy spread across drawers and nodes — shared-cache organisation taken to the extreme.

---

## 🔬 Worked Example — Amdahl's Law on Multicore

**Problem:** An application is **75% parallelizable** (f = 0.75). Compute the speedup on **2, 4, 8, 16** cores and the absolute maximum. Show the diminishing returns.

**Formula:** Speedup(N) = 1 / [ (1 − f) + f/N ], with the serial part (1 − f) = 0.25.

```text
N = 2 :  1 / (0.25 + 0.75/2)  = 1 / (0.25 + 0.375) = 1/0.625 = 1.60×
N = 4 :  1 / (0.25 + 0.75/4)  = 1 / (0.25 + 0.1875)= 1/0.4375= 2.29×
N = 8 :  1 / (0.25 + 0.75/8)  = 1 / (0.25 + 0.0938)= 1/0.3438= 2.91×
N = 16:  1 / (0.25 + 0.75/16) = 1 / (0.25 + 0.0469)= 1/0.2969= 3.37×
N →∞ :  1 / (0.25 + 0)        = 1 / 0.25           = 4.00×  ← CEILING
```

**The diminishing returns, made obvious:**

| Step | Cores added | Speedup gained |
|---|---|---|
| 1 → 2 | +1 | +0.60× |
| 2 → 4 | +2 | +0.69× |
| 4 → 8 | +4 | +0.62× |
| 8 → 16 | +8 | +0.46× |
| 16 → ∞ | +∞ | +0.63× (forever!) |

**What it means:** going from 8 → 16 cores **doubles the hardware** for only about 16% more speedup. And even *infinite* cores never get past **4×**, because the serial 25% can't be touched. To do better you must **reduce the serial fraction** — not add cores.

---

## ✅ You now understand…

Take a breath — that was a big chapter. In plain terms:

1. **Why multicore exists:** one fast core hit the **power wall** (P ≈ C·V²·f → too hot), the **ILP limit** (one program has finite parallelism), and **Pollack's rule** (making one core more complex only gives √ the speedup). The fix: **many simpler cores**.
2. **Three ways to use a chip:** **Superscalar** (wide, 1 thread), **SMT** (one core filling slots from many threads), **Multicore** (clone whole cores). Modern chips combine all three.
3. **Amdahl's Law** caps the payoff: `Speedup(N) = 1/[(1−f)+f/N]`, ceiling `1/(1−f)`. The serial fraction wins in the end — adding cores has diminishing returns.
4. **Caches** can be **private** (fast, isolated) or **shared** (flexible, good for sharing). The common design is private L1/L2 + **shared L3**. Multiple caches need **coherence** (MESI/MOESI; snoopy/directory).
5. **Heterogeneous chips** mix core types: **big.LITTLE** (same ISA, swap for power) and **CPU+GPU/HSA** (different ISA, split by job). A **GPU = throughput processor** (many slow cores).

If any of those feels shaky, re-read that section before moving on. When all five feel comfortable, do `exercises.md`, then test yourself with `mcq.md`.

---

## 🎓 When you're revising for the exam

Everything above is the understanding. For the exam, examiners reward precise wording and correct numbers, so keep these crisp:

- **Amdahl drill:** memorise `Speedup(N) = 1/[(1−f)+f/N]`; the ceiling = `1/(1−f)`. **Always state the ceiling when N→∞.**
- **Reading f from words:** "80% of the work can run in parallel" → f = 0.8, serial part = 0.2.
- **Pollack's rule:** *performance ≈ √(complexity factor)* — name it explicitly. Doubling complexity → ~1.4×.
- **Power wall:** dynamic power **P ≈ C·V²·f** — say multicore improves **performance-per-watt**, it does not reduce power outright.
- **Org diagrams:** be ready to sketch **superscalar vs SMT vs multicore**, and the **four cache arrangements (a)–(d)**.
- **GPU GFLOPS:** **clock × cores × FLOPS/core**. (AMD A10: CPU 121.6, GPU 614.4 GFLOPS.)
- **Heterogeneous:** distinguish *same-ISA* (big.LITTLE) from *different-ISA* (CPU+GPU/HSA).
- **Terminology to drop in:** "dedicated/shared cache", "thread-level vs process-level parallelism", "threading granularity", "MESI/MOESI", "SCU", "GIC".

> 🧠 **Mega-mnemonics:**
> - *"Square-root one, double two"* → **Pollack** (replication beats complexity).
> - *"Superscalar wide, SMT sneaky-fill, Multicore clone."*
> - *"L1 private for speed, L3 shared for sharing."*
> - *"The serial tail wags the parallel dog"* → **Amdahl** ceiling 1/(1−f).
> - *"big.LITTLE = same ISA swap; CPU+GPU = different ISA split."*

**Likely exam question:** *"An application is 90% parallelizable. Find the speedup on 4 cores and the maximum possible speedup."*
<details><summary>Model answer</summary>

f = 0.90, so serial part (1−f) = 0.10.
- On N = 4 cores: Speedup = 1 / [0.10 + 0.90/4] = 1 / (0.10 + 0.225) = 1/0.325 = **3.08×**.
- As N → ∞: ceiling = 1/(1−f) = 1/0.10 = **10×**.

So no number of cores can ever push this program past **10× speedup** — the serial 10% caps it.
</details>

---

## 📚 Want to see/hear it explained another way?

- Stallings *COA* 11e — Chapter 21 "Multicore Computers" (textbook & lecture PPT).
- Neso Academy — Multicore Processors / Amdahl's Law: https://www.youtube.com/c/nesoacademy
- Gate Smashers — Multicore Processor & Amdahl's Law: https://www.youtube.com/c/GateSmashers
- GeeksforGeeks — Multi Core Processors: https://www.geeksforgeeks.org/computer-organization-multi-core-processors/
- GeeksforGeeks — Amdahl's Law: https://www.geeksforgeeks.org/computer-organization-amdahls-law-and-its-proof/
- TutorialsPoint — Multicore / Parallel Processing: https://www.tutorialspoint.com/parallel_computer_architecture/index.htm
- ARM big.LITTLE technology: https://www.arm.com/technologies/big-little
