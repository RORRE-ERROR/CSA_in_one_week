# Chapter 11 — Quick Self-Test (Multiple Choice)

> 🌱 **How to use this.** Once you've read `notes.md` and tried `exercises.md`, use these 15 questions to check what stuck. Decide your answer (jot A/B/C/D) **before** opening the explanation. The aim isn't just the right letter — it's understanding *why*, which the explanations spell out in plain words.
>
> Don't stress about your score the first time. Re-take it the day before the exam and aim for 14–15. Flynn and MESI questions are the most likely to appear, so make sure those click.

---

**Q1.** In Flynn's taxonomy, a classic uniprocessor is:
- A) SIMD
- B) MISD
- C) SISD
- D) MIMD

**Q2.** Which Flynn class has **no commercial implementation**?
- A) SISD
- B) SIMD
- C) MISD
- D) MIMD

**Q3.** Vector and array processors belong to which class?
- A) SISD
- B) SIMD
- C) MISD
- D) MIMD

**Q4.** SMPs, clusters, and NUMA systems all fall under:
- A) SISD
- B) SIMD
- C) MISD
- D) MIMD

**Q5.** A defining property of a **tightly coupled** system is:
- A) Communication by message passing
- B) Each processor has its own private main memory
- C) Processors share a common main memory
- D) Nodes are whole computers

**Q6.** The **main drawback** of the SMP shared-bus organisation is:
- A) Poor reliability
- B) Performance limited by bus cycle time
- C) Inability to add processors
- D) Lack of a single OS

**Q7.** In an SMP, the cache-coherence problem is typically addressed:
- A) By the application programmer
- B) In hardware
- C) By the compiler only
- D) By disabling all caches

**Q8.** Snoopy protocols are best suited to:
- A) Large distributed clusters
- B) Bus-based multiprocessors
- C) Single-core systems
- D) NUMA systems with no bus

**Q9.** The write-invalidate snoopy protocol that marks lines Modified/Exclusive/Shared/Invalid is called:
- A) Directory
- B) Write-update
- C) MESI
- D) RWITM

**Q10.** In MESI, the **Exclusive** state means the line is:
- A) Valid, dirty, and present in other caches
- B) Valid, clean (matches memory), and **not** in any other cache
- C) Invalid
- D) Shared with maybe other caches

**Q11.** A write hit to a line in state **Shared** causes:
- A) Nothing; stays Shared
- B) The bus to be signalled, other copies invalidated, this copy → Modified
- C) Immediate transition to Exclusive
- D) A write-back to memory then → Invalid

**Q12.** On a **write miss**, the processor issues a signal called:
- A) RWITM (read-with-intent-to-modify)
- B) Snoop broadcast
- C) Cache flush
- D) Page fault

**Q13.** Simultaneous multithreading (SMT) is best described as:
- A) Switching threads every clock cycle
- B) Running a thread until a stall, then switching
- C) Issuing instructions from multiple threads to a superscalar's units in the same cycle
- D) Replicating the processor on one chip

**Q14.** Which statement about NUMA is correct?
- A) All memory regions have equal access time
- B) Each processor has a separate address space
- C) All processors can access all memory, but access time depends on the region
- D) NUMA requires message passing for all communication

**Q15.** A key benefit of a **cluster** over an SMP is:
- A) Single shared bus simplicity
- B) High availability through whole-computer node failover
- C) Uniform memory access
- D) No need for an operating system

---

## Answers — with the *why*

<details><summary>Q1</summary><b>C) SISD</b> — one instruction stream working on one data stream. A plain single-core machine (one cook, one recipe, one dish) is the textbook SISD.</details>

<details><summary>Q2</summary><b>C) MISD</b> — multiple instruction streams over a single data stream. It's the "imaginary" box; nobody builds real MISD products, so it's the usual trap answer.</details>

<details><summary>Q3</summary><b>B) SIMD</b> — one instruction controls many processing elements in lockstep. Vector and array processors (and GPUs) all fit here: one order, many data lanes doing it together.</details>

<details><summary>Q4</summary><b>D) MIMD</b> — independent instruction *and* data streams. SMPs, clusters and NUMA are all "everyone doing their own thing," so all three are MIMD.</details>

<details><summary>Q5</summary><b>C)</b> Tightly coupled means the processors **share a common main memory** (one address space — one big shared desk). A, B and D all describe loosely coupled clusters (own memory, message passing, whole computers).</details>

<details><summary>Q6</summary><b>B)</b> Every memory reference has to cross the one shared bus, so throughput is capped by **bus cycle time** (one road, everyone on it). Reliability, expandability and the single OS are strengths, not the problem.</details>

<details><summary>Q7</summary><b>B) In hardware</b> — coherence protocols live in the cache hardware and are invisible to software, so the programmer and compiler don't have to manage it.</details>

<details><summary>Q8</summary><b>B)</b> Bus-based multiprocessors — the shared bus is already a cheap way to **broadcast** writes and let every cache **snoop**. Large/NUMA systems have no single bus, so they use **directory** protocols instead.</details>

<details><summary>Q9</summary><b>C) MESI</b> — the write-invalidate protocol whose four states are Modified, Exclusive, Shared, Invalid (that's literally what the letters stand for).</details>

<details><summary>Q10</summary><b>B)</b> Exclusive = valid, **clean** (still matches memory), and held in **no other cache**. The "dirty-and-only-mine" version is Modified, not Exclusive.</details>

<details><summary>Q11</summary><b>B)</b> A Shared line might be in other caches, so before writing you must gain exclusive ownership: signal the bus → other Shared copies go Invalid → your copy goes Shared→Modified.</details>

<details><summary>Q12</summary><b>A) RWITM</b> — read-with-intent-to-modify. It reads the line but warns others you're about to change it; the line is then loaded and immediately marked Modified.</details>

<details><summary>Q13</summary><b>C)</b> SMT issues instructions from *multiple threads* into a superscalar core's execution units in the *same* cycle. (A = fine-grained, B = coarse-grained, D = chip multiprocessing.)</details>

<details><summary>Q14</summary><b>C)</b> In NUMA, every processor can reach all memory via loads/stores, but **access time differs by region** (local fast, remote slow). It keeps a **single** address space; the coherence-maintained version is CC-NUMA.</details>

<details><summary>Q15</summary><b>B)</b> Clusters give **high availability**: they're built from whole computers (nodes), so one node failing doesn't take the service down. They also offer absolute/incremental scalability and good price/performance.</details>

---

> 📊 **Scored low?** Totally normal on a first pass — go back to the matching `notes.md` section (especially Flynn and MESI) and retry. **Scored 13+?** You've got Chapter 11 down.
