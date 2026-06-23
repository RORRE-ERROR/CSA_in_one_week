# Chapter 09 — CISC vs RISC · Practice Questions

> 🌱 **How to use this file.** Read `notes.md` first. Then try each question **on your own** before opening the answer — even a rough attempt makes it stick far better than reading the solution. Peeking too early feels productive but teaches you much less. It's completely fine to get them wrong; that's how you find your gaps.
>
> Questions go **easy → harder**: first plain recall, then classifying and applying, then a couple of exam-style ones with arithmetic.

---

## Warm-up: can you remember the basics?

### 1. Classify the features

For each feature, label it **CISC** or **RISC**: (a) variable-length instructions, (b) load/store architecture, (c) microcoded control unit, (d) ~32 general-purpose registers, (e) many addressing modes, (f) CPI ≈ 1.

<details><summary>Show answer</summary>

(a) CISC · (b) RISC · (c) CISC · (d) RISC · (e) CISC · (f) RISC.

**The trick:** anything that makes the *hardware* do more work (variable length, microcode, many addressing modes, memory operands) is **CISC**. Anything that keeps instructions *simple and uniform* (load/store, fixed length, lots of registers, one cycle each) is **RISC**.
</details>

---

### 2. The historical motivation for CISC

List the three main reasons CISC arose in the 1970s and explain each in one sentence.

<details><summary>Show answer</summary>

1. **Expensive/scarce memory** — complex instructions packed more work into fewer bytes, so dense code saved costly memory.
2. **The semantic gap** — designers added instructions that *looked like* high-level-language statements, to narrow the distance between source code and machine code.
3. **Cheap microcode** — adding an instruction just meant writing a bit more microcode (in fast control memory), not wiring up new circuits, so rich instruction sets were inexpensive to build and let new chips keep old instructions for backward compatibility.
</details>

---

### 3. The "Reduced" myth

A classmate says: "RISC programs always execute fewer instructions than CISC, that's why they're faster." Correct them in plain words.

<details><summary>Show answer</summary>

That's false. "Reduced" refers to the **complexity of each instruction**, not the length of the program. A task usually needs **more** RISC instructions (so **larger code**). RISC wins because each simple instruction runs fast and **pipelines cleanly (CPI ≈ 1)**, and the big register file + smart compiler keep operands on-chip — so total time is competitive or better *despite* executing more instructions.
</details>

---

### 4. Identify the architecture

Classify each as CISC or RISC: x86, ARM, VAX, MIPS, RISC-V, Motorola 68000, SPARC, IBM z/Architecture.

<details><summary>Show answer</summary>

**CISC:** x86, VAX, Motorola 68000, IBM z/Architecture.
**RISC:** ARM, MIPS, RISC-V, SPARC.
</details>

---

## Applying it

### 5. Multiply, two ways

Write the instruction sequence to compute `Z = X * Y` (X, Y, Z all in memory) in (a) a CISC style and (b) a RISC style. Then state the code-size / pipelining trade-off.

<details><summary>Show answer</summary>

(a) **CISC** — one memory-to-memory instruction:
```text
MUL  Z, X        ; fetch X & Y from memory, multiply, store result to Z
```
(b) **RISC** — load/store, register-to-register:
```text
LOAD  R1, X
LOAD  R2, Y
MUL   R3, R1, R2
STORE Z,  R3
```
**Trade-off:** CISC is **1 instruction (small code)** but internally complex, variable-cycle, and hard to pipeline. RISC is **4 fixed-length instructions (larger code)** but each is simple and the sequence overlaps in the pipeline; the compiler can keep R1–R3 in registers. Same job, opposite trade: *small code & many cycles* vs *bigger code & one-cycle-each*.
</details>

---

### 6. Why is RISC pipeline-friendly?

Give three structural properties of RISC that make pipelining easy, and explain *why* each helps.

<details><summary>Show answer</summary>

1. **Fixed-length instructions** — fetch and decode take a uniform, single step, so those stages have predictable timing and stay in sync.
2. **Load/store architecture** — only loads/stores touch memory, so memory access sits in just one pipeline stage (MEM) and the other stages never wait on slow memory.
3. **CPI ≈ 1 / simple uniform instructions** — every stage takes a similar time, so stages stay balanced and no long microcoded instruction stalls the pipe.

(Simple addressing modes help too: operand addresses are predictable.)
</details>

---

### 7. Register windows

Explain how overlapping register windows reduce procedure-call overhead, and what happens on a "window overflow."

<details><summary>Show answer</summary>

On a call, the hardware rotates to a new window of registers. Because windows **overlap**, the caller's *out* registers **are** the callee's *in* registers — so arguments pass in-register with no save/restore to memory. The whole call/return is just a window rotation rather than pushing and popping a stack frame.

When every physical window is in use (**window overflow**), the hardware spills the oldest window's contents to memory (the stack) to free one up, and reloads it later on underflow. **SPARC** is the classic example.
</details>

---

### 8. Control unit and the design philosophy

(a) Which control-unit style does each use, and why? (b) In one sentence, where does each philosophy *put* the complexity?

<details><summary>Show answer</summary>

(a) **CISC: microcoded** control — it needs microcode to sequence its many complex, variable-length instructions; that's flexible and cheap to extend, but slower. **RISC: hardwired** control — its instructions are simple and uniform, so fast fixed logic suffices, giving a smaller, faster decoder.

(b) **CISC puts the complexity in the hardware/microcode; RISC puts it in the compiler/software** (instruction scheduling and register allocation via graph colouring).
</details>

---

## Exam-style (with a bit of arithmetic)

### 9. Performance arithmetic

A task is N CISC instructions at CPI = 6, or 1.4N RISC instructions at CPI = 1.1, at the same clock. Which is faster, and by how much?

<details><summary>Show answer</summary>

CPU time ∝ Instructions × CPI.
- CISC ∝ N × 6 = **6N**
- RISC ∝ 1.4N × 1.1 = **1.54N**

RISC is **6 / 1.54 ≈ 3.9× faster**, even though it executes 40% more instructions. That's the core lesson: a low CPI from pipelining beats raw instruction-count savings.
</details>

---

### 10. Transistor budget reasoning

Why did RISC have a bigger advantage when transistor budgets were small (e.g. 500k) than when they were large (e.g. 50M)?

<details><summary>Show answer</summary>

With a **small** budget, a microcoded CISC decoder ate up most of the transistors, leaving little for performance features. A simple RISC core fit the same budget *and* left room for a **large register file, cache, and pipeline** — a real edge. As budgets grew into the millions, **both** styles could afford full pipelines, caches, and out-of-order execution, so RISC's relative advantage shrank → convergence. (Yield helps explain the early gap too: defects scale with die *area*, so smaller, simpler cores cost less to make — but that matters less on today's mature processes.)
</details>

---

### 11. The convergence argument

Explain the slogan "CISC outside, RISC inside," and why the CISC-vs-RISC debate is now considered largely moot.

<details><summary>Show answer</summary>

Modern x86 (Intel/AMD) keeps the **CISC instruction set** for backward compatibility (the "outside"), but the front-end **decoder cracks each instruction into RISC-like micro-ops** that run on a **RISC-style superscalar, out-of-order core** (the "inside"). Meanwhile RISC ISAs (ARM, RISC-V) added rich features. With huge transistor budgets, decoders, microcode, caches, and pipelines are all affordable on either side, so performance now depends on **microarchitecture and process technology, not the ISA label** — which is why the original debate is moot.

**Caveat:** for low-power mobile/embedded, RISC's cheaper fixed-length decode still gives an edge — hence ARM/RISC-V dominance there.
</details>
