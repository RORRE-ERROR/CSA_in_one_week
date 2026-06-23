# Chapter 02 — Quick Self-Test (Multiple Choice)

> 🌱 **How to use this.** Once you've read `notes.md` and tried `exercises.md`, use these 15 questions to check what stuck. Pick an answer in your head (or jot A/B/C/D) **before** opening the explanation. The goal is to understand *why* the right answer is right — the explanations say so in plain words.
>
> Don't worry about your score the first time. Re-take it the day before the exam and aim for 14–15.

---

**Q1.** The CPU performance equation is:
- A. CPU time = Ic / (CPI × τ)
- B. CPU time = Ic × CPI × τ
- C. CPU time = CPI × f / Ic
- D. CPU time = Ic × τ / CPI

**Q2.** For a 4 GHz processor, the clock cycle time τ is:
- A. 4 ns
- B. 0.25 ns
- C. 2.5 ns
- D. 0.4 ns

**Q3.** The main reason the industry shifted from raising clock speed to multicore designs is:
- A. instructions became too long
- B. compilers couldn't keep up
- C. power density / heat dissipation (the power wall) plus RC delay and memory lag
- D. caches became unnecessary

**Q4.** To average a set of **rates** (e.g., MIPS values), you should use the:
- A. arithmetic mean
- B. harmonic mean
- C. geometric mean
- D. median

**Q5.** SPEC computes its overall benchmark score using the ________ of the ratios because it is independent of the reference machine:
- A. arithmetic mean
- B. harmonic mean
- C. geometric mean
- D. weighted sum

**Q6.** A program executes 4×10⁹ instructions at CPI = 1.5 on a 2 GHz CPU. The CPU time is:
- A. 1.5 s
- B. 3.0 s
- C. 6.0 s
- D. 12.0 s

**Q7.** Instruction mix: 50% @ CPI 1, 30% @ CPI 2, 20% @ CPI 5. The average CPI is:
- A. 1.7
- B. 2.0
- C. 2.1
- D. 2.6

**Q8.** A program is 90% parallelizable. The maximum possible speedup (infinite processors) is:
- A. 9×
- B. 10×
- C. 90×
- D. unbounded

**Q9.** With f = 0.8 parallelizable and k = 4 processors, Amdahl's Law gives a speedup of:
- A. 2.0×
- B. 2.5×
- C. 3.2×
- D. 4.0×

**Q10.** Which statement about MIPS is TRUE?
- A. Higher MIPS always means faster program execution
- B. MIPS is comparable across all instruction set architectures
- C. MIPS can be misleading because instructions do different amounts of work
- D. MIPS already accounts for instruction count of the task

**Q11.** Computed as f/(CPI×10⁶): a 3 GHz CPU with CPI = 2.0 has a MIPS rating of:
- A. 600 MIPS
- B. 1000 MIPS
- C. 1500 MIPS
- D. 6000 MIPS

**Q12.** In SPEC terminology, the **rate** metric measures:
- A. time to run a single task
- B. throughput — how many tasks completed in a time, using multiple processors
- C. the clock frequency
- D. the geometric mean of cycle times

**Q13.** Which set of system attributes affects **CPI and the clock rate** (per Table 2.1)?
- A. instruction set architecture
- B. compiler technology
- C. processor implementation and cache/memory hierarchy
- D. application source language only

**Q14.** Three runs take 2 s, 4 s, and 6 s. The correct mean for summarizing these **times** is the arithmetic mean, which equals:
- A. 3.27 s
- B. 4.0 s
- C. 3.0 s
- D. 12.0 s

**Q15.** Little's Law states that the average number of items in a stable system equals:
- A. arrival rate ÷ service time
- B. arrival rate × average time in system (L = λW)
- C. service time × throughput
- D. throughput ÷ arrival rate

---

## Answers — with the *why*

<details><summary>Q1</summary><b>B.</b> CPU time = Ic × CPI × τ (= Ic × CPI / f). Think "time = how many instructions × cycles each × seconds per cycle." The units cancel to seconds, which is the giveaway that this is the right form.</details>

<details><summary>Q2</summary><b>B.</b> τ = 1/f, and f and τ are reciprocals. τ = 1/(4×10⁹) = 0.25 ns. (Remember GHz = 10⁹.)</details>

<details><summary>Q3</summary><b>C.</b> You can't keep raising the clock without the chip overheating — that's the "power wall." RC delay (thinner, closer wires slow signals) and memory lagging the CPU pile on. So designers added more cores instead.</details>

<details><summary>Q4</summary><b>B.</b> Rates are work/time, so you must use the **harmonic mean** to keep total-work-over-total-time correct. The arithmetic mean would overstate the throughput.</details>

<details><summary>Q5</summary><b>C.</b> SPEC uses the **geometric mean** of normalised ratios. It's reference-machine-independent (GM of ratios = ratio of GMs), so the ranking of machines doesn't change if you pick a different baseline.</details>

<details><summary>Q6</summary><b>B.</b> T = Ic × CPI / f = 4×10⁹ × 1.5 / (2×10⁹) = 6×10⁹ / 2×10⁹ = <b>3.0 s</b>.</details>

<details><summary>Q7</summary><b>C.</b> Weight each CPI by its fraction: CPI = 1(0.5) + 2(0.3) + 5(0.2) = 0.5 + 0.6 + 1.0 = <b>2.1</b>.</details>

<details><summary>Q8</summary><b>B.</b> The ceiling is Smax = 1/(1−f) = 1/(1−0.9) = 1/0.1 = <b>10×</b>. The 10% serial part you can't parallelise caps the whole thing — even with infinite processors.</details>

<details><summary>Q9</summary><b>B.</b> S = 1/[(1−0.8)+0.8/4] = 1/[0.2+0.2] = 1/0.4 = <b>2.5×</b>. (And it's below the 5× ceiling, as it must be.)</details>

<details><summary>Q10</summary><b>C.</b> MIPS just counts instructions per second, but instructions do different amounts of work — so a higher-MIPS machine can run a real program <i>slower</i>. Compare execution time, not MIPS. (A, B, D are all the myths MIPS encourages.)</details>

<details><summary>Q11</summary><b>C.</b> MIPS = f/(CPI×10⁶) = 3×10⁹/(2.0×10⁶) = <b>1500 MIPS</b>. (GHz → 10⁹ on top; the 10⁶ is the "millions.")</details>

<details><summary>Q12</summary><b>B.</b> The **rate** metric is a throughput measure — how many tasks finish per unit time, running several at once across multiple processors. (The **speed** metric is the time for a single task.)</details>

<details><summary>Q13</summary><b>C.</b> Per Table 2.1, **processor implementation** and **cache & memory hierarchy** affect CPI and the clock rate. (The instruction set and the compiler instead affect Ic and CPI.)</details>

<details><summary>Q14</summary><b>B.</b> These are absolute **times**, so use the arithmetic mean: AM = (2+4+6)/3 = 12/3 = <b>4.0 s</b>.</details>

<details><summary>Q15</summary><b>B.</b> Little's Law: <b>L = λ × W</b> — average items in the system = arrival rate × average time each item spends in it.</details>

---

> 📊 **Scored low?** That's normal on a first pass — go back to the matching `notes.md` section for anything you missed, then retry. **Scored 13+?** You've got Chapter 2 down. This is a final-exam carryover topic, so make sure the formulas are automatic.
