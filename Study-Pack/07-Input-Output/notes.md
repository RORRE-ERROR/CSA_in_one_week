# Chapter 07 — Input / Output

> 🌱 **Starting from zero?** Perfect — this chapter is about how your computer talks to the outside world: the keyboard, the screen, the disk, the printer, the network. You don't need to remember anything from earlier chapters except one picture: a computer is a **CPU** (the brain), **main memory** (the working desk), and a **bus** (the road between them). This chapter adds the **doorways** that connect that inner world to everything outside. We'll build it one small step at a time, everyday comparisons first, technical words second.
>
> ⏱️ Take about 2 hours. The heart of this chapter is the **three I/O techniques** and **DMA** — if those click, you've got the chapter.

---

## 🤔 First, why does this chapter exist?

Think about what's actually attached to your computer: a keyboard you type on slowly, a fast solid-state disk, a printer that jams, a mouse, a webcam, a network cable. They are all wildly different — different speeds, different shapes of data, different rules for talking. The CPU and memory, meanwhile, are fast, precise, and all speak one neat internal language.

So there's a clash: a tidy, blazing-fast inner world, and a messy, slow, varied outer world. **Something has to sit in the middle and translate.** That something is the **I/O module**, and this whole chapter is about it — what it is, and especially the different *strategies* the CPU and the I/O module use to shuffle data back and forth.

The big through-line of the chapter is one simple question:

> **How much does the CPU have to babysit a data transfer?**

The answer improves over three techniques — and the less the CPU has to babysit, the better. Keep that question in your head and the whole chapter lines up.

By the end you'll be able to, in your own words:
- explain **why I/O modules exist** and what's **inside** one,
- tell apart **memory-mapped** and **isolated** I/O (two ways to give devices an address),
- explain the **three I/O techniques** — programmed, interrupt-driven, DMA — and **rank them by CPU cost**,
- explain how the CPU figures out **which device interrupted** it,
- explain **DMA** and the trick called **cycle stealing**,
- name what an **I/O channel** is and the common **external interfaces** (USB, FireWire, etc.).

---

## 1. Why I/O modules exist

Imagine you run a busy international office. You (the CPU) work fast and speak one language. But visitors arrive speaking dozens of languages, at all different speeds, with paperwork in all different formats. You can't possibly learn to deal with every single one personally. So you hire a **front-desk translator** who greets each visitor, handles their quirks, and hands you a clean, standard summary.

That translator is the **I/O module** (also called an I/O controller or interface). Here's why you can't just wire a keyboard or disk straight onto the system bus:

- **Too many different devices.** Peripherals work in wildly different ways. It would be hopeless to build the logic for every possible device into the CPU itself.
- **Speed mismatch.** Most peripherals are **far slower** than the CPU and memory (a human typing). A few can briefly be **faster** (a disk dumping a burst of data).
- **Different data formats.** Devices use different word lengths and data formats than the computer does internally.

The I/O module fixes all three. It has **two jobs**:
1. **Talk to the processor and memory** on one side (over the system bus).
2. **Talk to one or more peripheral devices** on the other side (over links tailored to each device).

> 🧠 **Memory hook:** the I/O module is a *translator + buffer + traffic cop* sitting between the fast, uniform CPU bus and the slow, messy outside world.

Devices themselves come in **three families**, depending on *who* they talk to:

| Family | Talks to… | Examples |
|----------|-------------------------|----------|
| **Human-readable** | a human user | screen/display, printer, keyboard |
| **Machine-readable** | other equipment | magnetic disk/tape, sensors, actuators |
| **Communication** | remote/distant devices | modems, another computer, network terminals |

> ✍️ **Check yourself:** Why can't a slow keyboard be wired directly onto the fast system bus?
> <details><summary>Reveal answer</summary>Because peripherals differ from the CPU in <b>operating method, speed, and data format</b>. A direct connection would force the CPU to cope with every device's quirks and to wait at the device's slow pace. The I/O module sits in between to <b>translate, buffer, and coordinate</b>.</details>

---

## 2. What's inside an I/O module?

Let's open up the translator's desk. It has connections to the **bus side** (toward CPU and memory) and connections to the **device side** (toward the peripherals), plus some brains and notepads in the middle.

