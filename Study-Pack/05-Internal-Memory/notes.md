# Chapter 05 — Internal Memory

> 🌱 **Starting from zero?** Perfect. This chapter assumes you've never looked inside a memory chip. We'll build everything from everyday comparisons first, name the technical terms second, and walk through every number slowly. The only thing that helps to have first is Chapter 1's "big picture" (CPU + Memory + I/O + Bus). Read top to bottom — don't skip the Hamming section, it looks scary but it's just careful counting.
>
> ⏱️ Take about 2 hours. This is a **high-priority, numbers-heavy** chapter, so go slowly through the worked examples.

---

## 🤔 First, why does this chapter exist?

In Chapter 1 we said the computer has a "working desk" called **main memory** where the CPU keeps the data and programs it's using *right now*. But we never asked: **how is that desk actually built?** What is a single "slot" of memory physically made of? Why is your computer's RAM fast but forgets everything when you switch off, while a USB stick is slower but remembers? And how does a memory chip not constantly corrupt your data given that it's just tiny electrical charges sitting in a noisy machine?

This chapter answers all of that. It's about the **stuff memory is made of** (semiconductors), the **trade-offs** between the different kinds, and the **clever tricks** that make memory cheap, dense, and reliable.

By the end you'll be able to, in your own words:
- explain how a single **memory cell** stores one bit,
- say why there are two flavours of RAM (**SRAM** and **DRAM**) and when you'd use each,
- run through the **ROM family** (ROM, PROM, EPROM, EEPROM, Flash) and how each is written and erased,
- read a chip spec like "16 Mb DRAM = 4M × 4" and work out the address bits,
- explain why DRAM needs **refreshing**,
- build a **memory module** out of smaller chips,
- and — the big one — do **Hamming error correction**: count check bits, encode a word, and use the **syndrome** to find and fix a flipped bit,
- plus compare **SDRAM / DDR1–DDR4** and **NOR vs NAND Flash**.

---

## 🗺️ The big picture before we dive in

Think of internal memory as a family tree of technologies, all built from the same raw material (silicon), but making different bargains. The eternal trade-off is: **fast & expensive** versus **dense, cheap, but forgetful**.

```text
                 SEMICONDUCTOR MEMORY
        ┌────────────────────┴────────────────────┐
       RAM (volatile, R/W)              ROM family (nonvolatile)
        ├── SRAM  → cache                ├── ROM    (mask, factory)
        └── DRAM  → main memory          ├── PROM   (write once, fuses)
              └── SDRAM → DDR1..4         ├── EPROM  (UV erase, whole chip)
                                          ├── EEPROM (electrical, byte erase)
                                          └── Flash  (electrical, block erase) NOR/NAND
```

