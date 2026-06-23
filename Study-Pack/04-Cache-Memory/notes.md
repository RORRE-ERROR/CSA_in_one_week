# Chapter 04 — Cache Memory

> 🌱 **Starting from zero?** Perfect — this chapter assumes you've never thought about *why* a computer has different kinds of memory or how it decides where to keep things. We'll build it up slowly with everyday comparisons (a desk, a filing cabinet, a librarian) before any technical words. Read top to bottom, don't skip.
>
> ⏱️ Give it ~2 hours. This is a **final-exam carry-over topic**, so it's worth getting right.

---

## 🤔 First, why does this chapter exist?

Here's the problem the whole chapter is trying to solve.

The CPU (the brain) is *blisteringly* fast. But the main memory (RAM) where data lives is comparatively *slow*. If the brain had to wait for slow memory every single time it needed a number, it would spend most of its life just... waiting. That's wasteful.

Could we just make all memory super-fast? Yes — but fast memory is **expensive** and you can only fit a little of it. Slow memory is **cheap** and you can have loads. You can't have all three of fast, big, and cheap at once.

So engineers played a clever trick: put a **small, fast, expensive** memory (called a **cache**) right next to the brain, and keep in it the handful of things the brain is *most likely to need next*. Most of the time the brain finds what it wants in the fast cache and never has to wait for slow memory. You get *almost* the speed of fast memory at *almost* the price of cheap memory.

This chapter is about **how that trick works** — and the one skill examiners love to test: given some memory sizes, **chop a memory address into pieces** to figure out where in the cache something goes.

By the end you'll be able to, in your own words:
- explain the **memory hierarchy** and why we can't have fast + big + cheap all at once,
- explain **locality** (why keeping "recently and nearby used" data works),
- describe how cache and memory are organised (blocks, lines, tags),
- **split an address into TAG / LINE(or SET) / WORD fields** for the three mapping schemes — even in hexadecimal,
- compare **replacement algorithms** and **write policies**,
- compute **effective (average) access time**.

---

## 🗺️ The big picture in one breath

