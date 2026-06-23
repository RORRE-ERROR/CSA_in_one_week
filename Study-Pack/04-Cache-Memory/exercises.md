# Chapter 04 — Cache Memory · Exercises

> 🌱 **How to use this file.** Read `notes.md` first. Then try each problem **on your own** before opening the solution — even a rough, wrong attempt teaches you far more than reading the answer cold. Getting them wrong is *expected*; that's how you find your gaps.
>
> Keep the recipe beside you the whole time: `n = log2(memory)`, `w = log2(block)`, `s = n − w`, `m = cache / block`. Problems go **easy → harder**.

---

### Problem 1 — Hierarchy & locality (warm-up)
(a) Order registers, cache, disk, main memory by **decreasing** speed. (b) Which locality justifies transferring a whole **block** on a miss?

<details><summary>Show answer</summary>

(a) **Registers → Cache → Main memory → Disk** (fastest to slowest). The same order is also smallest → largest and most expensive → cheapest per bit.
(b) **Spatial** locality — nearby addresses are likely to be needed soon, so grabbing the whole surrounding block (not just one word) pays off.
</details>

---

### Problem 2 — Direct mapping basic split
Main memory = **4 GB**, cache = **256 KB**, block size = **64 B**. Direct-mapped. Find n, w, number of lines, line bits, tag bits, and draw the split.

<details><summary>Show answer</summary>

Walk the recipe step by step:
- `n = log2(4 GB) = log2(2^32) =` **32 bits** (4 GB = 2^32 bytes).
- `w = log2(64) =` **6 bits** (a block holds 64 bytes = 2^6).
- `m = 256 KB / 64 B = 262144 / 64 = 4096 = 2^12`, so **line bits r = 12**.
- `s = n − w = 32 − 6 = 26`, so **TAG = s − r = 26 − 12 = 14 bits**.

```text
 ┌──────────┬──────────┬─────────┐
 │ TAG 14   │ LINE 12  │ WORD 6  │  = 32  ✔
 └──────────┴──────────┴─────────┘
```
Sum check: 14 + 12 + 6 = 32 = n ✔
</details>

---

### Problem 3 — Fully associative split
Same system as P2 (4 GB memory, 64 B block) but **fully associative**. Give tag and word bits.

<details><summary>Show answer</summary>

Fully associative has **no line field** — a block can go in any line, so we don't index. Just tag + word:
- `w = 6`, `n = 32`, so `s = n − w =` **26**.
- **TAG = s = 26 bits**, WORD = 6 bits.

```text
 ┌────────────────┬─────────┐
 │    TAG 26      │ WORD 6  │  = 32  ✔
 └────────────────┴─────────┘
```
Notice the tag jumped from 14 bits (direct) to 26 bits — fully associative stores far more tag overhead, because the tag alone has to identify the block.
</details>

---

### Problem 4 — Set-associative split
Main memory = **1 GB**, cache = **128 KB**, block = **32 B**, **8-way** set-associative. Find set bits and tag bits.

<details><summary>Show answer</summary>

- `n = log2(1 GB) = log2(2^30) =` **30 bits**; `w = log2(32) =` **5 bits**; `s = 30 − 5 =` **25**.
- `m = 128 KB / 32 B = 131072 / 32 = 4096 = 2^12` lines.
- Now the key step — find the number of **sets** first: `v = m / k = 4096 / 8 = 512 = 2^9`, so **SET d = 9 bits**.
- **TAG = s − d = 25 − 9 = 16 bits**.

```text
 ┌──────────┬─────────┬─────────┐
 │ TAG 16   │ SET 9   │ WORD 5  │  = 30  ✔
 └──────────┴─────────┴─────────┘
```
Trap avoided: we used log2(**sets**)=9, not log2(lines)=12.
</details>

---

### Problem 5 — Which line / which set?
Cache: 1024 lines, block = 16 B, byte-addressable. (a) Direct-mapped: which **line** holds byte address **0x0001A4C0**? (b) If instead 4-way set-associative, which **set**?

<details><summary>Show answer</summary>

First turn the address into a block number:
- `0x0001A4C0 = 107712` (decimal). Block number = `107712 / 16 = 6732`.

(a) Direct mapping: `line = block mod (number of lines) = 6732 mod 1024`. Since `6732 = 6·1024 + 588`, the remainder is **line 588**.

(b) For 4-way: first the number of sets `v = 1024 / 4 = 256`. Then `set = block mod 256 = 6732 mod 256`. Since `6732 = 26·256 + 76`, the remainder is **set 76**.
</details>

---

### Problem 6 — Conflict / collision
Direct-mapped cache, **512 lines**, block = 8 B. Show that byte addresses **0x0000** and **0x1000** (4096) map to the same line. What distinguishes them?

<details><summary>Show answer</summary>

Block size is 8, so divide each address by 8 to get its block number:
- `0x0000 → block 0`; `0x1000 = 4096 → block 512` (4096 / 8 = 512).
- `line = block mod 512`: block 0 → `0 mod 512 =` **0**; block 512 → `512 mod 512 =` **0**. Both want **line 0** → a **collision**.
- They're told apart by their **tags**: `tag = block / 512` → **0** and **1** respectively. If a program keeps alternating between these two addresses, they keep evicting each other from line 0 — that's **thrashing**, the weakness of direct mapping.
</details>

---