In plain words: the **RAM** branch is fast, read/write memory that **forgets when power is lost** (that's what "volatile" means). The **ROM** branch **remembers without power** ("nonvolatile"), but is harder to write to. SRAM goes into the tiny, fast **cache**; DRAM is the big **main memory**; and the ROM branch ends at **Flash** (your SSDs and USB sticks). Because memory wires are long and a little noisy, we bolt on **Hamming error-correcting codes** to catch and fix flipped bits. And **SDRAM/DDR** are DRAM with a clock and clever buffering strapped on to keep up with fast CPUs.

---

## 1. The memory cell — one tiny box that holds one bit

Imagine a **light switch with a memory**: it can be ON or OFF, it stays put until you change it, and it has a little doorbell so you only fiddle with *this* switch when you ring it. That's basically a memory cell.

In plain words: a memory cell is the smallest building block of memory. It stores exactly **one bit** — it has **two stable states**, which we call 0 and 1. To use it, you need three wires.

```text
            Control (select)
                  │
            ┌─────┴─────┐
   Select ─►│  MEMORY   │◄─► Data in / out   (read OR write)
            │   CELL    │
            └───────────┘
```

Reading the diagram in plain words: the **Select** wire on the left is the doorbell — it picks *this* cell out of millions. The **Control** wire on top is the instruction — "are we reading you or writing to you?". The **Data** wire on the right is the actual bit going in (when writing) or coming out (when reading).

| Terminal (technical term) | Plain role |
|---|---|
| **Select** | The doorbell — activates this cell (worked out from the address you asked for) |
| **Control** | The instruction — says whether this is a **read** or a **write** |
| **Data in/out** | The bit itself — carries data in (write) or out (read) |

So a cell supports three operations: **Select**, **Read**, and **Write**. Nothing happens to a cell unless it's selected first.

> 🧠 **Memory hook:** a cell needs **3 things — pick me (Select), tell me (Control: R/W), feed/show me (Data)**.

---

## 2. The whole family of semiconductor memory

Now zoom out to the whole family tree. Two big questions sort every type: **does it forget when the power goes off?** (volatile or not) and **how hard is it to write to?**

| Type | Category | Erasure | Write mechanism | Volatility |
|---|---|---|---|---|
| **RAM (DRAM/SRAM)** | Read-write | Electrical, byte | Electrical | **Volatile** |
| **ROM** | Read-only | Not possible | Masks (factory) | Nonvolatile |
| **PROM** | Read-(mostly)-only | Not possible | Electrical (once) | Nonvolatile |
| **EPROM** | Read-mostly | UV light, whole chip | Electrical | Nonvolatile |
| **EEPROM** | Read-mostly | Electrical, byte | Electrical | Nonvolatile |
| **Flash** | Read-mostly | Electrical, **block** | Electrical | Nonvolatile |

A quick word on the jargon: **volatile** means "loses its data when the power is off" (like a thought you forget the moment you fall asleep). **Nonvolatile** means it remembers without power (like writing in a notebook). **RAM** is volatile read/write; everything in the **ROM family** is nonvolatile.

> ⚠️ **Exam trap:** "RAM" stands for **Random Access Memory** — that name only describes *how you reach it* (you can jump straight to any location, no waiting). It does **not** mean "volatile read/write." In fact ROM is *also* random access. What actually makes RAM "RAM" in this context is that it's **read/write and volatile**.

> ✍️ **Check yourself:** Which two types allow **byte-level electrical erase**?
> <details><summary>Reveal answer</summary>RAM and EEPROM. EPROM erases the whole chip (with UV light); Flash erases a block at a time.</details>

---

## 3. The two kinds of RAM — DRAM vs SRAM

Both kinds of RAM are **volatile** (forget on power-off) and both can be read and written. The difference is *how they physically hold a bit* — and that one difference cascades into everything else (speed, cost, size, whether it needs babysitting).

### DRAM (Dynamic RAM) — the leaky bucket

Picture a tiny **bucket that holds water**, with a single tap to fill or empty it. "Full" means 1, "empty" means 0. The catch: the bucket **leaks**. So every few milliseconds someone has to top it back up, or the bit fades away.

In plain words: **DRAM** stores each bit as **electrical charge on a capacitor** (the bucket), controlled by **one transistor** (the tap). Because charge leaks away, DRAM must be **refreshed** — periodically read and rewritten — or it loses the data. It's "dynamic" precisely because it constantly needs topping up.

### SRAM (Static RAM) — the latched switch

Now picture a proper **light switch (a toggle)** built from a little loop of logic. Flip it and it *stays* exactly where you left it — for as long as the power is on — with no leaking, no topping up.

In plain words: **SRAM** stores each bit in a **flip-flop** — a small circuit of cross-coupled transistors (usually **6 transistors**) that locks onto a 0 or 1 and holds it. It needs **no refresh** as long as power is applied. It's "static" because it just sits there, stable. It's built from the same logic-gate technology as the processor itself.

### The cell sketches (in plain words below)

```text
   DRAM CELL (1T + 1C)                 SRAM CELL (6T flip-flop)
   ─────────────────────              ──────────────────────────
        Word line                          Word line (select)
           │                            ──────┬───────┬──────
        ───┴───  (transistor)          B │    │       │   B (bit lines,
        │     │                          │  ┌─┴─┐  ┌─┴─┐ │  complementary)
   Bit ─┤     ├─ ═══ Capacitor           │  │ T │××│ T │ │
   line │     │  ───  (holds charge)     │  └─┬─┘  └─┬─┘ │
        ───────                          └────┘  ╳╳  └───┘
   1 transistor + 1 capacitor            cross-coupled inverters
   → leaks → NEEDS REFRESH               → stable → NO refresh
```

Reading the sketches: on the **left**, the DRAM cell is just **one transistor** (the tap) plus **one capacitor** (the bucket) — beautifully simple and tiny, which is why you can pack loads of them in. On the **right**, the SRAM cell is a knot of **six transistors** wired so they hold each other's state steady — bigger and pricier, but rock-solid and fast.

### Side-by-side comparison

| Feature | **SRAM** | **DRAM** |
|---|---|---|
| Storage element | Flip-flop (cross-coupled transistors) | Capacitor charge |
| Transistors / bit | ~6 | ~1 (+1 capacitor) |
| **Refresh needed?** | **No** | **Yes** (charge leaks) |
| Speed | **Faster** | Slower |
| Density (bits/area) | Lower | **Higher** |
| Cost per bit | **Higher** | Lower |
| Power | Higher when active | Lower |
| Volatile? | Yes | Yes |
| Typical use | **Cache** | **Main memory** |

> 🧠 **Memory hook:** **S**RAM = **S**tatic = **S**tays (no refresh), **S**wift, **S**mall capacity (cache). **D**RAM = **D**ynamic = **D**ecays (refresh), **D**ense, **D**irt cheap (main memory).

> ⚠️ **Exam trap:** SRAM is faster and needs no refresh — but it is **NOT** nonvolatile. Both SRAM and DRAM lose everything when the power goes. "No refresh" is not the same as "remembers without power."

> ✍️ **Check yourself:** Why is DRAM denser than SRAM?
> <details><summary>Reveal answer</summary>A DRAM cell uses only ~1 transistor + 1 capacitor, versus SRAM's ~6 transistors. Smaller cells mean more bits fit in the same area.</details>

---

## 4. The ROM family — memory that remembers without power

The ROM family is all **nonvolatile** (keeps data with the power off). The members differ along a **writability spectrum** — how easy it is to put data in and, later, change it. Think of it as a ladder from "carved in stone" up to "easily edited."

### How each one is written and erased, in plain words

- **ROM** (Read-Only Memory) — the data is **stamped in at the factory** using a mask, like printing words into a coin's mould. It can **never** change. Cheap when you make millions, but one mistake ruins the whole batch and there are no field updates.
- **PROM** (Programmable ROM) — ships **blank**; you (the user) **write it once**, electrically, by blowing tiny fuses. After that, read-only forever. Like a write-once CD-R.
- **EPROM** (Erasable PROM) — written electrically, but you can **wipe it clean with UV light** shone through a little quartz window. UV erases the **entire chip** at once (takes ~20 minutes). Reusable many times. Like a whiteboard you can only erase by holding it under a lamp.
- **EEPROM** (Electrically Erasable PROM) — erase and rewrite **electrically, one byte at a time**, without removing the chip from the circuit. The most flexible to edit, but writes are slower, density is lower, and it costs more.
- **Flash** — electrically erasable, but in **blocks** (not single bytes), using just 1 transistor per bit (so it's dense like EPROM) and faster than EEPROM. It sits **between EPROM and EEPROM** in cost and capability.

| Type | Write mechanism | Erasure | Granularity | Reusable | Volatile |
|---|---|---|---|---|---|
| **ROM** | Mask (factory) | — | — | No | No |
| **PROM** | Electrical (once) | — | — | No (once) | No |
| **EPROM** | Electrical | **UV light** | Whole chip | Yes | No |
| **EEPROM** | Electrical | Electrical | **Byte** | Yes | No |
| **Flash** | Electrical | Electrical | **Block** | Yes | No |

> 🧠 **Memory hook:** Writability ladder — **ROM(never) → PROM(once) → EPROM(UV, whole chip) → Flash(block) → EEPROM(byte)** = increasing flexibility, with EEPROM the easiest to edit (single byte).

> ✍️ **Check yourself:** How is an EPROM erased, and at what granularity?
> <details><summary>Reveal answer</summary>By exposure to UV light through a quartz window; it erases the entire chip at once.</details>

---

## 5. Reading a chip spec — the 16 Mb DRAM (4M × 4)

Memory chips are sold with a spec like **"4M × 4"**. Read it as **"4M words, each 4 bits wide."** So this chip has 4M (4,194,304) separate addressable locations, and every time you read one location you get **4 bits** at once. Total = 4M × 4 = **16M bits** = 16 Mb.

```text
   16 Mb DRAM  =  4M × 4
   ┌──────────────────────────────┐
   │   2048 × 2048 cell array      │   (4M cells laid out as a square)
   │   per bit plane × 4 planes    │
   └──────────────────────────────┘
   Address = 22 bits (2^22 = 4M)
   → split into 11 row + 11 col bits, sent over the SAME 11 pins
```

In plain words: to name 4M different locations you need an address with enough bits, and since 2²² = 4M, the address is **22 bits** long. The cells are physically arranged as a big **square grid** (2048 rows × 2048 columns), four such grids stacked (one per bit of the 4-bit output).

### Multiplexed row/column addressing — sending the address in two halves

Here's the clever bit. Pins on a chip are expensive. Instead of having 22 address pins, the chip reuses **11 pins twice**: first you send the **row** half of the address, then the **column** half, down the *same* wires.

```text
   Step 1: put ROW addr on A0..A10, pulse RAS (Row Address Strobe)
           → whole row read into sense amplifiers
   Step 2: put COL addr on A0..A10, pulse CAS (Column Address Strobe)
           → selects the bit(s) within that row → data out
```

Reading it in plain words: think of finding a seat in a stadium. First you announce the **row** (and the whole row gets pulled up ready — the "sense amplifiers" read that entire row). Then you announce the **column / seat number** within that row, and that's your bit. **RAS** (Row Address Strobe) is the signal "here comes the row," and **CAS** (Column Address Strobe) is "here comes the column."

The payoff: a 22-bit address travels on just **11 pins** instead of 22. A side effect — because a whole row gets read at once — is what makes **fast page / burst** modes possible (you can grab many nearby bits cheaply).

> 🧠 **Memory hook:** **RAS before CAS** — **R**ows first, **C**olumns second; both ride the same wires.

> ⚠️ **Exam trap:** Multiplexing **halves the address *pins*, not the address *bits***. 4M locations still need all 22 address bits in total — you just send them in two batches of 11.

---

## 6. Refreshing — topping up the leaky buckets

Recall the DRAM bucket leaks. So the chip can't just sit there — every cell must be **read and rewritten** within the **refresh interval** (typically a few milliseconds) or the charge fades and the bit is lost. A dedicated **refresh circuit** marches through the rows one at a time, restoring each.

```text
   for each row:
        activate row (RAS)  →  sense amps read charge
        write the same value back (recharge capacitor)
   ...repeat across all rows every few ms (refresh cycle)
```

In plain words: for each row, you switch it on, the sense amplifiers read what's currently there, and then you immediately write that same value back — which tops the capacitor back up. Do this for every row, over and over, every few milliseconds.

The cost: refresh eats **time and power**, and while a chunk of memory is being refreshed it's **busy** and can't serve the CPU. SRAM avoids all of this hassle entirely — that's part of why it's faster.

---

## 7. Building a memory module from chips

A single chip rarely gives you exactly the **word length** (how many bits wide) and **capacity** (how many locations) you want. So you wire several chips together. Two rules cover everything:

- Need it **wider**? Put chips **in parallel**, each supplying some of the bits.
- Need **more locations**? Add more **banks**, and use the top address bits to pick which bank.

### A 256 KByte module (256K × 8) from 256K × 1 chips

You want bytes (8 bits wide), but each chip is only 1 bit wide. So use **8 chips**, each 256K × 1. The 18-bit address goes to **all 8 chips at once**; chip number *k* hands over bit *k* of every byte.

```text
   A0..A17 ─┬───┬───┬─ ... ─┬─   (same 18 addr lines to all 8 chips)
            ▼   ▼   ▼        ▼
          [256K×1][256K×1]...[256K×1]   (8 chips)
            │b0   │b1          │b7
            └──── 8-bit data byte ──────┘
   2^18 = 256K addresses, 8 bits each = 256 KByte
```

In plain words: the same address (18 bits, because 2¹⁸ = 256K) is broadcast to all eight chips simultaneously. Each chip looks up that one address and outputs its single bit. Line up all eight bits side by side and you've got your byte.

### A 1 MByte module (1M × 8) — now we need more locations

256K isn't enough; we want 1M locations. Since 1M = 4 × 256K, take **four banks** of the 256 KB design above. The bottom 18 address bits pick the location *within* a bank; the top **2 bits** choose *which of the 4 banks* (fed through a decoder that switches on just one bank's chips).

```text
   A0..A17  → all banks (within-bank address)
   A18,A19  → 2-to-4 decoder → enables ONE of 4 banks (group select)
   ┌──────┐┌──────┐┌──────┐┌──────┐
   │Bank0 ││Bank1 ││Bank2 ││Bank3 │   each = 256KB (8 chips)
   └──────┘└──────┘└──────┘└──────┘
```

In plain words: 2 bits can count to 4 (00, 01, 10, 11), so the top two address bits select one of the four banks via a "2-to-4 decoder," and only that bank wakes up to answer.

> 🧠 **Memory hook:** **More bits wide → more chips in parallel** (each gives some bits). **More addresses → more banks** (top address bits pick the bank).

> ✍️ **Check yourself:** How many 256K×1 chips for a 512K × 16 module?
> <details><summary>Reveal answer</summary>16 chips per 256K bank to make it 16 bits wide, times 2 banks (because 512K = 2 × 256K) = 32 chips.</details>

---

## 8. Hamming error correction — finding and fixing a flipped bit

> 🌱 Take this section slowly. It's the most important one in the chapter for exams, and it's not hard — it's just careful bookkeeping. We'll keep every number exactly as in the worked example.

**Why bother?** Memory can flip a bit. Errors are either **hard** (a permanently broken cell) or **soft** (a one-off glitch, e.g. a cosmic ray nudging a charge). An **ECC** (Error-Correcting Code) stores a few **extra check bits** alongside each data word so the machine can not only *notice* a flip but actually *fix* it.

The clever idea: it's like adding a few overlapping "this group of bits should be even" rules. If exactly one bit flips, it breaks a unique combination of rules — and that combination spells out, in binary, *exactly which bit* went wrong.

### The function — encode on write, check on read

```text
   WRITE:  M data bits ──► [function f] ──► K check bits
                                store M+K bits

   READ:   stored M data + K check  ──► recompute check ──► compare
                XOR(old check, new check) = SYNDROME
                syndrome = 0   → no error
                syndrome ≠ 0   → points to the bit position to flip (SEC)
```

In plain words: when you **write**, you compute K check bits from the M data bits and store all M+K bits together. When you **read**, you recompute the check bits from the data you got back, and compare them to the stored ones (by XOR-ing — "spot the difference"). That difference is called the **syndrome**. If the syndrome is all zeros, nothing's wrong. If it's nonzero, read it as a binary number and it tells you the **exact position** of the broken bit — flip it back. This single-error-correcting scheme is **SEC**.

(Jargon: **XOR** just means "are these two bits different? 1 if different, 0 if same." **Parity** means counting whether the number of 1s in a group is even or odd.)

### How many check bits do you need? The SEC rule

For the syndrome to be able to point at any of the **M data bits + K check bits**, *plus* have a spare "all clear" code (the 0), you need enough distinct syndrome values. K check bits give 2ᴷ possible syndromes, so:

```text
        2^K  ≥  M + K + 1
```

You just try values of K until it holds. Here are the standard ones (memorise these):

| Data bits M | Min check bits K | Total |
|---|---|---|
| 8  | 4 | 12 |
| 16 | 5 | 21 |
| 32 | 6 | 38 |
| 64 | 7 | 71 |

### Where the bits go (the Hamming layout)

The trick that makes the syndrome spell out the position: put the **check bits at the power-of-two positions** (1, 2, 4, 8, …) and let data bits fill in all the gaps. Each check bit Cᵢ then guards every position whose number, written in binary, includes that bit.

```text
   Position:  1    2    3    4    5    6    7    8    9   10   11   12
   Bit type:  C1   C2   D1   C4   D2   D3   D4   C8   D5   D6   D7   D8
              ▲    ▲         ▲                   ▲
            check check    check               check  (powers of 2)

   Coverage (binary of position):
     C1 → positions with bit0 set: 1,3,5,7,9,11
     C2 → positions with bit1 set: 2,3,6,7,10,11
     C4 → positions with bit2 set: 4,5,6,7,12
     C8 → positions with bit3 set: 8,9,10,11,12
   Each Cᵢ = even parity (XOR) over the bits it covers.
```

In plain words: position 3 in binary is `011`, which has the "1" bit and the "2" bit set — so position 3 is guarded by **C1 and C2**. Position 6 is `110` (the "2" and "4" bits) — guarded by **C2 and C4**. Each check bit is set so that the count of 1s in its group is **even**. If later a single bit flips, it throws off exactly the check bits whose groups it belongs to — and those check bits, read together, are the binary address of that bit.

> 🧠 **Memory hook:** **Check bits live at powers of 2** (1, 2, 4, 8). The **syndrome, read as a binary number, IS the position of the wrong bit** (0 = everything clean).

> ⚠️ **Exam trap:** **SEC** (single-error correct) needs `2^K ≥ M+K+1`. **SEC-DED** (also *detects* double errors) adds **one extra overall parity bit** on top. Don't confuse the two — SEC-DED still only *corrects* one error, but it can *notice* when two have occurred.

> ✍️ **Check yourself:** For M = 16 data bits, what's the minimum K for SEC?
> <details><summary>Reveal answer</summary>K = 5, because 2⁵ = 32 ≥ 16 + 5 + 1 = 22, whereas 2⁴ = 16 < 21. So 5 check bits.</details>

The full step-by-step worked example is near the end of this file — go through it once you've read the rest.

---

## 9. Advanced DRAM — SDRAM & DDR

### SDRAM (Synchronous DRAM)

Old-style DRAM is **asynchronous**: the CPU asks for data and then just *waits* an unknown amount of time for the answer — like ordering at a counter with no idea when your number's called.

**SDRAM** fixes this by **marching to the system clock**. Data is exchanged with the CPU **in step with the clock ticks**, so the CPU doesn't have to sit and guess. It uses a **burst mode** (deliver a run of consecutive values back-to-back) and an internal **mode register** (which sets things like burst length and CAS latency). It also has several internal **banks** that can work in an overlapping way for more throughput.

### DDR SDRAM (Double Data Rate)

Standardised by **JEDEC** (the industry standards group). DDR pushes the data rate up **three ways**:

1. It transfers data on **both the rising and the falling clock edge** — two transfers per clock tick instead of one. (This is literally where "double data rate" comes from.)
2. It runs at a **higher bus clock rate** with each new generation.
3. It uses a **prefetch buffer** — internally grab a wide chunk of bits per access, then stream them out fast.

```text
   SDR:  data │‾|__│‾|__   one transfer per clock (rising edge only)
              ▲      ▲

   DDR:  data │‾|__│‾|__   two transfers per clock (rising AND falling)
              ▲  ▲  ▲  ▲     → "double data rate"
```

Reading the diagram: in plain **SDR** (single data rate) you only deliver data on the *up*-tick of the clock — one chance per cycle. In **DDR** you deliver on both the up-tick *and* the down-tick — two chances per cycle, so twice the data for the same clock.

### DDR1 to DDR4 at a glance

| Feature | **DDR1** | **DDR2** | **DDR3** | **DDR4** |
|---|---|---|---|---|
| Prefetch buffer (bits) | 2 | 4 | 8 | 8 |
| Voltage (V) | 2.5 | 1.8 | 1.5 | 1.2 |
| Front-side bus data rate (Mbps) | 200–400 | 400–1066 | 800–2133 | 2133–4266 |

> 🧠 **Memory hook:** Across DDR1→4, the **voltage drops** (2.5→1.2, more efficient) while **data rates climb**. The prefetch buffer grows 2→4→8, then DDR4 keeps 8 but adds **bank groups** for more parallelism.

> ⚠️ **Exam trap:** DDR transfers **twice per clock cycle** by using *both edges* — the **bus clock itself is not doubled**. "Double data rate" ≠ "double the clock speed."

> ✍️ **Check yourself:** Name the three ways DDR raises throughput.
> <details><summary>Reveal answer</summary>Both clock edges; a higher bus clock; and prefetch buffering.</details>

---

## 10. Flash memory — NOR vs NAND

Flash arrived in the mid-1980s. It's **nonvolatile**, **electrically erased in blocks**, uses just **1 transistor per bit** (so it's dense, like EPROM), and sits **between EPROM and EEPROM** in cost and capability. It's everywhere — inside the machine (BIOS) and outside it (SSDs, USB sticks, memory cards).

