# Chapter 08 — Practice Questions · Instruction Set Architecture

> 🌱 **How to use this file.** Read `notes.md` first. Then try each question **on your own** before opening the solution — even a rough attempt makes it stick far better than reading the answer. It's completely fine to get them wrong; that's how you find your gaps.
>
> For the address-calculation ones, do what the pros do: **write the formula first (`EA = …`), then plug in the numbers.** Remember every pair of parentheses `( )` means "go fetch from memory once."
>
> Questions go **easy → harder**: first the addressing-mode mechanics, then code generation, then a couple of trickier format/classification ones.

---

### Problem 1 — Effective-address computation (mixed modes)
Given:
```text
A = 200 (address field)   R1 = 600   PC = 50   index R2 = 8
M[200] = 350   M[208] = 1234   M[600] = 999   M[350] = 42
```
Compute the EA (or operand) for: (a) immediate, (b) direct, (c) indirect, (d) register-indirect using R1, (e) displacement using R1, (f) relative, (g) indexed using R2.

<details><summary>Show answer</summary>

Write the formula, then substitute. Remember: `(X)` = "contents of X" = one memory trip.

| Mode | Formula | Work | Result |
|---|---|---|---|
| (a) immediate | operand = A | the value is in the instruction | operand = **200** |
| (b) direct | EA = A | field *is* the address | EA = **200** (operand M[200]=350) |
| (c) indirect | EA = (A) | go to M[200], find 350 | EA = **350** (operand M[350]=42) |
| (d) reg-indirect | EA = (R1) | the address is already in R1 | EA = **600** (operand M[600]=999) |
| (e) displacement | EA = A+(R1) | 200+600 | EA = **800** |
| (f) relative | EA = A+(PC) | 200+50 | EA = **250** |
| (g) indexed | EA = A+(R2) | 200+8 | EA = **208** (operand M[208]=1234) |

Notice (c) needed *two* trips (read the pointer 350, then read the operand), while (d) needed *one* (the pointer was already sitting in register R1).
</details>

---

### Problem 2 — Indirect vs register-indirect memory references
A direct-addressing instruction needs 1 memory reference to fetch its operand (after the instruction fetch). How many operand-fetch memory references does (a) indirect and (b) register-indirect addressing need? Explain the difference.

<details><summary>Show answer</summary>

Count the parentheses, count the trips.
- (a) **Indirect** EA = (A): **2** memory refs — one trip to read the pointer stored at M[A], then a second trip to read the actual operand at that address.
- (b) **Register-indirect** EA = (R): **1** memory ref — the pointer is *already* sitting in a fast register (no memory trip to get the address), then just 1 trip to read the operand.

Register-indirect saves one memory reference because the address lives in a register rather than out in slow memory. (Same locker idea — but your hand already holds the locker number.)
</details>

---

### Problem 3 — Pre-index vs post-index
Given `A = 100`, index register `R = 10`, and memory `M[100] = 500`, `M[110] = 700`, `M[510] = 88`.
Compute EA for (a) preindexed `(A+(R))` and (b) postindexed `(A)+(R)`.

<details><summary>Show answer</summary>

The only difference is whether you add the index **before** or **after** you dereference. "Pre" = index *inside* the parentheses; "post" = index *outside*.

- (a) **Preindexed** EA = (A+(R)): add first (100+10 = 110), *then* dereference → M[110] = **700**.
- (b) **Postindexed** EA = (A)+(R): dereference first (M[100] = 500), *then* add the index → 500+10 = **510** (operand M[510]=88).
</details>

---

### Problem 4 — 3-address code generation
Generate 3-address code for `X = (A + B) × (C − D)`. Count the instructions.

<details><summary>Show answer</summary>

Each 3-address instruction can name all three locations at once (`OP dest, src1, src2`), so you can compute a whole sub-result per line:

```text
ADD  T1, A, B      ; T1 ← A + B
SUB  T2, C, D      ; T2 ← C − D
MUL  X,  T1, T2    ; X  ← T1 × T2
```
**3 instructions.** Rich, but each instruction is long (it carries three address fields).
</details>

---

### Problem 5 — 1-address (accumulator) code generation
Generate accumulator (1-address) code for the same `X = (A + B) × (C − D)`. Recall `OP A` ⇒ AC ← AC OP A.

<details><summary>Show answer</summary>

Now there's just one mixing bowl (the accumulator AC). Every step can only talk about "the bowl plus one ingredient," so you LOAD a value in, operate, and STOR partial results out to make room:

