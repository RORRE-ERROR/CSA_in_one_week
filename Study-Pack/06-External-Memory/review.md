# Chapter 06 — External Memory · Quick Refresher

> 🌱 Read this in 5 minutes to refresh everything, or the day before the exam. Each idea is given in **plain words first**, then the exam wording.

---

## The big ideas, in plain words

- **External memory = secondary storage.** The slow-but-huge, cheap, **non-volatile** bottom of the memory ladder — hard disks, SSDs, optical discs, tape. It **keeps your data when the power is off** (unlike RAM, which forgets).
- **A hard disk** is like a record player storing data magnetically: spinning **platters** coated in magnetic material, read/written by a floating **head**. *Exam terms:* substrate (glass or aluminium), inductive write + magnetoresistive (MR) read heads, Winchester (aerodynamic) head.
- **Disk layout — track, sector, cylinder.** A **track** is one ring; a **sector** is the smallest readable arc (512 or 4096 bytes); a **cylinder** is the same track across all stacked surfaces — reachable **with no arm movement (no seek)**.
- **CAV vs MZR.** **CAV** = same sectors on every track (the head sees a constant data rate, but the roomy outer tracks are *wasted*, and bits are densest on the inner track). **MZR** = more sectors on the outer tracks → uses that space → more capacity. **Real drives use MZR.**
- **Disk access time** = the time to fetch data, and it's three steps: **seek** (move the arm — slowest), **rotational latency** (wait for the sector to spin around — on average *half* a spin), and **transfer** (read the bytes — tiny). For small reads, the **positioning (seek + latency) dominates**.
- **RAID** = several disks ganged into **one logical drive** using **striping** (speed), **mirroring** (full copy), and **parity** (rebuild info). Levels 0–6 are *different designs, not a ranking*. The **write penalty** on parity levels 4/5 = **2 reads + 2 writes** (read old data + old parity, write new data + new parity); RAID 1 has none.
- **SSD = flash, no moving parts.** Faster, quieter, tougher against bumps, lower power, but pricier per GB and **finite writes** → needs **wear leveling**. It also **slows as it fills** (must erase + rewrite whole blocks).
- **Optical** = laser reads pits/lands on a plastic disc. **Bluer (shorter-wavelength) laser → smaller pits → more data:** CD < DVD < Blu-ray.
- **Tape** = a magnetic ribbon, **sequential access** (wind to the data). Dirt cheap per TB → archives/backups.

---

## ⏱️ Disk access time (the must-know formula)

```text
Total access = SEEK (Ts) + ROTATIONAL LATENCY (1/2r) + TRANSFER (b/rN)
   r = RPM / 60   (rev per SECOND)
   one revolution = 1/r        avg latency = 1/(2r)  (half a rev)
   transfer time  = b / (r·N)   b = bytes moved, N = bytes per track
   block access time (Ta) = seek + latency   (positioning only)
```
- **Convert RPM → rev/s first.** Keep everything in seconds, report ms at the end.
- Small reads: **seek + latency dominate**; transfer is tiny.
- Read a whole track: transfer = 1/r. Track read rate = N·r.

## 💾 RAID 0–6 one-liner table

| Lvl | Mechanism | Min disks | Usable (N data, size S) | Survives | Write penalty | Use |
|---|---|---|---|---|---|---|
| 0 | Striping, no redundancy | 2 | N·S (100%) | 0 | none | speed; disposable data |
| 1 | Mirroring | 2 | N·S/2 (50%) | ≥1 per pair | none | high availability, simple |
| 2 | Bit + Hamming ECC | N+m (m∝logN) | — | 1 | yes | none commercial |
| 3 | Bit-interleaved parity | N+1 (≥3) | (N−1)·S | 1 | yes | high transfer rate |
| 4 | Block parity, 1 disk | N+1 (≥3) | (N−1)·S | 1 | **high** (bottleneck) | none commercial |
| 5 | Block parity, distributed | N+1 (≥3) | (N−1)·S | 1 | moderate | **most versatile** (servers) |
| 6 | Dual distributed parity | N+2 (≥4) | (N−2)·S | **2** | **highest** | mission-critical |

