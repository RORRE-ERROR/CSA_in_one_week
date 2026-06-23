# Chapter 03 — Quick Self-Test (Multiple Choice)

> 🌱 **How to use this.** Once you've read `notes.md` and tried `exercises.md`, use these 15 questions to check what stuck. Decide on your answer (jot A/B/C/D) **before** opening the explanation. The goal isn't the score — it's understanding *why* the right answer is right, which the explanations spell out in plain words.
>
> Don't sweat a low score on the first pass. Re-take it the day before the exam and aim for 14–15.

---

**Q1.** Which is **not** one of von Neumann's three key concepts?
- A. Data and instructions stored in a single read-write memory
- B. Memory addressable by location regardless of data type
- C. Execution proceeds sequentially unless explicitly modified
- D. The program is fixed by hardwiring components together

**Q2.** Which register holds the **address of the next instruction** to be fetched?
- A. IR
- B. PC
- C. MAR
- D. MBR

**Q3.** During a fetch, the address of the instruction is placed in the ___ and the fetched word arrives in the ___.
- A. MBR, MAR
- B. IR, AC
- C. MAR, MBR
- D. PC, IR

**Q4.** The correct order of fetch-cycle transfers is:
- A. IR←MBR; MBR←Mem[MAR]; MAR←PC; PC++
- B. MAR←PC; MBR←Mem[MAR]; PC++; IR←MBR
- C. PC←PC+1; MAR←PC; IR←MBR; MBR←Mem[MAR]
- D. MBR←PC; MAR←MBR; IR←MAR; PC++

**Q5.** The **indirect** stage of the instruction cycle is used to:
- A. Increment the program counter
- B. Fetch the actual operand address via an extra memory access
- C. Check for pending interrupts
- D. Decode the opcode

**Q6.** Which is a **Program** class interrupt?
- A. Printer signals completion
- B. Memory parity error
- C. Arithmetic overflow
- D. Processor timer tick

**Q7.** The primary purpose of interrupts is to:
- A. Increase memory capacity
- B. Improve processing efficiency by overlapping I/O with CPU work
- C. Simplify the instruction set
- D. Reduce the number of buses

**Q8.** When an enabled interrupt is detected, the processor first:
- A. Sets PC to the handler address
- B. Disables the data bus
- C. Saves the context of the current program
- D. Resumes the user program

**Q9.** In **sequential (disabled)** multiple-interrupt handling, a new interrupt arriving during an ISR is:
- A. Serviced immediately, preempting the current ISR
- B. Lost permanently
- C. Held pending until interrupts are re-enabled
- D. Converted into a program interrupt

**Q10.** Priorities: printer=2, disk=4, comm=5 (nested). At t=15 a comm interrupt occurs while the printer ISR runs. Result:
- A. Comm waits until printer ISR finishes
- B. Printer ISR is preempted; comm ISR runs immediately
- C. Both run simultaneously
- D. Comm interrupt is discarded

**Q11.** The width of the **address bus** primarily determines:
- A. Data transfer rate
- B. Maximum memory capacity
- C. Number of control signals
- D. Clock frequency

**Q12.** Timing and command signals are carried on the:
- A. Data bus
- B. Address bus
- C. Control bus
- D. Local bus

**Q13.** On the address bus, the **high-order** bits typically:
- A. Select a location within a module
- B. Select which module on the bus
- C. Carry the data word
- D. Indicate data validity

**Q14.** A key advantage of **point-to-point** interconnect (QPI) over a shared bus is:
- A. It uses fewer transistors
- B. Direct pairwise links eliminate the need for arbitration
- C. It stores instructions and data together
- D. It removes the need for any error control

**Q15.** **PCIe** differs from PCI in that PCIe is:
- A. A wider shared parallel bus
- B. A point-to-point interconnect that replaces the bus scheme
- C. Only used for legacy devices
- D. Incapable of carrying memory transactions

---

## Answers — with the *why*

<details><summary>Q1</summary><b>D</b> — A, B and C <i>are</i> von Neumann's three concepts. A hardwired program is the <i>opposite</i> of the stored-program idea (you'd change the wiring, not load new code).</details>
<details><summary>Q2</summary><b>B</b> — The Program Counter holds the address of the <i>next</i> instruction and bumps up by 1 after each fetch. (IR holds the <i>current</i> one.)</details>
<details><summary>Q3</summary><b>C</b> — MAR takes the <i>address</i> ("which" slot), MBR receives the fetched <i>word</i> ("what" was there). MAR↔address bus, MBR↔data bus.</details>
<details><summary>Q4</summary><b>B</b> — Address first (MAR←PC), read it (MBR←Mem[MAR]), bump the PC, then load IR. The other orders shuffle these into nonsense.</details>
<details><summary>Q5</summary><b>B</b> — Indirect addressing means the operand field points to the <i>address of the address</i>, so the CPU needs one extra memory access to get the real operand address before fetching it.</details>
<details><summary>Q6</summary><b>C</b> — Arithmetic overflow comes from running the instruction itself → <b>Program</b> (internal). B = hardware failure, A = I/O, D = timer.</details>
<details><summary>Q7</summary><b>B</b> — Interrupts let the CPU do useful work instead of busy-waiting on slow I/O — that overlap is the whole point.</details>
<details><summary>Q8</summary><b>C</b> — It first <b>saves the context</b> (push PC/PSW/state) so it can return later; <i>then</i> it sets PC to the handler address. Saving has to come before the jump.</details>
<details><summary>Q9</summary><b>C</b> — During the ISR, interrupts are disabled, so the new one stays <b>pending</b> and is handled once interrupts are re-enabled. Nothing is lost.</details>
<details><summary>Q10</summary><b>B</b> — Comm (5) outranks printer (2), so the printer ISR is <b>preempted</b> (its state pushed) and the comm ISR runs immediately. That's the "VIP cuts the line" behaviour.</details>
<details><summary>Q11</summary><b>B</b> — Address-bus width = number of addressable locations = maximum memory capacity (and the I/O port range). Data-bus width sets <i>speed</i>, not capacity.</details>
<details><summary>Q12</summary><b>C</b> — The control bus carries <b>command</b> signals (what operation) and <b>timing</b> signals (when the data/address is valid).</details>
<details><summary>Q13</summary><b>B</b> — High-order bits pick <i>which module</i>; low-order bits pick the <i>location/port within</i> it.</details>
<details><summary>Q14</summary><b>B</b> — Direct pairwise links mean no shared medium, so <b>no arbitration</b> and concurrent transfers. QPI still uses layered protocols and error control, so D is wrong.</details>
<details><summary>Q15</summary><b>B</b> — PCIe is a <b>point-to-point</b> interconnect built to replace the bus-based PCI, supporting high-rate and time-dependent (isochronous) I/O.</details>

---

> 📊 **Scored low?** Totally normal on a first pass — go back to the matching `notes.md` section for anything you missed, then retry. **Scored 13+?** You've got Chapter 3 down.
