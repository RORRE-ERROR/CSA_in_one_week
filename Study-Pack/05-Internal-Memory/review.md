# Chapter 05 — Internal Memory · Quick Refresher

> 🌱 Read this in 5 minutes to refresh everything, or the day before the exam. Each idea is given in **plain words first**, then the exam wording.

---

## The big ideas, in plain words

- **Memory cell** = one tiny box holding **one bit**. It needs three wires: **Select** (a doorbell to pick this cell), **Control** (read or write?), **Data** (the bit itself).
- **RAM vs ROM** = **forgetful vs faithful**. RAM is fast read/write but **volatile** (loses data on power-off). The whole ROM family is **nonvolatile** (remembers without power). Note: "RAM" only means *random access*, not "volatile" — ROM is random access too.
- **SRAM vs DRAM** = **latched switch vs leaky bucket**. SRAM is a flip-flop (6 transistors) that just stays put → fast, no refresh, but big and pricey → used for **cache**. DRAM is charge on a capacitor (1 transistor) that leaks → dense and cheap but must be **refreshed** → used for **main memory**. Both are volatile.
- **ROM family** = a ladder from "carved in stone" to "easily edited": **ROM** (stamped at factory, never changes) → **PROM** (write once) → **EPROM** (UV-erase the whole chip) → **EEPROM** (electrical, one byte at a time) → and **Flash** (electrical, a block at a time) sitting between EPROM and EEPROM.
- **Chip spec "W × B"** = W locations, each B bits wide. Address bits = log₂(W). To save pins, the address is sent in two halves — **row first (RAS), column second (CAS)** — over the same wires.
- **Refresh** = topping up the leaky buckets: read every DRAM row and write it straight back, every few milliseconds. SRAM never needs this.
- **Modules** = combine chips. Need it **wider** → chips in **parallel** (each gives some bits). Need **more locations** → more **banks**, with the top address bits choosing the bank.
- **Hamming SEC** = add a few overlapping "should be even" rules so a single flipped bit breaks a unique combination that spells out *its own position*. Need K check bits where **2^K ≥ M+K+1**, placed at powers of 2; the **syndrome** (recomputed checks XOR stored checks) read as a binary number **is the position of the bad bit** (0 = clean). **SEC-DED** adds one parity bit to also *detect* double errors.
- **SDRAM / DDR** = DRAM that marches to the clock. DDR gets its speed three ways: **both clock edges + a higher clock + a prefetch buffer**. Across DDR1→4, voltage falls and rates rise.
- **Flash NOR vs NAND** = **read-anywhere code chip vs dense storage chip**. NOR = parallel cells, random/byte read (BIOS, run-in-place). NAND = series cells, dense and cheap, block access (SSDs, USB).

---

## SRAM vs DRAM — at a glance

| Feature | SRAM | DRAM |
|---|---|---|
| Storage | Flip-flop (cross-coupled T) | Capacitor charge |
| Transistors/bit | ~6 | ~1 (+capacitor) |
| **Refresh** | **No** | **Yes** (leaks) |
| Speed | Faster | Slower |
| Density | Lower | Higher |
| Cost/bit | Higher | Lower |
| Volatile | Yes | Yes |
| Use | **Cache** | **Main memory** |

## ROM family

| Type | Write | Erase | Granularity | Volatile |
|---|---|---|---|---|
| ROM | Mask (factory) | none | — | No |
| PROM | Electrical (once) | none | — | No |
| EPROM | Electrical | UV light | Whole chip | No |
| EEPROM | Electrical | Electrical | Byte | No |
| Flash | Electrical | Electrical | Block | No |

NOR Flash = parallel cells, random/byte read (code/BIOS, XIP).
NAND Flash = series cells, dense, block access (SSD, USB).

## DDR generations

| | DDR1 | DDR2 | DDR3 | DDR4 |
|---|---|---|---|---|
| Prefetch (bits) | 2 | 4 | 8 | 8 |
| Voltage (V) | 2.5 | 1.8 | 1.5 | 1.2 |
| Data rate (Mbps) | 200–400 | 400–1066 | 800–2133 | 2133–4266 |

DDR beats SDRAM via: **both clock edges + higher bus clock + prefetch buffer.**

## Hamming SEC recipe

```text
1. Check bits K: smallest K with  2^K ≥ M + K + 1.
   (8→4, 16→5, 32→6, 64→7)
2. Place check bits at positions 1,2,4,8,...(powers of 2). Data fill the rest.
3. Cᵢ = even parity (XOR) over positions whose binary index includes that bit:
      C1 → positions ...,1,3,5,7,9...   (bit0 set)
      C2 → positions ...,2,3,6,7,10...  (bit1 set)
      C4 → positions ...,4,5,6,7,12...  (bit2 set)
      C8 → positions ...,8..15...       (bit3 set)
4. DECODE: recompute each parity → syndrome = S8 S4 S2 S1.
      syndrome = 0      → no error
      syndrome = n ≠ 0  → flip bit at position n
5. SEC-DED = SEC + 1 overall parity bit → also DETECT (not correct) 2-bit errors.
```

## Chip / module rules

```text
"W words × B bits":  address bits = log2(W);  word width = B.
16 Mb = 4M × 4  → 22 addr bits, 4 data bits.
Multiplexed addressing: RAS sends ROW, CAS sends COLUMN, share same pins → half the pins.
MODULE width   → chips in PARALLEL (chips = needed_width / chip_width).
MODULE capacity→ multiple BANKS; top address bits decode which bank.
```

## Mini diagrams to be able to draw

```text
DRAM cell:  1 transistor + 1 capacitor   → leaks → needs REFRESH
SRAM cell:  ~6 transistors (flip-flop)    → stable → NO refresh

Hamming layout (M=8):
 Pos:  1   2   3   4   5   6   7   8   9  10  11  12
 Bit:  C1  C2  D1  C4  D2  D3  D4  C8  D5  D6  D7  D8
       └ check bits at powers of 2; data fills the gaps ┘
 Syndrome read as binary = position of the flipped bit (0 = clean).
```

## Mnemonics

- **SRAM = Stays, Swift, Small (cache); DRAM = Decays, Dense, cheap (main mem).**
- **RAS before CAS** — Rows then Columns, same wires.
- ROM writability ladder: **never → once → UV-chip → block → byte** (ROM, PROM, EPROM, Flash, EEPROM).
- ECC: **2^K ≥ M+K+1**; **syndrome IS the bad bit's position** (0 = clean).
- DDR: **edges + clock + prefetch**; voltage **down**, rate **up** (DDR1→4).
- **NO**R = **NO** wait random read (code); **NAND** = blocks, dense (storage).

---

### ⭐ If you only revise 5 things

1. **SRAM (flip-flop, no refresh, cache) vs DRAM (capacitor, refresh, main memory)** — and why DRAM is denser/cheaper (smaller 1-transistor cell). Both are volatile.
2. **ROM family write/erase + granularity** (ROM mask, PROM once, EPROM UV-whole-chip, EEPROM byte, Flash block).
3. **Hamming SEC**: `2^K ≥ M+K+1`, check bits at powers of 2, **syndrome = position of bad bit** (0 = no error); SEC-DED adds 1 parity bit.
4. **Chip/module org**: read "W × B", address bits = log₂W, multiplexed RAS/CAS halves the *pins*; width → parallel chips, capacity → banks (top bits select bank).
5. **DDR**: both clock edges + higher clock + prefetch; DDR1→4 voltage 2.5→1.2, prefetch 2/4/8/8, rates climbing.
