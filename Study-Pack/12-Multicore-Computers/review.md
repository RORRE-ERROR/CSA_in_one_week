# Chapter 12 — Quick Refresher (Multicore Computers)

> 🌱 Read this in 5 minutes to refresh everything, or the day before the exam. Each idea is given in **plain words first**, then the exam wording.

---

## The big ideas, in plain words

- **Why we went multicore.** One super-fast core stopped working: it got **too hot to clock faster** (the *power wall*), one program only has **so much parallelism** to exploit (the *ILP limit*), and **Pollack's rule** says making a single core more complex gives only the *square root* of the speedup. The fix: use the transistors for **many simpler cores** instead.
- **Three ways to use a chip.** *Superscalar* = one wide core, one program. *SMT* = one core juggling several programs to fill its idle slots. *Multicore* = clone whole cores. Modern chips do all three together.
- **The catch — Amdahl's Law.** Extra cores only help the *parallel* part of a program. The *serial* part can't be sped up, and it sets a hard ceiling on speedup.
- **Caches.** Each core can keep its own *private* cache (fast, isolated) or *share* one (flexible, good for sharing data). Common design: private L1/L2 + a big shared L3. Multiple caches need *coherence* so no core reads stale data.
- **Heterogeneous chips.** Mix core types: *big.LITTLE* (same instruction set, swap a big core for a little one to save power) and *CPU+GPU* (different instruction sets, split work by job). A GPU is a *throughput* processor — many slow cores, great for parallel work.

---

## Why multicore? (3 reasons)
| Reason | One-liner |
|---|---|
| **Power wall** | Dynamic power P ≈ C·V²·f; can't keep raising clock/voltage — too much heat. |
| **ILP limit** | Single-thread instruction-level parallelism is finite; wider/deeper logic → ↓ returns. |
| **Pollack's rule** | Perf ≈ **√(complexity)**. Doubling 1 core's logic → only ~1.4×; better to replicate simpler cores. |
| (+ Memory wall) | DRAM latency lags CPU; favour on-chip shared cache + bandwidth. |

**Net:** spend transistors on **many simpler cores at lower V/f** → better performance-per-watt (only if the software is parallel).

## Alternative chip organisations
| Org | Threads | Idea | Limited by |
|---|---|---|---|
| **Superscalar** | 1 | Issue several instrs/cycle, one thread | ILP of the thread |
| **SMT** | many | Fill idle issue slots from multiple threads, ONE core | Shared core resources |
| **Multicore** | 1/core | Replicate full cores | Software parallelism (Amdahl) |
*(Modern chips = multicore + SMT + superscalar combined.)*

## Cache arrangements (Fig 21.6)
```text
(a) L1 only      (b) +private L2     (c) priv L1/L2 +SHARED L3   (d) +SHARED L2
                                         ← most common today
```
| | Dedicated (private) | Shared |
|---|---|---|
| Latency | low | higher (cores take turns) |
| Interference | none | cores can evict each other |
| Capacity | fixed per core | flexible |
| Shared data | duplicated → more coherence | one copy → easier |

**Coherence** (stops cores reading stale data): **snoopy** (caches listen on a bus) or **directory** (a directory tracks who holds copies); states **MESI** / **MOESI** (Owned = share dirty data without writing back). ARM: **ACE** (supports dissimilar cores → enables big.LITTLE), and the **SCU** keeps L1 coherent.

## Amdahl's Law — multicore
```text
                 1
 Speedup(N) = ───────────         ceiling (N→∞) = 1/(1−f)
              (1−f) + f/N
```
*f* = parallel fraction, *(1−f)* = serial fraction (the cap that no number of cores can beat).

| f | ceiling |
|---|---|
| 0.50 | 2× |
| 0.75 | 4× |
| 0.90 | 10× |
| 0.95 | 20× |

**Reduce (1−f), don't just add cores.** (e.g. f 0.80→0.90 lifts the ceiling from 5× to 10×.)

## Software side
- **Effective apps:** **multi-threaded native** (thread-level), **multi-process** (process-level), **Java** (the JVM is multithreaded), **multi-instance** (virtualization).
- **Granularity:** finer = more flexible but more threading overhead; coarse = low overhead but rigid. **Hybrid** balances them.
- **Scalability** flattens (Fig 21.4) because of the serial fraction + coherence/lock traffic.

## Heterogeneous multicore
- **Same ISA:** ARM **big.LITTLE** (A15 big + A7 LITTLE) — swap cores for power efficiency.
- **Different ISA:** **CPU + GPU** under **HSA** (shared coherent virtual memory + unified programming model).
- **GPU = throughput processor:** many slow cores; wins on data-parallel work. **GFLOPS = clock × cores × FLOPS/core.** AMD A10: CPU **121.6**, GPU **614.4** GFLOPS.

## Examples
- **Intel Core i7-5960X:** 8 cores, private L1/L2, **20 MB shared L3**, SMT, DDR4 controller.
- **ARM Cortex-A15 MPCore:** ≤4 cores, **SCU** (MESI L1 coherence), **GIC** interrupts (Inactive/Pending/Active), DDI, duplicated tag RAMs, migratory lines.
- **IBM z13:** mainframe with a multi-drawer/node cache hierarchy.

## Mnemonics
- **"Square-root one, double two"** → Pollack: replication beats complexity.
- **"Superscalar wide, SMT sneaky-fill, Multicore clone."**
- **"L1 private for speed, L3 shared for sharing."**
- **"The serial tail wags the parallel dog"** → Amdahl ceiling 1/(1−f).
- **"big.LITTLE = same ISA swap; CPU+GPU = different ISA split."**

---

### ⭐ If you only revise 5 things
1. **Why multicore:** power wall (P ≈ C·V²·f) + ILP limit + **Pollack (√complexity)** → many simple cores.
2. **3 orgs:** superscalar (1 thread) → SMT (many threads, 1 core) → multicore (clone cores).
3. **Amdahl:** `1/((1−f)+f/N)`, ceiling **1/(1−f)** — adding cores gives diminishing returns; shrink the serial part instead.
4. **Cache org (c):** private L1/L2 + **shared L3**; coherence via MESI/MOESI, snoopy/directory.
5. **Heterogeneous:** big.LITTLE (same ISA, power) vs CPU+GPU/HSA (different ISA); **GPU = throughput** = clock × cores × FLOPS/core.