```text
LOAD C        ; AC ← C
SUB  D        ; AC ← C − D
STOR T        ; T  ← AC   (save C−D out of the bowl)
LOAD A        ; AC ← A
ADD  B        ; AC ← A + B
MUL  T        ; AC ← (A+B)×(C−D)
STOR X        ; X  ← AC
```
**7 instructions** — notice all the extra LOAD/STOR traffic compared to the 3-address version. That's the price of naming fewer addresses per instruction.
</details>

---

### Problem 6 — 0-address (stack) code generation
Convert `X = (A + B) × (C − D)` to postfix, then write stack (0-address) code.

<details><summary>Show answer</summary>

A 0-address machine names *no* operands — it just pushes values onto a stack and each operator grabs the top two. That's exactly what **postfix** (operators written *after* their operands) describes:

Postfix: `A B + C D − ×`
```text
PUSH A
PUSH B
ADD          ; TOS = A+B  (pop B and A, push their sum)
PUSH C
PUSH D
SUB          ; TOS = C−D
MUL          ; TOS = (A+B)×(C−D)
POP  X
```
**8 instructions.** Trend across the chapter: 3-addr (3) < 1-addr (7) < 0-addr (8) — fewer addresses, more instructions.
</details>

---

### Problem 7 — Endianness layout
Store the 32-bit value `0xDEADBEEF` starting at byte address 4000. Show big- and little-endian byte layouts. Then: a little-endian machine reads the single byte at address 4000 — what value does it get?

<details><summary>Show answer</summary>

Split the value into its 4 bytes (`DE AD BE EF`), then lay them out by increasing address. Big-endian puts the big end first; little-endian puts the little end first:

```text
 addr:   4000  4001  4002  4003
 BIG:     DE    AD    BE    EF
 LITTLE:  EF    BE    AD    DE
```
On the little-endian machine, the lowest address holds the least-significant byte, so the byte at 4000 = **0xEF**.
</details>

---

### Problem 8 — Endianness round-trip bug
A big-endian server sends the 16-bit value `0x0102` as raw bytes; a little-endian client reads them into a 16-bit integer without conversion. What value does the client interpret, and why?

<details><summary>Show answer</summary>

The server, being big-endian (= network order), sends the bytes big-end-first: **01, then 02**. The little-endian client assumes the *first* byte it receives is the *least-significant* one — so it slots 01 into the low byte and 02 into the high byte, building `0x0201` = **513** instead of `0x0102` = 258.

This is the classic network-vs-host bug. Fix: convert received data to host order (e.g. the `ntohs` function). It only happens because the two ends disagreed about byte order.
</details>

---

### Problem 9 — Classify the operation type
Classify each: (a) PUSH, (b) IDIV, (c) XOR, (d) JNZ (jump if not zero), (e) IN, (f) HLT.

<details><summary>Show answer</summary>

Match each to its family from the operation-types menu:

| Instr | Category | Why |
|---|---|---|
| (a) PUSH | Data transfer | moves data onto the stack, no maths |
| (b) IDIV | Arithmetic | integer division |
| (c) XOR | Logical | bitwise operation |
| (d) JNZ | Transfer of control | jumps (changes the PC) if a condition holds |
| (e) IN | Input/Output | reads from a device |
| (f) HLT | System control | a privileged machine-state command |
</details>

---

### Problem 10 — Bit budget for instruction format
A machine has 16-bit instructions, must support **32 opcodes**, and uses a **single memory-address operand**. How many bits are left for the address field, and how many distinct addresses can it reach directly?

<details><summary>Show answer</summary>

It's a fixed budget: bits spent on the opcode can't be spent on the address.
- To number 32 different opcodes you need ⌈log₂32⌉ = **5 opcode bits** (because 2⁵ = 32).
- Address field = 16 − 5 = **11 bits** ⇒ 2¹¹ = **2048** directly addressable locations.

This is the trade-off in action: more opcodes ⇒ a smaller directly reachable address space (which you'd then stretch using indirect/displacement modes).
</details>

---

### Problem 11 — Shift/rotate evaluation
For input `11001010`, give the result of (a) logical right shift by 2, (b) arithmetic right shift by 2, (c) left rotate by 2.

<details><summary>Show answer</summary>

Picture the 8 bits as beads you slide. The difference is what fills the gap (and whether bits wrap):
- (a) **Logical right 2:** slide right, pour 0s into the gap on the left → `00110010`.
- (b) **Arithmetic right 2:** slide right, but copy the sign bit (here it's 1) so a negative number stays negative → `11110010`.
- (c) **Left rotate 2:** slide left, and the two beads that fall off the left reappear on the right (nothing lost) → `00101011`.
</details>