> ⚠️ **Exam model note — read before Problems 7–8.** There are **two** effective-access-time (EAT) formulas in common use, and they give *different* numbers:
> - **Weighted average:** `EAT = H·T_cache + (1−H)·T_memory` — a hit costs *only* cache time, a miss costs *only* memory time.
> - **Additive (the form used in the solutions below):** `EAT = T_cache + (1−H)·T_memory` — you *always* pay cache time, plus the memory penalty on a miss.
>
> **Your midterm marked the *weighted-average* form as the correct one** (worked example: 500 ns memory, 50 ns cache, 90% hit → `0.9·50 + 0.1·500 = 95 ns`, **not** `50 + 0.1·500 = 100 ns`). So for the exam, **default to `H·Tc + (1−H)·Tm`** — but if a question's wording or its answer options clearly point at the additive model, follow that instead. The solutions below happen to use the additive form; the *method* is identical either way, only the formula swaps. See `../00-FINAL-FOCUS.md` and `../00-MIDTERM-FOCUS.md`.

### Problem 7 — Average access time
T_cache = 4 ns, T_memory = 80 ns. (a) H = 0.90, T_avg? (b) H = 0.98? (c) Speedup of (b) vs DRAM-only?

<details><summary>Show answer</summary>

Using the additive model `T_avg = T_cache + (1 − H)·T_memory` (you always pay the 4 ns cache time, plus 80 ns only on the fraction that miss):
- (a) `4 + 0.10·80 = 4 + 8 =` **12 ns**.
- (b) `4 + 0.02·80 = 4 + 1.6 =` **5.6 ns**.
- (c) Memory alone would take 80 ns per access, so the speed-up is `80 / 5.6 ≈` **14.3×** faster.

*(If your exam uses the weighted-average model instead, the method is the same — just swap in `H·Tc + (1−H)·Tm`.)*
</details>

---

### Problem 8 — Two-level cache access time
L1: 2 ns, hit ratio 0.95. L2: 10 ns, hit ratio 0.90 (of the L1 misses). Main memory: 100 ns. Compute average access time (model: always check L1; on an L1 miss check L2; on an L2 miss go to memory).

<details><summary>Show answer</summary>

Build it from the inside out. On every access you pay L1's 2 ns. The 5% that miss L1 then pay the L2 path; the 10% of *those* that also miss L2 pay memory:

```text
T_avg = T_L1 + (1−H1)·[ T_L2 + (1−H2)·T_mem ]
      = 2 + 0.05·[ 10 + 0.10·100 ]
      = 2 + 0.05·[ 10 + 10 ]
      = 2 + 0.05·20
      = 2 + 1.0
      = 3.0 ns
```
L2 soaks up most of the L1 misses, so the expensive trip to memory happens rarely and the penalty stays tiny.
</details>

---

### Problem 9 — Reverse engineering
A direct-mapped, byte-addressable cache uses the split **TAG=12 | LINE=10 | WORD=4**. Find: (a) address width, (b) block size, (c) number of lines, (d) cache data capacity, (e) main memory size.

<details><summary>Show answer</summary>

Run the recipe backwards — each field width is a power of two:
- (a) `n = 12 + 10 + 4 =` **26 bits** (just add the fields).
- (b) block size `= 2^WORD = 2^4 =` **16 bytes**.
- (c) lines `= 2^LINE = 2^10 =` **1024 lines**.
- (d) cache data `= lines × block size = 1024 × 16 = 16384 =` **16 KB**.
- (e) memory `= 2^n = 2^26 =` **64 MB**.
</details>

---

### Problem 10 — Mapping comparison & policy
For a cache that must (a) avoid all conflict misses, (b) be cheapest in hardware, (c) balance both — name the mapping. Then: which write policy minimises memory traffic, and what allocate policy normally pairs with it?

<details><summary>Show answer</summary>

- (a) **Fully associative** — a block can go in *any* line, so two hot blocks never have to fight over the same slot → no conflict misses.
- (b) **Direct mapped** — only one comparator and a fixed line, so it's the simplest/cheapest hardware.
- (c) **Set-associative** — the compromise between the two.
- Write policy that minimises memory traffic: **write-back** (it writes to memory only when a dirty block is evicted, not on every write). It normally pairs with **write-allocate**.
</details>

---

### Problem 11 (challenge) — Full split + locate + tag
Memory = **512 MB**, cache = **1 MB**, block = **128 B**, **2-way** set-associative. (a) Give TAG|SET|WORD. (b) For byte address **0x0ABCDEF0**, find the word offset, set number, and tag (in decimal).

<details><summary>Show answer</summary>

**(a) The split.** Recipe:
- `n = log2(512 MB) = log2(2^29) =` **29**; `w = log2(128) =` **7**; `s = 29 − 7 =` **22**.
- `m = 1 MB / 128 B = 1048576 / 128 = 8192 = 2^13` lines.
- Sets first: `v = m / k = 8192 / 2 = 4096 = 2^12` → **SET = 12**; **TAG = s − d = 22 − 12 = 10**.

```text
 ┌──────────┬──────────┬─────────┐
 │ TAG 10   │ SET 12   │ WORD 7  │  = 29  ✔
 └──────────┴──────────┴─────────┘
```

**(b) Decode the address.** `0x0ABCDEF0 = 179,996,400` (decimal). It's below `2^29 = 536,870,912`, so it fits in 29 bits — no masking needed.
- **WORD** = low 7 bits = `address mod 128`. The low byte `0xF0 = 240`, and `240 mod 128 = ` **112** (equivalently `addr & 0x7F = 0x70 = 112`).
- **Block number** = `addr / 128 = 179996400 / 128 = 1,406,221` (check: `1406221 × 128 = 179996288`, remainder 112 ✔).
- **SET** = `block mod 4096`. Since `1406221 = 343·4096 + 1293` (`343 × 4096 = 1,404,928`), the set is **1293**.
- **TAG** = `block / 4096 =` **343**.
</details>
