# 🏁 FINAL EXAM FOCUS (WIA1003) — READ THIS FIRST

> The final is **mostly the second half (Ch 05–12)** with **some first-half carryover** (cache & performance), in the **same MCQ style** as the midterm: scenario-framed, numerical, figure/diagram-based, with "None of the above" distractors.
> This file tells you *what* to drill and *how it's asked*. Then sit **`FINAL-MOCK-EXAM.md`** closed-book.
> (The midterm files remain useful for the **carryover** topics — see the bottom.)

---

## ✅ Scope & expected weighting

| Chapter | Priority | What to expect |
|---------|:--------:|----------------|
| `05-Internal-Memory` | 🔴 high | **Hamming SEC** (check-bit count, syndrome → error position), SRAM vs DRAM, ROM family, refresh, DDR, chip/module organisation |
| `06-External-Memory` | 🔴 high | **Disk access-time** numericals, **RAID** levels (capacity, fault tolerance, write penalty), CAV vs MZR, SSD wear |
| `07-Input-Output` | 🟠 med | Programmed vs interrupt-driven vs **DMA**, cycle stealing, memory-mapped vs isolated I/O, device identification |
| `08-Instruction-Set-Architecture` | 🔴 high | **Addressing modes / effective-address calc**, number-of-addresses (0/1/2/3) code & code-size, endianness, instruction-format bit budget |
| `09-CISC-vs-RISC` | 🟠 med | Compare/contrast table, RISC design principles, register windows, why the debate converged |
| `10-Pipelining` | 🔴 high | **Speedup / efficiency / cycle-count** formulas, hazards (RAW/WAR/WAW, structural, control), branch penalty, 2-bit predictor |
| `11-Parallel-Processing` | 🔴 high | **Flynn's taxonomy**, **MESI** states & transitions, SMP vs cluster vs NUMA, cache coherence |
| `12-Multicore-Computers` | 🟠 med | **Amdahl's Law on multicore**, Pollack's rule, superscalar vs SMT vs multicore, cache arrangements |
| `02-Performance` (carryover) | 🟡 carry | Execution time, CPI from a mix, **reverse-solve** CPI/speed |
| `04-Cache-Memory` (carryover) | 🟡 carry | TAG/SET/WORD **hex split**, effective access time, locality, write policy |
| `01`, `03` (carryover) | ⚪ light | Possible 1–2 concept Qs (Moore/RC delay; instruction cycle, interrupts) |

> **Highest-yield to drill:** Hamming (05), disk/RAID (06), addressing modes (08), pipeline formulas (10), Flynn + MESI (11). These are where the marks and the trickiest questions live.

---

## 🧪 Exam format (same as the midterm)

- **All MCQ**, ~1 min/question, single attempt, no post-exam review.
- **4–5 options**; when 5, **"None of the answers is correct"** is usually present and is *sometimes* right.
- **Scenario-framed** stems with deliberate distractor numbers — read the whole question.
- **Diagrams appear verbatim** from Stallings: pipeline space-time charts, MESI state diagram, Flynn's quadrants, RAID layouts, DMA/interrupt flow, Hamming bit layout.
- **Answers in the expected unit/base** — ms for disk, hex where asked, a state name (M/E/S/I), a RAID level, etc.

---

## 🔢 Second-half numerical archetypes (drill until automatic)

### 1. Hamming SEC — check-bit count & error location (Ch 05)
- **#check bits:** smallest K with `2^K ≥ M + K + 1` (M = data bits). 8→4, 16→5, 32→6, 128→8.
- **Encode:** check bits at positions 1,2,4,8…; Cᵢ = even parity over positions whose index has that bit set (C1→1,3,5,7…; C2→2,3,6,7…; C4→4,5,6,7…).
- **Decode:** recompute parity → **syndrome** (S8 S4 S2 S1). Syndrome = **0** → no error; otherwise its decimal value = **the bit position to flip**.

### 2. Disk access time (Ch 06)
`T_access = T_seek + rotational_latency + transfer`, where
`latency = 1/(2r)`, `transfer = b/(r·N)` (b = bytes to read, N = bytes/track), `r = RPM/60` rev/s.
One whole track transfers in `1/r`; one sector = `(1/r)/sectors_per_track`. **Positioning dominates** small reads.

### 3. RAID capacity / fault tolerance (Ch 06)
- RAID 0 = N·cap (0 redundancy). RAID 1 = N/2 (mirror, survives 1/pair).
- RAID 5 = (N−1)·cap, survives **1** failure. RAID 6 = (N−2)·cap, survives **2**.
- **Small-write penalty** (RAID 4/5) = **2 reads + 2 writes** (read old data + old parity, write new data + new parity). RAID 1 has **no** parity penalty.

