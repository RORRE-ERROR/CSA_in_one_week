# Chapter 07 — Quick Refresher (Input / Output)

> 🌱 Read this in 5 minutes to refresh everything, or the day before the exam. Each idea is given in **plain words first**, then the exam wording.

---

## The big ideas, in plain words

- **Why I/O modules exist:** the outside devices are too **varied**, too **slow (or sometimes bursty-fast)**, and use the **wrong data formats** to wire straight onto the CPU bus. The I/O module sits in the middle as a *translator + buffer + traffic cop*. (Exam wording: peripherals differ in **operating method, speed, and data format**; the module interfaces to the processor/memory on one side and to peripherals on the other.)
- **What's inside it:** registers (data, status, control) + I/O logic. Five functions: **control/timing · processor comm · device comm · buffering · error detection.** Four commands: **Control · Test · Read · Write** (C-T-R-W).
- **Two ways to address a device:** **memory-mapped** (devices share memory's address space; use ordinary load/store; *no* special instructions) vs **isolated** (separate I/O space; special `IN`/`OUT`; needs a MEM/IO select line).
- **The three techniques — the heart of the chapter.** They differ by *how much the CPU babysits the transfer*:
  - **Programmed I/O** = CPU *stares* at the device (busy-waits, polls status, moves each word).
  - **Interrupt-driven** = device *taps* the CPU per word (CPU works in between, but handles every word).
  - **DMA** = CPU *delegates* the whole block, gets one "done" tap at the end.
  - **CPU overhead ranking: DMA < interrupt-driven < programmed.**
- **DMA is NOT zero-CPU:** the CPU still issues one command at the **start** and handles one interrupt at the **end** — it's only freed from the per-word work.
- **Cycle stealing:** DMA grabs the bus for **one cycle**, the CPU pauses one cycle, **no context switch** — this is *not* an interrupt.
- **Identifying which device interrupted:** multiple lines, software poll (slow, non-vectored), daisy chain (vectored, nearest-CPU wins), bus arbitration (vectored).

---

## The three I/O techniques — master comparison
| Feature | **Programmed I/O** | **Interrupt-driven I/O** | **DMA** |
|---|---|---|---|
| **Who moves the data** | CPU (per word) | CPU (per word, in ISR) | **DMA module** (whole block) |
| **CPU during transfer** | **Busy-waits** (polls status) | Does other work; interrupted **per word** | Does other work; only **cycle-steal slowdown** |
| **CPU involvement** | Total (100%) | Per-word interrupt overhead | **Only at start (command) + end (1 interrupt)** |
| **Interrupts used** | None | One per word | **One per block** |
| **Path to memory** | Through CPU | Through CPU | **Direct** device↔memory |
| **Speed / efficiency** | Slowest, wastes CPU | Better, but per-word cost | **Best for large blocks** |
| **Best for** | tiny/simple, no other work | sporadic single bytes (keyboard) | **large data volumes (disk, network)** |

## DMA steps (memorize)
1. CPU → DMA: **direction, device address, memory address, word count**; CPU continues working.
2. DMA transfers the block **one word at a time, direct to/from memory**, via **cycle stealing**.
3. On completion, DMA sends **one interrupt** to the CPU.

**Cycle stealing** = DMA grabs the bus for **one cycle**, CPU pauses one cycle, **no context switch** (≠ interrupt).

## DMA configurations
- **Single-bus detached DMA** — 2 system-bus cycles/word (device↔DMA, then DMA↔mem, both on the same bus).
- **Integrated DMA-I/O** — 1 cycle/word (device↔DMA happens inside the module).
- **Separate I/O bus** — 1 cycle/word (devices sit on a dedicated I/O bus).

## I/O addressing
| | Memory-mapped | Isolated (I/O-mapped) |
|---|---|---|
| Address space | shared | separate |
| Instructions | normal load/store | special IN/OUT |
| Op set for I/O | large | limited |
| Extra line | no | MEM/IO select |

## Interrupt device-identification methods
| Method | Priority basis | Vectored? | Speed |
|---|---|---|---|
| Multiple interrupt lines | which line | (implied) | fast, lines scarce |
| **Software poll** | poll order | **No** | **slow** |
| **Daisy chain** (HW poll) | chain position (nearest CPU = highest) | **Yes** | fast |
| **Bus arbitration** | bus arbiter wins | **Yes** | fast |

**Vector** = address/ID of the module → lets the CPU jump straight to the right device-service routine.

## Evolution of I/O (6 steps)
direct control → programmed I/O → +interrupts → **DMA** → **I/O channel** (own instruction set) → **I/O processor** (own memory).

## Mini diagrams to be able to picture
```text
THREE TECHNIQUES (less CPU babysitting →):
   Programmed I/O  →  Interrupt-driven  →  DMA  →  I/O channel
   (CPU stares,        (device taps CPU     (CPU      (module is a
    busy-waits)         per word)            delegates  processor)
                                             whole block)

CYCLE STEALING (DMA slips one bus cycle into the gaps):
   CPU bus:  ██ ██ ░░ ██ ░░ ██ ██   (██ = CPU cycle)
   DMA:            ▓▓    ▓▓          (▓▓ = DMA grabs bus, no context switch)
```

## External interfaces
- **USB** = tiered-star **tree**, root host controller, hot-plug; 1.5/12 Mbps → 480 Mbps → 5 Gbps (SuperSpeed) → 10 Gbps (SuperSpeed+).
- **FireWire (IEEE 1394)** = **daisy chain**, ≤63 devices/port, hot-plug + auto-config.
- **SCSI** = shared **bus**, parallel, ≤16/32 devices.
- **Thunderbolt** = 10 Gbps each way + 10 W power, data/video/audio/power combined.
- **Point-to-point** = dedicated link to one device; **multipoint** = shared external bus.

## Mnemonics
- **C-T-R-W** = Control, Test, Read, Write (the four I/O commands).
- **"Stare / Tap / Delegate"** = Programmed (CPU stares) / Interrupt (device taps per word) / DMA (CPU delegates the whole block).
- **"Steal a cycle, not a program"** = cycle stealing has no context switch.
- **"Tree-Chain-Bus"** = USB tree, FireWire chain, SCSI bus.
- **"Special IN/OUT → Isolated"**; ordinary load/store → memory-mapped.

---

### ⭐ If you only revise 5 things
1. **The three techniques + the ranking: DMA < interrupt-driven < programmed** (CPU overhead). Know who moves each word and how cost grows with block size.
2. **DMA still needs the CPU at the start (command) and end (one interrupt)** — only the per-word work is offloaded.
3. **Cycle stealing ≠ interrupt:** one bus cycle, no context save.
4. **Device ID & priority:** software poll (non-vectored, slow) vs daisy chain / bus arbitration (vectored).
5. **Memory-mapped vs isolated I/O** trade-offs (special `IN`/`OUT` + select line = isolated).
