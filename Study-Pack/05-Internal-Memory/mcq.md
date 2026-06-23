# Chapter 05 — Internal Memory · Quick Self-Test (15 MCQ)

> 🌱 **How to use this.** Once you've read `notes.md` and tried `exercises.md`, use these 15 questions to check what stuck. Decide your answer (A/B/C/D) **before** opening the explanation — the explanations tell you *why* the right answer is right, in plain words.
>
> Don't sweat your score the first time. Re-take it the day before the exam and aim for 14–15.

---

1. A memory cell can be in two stable states. Which three operations does it support?
   A. Add, select, clear
   B. Select, read, write
   C. Refresh, read, write
   D. Decode, latch, output

2. Which statement about DRAM is TRUE?
   A. It stores bits in flip-flops and needs no refresh
   B. It stores bits as capacitor charge and must be refreshed
   C. It is faster than SRAM
   D. It is nonvolatile

3. SRAM is typically used for:
   A. Main memory
   B. Hard disk cache buffers only
   C. Cache memory
   D. BIOS storage

4. Compared with SRAM, DRAM is:
   A. Less dense and more expensive
   B. Denser and cheaper per bit
   C. Faster and nonvolatile
   D. Larger transistor count per cell

5. An EPROM is erased by:
   A. Electrically, one byte at a time
   B. Electrically, in blocks
   C. Exposure to UV light, whole chip
   D. It cannot be erased

6. Which ROM-family member offers electrical erase at **byte** granularity?
   A. PROM
   B. EPROM
   C. EEPROM
   D. Mask ROM

7. A 16 Mb DRAM organised as 4M × 4 has how many total address bits?
   A. 20
   B. 21
   C. 22
   D. 24

8. Multiplexed row/column addressing (RAS/CAS) primarily serves to:
   A. Double the storage capacity
   B. Reduce the number of address pins on the chip
   C. Eliminate refresh
   D. Increase the word width

9. For SEC on a 16-bit data word, the minimum number of check bits is:
   A. 4
   B. 5
   C. 6
   D. 8

10. In a Hamming SEC code, check bits are placed at:
    A. The end of the word
    B. Positions that are powers of two (1,2,4,8,…)
    C. Every even position
    D. Positions chosen randomly

11. After a read, the computed syndrome of an SEC code is `0000`. This means:
    A. A double error occurred
    B. The check bits are corrupted
    C. No error detected
    D. Bit 0 is in error

12. A received Hamming codeword gives syndrome `0110`. The error is at position:
    A. 3
    B. 6
    C. 9
    D. No error

13. DDR SDRAM increases data rate by all of the following EXCEPT:
    A. Transferring on both rising and falling clock edges
    B. Using a higher bus clock rate
    C. Eliminating the need for refresh
    D. Using a prefetch buffer

14. From DDR1 to DDR4, the supply voltage trend is:
    A. 1.2 → 1.5 → 1.8 → 2.5 (rising)
    B. 2.5 → 1.8 → 1.5 → 1.2 (falling)
    C. Constant at 1.8 V
    D. 3.3 → 2.5 → 1.8 → 1.5

15. NAND Flash (versus NOR Flash) is best characterised as:
    A. Random/byte read, used for execute-in-place code
    B. Higher density and lower cost, used for SSD/USB bulk storage
    C. Volatile and requiring refresh
    D. Erased only by UV light

---

## Answers — with the *why*

<details><summary>Q1</summary><b>B</b> — A cell needs three things: pick it (select), tell it (read or write), and feed/show the bit (data) — so select, read, write. Refresh isn't a single-cell operation; it's something the whole DRAM array does.</details>
<details><summary>Q2</summary><b>B</b> — DRAM holds each bit as charge on a capacitor (a leaky bucket), so it must be refreshed. That also means it's volatile and slower than SRAM, so A, C and D are all wrong.</details>
<details><summary>Q3</summary><b>C</b> — SRAM is fast and needs no refresh, which is exactly what cache wants. The big, cheap main memory is DRAM instead.</details>
<details><summary>Q4</summary><b>B</b> — DRAM's ~1-transistor cell is tiny, so you fit more bits per area (denser) and pay less per bit (cheaper). The trade-off is that it's slower and needs refresh.</details>
<details><summary>Q5</summary><b>C</b> — EPROM is wiped by shining UV light through a quartz window, which erases the entire chip at once.</details>
<details><summary>Q6</summary><b>C</b> — EEPROM erases and rewrites electrically, one byte at a time. EPROM is whole-chip UV; Flash is per-block.</details>
<details><summary>Q7</summary><b>C</b> — "4M × 4" means 4M locations, and 4M = 2²², so you need 22 address bits. (Each location hands over 4 bits: 4M × 4 = 16 Mb.)</details>
<details><summary>Q8</summary><b>B</b> — Sending the row half then the column half over the same wires lets the chip reuse its address pins, halving how many it needs. It doesn't change capacity, refresh, or width.</details>
<details><summary>Q9</summary><b>B</b> — Apply 2^K ≥ M+K+1: K=5 gives 32 ≥ 22 ✓, but K=4 gives 16 ≥ 21 ✗. So 5 check bits.</details>
<details><summary>Q10</summary><b>B</b> — Check bits sit at the power-of-two positions (1,2,4,8,…) and data fills the gaps. This is the trick that makes the syndrome spell out the bad bit's position.</details>
<details><summary>Q11</summary><b>C</b> — An all-zero syndrome means the recomputed check bits matched the stored ones, so no single-bit error was detected.</details>
<details><summary>Q12</summary><b>B</b> — Read the syndrome as a binary number: `0110` = 6, so the flipped bit is at position 6. Flip it back to fix it.</details>
<details><summary>Q13</summary><b>C</b> — DDR is still DRAM, so it still needs refresh; that's the one thing it does NOT do. Its speed gains come from both clock edges, a higher clock, and prefetch buffering.</details>
<details><summary>Q14</summary><b>B</b> — Across DDR1→DDR4 the voltage drops 2.5 → 1.8 → 1.5 → 1.2 V (more power-efficient each generation), while data rates climb.</details>
<details><summary>Q15</summary><b>B</b> — NAND wires cells in series, giving higher density and lower cost with block access — perfect for SSDs and USB sticks. NOR is the random/byte-read one used for code (XIP).</details>

---

> 📊 **Scored low?** Totally normal on a first pass — go back to the matching `notes.md` section for anything you missed, then retry. **Scored 13+?** You've got Chapter 5 down.
