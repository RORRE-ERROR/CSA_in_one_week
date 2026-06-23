# Chapter 11 — Practice Questions (Parallel Processing)

> 🌱 **How to use this file.** Read `notes.md` first. Then try each question **on your own** before opening the solution — even a rough attempt cements the idea far better than reading the answer. Peeking early feels productive but teaches you less. Getting them wrong is completely fine; that's how you find your gaps.
>
> Questions go **easy → harder**: first quick *recall* of Flynn and SMP, then *applying* coherence and MESI, then a couple of longer *exam-style* ones.

---

## Warm-up: can you remember the basics?

### Q1. Flynn classification — rapid fire
Classify each: (a) a 1990s single-core desktop; (b) a GPU running one shader over a million pixels; (c) a 32-core database server; (d) a hypothetical machine where one data stream passes through processors each running a different program.

<details><summary>Show answer</summary>

(a) **SISD** — single instruction stream, single data stream (uniprocessor). *One cook, one recipe, one dish.*
(b) **SIMD** — one instruction applied in lockstep across many data elements. *One order, many workers all doing it at once.*
(c) **MIMD** — independent instruction and data streams per core. *A kitchen of independent cooks.*
(d) **MISD** — multiple instruction streams, single data stream. This is the **empty** category, never commercially built. *The imaginary box.*
</details>

### Q2. Why isn't a multicore CPU "SIMD"?
A student says "my quad-core laptop is SIMD because it has 4 things working at once." Correct them.

<details><summary>Show answer</summary>

SIMD means **one** instruction stream drives **many** data lanes **in lockstep** (e.g. vector/array processors — one boss shouting one order to many workers). A multicore CPU runs **independent instruction streams** on each core — different programs/threads — so it is **MIMD**. "Many units working at once" alone is *not* SIMD; the defining feature of SIMD is a *single* instruction controlling all of them simultaneously.
</details>

### Q3. SMP bus — advantages and the catch
List the three attractive features of the SMP shared-bus organisation, then state its main drawback and the fix (and the new problem the fix creates).

<details><summary>Show answer</summary>

Features: **Simplicity** (simplest multiprocessor approach — one shared road), **Flexibility** (add processors to the bus easily), **Reliability** (bus is passive wiring; one device failing doesn't crash the system).
Drawback: **performance** — all memory references cross the **common bus**, so throughput is limited by **bus cycle time** (one road, everyone driving on it).
Fix: give **each processor its own cache** to reduce trips to memory.
New problem: **cache coherence** — a write in one cache can leave stale copies in the others. Handled in **hardware**.
</details>

---

## Applying it

### Q4. Demonstrate the coherence problem
With write-back caches and no coherence protocol, show a sequence where CPU B reads a stale value of X after CPU A modifies it.

<details><summary>Show answer</summary>

1. X = 5 in main memory.
2. A reads X → A:5. B reads X → B:5, MM:5. (everyone agrees — consistent)
3. A writes X = 9 (write-back, so it just stays in A's cache without telling anyone) → A:9, B:**5 (stale)**, MM:5.
4. B reads its cached X → gets **5**, but the true value is now **9**. Incoherent.

A coherence protocol fixes step 3 by either **invalidating** (write-invalidate / MESI — "throw your copy away") or **updating** B's copy ("here's the new value").
</details>

### Q5. Snoopy vs directory
For (a) a small bus-based SMP and (b) a large CC-NUMA system, which coherence approach fits and why?

<details><summary>Show answer</summary>

(a) **Snoopy** (e.g. MESI write-invalidate). The shared bus is already a cheap **broadcast** channel for announcing writes, and every controller can **snoop** (eavesdrop) on it. Perfect when everyone's on one road.
(b) **Directory**. With many nodes and no single shared bus, shouting to everyone is too expensive; a central **directory** records which caches hold each line and routes coherence traffic *only* where it's needed — this is what CC-NUMA uses.
</details>

### Q6. MESI E vs M
Two cache lines are both "only present in my cache." One is in state E, the other in M. What's the difference, and what happens on a write hit to each?

<details><summary>Show answer</summary>

Both mean **no other cache has the line**. The difference is the **memory copy**: **E (Exclusive) is clean** (memory is up-to-date); **M (Modified) is dirty** (memory is stale, my copy is the only correct one).
Write hit on **E**: silently transition **E→M**, no bus traffic (I'm already the only one — nobody to tell).
Write hit on **M**: just update the data, stays **M** (already exclusive and dirty).
This is exactly why E exists: a private read can later be written with **zero** bus traffic.
</details>

### Q7. MESI trace — two cores
Line L starts uncached. Trace states of Core 0 and Core 1 (I/E/S/M) through:
1) C0 reads L; 2) C1 reads L; 3) C1 writes L; 4) C0 reads L.

