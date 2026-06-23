# Chapter 03 — Computer Function & Interconnection

> 🌱 **Starting from zero?** Great — this chapter is where a computer stops being a "magic box" and starts making sense. In Chapter 1 we named the big parts (CPU, memory, I/O, bus). Here we watch them actually *work*: how the CPU runs a program one tiny step at a time, how it deals with slow devices without wasting time, and how all the parts pass messages along shared wires. We'll use everyday comparisons before any technical word.
>
> ⏱️ Take about 2 hours. Read slowly, top to bottom. The two big stars of this chapter — the **instruction cycle** and **interrupts** — are exam favourites, so we go extra-slow there.

---

## 🤔 First, why does this chapter exist?

You know a computer "runs programs." But *how*, exactly? A program is just a long list of instructions sitting in memory. Something has to pick them up one by one, understand each one, and carry it out — forever, billions of times a second. That repeating routine is the heart of every computer, and most of this chapter is spent on it.

Two extra problems come up once you understand that routine:
1. **Devices are slow.** A printer or disk is *thousands* of times slower than the CPU. If the CPU just sat and waited for them, it would waste almost all its time. The fix is called an **interrupt** — and it's so important we'll spend three sections on it.
2. **The parts need to talk.** The CPU, memory, and I/O all live in separate boxes. They pass data along shared wires called **buses**. We'll see what's on those wires and why modern machines moved to a faster design.

By the end you'll be able to, in your own words:
- explain the **stored-program idea** (program lives in memory) and the **von Neumann** model,
- name the **key registers** and trace a **fetch–execute cycle** step by step,
- explain **what an interrupt is, why it exists, and exactly what the CPU does** when one happens,
- handle **multiple interrupts** (queue vs. cut-the-line),
- describe the **three buses** and why machines moved to **point-to-point** links.

---

## 1. The stored-program idea (von Neumann)

Imagine a player piano. An old one had the tune *built into the machine* — to play a new song you'd practically rebuild it. A better player piano reads a **paper roll**: the song is written on a roll you feed in. Want a new song? Swap the roll. Same machine, new music.

A computer works like the second piano. The "song" is the **program**, and it's stored as data you can load and swap — not wired permanently into the hardware. This is the **stored-program concept**, and it's the single idea that makes a computer a flexible, general-purpose machine.

- **Plain English:** the program (the list of instructions) lives *in memory*, right alongside the data it works on. To run a different program, you just load different bits into memory — no rewiring.
- **Formal term:** this is the **von Neumann architecture**, named after John von Neumann and the **IAS computer** (Institute for Advanced Studies, Princeton).

Von Neumann's model rests on three key ideas:

| # | Concept | Plain meaning |
|---|---------|---------------|
| 1 | Single read-write memory | **Data and instructions live together** in one memory |
| 2 | Addressable by location | You find things **by their address (location)**, not by what kind of thing they are |
| 3 | Sequential execution | Instructions run **one after the next**, top to bottom, unless one explicitly says "jump elsewhere" |

The opposite of a stored program is a **hardwired program** — the behaviour is fixed by *physically wiring* the components (like the old piano). The breakthrough was realising you can put the control logic *in memory as data you can change*, so the same hardware runs any program.

> 🧠 **Remember it as:** *"Same box, swap the code."* Data + instructions share one addressable memory, so you reprogram by loading new bits, not by rewiring.

> ⚠️ **Exam trap:** "addressable by location, *regardless of data type*" means **memory has no idea** whether a word is an instruction or a number. The meaning comes entirely from *how the CPU chooses to use it*.

> ✍️ **Check yourself:** What's the difference between a stored-program computer and a hardwired one?
> <details><summary>Reveal answer</summary>In a <b>stored-program</b> machine the program sits in read-write memory as data and can be changed by loading new bits. A <b>hardwired</b> program is fixed by the physical wiring of components — to change it you change the hardware.</details>

---

## 2. The key registers (the actors in the story)

