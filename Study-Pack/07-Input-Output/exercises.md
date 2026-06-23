# Chapter 07 — Practice Questions (Input / Output)

> 🌱 **How to use this file.** Read `notes.md` first. Then try each question **on your own** before opening the answer — even a rough attempt makes the idea stick far better than reading the solution does. Peeking early feels productive but teaches you less. And it's totally fine to get them wrong — that's exactly how you find the gaps to patch.
>
> The questions go **easy → harder**: first simple recall, then applying the ideas, then a couple of exam-style ones with numbers.

---

## Warm-up: can you remember the basics?

### 1. Why an I/O module at all?
List the three reasons a peripheral is **not** connected directly to the system bus, and match each to the I/O-module function that fixes it.

<details><summary>Show answer</summary>

1. **There are too many different kinds of device**, each with its own way of operating → impractical to build them all into the CPU. Fixed by the module's **device-communication / control logic** (one tailored interface per device).
2. **Speed mismatch** — devices are usually slower, sometimes burst faster → fixed by **data buffering** (the module holds data so neither side waits unnecessarily).
3. **Different data formats / word lengths** than the computer uses → fixed by the module's **processor-side interface + data registers**, which reformat data to the system word.

On top of that, the module supplies **control & timing** and **error detection** across the boundary.
</details>

---

### 2. Classify the techniques (Table 8.1)
Fill in the 2×2 grid: rows = "data passes through the processor" vs "direct to memory"; columns = "no interrupts" vs "uses interrupts."

<details><summary>Show answer</summary>

| | No interrupts | Uses interrupts |
|---|---|---|
| **Through processor** | Programmed I/O | Interrupt-driven I/O |
| **Direct to memory** | *(none — pointless without notification)* | **DMA** |

DMA is the only "direct to memory" technique, and it always ends with an interrupt to announce it's finished. There's no useful "direct-to-memory, no-interrupt" box — you'd never know when it was done.
</details>

---

### 3. Memory-mapped vs isolated I/O
A microcontroller's instruction set has **no** `IN`/`OUT` instructions, and only one read line + one write line (no MEM/IO select line). Which addressing scheme does it use, and name two consequences.

<details><summary>Show answer</summary>

**Memory-mapped I/O.** With no special I/O instructions and no select line, the device's registers have to live in the **single shared address space** and be reached with ordinary `load`/`store`.

Two consequences:
1. **The whole memory-access instruction set** can be used on device registers — flexible.
2. **The I/O ports use up part of the memory address space**, leaving less room for addressable RAM.
</details>

---

## Applying it

### 4. Polling cost
A device delivers one byte every 1 ms. The CPU runs at 1 GHz, and one iteration of a status-poll loop takes 5 cycles. Under **programmed I/O**, roughly how many CPU cycles are burned waiting between two bytes, and what fraction of CPU time is wasted?

<details><summary>Show answer</summary>

In 1 ms at 1 GHz, the CPU executes 1,000,000 cycles. Spinning in a 5-cycle poll loop, that's about **200,000 iterations** (1,000,000 ÷ 5) doing nothing useful before the next byte even arrives.

In plain terms, **~100% of the CPU's time is wasted** spinning, because the device is so much slower than the CPU and programmed I/O won't let the CPU do anything else. This is exactly why interrupt-driven I/O was invented for slow devices.
</details>

---

### 5. Interrupt overhead vs block size
Transferring N words by interrupt-driven I/O costs *c* overhead instructions per interrupt. DMA costs a fixed *S* (setup) + *F* (final interrupt). For c = 30, S = 50, F = 30, find the break-even N where DMA becomes cheaper, and comment.

<details><summary>Show answer</summary>

Interrupt cost = `30 × N`. DMA cost = `S + F = 80` (plus a little cycle-steal slowdown, but **no** per-word instructions).

Break-even: `30N = 80` → `N ≈ 2.67`, so from **N ≥ 3 words, DMA already costs fewer CPU instructions.**

