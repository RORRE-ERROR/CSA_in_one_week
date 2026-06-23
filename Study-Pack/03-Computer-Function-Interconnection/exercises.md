# Chapter 03 — Practice Questions

> 🌱 **How to use this file.** Read `notes.md` first. Then try each question **on your own** before opening the answer — even a rough or wrong attempt makes the answer stick far better than reading it cold. Peeking early feels productive but teaches you much less. Getting things wrong is exactly how you find your gaps, so don't worry about it.
>
> Questions go **easy → harder**: first just *recall* the pieces, then *trace* and *apply* them, then a couple of longer *exam-style* ones. Use standard Stallings register notation (PC, MAR, MBR, IR, AC).

---

## Warm-up: can you remember the pieces?

### 1. Classify the interrupts
Classify each event into Program / Timer / I/O / Hardware failure:
(a) divide by zero · (b) printer finished printing · (c) memory parity error · (d) OS scheduler tick · (e) attempt to execute an illegal opcode · (f) power supply failing.

<details><summary>Show answer</summary>

| Event | Class |
|-------|-------|
| (a) divide by zero | **Program** |
| (b) printer finished | **I/O** |
| (c) memory parity error | **Hardware failure** |
| (d) scheduler tick | **Timer** |
| (e) illegal opcode | **Program** |
| (f) power failing | **Hardware failure** |

The quick rule: did the **running instruction itself** cause it (overflow, divide-by-zero, illegal opcode)? → **Program** (internal). Came from an outside **device**? → **I/O**. Periodic / OS housekeeping? → **Timer**. Physical fault? → **Hardware failure**.
</details>

### 2. Bus reasoning
For each requirement, name the bus and justify: (a) increase max installable RAM; (b) double the data moved per transfer; (c) signal that the address lines now hold a valid address.

<details><summary>Show answer</summary>

(a) **Address bus** — its width sets how many distinct addresses exist, so it caps maximum memory capacity. Want to address more memory? Add address lines.
(b) **Data bus** — its width (number of data lines) is how many bits move at once; double the lines and you double the data per transfer, boosting performance.
(c) **Control bus** — the **timing** signals on it announce that the data/address lines are now valid; **command** signals say what operation to do. The address bus only carries the address bits, not the "it's valid now" signal.
</details>

### 3. Interrupt efficiency
Why are interrupts described as improving **processing efficiency**? What is the alternative and its cost?

<details><summary>Show answer</summary>

I/O devices are far slower than the CPU. **Without interrupts** (programmed I/O), after the CPU issues an I/O command it must **busy-wait / keep polling** — sitting idle for possibly thousands of instruction cycles, all wasted. **With interrupts**, the CPU keeps running other useful instructions while the device works in parallel; the device raises an **interrupt** when it's done, and only then does the CPU stop to service it. That overlap is the efficiency win. (Small catch: there's some **overhead** — handler instructions just to identify the cause and act.)
</details>

---

## Tracing and applying

### 4. Fetch-cycle register transfers
Write the register-transfer steps of the **fetch cycle**, assuming PC = 250.

<details><summary>Show answer</summary>

```text
1. MAR ← PC                ; MAR = 250 (address goes out on the address bus)
2. MBR ← Memory[MAR]       ; the instruction word is read into MBR via the data bus
3. PC  ← PC + 1            ; PC = 251 (now points at the next instruction)
4. IR  ← MBR               ; instruction is now in IR, ready to decode
```
The CPU then decodes IR and moves into the execute cycle. Remember: **MAR drives the address bus**, **MBR connects to the data bus**.
</details>

### 5. The indirect stage
What is the **indirect** stage in the instruction-cycle state diagram, and when does it occur?

<details><summary>Show answer</summary>

It happens when an instruction uses **indirect addressing** — where the operand field doesn't hold the operand's address, but the *address of the address* of the operand. So after **operand address calculation**, the CPU makes one **extra memory access** to fetch the *real* operand address, before the **operand fetch** stage. In the state diagram it sits **between** address calculation and operand fetch, and it costs one extra memory reference per level of indirection.
</details>

### 6. Steps of the interrupt cycle
List what the processor does when it detects a pending, enabled interrupt at the interrupt-check stage.

<details><summary>Show answer</summary>

1. **Suspend** the current program and **save its context** — push the PC and processor state (PSW/registers) onto the stack.
2. Set **PC** ← starting address of the **interrupt handler routine (ISR)**.
3. Proceed to the **fetch cycle** and run the ISR (part of the OS): figure out the cause and service the device.
4. On completion, **restore the context** (pop the PC/state back off the stack).
5. **Resume** the user program at the exact point it was interrupted.
</details>

