# Chapter 08 — Quick Self-Test (Multiple Choice) · Instruction Set Architecture

> 🌱 **How to use this.** Once you've read `notes.md` and tried `exercises.md`, use these 15 questions to check what stuck. For the address-calculation ones, jot the formula and work it out **before** opening the explanation. Aim to understand *why* the right answer is right — the explanations say so in plain words.
>
> Don't worry about your score the first time. Re-take it the day before the exam and aim for 14–15.

---

**Q1.** Which is NOT one of the four areas where an operand can reside?
A. Main/virtual memory
B. Processor register
C. Cache tag directory
D. Immediate (inside the instruction)

**Q2.** In a 1-address instruction `SUB X`, the operation performed is:
A. X ← X − AC
B. AC ← AC − X
C. X ← AC − X
D. AC ← X − AC

**Q3.** Given `A = 300`, `M[300] = 750`, `M[750] = 90`. For **indirect** addressing, the effective address is:
A. 300
B. 750
C. 90
D. 1050

**Q4.** Register R = 400, M[400] = 555, address field A = 400. For **register-indirect** addressing the EA is:
A. 400
B. 555
C. 800
D. operand = 400

**Q5.** Displacement addressing with A = 1000 and register R containing 250 yields EA =
A. 250
B. 1000
C. 1250
D. (1000)

**Q6.** The 32-bit value `0x11223344` is stored at address 0 on a **little-endian** machine. The byte at address 0 is:
A. 0x11
B. 0x22
C. 0x33
D. 0x44

**Q7.** The 32-bit value `0xAABBCCDD` is stored at address 100 on a **big-endian** machine. The byte at address 103 is:
A. 0xAA
B. 0xBB
C. 0xCC
D. 0xDD

**Q8.** Relative addressing computes EA as:
A. A + (index register)
B. A + (PC)
C. (A)
D. top of stack

**Q9.** Preindexed addressing is defined as:
A. EA = (A) + (R)
B. EA = (A + (R))
C. EA = A + (R)
D. EA = (R)

**Q10.** Which addressing mode requires the MOST memory references to fetch the operand?
A. Register
B. Direct
C. Indirect
D. Immediate

**Q11.** A stack (0-address) machine evaluates expressions most naturally from:
A. infix notation
B. prefix (Polish) notation
C. postfix (reverse Polish) notation
D. binary-coded decimal

**Q12.** In packed decimal representation, one byte stores:
A. one decimal digit
B. two decimal digits (4 bits each)
C. four decimal digits
D. one ASCII character

**Q13.** Which character code is the 8-bit code used on IBM mainframes?
A. ASCII
B. IRA
C. EBCDIC
D. Unicode

**Q14.** A machine has 12-bit instructions and must encode 64 opcodes with one address operand. How many bits remain for the address field?
A. 4
B. 6
C. 8
D. 12

**Q15.** Compared with a 3-address machine, code on a 0-address (stack) machine for the same expression typically has:
A. fewer, longer instructions
B. more, shorter instructions
C. the same number of instructions
D. no instructions (hardware evaluates it)

---

## Answers — with the *why*

<details><summary>Q1</summary><b>C</b>. An operand can only live in one of four places — memory, an I/O device, a register, or immediate (inside the instruction). The cache tag directory is just internal CPU bookkeeping, never a place you point an operand at. (Remember <b>MIRI</b>.)</details>

<details><summary>Q2</summary><b>B</b>. A 1-address machine has one secret built-in register, the accumulator (AC). So `OP A` always means "AC ← AC OP A" — the AC is both a source and the destination. Therefore `SUB X` does AC ← AC − X.</details>

<details><summary>Q3</summary><b>B</b>. Indirect means EA = (A): go to address 300, and whatever's stored there (750) is the effective address. Two trips total to get the operand — but the *EA itself* is 750. (The operand would then be M[750]=90, which is the tempting wrong answer C.)</details>

<details><summary>Q4</summary><b>A</b>. Register-indirect means EA = (R): the address is already sitting in the register, so EA = contents of R = 400. The operand would be M[400] = 555 (the trap answer B), but the *EA* is 400.</details>

<details><summary>Q5</summary><b>C</b>. Displacement just adds the address field to the register's contents: EA = A + (R) = 1000 + 250 = 1250.</details>

<details><summary>Q6</summary><b>D</b>. Little-endian puts the little (least-significant) end first, at the lowest address. The least-significant byte of 0x11223344 is 0x44, so the byte at address 0 is 0x44.</details>

<details><summary>Q7</summary><b>D</b>. Big-endian puts the big (most-significant) end first: AA at 100, then BB at 101, CC at 102, DD at 103. So address 103 holds 0xDD (the least-significant byte ends up at the highest address).</details>

<details><summary>Q8</summary><b>B</b>. Relative addressing is just displacement where the register is the program counter: EA = A + (PC) — "this far from where I am now."</details>

<details><summary>Q9</summary><b>B</b>. "Pre" means the index is applied *before* the dereference, i.e. inside the parentheses: EA = (A + (R)). (Postindexing dereferences first: (A)+(R), which is answer A.)</details>

<details><summary>Q10</summary><b>C</b>. Count the parentheses = count the trips. Indirect (A) needs 2 memory references (read the pointer, then read the operand). Direct = 1; register and immediate = 0.</details>

<details><summary>Q11</summary><b>C</b>. A stack machine has no operand addresses — it just pushes values and each operator grabs the top two. That's exactly the order postfix (reverse Polish) notation gives you: operands first, operator last.</details>

<details><summary>Q12</summary><b>B</b>. Packed decimal squeezes two decimal digits into one byte, using 4 bits per digit (e.g. 0011 0111 = 37).</details>

<details><summary>Q13</summary><b>C</b>. EBCDIC is the 8-bit IBM-mainframe character code. ASCII/IRA are 7-bit; Unicode is 16/32-bit.</details>

<details><summary>Q14</summary><b>B</b>. It's a fixed bit budget. 64 opcodes need log₂64 = 6 opcode bits; that leaves 12 − 6 = 6 bits for the address field.</details>

<details><summary>Q15</summary><b>B</b>. Fewer addresses per instruction ⇒ each instruction is shorter (no room for explicit address fields), but you need more of them to do the same work. It's the 3→2→1→0 see-saw.</details>

---

> 📊 **Scored low?** That's normal on a first pass — go back to the matching `notes.md` section (especially section 7 on addressing modes) for anything you missed, then retry. **Scored 13+?** You've got Chapter 8 down.