- **RAID 4 vs 5:** 4 = parity on **one** dedicated disk (bottleneck); 5 = parity **spread** round-robin.
- **Write penalty (4/5):** 2 reads + 2 writes per small write (old data + old parity → new data + new parity).
- **RAID 6:** two parity blocks (P, Q) → survives 2 failures; a 3rd failure within the rebuild window loses data.

## 💿 Optical media table

| Product | Erasable | Capacity | Mechanism / note |
|---|---|---|---|
| CD / CD-ROM | No | ~650 MB | stamped pits, 780 nm |
| CD-R | Write once | ~650 MB | dye layer (WORM) |
| CD-RW | Rewritable | ~650 MB | phase-change (amorphous/crystalline) |
| DVD-ROM | No | up to 17 GB (DS/DL) | 650 nm red |
| DVD-R / DVD-RW | once / rewritable | single-sided | |
| Blu-ray | depends | **25 GB / layer** | **405 nm** blue-violet |

**Density chain:** wavelength ↓ ⇒ pits ↓ ⇒ capacity ↑ (780 → 650 → 405 nm).

## 🖥️ SSD vs HDD (fast facts)
- **SSD** = NAND flash, no moving parts: **high IOPS, low latency, 2–3 W, quiet, shock-resistant, costlier (~$0.20/GB)**.
- **HDD** = magnetic platters: cheaper (~$0.03/GB), bigger, pays mechanical seek + latency, 6–7 W.
- **SSD limits:** **finite write cycles** → **wear leveling**; **slows as it fills** (must read-erase-write whole blocks) → cache front-end, bad-block management.

## 🖴 Disk layout & tape
- **Track** = ring; **Sector** = smallest block (512 or **4096** B); **Cylinder** = same track on all surfaces (no seek).
- **CAV** = same sectors/track (wastes outer, densest inner); **MZR** = more sectors outer (modern, higher capacity).
- **Tape** = sequential; blocks (physical records) + inter-record gaps; cheap archive (LTO up to 32 TB).

## 🧠 Mnemonics
- **"SeeR-Lat-Trans"** → Seek + ½ Rev + b/rN.
- **RAID "0 None · 1 Clone · 5 One-for-all · 6 Two-for-all"** (overhead + failures tolerated).
- **Glass substrate "BRUSS"** → Better reliability, Reduced defects, lower fly heights, Stiffer, Shock-resistant.
- **Bluer laser = denser disc.**

## Mini diagrams to be able to draw
```text
ACCESS-TIME TIMELINE:   ├─ Seek ─┤─ Latency (½r) ─┤─ Transfer (b/rN) ─┤
                          move arm   wait for sector    read the bytes

RAID CORE IDEAS:   STRIPE 0: D0|D1|D2|D3     MIRROR 1: D0|D0'   PARITY 5: D0|D1|D2|P
```

---

### ⭐ If you only revise 5 things
1. **Access time = seek + 1/2r + b/rN**, with **r = RPM/60**; positioning (seek + latency) dominates small reads.
2. **RAID overhead / fault tolerance:** 0 = none / survives 0 · 1 = 50% / ≥1 · 5 = 1 disk / 1 · 6 = 2 disks / 2.
3. **RAID 4 vs 5:** dedicated vs **distributed** parity (5 avoids the bottleneck → most versatile); write penalty = 2 reads + 2 writes.
4. **SSD:** flash, **finite writes → wear leveling**; faster/pricier than HDD, no moving parts, slows as it fills.
5. **Optical density** rises as laser wavelength falls: CD < DVD < **Blu-ray (405 nm, 25 GB/layer)**.
