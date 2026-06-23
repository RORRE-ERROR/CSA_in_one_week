# 🎯 MASTER CHEAT SHEET — All Chapters

> Final-night revision. One screen per topic. For depth, open the chapter's own `review.md`.

---

## 01 · Introduction
- **Architecture** = attributes *visible to the programmer* (ISA, data types, addressing modes, I/O mechanism). **Organisation** = *how* it's implemented (control signals, interfaces, memory tech). → *Same architecture, many organisations.*
- **4 functions:** Data **Processing**, **Storage**, **Movement**, **Control** → mnemonic **"P-S-M-C"**.
- **Top-level structure:** CPU + Main Memory + I/O + System Bus. **CPU internals:** ALU, Control Unit, Registers, internal interconnect.
- **Generations:** ① Vacuum tube (ENIAC/von Neumann/IAS) ② Transistor ③ IC (Moore's Law) ④ LSI/VLSI/μprocessor.
- **Moore's Law:** transistors per chip ≈ **doubles ~every 2 years**.

## 02 · Performance  ⭐formulas
```text
CPU time = Instruction Count × CPI × Clock cycle time
         = (IC × CPI) / Clock rate
MIPS = IC / (CPU time × 10^6) = Clock rate / (CPI × 10^6)
Amdahl speedup  S = 1 / [ (1−f) + f/k ]      (f = fraction sped up, k = factor)
   → max speedup as k→∞ is 1/(1−f)   (the ceiling!)
```
- **Means:** rates → **harmonic**; ratios/speedups → **geometric**; times → **arithmetic**.
- ⚠️ **MIPS/MFLOPS are misleading** across different ISAs/programs.

## 03 · Computer Function & Interconnection
- **Instruction cycle:** **Fetch → Decode → Execute** (+ Indirect, + Interrupt stages).
- **Registers:** PC (next addr), MAR (addr to bus), MBR (data to/from mem), IR (current instr), AC (accumulator).
- **Interrupts** let I/O overlap CPU work. Classes: program, timer, I/O, hardware failure.
- **Multiple interrupts:** *Sequential* (disable during ISR) vs *Nested* (priority preempt).
- **Buses:** **Data** (width = word size), **Address** (width = addressable memory), **Control**.

## 04 · Cache Memory  ⭐the bit-field recipe
- **Locality:** *Temporal* (reuse soon) + *Spatial* (nearby next).
- **Address split** — let block size = 2^w words, cache = 2^L lines / 2^s sets:
```text
DIRECT:           | TAG | LINE | WORD |
FULLY ASSOC.:     | TAG |      | WORD |     (no line field)
SET ASSOC.:       | TAG | SET  | WORD |
word bits = log2(block size);  set/line bits = log2(#lines or #sets);  tag = remaining
```
- **Replacement:** LRU (best), FIFO, LFU, Random (only for associative).
- **Write:** *Write-through* (simple, slow) vs *Write-back* (dirty bit, fast, coherence risk).
- `Avg access time = Hit time + Miss rate × Miss penalty`. Hit ratio H → `T = H·Tcache + (1−H)·Tmem`.

## 05 · Internal Memory
| | SRAM | DRAM |
|--|------|------|
| Cell | flip-flop (6T) | capacitor (1T) |
| Refresh | No | **Yes** |
| Speed | Fast | Slower |
| Density/cost | Low / costly | High / cheap |
| Use | **Cache** | **Main memory** |
- **ROM family:** ROM → PROM (once) → EPROM (UV erase) → EEPROM (electrical, byte) → **Flash** (electrical, block).
- **DDR** doubles rate: data on **both clock edges** (+ higher bus clock + prefetch buffer 2→4→8→8 for DDR1-4).
- **Hamming SEC:** check bits k satisfy **2^k ≥ m + k + 1**; XOR-parity groups → **syndrome** points to the bad bit.

## 06 · External Memory  ⭐formulas
```text
Disk access time = Seek time + Rotational latency + Transfer time
Avg rotational latency = (1/2) × (60 / RPM)  seconds
Transfer time = (bytes to read) / (track size × RPS)  ≈ b / (r·N)
```
| RAID | Idea | Min disks | Fault tolerance |
|----:|------|:--:|---|
| 0 | Striping | 2 | **None** (speed only) |
| 1 | Mirroring | 2 | 1 disk |
| 2 | Hamming ECC | — | rare |
| 3 | Byte parity, 1 parity disk | 3 | 1 disk |
| 4 | Block parity, 1 parity disk | 3 | 1 disk |
| 5 | **Distributed** parity | 3 | 1 disk |
| 6 | Dual distributed parity | 4 | **2 disks** |

## 07 · Input / Output  ⭐compare
| Technique | Who moves data | CPU busy? | Speed |
|-----------|----------------|-----------|-------|
| **Programmed I/O** (polling) | CPU | Yes — wastes cycles | Slow |
| **Interrupt-driven** | CPU (on interrupt) | Frees CPU between transfers | Medium |
| **DMA** | DMA controller | Only at start & end | **Fast** (bulk) |
- **DMA cycle stealing:** DMA grabs the bus for one cycle, briefly pausing CPU.
- Device ID for interrupts: software poll / **daisy chain** (HW poll) / bus arbitration.
- **Memory-mapped** I/O (shares address space, uses normal loads/stores) vs **Isolated** I/O (separate I/O instructions/space).

## 08 · Instruction Set Architecture  ⭐addressing modes
| Mode | Effective Address | Note |
|------|-------------------|------|
| Immediate | operand = A (in instruction) | no memory ref |
| Direct | EA = A | one memory ref |
| Indirect | EA = (A) | two memory refs |
| Register | EA = R | fastest |
| Register indirect | EA = (R) | |
| Displacement | EA = A + (R) | relative / base / indexed |
| Stack | EA = top of stack | implicit |
- **n-address machines:** 3-addr (most code-compact ops) → 2-addr → 1-addr (**accumulator**) → 0-addr (**stack**).
- **Endianness:** *Big-endian* = MSB at lowest address; *Little-endian* = LSB at lowest address.

## 09 · CISC vs RISC
| | CISC | RISC |
|--|------|------|
| Instructions | many, complex, variable-length | few, simple, **fixed-length** |
| Addressing modes | many | few |
| Memory access | many instructions | **load/store only** |
| Registers | few | **many** (+ register windows) |
| Control unit | microcoded | **hardwired** |
| Cycles/instr | variable, multi | mostly **1** (pipelined) |
| Code size | small | larger |
- **Convergence:** modern x86 = *CISC outside, RISC inside* (decodes to micro-ops). Mnemonic: **"RISC = Reduced Instruction Set, but more instructions executed."**

## 10 · Pipelining  ⭐formulas
```text
k-stage pipeline, n instructions:
  Time (pipelined)  = (k + n − 1) cycles
  Speedup  S = n·k / (k + n − 1)   → approaches k for large n (the ceiling!)
  Efficiency = S / k ;  Throughput = n / [(k+n−1)·τ]
```
- **Hazards:** **Structural** (resource clash), **Data** (RAW/WAR/WAW), **Control** (branch).
- **Branch handling:** multiple streams · prefetch target · loop buffer · **branch prediction** (static / dynamic 2-bit) · delayed branch.

## 11 · Parallel Processing  ⭐Flynn
| | Single Data | Multiple Data |
|--|--|--|
| **Single Instr** | **SISD** (uniprocessor) | **SIMD** (vector/GPU) |
| **Multiple Instr** | **MISD** (rare) | **MIMD** (multiprocessor/cluster) |
- Mnemonic: **"S-S, S-M, M-S, M-M"**.
- **SMP** = tightly coupled, shared memory. **Cluster** = loosely coupled, message passing. **NUMA** = shared mem, non-uniform latency.
- **MESI** cache-coherence states: **M**odified, **E**xclusive, **S**hared, **I**nvalid.

## 12 · Multicore Computers
- **Why multicore:** power wall + ILP limits + **Pollack's rule** (perf ∝ √complexity → many simple cores win).
- **Chip options:** superscalar → SMT (hyperthreading) → **multicore**.
- **Cache:** dedicated L2 vs **shared L2/L3**.
- **Amdahl on cores:** `S(N) = 1 / [ (1−f) + f/N ]` → speedup capped by serial fraction; more cores ≠ proportional gain.
- **Heterogeneous:** ARM **big.LITTLE**, CPU+GPU (HSA).

---

### 🔑 The formulas examiners reuse most
```text
CPU time = IC × CPI × Tclock
Amdahl   = 1 / [(1−f) + f/k]
Cache addr = | TAG | LINE/SET | WORD |   (word=log2 block, line/set=log2 count)
Avg access = Hit + MissRate × MissPenalty
Disk = Seek + (½·60/RPM) + Transfer
Pipeline = (k+n−1) cycles ;  Speedup = nk/(k+n−1)
```

> 🧠 If you can reproduce this sheet from memory, you're ready. Re-derive each formula, then redraw: instruction cycle · cache address split · pipeline space-time · MESI states · Flynn 2×2.