A small, fast **cache** sits between the fast CPU and the slow main memory. Because programs tend to reuse the same data and nearby data (that's "locality"), a tiny cache catches the *vast majority* of requests. So on average the brain gets its data at nearly cache speed, even though most of the actual storage is cheap slow memory.

```text
                 FAST · SMALL · EXPENSIVE
                        ▲
   CPU ──► Registers ──► Cache ──► Main Memory ──► Disk ──► Tape
                        ▼
                 SLOW · BIG · CHEAP
```

> 🎯 **The single hardest exam skill** is in §5: given memory size, cache size, and block size, work out the **bit-widths of the tag / line(set) / word address fields** for each mapping scheme. Master the recipe there and you own this chapter.

---

## 1. The Memory Hierarchy — why we layer memory

**Everyday analogy.** Think about where you keep your stuff while working at a desk:
- The few papers **in your hands** = instant to use, but you can only hold a couple. (registers)
- The papers **on your desk** = a quick reach away. (cache)
- The **filing cabinet** in the room = slower to walk to, but holds loads. (main memory / RAM)
- The **storage unit across town** = huge and cheap, but a real trek. (disk, then tape)

You don't pick *one* of these. You use **all of them, layered** — keep what you need right now close, and the rest further away. That layering is the **memory hierarchy**.

**Plain English.** Every memory technology forces a trade-off between three things:

- Faster access → **costs more** per bit.
- Bigger capacity → **costs less** per bit.
- Bigger capacity → **slower** access.

You can't win all three, so we stack several technologies, fastest/smallest/dearest at the top, slowest/biggest/cheapest at the bottom.

```text
                          ▲ cost/bit ↑   speed ↑
        ┌───────────────┐ │
        │   Registers   │  tiny, in the CPU,   managed by the COMPILER
        ├───────────────┤
        │     Cache     │  small & fast,        managed by PROCESSOR HARDWARE
        ├───────────────┤
        │  Main Memory  │  the working RAM,     managed by the OS
        ├───────────────┤
        │ Secondary mem │  disk,                managed by OS / user
        ├───────────────┤
        │  Offline bulk │  tape,                managed by OS / user
        └───────────────┘
                          ▼ capacity ↑   access time ↑ (slower)
```

| Level | Technology | Managed by |
|---|---|---|
| Registers | CMOS | Compiler |
| Cache | SRAM / eDRAM | Processor hardware |
| Main memory | DRAM | Operating system |
| Secondary | Magnetic disk | OS / user |
| Offline bulk | Magnetic tape | OS / user |

> 🧠 **Memory hook:** "**R-C-M-D-T**" = Registers, Cache, Main, Disk, Tape. Going **down** = bigger, slower, cheaper per bit. Going **up** = smaller, faster, dearer.

> ✍️ **Check yourself:** Why does adding a fast cache *not* require it to be huge?
> <details><summary>Reveal answer</summary>Because of <b>locality</b> (next section): a small cache still catches most of the requests. We want it small enough that the average cost per bit is close to cheap main memory, yet big enough that the average <i>access time</i> is close to fast cache.</details>

> 📌 **Some jargon you'll meet (Stallings Table 4.1).** A memory can be described by its **location** (inside the chip vs external like disk/tape), **capacity** (how many bytes), **unit of transfer** (a single word, or a whole **block**), **access method** (sequential like tape, or **random** like RAM where any address is equally fast, or **associative** like cache where you search by content), and **performance** (access time, etc.). Don't memorise the table — just know these words exist.

---

## 2. The Principle of Locality — why the trick works

The cache only helps if the brain keeps asking for things the cache happens to be holding. Luckily, real programs are *predictable* in two ways. This predictability is called **locality**.

**Everyday analogy.** Imagine you're studying at a library desk:
- You keep re-opening the **same textbook** every few minutes. → If you've used something recently, you'll probably use it again soon. (**temporal** locality — "temporal" means *time*.)
- When you grab one book, you usually want the **books next to it on the shelf** too. So a smart librarian brings you the **whole shelf section**, not a single book. → If you used one address, you'll probably use nearby ones soon. (**spatial** locality — "spatial" means *space/place*.)

**Plain English / formal idea:** *during execution, the memory addresses a program touches tend to cluster* — not spread evenly, and the recent past predicts the near future.

```text
TEMPORAL locality            SPATIAL locality
(about TIME)                 (about SPACE / nearby addresses)
"used it recently            "used an address →
 → will use it again soon"    nearby addresses used soon"
   loop counters,               arrays/tables,
   constants, the stack         instructions run in sequence
```

| Form | Plain meaning | How the cache exploits it |
|---|---|---|
| **Temporal** (time) | Re-use the *same* location soon | Keep it in the cache; don't throw it out |
| **Spatial** (space) | Use a *nearby* location soon | On a miss, fetch a whole **block** of neighbouring data, not just 1 word |

> 🧠 **Memory hook:** **Temporal = Time** (same address, again). **Spatial = Space** (nearby address). Spatial locality is *the reason* we move data in whole blocks instead of one word at a time.

---

## 3. How cache and memory are organised — blocks, lines, tags

Before we can split addresses, we need the vocabulary, and it's easy once you see the analogy.

**Everyday analogy — a hotel.** Main memory is a huge town full of **guests** (data). The cache is a small **hotel** with a fixed number of **rooms**. Because there are far more guests in town than rooms in the hotel, each occupied room wears a **name badge** saying *which* guest is currently staying in it.

- A **block** = a fixed-size chunk of main memory. It's the **smallest amount that ever moves** between memory and cache. *(The "guest" — and guests always travel as a group of K words, never alone.)*
- A **line** = one slot in the cache that can hold exactly one block. *(A "room" — drawn as a horizontal row, hence "line".)*
- A **frame** (or block frame) = the physical room itself, the container, as opposed to the block (the contents) inside it.
- A **tag** = a small label stored with each line saying *which* block is currently in it. *(The "name badge".)*
- **Line size = block size** = how many data bytes a line/block holds.

```text
   MAIN MEMORY (M blocks)          CACHE (m lines,  with m far less than M)
   ┌──────────────┐ block 0        ┌─────┬──────────────┐ line 0
   │  block 0     │                │ tag │  block       │
   ├──────────────┤ block 1        ├─────┼──────────────┤ line 1
   │  block 1     │                │ tag │  block       │
   ├──────────────┤   ...          ├─────┼──────────────┤  ...
   │   ...        │                │ tag │  block       │ line m-1
   ├──────────────┤ block M-1      └─────┴──────────────┘
   │  block M-1   │                Each block = K words.
   └──────────────┘                Each line  = K words + a tag.
```

Because there are **many more blocks than lines** (M much bigger than m), a line can't be permanently assigned to one block. Whoever is "checked in" right now is identified by the **tag**.

> 🧠 **Memory hook:** Line = the *furniture* (a fixed slot). Block = the *guest* (the data that checks in). Tag = the guest's *name badge*.

---

## 4. What happens on a cache read

```text
        CPU wants the data at address RA
                │
                ▼
        ┌───────────────────┐
        │ Is that block      │   YES (a HIT)
        │ already in cache?  ├──────────► Deliver the word from the cache line ─► done
        └─────────┬──────────┘
                  │ NO (a MISS)
                  ▼
        Go to slow main memory, read the WHOLE block containing RA
                  │
                  ▼
        Put that block (plus its tag) into a cache line
                  │
                  ▼
        Deliver the requested word to the CPU
```

A **hit** = the brain found what it wanted in the cache (fast). A **miss** = it wasn't there, so we had to fetch it from slow memory (slow).

> ⚠️ **Exam trap:** On a miss, the **whole block** is loaded into the cache — not just the single word the CPU asked for. Loading the neighbours too is exactly how we cash in on **spatial** locality.

---

## 5. Mapping Functions — the heart of the chapter

**The question mapping answers:** when a block comes in from memory, **which cache line(s) is it allowed to live in?** There are three answers, and each one chops the memory address into fields differently.

### 5.0 The address-splitting recipe (READ THIS SLOWLY)

Every memory address is just a binary number. We're going to **carve it into named slices**, where each slice tells us something. Here's the recipe — follow it like a cooking method, in order, every single time.

```text
STEP 1.  n = log2(main-memory size in bytes)      → total ADDRESS bits
STEP 2.  w = log2(block size in bytes)            → WORD/OFFSET bits
STEP 3.  s = n − w                                → "block-id" bits (identifies a block)
STEP 4.  m = cache size / block size              → number of cache LINES
```

What each slice *means*, in plain words:
- **WORD field (w bits)** — *which byte inside the block* do I want? A block has `2^w` bytes, so it takes `w` bits to point at one of them.
- **block-id (s bits)** — *which block* of memory is this? (We never split this off as its own field; it gets divided up by the scheme below.)
- The **rest** of the bits get arranged into a TAG and (maybe) an index, depending on the scheme.

**Tiny worked example to feel it.** Memory = 1 KB (so `n = log2(1024) = 10` bits), block = 4 bytes (so `w = log2(4) = 2` bits). Then `s = 10 − 2 = 8` bits identify the block. The lowest 2 bits of any address pick the byte *within* the block; the top 8 bits say *which* block. That's the whole idea — the low bits are "where inside the block," the high bits are "which block."

> 🧠 **Always finish with the SUM CHECK:** the field widths must add back up to `n`. If they don't, you slipped somewhere. This one habit catches almost every arithmetic mistake.

Now the three schemes, which differ only in *how they use the s block-id bits*.

### 5.1 Direct Mapping — every block has one fixed home

Each memory block is allowed in **exactly one** cache line, decided by simple arithmetic: `line = (block number) mod (number of lines)`. Like a hotel where your room number is fixed by your house number back home — no choice.

```text
ADDRESS  ( n bits ):
 ┌────────────────────────┬───────────────┬─────────────┐
 │           TAG          │     LINE       │    WORD     │
 │      (s − r) bits      │   (r bits)     │  (w bits)   │
 └────────────────────────┴───────────────┴─────────────┘
   r = log2(number of lines)   ← which line is this block's fixed home
   w = log2(block size)        ← which byte inside the block
   TAG = s − r                 ← what's left over, to confirm identity
```

In plain words: the middle **LINE** slice tells the hardware exactly which line to look in (no searching). The **TAG** stored in that line is then compared with the TAG from the address — if they match, it's a **hit**.

- **Pro:** simplest, cheapest hardware — just **one** comparator.
- **Con:** **conflict misses / thrashing** — two heavily-used blocks that happen to map to the *same* line keep kicking each other out, even if the rest of the cache is empty.

> ⚠️ **Exam trap:** Direct mapping has **THREE** fields (tag / line / word). The number of **line** bits = `log2(number of lines)` — there are no "sets" here, so don't go looking for them.

### 5.2 Fully Associative Mapping — a block can go anywhere

A block may be placed in **any** free line. Like a hotel where you take any open room. There's no fixed "line" slice — just a tag and a word.

```text
ADDRESS  ( n bits ):
 ┌──────────────────────────────────────┬─────────────┐
 │                 TAG                   │    WORD     │
 │              (s bits)                 │  (w bits)   │
 └──────────────────────────────────────┴─────────────┘
   TAG = s = n − w     (the tag alone identifies the block)
```

In plain words: since a block could be in *any* line, the hardware must compare the address's **TAG against every line's tag at once** (this parallel "search by content" is called associative or CAM lookup).

- **Pro:** most flexible — **no conflict misses** (use any empty line).
- **Con:** most expensive — needs a comparator for **every** line. Also needs a **replacement algorithm** to decide who to evict when full (since any line could be the victim).

*Stallings' example (a 24-bit address with a 22-bit tag and 2-bit word):* address `FFFFFC` → tag `3FFFFF`, and the low 2 bits select the word inside the block.

> ⚠️ **Exam trap:** Fully associative has **only TWO** fields — there is **no line/set field at all**. Splitting off "line bits" here is the classic mistake.

### 5.3 Set-Associative Mapping — the sensible compromise

Split the cache into **v sets**, each set holding **k lines** (we call this "**k-way**"). So total lines `m = v × k`. A block is sent to **one particular set** (`set = block mod v`), but inside that set it can sit in **any** of the k lines. Like a hotel where your *floor* is fixed by your home address, but you can take any room *on that floor*.

```text
ADDRESS  ( n bits ):
 ┌────────────────────────┬───────────────┬─────────────┐
 │           TAG          │      SET       │    WORD     │
 │      (s − d) bits      │   (d bits)     │  (w bits)   │
 └────────────────────────┴───────────────┴─────────────┘
   d = log2(number of SETS, v)     ← NOT the number of lines!
   w = log2(block size)
   TAG = s − d
```

In plain words: the **SET** slice picks the set (the floor); then the **TAG** is compared against the **k** lines in that set only — far fewer comparisons than fully associative.

- `k = 1` → only one line per set → this is just **direct** mapping.
- `v = 1` → one giant set → this is just **fully associative**.
- Typical real caches are 2-way or 4-way. Going 1-way → 2-way gives a big hit-rate jump; after that, diminishing returns.

> 🧠 **Memory hook (D-A-S):** **D**irect = one fixed home · **A**ssociative = go **A**nywhere · **S**et = pick a **S**et, then anywhere inside it.

> ⚠️ **Exam trap (THE big one):** Set-associative uses **SET bits = log2(number of SETS)**, where `number of sets = number of lines / k`. Students wrongly use `log2(number of lines)`. **Always compute number of sets FIRST, then take its log.**

> ✍️ **Check yourself:** A cache has 256 lines, 4-way set-associative. How many *set* bits?
> <details><summary>Reveal answer</summary>Number of sets = 256 / 4 = 64 = 2^6 → <b>6 set bits</b>. (If you'd wrongly used log2(256) you'd get 8 — that's the trap.)</details>

### 5.4 A full hexadecimal example (this is what the exam looks like)

**Given:** memory = **16 MB** byte-addressable, cache = **64 KB**, block = **32 bytes**.

Run the recipe:
- `n = log2(16 MB) = log2(2^24) =` **24 bits** (so addresses are 6 hex digits).
- `w = log2(32) = log2(2^5) =` **5 bits**.
- `m = 64 KB / 32 B = 65536 / 32 = 2048 = 2^11` lines.
- `s = n − w = 24 − 5 =` **19 bits**.

Take the hex address `0x00ABCDEF` — but we only have 24-bit addresses, so use the low 24 bits: `0xABCDEF`. In binary that's:

```text
   0xAB CD EF  =  1010 1011  1100 1101  1110 1111   (24 bits)
```

**Direct mapping (line bits r = log2(2048) = 11, tag = 19 − 11 = 8):**
Slice from the right: lowest **5** bits = WORD, next **11** bits = LINE, top **8** bits = TAG.

```text
   TAG (8)    LINE (11)            WORD (5)
  ┌────────┬──────────────────┬──────────┐
  │1010101 1│100 1101 1110 1   │ 0 1111   │   sums to 24 ✔
  └────────┴──────────────────┴──────────┘
```

The point isn't to grind the binary by hand under pressure — it's to know **which slice is which** and that the **low bits are the offset, the high bits are the tag**. Practise the slicing in the exercises.

---

## 6. Replacement Algorithms — who gets evicted?

When the cache (or a set) is full and a new block arrives, something must be thrown out. This choice only exists for **associative** and **set-associative** caches — **direct mapping has no choice** (each block has exactly one legal line). For speed, the choice is made by **hardware**.

| Algorithm | Plain rule | Note |
|---|---|---|
| **LRU** (Least Recently Used) | Throw out whatever's gone **unused the longest** | **Most effective & most popular**; for 2-way it's just a single USE bit |
| **FIFO** (First-In-First-Out) | Throw out whatever's **been here longest** (regardless of use) | Like a queue / circular buffer |
| **LFU** (Least Frequently Used) | Throw out whatever's been **used the fewest times** | Needs a counter per line |
| **Random** | Throw out a **random** one | Cheapest; only slightly worse in practice |

> 🧠 **Memory hook:** LRU watches *recency*, LFU watches *frequency*, FIFO watches *age*, Random watches *nothing*.

> ✍️ **Check yourself:** Why does direct mapping need no replacement algorithm?
> <details><summary>Reveal answer</summary>Each block has exactly one legal line, so there's never a <i>choice</i> of victim — the incoming block simply overwrites that one line.</details>

---

## 7. Write Policy — keeping memory in sync

When the CPU **changes** a value sitting in the cache, when should the slow main-memory copy be updated too? Two policies.

```text
WRITE-THROUGH                       WRITE-BACK
 write → cache AND memory            write → cache only (and set a DIRTY bit)
 (every time)                        memory updated only LATER, on eviction
 ─────────────────────────          ──────────────────────────────────────
 + simple; memory always correct     + far fewer memory writes → faster
 - LOTS of memory traffic            - memory may be stale; I/O must go via
   (a real bottleneck)                 cache; more complex; coherence harder
```

> ⚠️ **Watch this downside:** **write-through** updates main memory on *every* write, which creates **heavy memory traffic** and can bottleneck the system. **Write-back** avoids this by only writing the modified ("dirty") block back when it's evicted — at the cost of memory being temporarily out of date.

**What about a write that MISSES** (the block isn't even in cache yet)?
- **Write allocate** — first fetch the block into cache, then write to it. (Normally paired with **write-back**.)
- **No write allocate** — write straight to memory, don't bother loading the block. (Normally paired with **write-through**.)

**Cache coherency** (when several caches share one memory): a write in one cache can leave stale copies in others. Fixes include **bus watching / snooping** (with write-through), **hardware transparency**, and marking shared regions **non-cacheable**.

> ⚠️ **Exam trap:** Remember the natural pairings — **no-write-allocate + write-through**, and **write-allocate + write-back**. The crossed-over pairings are uncommon and usually the wrong MCQ choice.

---

## 8. Line (Block) Size — bigger isn't always better

```text
 hit ratio
    ▲          ___ peak
    │        /     \___
    │      /            \____  too big: fewer blocks fit, and the far-away
    │    /                     words you dragged in often go unused
    └──────────────────────►
        block size
```

A **bigger block** pulls in more neighbours, which helps **spatial** locality (good). But make it too big and (1) **fewer blocks fit** in the cache, so useful data gets evicted sooner, and (2) the far end of a huge block is less likely to actually get used. So there's an **optimum** size — "bigger is always better" is wrong.

---

## 9. Number of Caches — L1/L2/L3, split vs unified

**Multilevel (L1 / L2 / L3):** the on-chip **L1** is the smallest and fastest; **L2** and **L3** are bigger and slower but still far faster than DRAM. Hits inside the chip also avoid using the external bus, freeing it for other work. How much you save depends on the **hit rate at each level**.

**Unified vs Split** (does one cache hold both instructions and data, or do we have separate ones?):

| | Unified (one cache for instructions + data) | Split (separate I-cache + D-cache) |
|---|---|---|
| Hit rate | Often higher; auto-balances how much is instructions vs data | — |
| Design | Simpler — just one cache | Two caches to build |
| Contention | — | **Removes** the clash between fetching instructions and reading/writing data → great for **pipelining** |

**Trend:** **split at L1**, **unified at the higher levels** (L2/L3).

**Inclusion policy (which levels keep copies):**
- **Inclusive** — anything in an upper level is *also* guaranteed to be in the lower levels (simpler coherence/search; wastes some capacity).
- **Exclusive** — guaranteed *not* duplicated lower down (saves capacity; more work on invalidation).
- **Non-inclusive** — no guarantee either way.

---

## 10. Cache Performance — effective (average) access time

- **Hit ratio `H`** = (number of hits) / (total accesses). **Miss ratio** = `1 − H`.

> ⚠️ **Two models exist — know which one your course uses.** There are two common formulas for effective/average access time, and they give *different* numbers:
>
> - **Weighted-average (THE ONE THIS COURSE USES):**
>   `EAT = H · T_cache + (1 − H) · T_memory`
>   — a hit costs *only* cache time; a miss costs *only* memory time.
> - **Additive:** `EAT = T_cache + (1 − H) · T_memory` — you always pay cache time, then the memory penalty on a miss.
>
> Your midterm marked the **weighted-average** form as correct. **Default to `H·Tc + (1−H)·Tm`** unless a question's wording clearly implies the additive model. See `../00-MIDTERM-FOCUS.md` and `../00-FINAL-FOCUS.md`.

> 🧠 **Memory hook (weighted average):** *each access is either a hit or a miss* — weight cache time by the hit chance, memory time by the miss chance, and add.

---

## 🔬 Worked Example (all schemes, one system)

**Given:** Main memory = **16 MB** (byte-addressable). Cache = **64 KB**. Block (line) size = **32 bytes**.

**Step 0 — fixed quantities (same for every scheme):**
- Address width `n = log2(16 MB) = log2(2^24) =` **24 bits**.
- Word/offset bits `w = log2(block size) = log2(32) = log2(2^5) =` **5 bits**.
- Number of cache lines `m = cache size / block size = 64 KB / 32 B = 65536 / 32 = 2048 = 2^11`.
- Total block-id bits `s = n − w = 24 − 5 =` **19 bits**.

### (a) Direct Mapping
- Line bits `r = log2(m) = log2(2048) = log2(2^11) =` **11 bits**.
- **TAG = s − r = 19 − 11 = 8 bits.**

```text
 ┌──────────┬───────────────┬──────────┐
 │ TAG 8    │   LINE 11     │ WORD 5   │   = 24 bits  ✔
 └──────────┴───────────────┴──────────┘
```

### (b) Fully Associative
- No line field. **TAG = s = 19 bits**, WORD = 5 bits.

```text
 ┌────────────────────────────┬──────────┐
 │          TAG 19            │ WORD 5   │   = 24 bits  ✔
 └────────────────────────────┴──────────┘
```

### (c) Set-Associative (4-way, k = 4)
- Number of sets `v = m / k = 2048 / 4 = 512 = 2^9`.
- Set bits `d = log2(v) = log2(512) =` **9 bits**.
- **TAG = s − d = 19 − 9 = 10 bits.**

```text
 ┌───────────┬───────────┬──────────┐
 │  TAG 10   │  SET 9    │ WORD 5   │   = 24 bits  ✔
 └───────────┴───────────┴──────────┘
```

### Worked mapping table (which line/set holds which block?)

Using direct mapping (m = 2048 lines): `line = block mod 2048`, and `block = byte_addr / 32`.

| Byte address | Block # = addr/32 | Direct line = block mod 2048 | Tag = block / 2048 |
|---|---|---|---|
| 0x000000 | 0 | 0 | 0 |
| 0x000020 | 1 | 1 | 0 |
| 0x010000 (65536) | 2048 | 0 | 1 |
| 0x010020 (65568) | 2049 | 1 | 1 |
| 0xFFFFFF | 524287 | 2047 | 255 (0xFF) |

> Notice rows 1 and 3: blocks 0 and 2048 **collide** on line 0 — a direct-mapping conflict, told apart only by their tags (0 vs 1).

### (d) Effective access time
Cache access = **5 ns**, main-memory access = **70 ns**, hit ratio `H = 0.95`.

Using the course's **weighted-average** model:

```text
 EAT = H·T_cache + (1 − H)·T_memory
     = 0.95·5 + 0.05·70
     = 4.75 + 3.5
     = 8.25 ns
```

(For comparison, the older additive model would give `5 + 0.05·70 = 8.5 ns`. Either way, versus 70 ns for DRAM alone that's roughly an **8× speed-up** from a 95% hit rate.) Push `H` to 0.99 and it drops further still.

---

## ✅ You now understand…

In plain terms, you can now say:

1. **Why we layer memory:** you can't have fast + big + cheap at once, so we stack registers → cache → main memory → disk → tape (**R-C-M-D-T**), close-and-fast at the top.
2. **Why caching works:** programs have **locality** — they reuse the *same* data (temporal/time) and *nearby* data (spatial/space). Spatial locality is why we move whole **blocks**.
3. **How cache is organised:** main memory is cut into **blocks**; the cache holds **lines**; each line carries a **tag** to say which block it currently holds.
4. **A miss loads the whole block**, then hands the word to the CPU.
5. **The three mapping schemes** and how each splits an address:
   - Direct: `TAG | LINE(r=log2 m) | WORD(w)` — one fixed line; cheap; conflict-prone.
   - Fully associative: `TAG(s) | WORD(w)` — any line; flexible; expensive; needs replacement.
   - Set-associative: `TAG | SET(d=log2 v) | WORD(w)`, with `v = lines / k` — the compromise.
6. **Replacement:** LRU (best & most popular), FIFO, LFU, Random; direct needs none.
7. **Write policy:** write-through (simple but heavy memory traffic) vs write-back (fast, complex, uses a dirty bit); allocate pairings (no-alloc + through, alloc + back).
8. **Performance:** effective access time, using the course's weighted-average `H·Tc + (1−H)·Tm`.

If any feels shaky, re-read that section before doing `exercises.md`, then `mcq.md`.

---

## 🎓 When you're revising for the exam

The understanding above is the goal; for the exam itself, examiners reward exact wording and a flawless bit-field split. Keep these ready.

**THE bit-field recipe (execute it the same way every time):**

```text
1. n = log2(main memory size in bytes)            → ADDRESS bits
2. w = log2(block/line size in bytes)             → WORD bits
3. s = n − w                                      → block-id bits
4. m = cache size / block size                    → number of cache lines

   DIRECT:        r = log2(m)         TAG = s − r ;  fields = TAG | LINE(r) | WORD(w)
   ASSOCIATIVE:   (no line field)     TAG = s     ;  fields = TAG | WORD(w)
   SET-ASSOC:     v = m / k           d = log2(v)
                  TAG = s − d         fields = TAG | SET(d) | WORD(w)

5. CHECK: all fields must sum back to n.
```

Conversions to keep at your fingertips:

```text
2^10 = 1K   2^20 = 1M   2^30 = 1G
KB = 2^10 B    MB = 2^20 B    GB = 2^30 B
```

- **Block number** = byte address `/ block size` (i.e. shift right by `w`).
- **Direct line** = block number `mod m`. **Set** = block number `mod v`.
- Always finish with the **sum check** (fields = n) — it catches almost every slip.

**Crisp one-liners examiners like:**
- *Temporal* locality = same address reused soon; *spatial* = nearby addresses used soon (so we fetch a block).
- Set bits = `log2(number of sets)`, and number of sets = `lines / k` — **compute sets first**.
- Write-through's weakness = **heavy memory traffic**; write-back fixes it via a **dirty bit**, updating memory only on eviction.
- LRU = most effective and most popular replacement algorithm.
- **Effective access time (course model): `EAT = H·Tc + (1−H)·Tm`.**

> 🧠 **Mega-mnemonic:** **"R-C-M-D-T · T/S · D-A-S · TLW/TW/TSW"** = the hierarchy · Temporal/Spatial locality · Direct/Associative/Set · the three field-splits.

**Likely exam question:** *"Memory = 16 MB, cache = 64 KB, block = 32 B. Give the TAG/LINE/WORD split for direct mapping and the TAG/SET/WORD split for 4-way set-associative."*
<details><summary>Model answer</summary>

`n = 24`, `w = log2(32) = 5`, `s = 24 − 5 = 19`, `m = 64 KB/32 B = 2048 = 2^11`.
**Direct:** `r = log2(2048) = 11`, `TAG = 19 − 11 = 8` → **TAG 8 | LINE 11 | WORD 5** (sums to 24 ✔).
**4-way set-associative:** `v = 2048/4 = 512 = 2^9`, so `SET = 9`, `TAG = 19 − 9 = 10` → **TAG 10 | SET 9 | WORD 5** (sums to 24 ✔).
</details>

---

## 📚 Want to see/hear it explained another way?

- **Stallings, COA 11e — Ch. 4 "Cache Memory"** (Pearson): https://www.pearson.com/en-us/subject-catalog/p/computer-organization-and-architecture/P200000003503
- **Neso Academy — Cache Memory / Mapping** (COA playlist): https://www.youtube.com/playlist?list=PLBlnK6fEyqRgL8YpaSDfFqM6QY2bd1G_M
- **Gate Smashers — Cache Memory & Mapping**: https://www.youtube.com/playlist?list=PLxCzCOWd7aiHMonh3G6QNKq53C6oNXGrX
- **GeeksforGeeks — Cache Memory Mapping techniques**: https://www.geeksforgeeks.org/cache-memory-in-computer-organization/
- **TutorialsPoint — Cache Memory**: https://www.tutorialspoint.com/computer_organization_and_architecture/cache_memory.htm
