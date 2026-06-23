# Chapter 10 — Pipelining · Quick Self-Test (Multiple Choice)

> 🌱 **How to use this.** Once you've read `notes.md` and tried `exercises.md`, use these 15 questions to check what stuck. Pick an answer in your head (or jot A/B/C/D) **before** opening the explanation. The goal isn't the score — it's understanding *why* the right answer is right, which the explanations spell out in plain words.
>
> Don't worry about your score the first time. Re-take it the day before the exam and aim for 14–15.

---

**Q1.** The six stages of the Stallings instruction pipeline, in order, are:
- A. FI, CO, DI, FO, EI, WO
- B. FI, DI, CO, FO, EI, WO
- C. DI, FI, FO, CO, EI, WO
- D. FI, DI, FO, CO, WO, EI

**Q2.** Pipelining primarily improves:
- A. The latency of a single instruction
- B. Instruction throughput
- C. Memory capacity
- D. Cache hit rate

**Q3.** For a k-stage pipeline running n instructions (no hazards), the number of clock cycles is:
- A. n · k
- B. k + n
- C. k + (n − 1)
- D. n − (k − 1)

**Q4.** (numerical) A 5-stage pipeline runs 25 instructions with no hazards. Total cycles =
- A. 29
- B. 30
- C. 125
- D. 25

**Q5.** (numerical) Using the data in Q4, the speedup over a non-pipelined design is approximately:
- A. 5.00
- B. 4.31
- C. 3.50
- D. 6.25

**Q6.** As n → ∞, the speedup of a k-stage pipeline approaches:
- A. 2k
- B. k
- C. k²
- D. unlimited

**Q7.** A hazard caused by two instructions needing the same hardware resource in the same cycle is a:
- A. Data hazard
- B. Control hazard
- C. Structural hazard
- D. Branch hazard

**Q8.** `ADD R1,R2,R3` followed by `SUB R4,R1,R5` creates which hazard?
- A. WAR
- B. WAW
- C. RAW
- D. Structural

**Q9.** Which data-hazard type is also called an *antidependency*?
- A. RAW
- B. WAR
- C. WAW
- D. RAR

**Q10.** In a simple in-order pipeline, which data hazard can actually occur?
- A. Only WAR
- B. Only WAW
- C. Only RAW
- D. All three equally

**Q11.** Which of these is a **static** branch-prediction strategy?
- A. Branch history table
- B. 2-bit saturating counter
- C. Predict by opcode
- D. Taken/not-taken switch

**Q12.** (numerical) A 6-stage pipeline runs 30 instructions; 5 are taken branches each costing a 3-cycle penalty. Total cycles =
- A. 35
- B. 50
- C. 45
- D. 53

**Q13.** A 2-bit saturating counter in state **11 (strong taken)** sees a single **not-taken** outcome. Its new state and next prediction are:
- A. 00, predict not-taken
- B. 10, predict taken
- C. 01, predict not-taken
- D. 11, predict taken

**Q14.** The technique where the compiler places a useful instruction in the slot immediately after a branch is called:
- A. Loop buffer
- B. Delayed branch
- C. Prefetch branch target
- D. Multiple streams

**Q15.** (numerical) A 4-stage pipeline at 2.5 GHz has a real CPI of 1.25 due to stalls. Effective throughput is about:
- A. 2500 MIPS
- B. 2000 MIPS
- C. 3125 MIPS
- D. 1250 MIPS

---

## Answers — with the *why*

<details><summary>Q1</summary><b>B</b> — FI, DI, CO, FO, EI, WO. In plain words: fetch the instruction, decode it, work out where the operands are, fetch them, execute, write the result. (Mnemonic: <i>Five Dogs Chase Four Energetic Wolves</i>.)</details>

<details><summary>Q2</summary><b>B</b> — Throughput (instructions completed per unit time). A single instruction still passes through every stage, so its own latency is unchanged or slightly worse — the win is in finishing one instruction per cycle once the line is full.</details>

<details><summary>Q3</summary><b>C</b> — The first instruction takes all k cycles to come out (filling the pipe); after that, the remaining n−1 instructions each pop out one cycle later. So k + (n − 1).</details>

<details><summary>Q4</summary><b>A</b> — k + (n−1) = 5 + 24 = 29 cycles. (Don't fall for 125 = n·k, that's the non-pipelined count.)</details>

<details><summary>Q5</summary><b>B</b> — S = nk/(k+n−1) = (25·5)/29 = 125/29 = 4.31. It's just below the 5-stage cap because n is still fairly small.</details>

<details><summary>Q6</summary><b>B</b> — Speedup → k, the number of stages. It's bounded: the best you can do is one instruction per cycle vs k cycles each before, so k is the hard ceiling — never unlimited.</details>

<details><summary>Q7</summary><b>C</b> — Structural (resource) hazard: two jobs want one tool, e.g. a single memory port needed by FI and FO in the same cycle.</details>

<details><summary>Q8</summary><b>C</b> — RAW: SUB tries to read R1 before ADD has finished writing it. Read-after-write = the true (real, unavoidable) dependency.</details>

<details><summary>Q9</summary><b>B</b> — WAR (write-after-read) is the antidependency. (WAW = output dependency; RAW = true dependency.)</details>

<details><summary>Q10</summary><b>C</b> — Only RAW. WAR and WAW need instructions to finish out of program order, which only happens with out-of-order execution / register renaming.</details>

<details><summary>Q11</summary><b>C</b> — Predict-by-opcode is static: the guess is fixed in advance with no runtime history. A, B and D all learn from what branches did before → dynamic.</details>

<details><summary>Q12</summary><b>B</b> — Base = k+(n−1) = 6+29 = 35; stall cycles = 5×3 = 15; total = 35 + 15 = 50. (Always: base cycles + Σ stalls.)</details>

<details><summary>Q13</summary><b>B</b> — From 11, one not-taken decrements to 10 (weak taken) but it still predicts taken. It needs <i>two</i> consecutive misses to flip its prediction — that's the whole point of a 2-bit counter (two strikes to change its mind).</details>

<details><summary>Q14</summary><b>B</b> — Delayed branch: the instruction in the delay slot (right after the branch) executes regardless of the branch outcome, so the compiler fills it with useful work.</details>

<details><summary>Q15</summary><b>B</b> — Effective rate = clock/CPI = 2.5×10⁹ / 1.25 = 2.0×10⁹ = 2000 MIPS.</details>

---

> 📊 **Scored low?** Totally normal on a first pass — go back to the matching `notes.md` section for anything you missed, then retry. **Scored 13+?** You've got pipelining down.
