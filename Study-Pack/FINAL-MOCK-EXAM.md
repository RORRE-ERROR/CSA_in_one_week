# 🏁 Final Mock Exam (WIA1003)

> **38 MCQs · ~70-minute timer · closed book.** Same style as the midterm; weighted to the **second half (Ch 05–12)** with **first-half carryover** (cache & performance) at the end.
> Reveal each answer only after you commit. Working is shown so you learn the method. See `00-FINAL-FOCUS.md` for archetypes & traps.

---

## Section A — Internal Memory (Ch 05)

**Q1.** How many Hamming SEC check bits are needed to protect **16 data bits**?
A. 4   B. 5   C. 6   D. 8

<details><summary>Answer</summary>

**B — 5.** Smallest K with `2^K ≥ M + K + 1`: K=5 → 32 ≥ 16+5+1 = 22 ✓; K=4 → 16 ≥ 21 ✗.
</details>

**Q2.** A 7-bit SEC Hamming codeword (check bits at 1,2,4) is received as `0 1 1 0 1 1 1` (positions 1→7). Which bit is in error?
A. No error   B. Position 3   C. Position 5   D. Position 7

<details><summary>Answer</summary>

**C — Position 5.**
S1(1,3,5,7)=0⊕1⊕1⊕1=**1**; S2(2,3,6,7)=1⊕1⊕1⊕1=**0**; S4(4,5,6,7)=0⊕1⊕1⊕1=**1**.
Syndrome S4S2S1 = `101` = **5** → flip position 5. (Syndrome value = the position, not a data index.)
</details>

**Q3.** Which statement about SRAM vs DRAM is correct?
A. DRAM is faster and needs no refresh
B. SRAM stores bits as capacitor charge and must be refreshed
C. SRAM uses flip-flops (fast, no refresh) — used for cache; DRAM uses a capacitor (dense, cheap, needs refresh) — used for main memory
D. Both require periodic refresh

<details><summary>Answer</summary>

**C.** SRAM = flip-flop → fast, no refresh, lower density (cache). DRAM = 1T+capacitor → dense, cheap, **leaks → needs refresh** (main memory).
</details>

**Q4.** Which memory type is erased **electrically, one byte at a time**?
A. EPROM   B. EEPROM   C. Flash   D. PROM

<details><summary>Answer</summary>

**B — EEPROM.** EPROM = UV, whole chip; **EEPROM = electrical, byte**; Flash = electrical, **block**; PROM = write-once.
</details>

**Q5.** Why must DRAM be refreshed?
A. To clear cache coherence flags
B. Because the capacitor storing each bit leaks charge and would lose the data
C. To synchronise it with the CPU clock
D. To erase worn-out flash blocks

<details><summary>Answer</summary>

**B.** Each DRAM bit is charge on a capacitor that leaks; refresh reads each row and writes it back to recharge the cells, within a few-ms interval.
</details>

**Q6.** DDR SDRAM achieves higher throughput than classic SDRAM primarily because it:
A. Transfers data on **both** the rising and falling clock edges
B. Removes the need for a memory bus
C. Stores two bits per capacitor
D. Eliminates the refresh requirement

<details><summary>Answer</summary>

**A.** "Double Data Rate" = 2 transfers per clock (both edges), plus higher bus clocks and a prefetch buffer each generation.
</details>

---

## Section B — External Memory (Ch 06)

**Q7.** A disk spins at **6000 RPM**, average seek = **8 ms**, **300 sectors/track**. What is the average time to read **one sector**?
A. ≈ 8.0 ms   B. ≈ 13.0 ms   C. ≈ 18.3 ms   D. ≈ 5.0 ms

<details><summary>Answer</summary>

**B — ≈13.0 ms.** `r = 6000/60 = 100 rev/s` → one rev = 10 ms.
Latency = `1/(2r) = 5 ms`. Transfer one sector = `10 ms / 300 = 0.033 ms`.
Total = `8 + 5 + 0.033 ≈ 13.03 ms` (positioning dominates).
</details>

**Q8.** Average **rotational latency** equals:
A. One full revolution time
B. Half a revolution time, `1/(2r)`
C. The seek time
D. `bytes / (r·N)`

<details><summary>Answer</summary>

**B.** On average you wait half a rotation for the sector to arrive → `1/(2r)`.
</details>

**Q9.** Six 4 TB disks in **RAID 5**. Usable capacity and how many failures it survives?
A. 24 TB, 0 failures
B. 12 TB, 1 failure
C. 20 TB, 1 failure
D. 16 TB, 2 failures

<details><summary>Answer</summary>

