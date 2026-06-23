# Chapter 02 — Practice Questions (Computer Performance)

> 🌱 **How to use this file.** Read `notes.md` first. Then try each question **on your own** — write the formula, plug in the numbers, show your units — *before* opening the solution. A rough attempt teaches you far more than reading the answer. It's completely fine to get them wrong; that's how you find the gaps. Always **show units** so you can catch slips.
>
> Questions go **easy → harder**: first plug-and-chug, then multi-step, then a few tricky scenario ones.

**Key formulas to keep beside you:** `T = Ic × CPI × τ`, `τ = 1/f`, `MIPS = f/(CPI×10⁶)`, `Speedup = 1/[(1−f)+f/k]`, means AM / HM / GM, `L = λW`.

---

## Warm-up: one formula at a time

### Problem 1 — CPU time (basic)
A program runs **Ic = 3 × 10⁹** instructions with **CPI = 2.0** on a **1.5 GHz** processor. Find the CPU time.
<details><summary>Show answer</summary>

**Step 1 — find τ (the cycle time):** τ = 1/f = 1/(1.5×10⁹) = 0.667 ns = 0.667×10⁻⁹ s.

**Step 2 — plug into T = Ic × CPI × τ:**
T = 3×10⁹ × 2.0 × 0.667×10⁻⁹
= 3×10⁹ × 1.333×10⁻⁹  (multiply CPI × τ first)
= **4.0 s**.

**Cross-check via cycles:** N = Ic × CPI = 3×10⁹ × 2 = 6×10⁹ cycles; divide by f: 6×10⁹ / 1.5×10⁹ = 4.0 s. ✓
</details>

---

### Problem 2 — Average CPI from a mix
Instruction mix: ALU 40% @ CPI 1, Load 25% @ CPI 3, Store 15% @ CPI 2, Branch 20% @ CPI 4. Find the average CPI.
<details><summary>Show answer</summary>

Multiply each class's CPI by its fraction, then add them all up:

CPI = (1 × 0.40) + (3 × 0.25) + (2 × 0.15) + (4 × 0.20)
= 0.40 + 0.75 + 0.30 + 0.80
= **2.25 cycles/instruction**.

(Sanity check: the fractions 0.40 + 0.25 + 0.15 + 0.20 = 1.00, so we covered every instruction.)
</details>

---

## Putting pieces together

### Problem 3 — Put it together (CPI → time → MIPS)
Using the mix from Problem 2 (CPI = 2.25), with Ic = 8×10⁸ and clock = 2 GHz. Find (a) CPU time, (b) MIPS.
<details><summary>Show answer</summary>

**(a) CPU time.** First τ = 1/(2×10⁹) = 0.5 ns.
T = Ic × CPI × τ = 8×10⁸ × 2.25 × 0.5×10⁻⁹
= 8×10⁸ × 1.125×10⁻⁹  (multiply CPI × τ first)
= **0.9 s**.

**(b) MIPS.** Use MIPS = f/(CPI×10⁶) = 2×10⁹ / (2.25×10⁶) = **888.9 MIPS**.

**Cross-check:** MIPS = Ic/(T×10⁶) = 8×10⁸ / (0.9×10⁶) = 888.9. ✓ (Both forms agree.)
</details>

---

### Problem 4 — MIPS is misleading
Machine A: 2 GHz, CPI 2.0. Machine B: 2 GHz, CPI 1.0 but needs **2.5×** as many instructions for the same task. (a) MIPS of each. (b) Which finishes the task faster?
<details><summary>Show answer</summary>

**(a) MIPS of each:**
- A: MIPS = f/(CPI×10⁶) = 2×10⁹/(2.0×10⁶) = **1000 MIPS**.
- B: MIPS = 2×10⁹/(1.0×10⁶) = **2000 MIPS** — looks twice as fast!

**(b) Which is actually faster?** Same clock, so we can just compare the **number of cycles** for the task (fewer cycles = faster). Let the task = Ic instructions on A.
- Cycles_A = Ic × 2.0 = **2.0·Ic**.
- On B the same task takes 2.5·Ic instructions, each 1.0 cycle: Cycles_B = 2.5·Ic × 1.0 = **2.5·Ic**.

2.5·Ic > 2.0·Ic, so **A is faster** despite B's higher MIPS.

**Lesson:** MIPS ignores how much work each instruction does. B's instructions are cheaper, but it needs so many more that it loses.
</details>

---

## Amdahl's Law

### Problem 5 — Amdahl, finite cores
A program is **f = 0.6** parallelisable. Find the speedup with k = 2, k = 4, and the maximum.
<details><summary>Show answer</summary>

Here (1 − f) = 0.4 (the serial part). Plug into Speedup = 1/[(1−f) + f/k]:

