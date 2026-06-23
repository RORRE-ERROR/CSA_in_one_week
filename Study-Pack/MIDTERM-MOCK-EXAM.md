# 📝 Midterm Mock Exam — First Half (WIA1003)

> **25 MCQs · 50-minute timer · closed book.** Mirrors the real Midterm Test (22 April 2026) in style and difficulty.
> Covers `01-Introduction`, `02-Performance`, `03-Computer-Function`, `04-Cache-Memory`, and the interrupt/DMA parts of `07-Input-Output`.
> Reveal each answer only **after** you commit. Working is shown so you learn the method, not the number.
>
> See `00-MIDTERM-FOCUS.md` for the question archetypes and traps these drill.

---

## Section A — Introduction & performance techniques (Ch 01)

**Q1.** As transistors on a chip shrink, what happens to the on-chip wire interconnects and their electrical behaviour?
A. Thinner wires → higher resistance; closer together → higher capacitance → increased RC delay
B. Thicker wires → lower resistance
C. Thinner wires → lower resistance
D. Wires move further apart → lower capacitance
E. None of the answers is correct

<details><summary>Answer</summary>

**A.** Shrinking makes wires **thinner (↑ resistance)** and **closer (↑ capacitance)**; RC delay rises and increasingly limits clock speed — a key reason raw clock scaling stalled.
</details>

**Q2.** Which of the following is **NOT** a technique used in contemporary processors to improve performance?
A. Increasing the size and speed of caches
B. Increasing hardware speed by shrinking logic-gate size
C. Parallelism (more cores / pipelining / superscalar)
D. Decreasing the power density
E. None of the answers is correct

<details><summary>Answer</summary>

**D.** Falling power density is *desirable* but it is **not a performance technique** — rising power density is the *problem* (the power wall). The real techniques are A, B, and C.
</details>

**Q3.** The primary reason industry moved from ever-higher clock speeds to multicore designs is:
A. Compilers could not keep up
B. The power wall (power density/heat), plus RC delay and memory latency lagging the CPU
C. Instructions became too long to decode
D. Caches became unnecessary

<details><summary>Answer</summary>

**B.** Power density rises with logic density and clock frequency until the chip can't be cooled — combined with RC delay and the memory gap, this forced the shift to multiple slower-but-parallel cores.
</details>

---

## Section B — Performance numericals (Ch 02)

**Q4.** A computer has a clock rate of **50 MHz**. How long does it take to execute a program of **1,000 instructions** if the CPI is **3.5**?
A. 70 µs
B. 142.8 ns
C. 700 ns
D. 1.428 ms

<details><summary>Answer</summary>

**A — 70 µs.** `T = Ic × CPI / f = 1000 × 3.5 / (50×10⁶) = 3500 / 5×10⁷ = 7×10⁻⁵ s = 70 µs.`
</details>

**Q5.** You are evaluating **Processor A** (3.0 GHz, CPI 1.5, task = 5×10⁹ instructions) and **Processor B** (2.4 GHz, task compiles to 3.5×10⁹ instructions). If **B must run the task 20% faster** (take 20% less time) than A, what average CPI must B have?
A. 1.500
B. 1.714
C. 1.200
D. 1.371

<details><summary>Answer</summary>

**D — 1.371.**
`T_A = 5×10⁹ × 1.5 / 3.0×10⁹ = 2.5 s.`
20% faster ⇒ `T_B = 0.8 × 2.5 = 2.0 s` (×0.8, **not** ÷1.2).
`CPI_B = T_B × f_B / Ic_B = 2.0 × 2.4×10⁹ / 3.5×10⁹ = 4.8×10⁹ / 3.5×10⁹ = 1.371.`
</details>

**Q6.** A workstation CPU runs at **4.0 GHz**; a program of **1.6×10¹⁰** instructions currently takes 10 s. Mix: Floating-point 30% (CPI 4), Integer 40% (CPI 1), Memory 30% (CPI unknown). An upgrade affecting **only the Memory-op CPI** brings total execution time to **8.5 s**. What is the new Memory CPI?
A. 2.125
B. 3.00
C. 1.75
D. 2.5

<details><summary>Answer</summary>