There are two wiring styles, named after the logic gate their cell layout resembles:

| | **NOR Flash** | **NAND Flash** |
|---|---|---|
| Cell wiring | Cells in parallel (like a NOR gate) | Cells in series strings (like a NAND gate) |
| Access | **Random/byte read** (XIP — execute-in-place) | **Page/block** access |
| Speed | Fast read, slow write/erase | Fast write/erase, slower random read |
| Density / cost | Lower density, costlier | **Higher density, cheaper** |
| Typical use | Code/BIOS storage | **Bulk storage**: SSD, USB, cards |

```text
   NOR: cells in PARALLEL  → random access, run code in place (BIOS)
   NAND: cells in SERIES   → dense, block access, mass storage (SSD)
```

In plain words: **NOR** wires cells side-by-side so you can jump straight to any byte and read it instantly — perfect for code the CPU runs directly from the chip ("execute-in-place"). **NAND** wires cells in long series strings, which packs them in tightly (cheaper, denser) but means you access them in pages/blocks rather than single bytes — perfect for mass storage like SSDs.

> 🧠 **Memory hook:** **NO**R = **NO** waiting to read randomly (code). **NAND** = **N**eed **A**ddress in blocks, **N**ice **D**ensity (storage).

---

## 🔬 Worked Example — Hamming SEC (8-bit data)