```text
        SYSTEM BUS SIDE                        I/O MODULE                       DEVICE SIDE
   ┌──────────────────────┐         ┌──────────────────────────────┐
   │  Data lines  ◄──────► │◄──────► │  Data registers              │◄──┐
   │  Address lines ─────► │         │  Status / Control registers  │   │   ┌──────────┐
   │  Control lines ─────► │◄──────► │  ┌────────────────────────┐  │   ├──►│ Device 1 │
   │                       │         │  │  I/O logic             │  │   │   └──────────┘
   │  (to CPU & memory)    │         │  │  (address decode,      │  │   │   ┌──────────┐
   │                       │         │  │   command, status,     │◄─┼───┼──►│ Device 2 │
   │                       │◄──────► │  │   interrupt logic)     │  │   │   └──────────┘
   └──────────────────────┘         │  └────────────────────────┘  │   │
                                     │   External device interface  │◄──┘
                                     └──────────────────────────────┘
```

**Reading the diagram in plain words:** On the left, the module connects to the system bus with three kinds of wires — **data** (the actual bytes), **address** (which register/device), and **control** (read/write commands and interrupt signals). In the middle it keeps small **registers**: a **data register** (a tiny mailbox holding a byte in transit), and **status/control registers** (a notepad saying "device ready? error? do this command"). The **I/O logic** is the little brain that decodes addresses and commands. On the right, the **external device interface** connects to the actual devices.

