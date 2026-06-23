# Chapter 09 — CISC vs RISC

> 🌱 **Starting from zero?** Great — this chapter is one big argument between two ways of designing a CPU, and you don't need any prior chip knowledge to follow it. We'll use everyday comparisons first, then put the technical names on them. Read it slowly, top to bottom.
>
> ⏱️ Take about 2 hours. The two stars of this chapter are the **CISC-vs-RISC comparison table** and the **RISC design principles** — they're the most exam-tested, so we'll make them crystal clear.

---

## 🤔 First, why does this chapter exist?

When engineers design the "language" a CPU understands — its **instruction set** (the list of commands the chip can obey, like ADD, LOAD, JUMP) — they face a fork in the road:

- **Make each command do a LOT** (one fancy command might fetch two numbers from memory, multiply them, and store the answer back) — so a program needs fewer commands.
- **Make each command do a LITTLE** (tiny, simple steps) — so a program needs more commands, but each one runs fast and predictably.

That's the whole fight. Door number one is called **CISC**. Door number two is called **RISC**. This chapter explains *why each side made the choice it did*, lays them side by side, and finishes with the surprising ending: in modern chips, both sides quietly borrowed from each other.

By the end you'll be able to, in your own words:
- say what **CISC** is and **why** the 1970s pushed designers toward it,
- list the **RISC design principles** and explain why each one helps,
- reproduce the **CISC-vs-RISC comparison table** from memory,
- explain **register windows** and the **compiler** approach to using registers,
- explain why **pipelining** is the real reason RISC won on speed,
- and explain why the debate became "moot" — *and* why CISC is **not** simply "the slow one."

---

## A quick word before we start: CISC is NOT just "the slow kind"

This is the single biggest misunderstanding, so let's kill it up front.

CISC and RISC make **opposite trades**, and neither is free:

- **CISC** writes **shorter programs** (small code) but each instruction can take **many clock ticks**.
- **RISC** writes **longer programs** (big code) but each instruction takes about **one clock tick** and they flow smoothly.

So the real trade is **code size vs cycles** — not "fast vs slow." Keep that sentence in your pocket; we'll earn it properly by the end.

---

## 1. CISC — the "do-it-all command" design

**Analogy first.** Imagine a kitchen gadget that, at the press of one button, fetches the vegetables from the fridge, chops them, cooks them, and plates the dish. One button, lots happening inside. Handy! But that button is complicated to build, and pressing it takes a while because so much happens behind the scenes.

**Plain English.** A CISC CPU offers *rich, powerful* instructions. A single instruction can reach into memory, do arithmetic, and write the result back — all by itself. Programs are short because each command packs in a lot of work.

**The formal term.** **CISC = Complex Instruction Set Computer.** "Complex" describes the *instructions*, which do a lot each.

```text
CISC INSTRUCTION (one opcode does a lot)
┌────────────────────────────────────────────┐
│  ADD  R1, [R2+disp]     ; memory operand    │
│  └─ fetch operand from mem, add, store back │
│  variable length (1–15 bytes on x86)        │
│  decoded by MICROCODE → many micro-steps    │
└────────────────────────────────────────────┘
```

**Reading that diagram in plain words:** a single `ADD` here grabs a number out of memory, adds it, and puts it back — three jobs in one command. The instruction can be anywhere from 1 to 15 bytes long (its size varies), and inside the chip it's broken into many tiny steps by something called *microcode* (defined below).