Before we watch the CPU work, meet its **registers** — tiny, ultra-fast storage slots *inside* the CPU. Think of them as the few sticky-notes on the desk that the CPU keeps right in front of it while working. There are five you must know, and each has one clear job.

| Register | Full name | Think of it as… | Its one job |
|----------|-----------|-----------------|-------------|
| **PC** | Program Counter | A **bookmark** | Holds the **address of the *next* instruction** to fetch. Bumps up by 1 after each fetch. |
| **IR** | Instruction Register | The **instruction in your hand** | Holds the instruction the CPU is **working on right now** while it's decoded/executed. |
| **MAR** | Memory Address Register | A note saying **"which" slot** | Holds the **address** the CPU wants to read/write. Connects to the **address bus**. |
| **MBR** | Memory Buffer Register | A note holding **"what"** | Holds the actual **data** going to or coming from memory. Connects to the **data bus**. |
| **AC** | Accumulator | The **scratch pad for sums** | Holds operands and results for the **ALU** (the calculator). |

```text
        ┌────────────── PROCESSOR ──────────────┐
        │  PC ── address of the NEXT instruction │
        │  IR ── the CURRENT instruction         │      ┌──────────┐
        │  AC ── ALU work register     MAR ──────┼─addr→│          │
        │                              MBR ◄─────┼─data─┤  MEMORY  │
        └────────────────────────────────────────┘      └──────────┘
```

The diagram shows the two memory registers reaching out to memory: **MAR** sends the *address* over the address bus ("look at slot 940"), and **MBR** carries the *data* back over the data bus ("here's what was in slot 940").

> 🧠 **Remember it as:** **MAR = "which" (address), MBR = "what" (data).** MAR rides the address bus; MBR rides the data bus. And **PC = next**, **IR = now**.

> ✍️ **Check yourself:** Which register tells you where the *next* instruction is, and which holds the one being executed *now*?
> <details><summary>Reveal answer</summary><b>PC</b> (Program Counter) = the bookmark for the <i>next</i> instruction. <b>IR</b> (Instruction Register) = the instruction being worked on <i>now</i>.</details>

---

## 3. The instruction cycle (fetch → execute)

Here is the beating heart of the computer. To run a program, the CPU repeats one simple loop over and over: **go fetch the next instruction, then do it.** That loop is the **instruction cycle**, and it has two halves: the **fetch cycle** and the **execute cycle**.

```text
   ┌──────────────┐        ┌──────────────┐
   │  FETCH       │ ─────► │  EXECUTE     │ ─────► (then fetch the next one…)
   │  go get the  │        │  carry out   │
   │  next        │        │  the         │
   │  instruction │        │  instruction │
   └──────────────┘        └──────────────┘
```

**Fetch — "go get the next instruction":**
1. The **PC** holds the address of the next instruction.
2. That address is copied into **MAR**; memory is read; the instruction lands in **MBR** and is copied into **IR**.
3. The **PC is bumped up** (now points at the instruction after this one).
4. The CPU **decodes** the instruction in IR — figures out what it's asking for.

**Execute — "now do it":** what an instruction actually does falls into a few categories:
- **Processor ↔ Memory** — move data between CPU and memory.
- **Processor ↔ I/O** — move data between CPU and an I/O device.
- **Data processing** — arithmetic or logic on data (the ALU does this).
- **Control** — change the order of execution (e.g. a *jump* writes a new value into the PC).
- …or a combination of these.

> ⚠️ **Exam trap (instructions vs. memory references):** on a *simple* CPU, "add the contents of 940 to 941" needs **three separate instructions** (LOAD, ADD, STORE) — three full instruction cycles. A *fancier* CPU (e.g. PDP-11 `ADD B,A`) does the same thing in **one** instruction cycle — but during its single *execute* phase it makes **several memory references** (read A, read B, write A). Fewer cycles ⇒ each instruction does more work.

### The instruction-cycle state diagram (with indirect & interrupt stages)

The simple "fetch then execute" hides two extra detours the CPU sometimes takes. Stallings draws the full picture as a **state diagram** (his Figure 3.5). Don't be scared by it — read it as a flowchart of "what stage am I in?"

