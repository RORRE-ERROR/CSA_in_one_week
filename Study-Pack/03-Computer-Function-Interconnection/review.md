# Chapter 03 — Quick Refresher

> 🌱 Read this in 5 minutes to refresh everything, or the day before the exam. Each idea is given in **plain words first**, then the exam wording.

---

## The big ideas, in plain words

- **Stored-program / von Neumann** = *"same box, swap the code."* The program lives in memory as changeable data, right next to the data it works on — so you reprogram by loading new bits, not by rewiring. *Exam wording:* (1) data + instructions in a single read-write memory; (2) memory addressable by location, regardless of data type; (3) sequential execution unless explicitly changed. Opposite = **hardwired program**.
- **The registers** = the CPU's sticky-notes. **PC** = bookmark for the *next* instruction; **IR** = the instruction *now* in hand; **MAR** = *which* address; **MBR** = *what* data; **AC** = the calculator's scratch pad.
- **Instruction cycle** = the CPU's endless loop: **fetch the next instruction, then do it** — forever. Two optional detours: **indirect** (an extra memory trip to find the real operand address) and **interrupt** (check if a device needs me).
- **Interrupts** exist so the CPU doesn't *stand and stare* at slow devices — it gets on with other work and the device "whistles" when done. Four classes: **Program, Timer, I/O, Hardware failure**.
- **Interrupt cycle** = finish current instruction → jot down where I was (**save context**) → jump to the handler → handle it → pick up where I left off (**restore + resume**).
- **Multiple interrupts** = a polite **queue** (sequential) or a **VIP line** (nested/priority, where urgent ones cut ahead).
- **DMA** = "device, you have my permission to talk to memory yourself; tell me when you're done" — so the CPU isn't a courier for every word.
- **Buses** = shared wires (a party line). Three of them: **data** (speed), **address** (capacity), **control** (commands/timing). They get congested (**contention**), which is why modern machines use **point-to-point** private links (QPI, PCIe).

---

## Register roles — at a glance
| Reg | Name | Role | Bus |
|-----|------|------|-----|
| **PC** | Program Counter | Address of the **next** instruction; auto-increments | — |
| **IR** | Instruction Register | Holds the **current** instruction (decoded here) | — |
| **MAR** | Memory Address Register | Holds the **address** for a memory access | **Address** bus |
| **MBR** | Memory Buffer Register | Holds the **data** read/written | **Data** bus |
| **AC** | Accumulator | ALU operand/result work register | — |

## Instruction cycle
**Cycle = Fetch + Execute** (repeat until halt).
Fetch (memorise in order): `MAR←PC` → `MBR←Mem[MAR]` → `PC←PC+1` → `IR←MBR` → decode.
State-diagram order (Fig. 3.5): **Instr addr calc → Instr fetch → Operand addr calc → [indirect] → Operand fetch → Data operation → Operand store → Interrupt check → (back to fetch)**. The operand stages can **loop** (multiple operands).

**Execute action categories:** processor↔memory · processor↔I/O · data processing · control · combinations.

## Interrupts
**Purpose (plain):** overlap slow I/O with CPU work so the CPU isn't busy-waiting → efficiency.
**Cycle (Fig. 3.7):** finish current instruction → **save context** (push PC + PSW/state) → `PC←ISR address` → run handler → restore → resume. *(Not free — there's handler overhead.)*

| Class | Cause |
|-------|-------|
| **Program** | overflow, divide-by-zero, illegal opcode, memory violation (**internal** — from the instruction itself) |
| **Timer** | processor timer → OS periodic functions |
| **I/O** | device completion / service request / error |
| **Hardware failure** | power failure, memory parity error |

**Multiple interrupts (Fig. 3.9):**
- **Sequential / disabled** — interrupts off during the handler; new ones pend; run in **arrival order**; ignores urgency.
- **Nested / priority** — a higher priority **preempts**; when each handler ends, re-check and run the **highest pending**.

## Buses
| Bus | Carries | Width sets |
|-----|---------|-----------|
| **Data** | data words | throughput / **speed** |
| **Address** | source/dest address | **max memory capacity** + I/O ports |
| **Control** | command + timing signals | coordination of the shared lines |
- Address bus: **high bits = which module**, **low bits = location/port within it**.
- **Contention:** shared lines → only one transfer at a time → bottleneck.

## Point-to-point
- **QPI** (2008): direct pairwise links, **no arbitration**, **layered protocol**, **packetized**; link layer = **flits** (72-bit payload + 8-bit CRC) with flow + error control; protocol layer = cache coherency.
- **PCIe**: point-to-point, **replaces the PCI bus**; Transaction Layer builds **TLPs**; **split transactions** (+ posted); address spaces = **Memory, I/O, Configuration, Message**.
- **DMA**: the I/O module reads/writes memory directly, freeing the CPU (interrupted only at block end).

## Mini diagrams to be able to draw
```text
WHOLE SYSTEM:     PROCESSOR ── MEMORY ── I/O   all hung on the buses:
                  ═══ CONTROL BUS  (commands & timing) ═══
                  ═══ ADDRESS BUS  (which location)    ═══
                  ═══ DATA BUS     (the actual data)   ═══

CYCLE WITH INTERRUPT (Fig 3.7):
   Fetch → Execute → (interrupt pending & enabled?) ──yes──► save context;
        ▲                                                    PC ← handler
        └──────────────── no / after handler ────────────────┘
```

## Mnemonics
- **PC = next, IR = now; MAR = "which" (address), MBR = "what" (data).** MAR↔address bus, MBR↔data bus.
- Interrupt classes **P-T-I-H** = "Programs Take Interrupts Hard" (Program, Timer, I/O, Hardware failure).
- **Bus = party line; point-to-point = private call.**
- **Address bus → capacity; Data bus → speed; Control bus → command/timing.**

---

### ⭐ If you only revise 5 things
1. **Fetch-cycle transfers, in order:** `MAR←PC` → `MBR←Mem[MAR]` → `PC++` → `IR←MBR` (MAR↔address bus, MBR↔data bus).
2. **The instruction-cycle state diagram**, including the **indirect** and **interrupt** detours.
3. **Four interrupt classes** (Program / Timer / I/O / Hardware) + the **interrupt cycle**: save context (PC + PSW) → PC←ISR → run → restore → resume.
4. **Sequential vs nested** multiple-interrupt handling — polite queue vs. priority preemption.
5. **Three buses** — data = speed, address = capacity, control = command/timing — and why **contention** drove the move to **point-to-point** (QPI / PCIe).