Comment: in pure instruction-overhead terms, DMA wins almost immediately because its cost is **constant in N** (it doesn't grow with the block), while interrupt-driven grows linearly. In real life, DMA setup latency and bus arbitration mean it's only worth it for larger blocks — but the exam point is the **constant vs linear** comparison.
</details>

---

### 6. DMA is not free
"Once the CPU starts a DMA transfer, it is completely uninvolved until the data is in memory." Critique this statement.

<details><summary>Show answer</summary>

It's **misleading on two counts**:
1. The CPU **is** involved at the **start** (issuing the command: direction, device address, memory address, word count) and at the **end** (servicing the **completion interrupt**).
2. **During** the transfer, the CPU isn't totally uninvolved either — DMA does **cycle stealing**, briefly pausing the CPU for one bus cycle each time DMA needs the bus. The CPU is freed only from the **per-word transfer instructions**, not from all impact.

Correct version: the CPU is uninvolved in moving the *individual words*, but it participates at the start and end and is slightly slowed by cycle stealing in between.
</details>

---

### 7. Cycle stealing vs interrupt
Explain the difference between cycle stealing and an interrupt. Why does using cycle stealing for a block transfer cost the CPU far less than handling an interrupt per word?

<details><summary>Show answer</summary>

- **Interrupt:** the CPU finishes its current instruction, **saves its full context** (program counter, registers, status flags), branches to the service routine, runs it, then **restores the context** — heavyweight, and it happens **per word** in interrupt-driven I/O.
- **Cycle stealing:** the DMA module takes the bus for **one cycle**; the CPU is just **delayed one bus cycle** with **no context save/restore** and no program switch.

For a block, interrupt-driven I/O pays a full save / run-routine / restore **per word** (N times). DMA + cycle stealing pays only a one-cycle pause per word (no software overhead) plus a **single** interrupt at the very end. So the heavy software overhead drops from "N big interrupts" down to "one."
</details>

---

### 8. Device identification & priority
Three devices D1, D2, D3 sit on a daisy-chained interrupt-acknowledge line in that physical order from the CPU. D2 and D3 both interrupt at exactly the same moment. (a) Which is serviced first? (b) How would the answer change under a software poll? (c) Which methods are "vectored"?

<details><summary>Show answer</summary>

(a) **D2** — it is closer to the CPU on the chain, so it intercepts the acknowledge signal first, places its vector, and the acknowledge never reaches D3. Priority = **physical position on the chain**.

(b) Under a **software poll**, priority is set by **the order the ISR polls** the modules' status registers — decided in software, independent of physical wiring. Whichever of D2/D3 is polled first is serviced first.

(c) **Daisy chain** and **bus arbitration** are **vectored** (the device supplies its own vector). **Software poll** is **not** vectored (the CPU has to search). **Multiple interrupt lines** is effectively identified by the line itself but doesn't use a data-bus vector.
</details>

---

## Exam-style (a bit longer)

### 9. DMA configurations and bus traffic
Explain why a "single-bus, detached DMA" configuration uses the system bus **twice** per word, while a "separate I/O bus" or "integrated DMA-I/O" configuration uses it **once**. Which is more efficient?

<details><summary>Show answer</summary>

In **single-bus detached DMA**, both the device↔DMA transfer **and** the DMA↔memory transfer happen on the *same* system bus → **two bus cycles per word**, doubling how much DMA competes with the CPU for the bus.

In **integrated DMA-I/O**, the device↔DMA path is built into the combined module (off the system bus), so only the DMA↔memory step uses the system bus → **one cycle per word**. In **separate I/O bus**, the devices talk to DMA over a dedicated I/O bus, so again only DMA↔memory uses the system bus → **one cycle per word**.

The integrated and separate-I/O-bus configurations are **more efficient** (half the system-bus cycles), leaving the bus freer for the CPU.
</details>

---

### 10. I/O channels vs DMA
The I/O function evolved through six steps. (a) What makes an **I/O channel** (step 5) different from plain DMA (step 4)? (b) What makes an **I/O processor** (step 6) different from a channel?

<details><summary>Show answer</summary>

(a) With **DMA**, the CPU still issues each transfer command directly; the DMA module just moves the block. An **I/O channel** is a **processor with its own specialized I/O instruction set** — the CPU points it at an **I/O program in memory**, and the channel runs a whole sequence of I/O operations on its own, cutting CPU involvement further.

(b) An **I/O processor** (step 6) goes one step beyond: it has its **own local memory** and is effectively a **computer in its own right**, controlling a large set of devices with minimal CPU help. So: channel = its own instruction set; I/O processor = its own instruction set **and** its own memory.
</details>

---

### 11. External interface topologies
Match each to its topology and one signature feature: USB, FireWire, SCSI, Thunderbolt. Then define point-to-point vs multipoint.

<details><summary>Show answer</summary>

- **USB** — tiered-star / hierarchical **tree** via a root host controller; default for slower devices, multiple generations (1.5 Mbps → 10 Gbps SuperSpeed+).
- **FireWire (IEEE 1394)** — **daisy chain** (up to 63 devices/port); **hot-plug + automatic configuration** (no terminators, auto address assignment).
- **SCSI** — shared **bus** (multipoint), **parallel** transmission, up to 16/32 devices.
- **Thunderbolt** — high-speed serial, 10 Gbps each direction **+ 10 W power**, combines data/video/audio/power.

**Point-to-point** = a dedicated link between the I/O module and a single device. **Multipoint** = a shared external bus connecting many devices to the module.

Quick memory hook: **Tree-Chain-Bus** = USB / FireWire / SCSI.
</details>
