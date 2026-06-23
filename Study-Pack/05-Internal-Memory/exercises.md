# Chapter 05 — Internal Memory · Practice Questions

> 🌱 **How to use this file.** Read `notes.md` first. Then try each question **on your own** before opening the solution — even a rough, wrong attempt teaches you far more than reading the answer cold. It's completely fine to get them wrong; that's how you find your gaps. Peeking early *feels* productive but doesn't stick.
>
> Questions go **easy → harder**: first recall the facts, then apply them, then the chunkier Hamming and module problems near the end. Keep a pencil handy for the numerical ones.

---

## Warm-up: recall the basics

### Q1 — SRAM vs DRAM reasoning
A designer needs the **fastest possible cache** and, separately, the **cheapest large main memory**. Which technology for each, and give two reasons each.

<details><summary>Show answer</summary>

**Cache → SRAM.** Why: (1) its flip-flop ("latched switch") storage is faster — there's no waiting to sense a tiny charge; (2) it needs no refresh, so its latency stays consistently low.
**Main memory → DRAM.** Why: (1) ~1 transistor + 1 capacitor per bit (the "leaky bucket") makes it far denser, so you fit much more in; (2) far cheaper per bit. The accepted price for that bargain: it's slower and must be refreshed.
</details>

---

### Q2 — Why refresh?
Explain why DRAM requires refreshing but SRAM does not. What does a refresh operation physically do?

<details><summary>Show answer</summary>

DRAM stores each bit as **charge on a capacitor** — a bucket that **leaks**. Without topping it up, the charge drains and the bit is lost. SRAM stores bits in a **flip-flop** (a latched switch) that simply holds its state while powered — nothing leaks, nothing to top up. A **refresh** reads each row into the sense amplifiers and **writes the same value straight back**, which recharges the capacitors. Every row must be refreshed within the refresh interval (a few milliseconds).
</details>

---

### Q3 — ROM erase mechanisms
Match each to its erase method and granularity: ROM, PROM, EPROM, EEPROM, Flash.

<details><summary>Show answer</summary>

| Type | Erase method | Granularity |
|---|---|---|
| ROM | Cannot be erased (stamped in at the factory) | — |
| PROM | Cannot be erased (write once) | — |
| EPROM | UV light (through a quartz window) | Whole chip |
| EEPROM | Electrical | Byte |
| Flash | Electrical | Block |

Remember the ladder from "carved in stone" to "easily edited": ROM → PROM → EPROM → Flash → EEPROM.
</details>

---

## Applying it

### Q4 — Chip organisation
A **64 Mb** DRAM is organised as **16M × 4**. (a) How many addressable locations? (b) How many address bits total? (c) If row/column addresses are multiplexed equally, how many address pins?

<details><summary>Show answer</summary>

(a) 16M = 16 × 2²⁰ = 2²⁴ = **16,777,216 locations**.
(b) To name 2²⁴ locations you need **24 address bits** (and each location hands over 4 bits: 16M × 4 = 64 Mb ✓).
(c) Multiplexed equally means you send half the address as the row and half as the column over the same wires: 12 row + 12 col bits = **12 address pins** (plus the RAS and CAS signals). Remember: multiplexing halves the *pins*, not the *bits*.
</details>

---

### Q5 — Module construction
Build a **1M × 16** memory module using **1M × 4** chips. How many chips, and how are they connected?

<details><summary>Show answer</summary>

Need width = 16 bits; each chip gives 4 bits → **16 / 4 = 4 chips in parallel** (each supplies 4 of the 16 bits).
Need capacity = 1M, which is exactly each chip's own depth → only **1 bank** needed.
Total = **4 chips**. The full 20-bit address (2²⁰ = 1M) is broadcast to **all 4 chips at once**; chip *n* supplies data bits [4n .. 4n+3]. (Rule: wider → more chips in parallel; deeper → more banks.)
</details>

---

### Q6 — Check-bit count
How many Hamming check bits are needed for SEC on (a) 8 data bits, (b) 32 data bits, (c) 128 data bits?

<details><summary>Show answer</summary>

Use the rule `2^K ≥ M + K + 1` and just try values of K until it holds.
(a) M=8: K=4 → 16 ≥ 13 ✓ (K=3 → 8 ≥ 12 ✗). **K = 4.**
(b) M=32: K=6 → 64 ≥ 39 ✓ (K=5 → 32 ≥ 38 ✗). **K = 6.**
(c) M=128: K=8 → 256 ≥ 137 ✓ (K=7 → 128 ≥ 136 ✗). **K = 8.**
</details>