```text
   ┌──────────────────────────────────────────────────────────────┐
   │                                                                │
   ▼                                                                │
┌────────────────┐   ┌──────────────┐   ┌──────────────────┐       │
│ Instruction    │──►│ Instruction  │──►│ Operand          │       │
│ Address Calc.  │   │ Fetch        │   │ Address Calc.    │◄──┐   │
└────────────────┘   └──────────────┘   └────────┬─────────┘   │   │
        ▲                                         │ (indirect)  │   │
        │                                         ▼             │   │
        │                              ┌──────────────────┐     │   │
        │                              │ Operand Fetch    │─────┘   │
        │                              └────────┬─────────┘         │
        │                                       ▼                   │
        │                              ┌──────────────────┐         │
        │                              │ Data Operation   │         │
        │                              │ (execute)        │         │
        │                              └────────┬─────────┘         │
        │                                       ▼                   │
        │                              ┌──────────────────┐         │
        │                              │ Operand Store    │─────────┘ (multiple operands)
        │                              └────────┬─────────┘
        │                                       ▼
        │                              ┌──────────────────┐
        └──────────────────────────────│ Interrupt Check  │
              (no interrupt → next)     │ / Interrupt      │
                                        └──────────────────┘
   FETCH ─────────────────────────────  EXECUTE ─────────  INTERRUPT
```

In plain words, reading left to right:
- **Work out where the instruction is, go fetch it, decode it** (the fetch half).
- **Work out where the operand is** — and here's detour #1: the **indirect stage**. If the instruction uses *indirect addressing*, the address field doesn't hold the operand's address — it holds *the address of the address*. So the CPU makes one extra memory trip to find the real address before fetching the operand.
- **Fetch the operand(s), do the operation, store the result.** These operand steps can **loop** because one instruction might have several operands.
- **Check for an interrupt** — detour #2. After executing, the CPU asks "did any device need me while I was busy?" If yes, it handles it (next section); if not, it loops back to fetch the next instruction.

> ✍️ **Check yourself:** Why do the "operand" boxes loop back on themselves?
> <details><summary>Reveal answer</summary>An instruction may have <b>more than one operand</b>, so the address-calculation / fetch (and store) steps repeat once per operand before the cycle moves on.</details>

---

## 4. Interrupts — why they exist, and the four classes

Now the second star of the chapter. Picture yourself cooking and you put a kettle on to boil. You have two choices:
- **Stand and stare at the kettle** until it whistles, doing nothing else. (Wasteful!)
- **Go chop vegetables**, and when the kettle *whistles* you stop, deal with it, then go back to chopping.

The whistle is an **interrupt**. The CPU faces exactly this problem: most I/O devices (printers, disks, keyboards) are *agonisingly slow* compared to the CPU.

- **Plain English:** an interrupt is a **signal from a device (or condition) that says "stop what you're doing for a moment and deal with me."** It lets the CPU get on with other work instead of standing and staring (the "stand and stare" approach is called **busy-waiting** or **polling**).
- **Why it matters (the purpose):** interrupts **improve processing efficiency** by letting the CPU's work *overlap* with slow I/O.

### The four classes of interrupt (Stallings Table 3.1)

| Class | Where it comes from | Examples |
|-------|---------------------|----------|
| **Program** | From the **running instruction itself** (internal!) | arithmetic **overflow**, **divide by zero**, illegal instruction, memory-access violation |
| **Timer** | A **timer inside the processor** | lets the OS do things on a regular schedule (e.g. switch tasks) |
| **I/O** | An **I/O controller** | "I'm finished", "I need service", or "I hit an error" |
| **Hardware failure** | A **physical fault** | power failure, memory parity error |

> 🧠 **Remember it as:** **P-T-I-H → "Programs Take Interrupts Hard."** Program, Timer, I/O, Hardware failure.

