# Chapter 06 — External Memory · Practice Questions

> 🌱 **How to use this file.** Read `notes.md` first. Then try each question **on your own** before opening the answer — even a rough attempt cements it. Peeking early feels productive but teaches far less. It's completely fine to get them wrong; that's how you find your gaps.
>
> For the disk-timing ones, follow the drill every time: **`r = RPM/60` first, keep `r` in rev/second, convert to ms only at the very end.** Questions go **easy → harder**.

---

## Warm-up: the disk-timing drill

### Problem 1 — Rotational latency from RPM
A hard disk spins at **15,000 RPM**. Compute (a) rotation speed `r` in rev/s, (b) time for one revolution, (c) average rotational latency.

<details><summary>Show answer</summary>

(a) Convert RPM to rev/second: `r = 15000 / 60 = 250 rev/s`.
(b) One revolution is just the reciprocal: `1/r = 1/250 = 0.004 s = 4.0 ms`.
(c) On average the sector you want is half a spin away, so average latency = `1/(2r) = 4.0/2 = `**`2.0 ms`**.

*Plain version: it spins 250 times a second, so one spin is 4 ms, and on average you wait half a spin = 2 ms.*
</details>

---

### Problem 2 — Full access time, small read
Disk: **7200 RPM**, average seek `Ts = 9 ms`, **400 sectors/track**, **512 bytes/sector**. Find the average time to read **a single sector**.

<details><summary>Show answer</summary>

Run the drill in order:
- `r = 7200/60 = 120 rev/s`.
- Latency (half a spin) = `1/(2·120) = 4.167 ms`.
- Bytes per track `N = 400 × 512 = 204,800 B`; we want `b = 512 B` (one sector).
- Transfer = `b/(rN) = 512/(120 × 204800) = 512/24,576,000 = 2.083×10⁻⁵ s = 0.0208 ms`.
  (Shortcut: one sector is 1/400 of a revolution = `8.333 ms / 400 = 0.0208 ms`. ✓)
- **Total = seek + latency + transfer = 9 + 4.167 + 0.0208 ≈ 13.19 ms.**

*Notice the actual reading (0.02 ms) is almost nothing — the 13.17 ms of positioning is the whole cost.*
</details>

---

### Problem 3 — Reading a whole track vs scattered sectors
Same disk as Problem 2 (7200 RPM, Ts = 9 ms, N = 204,800 B/track). Compare reading **all 400 sectors of one track at once** vs reading **400 sectors scattered one-per-track** (so you pay seek + latency every single time).

<details><summary>Show answer</summary>

**Whole track (one positioning, then read everything):** transfer = `N/(rN) = 1/r = 8.333 ms`. Total = `9 + 4.167 + 8.333 = 21.5 ms` for all 400 sectors at once.

**Scattered (pay positioning 400 times):** each access ≈ `9 + 4.167 + 0.0208 = 13.19 ms` (Problem 2), times 400 = **≈ 5,275 ms ≈ 5.3 s**.

Sequential is about **245× faster** here. The lesson, in plain words: because the fixed positioning cost is paid once vs 400 times, *where your data sits matters enormously*. This is exactly why operating systems and databases try to read data in big sequential chunks.
</details>

---

### Problem 4 — Transfer rate from a track
A drive at **10,000 RPM** has **N = 1,000,000 bytes per track**. What is the sustained transfer rate while reading one track?

<details><summary>Show answer</summary>

- `r = 10000/60 = 166.67 rev/s`.
- You read one whole track per revolution, so the rate is "a track's worth of bytes, that many times a second": `rate = N × r = 1,000,000 × 166.67 = 1.667×10⁸ B/s ≈ 166.7 MB/s`.
  (Same thing written as `rate = N / (1/r) = N·r`.)
</details>

---

## Applying it

### Problem 5 — CAV vs MZR
Explain why a CAV disk wastes capacity and how Multiple Zone Recording fixes it. Where is bit density highest under CAV?

<details><summary>Show answer</summary>

Under **CAV**, every track holds the **same number of sectors/bits**, so at a constant spin speed the head sees a constant data rate (simple). But outer tracks are physically *longer* circles, so the same bits get **stretched out** over more space — that room is **wasted**, and **bit density is highest on the innermost (shortest) track** because the bits are most crammed there.

**MZR** groups tracks into zones and puts **more sectors on the outer (longer) tracks**, using the space that CAV wasted. Density ends up roughly even across the surface; addressing gets more complex, but total capacity is higher. **Modern HDDs use MZR.**
</details>

---

### Problem 6 — RAID capacity & overhead
You have **8 disks of 2 TB each (16 TB raw)**. Give usable capacity and % overhead for RAID 0, RAID 1, RAID 5, RAID 6.

