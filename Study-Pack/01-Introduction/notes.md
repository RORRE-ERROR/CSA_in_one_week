# Chapter 01 — Introduction to Computer Systems

> 🌱 **Starting from zero?** You're in the right place. This chapter assumes you know *nothing* about how a computer works inside. We'll build the picture one small step at a time, using everyday comparisons before any technical words. Read it slowly, top to bottom.
>
> ⏱️ Take about 2 hours. Don't rush — this chapter is the map for the whole course.

---

## 🤔 First, why does this chapter exist?

You use a computer (or phone) every day, but you've probably never had to think about *what's actually inside it* or *how the pieces talk to each other*. This whole course answers that question. Chapter 1 is the **bird's-eye view** — we name the big parts and see how they fit together. Every later chapter just zooms into one of these parts in detail.

So the goal right now is simple: **get the overall shape of a computer into your head.** Everything else hangs off this.

By the end you'll be able to, in your own words:
- explain the difference between *what a computer does* and *how it's built* (architecture vs organisation),
- name the **four jobs** every computer does,
- draw the **main parts** of a computer and what's **inside the CPU**,
- tell the short story of how computers evolved, and what **Moore's Law** says.

---

## 1. Two ways to describe a computer: the "what" and the "how"

Imagine a car. There are two very different ways to talk about it:

- **The driver's view:** there's a steering wheel, an accelerator, a brake. You don't care *how* the engine makes the car move — you just need to know what the controls do.
- **The mechanic's view:** pistons, fuel injectors, the gearbox. This is *how* the car actually delivers what the driver asked for.

Computers have the exact same split:

| | Plain meaning | Car analogy | Computer examples |
|---|---|---|---|
| **Architecture** | The "**what**" — the parts a *programmer* can see and use | The driver's controls | What instructions the CPU understands; how many bits a number uses; how it talks to devices |
| **Organisation** | The "**how**" — the actual circuitry that makes it work, hidden from the programmer | The engine internals | The wiring, the bus widths, the memory technology, whether multiply is a dedicated circuit or done by repeated adding |

> 💡 **The key idea:** the *same* "what" can be built in many different "hows."
> Intel's x86 chips have kept (mostly) the **same architecture** for decades — that's why a program from years ago still runs today. But the **organisation** (the engine) is redesigned with every new chip to be faster. Driver controls stay familiar; the engine keeps improving.