> ⚠️ **Exam trap:** **Program** interrupts (overflow, divide-by-zero) are caused *by the instruction the CPU is running* — they are **internal**. Don't confuse them with **I/O** interrupts, which come from an *external* device.

### Picture: with vs. without interrupts

```text
NO INTERRUPT (busy-wait)            WITH INTERRUPT (overlap)
─────────────────────────          ──────────────────────────
USER: code 1                        USER: code 1
USER: WRITE → I/O prep              USER: WRITE → I/O prep
WAIT ........ idle ........         USER: code 2 (runs while I/O works!)
I/O: actual transfer                I/O: actual transfer (concurrent)
USER: code 2 (only now)             ─INT─► handler finishes the I/O
USER: finish                        USER: resume code 2
```

On the left, the CPU sits idle ("WAIT") for possibly thousands of cycles. On the right, it keeps running useful code and only pauses briefly when the device signals it's done. Same work, far less waste.

> 💡 **Two sub-cases worth knowing.** *Short I/O wait:* the device finishes before the program needs it again → smooth overlap. *Long I/O wait:* the program reaches its *next* I/O request before the first one finishes → it has to **stop and wait** at that point until the earlier I/O completes.

---

## 5. The interrupt cycle — exactly what the CPU does

So a device "whistled." What happens, precisely? This is a classic exam question, so memorise the steps. The CPU checks for interrupts at the **end of execute** (the Interrupt Check stage from §3). If one is pending **and** interrupts are enabled:

1. **Finish the current instruction first.** The CPU never stops mid-instruction — it completes the one in progress.
2. **Save the context.** Push the **PC** and the processor status (the **PSW** — Program Status Word) and registers onto the **stack**, so the CPU can come back exactly where it left off. (This is like jotting down "I was on step 3 of chopping" before answering the kettle.)
3. **Load the PC with the handler's address.** The PC is set to the start of the **interrupt handler routine** (the **ISR** — Interrupt Service Routine), which is part of the OS.
4. **Run the handler.** The CPU fetches and executes the ISR: it works out *which* device/condition interrupted and *services* it (e.g. sends the next chunk of data).
5. **Restore the context.** Pop the saved PC/PSW/registers back off the stack.
6. **Resume the user program** at the *exact* point it was interrupted, as if nothing happened.

```text
          INTERRUPT CYCLE (inserted after EXECUTE)  — Stallings Fig. 3.7
   ┌─────────┐   ┌──────────┐   ┌───────────────────┐
   │ Fetch   │──►│ Execute  │──►│ Interrupts enabled │
   └─────────┘   └──────────┘   │ & one pending?     │
        ▲                       └─────────┬─────────┘
        │                          no │    │ yes
        │                             │    ▼
        │                             │   ┌─────────────────────────┐
        │                             │   │ Save context (push PC,  │
        │                             │   │ PSW); PC ← handler addr  │
        │                             │   └────────────┬────────────┘
        └─────────────────────────────┘                │
                  (continue normally)                   ▼
                                            (fetch the handler's instructions)
```

> ⚠️ **Exam trap:** interrupts aren't *free*. There's **overhead** — extra handler instructions just to figure out the cause and decide what to do, plus the save/restore work. They're a big win overall, but not zero-cost.

> ✍️ **Check yourself:** What two things does the CPU save before jumping to the handler, and where?
> <details><summary>Reveal answer</summary>It saves the <b>PC</b> (so it knows where to return) and the <b>PSW / processor state</b> (and registers) — pushed onto the <b>stack</b>.</details>

---

## 6. Multiple interrupts — queue vs. cut-the-line

What if a *second* device whistles while you're already dealing with the first? There are two strategies.

| Approach | How it works | Behaviour |
|----------|--------------|-----------|
| **Sequential (disabled)** | While running a handler, **all interrupts are turned off**; new ones wait (stay **pending**) | Handlers run **one at a time, in arrival order**. Ignores how urgent each is. |
| **Nested (priority)** | Every interrupt has a **priority**; a **higher-priority** one can **interrupt the handler** that's running | Urgent things jump ahead; less urgent ones wait their turn. |

