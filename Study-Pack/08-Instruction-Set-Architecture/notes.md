# Chapter 08 — Instruction Set Architecture

> 🌱 **Starting from zero?** Perfect. This chapter is about the *tiny commands* a computer's brain actually obeys — things like "add these two numbers" or "fetch that value from memory." You don't need to remember anything from earlier chapters. We'll build it up slowly, everyday-comparison first, and only then put the proper names on things. Read top to bottom, no rushing.
>
> ⏱️ Give it about 2 hours. The middle of this chapter (addressing modes) is the single most exam-tested topic in the whole course, so go extra slow there.

---

## 🤔 First, why does this chapter exist?

A CPU can't read your Python or your essay. The only thing it truly understands is a small, fixed menu of *very simple commands*, each written as a pattern of 0s and 1s. That menu is called the **instruction set**.

Think of it like the buttons on a microwave. The microwave can't "make dinner." It only knows a handful of primitive actions — *set power*, *set time*, *start*, *stop*. Everything fancy you do is just a clever sequence of those few buttons. A CPU is the same: every program you've ever run is, underneath, a long sequence of these primitive instructions.

So this chapter answers: **what's on that menu of commands, and how is each command written down so the CPU knows what to do and where to find the data?**

The grown-up name for "the menu of commands plus the rules for writing them" is the **Instruction Set Architecture (ISA)**. It's the **contract between hardware and software**: the programmer (or compiler) promises to only use commands from the menu, and the hardware promises to obey every command on the menu.

By the end you'll be able to, in your own words:
- list the **pieces that make up one machine instruction**,
- name the **types of operations** a CPU can do,
- explain **0/1/2/3-address machines** and the trade-off between *how many* instructions and *how long* each one is,
- describe the **data types** an operand can be, and what **endianness** (byte order) means,
- and — the big one — **compute the effective address (EA)** for every addressing mode.

---

## 🗺️ The big picture first

Here's the loop a CPU runs forever: grab the next instruction, work out what it says, find the data it needs, do the thing, then move on to the next instruction. Every instruction has to tell the CPU four things:

```text
   ┌──────────────────────── A MACHINE INSTRUCTION ────────────────────────┐
   │ 1. WHAT to do?      → Operation code (opcode)                          │
   │ 2. WHAT data?       → Source operand(s)  (memory / register / I/O / immediate) │
   │ 3. WHERE result?    → Result operand     (same four areas)             │
   │ 4. WHAT's next?     → Next-instruction reference (usually implicit PC; explicit on branch) │
   └────────────────────────────────────────────────────────────────────────┘
```

