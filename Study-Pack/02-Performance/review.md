# Chapter 02 — Quick Refresher (Computer Performance)

> 🌱 Read this in 5 minutes to refresh everything, or the day before the exam. Each idea is given in **plain words first**, then the exam wording / formula. This is a final-exam carryover topic — make the formulas automatic.

---

## The big ideas, in plain words

- **Why performance, why multicore.** Apps keep wanting more power. Making one core faster hit physical walls — too much **heat** (power wall), **RC delay** (thin, close wires slow signals), and **slow memory**. So instead of one faster core, designers added **more cores** (multicore → MIC → GPGPU).
- **Balance, not just speed.** A fast CPU starved by slow memory/bus/I-O sits idle. Match the whole path. *(Race car on a dirt road goes nowhere.)*
- **The master equation.** Real time = how many instructions × cycles each × time per cycle: **T = Ic × CPI × τ**, with **τ = 1/f**. Units must cancel to **seconds**.
- **Average CPI.** Weight each instruction class's CPI by how often it runs, then add them up.
- **MIPS and clock speed lie.** They count instructions or ticks, not real work. Always compare **execution time on the same real program**.
- **Amdahl's Law.** The part you *can't* speed up is the ceiling. Even infinite cores can't beat **1/(1−f)**.
- **Right average.** The *type of data* decides the *type of mean*: **Times → Arithmetic, Rates → Harmonic, Ratios → Geometric** (SPEC uses geometric).
- **Little's Law.** Items in a system = arrival rate × time each stays: **L = λW**. *(Customers in shop = arrivals/min × minutes each stays.)*

---

## 📐 Formulas (boxed)
```text
 ┌──────────────────────────────────────────────────────────────┐
 │ τ = 1/f                      clock cycle time ↔ frequency      │
 │ T = Ic × CPI × τ = Ic × CPI / f      CPU performance equation  │
 │ N = Ic × CPI                 total clock cycles               │
 │ CPI = Σ(CPIᵢ·Icᵢ)/Ic = Σ(CPIᵢ·fracᵢ)     average CPI          │
 │ MIPS = Ic/(T×10⁶) = f/(CPI×10⁶)                               │
 │ MFLOPS = (FP ops)/(T×10⁶)                                     │
 │ Amdahl:  S = 1/[(1−f) + f/k]      Smax = 1/(1−f)              │
 │ Little:  L = λ × W                                            │
 │ SPEC ratio = ref_time / measured_time   (overall = GM)        │
 └──────────────────────────────────────────────────────────────┘
```

## 🧮 The three means
```text
 AM = (Σxᵢ)/n           HM = n / Σ(1/xᵢ)        GM = (Πxᵢ)^(1/n)
 ALWAYS:  HM ≤ GM ≤ AM   (equal only when all values identical)
```

## 🎯 Mean-selection rule (memorize)
| Data type | Mean | Example |
|---|---|---|
| Execution **times** (absolute) | **Arithmetic** | seconds per run |
| **Rates** (work/time) | **Harmonic** | MIPS, MFLOPS, throughput |
| Normalized **ratios** | **Geometric** | SPEC speed/rate ratios |

> Mnemonic: **Times-Arithmetic, Rates-Harmonic, Ratios-Geometric.**

## ⚖️ Amdahl's Law at a glance
```text
 f = parallel/enhanced fraction,  k = its speedup
 Step 1 ceiling:  Smax = 1/(1−f)        Step 2 finite:  S = 1/[(1−f)+f/k]
 f=0.50→max 2×   f=0.75→4×   f=0.90→10×   f=0.95→20×   f=0.99→100×
 Diminishing returns: serial part (1−f) is the hard ceiling.
```

## 🧠 Mnemonics
- **"I See Pie times Tau"** = Ic × CPI × τ.
- **f and τ are reciprocals** (τ = 1/f).
- **MIPS = "Meaningless Indicator of Processor Speed"** — compare *times*, not MIPS.
- **"Serial part is the ceiling"** (Amdahl).
- **Speed = single task; Rate = throughput. Base = strict; Peak = tuned** (SPEC).

## ⚠️ Top exam traps
1. Comparing **MIPS across different instruction sets** → invalid (different work per instruction).
2. Using **arithmetic mean on rates or SPEC ratios** → use HM / GM instead.
3. Expecting **linear speedup** from cores → Amdahl caps it at 1/(1−f).
4. **Clock speed alone** ≠ performance (it ignores CPI and Ic).
5. Mixing **ns vs s** or forgetting **GHz = 10⁹** (and MHz = 10⁶).

## 🏗️ Concept one-liners
- **Power wall + RC delay + memory lag** → why we went **multicore**.
- **Multicore** = a few identical general-purpose cores; **MIC** = many cores (hard to program); **GPGPU** = vector/SIMD chip used for repetitive maths.
- **Performance balance** = match CPU speed to memory/bus/I-O so nothing starves.
- **Table 2.1:** instruction set & compiler affect Ic & CPI; processor implementation & memory hierarchy affect CPI & clock.
- **SPEC CPU2017** = 20 integer + 23 FP benchmarks (C/C++/Fortran), compute-bound; rate vs speed, base vs peak.

---

### ⭐ If you only revise 5 things
1. **`T = Ic × CPI × τ`** (and τ = 1/f) — the master equation; always unit-check to seconds, and you can rearrange it to solve for a missing CPI or time.
2. **Average CPI = Σ(CPIᵢ × fractionᵢ)**, then plug into the equation.
3. **MIPS misleads** — always compare **execution time on the same program**.
4. **Amdahl:** `S = 1/[(1−f)+f/k]`, ceiling `1/(1−f)` — parallelism has hard limits.
5. **Mean rule:** Times→Arithmetic, Rates→Harmonic, Ratios→Geometric (SPEC uses GM).