```text
SEQUENTIAL / DISABLED (no cutting in line)
 User ──INT_A──► [ run handler A fully ] ──► [ run handler B fully ] ──► User
                 (B arrived during A but politely waits its turn)

NESTED / PRIORITY (higher priority cuts ahead)
 priorities: printer = 2,  disk = 4,  comm = 5   (bigger number = more urgent)
 t=0   User program running
 t=10  PRINTER int → run Printer handler
 t=15  COMM int (5 > 2) → cut in → run Comm handler
 t=20  DISK int (4 < 5) → less urgent than Comm → waits
 t=25  Comm done → before resuming Printer, DISK (4 > 2) cuts in → Disk handler
 t=35  Disk done → resume Printer handler
 t=40  Printer done → back to User program
```

> 🧠 **Remember it as:** **Sequential = a polite queue** (first come, first served). **Nested = a VIP line** (a more important guest cuts ahead — and even when one handler finishes, the CPU re-checks and runs the *most urgent* one still waiting).

> ✍️ **Check yourself:** At t=25 the Comm handler finishes. Why doesn't the Printer handler get even one instruction before Disk?
> <details><summary>Reveal answer</summary>The Disk interrupt (priority 4) is still pending and <b>outranks</b> the Printer (priority 2). When a handler ends, the CPU re-checks pending interrupts and always picks the highest priority — so Disk runs first; Printer only resumes at t=35.</details>

---

## 7. The I/O function & DMA (a first look)

How does data actually get between a device and memory? Two ways matter here:

- **Through the CPU:** the CPU reads from / writes to the I/O module using special **I/O instructions** (separate from memory instructions). Every word passes through the CPU — the CPU is the middleman.
- **Direct Memory Access (DMA):** for big transfers, that middleman is a bottleneck. So the CPU **hands the I/O module permission to talk to memory directly.** The module moves the whole block to/from memory on its own, and only **interrupts the CPU once, at the end.**

```text
   Without DMA:  I/O ──► CPU ──► MEMORY   (CPU relays every single word — slow)
   With DMA:     I/O ──────────► MEMORY   (CPU is free; interrupted only when done)
```

> 🧠 **Remember it as:** DMA = *"you have my permission, go talk to memory yourself and tell me when you're done."* The CPU stops being the courier for every word.

---

## 8. Bus interconnection — the shared wires

Now, how do the CPU, memory, and I/O actually connect? Classically, by a **bus**.

- **Analogy:** a bus is like an **old-style telephone party line** — a single shared set of wires that *everyone* is connected to. When one device "speaks," all the others can hear it, but **only one may speak at a time**.
- **Plain English:** a **bus** is a shared transmission path linking multiple modules. A signal placed on it by one module is available to all.

We group the wires into **three buses** by what they carry:

| Bus | Carries | Its width determines |
|-----|---------|----------------------|
| **Data bus** | the actual **data** being moved (e.g. 32 / 64 / 128 lines) | **throughput** — how many bits move at once → key to performance |
| **Address bus** | **which location** the data is going to/from | **maximum memory capacity** (and the range of I/O ports) |
| **Control bus** | **command & timing** signals | coordination — *not* capacity |

```text
   ┌──────────┐   ┌──────────┐   ┌──────────┐
   │   CPU    │   │  MEMORY  │   │   I/O    │
   └──┬──┬──┬─┘   └──┬──┬──┬─┘   └──┬──┬──┬─┘
      │  │  │        │  │  │        │  │  │
 ═════╪══╪══╪════════╪══╪══╪════════╪══╪══╪═  CONTROL BUS  (commands & timing)
      │  │           │  │           │  │
 ═════╪══╪═══════════╪══╪═══════════╪══╪════  ADDRESS BUS  (which location)
      │              │              │
 ═════╪══════════════╪══════════════╪═══════  DATA BUS     (the actual data)
```