- **k = 2:** 1/[0.4 + 0.6/2] = 1/[0.4 + 0.3] = 1/0.7 = **1.43×**.
- **k = 4:** 1/[0.4 + 0.6/4] = 1/[0.4 + 0.15] = 1/0.55 = **1.82×**.
- **max (k → ∞):** the f/k term vanishes, so Speedup = 1/(1−0.6) = 1/0.4 = **2.5×**.

Notice each finite answer is below the 2.5× ceiling — that's the sanity check.
</details>

---

### Problem 6 — Amdahl, design the target
You want an overall **4× speedup**. The enhanceable part can be sped up infinitely. What fraction **f** must be enhanced?
<details><summary>Show answer</summary>

"Sped up infinitely" means use the ceiling formula, Smax = 1/(1−f). Set it equal to 4 and solve:

1/(1−f) = 4
⇒ 1 − f = 1/4 = 0.25
⇒ **f = 0.75**.

So at least **75%** of the work must be enhanced — and that's only if you can speed that part up *infinitely*. (With finite speedup you'd need even more.)
</details>

---

### Problem 7 — Amdahl with a specific enhancement
A unit makes the FP portion (**30%** of run time) run **20×** faster. Overall speedup?
<details><summary>Show answer</summary>

Here f = 0.30 (the enhanced fraction), k = 20. Plug in:

Speedup = 1/[(1−0.30) + 0.30/20]
= 1/[0.70 + 0.015]
= 1/0.715
= **1.40×**.

Even a 20× boost on 30% of the work yields only **1.40×** overall — the untouched 70% dominates. *Make the common case fast.*
</details>

---

## Choosing the right average

### Problem 8 — Choosing & computing the mean
Three benchmarks report **rates** of 50, 75, 100 MFLOPS. (a) Which mean is correct and why? (b) Compute it. (c) What would arithmetic give, and why is it wrong?
<details><summary>Show answer</summary>

**(a)** Use the **harmonic mean** — these are *rates* (work per time). Averaging rates with HM keeps "total work ÷ total time" correct; the arithmetic mean would not.

**(b)** HM = n / Σ(1/xᵢ) = 3 / (1/50 + 1/75 + 1/100)
= 3 / (0.02 + 0.01333 + 0.01)
= 3 / 0.04333
= **69.2 MFLOPS**.

**(c)** AM = (50 + 75 + 100)/3 = 75 MFLOPS. It **overstates** throughput because it ignores that the slower runs take *more time* and should weigh more.
</details>

---

### Problem 9 — Geometric mean for SPEC ratios
A machine's SPEC ratios on four benchmarks are 4.0, 8.0, 5.0, 10.0. Compute the overall score (geometric mean) and explain why GM not AM.
<details><summary>Show answer</summary>

GM = (product of all values)^(1/n). With n = 4:

GM = (4.0 × 8.0 × 5.0 × 10.0)^(1/4)
= (1600)^(1/4)
= (1600)^0.25
= **6.32**.

**Why GM, not AM?** These are **normalised ratios**. With the arithmetic mean, the *ranking* of two machines could flip just by changing which machine is the reference — unacceptable. The geometric mean is **reference-independent** (the GM of ratios equals the ratio of GMs), so the verdict is stable. That's why SPEC uses it.
</details>

---

## Tougher: full comparisons & queues

### Problem 10 — Combined comparison
Two CPUs run the **same** program (same task). CPU X: Ic = 6×10⁹, CPI 1.6, 3 GHz. CPU Y: Ic = 6×10⁹, CPI 1.2, 2 GHz. (a) Times. (b) Speedup of faster over slower. (c) Which has higher MIPS, and does that match the timing winner?
<details><summary>Show answer</summary>

**(a) Times** (using T = Ic × CPI / f):
- X: T = 6×10⁹ × 1.6 / (3×10⁹) = 9.6×10⁹ / 3×10⁹ = 9.6/3 = **3.2 s**.
- Y: T = 6×10⁹ × 1.2 / (2×10⁹) = 7.2×10⁹ / 2×10⁹ = 7.2/2 = **3.6 s**.
- X is faster (smaller time).

**(b) Speedup of X over Y** = slower time ÷ faster time = 3.6 / 3.2 = **1.125×**.

**(c) MIPS:**
- MIPS_X = f/(CPI×10⁶) = 3×10⁹/(1.6×10⁶) = **1875**.
- MIPS_Y = 2×10⁹/(1.2×10⁶) = **1667**.
- X has higher MIPS — and here it **does** match the timing winner. Why? Because both run the **same Ic for the task**, so MIPS tracks real speed. MIPS only misleads when the instruction counts / instruction sets differ between machines.
</details>

---

### Problem 11 — Little's Law
A web service has an average arrival rate of **λ = 200 requests/sec** and each request spends on average **W = 0.05 s** in the system. How many requests are in the system on average?
<details><summary>Show answer</summary>

Little's Law: L = λ × W.

L = 200 requests/sec × 0.05 s = **10 requests** in the system on average.

(Units check: requests/sec × sec = requests. ✓)
</details>
