# Chapter 08 — Quick Refresher · Instruction Set Architecture

> 🌱 Read this in 5 minutes to refresh everything, or the day before the exam. Each idea is given in **plain words first**, then the exam wording.

---

## The big ideas, in plain words

- **Instruction set / ISA** = the **fixed menu of simple commands** the CPU obeys, plus the rules for writing them. It's the **contract between hardware and software** — like the buttons on a microwave: everything fancy is just a sequence of a few primitives.
- **One instruction** = an **opcode** (which command) + **operands** (the data) + (where to go next, usually unsaid). An operand can only live in **four places: Memory, I/O, Register, Immediate (MIRI)**.
- **Number of addresses** = how many operands one instruction names. **Fewer addresses → shorter instructions but more of them.** 3-address = name everything; 1-address = one secret bowl (the **accumulator**); 0-address = a **stack** (push values, operator grabs top two).
- **Data types** = bits only mean something once you say *how to read them*: **numbers** (integer / floating-point / packed-decimal), **characters** (ASCII/IRA, EBCDIC, Unicode), **logical** (loose on/off bits).
- **Endianness** = which end of a multibyte number goes at the lowest address. **Big** = big end first; **little** = little end first. Just like year-first vs day-first dates.
- **Addressing mode** = the rule for turning the instruction's little address field into the real location of the data (the **effective address, EA**). **Every pair of parentheses `( )` = one memory trip.**

---

## Addressing modes (EA formula + memory refs)
`A` = address field · `(X)` = contents of X · `R` = register

| Mode | Effective address | Mem refs (operand) | Use |
|---|---|---|---|
| Immediate | Operand = A | 0 | constants |
| Direct | EA = A | 1 | simple globals |
| Indirect | EA = (A) | 2 | pointers, large space |
| Register | EA = R | 0 | fast locals |
| Register indirect | EA = (R) | 1 | pointer in register |
| Displacement | EA = A + (R) | 1 | flexible (below) |
| Stack | EA = top of stack | implied | expression eval |

**Displacement sub-modes** (all EA = A + (R)):
- Relative → R = **PC**: EA = A + (PC)  *("this far from where I am now")*
- Base-register → R = base reg (segmentation)
- Indexed → A = base, R = index (arrays/loops)
  - Auto: `EA=A+(R); (R)←(R)±1` · Pre: `EA=(A+(R))` · Post: `EA=(A)+(R)`

*Plain-words exam line:* indirect `(A)` uses a **memory cell** to hold the address (2 trips); register-indirect `(R)` uses a **register** (1 trip) — same idea, register is cheaper. Pre-index adds the index **inside** the parentheses, post-index **outside**.

## n-address machine comparison
| # | Form | Implied store | Trade-off |
|---|---|---|---|
| 3 | `OP A,B,C` → A←B OP C | none | fewest instr, longest instr |
| 2 | `OP A,B` → A←A OP B | dest=src | dest overwritten |
| 1 | `OP A` → AC←AC OP A | accumulator | many LOAD/STOR |
| 0 | `OP` → T←(T−1) OP T | stack (TOS) | most instr, shortest |

Rule: **fewer addresses ⇒ more instructions, shorter each.** (For `Y=(A−B)/(C+D×E)` the counts ran 4 → 6 → 8 → 10.)

## Endianness rule
```text
0x1A2B3C4D @ addr N:
 BIG:    N=1A N+1=2B N+2=3C N+3=4D   (MSB at lowest addr)
 LITTLE: N=4D N+1=3C N+2=2B N+3=1A   (LSB at lowest addr)
```
- Big = **B**ig end first · Little = **L**east end first. Network/host order = big-endian. (Only reorders whole bytes — never the bits inside a byte, never registers.)

## Operation types
Data transfer · Arithmetic · Logical · Conversion · I/O · System control · Transfer of control (branch/skip/call-ret).

## Operand data types
Numbers (binary int / floating-point / packed-decimal: 2 BCD digits/byte) · Characters (ASCII/IRA, EBCDIC, Unicode) · Logical (n independent bits).

## Mnemonics quick list
| | | | |
|---|---|---|---|
| ADD/SUB/MUL/DIV | arithmetic | AND/OR/NOT/XOR/TEST | logical |
| LOAD/STOR/MOV/XCHG | data transfer | PUSH/POP | stack |
| JMP/Jcc/CALL/RET/NOP | control | IN/OUT | I/O |
| INC/DEC/NEG/ABS | single-op arith | SAL/SAR/SHR/ROL/ROR | shift/rotate |

*Shift/rotate in one line:* arithmetic shift **preserves the sign**, logical shift **fills 0**, rotate **wraps**.

## Instruction format
Fixed-length: simple decode, wasteful. Variable-length: compact/flexible, complex decode. **Bit budget:** opcode bits ↑ ⇒ address bits ↓ (the suitcase is a fixed size). Opcodes need ⌈log₂(#opcodes)⌉ bits.

---

### ⭐ If you revise only 5 things
1. **EA formulas:** immediate `=A`, direct `A`, indirect `(A)`, register `R`, reg-indirect `(R)`, displacement `A+(R)`, stack `TOS`. **Parentheses = dereference (one memory trip each).**
2. **Indirect (A) = 2 mem refs vs register-indirect (R) = 1 mem ref** — different container, register is cheaper.
3. **n-address trend:** fewer addresses → more instructions; accumulator = 1-addr, stack = 0-addr.
4. **Endianness:** big = MSB at lowest address; little = LSB at lowest address.
5. **Pre-index `(A+(R))` vs post-index `(A)+(R)`** — index inside vs outside the parentheses.