Two small details examiners like:
- On the **address bus**, the **high-order (top) bits** pick *which module* (memory? which I/O port?), and the **low-order (bottom) bits** pick the *location within* that module.
- The **control bus** carries two kinds of signal: **command** (what operation to do) and **timing** (saying "the data/address on the lines is valid *now*").

> ⚠️ **Exam trap — bus contention:** because every module shares the same data and address lines, **only one transfer can happen at a time**. As you add devices and demand higher speeds, the shared bus becomes a **bottleneck** (electrical loading, propagation delay, the cost of arbitrating whose turn it is). This is exactly why modern machines moved away from shared buses.

> ✍️ **Check yourself:** Which bus's width caps how much memory you can install?
> <details><summary>Reveal answer</summary>The <b>address bus</b> — its width sets how many distinct addresses exist, which caps maximum memory capacity (and the I/O port range). Data bus width sets <i>speed</i>, not capacity.</details>

---

## 9. Point-to-point links (QPI) & PCI Express

As CPUs got faster, the shared party-line bus couldn't keep up. The fix: **point-to-point** links.

- **Analogy:** instead of one party line everyone shares, give each pair of devices its **own private phone line**. Many conversations can happen at once, and nobody has to wait for the line to be free (no **arbitration**).

**QuickPath Interconnect (QPI)** — Intel, 2008:
- **Multiple direct (pairwise) connections** → no shared medium → **no arbitration**, and many transfers happen concurrently.
- **Layered protocol** (physical / link / routing / protocol layers) instead of raw control wires.
- **Packetized**: data travels as packets with control headers and **error-control codes**.
- The **link layer** handles flow + error control on units called **flits** (72-bit payload + 8-bit CRC); the **protocol layer** handles **cache coherency**.

**PCI and PCI Express (PCIe):**
- **PCI**: a high-bandwidth, processor-independent peripheral bus (maintained by the **PCI-SIG** group).
- **PCIe**: a **point-to-point** scheme that **replaces** the bus-based PCI. Needed for **high-data-rate I/O** (e.g. Gigabit Ethernet) and **time-dependent (isochronous)** streams like audio/video.
- Its **Transaction Layer** builds request/completion packets (**TLPs**); most use **split transactions** (ask now, get the **completion** packet later), some are **posted** (no reply expected). Four address spaces: **Memory, I/O, Configuration, Message**.

```text
   SHARED BUS                     POINT-TO-POINT (QPI / PCIe)
   ──────────                     ───────────────────────────
   A─┬─B─┬─C─┬─D  (one talks      A───B    direct private links;
     └───┴───┘    at a time,      │ X │    every pair can transfer
                  arbitration)    C───D    at once, no arbitration
```

> 🧠 **Remember it as:** **Bus = party line** (everyone shares, takes turns). **Point-to-point = private phone calls** (each pair has its own wire, all at once).

---

## ✅ You now understand…

Take a breath — you just learned how a computer actually *runs*. In plain terms:

1. **Stored-program / von Neumann:** the program lives in memory as changeable data — *"same box, swap the code."* Memory holds data + instructions, addressed by location, run in sequence.
2. **The registers:** **PC** (next instruction), **IR** (current instruction), **MAR** (which address), **MBR** (what data), **AC** (calculator scratch pad).
3. **The instruction cycle:** **fetch → decode → execute**, repeating forever — plus optional **indirect** and **interrupt** detours.
4. **Interrupts** exist so the CPU doesn't waste time waiting on slow devices; four classes = **Program, Timer, I/O, Hardware failure** (P-T-I-H).
5. **The interrupt cycle:** finish current instruction → **save context (PC + PSW)** → PC ← handler → run ISR → restore → resume.
6. **Multiple interrupts:** **sequential** (polite queue) vs. **nested/priority** (VIP cuts ahead).
7. **DMA** lets a device talk to memory directly so the CPU isn't a courier for every word.
8. **Three buses** — data (speed), address (capacity), control (commands/timing) — and **contention** on the shared bus is why we moved to **point-to-point** (QPI, PCIe).