<details><summary>Show answer</summary>

| Config | Usable | Overhead |
|---|---|---|
| RAID 0 | 8×2 = **16 TB** | 0% (no redundancy at all) |
| RAID 1 (4 mirrored pairs) | **8 TB** | 50% (every byte is duplicated) |
| RAID 5 | (8−1)×2 = **14 TB** | 1 disk = 12.5% (one disk's worth is parity) |
| RAID 6 | (8−2)×2 = **12 TB** | 2 disks = 25% (two disks' worth is parity) |

*Memory hook in action: 0 = none, 1 = a clone (half gone), 5 = one for the team, 6 = two for the team.*
</details>

---

### Problem 7 — Fault-tolerance scenario
An array uses **RAID 5** across 5 disks. (a) How many simultaneous disk failures can it survive? (b) During rebuild after one failure, a second disk dies — what happens? (c) What level would prevent that loss, and at what cost?

<details><summary>Show answer</summary>

(a) **One** disk failure — RAID 5 has a single (distributed) parity, enough to rebuild exactly one missing disk.
(b) A **second** failure before the first finishes rebuilding → **data lost**. Single parity can reconstruct only one missing disk, not two.
(c) **RAID 6** (dual distributed parity, N+2) survives **two** simultaneous failures. The cost: one extra disk's worth of capacity given up, plus a **heavier write penalty** (it must update *two* parity blocks per write).
</details>

---

### Problem 8 — The RAID write penalty
Why does RAID 4/5 incur a "write penalty" on small writes, and how many disk operations does a single small write require? Why is RAID 1 free of this penalty?

<details><summary>Show answer</summary>

When you change a little data on a parity level, the parity must still match the new data — so the controller must **read the old data strip and read the old parity strip**, use them to compute the new parity, then **write the new data strip and write the new parity strip**. That's **2 reads + 2 writes** for one logical write — the write penalty.

**RAID 1 has no parity** to keep in sync — it just writes the same data to both mirror disks. So there's **no write penalty** (and bonus: reads can come from either copy).
</details>

---

### Problem 9 — Match RAID level to use case
Match each scenario to the best RAID level: (a) video editing scratch space, max speed, data is disposable; (b) accounting system needing the simplest possible high availability; (c) versatile file/DB server balancing read performance, capacity, and redundancy; (d) mission-critical store that must tolerate two failures.

<details><summary>Show answer</summary>

(a) **RAID 0** — pure striping, fastest, no redundancy (fine because the data is disposable).
(b) **RAID 1** — mirroring; the simplest design, rebuild is just "copy the survivor," very high availability.
(c) **RAID 5** — distributed parity, the "most versatile" level, ideal for file/DB/web servers.
(d) **RAID 6** — dual parity, survives two simultaneous failures, built for mission-critical data.
</details>

---

## Harder / challenge

### Problem 10 — SSD behaviour
(a) Why does an SSD's write performance degrade as it fills? (b) Name three techniques that prolong flash lifetime and what each does.

<details><summary>Show answer</summary>

(a) Flash can only be erased/written in whole **blocks**, never a single byte in place. To change a little data, the controller reads the whole block into a RAM buffer, **erases the entire flash block**, then writes it back (read → modify → erase → write). As free space shrinks, more of this expensive shuffling is needed, so writes slow down.

(b) **Wear leveling** — spreads writes evenly across all cells so none wears out early (like rotating your tyres). **Cache front-end** — groups/delays writes so the flash gets written less often. **Bad-block management** — detects and retires worn-out blocks (and drives estimate remaining lifetime, so failure can be anticipated).
</details>

---

### Problem 11 — Optical media (challenge)
(a) Rank CD, DVD, Blu-ray by laser wavelength and per-layer capacity. (b) Distinguish CD-R from CD-RW physically. (c) State CD-ROM's two main advantages and two disadvantages.

<details><summary>Show answer</summary>

(a) Wavelength (longest → shortest): CD (780 nm infrared) > DVD (650 nm red) > Blu-ray (405 nm blue-violet). The rule is **shorter wavelength → smaller pits → higher density**, so capacity goes the other way: CD ~650 MB < DVD ~4.7 GB/layer (up to 17 GB double-sided dual-layer) < Blu-ray **25 GB/layer**.
(b) **CD-R** uses a **dye layer** that a laser darkens once → write-once (WORM). **CD-RW** uses a **phase-change** material that toggles between amorphous (dull) and crystalline (shiny) reflectivity → rewritable many times.
(c) Advantages: cheap **mass replication** of disc + data, and it's **removable** (good for archival). Disadvantages: **read-only** (you can't update it), and **access time is much slower** than a magnetic disk drive.
</details>