**C — 20 TB, 1 failure.** RAID 5 = `(N−1)·cap = 5×4 = 20 TB`, single distributed parity → survives **one** disk failure (a second failure during rebuild loses data; that's what RAID 6 fixes).
</details>

**Q10.** Why do RAID 4/5 suffer a "small-write penalty"?
A. Mirrors must be kept identical
B. Each small write needs **2 reads + 2 writes** (read old data + old parity, write new data + new parity)
C. The stripe must be fully rebuilt every write
D. Parity disks are slower hardware

<details><summary>Answer</summary>

**B.** To update parity for one strip the controller reads the old data and old parity, computes new parity, and writes both back — 4 disk ops. RAID 1 (no parity) has no such penalty.
</details>

**Q11.** Under **Constant Angular Velocity (CAV)**, bit density is highest on the:
A. Outermost track   B. Innermost track   C. Middle track   D. It is uniform

<details><summary>Answer</summary>

**B — innermost track.** CAV puts the same bits on every track; the short inner track packs them densest, and outer-track capacity is wasted (which Multiple Zone Recording fixes).
</details>

---

## Section C — Input/Output (Ch 07)

**Q12.** Order the three I/O techniques by **increasing** CPU involvement per data unit:
A. DMA < Interrupt-driven < Programmed (polling)
B. Programmed < Interrupt-driven < DMA
C. Interrupt-driven < Programmed < DMA
D. They are equal

<details><summary>Answer</summary>

**A.** DMA off-loads the whole block to a controller (least CPU); interrupt-driven services each transfer but doesn't busy-wait; programmed/polling has the CPU move every word (most CPU).
</details>

**Q13.** **Cycle stealing** in DMA means the DMA controller:
A. Raises an interrupt for every word transferred
B. Takes over the bus for one cycle to transfer a word, briefly pausing the CPU (no interrupt, no context switch)
C. Permanently locks the CPU out of memory during the transfer
D. Copies data through the ALU

<details><summary>Answer</summary>

**B.** The DMA module "steals" one bus cycle at a time; the CPU is delayed slightly but not interrupted — cheaper than a full interrupt per word.
</details>

**Q14.** In **memory-mapped I/O**, device registers are:
A. Accessed with special IN/OUT instructions only
B. Assigned addresses in the same address space as memory, so ordinary load/store instructions reach them
C. Inaccessible to the CPU
D. Always cached

<details><summary>Answer</summary>

**B.** Memory-mapped I/O shares the memory address space (any memory-reference instruction works); isolated I/O uses a separate address space with dedicated I/O instructions.
</details>

---

## Section D — Instruction Set Architecture (Ch 08)

Machine state for Q15–Q16: `A = 200 (address field), R1 = 600, PC = 50`; `M[200]=350, M[600]=999`.

**Q15.** Under **displacement** addressing using R1 (`EA = A + (R1)`), the effective address is:
A. 200   B. 600   C. 800   D. 350

<details><summary>Answer</summary>

**C — 800.** EA = A + (R1) = 200 + 600 = **800**.
</details>

**Q16.** How many memory references (to obtain the operand) does **indirect** addressing `EA = (A)` require, versus **register-indirect** `EA = (R)`?
A. 2 vs 1   B. 1 vs 2   C. 2 vs 2   D. 1 vs 1

<details><summary>Answer</summary>

**A — 2 vs 1.** Indirect: read pointer at M[A], then read operand → 2. Register-indirect: pointer already in the register → only the operand read → 1.
</details>

**Q17.** Ranking by **number of instructions** to evaluate an expression, which is correct (fewest → most)?
A. 0-address < 1-address < 3-address
B. 3-address < 1-address < 0-address
C. 1-address < 3-address < 0-address
D. They are equal

<details><summary>Answer</summary>

**B.** 3-address packs the most work per instruction (fewest instrs); accumulator (1-address) needs LOAD/STORE traffic; stack (0-address) needs the most instructions.
</details>

**Q18.** The 32-bit value `0xDEADBEEF` is stored from byte address 4000 on a **little-endian** machine. What byte is at address 4000?
A. 0xDE   B. 0xEF   C. 0xAD   D. 0xBE

<details><summary>Answer</summary>

**B — 0xEF.** Little-endian stores the **least-significant** byte at the lowest address (4000=EF, 4001=BE, 4002=AD, 4003=DE).
</details>

**Q19.** A 16-bit instruction must encode **32 opcodes** and one memory address operand. How many addresses can it reach directly?
A. 1024   B. 2048   C. 4096   D. 65536

<details><summary>Answer</summary>

**B — 2048.** 32 opcodes → 5 opcode bits; address field = 16−5 = 11 bits → 2¹¹ = **2048** locations.
</details>

---

## Section E — CISC vs RISC (Ch 09)

**Q20.** Which is a core **RISC** design principle?
A. Variable-length instructions to minimise code size
B. Memory-to-memory arithmetic on operands
C. Register-to-register operations with a simple load/store architecture, aiming for one instruction per cycle
D. Microcoded interpretation of complex instructions

<details><summary>Answer</summary>

**C.** RISC: fixed-length, register-register ALU ops, only load/store touch memory, hardwired control, large register file, target 1 instr/cycle. A/B/D describe CISC.
</details>

**Q21.** Compared with CISC, RISC programs typically have:
A. Fewer instructions and larger code size
B. More instructions but simpler, faster-to-pipeline ones (and larger code size)
C. Identical code in every case
D. Complex variable-length instructions

<details><summary>Answer</summary>

**B.** RISC uses more, simpler instructions (code is larger) but each is fast and easy to pipeline — the design trade that favoured throughput.
</details>

**Q22.** **Register windows** (e.g. SPARC) primarily reduce:
A. Cache misses
B. The cost of saving/restoring registers across procedure calls
C. Branch mispredictions
D. Memory refresh overhead

<details><summary>Answer</summary>

**B.** Overlapping register windows pass parameters and preserve locals across calls in registers, cutting the memory traffic of call/return.
</details>

---

## Section F — Pipelining (Ch 10)

**Q23.** A **5-stage** pipeline executes **100** instructions with no hazards. Total clock cycles?
A. 100   B. 104   C. 105   D. 500

<details><summary>Answer</summary>

**B — 104.** `cycles = k + (n−1) = 5 + 99 = 104`. (Non-pipelined would be 5×100 = 500.)
</details>

**Q24.** For that pipeline (k=5, n=100), the **speedup** over non-pipelined is closest to:
A. 5.00×   B. 4.81×   C. 3.85×   D. 1.04×

<details><summary>Answer</summary>

**B — 4.81×.** `S = nk/(k+n−1) = 500/104 = 4.81`. (Efficiency η = S/k = 0.96.) Note: speedup can **never exceed k = 5**.
</details>

**Q25.** Classify: `I1: ADD R1,R2,R3` then `I2: SUB R4,R1,R5`.
A. WAR hazard   B. WAW hazard   C. RAW (true) data hazard   D. Structural hazard

<details><summary>Answer</summary>

**C — RAW.** I2 **reads R1** that I1 **writes** — read-after-write, the only dependency that stalls a simple in-order pipeline.
</details>

**Q26.** A 5-stage pipeline (cycle = 1 ns) runs **100** instructions; **20** are taken branches each costing a **4-cycle** penalty. Total cycles?
A. 104   B. 124   C. 184   D. 504

<details><summary>Answer</summary>

**C — 184.** Base `= 104`; stalls `= 20 × 4 = 80`; total `= 104 + 80 = 184` cycles. (Effective speedup vs 500 = 2.72× — branches roughly halve the benefit.)
</details>

**Q27.** A 2-bit saturating predictor in state **11 (strong taken)** sees the branch **not taken**. Its next state and prediction were:
A. → 10, had predicted Taken
B. → 00, had predicted Not-taken
C. → 11, had predicted Taken
D. → 01, had predicted Not-taken

<details><summary>Answer</summary>

**A.** In 11 it predicts **Taken**; a single wrong (not-taken) outcome moves it to **10** (still predicts taken) — the 2-bit scheme tolerates one anomaly before flipping.
</details>

---

## Section G — Parallel Processing (Ch 11)

**Q28.** In Flynn's taxonomy, a GPU / vector unit applying one instruction to many data elements is:
A. SISD   B. SIMD   C. MISD   D. MIMD

<details><summary>Answer</summary>

**B — SIMD.** Single Instruction, Multiple Data. A uniprocessor = SISD; SMP/multicore/clusters = MIMD; **MISD** is the rare/essentially-unused class.
</details>

**Q29.** The four states of the **MESI** protocol are:
A. Modified, Exclusive, Shared, Invalid
B. Master, Exclusive, Slave, Idle
C. Modified, Empty, Shared, Idle
D. Mapped, Evicted, Stored, Invalid

<details><summary>Answer</summary>

**A.** **M**odified (dirty, only copy), **E**xclusive (clean, only copy), **S**hared (clean, may exist elsewhere), **I**nvalid.
</details>

**Q30.** A cache line is **Shared** in two cores' caches. Core 1 **writes** to it. Under MESI, afterwards:
A. Both copies become Shared
B. Core 1's line → **Modified**; Core 2's copy → **Invalid**
C. Both become Exclusive
D. Core 1's line → Invalid

<details><summary>Answer</summary>

**B.** A write must gain exclusivity: Core 1 invalidates other copies (snooping) and transitions its line to **Modified**; Core 2's copy becomes **Invalid**.
</details>

**Q31.** Which best distinguishes **NUMA** from **SMP**?
A. NUMA uses message passing only
B. Both share one global memory, but in NUMA memory-access latency depends on which processor/region is accessed (non-uniform)
C. SMP has no shared memory
D. NUMA is a cluster of independent computers

<details><summary>Answer</summary>

**B.** SMP = symmetric shared memory with **uniform** access; NUMA = shared address space but **non-uniform** access latency (local vs remote). Clusters use separate memories + message passing.
</details>

---

## Section H — Multicore (Ch 12)

**Q32.** A program is **80% parallelizable**. With **4** cores, Amdahl's Law gives a speedup of:
A. 2.0×   B. 2.5×   C. 3.2×   D. 4.0×

<details><summary>Answer</summary>

**B — 2.5×.** `S = 1/[(1−0.8) + 0.8/4] = 1/[0.2 + 0.2] = 1/0.4 = 2.5×`.
</details>

**Q33.** For that same program (f = 0.8), the **maximum** speedup with infinite cores is:
A. 4×   B. 5×   C. 8×   D. unbounded

<details><summary>Answer</summary>

**B — 5×.** `S_max = 1/(1−f) = 1/0.2 = 5×`. The 20% serial part caps everything — the core lesson of Amdahl on multicore.
</details>

**Q34.** **Pollack's rule** states that a single core's performance rises roughly with the:
A. Square of the transistor/area budget
B. **Square root** of the increase in logic complexity (area)
C. Cube of the clock frequency
D. Number of cache levels

<details><summary>Answer</summary>

**B — square root.** Doubling a core's complexity yields only ~√2 ≈ 1.4× performance — diminishing returns that motivate using the transistor budget for **more cores** instead of one bigger core.
</details>

---

## Section I — Carryover: Cache & Performance (Ch 04 & 02)

**Q35.** Main memory **4 GB** (32-bit byte address), **direct-mapped** cache **256 KB**, block **64 B**. How many **TAG** bits?
A. 6   B. 12   C. 14   D. 20

<details><summary>Answer</summary>

**C — 14.** `w = log₂64 = 6`; lines = 256 KB/64 = 4096 = 2¹² → LINE = 12; TAG = 32 − 12 − 6 = **14**.
</details>

**Q36.** Memory access = **200 ns**, cache access = **20 ns**, hit ratio = **95%**. Effective access time (course model)?
A. 20 ns   B. 29 ns   C. 30 ns   D. 200 ns

<details><summary>Answer</summary>

**B — 29 ns.** `EAT = H·Tc + (1−H)·Tm = 0.95·20 + 0.05·200 = 19 + 10 = 29 ns`. (Use the weighted-average model this course expects.)
</details>

**Q37.** A program of **1.5×10⁹** instructions must finish in **1.5 s** on a **2 GHz** CPU. What average CPI is required?
A. 1.0   B. 2.0   C. 3.0   D. 0.5

<details><summary>Answer</summary>

**B — 2.0.** Target cycles `= T·f = 1.5 × 2×10⁹ = 3×10⁹`; `CPI = cycles/Ic = 3×10⁹ / 1.5×10⁹ = 2.0`.
</details>

**Q38.** Two machines run the **same task**. Machine P has higher **MIPS** than Q but needs far more instructions for the task. Which is faster, and why?
A. P, because MIPS directly measures speed
B. Cannot tell from MIPS alone — compare **execution time** (Ic × CPI / f); more instructions can make the higher-MIPS machine slower
C. Q always, because it has fewer instructions
D. They tie

<details><summary>Answer</summary>

**B.** MIPS ignores how much work each instruction does and how many a task needs. The fair comparison is execution time; a higher-MIPS machine can lose if its instruction count is much larger.
</details>

---

## 📊 Score yourself

| Score | Verdict |
|------:|---------|
| 34–38 | Exam-ready. Skim `MASTER-CHEATSHEET.md` + the trap list and rest. |
| 27–33 | Strong. Re-drill the archetypes you missed in `00-FINAL-FOCUS.md`. |
| 20–26 | Re-read the notes for your weak chapters and redo their `exercises.md`, then retake. |
| < 20 | Work chapters in the order in `00-FINAL-FOCUS.md` (memory → ISA → pipelining → parallel) before retrying. |

> Missed a **numerical**? Redo it from a blank page — you lost the method, not the number.
> Missed a **concept**? Add it to your trap list and re-read that section's `notes.md`.