---

## Hamming — encode and decode

### Q7 — Hamming encode (4-bit data)
Data D1 D2 D3 D4 = **1 0 1 1**. Using SEC with check bits at positions 1, 2, 4, compute C1, C2, C4 and give the 7-bit codeword (positions 1–7).

<details><summary>Show answer</summary>

First drop the data into the non-power-of-2 slots:
Layout: pos1=C1, pos2=C2, pos3=D1=1, pos4=C4, pos5=D2=0, pos6=D3=1, pos7=D4=1.

Now each check bit is the even parity (XOR) of the positions it guards:
- C1 covers 1,3,5,7 → D1,D2,D4 = 1,0,1 → XOR = **0**
- C2 covers 2,3,6,7 → D1,D3,D4 = 1,1,1 → XOR = **1**
- C4 covers 4,5,6,7 → D2,D3,D4 = 0,1,1 → XOR = **0**

Codeword (pos1..7) = **C1 C2 D1 C4 D2 D3 D4 = 0 1 1 0 0 1 1**.
</details>

---

### Q8 — Hamming decode & correct
A 7-bit Hamming codeword (SEC, check at 1, 2, 4) is received as `0 1 1 0 1 1 1` (pos1..7). Find the syndrome, correct the word, and recover the data bits.

<details><summary>Show answer</summary>

Received: pos1=0, pos2=1, pos3=1, pos4=0, pos5=1, pos6=1, pos7=1.
Recompute each check group's parity (1 if it's wrong):
- S1 (1,3,5,7): 0⊕1⊕1⊕1 = 1 → 1
- S2 (2,3,6,7): 1⊕1⊕1⊕1 = 0 → 0
- S4 (4,5,6,7): 0⊕1⊕1⊕1 = 1 → 1

Syndrome S4 S2 S1 = 1 0 1 = **5** → the syndrome read as binary points at **position 5**. Flip it: pos5 1→0.
Corrected: 0 1 1 0 0 1 1. Data bits (positions 3,5,6,7) = **D1 D2 D3 D4 = 1 0 1 1**.
(That's exactly the Q7 codeword — which confirms the correction worked.)
</details>

---

### Q9 — Syndrome = 0 vs nonzero
In an SEC code, what do these syndromes mean: (a) 000, (b) 011, (c) 100? What is the limitation if **two** bits flip?

<details><summary>Show answer</summary>

(a) 000 → **no error** (everything checks out).
(b) 011 = decimal 3 → error at **position 3**, flip it.
(c) 100 = decimal 4 → error at **position 4** (which is the check bit C4), flip it.
Limitation: plain SEC **cannot reliably handle 2-bit errors** — two flips can produce a nonzero syndrome that points at the wrong single position, so it "corrects" the wrong bit silently. **SEC-DED** adds one overall parity bit so it can at least *detect* a double error (though it still only *corrects* one).
</details>

---

## Exam-style (a bit longer)

### Q10 — DDR throughput
Explain the **three** mechanisms by which DDR SDRAM beats classic SDRAM, and state the trend in voltage and prefetch buffer size from DDR1 to DDR4.

<details><summary>Show answer</summary>

Three mechanisms: (1) data is transferred on **both the rising and falling clock edges** (2 transfers per clock — the source of "double data rate"); (2) a **higher bus clock rate** each generation; (3) a **prefetch buffer** that internally grabs a wide chunk of bits and streams it out fast.
Trends DDR1→DDR4: **voltage falls** 2.5 → 1.8 → 1.5 → 1.2 V (lower power); **prefetch buffer** grows 2 → 4 → 8 → 8 bits (DDR4 stays at 8 but adds bank groups); data rates climb from 200–400 up to 2133–4266 Mbps.
</details>

---

### Q11 — NOR vs NAND Flash
You are choosing Flash for (a) storing boot/BIOS firmware that the CPU executes directly, and (b) a 256 GB SSD. Which Flash type for each and why?

<details><summary>Show answer</summary>

(a) Firmware / execute-in-place → **NOR Flash**: its cells wired in parallel give fast **random/byte read**, so the CPU can run code straight from the chip.
(b) SSD bulk storage → **NAND Flash**: its cells wired in series give **higher density and lower cost** per bit, with fast block write/erase — ideal for mass storage, where reads and writes happen in pages/blocks anyway.
</details>
