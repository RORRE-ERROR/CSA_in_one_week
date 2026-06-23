# Chapter 04 — Cache Memory · Quick Refresher

> 🌱 Read this in 5 minutes to refresh everything, or the day before the exam. Each idea is given in **plain words first**, then the exam wording / formula.

---

## The big ideas, in plain words

- **Why cache exists.** The CPU is fast, main memory is slow. A small, fast, expensive **cache** sits between them holding the data the CPU is most likely to need next, so most requests are served at near-cache speed.
- **Memory hierarchy (R-C-M-D-T).** Registers → Cache → Main memory → Disk → Tape. Going **down** = bigger, slower, cheaper per bit. You can't have fast + big + cheap at once, so you layer.
- **Locality** (why caching works): **Temporal = Time** (you reuse the *same* address soon) and **Spatial = Space** (you use *nearby* addresses soon). Spatial locality is *why* a miss fetches a whole **block**, not one word.
- **Blocks, lines, tags.** Memory is cut into fixed **blocks** (the unit that moves). The cache holds **lines** (slots). Each line stores a **tag** saying which block it currently holds (because there are far more blocks than lines).
- **A miss loads the whole block** into a line, then hands the word to the CPU.
- **Three mapping schemes** (where can a block live?): **D**irect = one fixed line · **A**ssociative = any line · **S**et = pick a set, then any line in it.
- **Replacement** (who gets evicted when full): **LRU** is best & most popular; also FIFO, LFU, Random. Direct mapping needs none (only one candidate line).
- **Write policy:** write-through (write cache + memory every time — simple but **heavy memory traffic**) vs write-back (write cache only, mark **dirty**, update memory only on eviction — fast but complex).
- **Performance:** effective access time. **This course uses the weighted average:** `EAT = H·Tc + (1−H)·Tm`.

---

## 🔢 The bit-field recipe (the core skill)

```text
n = log2(main memory size in bytes)      ADDRESS bits
w = log2(block / line size in bytes)     WORD/OFFSET bits
s = n − w                                block-id bits
m = cache size / block size              # cache lines
v = m / k                                # sets  (k = associativity / lines-per-set)

DIRECT:       r = log2(m)    TAG = s − r    →  TAG | LINE(r) | WORD(w)
ASSOCIATIVE:  (no line)      TAG = s         →  TAG(s)       | WORD(w)
SET-ASSOC:    d = log2(v)    TAG = s − d     →  TAG | SET(d)  | WORD(w)

ALWAYS verify:  all fields sum to n.
block# = addr / blocksize   line = block mod m   set = block mod v
```

Powers: `2^10 = 1K   2^20 = 1M   2^30 = 1G`. KB = 2^10 B, MB = 2^20 B, GB = 2^30 B.

*(Plain-words reminder: low bits = which byte inside the block; high bits = the tag. Set bits = log2(**sets**), and sets = lines / k — find sets FIRST.)*

## 🗺️ Mapping comparison

| Property | Direct | Fully Associative | Set-Associative (k-way) |
|---|---|---|---|
| Block can go to | 1 fixed line | any line | any line in 1 set |
| Address fields | TAG·LINE·WORD | TAG·WORD | TAG·SET·WORD |
| Index field bits | log2(#lines) | — | log2(#sets) |
| Comparators (hit logic) | 1 | m (all lines) | k (lines in set) |
| Hardware cost | lowest | highest | medium |
| Hit time | fastest | slowest | medium |
| Conflict misses | **many** (thrash) | **none** | few |
| Replacement algorithm | not needed | required | required |

> k = 1 ⇒ Direct.  v = 1 (one set) ⇒ Fully associative.

## ♻️ Replacement algorithms

| | Evicts | Tracks | Notes |
|---|---|---|---|
| **LRU** | least-recently-used | recency | **best & most popular** |
| **FIFO** | oldest resident | age | circular buffer |
| **LFU** | fewest references | frequency | per-line counter |
| **Random** | random | nothing | cheapest |

Direct mapping needs **none** (only one candidate line).

## ✍️ Write policy

| | Write-through | Write-back |
|---|---|---|
| Writes | cache **and** memory | cache only (dirty bit) |
| Memory traffic | high (**the downside**) | low |
| Complexity | simple | complex; I/O via cache |
| Memory validity | always valid | may be stale |

**Write miss:** Write-allocate (fetch block, then write) vs No-write-allocate (write memory only).
**Default pairs:** no-write-allocate + write-through · write-allocate + write-back.
**Coherency:** bus snooping (write-through), hardware transparency, non-cacheable memory.

## 🧠 Mnemonics

- **R-C-M-D-T** hierarchy: Registers, Cache, Main, Disk, Tape — down = bigger/slower/cheaper.
- **Temporal = Time** (same address again) · **Spatial = Space** (nearby → fetch a block).
- **D-A-S**: Direct = one home · Associative = Anywhere · Set = pick Set then anywhere.
- **SET bits = log2(#sets)**, and **#sets = #lines / k** — compute sets FIRST.
- Allocate pairs: "**back allocates, through doesn't**."

## ⏱️ Performance

```text
COURSE MODEL (weighted average):
   EAT = H·T_cache + (1 − H)·T_memory          (H = hit ratio)

(Additive variant, if a question clearly asks for it):
   T_avg = T_cache + (1 − H)·T_memory

2-level:  T_avg = T_L1 + (1−H1)·[ T_L2 + (1−H2)·T_mem ]
```

> ⚠️ Two EAT models exist and give different numbers. **Default to the weighted average `H·Tc + (1−H)·Tm`** (your midterm marked this correct), unless a question's wording points at the additive form. See `../00-FINAL-FOCUS.md` / `../00-MIDTERM-FOCUS.md`.

## ⭐ If you only revise 5 things

1. **The bit-field recipe:** `n, w=log2(block), s=n−w, m=cache/block`, then per-scheme TAG/index — and always **sum-check = n**.
2. **Field count differs:** Direct & Set-assoc have **3** fields; Fully associative has **2** (no index field).
3. **Set bits = log2(#lines / k)** — the #1 exam trap. Find #sets *before* taking the log.
4. **Mapping trade-offs:** Direct = cheap / conflict-prone · Associative = flexible / expensive · Set = compromise. (And LRU is the go-to replacement algorithm.)
5. **Effective access time (course model): `EAT = H·Tc + (1 − H)·Tm`** — weight cache time by the hit chance and memory time by the miss chance. (Write-through's weakness = heavy memory traffic; write-back fixes it with a dirty bit.)