### 7. Why three instruction cycles to add two numbers?
On a simple single-address ISA, adding the contents of location 940 to 941 takes **three** instruction cycles. Explain, and explain how a PDP-11-style ISA differs.

<details><summary>Show answer</summary>

A simple ISA needs three separate instructions, and each is its own full fetch+execute cycle:
1. **LOAD** 940 → AC
2. **ADD** 941 (AC ← AC + Mem[941])
3. **STORE** AC → 941

A more complex ISA (e.g. PDP-11 `ADD B,A`) does the whole thing in **one instruction cycle** — but its single *execute* phase makes **several memory references** inside that one cycle: fetch the ADD, read A, read B (you need two work registers so A isn't overwritten), add, then write the result back to A. The trade-off: **fewer cycles, but more work crammed into each execute phase**.
</details>

### 8. Sequential vs nested handling
A printer interrupt arrives at t=10 while the CPU runs a user program; at t=12 (during the printer ISR) a disk interrupt arrives. Describe the outcome under (a) sequential/disabled handling and (b) nested/priority handling where disk > printer.

<details><summary>Show answer</summary>

**(a) Sequential (disabled):** when the printer interrupt is taken, interrupts get **turned off**. The disk interrupt at t=12 just stays **pending**. The printer ISR runs to completion; *then* interrupts are re-enabled, the CPU notices the pending disk interrupt, runs the disk ISR, and finally resumes the user program. Order = strict arrival order, **no preemption**.

**(b) Nested (priority):** disk has higher priority, so at t=12 the printer ISR is **preempted** — its state is pushed onto the stack and the disk ISR runs immediately. When the disk ISR finishes, the printer ISR **resumes** where it left off, then the user program. Higher-priority work is served first.
</details>

### 9. DMA
What problem does DMA solve and how does the data path differ from non-DMA I/O?

<details><summary>Show answer</summary>

In ordinary I/O the **CPU relays every single word** between the I/O module and memory — that eats CPU time. **DMA (Direct Memory Access):** the CPU **grants the I/O module authority** to read/write memory directly, so the module issues its own memory commands and the **I/O↔memory transfer happens without tying up the CPU**. The CPU is typically interrupted only **once, when the whole block transfer is finished**.
```text
Non-DMA: I/O → CPU → MEMORY  (CPU relays each word)
DMA:     I/O ───────► MEMORY  (CPU is free)
```
</details>

---

## Exam-style (a bit longer)

### 10. The three-device priority timeline
Devices: printer (priority 2), disk (4), comm line (5). User starts at t=0. Printer interrupt at t=10; comm interrupt at t=15; disk interrupt at t=20. ISRs: comm done t=25, disk done t=35, printer done t=40. Walk through what is running over time (nested/priority).

<details><summary>Show answer</summary>

```text
t=0   User program running
t=10  Printer int → save user state → run Printer ISR (pri 2)
t=15  Comm int (5 > 2) → preempt Printer → save its state → run Comm ISR
t=20  Disk int (4 < 5) → lower than the running Comm → stays PENDING
t=25  Comm ISR done → about to resume Printer, BUT pending Disk (4 > 2)
      cuts in → run Disk ISR
t=35  Disk ISR done → resume Printer ISR (pri 2)
t=40  Printer ISR done → return to User program
```
The crucial moment is **t=25**: even though the Printer ISR was the one sitting on the stack waiting to resume, the CPU **re-checks all pending interrupts** when a handler ends and always picks the highest priority. The Disk (4 > 2) wins, so it runs before the Printer gets even one instruction.
</details>

### 11. Why move from buses to point-to-point?
Explain bus contention and how QPI/PCIe address it, including two QPI features and what PCIe replaces.

<details><summary>Show answer</summary>

**Bus contention:** the data and address lines are **shared** by every module, so **only one transfer can happen at a time**, and the system needs arbitration to decide whose turn it is. As you add devices and push for higher data rates, that shared bus becomes a **bottleneck** (electrical loading, propagation delay, arbitration cost).

**Point-to-point (QPI):** uses **multiple direct, pairwise connections** instead of one shared medium — so there's **no arbitration** and many pairs can communicate at once. Two QPI features: (1) a **layered protocol** (physical / link / routing / protocol) instead of raw control signals; (2) **packetized** transfer with control headers and **error-control codes** — the link layer works on **flits** (72-bit payload + 8-bit CRC) and does flow + error control, while the protocol layer ensures **cache coherency**.

**PCIe** is a point-to-point interconnect that **replaces the bus-based PCI**, giving the bandwidth for fast I/O (e.g. Gigabit Ethernet) and supporting time-dependent (**isochronous**) streams.
</details>
