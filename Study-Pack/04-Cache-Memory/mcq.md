# Chapter 04 — Cache Memory · Quick Self-Test (Multiple Choice)

> 🌱 **How to use this.** Once you've read `notes.md` and worked through `exercises.md`, use these 15 questions to check what actually stuck. Decide your answer (A/B/C/D) **before** opening the explanation — the explanations tell you *why* in plain words, which is what you want to remember.
>
> Don't stress about your first score. Re-take it the day before the exam and aim for 14–15.

---

**Q1.** Going *down* the memory hierarchy (registers → tape), which is TRUE?
A. Cost per bit increases, capacity decreases
B. Capacity increases, access time increases
C. Speed increases, capacity decreases
D. Cost per bit increases, speed increases

**Q2.** Fetching an entire block on a cache miss primarily exploits:
A. Temporal locality
B. Spatial locality
C. Associative access
D. Write-back policy

**Q3.** The minimum unit of transfer between cache and main memory is the:
A. Word
B. Tag
C. Block
D. Line

**Q4.** In *direct* mapping, the address is divided into:
A. Tag and word only
B. Tag, set, and word
C. Tag, line, and word
D. Set and word only

**Q5.** In *fully associative* mapping, the tag is compared against:
A. One line selected by the line field
B. The k lines of the selected set
C. Every line in the cache
D. Only the most-recently-used line

**Q6.** Main memory = 16 MB, cache = 64 KB, block = 32 B, **direct-mapped**. How many **tag** bits?
A. 5
B. 8
C. 11
D. 19

**Q7.** Same system (16 MB / 64 KB / 32 B) but **4-way set-associative**. How many **set** bits?
A. 7
B. 9
C. 11
D. 5

**Q8.** A cache has 1024 lines and is **8-way** set-associative. Number of sets =
A. 8192
B. 1024
C. 256
D. 128

**Q9.** A direct-mapped, byte-addressable cache uses TAG=12, LINE=10, WORD=4. The block size is:
A. 4 bytes
B. 10 bytes
C. 16 bytes
D. 1024 bytes

**Q10.** Which mapping function does **not** require a replacement algorithm?
A. Fully associative
B. Set-associative
C. Direct
D. 2-way set-associative

**Q11.** The **most effective and most popular** replacement algorithm is:
A. FIFO
B. LFU
C. Random
D. LRU

**Q12.** Under **write-back**, main memory is updated:
A. On every write to the cache
B. Only when the modified (dirty) block is evicted
C. Never
D. Only on a read hit

**Q13.** Which pairing is the common default?
A. Write-through + write-allocate
B. Write-back + no-write-allocate
C. Write-through + no-write-allocate
D. Write-back + write-through

**Q14.** T_cache = 5 ns, T_memory = 100 ns, hit ratio = 0.96. Average access time (model: cache time + miss penalty) =
A. 5 ns
B. 9 ns
C. 100 ns
D. 4 ns

**Q15.** Current design trend for cache organization is:
A. Unified at all levels
B. Split at all levels
C. Split at L1, unified at higher levels
D. Unified at L1, split at higher levels

---

## Answers — with the *why*

<details><summary>Q1</summary><b>B.</b> As you go down the hierarchy, things get bigger and cheaper but slower — so capacity goes up and access time goes up (slower), while speed and cost/bit go down. Only B matches all of that. (A, C, D each get a direction backwards.)</details>

<details><summary>Q2</summary><b>B.</b> Spatial locality = "if you used an address, you'll probably use its neighbours soon," so grabbing the whole block (the neighbours) is the payoff. Temporal locality is about reusing the *same* address.</details>

<details><summary>Q3</summary><b>C.</b> The **block** is the smallest chunk that ever moves between memory and cache. A *line* is the cache slot that holds a block — it's the container, not the unit of transfer.</details>

<details><summary>Q4</summary><b>C.</b> Direct mapping = **Tag | Line | Word** (three fields), because each block has one fixed line. Tag/word only = fully associative; tag/set/word = set-associative.</details>

<details><summary>Q5</summary><b>C.</b> In fully associative there's no index telling you *where* the block is, so the hardware must compare the tag against **every** line at once.</details>

<details><summary>Q6</summary><b>B = 8.</b> Recipe: n=24, w=log2(32)=5, so s=19. Lines m=64KB/32=2048=2^11, so line bits r=11. TAG = s − r = 19 − 11 = **8**.</details>

<details><summary>Q7</summary><b>B = 9.</b> Same m=2048 lines, but now find *sets* first: v = m/k = 2048/4 = 512 = 2^9 → **9 set bits** (and the tag would be 19 − 9 = 10). The trap is using log2(lines)=11 instead.</details>

<details><summary>Q8</summary><b>D = 128.</b> Number of sets = number of lines / k = 1024 / 8 = **128**. (Always divide lines by the associativity.)</details>

<details><summary>Q9</summary><b>C = 16 bytes.</b> The WORD field is the byte-offset inside a block, so block size = 2^WORD = 2^4 = 16 bytes.</details>

<details><summary>Q10</summary><b>C. Direct.</b> Each block has exactly one legal line, so there's never a choice of victim — nothing to "decide," hence no replacement algorithm needed.</details>

<details><summary>Q11</summary><b>D. LRU.</b> Least Recently Used is the most effective in practice and, because it's simple to implement (a single use bit for 2-way), the most popular.</details>

<details><summary>Q12</summary><b>B.</b> Write-back changes only the cache copy (and sets a dirty bit); main memory is updated **only when that dirty block is evicted** — that's how it cuts memory traffic.</details>

<details><summary>Q13</summary><b>C.</b> The natural pairs are no-write-allocate with write-through, and write-allocate with write-back. So the valid default here is **write-through + no-write-allocate**.</details>

<details><summary>Q14</summary><b>B = 9 ns.</b> Using the stated model (cache time + miss penalty): T_avg = 5 + (1−0.96)·100 = 5 + 0.04·100 = 5 + 4 = **9 ns**. (Note: this question is worded for the additive model; the weighted-average model would instead give 0.96·5 + 0.04·100 = 8.8 ns — always read which model the question asks for.)</details>

<details><summary>Q15</summary><b>C.</b> The trend is **split caches at L1** (separate instruction and data caches remove the clash between fetching instructions and reading data — great for pipelining), then **unified caches at higher levels** (L2/L3).</details>

---

> 📊 **Scored low?** Totally normal on a first pass — go back to the matching `notes.md` section, then retry. **Scored 13+?** You've got Chapter 4 under control. The bit-field questions (Q6–Q9) are the ones most likely to reappear, so make sure those feel automatic.
