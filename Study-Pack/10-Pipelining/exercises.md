# Chapter 10 — Pipelining · Practice Questions

> 🌱 **How to use this file.** Read `notes.md` first. Then try each question **on your own** before opening the solution — even a rough attempt cements it far better than reading the answer. Peeking early feels productive but teaches you much less, and it's totally fine to get them wrong; that's how you find your gaps.
>
> Questions go **easy → harder**: first plug-in-the-formula numbers, then identification, then comparing whole designs and tracing a predictor. Keep these three formulas handy: `cycles = k+(n−1)`, `S = nk/(k+n−1)`, `η = S/k`.

---

### Problem 1 — Basic cycle count (warm-up)
A 5-stage pipeline executes 50 instructions with no hazards. How many clock cycles? How many would a non-pipelined CPU take?
<details><summary>Show answer</summary>

Pipelined: the first instruction needs all 5 stages, then each of the other 49 pops out one cycle later. Non-pipelined: every instruction runs all 5 stages back-to-back.

```text
Pipelined     = k + (n-1) = 5 + 49 = 54 cycles
Non-pipelined = n * k     = 50 * 5 = 250 cycles
```
That gap (54 vs 250) is the overlap doing its job — the assembly line keeps every stage busy.
</details>

---

### Problem 2 — Speedup and efficiency
For Problem 1, compute the speedup and the efficiency.
<details><summary>Show answer</summary>

Speedup = how many times faster the line is than one-at-a-time. Efficiency = how full the pipeline is (speedup ÷ stages).

```text
S = nk/(k+n-1) = (50*5)/54 = 250/54 = 4.63
  (check: 250/54 = 4.63 ✔)
η = S/k = 4.63/5 = 0.926 = 92.6%
```
92.6% means the pipeline slots are almost always doing useful work — very little idle time with 50 instructions.
</details>

---

### Problem 3 — Speedup limit (why bigger n helps)
A 6-stage pipeline. (a) What is the max possible speedup as n→∞? (b) What speedup is achieved for n = 6? (c) For n = 1000?
<details><summary>Show answer</summary>

The cap is always the number of stages, k. Small batches don't reach it because the cost of *filling* the pipe (the first k−1 cycles where it isn't full yet) is a big fraction of the work.

```text
(a) S -> k = 6  (asymptotic limit, never exceeded)
(b) n=6:    S = (6*6)/(6+5)   = 36/11   = 3.27
(c) n=1000: S = (1000*6)/(1005) = 6000/1005 = 5.97  (≈ k, nearly full)
```
Lesson: speedup approaches k only for large n; small batches pay the fill cost.
</details>

---

### Problem 4 — Cycle time with latch overhead
Max stage delay τ = 1.8 ns, latch overhead d = 0.2 ns, k = 4 stages, n = 20. Find pipelined execution time and speedup vs a non-pipelined design whose instruction time = k·τ = 7.2 ns.
<details><summary>Show answer</summary>

Remember the latch overhead d: passing work between stages costs a sliver of time each cycle, so the real cycle time is τ + d, not just τ.

```text
Cycle time = τ + d = 1.8 + 0.2 = 2.0 ns
Pipelined cycles = k+(n-1) = 4+19 = 23
Tk = 23 * 2.0 = 46 ns
Non-pipelined T1 = n * 7.2 = 144 ns
Speedup = 144/46 = 3.13
```
Note the latch overhead is why real speedup < the ideal nk/(k+n−1) you'd get with τ alone.
</details>

---

### Problem 5 — Branch penalty effect
6-stage pipeline, n = 40 instructions, cycle = 1 ns. 25% are taken branches, each flushing 4 instructions (4-cycle penalty). Find total cycles, time, and effective speedup vs non-pipelined (40×6 cycles).
<details><summary>Show answer</summary>

Each taken branch throws away the wrong-path instructions it already fetched — that's the penalty. Add those wasted cycles on top of the base cycle count.

```text
Base cycles      = k+(n-1) = 6+39 = 45
Taken branches   = 0.25*40 = 10
Stall cycles     = 10 * 4 = 40
Total cycles     = 45 + 40 = 85
Time             = 85 * 1 ns = 85 ns
Non-pipelined    = 40*6 = 240 cycles = 240 ns
Effective speedup= 240/85 = 2.82   (vs ideal 240/45 = 5.33)
```
Branches cut the speedup nearly in half — exactly why CPUs work so hard to predict them.
</details>

---

### Problem 6 — Identify the hazard
Classify each:
```text
(a) I1: ADD R1,R2,R3   I2: SUB R4,R1,R5
(b) I1: ADD R3,R1,R2   I2: SUB R1,R6,R7
(c) I1: MUL R5,R0,R0   I2: ADD R5,R8,R9
(d) Two instructions both need the single memory port in the same cycle
```
<details><summary>Show answer</summary>

Look at *which register clashes* and *in what order* it's read vs written. (d) is the odd one out — no register clash, just a hardware clash.

