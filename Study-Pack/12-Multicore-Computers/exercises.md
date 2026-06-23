# Chapter 12 — Practice Questions (Multicore Computers)

> 🌱 **How to use this file.** Read `notes.md` first. Then try each question **on your own** before opening the answer — even a rough attempt helps you remember. Peeking early feels productive but teaches you much less. It's totally fine to get them wrong; that's how you find your gaps.
>
> Questions go **easy → harder**: first some quick recall, then Amdahl number-crunching, then a couple of exam-style reasoning ones.
>
> 🔑 **The one formula you'll keep using:** Amdahl's Law — **Speedup(N) = 1 / [(1 − f) + f/N]**, and the ceiling (best case, infinite cores) = **1/(1 − f)**. Here *f* is the fraction of work that can run in parallel, and *(1 − f)* is the stubborn serial fraction.

---

## Warm-up: recall and concepts

### Q1. Three chip organisations
Classify each and say what limits its performance:
(i) one core issuing 4 instructions/cycle from a **single thread**;
(ii) one core interleaving instructions from **4 threads** into its issue slots;
(iii) **four cores** each running one thread.
<details><summary>Show answer</summary>

- (i) **Superscalar** — one wide core, one thread. Limited by the **ILP** (instruction-level parallelism) available in that single thread; when it runs out, issue slots sit empty.
- (ii) **SMT (simultaneous multithreading)** — one core, many threads filling the empty slots. Limited by **shared core resources / contention**; it raises *throughput*, not single-thread *latency*.
- (iii) **Multicore** — separate cores running in genuine parallel. Limited by how **parallel the software is (Amdahl's Law)** and by memory/cache contention.

Memory hook: *Superscalar wide, SMT sneaky-fill, Multicore clone.*
</details>

### Q2. Threading granularity tradeoff
What is "threading granularity," and when does very **fine** granularity hurt?
<details><summary>Show answer</summary>

**Granularity** = the smallest chunk of work you bother to hand to a separate thread.
- **Finer grain** → more chances to parallelize and more flexibility...
- **...but** the threading overhead (creating, scheduling, and synchronizing threads) grows and eats into the gains.

**Very fine granularity hurts** when the per-task overhead gets close to — or bigger than — the useful work in each tiny task. Then the system spends more time *managing* threads than *computing*. Coarse grain has low overhead but is rigid. **Hybrid threading** (Fig. 21.5) balances the two.
</details>

### Q3. Heterogeneous classification
Classify each as same-ISA or different-ISA heterogeneous, and give the design goal:
(a) ARM **big.LITTLE** (Cortex-A15 + Cortex-A7);
(b) an **APU** combining x86 CPU cores + a GPU under HSA.
<details><summary>Show answer</summary>

- (a) **big.LITTLE = same ISA**, different microarchitecture (A15 = big/fast/power-hungry, A7 = LITTLE/slow/efficient). Goal: **energy efficiency** — light loads run on LITTLE, heavy loads on big; because the ISA matches, tasks move freely between them (ACE coherence makes this possible).
- (b) **CPU+GPU = different ISA** heterogeneous. Goal: **combine the CPU's serial power with the GPU's parallel throughput**, via HSA — shared coherent virtual memory + a unified programming model.

Memory hook: *big.LITTLE = same ISA swap; CPU+GPU = different ISA split.*
</details>

---

## Amdahl number-crunching

### Q4. Amdahl basics
A program is **90% parallelizable** (f = 0.90). Find the speedup on **4** cores and the absolute maximum speedup.
<details><summary>Show answer</summary>

Serial part = 1 − f = 0.10.
- N = 4: Speedup = 1 / (0.10 + 0.90/4) = 1 / (0.10 + 0.225) = 1/0.325 = **3.08×**.
- N → ∞: ceiling = 1/0.10 = **10×**.

So even *infinite* cores never exceed 10× — the serial 10% caps it.
</details>

### Q5. Diminishing returns
For **f = 0.95**, compute speedup at N = 2, 8, 32 and state the ceiling. How much of the ceiling is reached at N = 32?
<details><summary>Show answer</summary>

Serial part = 0.05.
- N = 2: 1/(0.05 + 0.475) = 1/0.525 = **1.90×**
- N = 8: 1/(0.05 + 0.11875) = 1/0.16875 = **5.93×**
- N = 32: 1/(0.05 + 0.0297) = 1/0.0797 = **12.55×**
- Ceiling: 1/0.05 = **20×**.

At N = 32 we've reached 12.55/20 = **63%** of the ceiling — already deep into diminishing returns, even though we've only used 32 of "infinite" cores.
</details>

### Q6. Solving for the parallel fraction
On **8** cores an application achieves a **4×** speedup. What fraction f is parallelizable? (Work backwards through the formula.)
<details><summary>Show answer</summary>

Start from 4 = 1 / [(1 − f) + f/8], so the bottom of the fraction must equal 1/4 = 0.25:

(1 − f) + f/8 = 0.25
1 − f + 0.125f = 0.25
1 − 0.875f = 0.25
0.875f = 0.75
**f = 0.857 (≈ 85.7%)**.

So about 85.7% of the work runs in parallel.
</details>

### Q7. Reduce cores or reduce the serial fraction?
A workload has f = 0.80 and currently runs on 16 cores. A team can either **(A)** double the cores to 32, or **(B)** refactor the code to push f from 0.80 up to 0.90. Which gives more speedup? Compute both.
<details><summary>Show answer</summary>

Baseline f = 0.80, N = 16: 1/(0.20 + 0.80/16) = 1/(0.20 + 0.05) = 1/0.25 = **4.00×**.
- **(A)** f = 0.80, N = 32: 1/(0.20 + 0.80/32) = 1/(0.20 + 0.025) = 1/0.225 = **4.44×**.
- **(B)** f = 0.90, N = 16: 1/(0.10 + 0.90/16) = 1/(0.10 + 0.05625) = 1/0.15625 = **6.40×**.

**Option B wins decisively** (6.40× vs 4.44×). Lesson: shrinking the serial fraction beats throwing more hardware at the problem — the Amdahl ceiling itself rose from 5× to 10×. *The serial tail wags the parallel dog.*
</details>

---

## Reasoning & design tradeoffs

### Q8. Pollack's rule vs replication
You have a transistor budget = 8 units. **Option A:** one core of complexity 8. **Option B:** four cores of complexity 2 each. By **Pollack's rule** (performance ∝ √complexity, with a baseline core of complexity 1 giving performance 1), compare peak performance. Assume the workload is fully parallel for Option B.
<details><summary>Show answer</summary>

- **Option A:** performance = √8 ≈ **2.83×** (but it's just one thread).
- **Option B:** each core's performance = √2 ≈ 1.41×; four cores running fully in parallel → 4 × 1.41 = **5.66×**.

Replication wins by about 2× for the *same* transistor budget — this is the whole reason for going multicore. **Caveat:** this only holds if the software is parallel. For purely serial code, Option A's single strong core may actually win.
</details>

### Q9. Power-per-watt reasoning
Why does running **two cores at frequency f/√2** often beat **one core at frequency f** for parallel workloads, in power terms? (Use P ≈ C·V²·f, and assume voltage V scales with frequency f.)
<details><summary>Show answer</summary>

If V scales roughly with f, then power per core P ∝ V²·f ∝ f³.
- **One core at f:** power ∝ f³, throughput ∝ f.
- **Two cores at f/√2:** per-core power ∝ (f/√2)³ = f³/2.83; two cores → 2·f³/2.83 ≈ **0.71·f³** total power. Throughput ∝ 2·(f/√2) = √2·f ≈ **1.41f**.

So the two slower cores use **less total power** *and* deliver **more parallel throughput** → far better performance-per-watt. This is the power motivation for multicore.
</details>

### Q10. Cache arrangement choice
A mobile SoC runs many independent single-threaded apps that rarely share data. Would you favour **dedicated** or **shared** last-level cache, and why? What if it instead ran one heavily-threaded app with lots of shared data?
<details><summary>Show answer</summary>

- **Independent apps, little sharing → dedicated (private) caches.** They cut inter-core interference and keep latency low. With little shared data, coherence/duplication isn't a concern, and each core gets predictable private space.
- **One heavily-threaded app, lots of sharing → shared last-level cache.** One copy of the shared data (less duplication), flexible capacity for the hungrier threads, and less coherence traffic at the shared level.

**Modern compromise (arrangement c):** private L1/L2 + shared L3 — you get both.
</details>

### Q11. GPU throughput (Table 21.1)
Using the AMD A10-5800K figures — CPU: 3.8 GHz, 4 cores, 8 FLOPS/core; GPU: 0.8 GHz, 384 cores, 2 FLOPS/core — compute the GFLOPS for each and explain why the slower-clocked GPU has higher throughput.
<details><summary>Show answer</summary>

GFLOPS = clock × cores × FLOPS-per-core:
- CPU = 3.8 × 4 × 8 = **121.6 GFLOPS**.
- GPU = 0.8 × 384 × 2 = **614.4 GFLOPS**.

The GPU clock is ~5× slower and each core is weaker, but it has **96× more cores**. For massively data-parallel work, that sheer width dominates → about **5× the CPU's throughput**. It's a **throughput processor**: it trades per-thread latency for total parallel work. Serial or branchy code would still be faster on the CPU.
</details>

### Q12. Coherence reasoning
On a multicore with private L2 caches, two cores both cache the **same** memory block; one core writes to it. What problem arises, and which mechanisms address it? Mention MESI vs MOESI.
<details><summary>Show answer</summary>

**Problem:** cache **incoherence** — after the write, the other core's copy is **stale**; without action it could read invalid (out-of-date) data.

**Mechanisms:** hardware **cache-coherence protocols** —
- **Snoopy** (every cache "listens in" on a shared bus) or **directory** (a directory tracks which cores hold copies).
- **State models:** **MESI** (each block is Modified/Exclusive/Shared/Invalid) — a write invalidates other copies, and to share Modified data it must be written back first. **MOESI** adds an **Owned** state, letting a core keep dirty data and **share it without writing back to memory** (the Owner forwards the data and stays responsible for the eventual write-back), which reduces memory traffic.

ARM's **SCU** keeps the L1 caches coherent (MESI) and uses DDI / migratory lines / duplicated tag RAMs to cut coherence traffic.
</details>