**The defining characteristics of CISC:**
- A **large instruction set** with many *specialised* commands (string-copy, `LOOP`, even polynomial evaluation on some chips).
- **Variable-length** instructions (on x86, anywhere from 1 to 15 bytes) → compact code, but harder to decode.
- **Many addressing modes** — lots of different ways to say *where* an operand lives (register, direct, indirect, indexed, base+displacement, autoincrement…). An **addressing mode** is just the rule the CPU uses to find an operand.
- Arithmetic instructions are allowed to use **memory operands** directly (it can do memory-to-memory work) — it is *not* restricted to a load/store style.
- A **microcoded control unit**. *Microcode* is a tiny built-in program inside the CPU; each machine instruction is expanded into a sequence of even smaller steps (**micro-operations**) read from a fast internal memory. Think of it as the chip "looking up the recipe" for each complex command.
- **Few general-purpose registers** (32-bit x86 had only 8). A **register** is a tiny ultra-fast storage slot inside the CPU.
- **Variable cycles per instruction** — some instructions take many clock ticks. (The measure here is **CPI = cycles per instruction**; for CISC it's often well above 1.)

> 🧠 **Memory hook:** **CISC = Complex = Compact code, Costly decode.** The hardware is smart so the compiler can be lazy.

### Why CISC happened (the history — and it made sense at the time)

CISC wasn't a mistake. In the 1970s it was the *rational* choice, for three reasons:

1. **Memory was scarce and expensive.** Every byte of program counted. A complex instruction crammed more work into fewer bytes, so dense code literally saved money. *(Picture paying by the word for a telegram — you'd want each word to do a lot.)*
2. **The "semantic gap."** High-level languages (with loops, arrays, procedure calls) looked nothing like the primitive steps a CPU does. The **semantic gap** is that distance between *what you write in source code* and *what the machine actually does*. Designers added instructions that *resembled* high-level statements, hoping compilers would use them directly and close the gap.
3. **Microcode made adding instructions cheap.** Thanks to microcode (Wilkes, 1951), adding a new fancy instruction just meant writing a bit more microcode — no need to wire up new dedicated circuits. So a rich instruction set felt almost "free," and it let each new chip keep all the old instructions (the x86 family runs from the 8086 right through to today).

> ⚠️ **Exam trap — the plot twist that created RISC.** In the 1980s, researchers (notably **Patterson**) *measured* real programs and found two awkward facts: (1) compilers actually used only a **small handful** of the fancy CISC instructions, and (2) a complex instruction was often **slower** than doing the same job with several simple instructions. That measurement is what launched RISC.

> ✍️ **Check yourself:** Why did expensive memory push designers toward complex instructions?
> <details><summary>Reveal answer</summary>Because a complex instruction packs more work into fewer bytes, so the program takes up less memory — and memory was the costly, scarce resource at the time. Dense code saved money.</details>

---

## 2. RISC — the "tiny simple steps" design

**Analogy first.** Instead of the one magic button, picture a clean assembly line: each worker does *one* simple task and hands the piece along. No single worker is impressive, but the line moves steadily and *something finishes coming off the end every second*. Simple stations are easy to build and easy to keep flowing.

**Plain English.** A RISC CPU offers only *simple* instructions, each doing a small amount of work but doing it fast and predictably. To get a big job done you string lots of them together — but they line up beautifully and run almost one-per-tick.

**The formal term.** **RISC = Reduced Instruction Set Computer.** "Reduced" means **each instruction is simpler** — *not* that programs are shorter (they're usually longer!). Lock that in.

```text
RISC PIPELINE-FRIENDLY INSTRUCTION
┌──────────────────────────────────────────────┐
│  LOAD  R1, [R2]    ; ONLY loads touch memory  │
│  ADD   R3, R1, R4  ; reg-to-reg arithmetic    │
│  STORE [R5], R3    ; ONLY stores touch memory │
│  fixed length (32 bits), 1 op = ~1 cycle      │
│  decoded by HARDWIRED logic (fast)            │
└──────────────────────────────────────────────┘
```

**Reading that diagram in plain words:** only `LOAD` and `STORE` are allowed to touch memory. All the actual arithmetic (`ADD`) happens between registers. Every instruction is the same size (32 bits), takes about one clock tick, and is decoded by fast fixed wiring rather than by looking up microcode.

**The defining characteristics of RISC:**
- A **reduced / simple** instruction set — each instruction does little, runs fast.
- **Fixed-length** instructions (usually 32 bits) → trivial to decode, easy to pipeline.
- A **load/store architecture**: *only* `LOAD` and `STORE` touch memory; all arithmetic is **register-to-register**. (This is a star concept — examiners love it.)
- **Few, simple addressing modes.**
- A **large register file** (e.g. 32 registers) so operands stay in fast on-chip storage instead of being fetched from slow memory.
- A **hardwired control unit** — fixed logic circuits instead of microcode, so decoding is fast and small.
- Designed for **CPI ≈ 1** (about one cycle per instruction) by keeping every instruction uniform and **pipeline**-friendly.
- Leans heavily on a smart **optimizing compiler** to schedule instructions and use the registers well.

> 🧠 **Memory hook:** **RISC = Reduced (per instruction) but Runs fast.** Push the cleverness into the *compiler*; keep the silicon simple and flowing.

### The RISC design principles (memorise these — Stallings)

These six are exam gold. Here they are with a plain reason for each:

1. **One instruction per cycle (CPI ≈ 1).** *Why:* if every instruction takes the same single tick, the chip has a steady rhythm and nothing stalls.
2. **Register-to-register operations** (only load/store touch memory). *Why:* memory is slow; keeping arithmetic between registers avoids waiting on it, and isolates all memory traffic to two instruction types.
3. **Simple, few addressing modes.** *Why:* fewer ways to find an operand means simpler, faster, more predictable decoding.
4. **Simple, fixed-length instruction formats.** *Why:* same-size instructions are decoded in one uniform step — perfect for a pipeline.
5. **Hardwired control** (not microcoded). *Why:* fixed logic is faster and smaller than looking up microcode for every instruction.
6. **Large register file + optimizing compiler.** *Why:* lots of registers let the compiler keep operands on-chip, cutting slow memory accesses.

> ⚠️ **Exam trap — the #1 graded distinction:** **RISC does NOT mean fewer instructions get executed.** A task usually needs *more* RISC instructions (so **bigger code**) than CISC. RISC wins because each instruction is fast and pipelines cleanly — total time comes out competitive or better. "Reduced" = reduced *complexity per instruction*, **not** shorter programs.

> ✍️ **Check yourself:** In a load/store architecture, which instructions are allowed to touch memory?
> <details><summary>Reveal answer</summary>Only <b>LOAD</b> and <b>STORE</b>. Every arithmetic/logic instruction works strictly register-to-register, so memory access is isolated to just those two instruction types.</details>

---

## 3. CISC vs RISC — the Master Comparison Table

This is **the** table the exam wants. Read it across one row at a time — each row is one "dimension" on which the two designs differ.

| Dimension | CISC | RISC |
|---|---|---|
| **Instruction set size** | Large, many specialized instrs | Small, simple, general instrs |
| **Instruction length** | **Variable** (e.g. x86 1–15 B) | **Fixed** (e.g. 32-bit) |
| **Addressing modes** | Many (8–20+) | Few (often ≤4) |
| **Memory access** | Most instrs can access memory | **Load/store only** |
| **Registers** | Few GPRs (~8) | Many GPRs (~32+) |
| **Control unit** | **Microcoded** | **Hardwired** |
| **Cycles per instruction (CPI)** | Variable, often >1 | ~1 (uniform) |
| **Pipelining** | Hard (variable length/CPI) | Easy / natural |
| **Code size** | **Smaller** (dense) | Larger (more instrs) |
| **Complexity lives in** | Hardware / microcode | **Compiler / software** |
| **Examples** | x86, VAX, Motorola 68k, z/Arch | ARM, MIPS, RISC-V, SPARC, PowerPC |

**How to read it in one breath:** CISC = big, varied, memory-touching instructions, few registers, microcode, variable speed, small code, complexity in hardware. RISC = small, uniform, register-only instructions, many registers, hardwired, steady speed, bigger code, complexity in the compiler.

> ✍️ **Check yourself:** Which design makes pipelining easy, and why?
> <details><summary>Reveal answer</summary>RISC. Its <b>fixed-length</b> instructions decode in one uniform step and almost all take the <b>same number of cycles (CPI≈1)</b>, so the pipeline stages stay balanced and instructions flow without stalls. CISC's variable length and variable CPI make stage timing irregular and lumpy.</details>

---

## 4. Keeping operands in registers — two clever tricks

**Why this section exists.** Most of a CPU's time goes on shuffling **operands** (the values instructions work on). Fetching them from memory is slow; keeping them in registers is fast. So both camps want operands to live in registers as much as possible. There are two ways to make that happen — one in hardware, one in software.

### (a) Hardware trick — Register Windows (the SPARC approach)

**Analogy first.** Imagine each procedure (function) gets its own small desk of registers. When procedure A calls procedure B, instead of packing up A's papers and handing them over, the two desks **overlap at the edge** — the papers A wants to pass are already sitting in the shared overlap zone, which is B's input area. Nothing gets copied; you just slide over to the next desk.

**Plain English.** On a procedure call, the hardware switches to a new **window** (a fresh group of registers). Adjacent windows **overlap**, so the caller's *out* registers literally *are* the callee's *in* registers. Parameters pass with **no memory traffic** — the call just rotates the active window.

```text
REGISTER WINDOW (overlapping)  — SPARC style
                Procedure A                Procedure B (callee)
  global  |  in  | local | out  |
          |      |       |▒▒▒▒▒▒|====overlap====|  in  | local | out |
          └──────┴───────┴──────┘                └──────┴───────┴─────┘
   A's OUT registers  ───────────────►  are B's IN registers
   No memory copy needed to pass parameters; CALL just rotates window.
  ( + a fixed set of GLOBAL registers visible to all windows )

When windows run out → "window overflow" spills oldest to memory.
```

**Reading it in plain words:** A's "out" box and B's "in" box are the *same physical registers* (the shaded overlap). So A puts arguments there, B reads them there — no copying through memory. There's also a set of **global** registers everyone shares. If you nest calls so deep that you run out of physical windows, that's a **window overflow**, and the hardware spills the oldest window's contents out to memory to make room.

### (b) Software trick — Compiler register allocation (graph colouring)

**Analogy first.** Think of scheduling shared meeting rooms (the registers). Two meetings that happen *at the same time* can't use the same room; two that never overlap in time *can* reuse one. You draw lines between meetings that clash, then assign rooms (colours) so no clashing pair shares a room.

**Plain English.** The compiler builds an **interference graph**: each variable is a dot, and a line connects two variables that are "alive at the same time." It then **colours** the graph so variables that are live together never share a register. This squeezes maximum use out of a large register file *without* any special hardware — it's the MIPS-style approach and what real compilers do today.

> 🧠 **Memory hook:** **Windows = the hardware does it; Colouring = the compiler does it.** Same goal: operands in registers, not memory.

> ✍️ **Check yourself:** Why do overlapping register windows speed up procedure calls?
> <details><summary>Reveal answer</summary>Because the caller's <i>out</i> registers <i>are</i> the callee's <i>in</i> registers, so arguments pass in-register with no save/restore to the memory stack — and the call/return is just a window rotation instead of pushing/popping a stack frame.</details>

---

## 5. Pipelining — the real reason RISC wins on speed

**Analogy first.** A laundromat with one washer-dryer combo does one load fully before starting the next. A **pipeline** is like having a separate washer, dryer, and folding table: while load 1 is drying, load 2 is already washing. You don't make any single load faster — but a *finished* load comes out far more often.

**Plain English.** A CPU **pipeline** overlaps the stages of different instructions. The classic five stages are **Fetch → Decode → Execute → Memory → Writeback** (IF–ID–EX–MEM–WB). RISC is practically *built* for this.

```text
Cycle →   1    2    3    4    5    6    7
I1        IF   ID   EX   MEM  WB
I2             IF   ID   EX   MEM  WB
I3                  IF   ID   EX   MEM  WB
  Fixed length + CPI≈1 + load/store ⇒ stages stay balanced,
  one instruction COMPLETES every cycle at steady state.
```

**Reading it in plain words:** instruction I1 moves through the five stages diagonally; I2 starts the moment I1 frees up the Fetch stage; I3 follows I2. After the pipe fills, *one instruction finishes every single cycle*.

Why RISC pipelines so cleanly:
- **Fixed-length instructions** → fetch and decode take a uniform, predictable step.
- **Load/store** → memory access is confined to *one* stage (MEM); other stages never wait on memory.
- **Simple addressing** → operand addresses are predictable, so fewer stalls.
- CISC, by contrast, must do extra work to chop its variable-length instructions into uniform steps before it can pipeline — which is *exactly* what modern x86 does (Section 6).

> ⚠️ **Exam trap:** Pipelining — not "fewer instructions" — is the real performance reason RISC pulled ahead. A clean pipeline at CPI ≈ 1 can beat a microcoded CISC *even when RISC executes more instructions*.

---

## 6. Convergence — why the debate became "moot"

**Plain English.** After all that arguing, here's the twist: modern CPUs from both camps ended up looking alike inside.

```text
   x86 (CISC ISA)                ARM / RISC-V (RISC ISA)
        │                                │
   front-end DECODER                  already simple
   cracks each CISC instr                 │
   into 1+ RISC-like                  added: SIMD, crypto,
   MICRO-OPS (µops)                   complex addressing →
        │                             "feature-rich RISC"
        ▼                                │
   RISC-like execution core  ◄──────── both use ──┐
   (out-of-order, superscalar, deep pipeline,      │
    register renaming, big caches) ────────────────┘
```

**Reading it in plain words:**
- **Modern x86 (Intel/AMD)** still *speaks* CISC on the outside (for backward compatibility), but its front-end **decoder translates each CISC instruction into one or more RISC-like micro-operations (µops)**, which then run on a RISC-style core. So inside, x86 basically *is* RISC.
- **RISC chips grew richer** too — ARM added Thumb (for code density) and NEON (SIMD), modern RISC has plenty of features — so pure minimalism faded.
- **Transistor budgets exploded** (Moore's Law): once you have millions of transistors, you can afford a decoder, microcode, a big register file, caches, *and* a deep pipeline on *either* side. The original pressures (dear memory, scarce transistors) simply vanished.
- **Result:** today's speed differences come from **microarchitecture, manufacturing process, and design effort** — not from the CISC-vs-RISC label.

> 🧠 **Memory hook:** **"CISC outside, RISC inside."** That one phrase *is* the convergence story.

> ⚠️ **Exam trap — the caveat:** the debate is moot *for high performance*, not totally irrelevant. For tiny low-power chips (phones, IoT), RISC's cheaper fixed-length decode still saves power and area — part of why **ARM and RISC-V dominate mobile/embedded**.

---

## 7. IC manufacturing economics & the transistor budget

**Analogy first.** Imagine a fixed budget to furnish a room. If most of your money goes on one elaborate antique cabinet (the microcoded decoder), there's little left for anything else. If you buy simple furniture (a lean core), you have cash left over for extras that actually help — bookshelves, a desk, good lighting (registers, cache, pipeline).

**Plain English.** A chip has a *transistor budget* — only so many transistors fit affordably (and bigger dies cost much more, because defects scale with area). Where you spend that budget shaped the early CISC/RISC gap.

```text
Cost / area of a die ↑ rapidly with size (defects scale with area).
Given a FIXED transistor budget, where do you spend it?

  500k transistors  → RISC: simple core fits + room for registers/cache.
                       CISC: microcode + decode eats most of the budget.
  2M / 5M / 50M     → both can afford full pipelines, caches, OoO.
                       The budget advantage of RISC SHRINKS as the
                       budget GROWS → CONVERGENCE.
```

**Reading it in plain words:** with a *small* budget (early days), CISC's microcode and decoder ate most of the transistors, leaving little for performance features. A simple RISC core fit the same budget *and* left room for a large register file, cache, and pipeline — a genuine edge. As budgets grew into the millions, **both** could afford everything, so RISC's relative advantage shrank → convergence. Also, **yield**: defects scale with die *area*, so smaller, simpler cores historically cost less to make (matters less on today's mature processes).

> 🧠 **Memory hook:** **Fixed budget → simplicity buys performance. Huge budget → everyone can afford complexity.**

---

## 🔬 Worked Example

### Part A — Model answer: "Compare and contrast CISC and RISC, with examples."

> **CISC** maximizes work per instruction: large, variable-length instruction sets, many addressing modes, memory operands in arithmetic, and a **microcoded** control unit. It was motivated by 1970s **expensive memory** (dense code mattered) and the **semantic gap** between high-level languages and machine code. **x86, VAX, and Motorola 68000** are CISC.
>
> **RISC** instead keeps instructions **simple and fixed-length** with a **load/store** model, **few addressing modes**, a **large register file**, and a **hardwired** control unit, targeting **CPI≈1** and clean **pipelining**, with complexity pushed onto the **optimizing compiler**. **ARM, MIPS, and RISC-V** are RISC.
>
> Key tradeoff: CISC yields **smaller code**; RISC yields **larger code but faster, pipeline-friendly execution**. Empirically, compilers used only a fraction of CISC instructions, and simple sequences often beat complex instructions — motivating RISC.
>
> Today the distinction is largely **moot**: modern **x86 decodes its CISC instructions into RISC-like micro-ops** run on a superscalar out-of-order core, while RISC ISAs have added rich features. With large transistor budgets, performance now stems from **microarchitecture and process**, not the ISA label — though RISC's cheaper decode still favours **low-power mobile/embedded** (ARM, RISC-V).

### Part B — "Multiply" done the CISC way vs the RISC way

Task: multiply two numbers in memory, `C = A * B`.

```text
CISC APPROACH (one powerful instruction; memory operands)
    MUL  C, A          ; load A and B from memory, multiply, store to C
                       ; ONE instruction, but internally many micro-steps,
                       ; variable cycles. Tiny code size.

RISC APPROACH (load/store; reg-to-reg; pipeline-friendly)
    LOAD  R1, A        ; R1 ← mem[A]
    LOAD  R2, B        ; R2 ← mem[B]
    MUL   R3, R1, R2   ; R3 ← R1 * R2   (register-to-register)
    STORE C,  R3       ; mem[C] ← R3
                       ; FOUR instructions, larger code, but each is
                       ; simple, fixed-length, and pipelines cleanly.
```

In plain words: CISC does it in **one** instruction (tiny code) but that instruction hides many internal steps and a variable number of cycles, and it's hard to pipeline. RISC takes **four** simple instructions (larger code), but each is fixed-length and the four overlap nicely in the pipeline — and the compiler can keep `R1, R2, R3` in registers across nearby work.

### Part C — Code-size vs cycle-count reasoning (the trade in numbers)

Suppose a task is one CISC instruction taking **12 cycles**, vs **4 RISC instructions**:

| Metric | CISC | RISC |
|---|---|---|
| Instructions | 1 | 4 |
| Cycles (non-pipelined) | 12 | 4 × 1 = 4 |
| Code size | smaller | larger |

Even **without** any pipelining, four CPI≈1 instructions (4 cycles total) beat one 12-cycle microcoded instruction. **With** pipelining, the four RISC instructions overlap toward ~1 cycle each at steady state, widening the gap. The price RISC pays is **larger code** (more to fetch, more cache pressure) — that's the central trade. **This is why CISC isn't "the slow one": it's "the small-code, many-cycles one."**

> ✍️ **Check yourself:** A program needs 1.5× as many RISC instructions as CISC, but RISC averages CPI = 1.2 vs CISC CPI = 5, at the same clock. Which is faster?
> <details><summary>Reveal answer</summary>Time ∝ Instructions × CPI. Let CISC = N instrs. RISC = 1.5N. CISC time ∝ N×5 = 5N. RISC time ∝ 1.5N×1.2 = 1.8N. RISC is ~2.8× faster <i>despite</i> executing more instructions — proving "more instructions" ≠ "slower."</details>

---

## ✅ You now understand…

Take a breath — that was the whole CISC/RISC debate. In plain terms:

1. **CISC** = powerful, do-a-lot instructions → **short programs** but each instruction can take **many cycles**. It happened because of **dear memory, the semantic gap, and cheap microcode** in the 1970s.
2. **RISC** = tiny, simple, uniform instructions → **longer programs** but **CPI ≈ 1** and smooth pipelining. Follow the **six design principles** (one-instr/cycle, register-to-register, simple addressing, fixed-length formats, hardwired control, big register file + smart compiler).
3. The **comparison table** is the heart of the chapter — know every row.
4. Keeping operands in registers uses two tricks: **register windows** (hardware, SPARC) and **graph-colouring** (compiler).
5. **Pipelining** is the real reason RISC won on speed — not "fewer instructions."
6. The debate became **"moot"**: **"CISC outside, RISC inside"** (x86 → RISC micro-ops), RISC ISAs grew feature-rich, and big transistor budgets erased the old trade-offs — except low-power embedded still favours RISC.
7. The honest trade is **code size vs cycles** — CISC is **not** simply "slower."

If any of those feels shaky, re-read that section before moving on. When all seven feel comfortable, do `exercises.md`, then test yourself with `mcq.md`.

---

## 🎓 When you're revising for the exam

Everything above is the understanding. For the exam, examiners reward precise wording, so keep these crisp:

- **"Reduced" = reduced *complexity per instruction*, NOT fewer executed instructions.** Say this explicitly — it's the #1 graded distinction.
- For "compare CISC and RISC," **structure your answer by the table dimensions**: set size, instruction length, addressing modes, memory model, registers, control unit, CPI, pipelining, code size, complexity location, examples.
- Always pair claims with **examples**: x86 / VAX / 68k / z-Arch = **CISC**; ARM / MIPS / RISC-V / SPARC / PowerPC = **RISC**.
- Use the performance identity: **CPU time = Instructions × CPI × Clock period.** Most trade-off problems reduce to this.
- For "why moot?" → **"CISC outside, RISC inside,"** micro-ops, growing transistor budget, ARM/RISC-V rise (caveat: RISC still wins low-power).
- Know the **two register strategies**: hardware **register windows** (SPARC) vs compiler **graph-colouring** allocation.
- Quick mappings: **Microcoded ⇒ CISC; Hardwired ⇒ RISC; Load/store ⇒ RISC.**

> 🧠 **Mnemonics:** **CISC = Complex / Compact code / Costly decode / microCode.** **RISC = Reduced (per instr) / Registers many / load-stoRe / hardwiRed / pipeline-Ready.** Slogan: **"CISC outside, RISC inside."**

**Likely exam question (10 marks):** *"Compare and contrast CISC and RISC architectures, with examples, and explain why the distinction has become less important in modern processors."*
<details><summary>Model answer</summary>

Work through the **table dimensions** (set size, length, addressing, memory model, registers, control unit, CPI, pipelining, code size, where complexity lives), giving CISC and RISC for each, with **examples** (x86/VAX/68k vs ARM/MIPS/RISC-V). State the **core trade-off**: CISC = smaller code but variable/high CPI; RISC = larger code but CPI≈1 and pipeline-friendly — so RISC is **not** simply faster, it trades *code size* for *cycles*. Note the empirical RISC motivation (compilers used few complex instructions; simple sequences often beat them). Then explain **convergence**: **"CISC outside, RISC inside"** — modern x86 decodes CISC instructions into RISC-like **micro-ops** on a superscalar out-of-order core; RISC ISAs added rich features; **large transistor budgets** mean both afford pipelines/caches/OoO, so performance now comes from **microarchitecture and process**, not the ISA — with the caveat that RISC's cheaper decode still favours **low-power mobile/embedded**.
</details>

---

## 📚 Want to see/hear it explained another way?

- **The RISC chapter itself** — Stallings *COA* 11e, Ch. 15 "Reduced Instruction Set Computers (RISC)": https://www.pearson.com/en-us/subject-catalog/p/computer-organization-and-architecture/P200000003520
- **Gentle video walk-through** — Neso Academy, RISC and CISC: https://www.youtube.com/watch?v=hkUMSpDLPdo
- **Fast exam-style explanation** — Gate Smashers, RISC vs CISC: https://www.youtube.com/watch?v=g16wd1Bz_jA
- **Written summary & table** — GeeksforGeeks, RISC vs CISC: https://www.geeksforgeeks.org/computer-organization-risc-and-cisc/
- **Quick difference list** — TutorialsPoint: https://www.tutorialspoint.com/difference-between-risc-and-cisc