> Work through this with a pencil. Every number here is exact — don't skip steps.

**Goal:** encode an 8-bit data word, then detect and correct a 1-bit error.

**Data (D1..D8) = `1 0 1 1 0 0 1 0`** (D1 is leftmost).
M = 8, so we need K = 4 check bits (since 2⁴ = 16 ≥ 8+4+1 = 13). Total = 12 bits.

### Step 1 — Lay out the positions (check bits at 1, 2, 4, 8)

```text
 Pos:  1   2   3   4   5   6   7   8   9   10  11  12
 Bit:  C1  C2  D1  C4  D2  D3  D4  C8  D5  D6  D7  D8
 Data:  ?   ?   1   ?   0   1   1   ?   0   0   1   0
```

We've dropped the 8 data bits into the non-power-of-2 slots (positions 3,5,6,7,9,10,11,12) and left the check bits (positions 1,2,4,8) blank for now.

### Step 2 — Compute each check bit (even parity over the positions it covers)

```text
 C1 covers pos 1,3,5,7,9,11  → data bits 3,5,7,9,11 = 1,0,1,0,1  → XOR = 1
 C2 covers pos 2,3,6,7,10,11 → data bits 3,6,7,10,11 = 1,1,1,0,1 → XOR = 0
 C4 covers pos 4,5,6,7,12    → data bits 5,6,7,12 = 0,1,1,0       → XOR = 0
 C8 covers pos 8,9,10,11,12  → data bits 9,10,11,12 = 0,0,1,0     → XOR = 1
```