**The five things an I/O module does:**
1. **Control & timing** — coordinate the back-and-forth between the inside and the outside.
2. **Processor communication** — understand commands from the CPU, exchange data, report status, recognise when it's being addressed.
3. **Device communication** — send commands, read status, move data to/from the device.
4. **Data buffering** — hold data in a register because the fast side and slow side run at different speeds (this is the translator's "please wait" tray).
5. **Error detection** — notice and report device problems (parity errors, paper jam, etc.).

**The four commands the CPU can give a module** (once it has the module's address):
- **Control** — switch a device on and tell it what to do (e.g., "rewind the tape").
- **Test** — check the device's status (powered on? ready? error?).
- **Read** — module fetches a data item from the device into its buffer.
- **Write** — module takes a data item from the bus and sends it to the device.

> 🧠 **Memory hook:** the four commands are **C-T-R-W** = *Control, Test, Read, Write.*

> ✍️ **Check yourself:** Why does an I/O module need data buffering?
> <details><summary>Reveal answer</summary>Because the CPU/memory side moves data <b>fast</b> while the device is <b>slow</b>. The buffer holds the data so the fast side isn't stuck waiting on the slow side (and vice versa) — like a "please wait" tray on the translator's desk.</details>

---

## 3. Two ways to give a device an address

Every I/O module has registers (data, status, control), and the CPU needs a way to *point at* them — to say "the byte goes to that register." There are **two schemes** for handing out those addresses.

**Analogy:** imagine the building has rooms (memory) and also a few service counters (I/O devices).
- **Memory-mapped I/O** = the service counters get *room numbers too*, mixed into the same numbering as the rooms. To talk to a counter you just "visit a room" — the same `load`/`store` instructions you'd use for memory. No special vocabulary.
- **Isolated I/O** = the counters live in a *separate building* with their own numbering. To visit them you need *special instructions* (`IN`/`OUT`) and an extra sign on the door saying "this is a counter, not a room" (a MEM/IO select line).

| Aspect | **Memory-Mapped I/O** | **Isolated (I/O-Mapped) I/O** |
|--------|-----------------------|-------------------------------|
| Address space | **Single, shared** for memory + I/O | **Separate** spaces for memory and I/O |
| Instructions used | Ordinary memory `load`/`store` | **Special** I/O instructions (`IN`/`OUT`) |
| Instruction set for I/O | **Large** (every memory op works on devices) | **Limited** (only the I/O ops) |
| Control lines needed | One read line + one write line | Extra **I/O-vs-memory select** line |
| Cost | I/O addresses eat into the memory address space | Full memory space preserved |
| Programming | Flexible, uniform | Simpler hardware decode, but more rigid |

```text
   MEMORY-MAPPED I/O                  ISOLATED I/O
   ┌────────────────┐                ┌──────────────┐  ┌──────────────┐
   │   address      │                │   memory     │  │   I/O        │
   │   space        │                │   space      │  │   space      │
   │  ┌──────────┐  │                │ ┌──────────┐ │  │ ┌──────────┐ │
   │  │  memory  │  │                │ │  memory  │ │  │ │  I/O     │ │
   │  ├──────────┤  │                │ │  only    │ │  │ │  ports   │ │
   │  │  I/O     │  │ same load/store│ └──────────┘ │  │ └──────────┘ │
   │  │  ports   │  │ instructions   │  uses MEM/IO─┘──┘  select line │
   │  └──────────┘  │                └──────────────┴────────────────┘
   └────────────────┘
```

**Reading the diagram:** on the left, memory and I/O share one big address space, so the *same* load/store instructions reach both. On the right, memory and I/O are two separate spaces, and a select line picks which one you mean.

> ⚠️ **Exam trap:** Memory-mapped I/O does **NOT** need special I/O instructions — that's the entire point of it. **Isolated** I/O is the one that **needs special `IN`/`OUT` instructions and an extra select line.** Don't swap these.

> ✍️ **Check yourself:** A CPU has no `IN`/`OUT` instructions at all. Which scheme must it use?
> <details><summary>Reveal answer</summary><b>Memory-mapped I/O.</b> With no I/O-specific instructions, the only way to reach a device's registers is to treat them as ordinary memory addresses and use normal <code>load</code>/<code>store</code>.</details>

---

## 4. The heart of the chapter: the three I/O techniques

This is the most important section. There are **three ways** the CPU and I/O module can move data, and they differ in **how much the CPU has to babysit.**

Here's the master grid the textbook uses (Table 8.1). It sorts the techniques by two questions: *does the data pass through the CPU, or go straight to memory?* and *are interrupts used?*

| | **No interrupts** | **Uses interrupts** |
|---|---|---|
| **Data passes through the CPU** | Programmed I/O | Interrupt-driven I/O |
| **Data goes straight to memory** | — | **DMA** |

Let's meet all three with an everyday story. Imagine you've ordered a package and you're waiting for the delivery.

### 4.1 Programmed I/O (also called polling)

**Analogy:** you stand at the window and stare down the street, again and again, checking "is it here yet? is it here yet?" — doing *nothing else* the whole time. When it finally arrives, you carry it in yourself.

**Plain English:** the CPU gives the module a command, then sits in a loop **repeatedly reading the module's status register** ("ready? ready? ready?") until the device is ready. Then the **CPU itself** moves the data word from the module into memory.

- ❌ The CPU is **busy-waiting** — burning cycles doing nothing useful while it waits. Terrible for slow devices.

**Formal term:** this is **Programmed I/O**, and the staring-in-a-loop is called **polling**.

### 4.2 Interrupt-driven I/O

**Analogy:** instead of staring out the window, you go do your chores. You've left a doorbell. When the delivery arrives, the courier **rings the bell**; you pause your chore, answer the door, take the one package in, then go back to your chore.

**Plain English:** the CPU gives the command and then **goes off and does other useful work**. When the device is ready, the module **raises an interrupt** — a hardware "doorbell." The CPU pauses what it's doing, runs a small routine (the **interrupt service routine, ISR**) to move that one data word, then resumes its previous work.

- ✅ No more busy-waiting. **But** the CPU still has to get up and handle **every single word** — one doorbell ring per word. For a big block, that's a *lot* of door-answering.

**Formal term:** this is **Interrupt-driven I/O**. An **interrupt** is a signal that makes the CPU suspend its current program to handle an event; the **ISR** is the little program that handles it.

### 4.3 Direct Memory Access (DMA)

**Analogy:** you hire a **mailroom assistant**. You tell them once: "collect all 500 packages from the depot and stack them in room 4000." Then you forget about it and work. The assistant does the entire job. When *all* of it is done, they ring the bell **once** to say "finished."

**Plain English:** for **large amounts of data**, the CPU issues **one** command to a special **DMA module** — telling it the direction (read/write), the device, the starting memory address, and how many words. Then the CPU goes back to work. The DMA module moves the **whole block directly between the device and memory**, without bothering the CPU for each word. When the entire block is done, it raises **one** interrupt.

**Formal term:** this is **Direct Memory Access (DMA)** — "direct" because the data goes straight to memory, not through the CPU.

### Putting them side by side (transferring a block of data in)

```text
 PROGRAMMED I/O            INTERRUPT-DRIVEN I/O          DMA
 ┌─────────────┐          ┌─────────────┐               ┌─────────────────┐
 │ CPU→I/O:    │          │ CPU→I/O:    │               │ CPU→DMA: read   │
 │ issue read  │          │ issue read  │               │ blk, addr, count│
 └──────┬──────┘          └──────┬──────┘               └────────┬────────┘
        │                        │ CPU does                      │ CPU does
        ▼                        ▼ other work                    ▼ other work
 ┌─────────────┐          ┌─────────────┐               ┌─────────────────┐
 │ read status │◄──┐      │ ...working  │               │ DMA moves WHOLE │
 └──────┬──────┘   │      └──────┬──────┘               │ block ↔ memory  │
        │ not      │ busy        │ INTERRUPT             │ (cycle stealing)│
        ▼ ready    │ wait        ▼ when ready            └────────┬────────┘
 ┌─────────────┐   │      ┌─────────────┐                        │ one
 │ ready? ─No──┼───┘      │ ISR: move   │                        ▼ INTERRUPT
 └──────┬──────┘          │ ONE word    │               ┌─────────────────┐
        │ Yes             └──────┬──────┘               │ ISR: done flag  │
        ▼                        ▼ resume               └─────────────────┘
 ┌─────────────┐          ┌─────────────┐
 │ CPU moves   │          │ more words? │
 │ ONE word    │          │ repeat per  │
 └──────┬──────┘          │ word        │
        ▼ repeat          └─────────────┘
   per word
```

**Reading the diagram:** Programmed I/O (left) loops on a status check (the "ready? No → loop back" cycle) and the CPU moves each word — it never gets to do anything else. Interrupt-driven (middle) lets the CPU work, but it gets interrupted once per word to move that word. DMA (right) hands off the whole block; the CPU works the whole time and gets just one interrupt at the very end.

### The one ranking to remember: CPU overhead

> **DMA < Interrupt-driven < Programmed**
>
> (DMA bothers the CPU the *least*; programmed I/O bothers it the *most*.)

> 🧠 **Memory hook — "Stare / Tap / Delegate":**
> **Programmed** = CPU *stares* at the device. **Interrupt** = device *taps* the CPU on the shoulder per word. **DMA** = CPU *delegates* the whole job and gets one "done" tap at the end.

> ⚠️ **Exam trap:** DMA is **NOT** zero-CPU. The CPU is still involved at the **start** (issuing the one command) and the **end** (handling the completion interrupt). It's only freed from the *per-word* work in between.

> ✍️ **Check yourself:** A single byte arrives from one key press. Which technique fits, and which is overkill?
> <details><summary>Reveal answer</summary><b>Interrupt-driven I/O</b> fits a single, sporadic byte nicely. <b>DMA is overkill</b> (the setup cost isn't worth it for one word). <b>Programmed I/O</b> wastes cycles busy-waiting on a slow human.</details>

---

## 5. Interrupt-driven I/O: the two design questions

When you use interrupts, the hardware has to answer two practical questions:
1. **Which device rang the doorbell?** (device identification)
2. **If several ring at once, who do I answer first?** (priority)

### How the CPU figures out which device interrupted — four techniques

| Technique | How it works | Vectored? | Notes |
|-----------|--------------|-----------|-------|
| **Multiple interrupt lines** | A separate wire per module | implied | Simplest; but wires are scarce, so lines often still share several modules |
| **Software poll** | One ISR checks each module's status register in turn to find the culprit | **No** | **Slow** (many reads); priority = the order you poll |
| **Daisy chain** (hardware poll, vectored) | An interrupt-**acknowledge** signal is passed module-to-module down a chain; the interrupting module drops its **vector** onto the data bus | **Yes** | Priority = physical position (nearest the CPU wins) |
| **Bus arbitration** (vectored) | A module must **win control of the bus first**, then raise its request; on acknowledge it puts its **vector** on the data lines | **Yes** | Priority decided by the bus arbitration logic |

**What's a "vector"?** It's the address (or unique ID) of the I/O module. A **vectored interrupt** lets the CPU jump *straight* to the correct device's service routine instead of running a generic routine that has to hunt for the culprit. So "vectored" = "the device tells the CPU exactly who it is" = faster.

```text
 DAISY CHAIN (the interrupt-acknowledge signal travels down the line)
   CPU ──INTA──► [Dev A] ──► [Dev B] ──► [Dev C]
   (highest priority)        (lower)      (lowest)
   The first device with a pending request grabs the acknowledge,
   puts its vector on the data bus, and stops it from going further.
```

**Reading the diagram:** the acknowledge signal (INTA) enters at Dev A, then Dev B, then Dev C. Whichever device near the front has a pending request "catches" the signal and answers — so the device **closest to the CPU has the highest priority**, because it gets first crack at the signal.

> 🧠 **Memory hook — where does priority come from?** **Software poll** = the order you poll. **Daisy chain** = the order on the wire. **Bus arbitration** = whoever wins the bus.

> ⚠️ **Exam trap:** *Daisy chain* and *bus arbitration* are **vectored** (the device supplies its own vector → fast). *Software poll* is **NOT** vectored (the CPU has to hunt) → slowest.

> ✍️ **Check yourself:** Two devices on a daisy chain interrupt at the same instant. Which is serviced first?
> <details><summary>Reveal answer</summary>The one <b>physically closer to the CPU</b> along the acknowledge chain — it intercepts the acknowledge signal first, and the chain stops propagating past it.</details>

---

## 6. DMA in detail: operation and configurations

### Why DMA exists

Both programmed and interrupt-driven I/O have two built-in problems:
1. The transfer speed is **capped by how fast the CPU can test/service** the device.
2. The CPU is **tied up** running many instructions per transfer.

For **large amounts of data**, DMA sidesteps both.

### The DMA steps

1. The CPU hands the DMA module four things: **direction** (read/write), **device address**, **starting memory address**, and **word count**. Then the CPU carries on with other work.
2. The DMA module moves the whole block **one word at a time, directly to/from memory** — no CPU instruction per word.
3. When it's finished, the DMA module raises **one interrupt** to tell the CPU.

### DMA configurations (where you plug the DMA module in)

The catch with DMA is that moving a word still uses the system bus — and the more times each word crosses the system bus, the more it competes with the CPU. The three layouts differ in **how many system-bus trips each word takes**.

```text
 (a) SINGLE BUS, DETACHED DMA          each transfer uses bus TWICE
     ┌─────┐  ┌─────┐  ┌─────┐  ┌──────┐   (device↔DMA, then DMA↔mem)
     │ CPU │  │ DMA │  │ I/O │  │ I/O  │
     └──┬──┘  └──┬──┘  └──┬──┘  └──┬───┘
        └────────┴────────┴────────┴──── system bus ──── memory

 (b) SINGLE BUS, INTEGRATED DMA-I/O    DMA + one/more I/O share a path;
     ┌─────┐  ┌───────────┐  ┌───────────┐   device↔DMA is off-bus →
     │ CPU │  │ DMA + I/O  │  │ DMA + I/O │   bus used ONCE per word
     └──┬──┘  └─────┬──────┘  └─────┬─────┘
        └───────────┴───────────────┴──── system bus ──── memory

 (c) SEPARATE I/O BUS                  devices hang off a dedicated I/O bus;
     ┌─────┐  ┌─────┐                  system bus used ONCE per word
     │ CPU │  │ DMA │── I/O bus ─[I/O][I/O][I/O]
     └──┬──┘  └──┬──┘
        └────────┴──── system bus ──── memory
```

**Reading the diagrams in plain words:**
- **(a) Detached DMA on a single bus:** the device-to-DMA step *and* the DMA-to-memory step both ride the one system bus, so each word crosses it **twice**. Wasteful of bus time.
- **(b) Integrated DMA-I/O:** the DMA logic is built into the I/O module, so the device-to-DMA step happens *inside* the module (off the bus). Only the DMA-to-memory step uses the system bus → **once** per word.
- **(c) Separate I/O bus:** the devices live on their own dedicated I/O bus; only the final DMA-to-memory step touches the system bus → **once** per word.

So (b) and (c) cut the system-bus traffic per word in half compared to (a).

> ✍️ **Check yourself:** Why does the detached single-bus DMA use the system bus twice per word?
> <details><summary>Reveal answer</summary>Because both the <b>device↔DMA</b> transfer and the <b>DMA↔memory</b> transfer happen on the <b>same</b> system bus. Integrating the DMA into the I/O module, or putting devices on a separate I/O bus, gets the first step off the system bus so each word only crosses it once.</details>

---

## 7. Cycle stealing — DMA's secret to staying out of the way

The DMA module needs the system bus to move each word — but the CPU also wants the bus. So DMA grabs the bus for **one cycle**, moves one word, and gives it back. The CPU is paused for exactly that one bus cycle, then carries straight on. DMA is, in effect, **"stealing" a single bus cycle** from the CPU.

**Analogy:** the mailroom assistant occasionally needs to use the shared hallway for a second to wheel a cart through. They wait for a gap, dash across, and you (briefly stepping aside) continue immediately. No meeting, no paperwork — just a one-moment pause.

The key point — and the favourite exam trap:
- Cycle stealing is **NOT an interrupt.** The CPU does **not** save its context or switch programs. It just **pauses for one bus cycle** and continues.
- Net effect: the CPU runs a touch slower during a DMA transfer, but vastly less disruption than an interrupt-per-word would cause.

### The cycle-stealing timeline

```text
  CPU bus usage:  ██ ██ ░░ ██ ░░ ██ ██ ░░ ██   (██ = CPU cycle)
  DMA steals:           ▓▓    ▓▓       ▓▓      (▓▓ = DMA grabs bus 1 cycle)
                        ↑     ↑        ↑
                CPU paused exactly one bus cycle each time DMA needs it.
                NO context save. CPU continues immediately after.

  vs INTERRUPT-DRIVEN per word:
  CPU: ...run... [SAVE ctx][ISR moves word][RESTORE ctx]...run...[SAVE]...
       full context switch on EVERY word — much heavier.
```

**Reading the diagram:** in the top strip, the DMA quietly slips a single bus cycle (▓▓) into the gaps; the CPU barely notices. The bottom strip shows interrupt-driven I/O by contrast — a whole save-context / run-ISR / restore-context dance on *every* word. DMA's per-word cost is tiny; interrupt-driven's is heavy.

> ⚠️ **Exam trap:** **Cycle stealing ≠ interrupt.** Cycle stealing suspends the CPU for *one bus cycle* with **no context switch**; an interrupt suspends the whole *program* and saves/restores full state. DMA uses **cycle stealing** during the transfer and **one** interrupt only at the end.

> 🧠 **Memory hook:** DMA *"steals a cycle, not a program."*

> ✍️ **Check yourself:** When can the DMA module steal a bus cycle?
> <details><summary>Reveal answer</summary>At points within the instruction cycle where the CPU doesn't need the bus — the CPU is only actually stalled when it wants the bus while DMA has it. Unlike an interrupt (recognised only at the <b>end</b> of an instruction), a DMA "breakpoint" can occur at various points <b>within</b> an instruction cycle.</details>

---

## 8. I/O channels and processors — the I/O function keeps growing up

Over time, the I/O function got smarter, offloading more and more from the CPU. The textbook lists **six steps**, each handing more responsibility to the I/O side:

```text
   step1 ───► step2 ───► step3 ───► step4 ───► step5 ───► step6
   CPU does   prog.      +interrupt  DMA       I/O        I/O processor
   everything I/O                              channel    (own memory)
   ◄─────────────── increasing CPU offload ───────────────►
```

1. CPU directly controls a peripheral.
2. Add a controller / I/O module → CPU uses **programmed I/O** (no interrupts).
3. Same, but now with **interrupts** → CPU needn't busy-wait.
4. I/O module gets **DMA** → moves a whole block without the CPU (except start/end).
5. The I/O module becomes a **processor in its own right** with its **own specialized I/O instruction set** — an **I/O channel**. The CPU just points it at an **I/O program in memory** and the channel runs the whole sequence.
6. The I/O module gets its **own local memory** too — now it's effectively a **computer in its own right**, the **I/O processor**, controlling many devices with barely any CPU help.

**The key distinction to remember:** an **I/O channel** = its own instruction set; an **I/O processor** = its own instruction set **and** its own memory.

Two channel flavours: a **selector channel** handles high-speed devices one at a time; a **multiplexor channel** handles several low-speed devices at once.

> ✍️ **Check yourself:** What's the difference between an I/O channel and a plain DMA module?
> <details><summary>Reveal answer</summary>A DMA module just moves a block when the CPU commands it. An <b>I/O channel</b> is a processor with its own <b>instruction set</b> that can run a whole <b>I/O program</b> from memory on its own — much less CPU involvement.</details>

---

## 9. External interfaces — how devices actually plug in

Two basic connection styles:
- **Point-to-point** = a dedicated link between the I/O module and **one** device.
- **Multipoint** = a shared bus connecting **many** devices to the module (essentially an external bus).

Here are the common standards. You don't need every number, but the **topologies** (USB = tree, FireWire = chain, SCSI = bus) are favourite exam questions.

| Standard | Type | Key facts |
|----------|------|-----------|
| **USB** | tiered-star **tree** (root host controller), hot-plug | Default for slower devices + high-speed I/O. 1.0: Low 1.5 Mbps / Full 12 Mbps; 2.0: 480 Mbps; 3.0 *SuperSpeed* 5 Gbps (~4 usable); 3.1 *SuperSpeed+* 10 Gbps (~9.7 usable). |
| **FireWire (IEEE 1394)** | **daisy chain**, point-to-point capable | Alternative to SCSI for smaller systems; up to 63 devices per port, 1022 buses bridgeable; **hot-plugging** + **automatic configuration** (no terminators, auto address assignment). |
| **SCSI** | shared **bus** (multipoint), parallel | Up to 16/32 devices; 16- or 32-bit parallel bus; 5 Mbps (SCSI-1) to 160 Mbps (SCSI-3 U3). Now mostly enterprise mass storage. |
| **Thunderbolt** | high-speed serial | Intel + Apple; up to 10 Gbps each direction + 10 W power; combines data, video, audio, power on one link. |
| **PCI Express** | high-speed bus | Wide variety of peripheral types/speeds. |
| **SATA** | serial disk interface | Up to 6 Gbps; widely used desktop/embedded storage. |
| **InfiniBand** | switched fabric | High-end server market; up to 64,000 devices in a fabric; storage-area networking. |
| **Ethernet** | switch-based | Predominant wired networking; up to 100 Gbps; moved from bus-based to switch-based. |
| **Wi-Fi** | wireless | Predominant wireless access; 802.11ac up to 3.2 Gbps. |

> 🧠 **Memory hook — "Tree-Chain-Bus":** **USB = tree** (host controller, tiered star). **FireWire = daisy chain.** **SCSI = shared bus.**

> ✍️ **Check yourself:** Which interface uses a daisy chain and supports hot-plugging with automatic address assignment?
> <details><summary>Reveal answer</summary><b>FireWire (IEEE 1394).</b></details>

---

## ✅ You now understand…

Take a breath — that was the whole I/O story. In plain terms:

1. **Why I/O modules exist:** devices are too varied, too slow, and use the wrong data formats to wire straight to the bus — the module **translates, buffers, and coordinates**.
2. **Inside the module:** registers (data, status, control) + I/O logic; five functions (control/timing, processor comm, device comm, **buffering**, error detection); four commands **C-T-R-W**.
3. **Two addressing schemes:** memory-mapped (shared space, normal load/store, *no* special instructions) vs isolated (separate space, special `IN`/`OUT` + select line).
4. **The three techniques, ranked by CPU cost — DMA < interrupt-driven < programmed.** Stare / Tap / Delegate.
5. **DMA still needs the CPU at the start and end** — only the per-word work is offloaded.
6. **Cycle stealing** = grab one bus cycle, no context switch — *not* an interrupt.
7. **Device identification** (multiple lines, software poll, daisy chain, bus arbitration) and where **priority** comes from.
8. **Evolution:** direct → programmed → interrupt → DMA → **I/O channel** (own ISA) → **I/O processor** (own memory).
9. **External interfaces:** USB tree, FireWire chain, SCSI bus; point-to-point vs multipoint.

If any of those feels shaky, re-read that section before moving on. When they all feel comfortable, do `exercises.md`, then test yourself with `mcq.md`.

---

## 🎓 When you're revising for the exam

Everything above is the understanding. For the exam, examiners reward precise wording — keep these crisp:

- **Why I/O modules:** devices differ in **operating method, speed, and data format**; the module interfaces to the **processor/memory** on one side and to **peripherals** on the other.
- **Five functions:** control & timing · processor communication · device communication · **data buffering** · error detection. **Four commands: C-T-R-W** (Control, Test, Read, Write).
- **Classify a technique first:** *who moves each word* (CPU = programmed/interrupt; the module = DMA) and *is the CPU polling or notified*? → that places it in the 2×2 (Table 8.1).
- **CPU overhead ranking:** **DMA < interrupt-driven < programmed.** Be ready to say why (per-word interrupts vs one-per-block; busy-waiting vs not).
- **"Special I/O instructions" → isolated I/O;** "ordinary load/store for devices" → memory-mapped.
- For **priority** questions, state *both* the identification method and *how* it sets priority (poll order / chain position / bus arbiter). Note which are **vectored** (daisy chain, bus arbitration) vs not (software poll).
- **Cycle stealing vs interrupt** is a near-guaranteed trap: *one bus cycle, no context switch* vs *full program suspend + state save*.
- **DMA still needs the CPU at start (command) and end (one interrupt)** — losing that point loses marks.
- **Topologies:** USB = tree, FireWire = daisy chain, SCSI = shared bus. **Evolution:** channel = step 5 (own instruction set), I/O processor = step 6 (own memory).

> 🧠 **Mnemonics:** **C-T-R-W** (commands) · **"Stare / Tap / Delegate"** (programmed / interrupt / DMA) · **"Steal a cycle, not a program"** (cycle stealing) · **"Tree-Chain-Bus"** (USB / FireWire / SCSI) · **"Special IN/OUT → Isolated."**

**Likely exam question (worked example):** *"Why is DMA more efficient than interrupt-driven I/O for transferring a large block? Quantify it."*
<details><summary>Model answer</summary>

For a block of **N words**:
- **Interrupt-driven I/O** interrupts the CPU **once per word**, so if each interrupt costs *c* overhead instructions, total CPU overhead ≈ **N × c** — it grows linearly with N.
- **DMA** issues **one** command at the start and takes **one** completion interrupt at the end, regardless of N. Per-word, it only causes minor **cycle stealing** (a one-bus-cycle pause, no context switch). CPU overhead ≈ **1 setup + 1 interrupt** — constant in N.

So as the block grows, DMA's constant cost beats interrupt-driven's linear cost decisively. Key caveat for full marks: DMA is **not** zero-CPU — the CPU still issues the command at the start and services the completion interrupt at the end.
</details>

---

## 📚 Want to see/hear it explained another way?

- **Stallings, *Computer Organization and Architecture*, 11e — Chapter 8 (Input/Output)** — primary text. Publisher page: https://www.pearson.com/en-us/subject-catalog/p/computer-organization-and-architecture/P200000003297
- **Neso Academy — I/O Organization / DMA playlist:** https://www.youtube.com/playlist?list=PLBlnK6fEyqRgLLlzdgiTUKULKJPYc0A4q
- **Neso Academy — Direct Memory Access (DMA):** https://www.youtube.com/watch?v=dB9Ct_Vi5UM
- **Gate Smashers — I/O & Interrupts / DMA (COA playlist):** https://www.youtube.com/playlist?list=PLxCzCOWd7aiHMonh3G6QNKq53C6oNXGrX
- **GeeksforGeeks — I/O Interface / Modes of data transfer (DMA, interrupt, programmed):** https://www.geeksforgeeks.org/io-interface-interrupt-dma-mode/
- **GeeksforGeeks — Direct Memory Access (DMA) Controller:** https://www.geeksforgeeks.org/direct-memory-access-dma-controller-in-computer-architecture/
- **TutorialsPoint — Computer Organization, I/O & DMA:** https://www.tutorialspoint.com/computer_organization_and_architecture/computer_organization_data_transfer_techniques.htm
