# Chapter 01 — Quick Self-Test (Multiple Choice)

> 🌱 **How to use this.** Once you've read `notes.md` and tried `exercises.md`, use these 15 questions to check what stuck. Pick an answer in your head (or jot A/B/C/D) **before** opening the explanation. Aim to understand *why* the right answer is right — the explanations say so in plain words.
>
> Don't worry about score the first time. Re-take it the day before the exam and aim for 14–15.

---

**Q1.** Computer *architecture* means:
- A. The internal units and how they're wired
- B. The features a programmer can see and use, which affect how a program runs
- C. The physical layout of chips on a board
- D. The type of memory the system uses

**Q2.** Which of these is *organisation* (the "how"), not architecture?
- A. The instruction set
- B. How many bits represent a number
- C. The width of the system bus
- D. The available addressing modes

**Q3.** "Does this computer have a multiply instruction?" is a question about:
- A. Organisation
- B. Architecture
- C. Data movement
- D. Control signals

**Q4.** The four basic jobs of a computer are:
- A. Input, Output, Process, Print
- B. Data processing, storage, movement, control
- C. Fetch, Decode, Execute, Store
- D. Add, Subtract, Multiply, Divide

**Q5.** Sending data from the computer to an attached printer is an example of:
- A. Data processing
- B. Data storage
- C. Data movement (I/O)
- D. Control

**Q6.** Which job "manages everything and coordinates the other three"?
- A. Data processing
- B. Control
- C. Data storage
- D. Data movement

**Q7.** The four top-level parts of a computer are:
- A. ALU, Control Unit, Registers, Cache
- B. CPU, Main Memory, I/O, System Bus
- C. Input, Output, Memory, Disk
- D. CPU, GPU, RAM, ROM

**Q8.** Inside the CPU, the part that does the actual maths and logic is the:
- A. Control Unit
- B. Registers
- C. ALU
- D. System bus

**Q9.** Which CPU part reads/decodes instructions and gives the orders?
- A. ALU
- B. Registers
- C. Control Unit
- D. Main memory

**Q10.** ENIAC is best described as:
- A. The first stored-program computer
- B. The first general-purpose electronic digital computer
- C. The first microprocessor
- D. The first transistor-based computer

**Q11.** The *stored-program concept* is most associated with:
- A. Gordon Moore
- B. John von Neumann / the IAS machine
- C. Charles Babbage
- D. The Intel 4004

**Q12.** The main technology of the **second** generation of computers was:
- A. Vacuum tubes
- B. Transistors
- C. Integrated circuits
- D. VLSI

**Q13.** Moore's Law says:
- A. CPU clock speed doubles every year
- B. The number of transistors on a chip doubles roughly every ~2 years
- C. Memory cost halves every month
- D. Computers double in physical size each decade

**Q14.** Which order goes from *fewest* to *most* components per chip?
- A. VLSI → LSI → MSI → SSI
- B. SSI → MSI → LSI → VLSI
- C. LSI → SSI → VLSI → MSI
- D. MSI → SSI → LSI → VLSI

**Q15.** A whole CPU on a single chip (the microprocessor) belongs to which generation?
- A. First (vacuum tubes)
- B. Second (transistors)
- C. Third (integrated circuits)
- D. Fourth (LSI/VLSI)

---

## Answers — with the *why*

<details><summary>Q1</summary><b>B</b> — Architecture = what the programmer can see and use. (A describes organisation, the internal "how".)</details>
<details><summary>Q2</summary><b>C</b> — Bus width is a hidden build detail = organisation. A, B and D are all things a programmer relies on = architecture.</details>
<details><summary>Q3</summary><b>B</b> — *Whether* an instruction exists is architecture. *How* it's built would be organisation.</details>
<details><summary>Q4</summary><b>B</b> — Process, Store, Move, Control (mnemonic **PSMC**).</details>
<details><summary>Q5</summary><b>C</b> — Moving data to/from a device is I/O = data movement.</details>
<details><summary>Q6</summary><b>B</b> — Control is the "manager" job that coordinates the other three.</details>
<details><summary>Q7</summary><b>B</b> — CPU, Memory, I/O, Bus (**CMIB**). Option A lists the parts *inside* the CPU, not the top level.</details>
<details><summary>Q8</summary><b>C</b> — The ALU (the "calculator") does arithmetic and logic.</details>
<details><summary>Q9</summary><b>C</b> — The Control Unit (the "manager") decodes instructions and issues control signals; the ALU only does the maths.</details>
<details><summary>Q10</summary><b>B</b> — ENIAC = first general-purpose electronic digital computer (it was rewired to reprogram, so <i>not</i> stored-program).</details>
<details><summary>Q11</summary><b>B</b> — von Neumann and the IAS machine: program + data both in memory.</details>
<details><summary>Q12</summary><b>B</b> — Gen 2 = transistors. (Gen 1 tubes, Gen 3 ICs, Gen 4 VLSI.)</details>
<details><summary>Q13</summary><b>B</b> — Transistor count per chip doubles ~every 2 years. It's about density, not clock speed.</details>
<details><summary>Q14</summary><b>B</b> — SSI → MSI → LSI → VLSI (then ULSI), cramming in more each step.</details>
<details><summary>Q15</summary><b>D</b> — The microprocessor (e.g. Intel 4004, 1971) defines the 4th generation (LSI/VLSI).</details>

---

> 📊 **Scored low?** That's normal on a first pass — go back to the matching `notes.md` section for anything you missed, then retry. **Scored 13+?** You've got Chapter 1 down.
