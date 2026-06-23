# Chapter 07 — Quick Self-Test (Multiple Choice)

> 🌱 **How to use this.** Once you've read `notes.md` and tried `exercises.md`, use these 15 questions to check what stuck. Pick an answer in your head (or jot A/B/C/D) **before** opening the explanation. Aim to understand *why* the right answer is right — each explanation says so in plain words.
>
> Don't worry about your score the first time. Re-take it the day before the exam and aim for 14–15.

---

**Q1.** The main reason peripherals connect through an I/O module instead of straight to the system bus is:
- A. To increase the CPU clock speed
- B. Because devices vary in operation, speed, and data format
- C. To add more registers to the CPU
- D. To eliminate the need for main memory

**Q2.** Which is NOT one of the four I/O commands an addressed module accepts?
- A. Control
- B. Test
- C. Interrupt
- D. Write

**Q3.** In **memory-mapped I/O**:
- A. Devices and memory share one address space and use normal load/store
- B. A separate I/O address space is used with IN/OUT instructions
- C. A MEM/IO select line is required
- D. Only a limited set of I/O instructions is available

**Q4.** Which technique keeps the CPU busy-waiting (polling status) until the device is ready?
- A. Interrupt-driven I/O
- B. DMA
- C. Programmed I/O
- D. Cycle stealing

**Q5.** In interrupt-driven I/O transferring a block of N words, the CPU is interrupted:
- A. Once for the whole block
- B. Once per word (N times)
- C. Never
- D. Only at the start

**Q6.** During a DMA block transfer, the CPU is directly involved:
- A. For every word
- B. Only at the start (command) and end (completion interrupt)
- C. Never at all
- D. Only at the end

**Q7.** **Cycle stealing** refers to:
- A. The CPU stealing cycles from the DMA module
- B. DMA taking one bus cycle, pausing the CPU without a context switch
- C. An interrupt that saves and restores full CPU state
- D. The DMA module halting the CPU until the entire block is done

**Q8.** Which device-identification method is **not** vectored and is the slowest?
- A. Daisy chain
- B. Bus arbitration
- C. Software poll
- D. Multiple interrupt lines

**Q9.** On a daisy-chained interrupt-acknowledge line, the highest-priority device is:
- A. The one physically farthest from the CPU
- B. The one with the smallest vector number
- C. The one physically closest to the CPU
- D. Chosen randomly by the arbiter

**Q10.** The main reason DMA is preferred over interrupt-driven I/O for large transfers:
- A. DMA needs no I/O module
- B. DMA avoids per-word CPU overhead by moving the block directly to memory
- C. DMA uses memory-mapped addressing
- D. DMA does not require an interrupt at all

**Q11.** A "single-bus, detached DMA" configuration uses the system bus per transferred word:
- A. Zero times
- B. Once
- C. Twice
- D. Four times

**Q12.** An I/O module that has become a **processor with its own specialized instruction set**, executing an I/O program in memory, is called:
- A. A DMA controller
- B. An I/O channel
- C. A peripheral
- D. A bus arbiter

**Q13.** Which external interface uses a **daisy-chain** configuration with hot-plugging and automatic configuration?
- A. USB
- B. SCSI
- C. FireWire (IEEE 1394)
- D. PCI Express

**Q14.** USB devices are organized as:
- A. A shared parallel bus
- B. A hierarchical tree (tiered star) under a root host controller
- C. A daisy chain of up to 63 devices
- D. A switched fabric

**Q15.** A **point-to-point** external interface is best described as:
- A. A shared bus connecting many devices
- B. A dedicated link between the I/O module and a single device
- C. A wireless connection
- D. A connection requiring bus arbitration

---

## Answers — with the *why*

<details><summary>Q1</summary><b>B.</b> Peripherals differ widely from the CPU bus in <i>operating method, speed, and data format</i> — the I/O module bridges all three (translate, buffer, control). Clock speed, registers, and memory are unrelated to why the module exists.</details>

<details><summary>Q2</summary><b>C.</b> The four commands are <b>Control, Test, Read, Write</b> (C-T-R-W). "Interrupt" is a signal the module <i>sends</i>, not a command it <i>receives</i> when addressed.</details>

<details><summary>Q3</summary><b>A.</b> Memory-mapped I/O shares a single address space with memory and uses ordinary load/store — that's the whole point of it. B, C, and D all describe <b>isolated</b> I/O (separate space, special instructions, select line).</details>

<details><summary>Q4</summary><b>C.</b> Programmed I/O has the CPU keep reading the status register (busy-wait / polling) until ready, then move the word itself. Interrupt-driven and DMA both free the CPU from that busy-waiting.</details>

<details><summary>Q5</summary><b>B.</b> Interrupt-driven I/O still moves one word per interrupt, so a block of N words causes N interrupts. (DMA is the one that interrupts only once for the whole block.)</details>

<details><summary>Q6</summary><b>B.</b> DMA frees the CPU from per-word work, but the CPU still issues the command at the <b>start</b> and services the <b>completion interrupt</b> at the <b>end</b>. So it's not "never involved."</details>

<details><summary>Q7</summary><b>B.</b> Cycle stealing = DMA grabs the bus for one cycle, briefly pausing the CPU with <b>no context save/restore</b>. It is explicitly <i>not</i> an interrupt (C), and it does not halt the CPU for the whole block (D).</details>

<details><summary>Q8</summary><b>C.</b> Software poll makes the CPU read each module's status to find the culprit — slow and <b>non-vectored</b>. Daisy chain and bus arbitration are both vectored (the device supplies its own vector).</details>

<details><summary>Q9</summary><b>C.</b> The device closest to the CPU intercepts the acknowledge signal first and stops it propagating, so it gets the highest priority. Priority = physical position on the chain.</details>

<details><summary>Q10</summary><b>B.</b> DMA moves the block directly between device and memory, removing the per-word CPU overhead (instructions/interrupts) of programmed and interrupt-driven I/O. It still uses one interrupt at the end (so D is wrong) and still needs a DMA/I/O module (so A is wrong).</details>

<details><summary>Q11</summary><b>C.</b> In detached single-bus DMA, both device↔DMA and DMA↔memory use the same system bus → <b>two</b> bus cycles per word. Integrated DMA-I/O and separate-I/O-bus configs use it once.</details>

<details><summary>Q12</summary><b>B.</b> An <b>I/O channel</b> is a processor with its own specialized I/O instruction set, executing an I/O program in memory. (An I/O <i>processor</i> goes further by adding its own local memory.) A DMA controller doesn't run an I/O program.</details>

<details><summary>Q13</summary><b>C.</b> FireWire (IEEE 1394) uses a daisy-chain configuration (up to 63 devices/port) with hot-plugging and automatic configuration. USB is a tree; SCSI is a shared bus.</details>

<details><summary>Q14</summary><b>B.</b> USB uses a hierarchical tree (tiered-star) topology controlled by a root host controller. The daisy chain of 63 devices (C) is FireWire; the shared parallel bus (A) is SCSI; the switched fabric (D) is InfiniBand.</details>

<details><summary>Q15</summary><b>B.</b> Point-to-point = a dedicated link to one device. Multipoint is the shared external bus connecting many devices.</details>

---

> 📊 **Scored low?** That's normal on a first pass — go back to the matching `notes.md` section for anything you missed, then retry. **Scored 13+?** You've got Chapter 7 down.