> 🧠 **Easy way to remember:** **A**rchitecture = **A**bstract (what you see). **O**rganisation = **O**perational guts (how it's built).

> ✍️ **Check yourself:** "Does this computer have a multiply instruction?" — is that *what* or *how*?
> <details><summary>Reveal answer</summary>It's <b>architecture</b> (the "what") — a programmer can see and use that instruction. <i>How</i> the multiply is actually performed inside (a special circuit, or adding in a loop) is <b>organisation</b>.</details>

---

## 2. Structure and Function — two simple questions

A computer is complicated, so we tame it by asking just **two questions** about any part of it:

1. **Function** — *what does this part do?* (its job)
2. **Structure** — *how are the parts wired together?* (the connections)

And we do this at every "zoom level": the whole computer → its big chunks → the chunks *inside* those → all the way down to tiny switches.

```text
Computer  ─▶  big parts (CPU, Memory…)  ─▶  parts inside those (ALU, Registers…)  ─▶  logic gates
   └── at each level, ask: what's its FUNCTION? what's the STRUCTURE connecting things?
```

> 🧠 **Remember it as:** **Function = the job description. Structure = the wiring diagram.**

---

## 3. The four jobs every computer does

Here's something surprising: no matter how fancy, **every computer only ever does four basic things.**

| # | Job | What it really means | Everyday kitchen analogy |
|---|---|---|---|
| 1 | **Processing** | Doing something *to* data — maths, comparisons, logic | The chef actually cooking the ingredients |
| 2 | **Storage** | Holding onto data — briefly (while working) or long-term (saved files) | The fridge and pantry |
| 3 | **Movement** | Getting data in and out, or sending it somewhere | The waiters carrying plates in and out |
| 4 | **Control** | Managing and coordinating the other three | The head chef directing everyone |

```text
                 ┌─────────────────────────┐
                 │      DATA STORAGE       │   ← hold data (fridge/pantry)
                 └────────────┬────────────┘
                              │
   DATA            ┌──────────▼──────────┐            DATA
  MOVEMENT  ◀────▶ │   DATA PROCESSING   │ ◀────▶  MOVEMENT
 (in & out)        │  (do stuff to data) │        (in & out)
                 └──────────┬──────────┘
                              │
                 ┌────────────▼────────────┐
                 │        CONTROL          │   ← the manager of the other 3
                 └─────────────────────────┘
```

> 🧠 **Remember the four as "PSMC":** **P**rocess, **S**tore, **M**ove, **C**ontrol. Control isn't a co-worker — it's the *boss* of the other three.

> 📌 **One small distinction:** "movement" comes in two flavours. Moving data between the computer and a device next to it (keyboard, printer, disk) is called **I/O** (input/output). Moving data over a longer distance (to another computer, over a network) is called **data communications**. Both are still just "movement."

> ✍️ **Check yourself:** Saving a photo to your hard drive vs. sending it to a printer — which jobs are those?
> <details><summary>Reveal answer</summary>Saving to disk = <b>storage</b> (long-term). Sending to a printer = <b>movement</b> (I/O). And <b>control</b> is quietly coordinating both.</details>

---

## 4. The big picture: what's inside the computer box?

Now let's open the case. At the top level there are **three workers and one road** connecting them:

```text
              ┌───────────────────────  COMPUTER  ───────────────────────┐
              │                                                           │
   PERIPHERALS│   ┌──────────┐                         ┌──────────────┐   │
      ◀──────▶│   │   CPU    │                         │ MAIN MEMORY  │   │
   (keyboard, │   │ (the     │                         │ (the working │   │
    disk,     │   │  brain)  │                         │  desk/RAM)   │   │
    network)  │   └────┬─────┘                          └──────┬───────┘  │
              │        │            SYSTEM BUS                 │          │
              │   ═════╪═══════════════════════════╤═══════════╪══════    │
              │        │                            │                     │
              │   ┌────┴─────┐                                            │
              │   │   I/O    │◀── the doorway to keyboards, screens, etc. │
              │   └──────────┘                                            │
              └───────────────────────────────────────────────────────────┘
```

| Part | Think of it as… | Its job |
|---|---|---|
| **CPU** (Central Processing Unit) | The **brain** | Does the actual thinking/processing and bosses everything around |
| **Main memory** (RAM) | A **working desk** | Holds the data and programs you're *currently* using |
| **I/O** (Input/Output) | The **doorways** | Moves data between the computer and the outside world (peripherals) |
| **System bus** | The **road/hallway** | The shared set of wires the three use to pass data to each other |

> 🧠 **Remember "CMIB":** **C**PU, **M**emory, **I/O**, **B**us. Three workers, one road.

> 💡 **Why a "desk" for memory?** When you open an app, the computer copies it from long-term storage onto the "desk" (RAM) where the brain can reach it fast. Turn the power off and the desk is wiped clean — that's why unsaved work is lost.

---

## 5. Zooming into the brain: inside the CPU

The CPU itself has parts. Zoom in and you find — same pattern — a few workers and an internal road:

```text
        ┌──────────────────────── CPU ────────────────────────┐
        │   ┌───────────────┐         ┌──────────────────┐     │
        │   │ CONTROL UNIT  │         │   REGISTERS      │     │
        │   │ (the manager) │         │ (tiny ultra-fast │     │
        │   │               │         │  scratch pads)   │     │
        │   └───────┬───────┘         └────────┬─────────┘     │
        │           │   internal CPU road      │               │
        │   ════════╪══════════════════════════╪═══════════    │
        │           │                          │               │
        │   ┌───────┴───────────────────────────────────┐      │
        │   │   ALU  (the calculator)                    │      │
        │   │   does the actual maths & logic            │      │
        │   └───────────────────────────────────────────┘      │
        └──────────────────────────────────────────────────────┘
```

| Inside the CPU | Think of it as… | Its job |
|---|---|---|
| **Control Unit (CU)** | The **manager** | Reads each instruction, figures out what it means, and tells the other parts what to do |
| **ALU** (Arithmetic & Logic Unit) | The **calculator** | Actually does the adding, subtracting, comparing — the real "processing" |
| **Registers** | Tiny **scratch pads** | A handful of super-fast storage slots the CPU uses while working |
| **Internal interconnection** | The **road** inside the CPU | Lets these three pass data around |

> ⚠️ **Don't mix these two up (a favourite trick question):** the **ALU does the calculating**; the **Control Unit just directs traffic**. The manager doesn't do the maths — the calculator does.

> ✍️ **Check yourself:** Which part reads an instruction and tells everything else what to do?
> <details><summary>Reveal answer</summary>The <b>Control Unit</b> (the manager). The ALU only does maths once it's told to.</details>

---

## 6. A short history: how we got here

Computers got smaller and faster in four big leaps ("generations"), each driven by a new way of building the switches inside:

```text
GEN  ROUGH ERA   BUILT FROM            THE BIG DEAL
──────────────────────────────────────────────────────────────
 1   1946–57     Vacuum tubes          ENIAC; the stored-program idea
 2   1958–64     Transistors           smaller, faster, cooler, cheaper
 3   1965–71     Integrated Circuits   many switches on one chip
 4   1972–now    VLSI / microprocessor a whole CPU on a single chip
──────────────────────────────────────────────────────────────
```

- **Generation 1 — Vacuum tubes.** Room-sized machines like **ENIAC**. Early on, you "programmed" them by *physically rewiring* — painfully slow. Then came the breakthrough idea (credited to **von Neumann**, in the **IAS machine**): the **stored-program concept** — keep the *instructions* in memory alongside the *data*. Now you change the program just by loading new instructions, no rewiring.

  > 🧠 **Stored-program in one line:** *"the program lives in memory, not in the wiring."* This single idea is the foundation of every computer since.

- **Generation 2 — Transistors.** The transistor replaced the bulky, hot, fragile vacuum tube. Result: smaller, cheaper, faster, cooler, more reliable.

- **Generation 3 — Integrated Circuits (ICs).** Instead of separate transistors, manufacturers print *many* of them together onto one small chip of silicon.

- **Generation 4 — VLSI & the microprocessor.** Packing keeps getting denser (the jargon ladder is **SSI → MSI → LSI → VLSI → ULSI**, just meaning "more and more components per chip"). Eventually an *entire CPU* fits on one chip — the **microprocessor** (the first was the Intel 4004, 1971).

| Density level | Roughly how many components per chip |
|---|---|
| SSI (Small) | up to ~100 |
| MSI (Medium) | 100 – 3,000 |
| LSI (Large) | 3,000 – 100,000 |
| VLSI (Very Large) | 100,000 – 1,000,000 |
| ULSI (Ultra Large) | over 1,000,000 |

*(You don't need to memorise the exact numbers — just the order and the idea that each step crams in far more.)*

---

## 7. Moore's Law

In **1965, Gordon Moore** (who later co-founded Intel) noticed a pattern and predicted it would continue: **the number of transistors you can fit on a chip roughly doubles every ~2 years.**

```text
transistors
 (count)            ●
            ●   ●
        ●               doubling ≈ every ~2 years
    ●
●─────────────────────────────────────▶ time
```

Why you should care — the **consequences**:
- Each chip costs about the same to make, but holds far more → **cost per transistor keeps dropping.**
- Things are physically closer together → **faster.**
- Smaller, cooler, lower-power, more reliable devices.

> ⚠️ **Two things students get wrong:** (1) Moore's Law is just an **observed trend / economic prediction**, *not* a law of physics. (2) It's about **transistor count**, *not* directly about clock speed.

> ✍️ **Check yourself:** Who said it, and what doubles?
> <details><summary>Reveal answer</summary><b>Gordon Moore</b> (1965). The number of <b>transistors on a chip</b> doubles roughly every ~2 years.</details>

---

## ✅ You now understand…

Take a breath — you just learned the skeleton of the entire course. In plain terms:

1. A computer can be described as a **"what" (architecture)** and a **"how" (organisation)** — same what, many hows (that's why old x86 software still runs).
2. We describe any part by its **function** (job) and **structure** (wiring).
3. Every computer does just **four jobs: Process, Store, Move, Control** (PSMC).
4. The whole machine = **CPU + Memory + I/O + Bus** (CMIB).
5. Inside the CPU = **Control Unit (manager) + ALU (calculator) + Registers (scratch pads) + an internal road.**
6. History: **tubes → transistors → ICs → VLSI/microprocessor**, and the game-changer was the **stored-program idea** (program lives in memory).
7. **Moore's Law:** transistors per chip ≈ double every ~2 years → cheaper, faster, smaller.

If any of those feels shaky, re-read that section before moving on. When all seven feel comfortable, do `exercises.md`, then test yourself with `mcq.md`.

---

## 🎓 When you're revising for the exam

Everything above is the understanding. For the exam specifically, examiners reward precise wording, so keep these crisp one-liners ready:

- **Architecture** = *attributes visible to the programmer that affect how a program runs* (instruction set, data types, addressing modes, I/O method).
- **Organisation** = *the operational units and their interconnections that implement the architecture* (control signals, bus widths, memory technology) — invisible to the programmer.
- **Four functions:** data processing, storage, movement, control.
- Be ready to **draw two diagrams from memory:** the top-level computer (CMIB) and the CPU internals (CU / ALU / registers / interconnection).
- **Moore's Law:** say *"≈doubles every ~2 years," "transistor count," "Gordon Moore, 1965,"* plus one consequence.
- **ENIAC** = first general-purpose electronic computer; **von Neumann / IAS** = stored-program concept.

> 🧠 **Mega-mnemonic:** **"A/O · S/F · PSMC · CMIB"** = Architecture/Organisation · Structure/Function · the four functions · the four top-level parts.

**Likely exam question (5 marks):** *"Distinguish computer architecture from computer organisation, with an example."*
<details><summary>Model answer</summary>

*Computer architecture* = the attributes **visible to the programmer** that directly affect a program's logical execution — e.g. the **instruction set, number of bits used for data, addressing modes, and I/O mechanisms.**
*Computer organisation* = the **operational units and their interconnections** that **realise** the architecture and are **transparent to the programmer** — e.g. **control signals, memory technology, bus widths.**
*Example:* whether the CPU **has a multiply instruction** is **architecture**; whether that multiply is done by a **dedicated circuit or by repeated addition** is **organisation**. This is why the **Intel x86 family** keeps one architecture across many generations (old software still runs) while changing organisation each model.
</details>

---

## 📚 Want to see/hear it explained another way?

- **Overview & architecture vs organisation** — Stallings *COA* 11e, Ch. 1. GeeksforGeeks: https://www.geeksforgeeks.org/computer-organization-and-architecture/
- **Gentle video walk-throughs** — Neso Academy COA playlist: https://www.youtube.com/playlist?list=PLBlnK6fEyqRgLLlzdgiTUKULKJPYc0A4q
- **Fast exam-style explanations** — Gate Smashers COA playlist: https://www.youtube.com/playlist?list=PLxCzCOWd7aiHMonh3G6QNKq53C6oNXGrX
- **See a computer actually work, part by part** — Ben Eater (YouTube): https://www.youtube.com/@BenEater
- **History / generations** — https://www.geeksforgeeks.org/generations-of-computers-computer-fundamentals/
- **Moore's Law** — https://www.britannica.com/technology/Moores-law