**C — 1.75.**
Target total cycles `= T × f = 8.5 × 4.0×10⁹ = 3.4×10¹⁰`.
Target average CPI `= 3.4×10¹⁰ / 1.6×10¹⁰ = 2.125`.
Mix: `2.125 = 0.30(4) + 0.40(1) + 0.30·CPIₘ = 1.6 + 0.30·CPIₘ` ⇒ `CPIₘ = 0.525/0.30 = 1.75`.
*(The "10 s" figure is a distractor — you don't need it.)*
</details>

**Q7.** A 2.5 GHz processor runs a program of **2×10⁶** instructions. Mix: ALU 40% (CPI 1), Load 25% (CPI 4), Store 15% (CPI 3), Branch 20% (CPI 2). A compiler optimisation cuts **ALU instructions by 50%** and **Branch instructions by 25%** (Load/Store and clock unchanged). What are the **new overall CPI** and **new execution time**?
A. CPI = 2.60, time = 1.56 ms
B. CPI = 2.00, time = 1.20 ms
C. CPI = 2.25, time = 1.80 ms
D. CPI = 2.60, time = 1.80 ms

<details><summary>Answer</summary>

**A — CPI = 2.60, time = 1.56 ms.**
Counts (Ic = 2×10⁶): ALU 800k, Load 500k, Store 300k, Branch 400k.
After: ALU 400k, Load 500k, Store 300k, Branch 300k → **new Ic = 1.5×10⁶**.
Cycles `= 400k(1) + 500k(4) + 300k(3) + 300k(2) = 0.4 + 2.0 + 0.9 + 0.6 = 3.9×10⁶`.
New CPI `= 3.9×10⁶ / 1.5×10⁶ = 2.60`.
New time `= 3.9×10⁶ / 2.5×10⁹ = 1.56 ms`.
⚠️ Option **D** uses the *old* Ic for the time — the trap. Time = cycles / f.
</details>

**Q8.** Two machines run the **same** program. Machine X: 1000 MIPS. Machine Y: 2000 MIPS but needs **2.5×** as many instructions for the task (same clock). Which finishes first?
A. Y, because its MIPS is double
B. X, because MIPS ignores how much work each instruction does
C. They tie
D. Cannot be determined

<details><summary>Answer</summary>

**B — X.** MIPS counts instructions/sec, not work. Y executes 2.5× the instructions, so it does more total cycles for the same task → slower despite higher MIPS. **Always compare execution time.**
</details>

---

## Section C — Computer function & interrupts (Ch 03)

**Q9.** During the **fetch cycle**, what is the primary function of the Program Counter (PC)?
A. It stores the final results of a completed execution cycle
B. It holds the actual instruction currently loaded into the IR
C. It holds the address of the next instruction to be fetched
D. It interprets the fetched instruction and performs the logic

<details><summary>Answer</summary>

**C.** The PC holds the **address** of the next instruction. (B describes the **IR**; D describes the control unit/ALU.)
</details>

**Q10.** In a program-execution trace (Stallings Fig 3.5), **immediately after the second instruction has been fetched**, what does the PC contain?
A. The address of the third instruction (it was incremented during the fetch)
B. The opcode of the second instruction
C. The data operand just read from memory
D. The address of the first instruction

<details><summary>Answer</summary>

**A.** The PC is **incremented during each fetch**, so right after fetching instruction #2 it already points to instruction #3. (If instructions start at 300: after fetch #1 PC=301, after fetch #2 PC=302.)
</details>

**Q11.** What is the primary reason modern computers provide an **interrupt mechanism**?
A. To improve processing efficiency because external devices are far slower than the CPU
B. To prevent the processor from ever using a system stack
C. To force instructions to execute in strict sequence
D. To let external devices run at the CPU's clock speed

<details><summary>Answer</summary>

**A.** Interrupts let the CPU do useful work instead of busy-waiting on slow I/O — the device signals when it's ready, raising overall efficiency.
</details>

**Q12.** Referring to the **Instruction Cycle with Interrupts** (Fig 3.9), when an interrupt is detected the processor:
A. Suspends the current program, saves its context (PC + PSW), and loads the PC with the interrupt-handler address
B. Disables all memory referencing and hands control to the DMA module
C. Ignores the interrupt until the whole program finishes, then stacks the next address
D. Halts, clears the IR, and waits for the I/O module to send new data
E. None of the answers is correct

<details><summary>Answer</summary>

**A.** The CPU finishes the **current instruction**, then saves context and vectors the PC to the handler. Note it checks for interrupts at the *end* of an instruction, not mid-instruction.
</details>

**Q13.** In the program-flow diagrams (Fig 3.7), what distinguishes the **"long I/O wait"** scenario (3.7c) from normal interrupt-driven execution?
A. The user program reaches the point needing the I/O result **before** the preceding I/O operation has completed, so it must wait
B. The processor suspends the user program indefinitely until *all* I/O devices finish
C. The I/O program bypasses the interrupt handler entirely
D. None of the answers is correct

<details><summary>Answer</summary>

**A.** In the long-wait case the I/O is so slow that the program catches up to where it needs the result and has to stall — versus the short-wait case where the CPU keeps doing useful work and the I/O finishes "in time." (B describes blocking/programmed I/O, not interrupt-driven.)
</details>

---

## Section D — Cache memory (Ch 04)

**Q14.** Using **fully associative** mapping with a **24-bit** byte-addressable address and a **4-byte** block, what is the exact **hex tag** the cache controller checks for the incoming address **FFFFFC**?
A. 1FFFF
B. 3FFFFF
C. FFFFF
D. 1FFFFF

<details><summary>Answer</summary>

**B — 3FFFFF.** Fully associative ⇒ address = TAG | WORD. `w = log₂(4) = 2`, so TAG = 24 − 2 = **22 bits** = address with the low 2 bits dropped. `FFFFFC ÷ 4 = 3FFFFF` (drop the trailing `…1100` → `…11`).
</details>

**Q15.** A **4-way set-associative** cache: byte-addressable main memory **16 MB**, cache **128 KB**, block **4 bytes**. For address **FFFFF8**, give the **hex tag** and **hex set**.
A. Tag 0FF, Set 1FFF
B. Tag 3FF, Set 0FFE
C. Tag 1FE, Set 1FF8
D. None of the answers is correct
E. Tag 1FF, Set 1FFE

<details><summary>Answer</summary>

**E — Tag 1FF, Set 1FFE.**
`n = log₂(16 MB) = 24`, `w = log₂(4) = 2`. Lines `= 128 KB / 4 = 32768 = 2¹⁵`; sets `= 32768 / 4 = 8192 = 2¹³` ⇒ **SET = 13 bits**, **TAG = 24 − 2 − 13 = 9 bits**.
`FFFFF8 = 1111 1111 1111 1111 1111 1000`.
WORD (low 2) = `00`. SET (next 13) = `1 1111 1111 1110` = **0x1FFE**. TAG (top 9) = `1 1111 1111` = **0x1FF**.
</details>

**Q16.** A system has main-memory access time **500 ns**, cache access time **50 ns**, and a hit ratio of **90%**. What is the effective (average) access time?
A. None of the answers is correct
B. 500 ns — memory time dominates
C. 95 ns — `H·T_cache + (1−H)·T_memory`
D. 450 ns
E. 100 ns — `T_cache + (1−H)·T_memory`

<details><summary>Answer</summary>

**C — 95 ns.** This course uses `EAT = H·T_c + (1−H)·T_m = 0.9·50 + 0.1·500 = 45 + 50 = 95 ns`.
⚠️ **E (100 ns)** uses the alternative model `T_c + (1−H)·T_m` — a real model, but the *distractor* here. If both appear, pick the weighted-average (95). See the trap in `00-MIDTERM-FOCUS.md`.
</details>

**Q17.** Which best describes **spatial locality**?
A. The tendency to reference in the near future the same units referenced in the recent past
B. The tendency to access one isolated variable repeatedly in a loop
C. The tendency to reference memory locations whose addresses are **close together**, around recently used ones
D. The tendency to reference units whose addresses are far apart
E. None of the answers is correct

<details><summary>Answer</summary>

**C.** Spatial locality = *nearby addresses are likely to be used soon* (justifies fetching a whole block). A and B describe **temporal** locality; D is the opposite.
*(On the real paper the options omitted a correct "nearby" choice, so the answer there was "None of the above" — read every option carefully.)*
</details>

**Q18.** In cache memory, what is a **tag**?
A. A designated portion of the address used to identify which memory block currently occupies a cache line
B. None of the answers is correct
C. The number of consecutive data bytes in one cache line
D. The minimum unit of transfer between cache and main memory
E. A region of cache that holds exactly one complete block of data

<details><summary>Answer</summary>

**A.** The tag stores the high-order address bits so the controller can verify a line holds the *requested* block. (D describes the **block**; E describes the **line/data field**.)
</details>

**Q19.** What is the primary disadvantage of a **write-through** policy?
A. It forces all I/O to access main memory only through the cache, limiting transfer speed
B. It generates substantial memory traffic because every write updates both cache and main memory
C. It needs highly complex circuitry that bottlenecks the processor
D. It causes large portions of main memory to hold invalid data

<details><summary>Answer</summary>

**B.** Write-through writes to memory on **every** store → high memory bus traffic. (D is the downside of **write-back**, where memory is stale until eviction.)
</details>

**Q20.** Which entity typically **manages** the cache (mapping, replacement, fetch-on-miss)?
A. The operating system, which swaps virtual-memory pages into the cache lines
B. The software compiler, allocating memory blocks at compile time
C. The user, who configures the mapping and replacement manually
D. The OS, which handles the rapid transfer of cache blocks
E. None of the answers is correct

<details><summary>Answer</summary>

**E — None of the above.** The cache is managed by **hardware (the cache controller)** and is **transparent** to the OS, compiler, and user. Since no option names the hardware, "None of the above" is correct.
</details>

**Q21.** Going **down** the memory hierarchy (registers → cache → main memory → disk), which is TRUE?
A. Cost per bit increases, capacity decreases
B. Capacity increases, access time increases (slower)
C. Speed increases, capacity decreases
D. Cost per bit increases, speed increases

<details><summary>Answer</summary>

**B.** Down the hierarchy: capacity ↑, access time ↑ (slower), cost/bit ↓, speed ↓. Only B is consistent.
</details>

**Q22.** Which mapping function needs **no replacement algorithm**, and why?
A. Fully associative — a block can go anywhere
B. Direct mapped — each block has exactly one legal line, so there is no victim to choose
C. 2-way set-associative — only two candidates
D. 8-way set-associative — LRU is trivial

<details><summary>Answer</summary>

**B — Direct mapped.** With one legal line per block there is no choice on a miss, so no replacement policy is needed. Associative/set-associative must pick a victim (typically **LRU**).
</details>

---

## Section E — Input/Output: interrupts & DMA (Ch 07)

**Q23.** What is the defining characteristic of **Direct Memory Access (DMA)**?
A. The processor must read every byte from the I/O module into the ALU
B. None of the answers is correct
C. I/O transfers occur directly with memory without constantly tying up the processor
D. I/O modules are forbidden from exchanging data directly with memory
E. The processor identifies a device and manages every single memory reference

<details><summary>Answer</summary>

**C.** The DMA controller moves a whole block between I/O and memory on its own; the CPU only **sets up** the transfer and is **interrupted once** at the end — it is not involved per word. (A/E describe programmed/interrupt-driven I/O.)
</details>

**Q24.** Compared with interrupt-driven I/O, the **CPU overhead** of transferring a large block by DMA is:
A. Higher, because DMA interrupts on every word
B. Much lower — the CPU is involved only at set-up and the single completion interrupt
C. Identical
D. Zero in all cases, including set-up

<details><summary>Answer</summary>

**B.** Interrupt-driven I/O interrupts the CPU **per word/byte**; DMA hands the whole block to the controller, so CPU overhead is ~constant regardless of block size (set-up + one final interrupt). (D is wrong — set-up still costs cycles, and DMA can "steal" bus cycles.)
</details>

**Q25.** Which sequence correctly orders the three I/O techniques by **increasing** CPU involvement per data unit?
A. DMA < Interrupt-driven < Programmed (polling)
B. Programmed < Interrupt-driven < DMA
C. Interrupt-driven < DMA < Programmed
D. They all involve the CPU equally

<details><summary>Answer</summary>

**A.** **DMA** (least — block handled by controller) < **Interrupt-driven** (CPU services each transfer but doesn't busy-wait) < **Programmed/polling** (most — CPU busy-waits and moves every word itself).
</details>

---

## 📊 Score yourself

| Score | Verdict |
|------:|---------|
| 23–25 | Exam-ready. Skim `MASTER-CHEATSHEET.md` and rest. |
| 18–22 | Solid. Re-drill the archetypes you missed in `00-MIDTERM-FOCUS.md`. |
| 13–17 | Re-read `02` and `04` notes + redo their `exercises.md`, then retake. |
| < 13 | Work the chapters in the order in `00-MIDTERM-FOCUS.md` before retrying. |

> Wrong on a **numerical**? You lost the *method*, not the number — redo it from a blank page.
> Wrong on a **concept**? Add it to your trap list and re-read that section's `notes.md`.
