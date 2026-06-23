# Chapter 09 — CISC vs RISC · Quick Refresher

> 🌱 Read this in 5 minutes to refresh everything, or the day before the exam. Each idea is given in **plain words first**, then the exam wording.

---

## The big ideas, in plain words

- **CISC = "do-it-all" instructions.** Each command does a lot (it can even reach into memory to do arithmetic), so **programs are short** — but each instruction can take **many clock ticks**. *Exam wording:* Complex Instruction Set Computer — large set, variable-length instructions, many addressing modes, memory operands, **microcoded** control, few registers, variable CPI.
- **RISC = "tiny simple steps."** Each command does a little but runs fast and uniformly, so **programs are longer** — but each instruction is about **one tick** and they flow smoothly through a pipeline. *Exam wording:* Reduced Instruction Set Computer — small set, **fixed-length** instructions, few addressing modes, **load/store only**, many registers, **hardwired** control, **CPI ≈ 1**.
- **"Reduced" ≠ fewer instructions.** It means *less complexity per instruction*. RISC code is usually **bigger**, not smaller. (This is the #1 exam trap.)
- **CISC is NOT just "slower."** The honest trade is **code size vs cycles**: CISC = small code, many cycles; RISC = bigger code, ~1 cycle each.
- **Why CISC happened (1970s):** expensive memory (dense code saved money) + the **semantic gap** (instructions made to look like high-level-language statements) + cheap **microcode** (easy to add instructions).
- **Why RISC wins on speed:** **pipelining** + keeping operands in registers — *not* "fewer instructions."
- **Keeping operands in registers, two ways:** hardware **register windows** (SPARC — overlapping windows pass parameters in-register) and compiler **graph colouring** (assign registers so variables live at the same time never share one).
- **Convergence — "CISC outside, RISC inside":** modern x86 keeps the CISC instruction set but its decoder turns each instruction into RISC-like **micro-ops** run on a RISC-style core. With huge transistor budgets, both afford pipelines/caches/OoO, so the debate is **moot** — except low-power mobile/embedded still favours RISC (ARM, RISC-V).

---

## Master Comparison Table (know every row)

| Dimension | CISC | RISC |
|---|---|---|
| Instruction set | Large, specialized | Small, simple |
| Instruction length | **Variable** (x86 1–15 B) | **Fixed** (32-bit) |
| Addressing modes | Many (8–20+) | Few (≤4) |
| Memory access | Most instrs (memory operands) | **Load/store only** |
| Registers | Few (~8) | Many (~32+) |
| Control unit | **Microcoded** | **Hardwired** |
| CPI | Variable, >1 | ≈1 (uniform) |
| Pipelining | Hard | Easy / natural |
| Code size | **Smaller** | Larger |
| Complexity in | Hardware / microcode | **Compiler / software** |
| Examples | x86, VAX, 68k, z/Arch | ARM, MIPS, RISC-V, SPARC, PowerPC |

## RISC Design Principles (the six)

1. One instruction per cycle (CPI ≈ 1).
2. Register-to-register operations (load/store isolates memory).
3. Simple, few addressing modes.
4. Simple, fixed-length instruction formats.
5. Hardwired (not microcoded) control.
6. Large register file + optimizing compiler.

## Why CISC existed (motivation)

- Expensive/scarce **memory** → dense code.
- **Semantic gap** between high-level language and machine code.
- **Microcode** made adding instructions cheap; kept backward compatibility.

## Register Optimisation — two routes

- **Register windows (hardware, SPARC):** overlapping windows pass parameters in-register; rotate on call; spill to memory on overflow.
- **Graph colouring (compiler):** colour the interference graph so variables that are live at the same time don't share a register; uses a large register file, no special hardware.

## Convergence Note (debate "moot")

- **"CISC outside, RISC inside":** x86 keeps the CISC ISA but decodes to **RISC-like micro-ops** on a superscalar/out-of-order core.
- RISC ISAs grew feature-rich (ARM Thumb, NEON; RISC-V extensions).
- Big **transistor budgets** erased the original trade-offs → performance now comes from microarchitecture + process, not the ISA label.
- **Exception:** low-power mobile/embedded still favours RISC (cheaper fixed-length decode) → ARM/RISC-V dominance.

## The multiply case study (one line each)

```text
CISC:  MUL Z, X                              → 1 instruction, small code, many cycles
RISC:  LOAD R1,X / LOAD R2,Y / MUL R3,R1,R2 / STORE Z,R3  → 4 instrs, bigger code, ~1 cycle each
```

## Memory aids

- **CISC = Complex / Compact code / Costly decode / microCode.**
- **RISC = Reduced (per instr) / Registers many / load-stoRe / hardwiRed / pipeline-Ready.**
- Performance identity: **Time = Instructions × CPI × Clock period.**
- Slogan: **"CISC outside, RISC inside."**

---

### ⭐ If you only revise 5 things

1. **The CISC vs RISC table** — especially variable vs fixed length, microcoded vs hardwired, memory-operands vs load/store-only, and CPI.
2. **"Reduced" ≠ fewer instructions / smaller code** — it's reduced *complexity per instruction*; RISC code is usually *larger* but pipelines fast (CPI≈1). CISC is *not* simply "slower" — the trade is **code size vs cycles**. (Exam trap.)
3. **Why CISC happened:** dear memory + semantic gap + cheap microcode. **Why RISC wins:** pipelining + registers, not "fewer instructions."
4. **Convergence:** "CISC outside, RISC inside" — x86 → micro-ops; big transistor budgets made it moot; ARM/RISC-V for low power.
5. **The two register tricks** (register windows in hardware / graph-colouring in the compiler) and the **multiply case study** (1 CISC `MUL` vs 4 RISC `LOAD/LOAD/MUL/STORE`).