In plain words, every instruction is like a tiny order ticket in a kitchen: *what to cook* (the operation), *which ingredients* (the input data), *where to put the finished plate* (the result), and *which ticket to read next* (usually just "the one after this," so it's left unsaid).

- **Stallings ch.13** covers the menu of commands (characteristics & operations).
- **Stallings ch.14** covers how each command points at its data (addressing modes & formats).

---

## 1. The pieces of one machine instruction

Let's open up a single instruction. Laid out, it looks like this:

```text
 OPCODE  | OPERAND 1 | OPERAND 2 | ... | (next-instr ref, usually implicit)
```

The first piece, the **opcode** (short for "operation code"), is just *which command from the menu* — add, subtract, load, store, and so on. The other pieces, the **operands**, are *the data the command works on*.

Now, where can that data actually live? Only in **four** places. Think of it like: when a chef needs an ingredient, it's either already in their hand, on the counter, written on the recipe card itself, or it has to be carried in from outside:

| Operand area | How you point at it | Plain meaning | Note |
|---|---|---|---|
| Main / virtual **memory** | a memory address | "it's in the big storeroom (RAM)" | needs address translation, cache check |
| **I/O device** | I/O module + device # | "carry it in from a gadget" | if memory-mapped → just a memory address |
| Processor **register** | a register name/number | "it's already in my hand" (fastest) | fastest |
| **Immediate** | the value sits *inside* the instruction | "the number is written on the recipe card" | no separate fetch needed |

> 🧠 **Easy way to remember:** **"MIRI"** — **M**emory, **I**/O, **R**egister, **I**mmediate. Those are the *only* four places an operand can be.

> ✍️ **Check yourself:** The instruction says "add 5 to the accumulator," and the number 5 is written right inside the instruction itself. Which of the four areas is that 5 in?
> <details><summary>Reveal answer</summary><b>Immediate</b> — the value is baked into the instruction, so there's no separate fetch to go get it.</details>

---

## 2. How an instruction is written: bits, fields, and mnemonics

Inside the machine, an instruction is just **a row of bits chopped into labelled sections** (the sections are called **fields**).

```text
 ┌────────┬──────────┬──────────┐
 │ Opcode │ Operand1 │ Operand2 │   ← A simple instruction format (Fig 13.2)
 │ 4 bits │  6 bits  │  6 bits  │
 └────────┴──────────┴──────────┘
```

In plain words: the first 4 bits say *which command*, the next two 6-bit chunks say *where the two operands are*. That's a 16-bit instruction split into three fields.

Of course, nobody wants to write `0100` to mean "add." So humans write short readable names called **mnemonics** (just memory-friendly nicknames), and each nickname maps to one fixed binary opcode:

| Mnemonic | Meaning | Mnemonic | Meaning |
|---|---|---|---|
| ADD | Add | LOAD | Load from memory → reg |
| SUB | Subtract | STOR | Store reg → memory |
| MUL | Multiply | DIV | Divide |

Example: `ADD R, Y` means *R ← R + contents of location Y* (the little arrow `←` just means "becomes" / "gets the value").

---

## 3. The menu of operation types

What kinds of commands are on the menu? They fall into a handful of families:

| Category | In plain words | Key actions |
|---|---|---|
| **Data transfer** | move data from one spot to another (no maths) | find address, translate, cache, read/write (MOV, LOAD, STOR, XCHG, PUSH, POP) |
| **Arithmetic** | the maths | ADD/SUB/MUL/DIV + ABS, NEG, INC, DEC; sets condition codes |
| **Logical** | fiddle with the individual bits | bitwise AND/OR/NOT/XOR/TEST + shift/rotate |
| **Conversion** | change a value's format | e.g. binary↔decimal; special logic |
| **I/O** | talk to a device | IN/OUT, INS/OUTS; issue command to I/O module |
| **System control** | privileged "OS-only" commands | kernel-mode only; mode management |
| **Transfer of control** | jump to a different instruction | BRANCH, SKIP, CALL/RET; update the PC |

**One family worth slowing down on — shifting and rotating bits.** Imagine the 8 bits of a value as 8 beads on a wire. You can slide them sideways. What happens to the bead that falls off, and what fills the gap, depends on which kind of shift:

| Input `10100110` | Op (3 bits) | Result | What happened |
|---|---|---|---|
| logical right | fill 0s | `00010100` | slide right, pour in 0s on the left |
| arithmetic right | copy sign bit | `11110100` | slide right, but copy the leftmost (sign) bit so negative stays negative |
| right rotate | wrap bits around | `11010100` | slide right, and beads that fall off the right reappear on the left |

> 🧠 **Easy way to remember:** **Arithmetic** shift *preserves the sign* (copies the top bit). **Logical** shift *fills with 0*. **Rotate** *wraps around* (nothing is lost).

---

## 4. Number of addresses (the classic exam topic)

Here's a subtle design choice: **how many operands does one instruction get to name?** Some machines let an instruction name three locations; some only one; some none at all. Each style is a different "personality" of CPU.

A kitchen analogy: imagine writing recipe steps.
- A **3-address** step can say everything at once: *"put (flour + sugar) into the bowl."* One rich step.
- A **1-address** machine has a single mixing bowl (the **accumulator**) and every step is *"add this to the bowl."* You can only ever talk about the bowl plus one ingredient, so you need more, simpler steps.
- A **0-address** machine works like a stack of plates: you pile ingredients up, and the operation just grabs the top two.

| # Addr | Symbolic | Meaning | Machine style |
|---|---|---|---|
| **3** | `OP A,B,C` | A ← B OP C | general-register |
| **2** | `OP A,B` | A ← A OP B | general-register (dest=src1) |
| **1** | `OP A` | AC ← AC OP A | **accumulator** (AC implied) |
| **0** | `OP` | T ← (T−1) OP T | **stack** (operands on top of stack) |

```text
 3-address:  fewest instructions, longest instructions (3 addr fields)
 2-address:  destination doubles as a source (overwrites it)
 1-address:  one implicit register = the ACCUMULATOR (AC)
 0-address:  no addresses — operands are PUSHed; OP pops top two (zero-address = STACK)
```

The "2-address" trick: since there's no room for a separate result location, the **destination doubles as one of the sources** — i.e. `A ← A OP B` quietly overwrites A. The "1-address" machine has one secret built-in register, the **accumulator (AC)**, so you never have to name it — `OP A` always means "AC ← AC OP A."

> 🧠 **Easy way to remember:** Going **3 → 2 → 1 → 0**, you name *fewer* addresses per instruction, so each instruction is *shorter* — but you need *more* of them. It's a see-saw: **instruction length vs instruction count.**

*(See the Worked Example section for the full hand-written code on each style.)*

---

## 5. What an operand can actually be (data types)

Bits are just bits — what they *mean* depends on how you treat them. Here's the family tree of operand data types:

```text
 OPERAND DATA TYPES
 ├── Numbers
 │     ├── Binary integer / fixed-point  (twos complement)
 │     ├── Binary floating-point         (limited precision)
 │     └── Decimal → PACKED DECIMAL: 1 digit = 4-bit code, 2 digits / byte
 ├── Characters (text strings)
 │     ├── ASCII / IRA  (7-bit, US standard)
 │     ├── EBCDIC       (8-bit, IBM mainframes)
 │     └── Unicode      (16/32-bit, universal)
 └── Logical data: n-bit unit, each bit independent (0/1, true/false)
```

In plain words:
- **Numbers** come in three styles: plain whole numbers (integers), numbers with a decimal point (floating-point), and a special "store decimal digits directly" style called **packed decimal**.
- **Packed decimal** crams *two* decimal digits into one byte, using 4 bits per digit. So the byte `0011 0111` reads as the two digits `37`.
- **Characters** (letters/symbols) are stored using a code. **ASCII/IRA** is the common 7-bit one, **EBCDIC** is the 8-bit IBM-mainframe one, and **Unicode** (16/32-bit) covers every language.
- **Logical data** means "just treat the word as a bag of independent on/off bits" — handy for masking (selecting some bits) or extracting (e.g. grabbing the rightmost 4 bits to turn an ASCII digit into packed decimal).

> ⚠️ **Exam trap:** The very same bits could be read as a *number* or as *logical data*. What decides the meaning isn't how it's stored — it's the **operation** you apply to it.

---

## 6. Byte ordering / endianness

When a value is too big for one byte (say a 32-bit value = 4 bytes), the CPU has to lay those 4 bytes out across 4 memory addresses. The only question is: **which byte goes in the lowest address — the big end or the little end?**

A plain-words analogy: writing the date. Some people write it big-end-first (year-month-day), some little-end-first (day-month-year). The *information* is identical; only the *order on the page* differs. Endianness is exactly that, for the bytes of a number.

```text
 Store 32-bit value  0x1A2B3C4D  starting at address 184:

           addr →  184    185    186    187
 BIG-endian        1A     2B     3C     4D     ← Most-Significant Byte FIRST (lowest addr)
 LITTLE-endian     4D     3C     2B     1A     ← Least-Significant Byte FIRST (lowest addr)
```

(The "most-significant byte" is the `1A` — the biggest-value end, like the "thousands" end of a number. The "least-significant byte" is the `4D` — the smallest-value end, like the "ones.")

- **Big-endian:** the big (most-significant) end goes first, at the lowest address. Reads left-to-right the way we write numbers. Used by SPARC, older PowerPC, ARM-BE, and **network byte order**.
- **Little-endian:** the little (least-significant) end goes first, at the lowest address. Used by x86 and most ARM.
- **Bi-endian:** ARM can switch between the two via an E-bit (Fig 13.5).

> 🧠 **Easy way to remember:** The name tells you which end comes **first** (lowest address). **Big**-endian = **Big** end first. **Little**-endian = **Little** (least-significant) end first.

> ⚠️ **Exam trap:** Endianness only reorders **whole bytes of multibyte data**. It does *not* flip the bits inside a byte, and it does *not* affect values sitting in registers. The #1 student mistake is reversing the rule — when in doubt, re-derive: "Little-endian = **little** end **first**."

> ✍️ **Check yourself:** Store `0x12345678` at address 100 in little-endian. What byte sits at address 100?
> <details><summary>Reveal answer</summary>The least-significant byte: <code>0x78</code> at addr 100, then 56, 34, 12 at 101/102/103.</details>

---

## 7. Addressing modes (slow down — this is the big one)

We said an operand can live in memory, a register, etc. But the instruction only has a small **address field** to point at it. An **addressing mode** is just *the rule for turning that little address field into the place where the data really is.* That final "place where the data really is" is called the **effective address (EA)**.

Two pieces of notation you'll see everywhere:
- `A` = the value sitting in the address field of the instruction.
- `(X)` = **"the contents of X"** — i.e. go to location X and read what's stored there. Every pair of parentheses means *one trip to fetch* (one dereference). `R` = a register.

A locker analogy for the main ones:
- **Immediate** — the thing you want *is the note itself*. No locker.
- **Direct** — the note gives you a locker number; the prize is in that locker.
- **Indirect** — the note gives you a locker number, but inside *that* locker is *another* locker number, and the prize is in the second locker. Two trips.
- **Register** — the prize is already in your hand (a register).
- **Register-indirect** — your hand holds a locker number; the prize is in that locker. One trip.

```text
 IMMEDIATE        Operand = A            [value is IN the instruction]
 DIRECT           EA = A                 [field holds the address]
 INDIRECT         EA = (A)               [field → memory cell holding the address]
 REGISTER         EA = R                 [operand is IN the register]
 REGISTER INDIR.  EA = (R)               [register holds the address]
 DISPLACEMENT     EA = A + (R)           [field + register → address]
 STACK            EA = top of stack      [implied; operate on TOS]
```

| Mode | Effective address | Pro | Con |
|---|---|---|---|
| Immediate | Operand = A | no memory ref | small operand |
| Direct | EA = A | simple | limited address space |
| Indirect | EA = (A) | large address space | multiple memory refs |
| Register | EA = R | no memory ref, fast | limited (few registers) |
| Register indirect | EA = (R) | large space, 1 fewer ref than indirect | extra memory ref |
| Displacement | EA = A + (R) | flexible | complex |
| Stack | EA = top of stack | no memory ref | limited applicability |

**Displacement = "address field plus a register."** This one combo has three named uses (all are `EA = A + (R)`, just with different jobs for the register):
- **Relative:** the register is the **PC** (program counter, which holds the address of the current instruction). So `EA = A + (PC)` — "this many steps from where I am now." Used for branches that work no matter where the program is loaded.
- **Base-register:** the register holds a **base address** (the start of a memory segment); A is the offset inside it. Supports segmentation.
- **Indexing:** A is the **base address** of, say, an array, and the register is the **index** (which element). Perfect for stepping through arrays in a loop. Three variants:
  - **Autoindexing:** `EA = A+(R); (R)←(R)+1` — fetch, then bump the index automatically.
  - **Preindexing:** `EA = (A + (R))` — add the index *first*, then dereference.
  - **Postindexing:** `EA = (A) + (R)` — dereference *first*, then add the index.

> ⚠️ **Exam trap (indirect vs register-indirect — students mix these up constantly):** **Indirect, `EA = (A)`** — a *memory cell* holds the address, so getting the operand costs **2 memory trips** (read the pointer, then read the operand). **Register-indirect, `EA = (R)`** — a *register* holds the address, so it costs only **1 memory trip** (the pointer was already in a fast register). Same idea, different container; register-indirect is cheaper.

> 🧠 **Easy way to remember:** Parentheses = "go fetch." Count the parentheses = count the memory trips. So register `R` (0 trips) → `(R)` reg-indirect / direct `A` (1 trip) → `(A)` indirect (2 trips).

> ✍️ **Check yourself:** Which mode is best for stepping through an array inside a loop, and why?
> <details><summary>Reveal answer</summary><b>Indexing</b> (a displacement mode, EA = A + (R)): A is the array's base address, and R is an index register you bump by 1 each loop. That walks element-by-element efficiently.</details>

---

## 8. Instruction formats & the opcode bit-budget

An instruction has a fixed number of bits to share out. Every bit you spend on one field is a bit you *can't* spend on another. Think of it like a fixed-size suitcase: more socks means less room for shirts.

```text
 ALLOCATION OF BITS — trade-offs for a fixed instruction length:
   #opcodes ↑  ⇒  bits for opcode ↑  ⇒  bits for addresses ↓
   #addr modes / address range / register count all compete for the same bits
```

In plain words: if you want to support *more distinct commands* (opcodes), you need more bits to number them, which leaves *fewer bits for the address* — so you can reach a *smaller* range of memory directly.

Design issues (from Stallings):
- **Instruction length:** balance memory size, bus width, and processor speed. It should equal (or be a multiple of) the **memory-transfer length**, and a multiple of the character length (8 bits).
- **Allocation of bits:** opcode size vs number of operands vs addressing-mode bits vs address range — they all fight over the same total.
- **Variable-length instructions** (VAX, x86): some instructions short, some long. Compact and flexible, but the decoder is more complex (it must fetch enough bytes to cover the longest possible instruction).
- **Expanding opcode:** let rare commands use longer opcodes so the common ones can stay short.

> 🧠 **Easy way to remember:** Fixed bits are a **budget**. Every bit you hand the opcode is a bit you take away from the address.

---

## 9. Transfer of control & procedures

Normally the CPU just runs the next instruction in line. But sometimes it needs to *jump* somewhere else. That's "transfer of control":
- **Branch** (jump — conditional or unconditional), **Skip** (skip the next instruction, e.g. ISZ), and **Procedure CALL/RET** (jump into a reusable chunk of code and come back).

Why procedures? Two reasons: **economy** (write the code once, reuse it everywhere) and **modularity** (break a big job into named pieces).

The clever bit is *coming back*. When you **CALL** a procedure, the CPU saves the **return address** (where to resume) — typically onto the **stack**, because a stack naturally supports calls-within-calls (nesting) and recursion. **RET** pops that address back off and jumps to it. The bundle of return-address + saved pointers + parameters + local variables for one call is a **stack frame** (in x86: CALL/ENTER/LEAVE/RET manage it).

```text
 main ──CALL──► P ──CALL──► Q          Stack (grows down):
                                        [ params/locals of Q ]  ← TOS
                                        [ return addr into P  ]
                                        [ params/locals of P  ]
                                        [ return addr into main]
```

Read the stack bottom-to-top as the story of how you got here: main called P, P called Q, and each call left a "breadcrumb" return address so the CPU can retrace its steps.

---

## ✅ You now understand…

Nice work — that was the toughest middle of the course. In plain terms, you now know:

1. The CPU only obeys a fixed **menu of simple commands** — that's the **instruction set**, and the whole contract is the **ISA**.
2. One instruction = **opcode + operands (+ where to go next).** Operands live in only four places: **Memory, I/O, Register, Immediate (MIRI).**
3. The **operation types**: data transfer, arithmetic, logical, conversion, I/O, system control, transfer of control.
4. **Number of addresses (3/2/1/0):** fewer addresses → shorter instructions but *more* of them. 1-address = accumulator; 0-address = stack.
5. **Data types:** numbers (integer / floating-point / packed-decimal), characters (ASCII/IRA, EBCDIC, Unicode), logical (loose bits).
6. **Endianness:** big = most-significant byte at the lowest address; little = least-significant byte first.
7. **Addressing modes & EA:** parentheses mean "go fetch," and you can compute the **effective address** for every mode.

If any of those feel shaky, re-read that section. When they all feel comfortable, do `exercises.md`, then test yourself with `mcq.md`.

---

## 🎓 When you're revising for the exam

Everything above is the understanding. For the exam, examiners reward crisp, exact wording. Keep these ready:

- **Operand locations:** memory, I/O, register, immediate (**MIRI**).
- **n-address machines:** `OP A,B,C` ⇒ A←B OP C (3); `OP A,B` ⇒ A←A OP B (2); `OP A` ⇒ AC←AC OP A (1, accumulator); `OP` ⇒ stack top two (0). **Fewer addresses ⇒ more instructions, each shorter.**
- **Endianness:** big = MSB at lowest address; little = LSB at lowest address; network order = big-endian.
- **EA formulas (memorise cold):** Immediate `operand=A` · Direct `EA=A` · Indirect `EA=(A)` · Register `EA=R` · Reg-indirect `EA=(R)` · Displacement `EA=A+(R)` (relative=PC, base, index) · Stack `EA=TOS`.
- **Memory-ref count:** register=0, immediate=0, direct=1, register-indirect=1, indirect=2.
- **Pre- vs post-index:** **pre** = index *inside* the parentheses `(A+(R))`; **post** = index *outside* `(A)+(R)`.
- **Bit budget:** opcode needs ⌈log₂(#opcodes)⌉ bits; the rest go to the address field.

> 🧠 **Mega-mnemonic:** **"MIRI · 3210 · BL · ()=fetch"** = the four operand areas · the address-count trade-off · Big/Little endianness · parentheses count memory trips.

**Likely exam question (worked example you must be able to reproduce):** *"Given the machine state below, compute the EA for each addressing mode."*

```text
 Instruction address field:  A = 500
 Register R3 = 1000        PC = 300        Index reg R5 = 4
 Memory:  M[500] = 800     M[1000] = 7777     M[504] = 9999
```

<details><summary>Model answer</summary>

| Mode | Formula | Computation | EA / Operand |
|---|---|---|---|
| Immediate | Operand = A | — | operand = **500** |
| Direct | EA = A | — | EA = **500** (operand = M[500] = 800) |
| Indirect | EA = (A) | (500) = M[500] = 800 | EA = **800** |
| Register | EA = R3 | operand in R3 | operand = **1000** |
| Register indirect | EA = (R3) | (1000) | EA = **1000** (operand = M[1000] = 7777) |
| Displacement (base) | EA = A + (R3) | 500 + 1000 | EA = **1500** |
| Relative | EA = A + (PC) | 500 + 300 | EA = **800** |
| Indexed | EA = A + (R5) | 500 + 4 | EA = **504** (operand = M[504] = 9999) |
| Preindexed | EA = (A + (R5)) | (500+4) = M[504] | EA = **9999** |
| Postindexed | EA = (A) + (R5) | M[500] + 4 = 800+4 | EA = **804** |

The trick: write the formula first, then substitute, and count parentheses = memory trips.
</details>

---

## 🔬 Worked Example

### (a) Evaluate `Y = (A − B) / (C + D × E)` on 0/1/2/3-address machines

**3-address** (A ← B OP C form):
```text
SUB  Y, A, B        ; Y ← A − B
MUL  T, D, E        ; T ← D × E
ADD  T, T, C        ; T ← C + T
DIV  Y, Y, T        ; Y ← Y / T      → 4 instructions
```

**2-address** (dest = one source, overwrites it):
```text
MOV  Y, A           ; Y ← A
SUB  Y, B           ; Y ← Y − B = (A−B)
MOV  T, D           ; T ← D
MUL  T, E           ; T ← D×E
ADD  T, C           ; T ← C + D×E
DIV  Y, T           ; Y ← (A−B)/(C+D×E)   → 6 instructions
```

**1-address** (accumulator AC implied; `OP A` ⇒ AC ← AC OP A):
```text
LOAD D          ; AC ← D
MUL  E          ; AC ← D×E
ADD  C          ; AC ← C + D×E
STOR T          ; T ← AC          (save denominator)
LOAD A          ; AC ← A
SUB  B          ; AC ← A − B
DIV  T          ; AC ← (A−B)/(C+D×E)
STOR Y          ; Y ← AC          → 8 instructions
```

**0-address** (stack; binary OP pops top two, pushes result). Postfix: `A B − C D E × + /`:
```text
PUSH A
PUSH B
SUB          ; TOS = A−B
PUSH C
PUSH D
PUSH E
MUL          ; TOS = D×E
ADD          ; TOS = C + D×E
DIV          ; TOS = (A−B)/(C+D×E)
POP  Y       ; Y ← result      → 10 instructions
```

> Pattern confirmed: **fewer addresses ⇒ more instructions** (4 → 6 → 8 → 10) but **shorter individual instructions**.

### (b) Endianness storage example
Store the 32-bit integer **`0xCAFEBABE`** beginning at byte address **2000**:

```text
 addr:   2000   2001   2002   2003
 BIG:     CA     FE     BA     BE      (MSB first)
 LITTLE:  BE     BA     FE     CA      (LSB first)
```
A little-endian CPU reading 4 bytes from 2000 reconstructs `0xCAFEBABE` correctly — *only when storer and reader agree on endianness*. Mismatch = byte-swapped garbage (the classic network-vs-host bug → use big-endian "network byte order").

### (c) Compute EA for each mode — given this machine state

```text
 Instruction address field:  A = 500
 Register R3 = 1000        PC = 300        Index reg R5 = 4
 Memory:  M[500] = 800     M[1000] = 7777     M[504] = 9999
```

| Mode | Formula | Computation | EA / Operand |
|---|---|---|---|
| Immediate | Operand = A | — | operand = **500** |
| Direct | EA = A | — | EA = **500** (operand = M[500] = 800) |
| Indirect | EA = (A) | (500) = M[500] = 800 | EA = **800** |
| Register | EA = R3 | operand in R3 | operand = **1000** |
| Register indirect | EA = (R3) | (1000) | EA = **1000** (operand = M[1000] = 7777) |
| Displacement (base) | EA = A + (R3) | 500 + 1000 | EA = **1500** |
| Relative | EA = A + (PC) | 500 + 300 | EA = **800** |
| Indexed | EA = A + (R5) | 500 + 4 | EA = **504** (operand = M[504] = 9999) |
| Preindexed | EA = (A + (R5)) | (500+4) = M[504] | EA = **9999** |
| Postindexed | EA = (A) + (R5) | M[500] + 4 = 800+4 | EA = **804** |

---

## 📝 Exam-Ready Techniques
- **n-address count check:** generate the code, then verify the trend 3<2<1<0 in instruction *count*. A binary op on a stack pops 2 / pushes 1.
- **EA computation:** write the formula first (`EA = ...`), then substitute. Watch the parentheses — one layer of `()` = one memory dereference.
- **Indirect vs register-indirect:** if the container is a *memory address field* → indirect `(A)`; if a *register* → register-indirect `(R)`.
- **Endianness:** decide MSB-or-LSB-at-lowest-address, then lay bytes left→right by increasing address.
- **Pre vs post index:** **pre** = index goes *inside* the parentheses `(A+(R))`; **post** = index *outside* `(A)+(R)`.
- **Memory-ref count:** register=0, immediate=0, direct=1, register-indirect=1, indirect=2.

## 🧷 One-Page Recap
- **Instruction = opcode + operands + (next-instr ref).** Operands live in Memory / I/O / Register / Immediate.
- **Operation types:** data transfer, arithmetic, logical, conversion, I/O, system control, transfer of control.
- **Addresses:** 3 (B OP C), 2 (A OP B into A), 1 (accumulator), 0 (stack). Fewer addr ⇒ more instructions.
- **Data types:** numbers (int/float/packed-decimal), characters (ASCII/IRA, EBCDIC, Unicode), logical (bits).
- **Endianness:** big = MSB at lowest addr; little = LSB at lowest addr.
- **Addressing modes & EA:** Immediate `=A` · Direct `A` · Indirect `(A)` · Register `R` · Reg-indirect `(R)` · Displacement `A+(R)` (relative/base/index) · Stack `TOS`.
- **Formats:** fixed bit budget — opcode size trades off against address range/modes; variable-length = compact but complex.

## 📚 Resources
- Stallings, *Computer Organization and Architecture*, 11e — Ch.13 (Instruction Sets: Characteristics & Functions) & Ch.14 (Addressing Modes & Formats).
- Neso Academy — Addressing Modes: https://www.youtube.com/watch?v=NzEWHU6cyTU
- Gate Smashers — Addressing Modes: https://www.youtube.com/watch?v=Nz0EUWBpbsM
- Gate Smashers — Instruction Format: https://www.youtube.com/watch?v=cWHwbEdRkdU
- GeeksforGeeks — Addressing Modes: https://www.geeksforgeeks.org/addressing-modes/
- TutorialsPoint — Addressing Modes: https://www.tutorialspoint.com/addressing-modes