Each line just XORs together the data bits in that check bit's group (XOR = "is the count of 1s odd? then 1"). So **C1=1, C2=0, C4=0, C8=1**. The full stored codeword:

```text
 Pos:  1   2   3   4   5   6   7   8   9  10  11  12
 Bit:  C1  C2  D1  C4  D2  D3  D4  C8  D5 D6  D7  D8
 Val:  1   0   1   0   0   1   1   1   0   0   1   0
```

### Step 3 — Introduce a single-bit error

Suppose **position 6 flips** (that's D3, going 1 → 0). The received (corrupted) word:

```text
 Pos:  1   2   3   4   5   6   7   8   9  10  11  12
 Val:  1   0   1   0   0   0   1   1   0   0   1   0     (pos 6 corrupted)
```

### Step 4 — Recompute parity to get the syndrome bits S8 S4 S2 S1

```text
 S1 (pos 1,3,5,7,9,11):  1⊕1⊕0⊕1⊕0⊕1 = 0   → matches → 0
 S2 (pos 2,3,6,7,10,11): 0⊕1⊕0⊕1⊕0⊕1 = 1   → mismatch → 1
 S4 (pos 4,5,6,7,12):    0⊕0⊕0⊕1⊕0   = 1   → mismatch → 1
 S8 (pos 8,9,10,11,12):  1⊕0⊕0⊕1⊕0   = 0   → matches → 0
```

For each check group we recompute the parity over *all* its positions (check bit included). If it comes out as it should (even), that syndrome bit is 0; if it's off, it's 1.

### Step 5 — Read the syndrome

```text
 Syndrome = S8 S4 S2 S1 = 0 1 1 0 (binary) = 6 (decimal)
 → Error is at POSITION 6.  Flip it back: 0 → 1.
```

The syndrome read as a binary number is **6** — and sure enough, position 6 is exactly where we flipped a bit. Flip it back and the corrected word matches the original. (A syndrome of 0 would have meant "no error.")

> ✍️ **Check yourself:** If the syndrome came out `0000`, what does it mean? And `1000`?
> <details><summary>Reveal answer</summary>`0000` = no error detected. `1000` = decimal 8 = error at position 8 (which happens to be the check bit C8 itself) — flip it.</details>

---

## ✅ You now understand…

Take a breath — that's the whole chapter. In plain terms:

1. A **memory cell** holds one bit and needs three wires: **Select** (pick me), **Control** (read or write?), **Data** (the bit).
2. **RAM** is volatile read/write; the **ROM family** is nonvolatile. ("RAM" only describes *random access*, not volatility.)
3. **SRAM** = flip-flop, 6 transistors, no refresh, fast, used for **cache**. **DRAM** = leaky capacitor, 1 transistor, needs **refresh**, dense and cheap, used for **main memory**. Neither survives power loss.
4. **ROM family** runs along a writability ladder: **ROM (mask) → PROM (once) → EPROM (UV, whole chip) → EEPROM (electrical, byte) → Flash (electrical, block)**.
5. A chip spec "**W × B**" means W locations of B bits each; address bits = log₂W. **Multiplexed RAS/CAS** sends the address in two halves to save pins (e.g. 16 Mb = 4M × 4, 22 bits over 11 pins).
6. **Refresh** = read-and-rewrite every DRAM row every few ms to top up the leaking charge.
7. **Modules**: more width → more chips in **parallel**; more capacity → more **banks** (top address bits select the bank).
8. **Hamming SEC**: need K check bits with `2^K ≥ M+K+1`; put them at powers of 2; the **syndrome read as binary is the position of the flipped bit** (0 = clean). **SEC-DED** adds one parity bit to also detect doubles.
9. **SDRAM** is clock-synced DRAM; **DDR** doubles throughput via **both clock edges + higher clock + prefetch buffer** (DDR1→4: voltage 2.5→1.2, prefetch 2/4/8/8).
10. **Flash**: nonvolatile, block-erase, 1T/bit. **NOR** = random/byte read for code; **NAND** = dense block storage (SSDs).

If any of those feel shaky, re-read that section. When they all feel comfortable, do `exercises.md`, then `mcq.md`.

---

## 🎓 When you're revising for the exam

The explanations above are for understanding. For the exam, examiners want precise wording and clean working — keep these ready.

### Exam-ready techniques

- **SRAM vs DRAM**: lead with refresh / transistor count; everything else (speed, density, cost, use) follows from those two facts.
- **ROM erase questions**: always give *mechanism + granularity* — ROM none / PROM once / EPROM UV whole-chip / EEPROM byte / Flash block.
- **Chip org**: read "W words × B bits"; address bits = log₂(W); width = B. For modules: width → chips in parallel; capacity → banks (top address bits select the bank).
- **Check-bit count**: solve `2^K ≥ M+K+1` by trying K. Memorise 8→4, 16→5, 32→6, 64→7.
- **Hamming encode**: check bits at powers of 2; each = even parity over the positions whose index (in binary) has that bit set.
- **Hamming decode**: recompute parities → syndrome (S8 S4 S2 S1) read as decimal = the bad bit's position; 0 = clean.
- **DDR**: "both edges + higher clock + prefetch buffer." Voltage falls, rate rises across DDR1→4.

### Mnemonics

- **S**RAM = **S**tatic, **S**tays, **S**wift, **S**mall (cache); **D**RAM = **D**ynamic, **D**ecays, **D**ense, **D**irt-cheap (main memory).
- **RAS before CAS** — Rows then Columns, same wires.
- ROM ladder: **never → once → UV-chip → block → byte** (ROM, PROM, EPROM, Flash, EEPROM).
- ECC: **2^K ≥ M+K+1**; **syndrome IS the bad bit's position** (0 = clean).
- DDR: **edges + clock + prefetch**; voltage **down**, rate **up**.
- **NO**R = **NO** wait random read (code); **NAND** = blocks, dense (storage).

### One-page recap

```text
CELL: select + control(R/W) + data. Stores 1 bit.
RAM (volatile): SRAM=flip-flop,6T,no refresh,fast,cache | DRAM=capacitor,1T,refresh,dense,main mem
ROM family (nonvolatile): ROM(mask) PROM(once) EPROM(UV,chip) EEPROM(elec,byte) Flash(elec,block)
CHIP: "W words × B bits"; addr bits=log2(W); multiplexed RAS(row)+CAS(col) share pins; 16Mb=4M×4
REFRESH: read+rewrite all rows every few ms (DRAM only)
MODULE: width→parallel chips; capacity→banks via top addr bits
ECC: 2^K ≥ M+K+1. Check bits at pos 1,2,4,8. Syndrome=XOR(old,new check)=bad position; 0=clean.
      SEC = correct 1; SEC-DED = +1 parity bit to also detect 2.
SDRAM: clock-synced, burst. DDR: both edges+higher clock+prefetch. DDR1→4: V 2.5→1.2, prefetch 2,4,8,8.
FLASH: nonvolatile, block erase, 1T/bit. NOR=random/code, NAND=block/storage(SSD).
```

### Likely exam question (worked)

**"Calculate the number of Hamming SEC check bits for a 16-bit data word, and explain what the syndrome tells you."**
<details><summary>Model answer</summary>

Apply `2^K ≥ M + K + 1` with M = 16. Try K = 5: 2⁵ = 32 ≥ 16 + 5 + 1 = 22 ✓. Try K = 4: 2⁴ = 16 < 21 ✗. So the minimum is **K = 5** check bits (21 bits total).

The **syndrome** is the bitwise XOR of the stored check bits and the check bits recomputed on read. If the syndrome is **0**, no single-bit error occurred. If it is **nonzero**, its value read as a binary number gives the **exact position of the flipped bit**, which is then corrected by flipping it back. (SEC corrects one error; **SEC-DED** adds one overall parity bit to also *detect* a double error.)
</details>

---

## 📚 Resources

- Stallings, *Computer Organization and Architecture* 11e — Ch.5 Internal Memory & Ch.6 advanced/Flash: https://www.pearson.com/en-us/subject-catalog/p/computer-organization-and-architecture/P200000003520
- Neso Academy — Memory (RAM/ROM) playlist: https://www.youtube.com/playlist?list=PLBlnK6fEyqRgLLlzdgiTUKULKJPYc0A4q
- Neso Academy — Hamming Code (error detection & correction): https://www.youtube.com/watch?v=1A_NcXxdoCc
- Gate Smashers — RAM & ROM types: https://www.youtube.com/watch?v=p3Dfk_5j0Ak
- Gate Smashers — Error detection & correction / Hamming code: https://www.youtube.com/watch?v=wbH2VxzmoZk
- GeeksforGeeks — Hamming code & memory: https://www.geeksforgeeks.org/hamming-code-in-computer-network/
- GeeksforGeeks — Difference between SRAM and DRAM: https://www.geeksforgeeks.org/difference-between-sram-and-dram/
- TutorialsPoint — Computer memory / ROM & RAM: https://www.tutorialspoint.com/computer_fundamentals/computer_memory.htm