```text
(a) RAW (true)  - I2 reads R1 that I1 writes (read-after-write)
(b) WAR (anti)  - I1 reads R1, I2 writes R1 (read-then-write)
(c) WAW (output)- both write R5 (write-then-write)
(d) Structural (resource) hazard - two jobs, one tool
```
Only (a) and (d) actually stall a simple in-order pipeline; (b) and (c) only appear with out-of-order execution.
</details>

---

### Problem 7 — RAW stall counting
6-stage pipeline (FI DI CO FO EI WO). A result is available after EI (stage 5) and an operand is needed at FO (stage 4) of a dependent instruction. With **no forwarding**, how many bubbles must be inserted between two back-to-back dependent instructions? With forwarding from EI to FO, how many?
<details><summary>Show answer</summary>

The trick is to line up the two instructions cycle-by-cycle and compare *when the answer is ready* against *when it's needed*.

```text
Producer's EI happens in its cycle 5.
Consumer (issued 1 cycle later) reaches FO in its cycle (1+4)=5? 
Align cycles: Producer FI@1..EI@5,WO@6. Consumer FI@2,DI@3,CO@4,FO@5.
Consumer needs operand at FO(c5); producer's EI completes end of c5 -> not ready.
Without forwarding (must wait for WO@6): stall until c7 for FO -> 2 bubbles.
With forwarding (EI result @ end c5 routed to consumer's FO): 1 bubble.
```
Forwarding (handing the result straight over instead of writing it back first) saves a bubble. Exact numbers depend on the model; the *method* is: align the cycles and compare produce-point vs consume-point.
</details>

---

### Problem 8 — 2-bit predictor trace
A 2-bit saturating counter starts at state **00 (strong not-taken)**. A branch's actual outcomes are: **T, T, T, N, T**. List the prediction made and whether it was correct for each, then the resulting state.
<details><summary>Show answer</summary>

Apply the rule each step: predict from the current state, then nudge the state up on T or down on N. Notice how the counter "warms up" — it has to be wrong a couple of times before it learns the branch is usually taken.

```text
Rule: predict T if state∈{10,11}, N if {00,01}; T -> ++ (sat 11), N -> -- (sat 00)

Step Actual State(before) Predict Correct? State(after)
 1     T       00          N       NO       01
 2     T       01          N       NO       10
 3     T       10          T       YES      11
 4     N       11          T       NO       10
 5     T       10          T       YES      11

Correct: 2 / 5 (predictor is warming up; a steady taken loop would soon hit ~100%).
```
See how the single N at step 4 only knocked it from 11 down to 10 — still predicting taken. That's the "two strikes to flip" stability in action.
</details>

---

### Problem 9 — Compare two designs
Design A: 4 stages, cycle 2 ns. Design B: 8 stages, cycle 1.2 ns (deeper but more latch overhead). Run n = 100 instructions, no hazards. Which is faster? Then if Design B suffers 15 taken branches at 6-cycle penalty each, recompute.
<details><summary>Show answer</summary>

Deeper pipelines have shorter cycle times (work split into smaller chunks) but pay a *bigger* penalty per branch, because more wrong-path instructions get flushed. Watch the verdict flip once branches show up.

```text
Design A: cycles = 4+99 = 103;  time = 103*2  = 206 ns
Design B: cycles = 8+99 = 107;  time = 107*1.2 = 128.4 ns  -> B faster

B with branches: stalls = 15*6 = 90 cycles
  cycles = 107 + 90 = 197;  time = 197*1.2 = 236.4 ns
  -> Now A (206 ns) BEATS B. Deeper pipelines pay a bigger branch penalty.
```
This is the real-world trade-off: more stages aren't automatically better once branches are in the picture.
</details>

---

### Problem 10 — Throughput & MIPS
A 5-stage pipeline runs at 2 GHz (cycle = 0.5 ns), CPI = 1 ideal but real CPI = 1.3 due to stalls. What is the effective instruction throughput (MIPS)?
<details><summary>Show answer</summary>

CPI = cycles per instruction. Stalls push the real CPI above the ideal 1, which drags throughput down. Effective rate = clock speed ÷ CPI.

```text
Effective rate = clock / CPI = (2x10^9) / 1.3 = 1.538x10^9 instr/s
             = 1538 MIPS  (≈ 1.54 GIPS)
Ideal (CPI=1) would be 2000 MIPS; stalls cost ~23% throughput.
```
</details>

---

### Problem 11 — Branch-handling match
Match the technique to its description:
```text
1. Loop buffer        a. Compiler fills the slot after the branch with useful work
2. Delayed branch     b. Fetch both the target and fall-through paths in parallel
3. Multiple streams   c. Small fast store of recent sequential instructions
4. Prefetch target    d. Get the branch target early, hold until branch resolves
```
<details><summary>Show answer</summary>

```text
1 -> c   2 -> a   3 -> b   4 -> d
```
Plain-words check: a loop buffer keeps recent code handy (c); a delayed branch hands the compiler a slot to fill (a); multiple streams run both forks at once (b); prefetch-target grabs the jump destination ahead of time and holds it (d).
</details>