### 4. Pipeline performance (Ch 10)
- Cycles `= k + (n − 1)`; non-pipelined `= n·k`.
- **Speedup** `S = nk / (k + n − 1)` → approaches **k** as n→∞.
- **Efficiency** `η = S / k`.
- **Branch penalty:** add `(#taken branches × penalty)` stall cycles to the base count. Deeper pipelines lose more to branches.

### 5. Effective address (Ch 08)
| Mode | EA / operand |
|---|---|
| Immediate | operand = A |
| Direct | EA = A |
| Indirect | EA = (A) — **2 mem refs** |
| Register | operand in R |
| Register-indirect | EA = (R) — **1 mem ref** |
| Displacement | EA = A + (R) |
| Relative | EA = A + (PC) |
| Indexed | EA = A + (index) |

Number of addresses → code size: **3-addr (fewest instrs) < 1-addr < 0-addr (stack, most)**.

### 6. Amdahl on multicore (Ch 12)
`Speedup = 1 / [ (1−f) + f/k ]`; max (k→∞) `= 1/(1−f)`. The **serial fraction caps** everything — a small (1−f) destroys scaling.

---

## ⚠️ Traps that cost marks (second half)

1. **Syndrome value = bit position, not data-bit index.** Position 5 in a 7-bit SEC code is a *data* bit; positions 1/2/4 are *check* bits.
2. **`2^K ≥ M + K + 1`** — the K appears on **both** sides; don't forget to add K.
3. **Rotational latency = 1/(2r)** (half a revolution on average), not 1/r.
4. **RAID 5 survives only ONE failure**; a second failure during rebuild = data loss. RAID 6 survives two.
5. **Pipeline speedup can never exceed k** (the number of stages). Any "speedup > k" option is wrong.
6. **RAW is the only true data dependency** that stalls a simple in-order pipeline; WAR/WAW appear only with out-of-order/register reuse.
7. **MESI has exactly four states** — Modified, Exclusive, Shared, Invalid. "Owned" is MOESI (not in scope unless taught).
8. **Flynn:** SIMD = one instruction stream over many data (GPU/vector); **MISD is the rare/empty one**; multicore/SMP = **MIMD**.
9. **DMA** = block transfer with the CPU involved only at setup + final interrupt; **cycle stealing** = DMA borrows one bus cycle, briefly pausing the CPU (not an interrupt).
10. **CISC ≠ "slower."** CISC = many complex variable-length instructions (smaller code); RISC = few fixed-length, register-register, load/store, **one instr/cycle target** (more code, simpler pipeline).
11. **Little/big-endian:** big-endian stores the **most-significant byte at the lowest address**; little-endian the least-significant byte first.
12. **Carryover cache EAT:** this course's accepted model is **`H·Tc + (1−H)·Tm`** (see `04/exercises.md` note) — pick the weighted-average form.

---

## 📌 Concept questions to nail (high-frequency, low-effort marks)

- **SRAM vs DRAM:** SRAM = flip-flop, fast, no refresh, cache; DRAM = capacitor, dense, cheap, needs **refresh**, main memory.
- **ROM family erase:** ROM/PROM = none; **EPROM = UV (whole chip)**; **EEPROM = electrical (byte)**; **Flash = electrical (block)**.
- **RISC design principles:** one instr/cycle, register-register ops, load/store architecture, fixed-length simple formats, hardwired control, many registers.
- **MESI transitions:** read-miss → S or E; write → M (invalidates other copies); snooping keeps coherence.
- **SMP vs NUMA vs Cluster:** SMP = shared memory, UMA; NUMA = shared memory, non-uniform access; cluster = separate machines + interconnect, message passing.
- **I/O techniques by CPU load:** DMA < interrupt-driven < programmed/polling.

---

## 🗓️ Final-revision plan (≈5 focused sessions)

1. **Memory systems** — `05` (Hamming!) + `06` (disk/RAID). Notes → all exercises → mock Section A–B.
2. **ISA & CPU design** — `08` (addressing/EA) + `09` (CISC/RISC). Notes → exercises → mock Section D.
3. **Pipelining** — `10`. Drill the four formulas + hazards + branch penalty → mock Section C.
4. **Parallelism** — `11` (Flynn + MESI) + `12` (Amdahl/multicore) + `07` (I/O). → mock Section E–F.
5. **Carryover + full mock** — re-skim `02`/`04`, then sit **`FINAL-MOCK-EXAM.md`** under a timer. Re-attempt `MIDTERM-MOCK-EXAM.md` for the carryover cache/performance reps.

> Night before: one pass of `MASTER-CHEATSHEET.md` + this trap list. You've got this. 💪

---

### 🔗 Using the older midterm files
`00-MIDTERM-FOCUS.md` and `MIDTERM-MOCK-EXAM.md` now serve as your **first-half carryover** drill — specifically the **cache hex-split** and **performance reverse-solve** questions, which the final is likely to recycle. Everything else there (instruction cycle, interrupts) is lower priority for the final.