If any of those feels shaky, re-read that section. When all eight feel comfortable, do `exercises.md`, then test yourself with `mcq.md`.

---

## 🎓 When you're revising for the exam

Everything above is the understanding. For the exam, examiners reward precise wording and the ability to *draw* and *trace*. Keep these crisp:

- **Stored-program concept:** *both instructions and data are stored in a single read-write memory; reprogram by loading new instructions, not by rewiring.* Three von Neumann ideas: single read-write memory, addressable by location, sequential execution.
- **Be ready to trace the fetch cycle in register-transfer notation, in order:** `MAR ← PC` → `MBR ← Memory[MAR]` → `PC ← PC + 1` → `IR ← MBR` → decode. Always say **which bus**: MAR → address bus, MBR → data bus.
- **Be ready to draw the state diagram** (Fig. 3.5): instruction addr calc → fetch → operand addr calc → **[indirect]** → operand fetch → data operation → operand store (operand steps may loop) → **interrupt check** → back to fetch.
- **Classify an interrupt fast:** caused by the instruction itself (overflow / divide-by-zero / illegal opcode)? → **Program**. Periodic/OS? → **Timer**. Device done/error? → **I/O**. Power/parity? → **Hardware failure**.
- **Interrupt cycle (Fig. 3.7):** *finish current instruction → save context (PC + PSW on stack) → PC ← ISR address → run handler → restore context → resume.* Mention the **overhead**.
- **Multiple interrupts (Fig. 3.9):** sequential/disabled = strict arrival order, no preemption; nested/priority = higher number preempts, and on each handler's completion the CPU re-checks for the highest pending.
- **Bus questions:** "max memory" → **address** bus; "transfer rate / performance" → **data** bus width; "coordination / timing / commands" → **control** bus; "bottleneck / why point-to-point" → **contention** on shared lines.

> 🧠 **Mega-mnemonic:** **"PC-now-IR; MAR-which-MBR-what; P-T-I-H; data-speed / address-capacity / control-command."**

**Likely exam question (worked example): "Trace the fetch–execute cycle for the instruction `1940` (LOAD AC ← contents of address 940) stored at address 300, with PC = 300."**
<details><summary>Model answer</summary>

```text
FETCH
  1. MAR ← PC                 ; MAR = 300
  2. MBR ← Memory[MAR]        ; MBR = 1940  (the instruction word is read)
  3. PC  ← PC + 1             ; PC = 301    (point to the next instruction)
  4. IR  ← MBR                ; IR = 1940
DECODE
  5. opcode 1 = LOAD AC; operand address = 940
EXECUTE
  6. MAR ← IR(address)        ; MAR = 940
  7. MBR ← Memory[MAR]        ; MBR = (value stored at 940)
  8. AC  ← MBR                ; AC now holds the loaded value
```
A full *"add the contents of 940 to 941"* task on this simple ISA takes **three instruction cycles**: **LOAD** (940 → AC), **ADD** (941 into AC), **STORE** (AC → 941).
</details>

---

## 📚 Want to see/hear it explained another way?

- **Instruction cycle & interrupts** — Stallings *COA* 11e, Ch. 3 (companion site): https://www.pearson.com/en-us/subject-catalog/p/computer-organization-and-architecture/P200000003520
- **Gentle video walk-throughs** — Neso Academy COA playlist: https://www.youtube.com/playlist?list=PLBlnK6fEyqRgLLlzdgiTUKULKJPYc0A4q
- **Fast exam-style explanations** — Gate Smashers COA playlist: https://www.youtube.com/playlist?list=PLxCzCOWd7aiHMonh3G6QNKq53C6oNXGrX
- **Instruction Cycle & Interrupts notes** — GeeksforGeeks: https://www.geeksforgeeks.org/computer-organization-and-architecture-tutorials/
- **See a CPU and bus built from scratch** — Ben Eater (YouTube): https://www.youtube.com/@BenEater
- **Computer Organization reference** — TutorialsPoint: https://www.tutorialspoint.com/computer_logical_organization/index.htm
