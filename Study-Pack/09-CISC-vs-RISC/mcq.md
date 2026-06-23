# Chapter 09 — CISC vs RISC · Quick Self-Test (Multiple Choice)

> 🌱 **How to use this.** Once you've read `notes.md` and tried `exercises.md`, use these 15 questions to check what stuck. Pick an answer in your head (or jot A/B/C/D) **before** opening the explanation. The goal isn't the score — it's understanding *why* the right answer is right, which the explanations spell out in plain words.
>
> Don't worry about your score the first time. Re-take it the day before the exam and aim for 14–15.

---

**Q1.** Which is a defining feature of a RISC architecture?
A. Variable-length instructions
B. Microcoded control unit
C. Load/store memory access
D. Many addressing modes

**Q2.** CISC arose largely because, in the 1970s, ______.
A. compilers were already highly optimizing
B. memory was expensive, so dense code was valued
C. transistor budgets were huge
D. pipelining was already standard

**Q3.** "Reduced" in RISC primarily refers to a reduction in:
A. the number of instructions a program executes
B. the complexity of each instruction
C. the number of registers
D. clock frequency

**Q4.** Which control-unit style is associated with RISC?
A. Microcoded
B. Hardwired
C. Microprogrammed with horizontal encoding
D. Nanocoded

**Q5.** Which set is entirely CISC?
A. ARM, MIPS, RISC-V
B. x86, VAX, Motorola 68000
C. SPARC, PowerPC, ARM
D. RISC-V, x86, MIPS

**Q6.** A key reason RISC is easy to pipeline is:
A. variable-length instructions
B. memory operands in every instruction
C. fixed-length instructions and CPI≈1
D. microcoded sequencing

**Q7.** The "semantic gap" refers to the distance between:
A. cache and main memory speeds
B. high-level language constructs and primitive machine operations
C. user mode and kernel mode
D. virtual and physical addresses

**Q8.** In overlapping register windows, the caller's *out* registers:
A. are saved to the stack on every call
B. become the callee's *in* registers
C. are cleared before the call
D. are the same as the global registers

**Q9.** The slogan "CISC outside, RISC inside" describes:
A. RISC chips that emulate x86 in software
B. modern x86 decoding instructions into RISC-like micro-ops
C. CISC running inside a virtual machine
D. RISC cores that use microcode

**Q10.** Compared with CISC, RISC code is generally:
A. smaller
B. larger
C. identical in size
D. always exactly half the size

**Q11.** The compiler technique for assigning variables to a limited register file is:
A. paging
B. graph colouring of the interference graph
C. branch prediction
D. write-back buffering

**Q12.** Given CPU time ∝ Instructions × CPI: CISC = N instrs at CPI 5; RISC = 2N instrs at CPI 1. Which is faster?
A. CISC, 5× faster
B. RISC, 2.5× faster
C. Equal
D. RISC, 10× faster

**Q13.** Which is NOT typical of CISC?
A. Variable-length instructions
B. Many addressing modes
C. Load/store-only memory access
D. Microcoded control

**Q14.** Why has the CISC-vs-RISC debate become largely "moot"?
A. CISC ISAs were abandoned entirely
B. Large transistor budgets let both adopt the same high-performance techniques
C. RISC chips can no longer be manufactured
D. Compilers stopped optimizing

**Q15.** Which architecture is most associated with **register windows**?
A. x86
B. SPARC
C. VAX
D. Motorola 68000

---

## Answers — with the *why*

<details><summary>Q1</summary><b>C.</b> Load/store — only LOAD and STORE touch memory — is a core RISC trait. A, B and D (variable length, microcode, many modes) are all CISC.</details>
<details><summary>Q2</summary><b>B.</b> Memory was costly back then, so packing more work into fewer bytes (dense code) saved money — which motivated complex multi-step instructions. (The semantic gap and cheap microcode pushed the same way.)</details>
<details><summary>Q3</summary><b>B.</b> "Reduced" means *less complexity per instruction* — not fewer instructions executed (often more!) and not a smaller register count.</details>
<details><summary>Q4</summary><b>B.</b> Hardwired control — simple, uniform instructions only need fast fixed logic to decode. Microcode is the CISC approach.</details>
<details><summary>Q5</summary><b>B.</b> x86, VAX and Motorola 68000 are all CISC. ARM, MIPS, RISC-V, SPARC and PowerPC are RISC.</details>
<details><summary>Q6</summary><b>C.</b> Fixed-length instructions decode uniformly and a steady CPI≈1 keeps every pipeline stage balanced, so instructions flow without stalls.</details>
<details><summary>Q7</summary><b>B.</b> The semantic gap is the distance between high-level-language constructs and the primitive machine operations a CPU actually does; CISC tried to close it.</details>
<details><summary>Q8</summary><b>B.</b> Windows overlap, so the caller's *out* registers literally are the callee's *in* registers — arguments pass in-register with no memory traffic.</details>
<details><summary>Q9</summary><b>B.</b> x86 keeps the CISC instruction set on the outside but executes RISC-like micro-ops on a RISC-style core inside.</details>
<details><summary>Q10</summary><b>B.</b> Larger — a task needs more (fixed-length) RISC instructions, so the program takes more memory. That's the code-size side of the trade-off.</details>
<details><summary>Q11</summary><b>B.</b> Graph colouring of the interference graph: variables that are "live" at the same time get different registers, so they never collide.</details>
<details><summary>Q12</summary><b>B.</b> CISC ∝ N×5 = 5N; RISC ∝ 2N×1 = 2N; 5N ÷ 2N = 2.5 → RISC is 2.5× faster, even with double the instructions.</details>
<details><summary>Q13</summary><b>C.</b> Load/store-only is the RISC trait. CISC instead allows memory operands in arithmetic, plus variable length, many addressing modes, and microcode.</details>
<details><summary>Q14</summary><b>B.</b> Huge transistor budgets let both styles use pipelines, caches, out-of-order execution and micro-op decode — so performance now comes from microarchitecture and process, not the ISA label.</details>
<details><summary>Q15</summary><b>B.</b> SPARC popularised overlapping register windows.</details>

---

> 📊 **Scored low?** That's normal on a first pass — go back to the matching `notes.md` section for anything you missed, then retry. **Scored 13+?** You've got CISC vs RISC down.
