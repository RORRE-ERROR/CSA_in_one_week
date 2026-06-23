# Chapter 01 — Practice Questions

> 🌱 **How to use this file.** Read `notes.md` first. Then try each question **on your own** before opening the answer — even a rough attempt helps you remember. Peeking too early feels productive but teaches you much less. It's totally fine to get them wrong; that's how you find the gaps.
>
> Questions go **easy → harder**: first just *recall* facts, then *apply* them, then a couple of *exam-style* ones.

---

## Warm-up: can you remember the basics?

### Q1. What are the four jobs every computer does?
<details><summary>Show answer</summary>

1. **Processing** — doing something to data (maths, comparisons). *The chef cooking.*
2. **Storage** — holding data, short-term or long-term. *The fridge/pantry.*
3. **Movement** — getting data in and out (I/O), or sending it over a distance (data communications). *The waiters.*
4. **Control** — managing the other three. *The head chef.*

Memory aid: **PSMC** — Process, Store, Move, Control.
</details>

### Q2. What are the four main parts of a computer (at the top level)?
<details><summary>Show answer</summary>

- **CPU** — the brain (does the processing, bosses everything).
- **Main memory (RAM)** — the working desk (holds what you're using right now).
- **I/O** — the doorways to the outside world (keyboard, screen, disk…).
- **System bus** — the road/wires connecting the three.

Memory aid: **CMIB** — CPU, Memory, I/O, Bus.
</details>

### Q3. What are the parts *inside* the CPU, and what does each do?
<details><summary>Show answer</summary>

| Part | Plain role | Job |
|---|---|---|
| **Control Unit (CU)** | the manager | reads each instruction, decides what happens, directs the others |
| **ALU** | the calculator | does the actual maths and logic |
| **Registers** | tiny scratch pads | super-fast slots the CPU uses while working |
| **Internal interconnection** | the inside road | lets these parts pass data around |

Remember: **the ALU calculates, the Control Unit directs.**
</details>

---

## Applying it

### Q4. Is each one *architecture* (the "what") or *organisation* (the "how")?
(a) the list of instructions the CPU understands; (b) how wide the data bus is; (c) the addressing modes; (d) whether multiply uses a special circuit or repeated adding; (e) how many bits an integer uses.
<details><summary>Show answer</summary>

- (a) **Architecture** — the programmer sees and uses these instructions.
- (b) **Organisation** — bus width is an internal build detail.
- (c) **Architecture** — addressing modes are part of what the programmer works with.
- (d) **Organisation** — this is *how* multiply is built, hidden from the programmer.
- (e) **Architecture** — the programmer depends on the data size.

**Quick test:** *Can a programmer see or rely on it in their code?* → architecture. *Is it about how it's built inside?* → organisation.
</details>

### Q5. Software from the 1990s still runs on a brand-new Intel chip. Why? (Use architecture vs organisation.)
<details><summary>Show answer</summary>

Because Intel keeps the **architecture** (the "what" — the instructions and programmer-visible features) backward-compatible, while only changing the **organisation** (the "how" — the internal engine) for more speed. Programs only depend on the architecture, so they keep working even though the hardware inside is completely modern. *Same driver controls, new engine.*
</details>

### Q6. Match each activity to one of the four jobs (PSMC):
(a) adding two numbers; (b) sending a document to a network printer; (c) keeping a value in RAM while a program runs; (d) the part that decodes an instruction and gives orders.
<details><summary>Show answer</summary>

- (a) **Processing** (the ALU adds).
- (b) **Movement** (I/O / data communications over the network).
- (c) **Storage** (short-term, on the "desk").
- (d) **Control** (the Control Unit).
</details>

### Q7. What is the *stored-program concept*, and why was it such a big deal? Who's it linked to?
<details><summary>Show answer</summary>

It means **both the instructions (the program) and the data live in the computer's memory.** Linked to **John von Neumann** and the **IAS machine**.

Why huge: before this, machines like **ENIAC** were "reprogrammed" by **physically rewiring** them — incredibly slow. Once the program lives in memory, switching tasks is just **loading different instructions** — no rewiring. That's what makes a computer a flexible, general-purpose machine.
</details>

---

## Exam-style (a bit longer)

### Q8. "Describe the four generations of computers — the main technology and one landmark of each." (8 marks)
<details><summary>Show answer</summary>

- **Gen 1 — Vacuum tubes (~1946–57):** big, hot, unreliable. Landmark: **ENIAC** (first general-purpose electronic computer) and the **von Neumann/IAS** machine (stored-program idea).
- **Gen 2 — Transistors (~1958–64):** replaced tubes → smaller, faster, cheaper, cooler. Landmark: transistorised computers like the **IBM 7000 series**.
- **Gen 3 — Integrated circuits (~1965–71):** many transistors on one chip. **Moore's Law** noticed in 1965. Landmark: **IBM System/360**, **DEC PDP-8**.
- **Gen 4 — LSI/VLSI (~1972 on):** so dense a whole CPU fits on one chip — the **microprocessor** (**Intel 4004**, 1971).

*Marking: 1 mark for the technology + 1 for a landmark, per generation = 8.*
</details>

### Q9. State Moore's Law and give two consequences. (5 marks)
<details><summary>Show answer</summary>

**Moore's Law** (Gordon Moore, 1965): the **number of transistors on a chip roughly doubles every ~2 years (18–24 months)**, for about the same chip cost.

**Two consequences (any two):**
1. **Cheaper** computing — cost per transistor keeps falling.
2. **Faster** — parts are closer together, so signals travel shorter distances.
3. **Smaller, lower-power, more reliable** devices.

*Remember:* it's an **observed trend, not a physical law**, and it's about **transistor count**, not clock speed.
</details>

### Q10. Explain how *structure* and *function* describe a computer, and how the top level "zooms in" to the CPU.
<details><summary>Show answer</summary>

For any part we ask two things: its **function** (what it does) and its **structure** (how its pieces are wired together) — then we zoom in and ask the same two questions again.

- **Top level:** structure = **CPU + Memory + I/O + Bus**; function = process, store, move, control data.
- **Zoom into the CPU:** its structure = **Control Unit + ALU + Registers + internal road**; its function = control the computer and do the processing.
- You could zoom further (into the control unit, then into logic gates) — same two questions, finer detail each time.

This "one layer at a time" approach is how we keep a very complex machine understandable.
</details>