<details><summary>Show answer</summary>

| Step | Action | Core 0 | Core 1 | Notes |
|------|--------|--------|--------|-------|
| 1 | C0 reads L | **E** | I | read miss, sole copy → Exclusive |
| 2 | C1 reads L | S | **S** | C0 snoops the read, downgrades **E→S**; C1 loads **S** |
| 3 | C1 writes L | I | **M** | C1 issues RWITM (intent to modify); C0 **S→I**; C1 **S→M** |
| 4 | C0 reads L | S | S | C0 read miss; C1 snoops, **writes back** L (M→S) & supplies data; C0 loads **S** |

Invariant held: never two M/E copies at once; while C1 was M, memory was stale until the write-back in step 4.
</details>

### Q8. RWITM
What is RWITM, when is it issued, and what state does the line end up in?

<details><summary>Show answer</summary>

**Read-With-Intent-To-Modify**. Issued on a **write miss**: the processor must first read the line from memory, but it announces "I'm about to change this," so other caches **invalidate** their copies (or a Modified holder writes back first). Once loaded, the line is **immediately marked Modified (M)**.
</details>

### Q9. Multithreading approaches
Match: (i) switch thread every clock cycle; (ii) run a thread until a stall then switch; (iii) issue instructions from several threads to a superscalar's units in the same cycle; (iv) replicate the whole processor on one chip.

<details><summary>Show answer</summary>

(i) **Interleaved / fine-grained** (switch every cycle).
(ii) **Blocked / coarse-grained** (switch only when a thread stalls).
(iii) **Simultaneous multithreading (SMT)** — e.g. Hyper-Threading (multiple threads issue in the *same* cycle).
(iv) **Chip multiprocessing (CMP)** — multicore (whole extra processors on the chip).

Bonus: **implicit** multithreading extracts multiple threads from a *single sequential program* (compiler-static or hardware-dynamic); all four above are **explicit** approaches (real, separate threads).
</details>

---

## Exam-style (a bit longer)

### Q10. SMP vs cluster decision
You need (a) maximum availability for a web service across a data center, and (b) a single tightly-integrated number-crunching box with one OS. Pick SMP or cluster for each and justify.

<details><summary>Show answer</summary>

(a) **Cluster** — built from **whole computers (nodes)**; if one node fails, the others carry on → **high availability**, plus absolute/incremental scalability and good price/performance. Ideal for servers.
(b) **SMP** — multiple similar processors sharing memory and I/O under a **single integrated OS** in one machine; the simplest tightly-coupled organisation, with low-latency shared-memory communication. (Drawback to remember: bus-bandwidth scaling limit.)
</details>

### Q11. UMA vs NUMA vs cluster address space
Classify each by memory model: (a) bus SMP; (b) CC-NUMA; (c) Beowulf cluster. State whether each has a single shared address space and how processors communicate.

<details><summary>Show answer</summary>

(a) **SMP = UMA**: single shared address space; **uniform** access time (all memory equally close); processors communicate via **shared memory** over the bus.
(b) **CC-NUMA**: single (global) shared address space, but **non-uniform** access time (local memory fast, remote memory slow); communicate via shared memory over the interconnect; caches kept coherent by a **directory**. If too many accesses are **remote**, performance breaks down.
(c) **Cluster**: **multiple** address spaces (one per node); communicate by **message passing**; no shared cache lines, so no cross-node coherence problem.
</details>

### Q12. MESI write hit on Shared
Line L is in state **S** in both Core 0 and Core 1. Core 0 performs a write hit. Walk through what happens.

<details><summary>Show answer</summary>

Because the line is **Shared**, Core 0 can't just change it — it must first grab **exclusive ownership**:
1. Core 0 signals its intent on the **bus**.
2. Core 1 (holding S) **snoops** the signal and transitions its copy **S→I** (invalidate — throws its copy away).
3. Core 0 performs the update and transitions **S→M** (Modified).

Result: Core 0 = **M**, Core 1 = **I**. The memory copy is now stale (only Core 0 has the truth).
</details>
