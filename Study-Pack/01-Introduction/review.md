# Chapter 01 — Quick Refresher

> 🌱 Read this in 5 minutes to refresh everything, or the day before the exam. Each idea is given in **plain words first**, then the exam wording.

---

## The big ideas, in plain words

- **Architecture vs Organisation** = the **"what" vs the "how."** What a programmer sees and uses (instructions, data sizes, addressing) vs. how it's actually built inside (wiring, bus width, memory tech). Same "what" can have many "hows" — that's why old x86 software still runs on new chips.
- **Structure vs Function** = the **wiring diagram vs the job description.** For any part, ask "how is it connected?" and "what does it do?"
- **The four jobs (PSMC):** **P**rocess (do maths), **S**tore (hold data), **M**ove (in/out = I/O, or over distance = data communications), **C**ontrol (the manager of the other three).
- **The whole computer (CMIB):** **C**PU (brain) + **M**emory (working desk) + **I/O** (doorways) + **B**us (the road between them).
- **Inside the CPU:** **Control Unit** (manager — decodes & directs) + **ALU** (calculator — does the maths) + **Registers** (tiny fast scratch pads) + an internal road. *ALU calculates, CU directs.*
- **Stored-program concept (von Neumann/IAS):** the **program lives in memory** alongside the data — so you reprogram by loading new instructions, not by rewiring. This is the foundation of all modern computers.
- **Moore's Law (Gordon Moore, 1965):** transistors per chip **≈ double every ~2 years** → cheaper, faster, smaller. (A trend, not a physics law; about transistor count, not clock speed.)

---

## Architecture vs Organisation — at a glance
| Architecture (the "what", visible) | Organisation (the "how", hidden) |
|---|---|
| Instruction set, data types | Control signals |
| Addressing modes | Bus widths |
| Number of bits for data | Memory technology |
| *Whether* a multiply instruction exists | *How* multiply is implemented |

## The four generations
| Gen | Built from | Remember this |
|---|---|---|
| 1 | Vacuum tubes | ENIAC; von Neumann/IAS; stored-program |
| 2 | Transistors | smaller, faster, cheaper, cooler |
| 3 | Integrated circuits | Moore's Law (1965); System/360, PDP-8 |
| 4 | LSI / VLSI | the microprocessor (Intel 4004, 1971) |

Density ladder (fewest → most per chip): **SSI → MSI → LSI → VLSI → ULSI**

## Mini diagrams to be able to draw
```text
WHOLE COMPUTER:        CPU ──── BUS ──── MEMORY
                              │
                             I/O ──── peripherals

INSIDE THE CPU:    [Control Unit]    [Registers]
                         └── internal bus ──┘
                              [ ALU ]
```

## Memory aids
- **A/O** — Architecture = visible, Organisation = how built.
- **PSMC** — Process, Store, Move, Control.
- **CMIB** — CPU, Memory, I/O, Bus.

---

### ⭐ If you only revise 5 things
1. **Architecture = what the programmer sees; Organisation = how it's built** (x86 = same architecture, many organisations).
2. **Four jobs: Process, Store, Move, Control (PSMC).**
3. **Whole computer = CPU + Memory + I/O + Bus (CMIB);** inside CPU = **Control Unit + ALU + Registers + road** (ALU calculates, CU directs).
4. **Generations: tubes (ENIAC, stored-program) → transistors → ICs → VLSI (microprocessor).**
5. **Moore's Law:** transistors/chip double ≈ every 2 years (Moore, 1965) → cheaper, faster, smaller.
