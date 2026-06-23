# Chapter 11 — Quick Refresher (Parallel Processing)

> 🌱 Read this in 5 minutes to refresh everything, or the day before the exam. Each idea is given in **plain words first**, then the exam wording. The two big-money topics are **Flynn's taxonomy** and **MESI** — make sure those feel automatic.

---

## The big ideas, in plain words

- **Why this chapter exists:** one processor can't just keep getting faster (heat/power limits), so we run **many processors at once**. The whole chapter is organised by *do the processors share memory or not?*
- **Flynn's taxonomy** sorts machines by **how many instruction streams × how many data streams**: SISD (one cook, one dish), SIMD (one order, many lockstep workers — GPU/vector), MISD (the imaginary empty box), MIMD (everyone independent — SMP/cluster/NUMA). *Multicore = MIMD; lockstep = SIMD.*
- **Tightly vs loosely coupled** = **share one desk vs separate offices.** Tightly coupled share one main memory (SMP, NUMA); loosely coupled have their own memory and pass messages (clusters).
- **SMP** = a box of **equal** processors sharing memory over one bus, run by one OS. Bus is simple/flexible/reliable but **bandwidth-limited** → add caches → which causes the **coherence problem** (fixed in hardware).
- **Cache coherence** = the "stale photocopy" problem: private copies go out of date when one CPU writes. Fix by **invalidate** ("throw yours away") or **update** ("here's the new value"), using **snoopy** (broadcast on a bus) or **directory** (central lookup) protocols.
- **MESI** = four sticky-note states on each cache line: **M** (I changed it, only mine, memory stale), **E** (only mine, still clean), **S** (several of us share a clean copy), **I** (junk).
- **Multithreading** keeps a processor busy by running several threads so idle hardware gets used.
- **Clusters** = whole computers acting as one → high availability + scalability. **NUMA** = one shared address space but **some memory is far away** (local fast, remote slow); **CC-NUMA** keeps the caches coherent.

---

## Flynn's Taxonomy — 4 classes

| Class | I × D | Meaning | Examples |
|-------|-------|---------|----------|
| **SISD** | 1×1 | single instruction, single data | uniprocessor |
| **SIMD** | 1×N | one instruction, many data in **lockstep** | vector/array processors, GPUs |
| **MISD** | N×1 | many instructions, one data stream | **none built commercially** |
| **MIMD** | N×N | independent instructions & data | **SMP, clusters, NUMA** |

MIMD → **tightly coupled** (shared memory: SMP, NUMA) vs **loosely coupled** (clusters: message passing).

## MESI states — one-liners

- **M (Modified)** — line valid, **dirty** (memory stale), **only my** cache has it; write stays local (no bus).
- **E (Exclusive)** — line valid, **clean** (memory ok), **only my** cache has it; write hit → M, **no bus**.
- **S (Shared)** — line valid, clean, **maybe others** have it; write hit → bus invalidates others, → M.
- **I (Invalid)** — no valid data; read/write here = miss → goes to bus.

**Key transitions:** read miss (no others)→E · read miss (others)→S · write miss = **RWITM**→M · write hit on S → invalidate others, →M · snoop another's read on M → write back, →S · snoop another's write/RWITM → **I**. *Invariant: at most one M or E at a time.*

*Plain version:* if you're the only holder and clean, you're **E**; change it and you're **M**. If others share it you're **S**; to write you must shout "invalidate" first, then become **M**. Overhear someone reading your **M** line → write it back and drop to **S**. Overhear anyone *writing* → you go **I**.

## Coherence solution tree

```text
software (compiler/OS, conservative)   vs   hardware (run-time, transparent)
                                              ├─ snoopy (bus broadcast)
                                              │   ├─ write-invalidate → MESI
                                              │   └─ write-update
                                              └─ directory (central, scales/NUMA)
```

*Plain version:* software solutions play it safe (mark shared data "don't cache") → wasteful. Hardware protocols react only when a clash actually happens → faster and invisible to you. **Snoopy = everyone eavesdrops on the one bus (good for SMP); directory = a central list of who-holds-what (good for NUMA).**

## SMP vs Cluster vs NUMA

| Feature | SMP | Cluster | NUMA / CC-NUMA |
|---------|-----|---------|----------------|
| Coupling | Tight | Loose | Tight |
| Memory | Shared, **UMA** | Per-node private | Shared, **non-uniform** |
| Communicate | Shared mem (bus) | **Message passing** | Shared mem (interconnect) |
| Address space | Single | Multiple | Single (global) |
| Coherence | **MESI/snoopy** | none needed | **directory** (CC-NUMA) |
| Scalability | Bus-limited | High | Higher than SMP |
| Availability | Lower | **High** | Moderate |

**SMP** = ≥2 similar CPUs, shared memory+I/O, bus, **single integrated OS**. Bus pros: simple/flexible/reliable; con: bandwidth → caches → coherence.

## Cluster configs
passive standby · active secondary · separate servers (copy data) · servers connected to disks (takeover) · servers share disks (needs **lock manager**).
*Plain version:* from "spare sits idle" up to "everyone shares the disks at once" — the more they share, the more you need a **lock manager** to stop clashes.

## Multithreading
**Explicit** (real threads): fine-grained (switch/cycle) · coarse-grained (switch on stall) · **SMT** (multi-thread issue/cycle) · **CMP** (multicore). **Implicit**: threads from one sequential program (compiler/hardware). `MIPS = f × IPC`.

## Mnemonics
- **SISD/SIMD/MISD/MIMD**: SI/MI = instruction streams, SD/MD = data streams. **MISD = the imaginary one.**
- **MESI** = **M**ine-dirty, **E**xclusive-clean, **S**hared, **I**nvalid.
- **UMA = Uniform = SMP**; **NUMA = local-fast/remote-slow**.
- Snoopy = **broadcast on bus**; Directory = **central lookup**.

---

### ⭐ If you only revise 5 things
1. **Flynn's 4 classes** + examples, and that **MISD is never built**; multicore = **MIMD**, lockstep = **SIMD**.
2. **SMP** = shared memory + bus + single OS; bus is simple/flexible/reliable but **bandwidth-limited** → caches → **coherence problem** (HW-solved).
3. **MESI** states and transitions: **M dirty-only-mine, E clean-only-mine, S shared, I invalid**; **RWITM** on write miss; write-on-S invalidates others; only one M or E at a time.
4. **Snoopy (MESI, bus, broadcast)** for SMP vs **Directory** for NUMA.
5. **SMP (UMA) vs Cluster (message passing, HA) vs NUMA (single address space, non-uniform access; CC-NUMA = coherent)**.
