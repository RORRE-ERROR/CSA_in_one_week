# Chapter 12 — Quick Self-Test (Multiple Choice)

> 🌱 **How to use this.** Once you've read `notes.md` and tried `exercises.md`, use these 15 questions to check what stuck. Pick an answer in your head (or jot A/B/C/D) **before** opening the explanation. Aim to understand *why* the right answer is right — the explanations say so in plain words.
>
> Don't worry about your score the first time. Re-take it the day before the exam and aim for 14–15.

---

**Q1.** Pollack's rule states that the performance increase of a single core is roughly proportional to:
- A. the square of the increase in logic complexity
- B. the increase in logic complexity
- C. the square root of the increase in logic complexity
- D. the cube of the clock frequency

**Q2.** The "power wall" that limited single-core scaling arises mainly because dynamic power is approximately proportional to:
- A. f only
- B. C·V²·f
- C. 1/f
- D. the number of cores

**Q3.** In which chip organisation does a single core fill its issue slots with instructions from several threads in the same cycle?
- A. Superscalar
- B. Simultaneous multithreading (SMT)
- C. Multicore
- D. Scalar pipeline

**Q4.** A superscalar (single-thread) core's performance is fundamentally limited by:
- A. the number of cores
- B. cache coherence traffic
- C. the instruction-level parallelism available in the thread
- D. the GPU clock

**Q5.** A program is 90% parallelizable. Its maximum speedup as the number of cores → ∞ is:
- A. 9×
- B. 10×
- C. 90×
- D. unbounded

**Q6.** Using Amdahl's Law with f = 0.75, the speedup on 4 cores is closest to:
- A. 1.60×
- B. 2.29×
- C. 3.00×
- D. 4.00×

**Q7.** In the most common modern arrangement (Fig. 21.6c), which cache is shared across all cores?
- A. L1
- B. L2
- C. L3
- D. None — all are private

**Q8.** A key advantage of a **shared** last-level cache over **dedicated** caches is:
- A. lower access latency in all cases
- B. flexible capacity allocation and one copy of shared data
- C. no need for any coherence
- D. it eliminates main memory

**Q9.** ARM big.LITTLE is an example of heterogeneous multicore in which the core types:
- A. use different instruction set architectures
- B. share the same ISA but differ in microarchitecture/power
- C. are all GPUs
- D. cannot be cache-coherent

**Q10.** Under HSA (Heterogeneous System Architecture), a key feature is:
- A. CPU and GPU each have totally separate, non-coherent memories
- B. the entire virtual memory space is visible to both CPU and GPU with coherent caches
- C. the GPU cannot access main memory
- D. only the GPU runs the operating system

**Q11.** From Table 21.1 (AMD A10): GPU = 0.8 GHz, 384 cores, 2 FLOPS/core. Its throughput is:
- A. 121.6 GFLOPS
- B. 307.2 GFLOPS
- C. 614.4 GFLOPS
- D. 768.0 GFLOPS

**Q12.** A GPU is best described as a:
- A. low-latency single-thread processor
- B. throughput processor with many simple cores for data-parallel work
- C. serial control processor
- D. cache-coherence controller

**Q13.** Which is an "effective application" type for multicore listed by Stallings?
- A. Single-threaded batch only
- B. Multi-threaded native, multi-process, Java, and multi-instance applications
- C. Applications that never use threads
- D. Strictly serial cryptographic kernels

**Q14.** The MOESI protocol adds which state versus MESI, allowing dirty data to be shared without an immediate write-back?
- A. Pending
- B. Owned
- C. Forward
- D. Locked

**Q15.** In the ARM Cortex-A15 MPCore, the unit responsible for maintaining L1 cache coherence among cores is the:
- A. GIC (Generic Interrupt Controller)
- B. SCU (Snoop Control Unit)
- C. DDR4 memory controller
- D. JVM

---

## Answers — with the *why*

<details><summary>Q1</summary><b>C</b> — Pollack's rule: performance ≈ √(complexity). So doubling a core's logic gives only ~1.4× the speed — a poor return. That's exactly why we replicate into several simpler cores instead.</details>

<details><summary>Q2</summary><b>B</b> — Dynamic power P ≈ C·V²·f. Raising the frequency (and the voltage needed to support it) makes heat unsustainable. That's the power wall: you can't keep clocking higher.</details>

<details><summary>Q3</summary><b>B</b> — SMT (simultaneous multithreading) pulls instructions from several threads into one core's issue slots in the same cycle, filling slots that would otherwise sit idle.</details>

<details><summary>Q4</summary><b>C</b> — A single thread has finite instruction-level parallelism (ILP). Once it runs out, the issue slots go empty no matter how wide the core is.</details>

<details><summary>Q5</summary><b>B</b> — The ceiling is 1/(1−f) = 1/0.10 = 10×. No number of cores can ever exceed it, because the serial 10% can't be sped up.</details>

<details><summary>Q6</summary><b>B</b> — 1/((1−0.75)+0.75/4) = 1/(0.25+0.1875) = 1/0.4375 = 2.29×.</details>

<details><summary>Q7</summary><b>C</b> — Arrangement (c): each core keeps private L1/L2, but they all share one big **L3** — the typical modern layout (e.g. Intel i7).</details>

<details><summary>Q8</summary><b>B</b> — Shared caches let cores use capacity flexibly and keep just one copy of shared data (less duplication, less coherence work at that level). They do NOT remove the need for coherence or memory, and their latency is generally higher — so A, C, D are wrong.</details>

<details><summary>Q9</summary><b>B</b> — big.LITTLE pairs Cortex-A15 (big) with Cortex-A7 (LITTLE): the **same ISA** but different microarchitecture/power profile, swapped by workload (ACE keeps them coherent).</details>

<details><summary>Q10</summary><b>B</b> — HSA gives the CPU and GPU a shared, coherent virtual memory and a unified programming model, so both can work on the same data without copying it back and forth.</details>

<details><summary>Q11</summary><b>C</b> — 0.8 × 384 × 2 = 614.4 GFLOPS (clock × cores × FLOPS-per-core).</details>

<details><summary>Q12</summary><b>B</b> — A GPU trades per-thread latency for aggregate throughput using many simple cores — ideal for massively data-parallel work, not for serial code.</details>

<details><summary>Q13</summary><b>B</b> — Stallings lists multi-threaded native (thread-level), multi-process (process-level), Java (the JVM is multithreaded), and multi-instance (virtualization) applications.</details>

<details><summary>Q14</summary><b>B</b> — The **Owned** state. The owner keeps dirty data and can forward/share it without writing back to memory, while staying responsible for the eventual write-back — saving memory traffic.</details>

<details><summary>Q15</summary><b>B</b> — The **Snoop Control Unit (SCU)** keeps the L1 caches coherent (MESI) and cuts coherence traffic via DDI, duplicated tag RAMs, and migratory lines. The GIC handles interrupts, not coherence.</details>

---

> 📊 **Scored low?** Totally normal on a first pass — go back to the matching `notes.md` section for anything you missed, then retry. **Scored 13+?** You've got Chapter 12 down.
