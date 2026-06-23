# Chapter 06 — External Memory

> 🌱 **Starting from zero?** You're in the right place. This chapter assumes you know *nothing* about how computers store files for the long term. We'll build the picture one small step at a time, with everyday comparisons before any technical words, and we'll go slowly through the two parts that scare people most — the disk *timing maths* and *RAID*. Read top to bottom; don't skip ahead.
>
> ⏱️ Take about 2 hours. This is a high-priority, number-heavy chapter — examiners love it.

> 📎 Maps to **Stallings COA 11e, Chapter 7 — External Memory**.

---

## 🤔 First, why does this chapter exist?

Think about what happens when you turn your computer off and on again. Your files are still there — your photos, your documents, your music. But you also know that "unsaved work" gets lost when the power dies. So clearly there are **two kinds of memory**: a fast one that forgets everything when the power goes (that's main memory / RAM, the previous chapter), and a slower one that **remembers things even with the power off**.

This chapter is about that second kind: **external memory**, also called **secondary storage** — hard disks, SSDs, CDs/DVDs, and tape. These are where your stuff actually *lives*. They're slower than RAM, but they're huge, cheap per gigabyte, and they **don't forget** (we call that **non-volatile**).

The reason this chapter matters so much for exams: a hard disk is partly a *mechanical* machine (spinning platters, a moving arm), so we can calculate exactly **how long it takes to fetch data** — that's a favourite numerical question. And when one disk isn't reliable or fast enough, we gang several together using **RAID** — another exam favourite. We'll treat both with extra care.

By the end you'll be able to, in your own words:
- describe **what a hard disk looks like inside** (platters, tracks, sectors, cylinders),
- explain **CAV vs Multiple Zone Recording** (two ways of laying out data),
- **calculate disk access time** from the RPM (seek + rotational latency + transfer),
- compare **RAID levels 0–6** (how much space you keep, how many failures you survive, the "write penalty"),
- explain how **SSDs/flash**, **optical discs**, and **tape** work and where each is used.

---

## 🗺️ The big picture first

Computer memory is a **hierarchy** — a ladder. At the top, things are tiny, blazing fast, and expensive. As you go down, they get bigger, slower, and cheaper. External memory is the **bottom rungs**: slow but enormous and cheap, and it keeps data with the power off.

```text
   FAST / small / $$$        Registers
        ↑                    Cache (SRAM)
   main memory               Main memory (DRAM)   ── internal (forgets when power off)
   ─────────────────────────────────────────────────────────
   SLOW / big / cheap        DISK (HDD) / SSD      ── EXTERNAL (this chapter)
        ↓                    Optical (CD/DVD/BD)      keeps data with power off
                             Magnetic tape (archive)
```

In plain words: the closer to the CPU, the faster and tinier and pricier. External memory is the far end of the ladder — slow to reach, but you get a *lot* of storage for very little money, and it survives a power cut.

Four families live in this chapter. Here's the cheat-table; we'll meet each one properly below.

| Family | What it really is | How you reach data | Can you erase/rewrite? | Typical job |
|---|---|---|---|---|
| Magnetic disk (HDD) | a spinning metal/glass platter coated in magnetic stuff | mechanically, jump straight to any spot (**direct**) | yes | the main bulk storage |
| SSD | flash memory chips, **no moving parts** | electronically, jump to any spot (**direct**) | yes (but in whole blocks) | fast storage |
| Optical (CD/DVD/Blu-ray) | a plastic disc read by a laser | mechanically, direct | depends on the type | sharing/distribution, archive |
| Magnetic tape | a long magnetic ribbon on a reel | must **wind to the spot** (**sequential**) | yes | dirt-cheap bulk backup |

> 🧠 **One word to remember about external memory: non-volatile** — it keeps your data when the power is off. (RAM is *volatile* — it forgets.)

---

## 1. What a hard disk looks like inside

Picture an old vinyl record on a turntable, spinning, with a needle hovering over it. A hard disk is basically that idea, but instead of grooves it stores data **magnetically**, and instead of a needle it has a tiny **head** that can both read and write.

The disc itself is called a **platter** — a flat circle. Its base material (the **substrate**) used to be aluminium alloy; modern drives often use **glass** instead. The platter is coated with a **magnetizable** material — a coating you can flip into tiny magnetic patterns that stand for 0s and 1s.

The **head** is a tiny conductive **coil** that hovers just over the surface. It writes by creating a magnetic field that flips the coating, and reads by sensing the coating's magnetism as it spins past. Modern drives actually use **two** heads side by side: a separate **inductive write** head and a **magnetoresistive (MR) read** head, because reading and writing are best done by different designs.

> 🧠 **Why glass platters? Memory hook "BRUSS":** **B**etter Reliability, **R**educed defects (fewer surface flaws), lower fly heights (the head **U**ndershoots closer to the surface — smaller gap), **S**tiffer, **S**hock-resistant. Glass is smoother and stiffer than aluminium, so the head can fly closer, which means data can be packed tighter.

**Ways drives differ (Stallings Table 7.1).** Don't memorise this as a list — just understand each contrast:

| Question about the drive | The two (or three) options, in plain words |
|---|---|
| Does the head move? | **Fixed head** = one head permanently parked over every track (no moving). **Movable head** = one head per surface, riding on an arm that swings in and out. |
| Can you remove the disk? | Nonremovable (a sealed PC hard disk) vs Removable (an old floppy or ZIP disk). |
| How many sides used? | Single- vs Double-sided. |
| How many platters? | Single vs Multiple (stacked). |
| How does the head sit? | Contact (touches, like a floppy), Fixed gap, or **Aerodynamic gap (Winchester)** — explained next. |

**The Winchester head (this is the clever bit).** In a modern sealed drive, the head is shaped like a little wing (an aerodynamic foil). When the disk is still, the head rests gently on the surface. When the disk spins up, the rushing air **lifts the head** to float just barely above the surface — like a hovercraft. Because the whole assembly is sealed against dust, the head can fly *very* close, which lets the drive use **narrower tracks** and therefore **pack in more data**.

> ✍️ **Check yourself:** Why does a narrower head allow higher data density, and what's the catch?
> <details><summary>Reveal answer</summary>Narrower head → narrower tracks → you fit more tracks (more data) on each surface. The catch: the head must fly closer to the surface, which makes it more sensitive to dust, surface imperfections, and the dreaded "head crash" if it touches down.</details>

---

## 2. How data is laid out on a disk: tracks, sectors, cylinders

Imagine drawing lots of concentric circles on the platter, like the rings on a dartboard. Each ring is a **track**. Now slice the whole platter into pie wedges. Where a wedge crosses a track, you get a small arc — that arc is a **sector**, and it's the **smallest chunk you can read or write at once** (you can't grab half a sector).

```text
  PLATTER (top view)                     SPINDLE STACK (side view)
  ┌─────────────────────────┐            head ─►├═══════ platter 0 surface 0
  │      ___________        │            head ─►├═══════           surface 1
  │    /  _______   \       │            head ─►├═══════ platter 1 surface 2
  │   /  /  ___  \   \      │  tracks     head ─►├═══════           surface 3
  │  |  |  | o |  |  |  ◄────┼── (concentric)    arm assembly moves all heads together
  │   \  \  ‾‾‾  /   /      │
  │    \  ‾‾‾‾‾‾‾   /        │   ┌── A CYLINDER = the same track number on
  │      ‾‾‾‾‾‾‾‾‾          │   │   ALL surfaces, accessible without moving the arm
  └─────────────────────────┘   └─────────────────────────────────────────────
        one wedge = a SECTOR (smallest addressable unit; e.g. 512 or 4096 bytes)
```

**Reading the left picture:** the rings are tracks; one pie-slice arc is a sector. **Reading the right picture:** drives often stack several platters on one spindle, each with its own head on the shared arm. When the arm swings, **all the heads move together** to the same track number.

That last fact gives us the third term. A **cylinder** is the set of tracks at the same radius **across all the platters at once** — imagine a tin can standing up through the stack of platters, touching the same-numbered track on every surface. Why does this matter? Because if your data is arranged in a cylinder, the arm is *already in the right place* for all of it — **no arm movement needed** (no "seek"). That's free speed.

- **Track** = one concentric ring on one surface.
- **Sector** = a fixed-size arc; the smallest addressable block. Sectors are kept apart by little **inter-sector gaps**. Old drives used 512 bytes/sector; modern **"Advanced Format" uses 4096 bytes/sector**.
- **Cylinder** = the same track number stacked across all surfaces — reachable with **no seek**.

> 🧠 **Memory hook:** **"Cylinder = stack the same track."** It's the cheapest data to read because the arm doesn't have to move.

### Two ways to space out the data: CAV vs Multiple Zone Recording

Here's a puzzle. Outer tracks are physically longer (bigger circle) than inner tracks. Should every track hold the *same* amount of data, or should the longer outer tracks hold *more*?

- **Constant Angular Velocity (CAV)** says: put the **same number of sectors on every track**. The disk spins at a steady speed, and because every track has the same sectors, the head sees a nice **constant data rate**. Simple to address (just "track, sector"). The downside: on the long outer tracks you've **stretched the same bits over more space** — that space is *wasted*.

- **Multiple Zone Recording (MZR)** says: group tracks into **zones**, and give the **outer zones more sectors** (since there's room). This **recovers the wasted capacity** → more total storage. The cost: addressing is more complicated. **Modern hard drives use MZR.**

| | Constant Angular Velocity (CAV) | Multiple Zone Recording (MZR) |
|---|---|---|
| Sectors per track | **Same** on every track | **More on the outer** tracks (grouped into zones) |
| The roomy outer tracks | **Wasted** (bits stretched out) | **Used** → more capacity |
| Addressing | Simple (track, sector) | More complex |
| Bit density | Higher on inner tracks (crammed) | Roughly even across the whole surface |

> ⚠️ **Exam trap:** CAV doesn't *choose* to be low-capacity — it keeps the same bits per track so the data rate stays constant, but it ends up **wasting** the longer outer tracks. MZR is the fix, and it's what real drives use today.

> ✍️ **Check yourself:** Under CAV, where is bit density highest — the inner or outer track?
> <details><summary>Reveal answer</summary>The <b>innermost</b> track. Same number of bits, but squeezed onto the shortest (smallest) circle, so they're packed most tightly.</details>

---

## 3. ⭐ Disk performance: how long does a read take? (the big numerical)

This is the heart of the chapter. When the disk wants to read or write some data, **three things have to happen in order**:

1. **Seek** — the arm swings to the right *track*. This is moving a physical arm, so it's the **slowest** part.
2. **Rotational latency** — once on the right track, the head **waits for the right sector to spin around** to it.
3. **Transfer** — the data bytes pass under the head and get read. This is usually the **fastest** part.

```text
  TOTAL ACCESS TIME timeline
  ├──── Seek time ────┤── Rot. latency ──┤── Transfer time ──┤
  │  move arm to track│ wait for sector  │ data passes head  │
  │  (mechanical, big)│ to rotate to head│ (b / rN)          │
                       └── avg = 1/2r ────┘
  Block access time (Ta) = seek + rotational latency      ← positioning
  Total transfer        = Ta + transfer time
```

**Reading the timeline:** first you pay for the arm to move (seek), then you wait for the spin (latency), then you actually read (transfer). The first two together are "positioning" — just getting *ready* to read.

Let's build the formulas slowly. The only number you're usually given is the spin speed in **RPM** (revolutions per minute).

**Step A — convert RPM to revolutions per second.** Formulas use `r` = revolutions **per second**, not per minute. Since there are 60 seconds in a minute:
> `r = RPM / 60`

**Step B — how long is one full spin?** If it does `r` revolutions every second, one revolution takes:
> `time per revolution = 1/r`

**Step C — average rotational latency.** When the head lands on the track, the sector it wants could be anywhere — sometimes it's already there (no wait), sometimes it just passed (wait a full spin). On *average* you wait **half a revolution**:
> `average rotational latency = 1/(2r)`

**Step D — transfer time.** To read `b` bytes off a track that holds `N` bytes total, you're reading the fraction `b/N` of one revolution, and one revolution takes `1/r`. Multiply them out and you get:
> `transfer time T = b / (r·N)`   (b = bytes you want, N = bytes per track)

**Putting it together:**

| Quantity | Formula | Plain meaning |
|---|---|---|
| Rotation speed | `r = RPM / 60` | spins per **second** |
| Time per revolution | `1/r` | one full spin |
| **Average rotational latency** | **`1 / (2r)`** | wait half a spin on average |
| **Transfer time** | **`T = b / (r·N)`** | reading b bytes off an N-byte track |
| **Block access time (Ta)** | seek `Ts` + `1/(2r)` | just getting positioned |
| **Total average access time** | `Ts + 1/(2r) + b/(rN)` | the whole job |

> 🧠 **Memory hook "SeeR-Lat-Trans":** **See**k → ½ **R**ev (latency) → **Trans**fer (b/rN). The only piece you compute from RPM is the latency = half of one revolution.

> ⚠️ **Exam trap (the #1 error):** `r` is rev per **SECOND**. Given 7200 RPM, you *must* convert: `r = 7200/60 = 120 rev/s`. One full revolution = `1/120 s = 8.33 ms`; average latency = half of that = **4.17 ms**. The two classic mistakes are (1) forgetting to halve for latency, and (2) leaving `r` in RPM.

> ✍️ **Check yourself:** A drive spins at 10,000 RPM. What's its average rotational latency?
> <details><summary>Reveal answer</summary>r = 10000/60 = 166.7 rev/s. One revolution = 1/166.7 = 6.0 ms. Average latency = 6.0 / 2 = <b>3.0 ms</b>.</details>

---

## 4. ⭐ RAID — many disks pretending to be one

One disk has two problems: it can be slow (only one arm), and if it dies, your data dies with it. **RAID** (Redundant Array of Independent Disks) fixes both by **ganging several physical disks together** so the operating system sees them as **one logical drive**.

There are three tricks RAID can use (and the different "levels" are different mixtures of them):

- **Striping** — chop your data into pieces and spread them across the disks, so several disks can work **at the same time** → faster. (Used by almost every level except pure mirroring.)
- **Mirroring** — keep a **full duplicate copy** on a second disk. If one dies, the copy survives.
- **Parity** — store some clever **redundant "checksum" info** so that if a disk dies, you can **rebuild** what was on it from the others. Cheaper than a full copy.

> 📌 **Crucial point:** the 7 levels (0–6) are just **different designs**, **not a ranking**. RAID 6 is **not** "better than" RAID 0 — they're for different jobs. Don't think bigger number = better.

**Two ways the disks coordinate:** **Parallel access** (RAID 2, 3 — the disks all spin in lockstep and every disk helps with every request, using tiny strips) vs **Independent access** (RAID 4, 5, 6 — each disk can handle a separate request, using larger strips). You mainly need this to tell the families apart.

### The picture of the three core ideas

```text
  STRIPING (RAID 0)        MIRRORING (RAID 1)       PARITY (RAID 5)
  D0|D1|D2|D3              D0|D0'  D1|D1'           D0|D1|D2|P
   →  spread, no copy       →  full duplicate        →  parity rotates across disks
```

In words: RAID 0 just scatters data with no safety net. RAID 1 keeps a twin of everything. RAID 5 keeps a parity block and rotates *which* disk holds it.

### RAID 0–6 at a glance (Stallings Tables 7.3 / 7.4)

In the table, `N` = the number of disks' worth of *actual data* (not counting the redundancy disks).

| Level | What it does | Min disks | Usable capacity | Survives | Write penalty | Notes / where it's used |
|---|---|---|---|---|---|---|
| **0** | Striping, **no redundancy** | 2 | N (100%) | **0 disks** | none | Fastest, but **any single failure loses everything**. Video editing, raw bandwidth. |
| **1** | **Mirroring** (full copy) | 2 | N/2 (50%) | ≥1 (a whole mirror set) | none | No parity maths, just copy; expensive (half your space gone). High availability / accounting. |
| **2** | Bit-level + **Hamming** error code | N + m (m grows like log N) | varies | 1 | yes | Parallel access, tiny strips. **Never used commercially.** |
| **3** | **Bit-interleaved parity** | N + 1 | N/(N+1) | 1 | yes | One parity disk; parallel access; great transfer rate. |
| **4** | **Block-interleaved parity** | N + 1 | N/(N+1) | 1 | **high** (the parity disk is a bottleneck) | Independent access. **Never used commercially.** |
| **5** | **Block parity, DISTRIBUTED** | N + 1 | N/(N+1) | 1 | moderate | Parity spread around all disks → no bottleneck. **Most versatile**; file/DB/web servers. |
| **6** | **Dual distributed parity** | N + 2 | N/(N+2) | **2 disks** | **highest** (two parity writes) | Two parity calcs; mission-critical, super-high availability. |

> 🧠 **Memory hook for overhead:** **"0 = None, 1 = a Clone, 3/4/5 = one-for-the-team, 6 = two-for-the-team."** That tells you how many disks' worth you give up to redundancy.

> ⚠️ **Exam trap — RAID 4 vs 5:** They're almost identical (both use one block of parity per stripe, both survive one failure). The *only* difference: RAID 4 dumps **all** parity onto **one dedicated disk** (that disk becomes a write bottleneck), while RAID 5 **spreads** parity across all disks (no bottleneck). That's why **RAID 5 wins** in practice and RAID 4 isn't used.

> ⚠️ **Exam trap — RAID 0 has NO redundancy.** The "0" and the scary word "array" make people assume it's fault-tolerant. It's the **least** reliable setup of all — because *any one* of the N disks failing kills the whole array, it actually fails **more often** than a single disk would.

### The "write penalty" — slowly

When you do a small write on a parity level (4 or 5), you can't just write the new data — you also have to **update the parity** so it still matches. To do that you need **four disk operations**:

```text
  1. READ  the old data strip      ┐
  2. READ  the old parity strip    ┘  → use these to compute the NEW parity
  3. WRITE the new data strip      ┐
  4. WRITE the new parity strip    ┘
```

So one logical write = **2 reads + 2 writes**. That's the "write penalty." (RAID 1 has **no** write penalty — it has no parity to recompute, it just copies the data to the mirror.)

> ✍️ **Check yourself:** Name the four operations in a RAID 4/5 small write.
> <details><summary>Reveal answer</summary>Read the old data strip + read the old parity strip → compute the new parity → write the new data strip + write the new parity strip. That's <b>2 reads + 2 writes</b> = the write penalty.</details>

> ✍️ **Check yourself:** Why does RAID 6 have the *highest* write penalty?
> <details><summary>Reveal answer</summary>It keeps <b>two</b> independent parity blocks (called P and Q) on different disks, so every write has to recompute and write <i>both</i> of them — even more work than RAID 5's single parity. The reward: it survives <b>two</b> disks failing at once.</details>

---

## 5. Solid-State Drives (SSD / flash)

An SSD has **no moving parts at all** — no spinning platter, no arm. It stores data in **NAND flash** memory chips (the same family as a USB stick, but bigger and faster). Because nothing has to physically move, there's no seek and no rotational latency — data comes back almost instantly.

Compared to a hard disk, an SSD is **faster, quieter, cooler, tougher, and uses less power**, but it **costs more per gigabyte** and — importantly — **each flash cell can only be written a limited number of times** before it wears out.

### SSD vs HDD (Stallings Table 7.5)

| Aspect | SSD (NAND flash) | HDD (magnetic) |
|---|---|---|
| Moving parts | **None** (electronic) | Yes (spinning platters + arm) |
| Speed (IOPS / latency) | **High, low latency** | Lower — pays mechanical seek + latency |
| File copy/write speed | 200–550 MB/s | 50–120 MB/s |
| Power draw | **2–3 W** (longer battery life) | 6–7 W |
| Noise / heat | Quiet, cool | Audible, warmer |
| Toughness / lifespan | Shock-resistant; long lifespan* | Sensitive to bumps |
| Capacity (laptop) | ≤ ~1 TB (4 TB on desktop) | ~500 GB–2 TB (10 TB desktop) |
| Cost | ~$0.20/GB | ~$0.03/GB (much cheaper) |

\* *but each flash cell has a finite number of erase/write cycles — see below.*

### Two quirks of flash you must understand

1. **It slows down as it fills up.** Flash can't overwrite a single byte in place — it can only erase and rewrite a **whole block** at a time. So to change a little data, the controller reads the whole block into a RAM buffer, **erases the entire flash block**, then writes it back (read → modify → erase → write). The fuller the drive, the more of this expensive shuffling is needed.

2. **It wears out.** Every flash cell dies after a certain number of writes.

**How drives fight back:**
- **Cache front-end** — put a cache in front of the flash to **group and delay** writes, so the flash gets written less often.
- **Wear leveling** — an algorithm that **spreads writes evenly across all cells**, so no single block gets hammered and dies early.
- **Bad-block management** — detect and **retire** worn-out blocks.
- Drives also **estimate their remaining lifetime** so the system can see failure coming.

> 🧠 **Memory hook:** **Flash wears out → "level the wear."** Wear leveling = rotating your car tyres so they all wear down together, instead of one going bald first.

> ⚠️ **Exam trap:** SSDs are **not** "indestructible" or "infinitely durable." They beat HDDs on shock and vibration (no moving parts), but each flash cell has **limited write cycles** — that's exactly why wear leveling exists. Don't confuse "tough against bumps" with "unlimited writes."

---

## 6. Optical memory (CD, DVD, Blu-ray)

An optical disc stores data as microscopic bumps. A **laser** shines on the spinning disc: a tiny dip (a **pit**) **scatters** the light away, while a flat area (a **land**) **reflects** it straight back. The drive senses "reflected vs not" and reads out the 0s and 1s.

A factory **CD-ROM** is **stamped** in bulk from a laser-cut master, then coated with reflective aluminium or gold plus a protective acrylic layer — cheap to mass-produce, can't be changed. Discs *you* can write use a different trick:
- **Write-once (CD-R)** uses a **dye layer** that a laser darkens permanently — you can burn it once. ("WORM" = Write Once, Read Many.)
- **Rewritable (CD-RW)** uses a **phase-change** material that the laser can flip between two states — **amorphous (dull)** and **crystalline (shiny)** — over and over.

### Optical products (Stallings Table 7.6)

| Product | Erasable? | Capacity | Notes |
|---|---|---|---|
| **CD** | No | 60+ min audio | 12-cm digitized audio disc |
| **CD-ROM** | No | **> 650 MB** | computer data; rugged, with error correction |
| **CD-R** | Write **once** | ~650 MB | dye layer; WORM (write-once-read-many) |
| **CD-RW** | **Rewritable** | ~650 MB | phase-change material |
| **DVD-ROM** | No | up to **17 GB** (double-sided, dual-layer) | digitized compressed video + data; 8/12 cm |
| **DVD-R** | Write once | single-sided only | |
| **DVD-RW** | Rewritable | single-sided only | |
| **Blu-ray** | depends | **25 GB / layer / side** | **405-nm blue-violet** laser → tighter pits → more data |

The pattern that explains all of this: **a shorter-wavelength (bluer) laser can be focused onto smaller pits**, and smaller pits packed closer together means **more data per disc**. That's the whole story of CD → DVD → Blu-ray.

> 🧠 **Memory hook:** **Shorter wavelength → smaller pits → more data.** CD (780 nm infrared) → DVD (650 nm red) → **Blu-ray (405 nm blue-violet)**. Bluer laser = denser disc.

> ⚠️ **Exam trap:** CD-ROM **advantages** = cheap to mass-produce + removable/archival. **Disadvantages** = read-only (can't update it) and **access time much slower than a magnetic disk**.

> ✍️ **Check yourself:** What physical difference lets Blu-ray hold ~25 GB vs DVD's ~4.7 GB per layer?
> <details><summary>Reveal answer</summary>A shorter-wavelength <b>405-nm blue-violet laser</b> can focus on smaller pits packed more densely, raising the areal data density.</details>

---

## 7. Magnetic tape

Tape is a long flexible polyester ribbon coated with the same magnetizable material as a disk — the read/write physics is identical. The big difference: tape is **sequential access**. To reach data in the middle, you have to **wind the tape to it**, like fast-forwarding a cassette. That makes random access terrible, but tape is incredibly **cheap per terabyte and very dense**, which is perfect for **backups and long-term archives** (think LTO tape libraries).

```text
  ◄── tape motion
  track 0 ████ gap ██████ gap ███      ← serial recording: bits along each track
  track 1 ████ gap ██████ gap ███      ← multiple PARALLEL tracks run lengthwise
  track 2 ████ gap ██████ gap ███
          └ physical record (block) ┘
                └ inter-record gap (separates blocks) ┘
```

**Reading the picture:** data is laid down as a stream of bits along each track (**serial recording**), with several tracks side by side running the length of the tape. Data is grouped into **blocks (physical records)** with **inter-record gaps** between them so the drive can find block boundaries.

- The **LTO** family (Table 7.7) is the modern standard: **LTO-8 reaches 32 TB compressed** at 1.18 GB/s; newer generations add features like WORM, encryption, and partitioning.

> 🧠 **Memory hook:** **Tape = "wait in line."** Sequential, so brilliant $/TB and density for archives, hopeless for random access.

---

## ✅ You now understand…

Take a breath — here's everything in plain words:

1. **External memory** = secondary storage: slow but huge, cheap, and **non-volatile** (keeps data with the power off). It's the bottom of the memory ladder.
2. A **hard disk** = spinning **platters** coated in magnetic material, read/written by a floating **head**. Data sits in **tracks** (rings), **sectors** (smallest block, 512 or 4096 B), and **cylinders** (same track on all surfaces — free, no seek).
3. **CAV** puts the same sectors on every track (wastes the roomy outer tracks); **MZR** puts more sectors on outer tracks (more capacity, used by real drives).
4. **Disk access time = seek + rotational latency + transfer = Ts + 1/(2r) + b/(rN)**, with `r = RPM/60`. For small reads, the **positioning (seek + latency) dominates** — transfer is tiny.
5. **RAID** gangs disks into one logical drive using **striping** (speed), **mirroring** (copy), and **parity** (rebuild info). Levels 0–6 are *designs, not a ranking*: 0 = no safety, 1 = full clone, 5 = distributed parity (the versatile workhorse), 6 = double parity (survives two failures). The **write penalty** on 4/5 = 2 reads + 2 writes.
6. **SSD** = flash, no moving parts: fast, tough against bumps, low power, but pricier and with **finite writes** → **wear leveling**, caching, bad-block management.
7. **Optical:** bluer/shorter-wavelength laser = denser disc (CD < DVD < Blu-ray). **Tape** = sequential, cheap archive.

If any of those feel shaky, re-read that section before moving on. Then do `exercises.md`, then `mcq.md`.

---

## 🎓 When you're revising for the exam

Everything above is the understanding. For the exam, examiners reward precise wording and clean numerical method. Keep these crisp:

- **Disk access-time drill (do it in this exact order every time):** (1) `r = RPM/60` (rev/**second**!), (2) latency = `1/(2r)` (half a rev), (3) transfer = `b/(rN)`, (4) add seek `Ts`. Work in seconds, convert to ms at the very end.
- **RAID mnemonic — "0 None · 1 Clone · 5 One-for-all · 6 Two-for-all":**
  - **0** = stripe, **no** redundancy (fastest, riskiest).
  - **1** = mirror/**clone** (50% capacity, no write penalty).
  - **5** = distributed parity, **one** disk of overhead, survives 1.
  - **6** = dual parity, **two** disks of overhead, survives 2.
  - **4 vs 5:** 4 = parity on one dedicated disk (bottleneck); 5 = parity spread out.
- **Min disks:** 0→2, 1→2, 3/4/5→ at least 3 (N+1 with N≥2), 6→ at least 4 (N+2).
- **Usable capacity:** 0 = N; 1 = N/2; 3/4/5 = N−1 disks; 6 = N−2 disks (× disk size).
- **Write penalty (RAID 4/5):** 2 reads + 2 writes (read old data + old parity → write new data + new parity).
- **Optical density chain:** wavelength ↓ ⇒ density ↑ (CD 780 → DVD 650 → Blu-ray 405 nm).
- **SSD red flags:** "limited writes" → **wear leveling**; "slows over time" → whole-block read-erase-write cycle.
- **Glass substrate "BRUSS"; "SeeR-Lat-Trans"; "Bluer laser = denser disc."**

### Worked example A — full disk access time (Stallings-style)

> **Given:** 7200 RPM drive; average seek `Ts` = 8 ms; `N` = 512 sectors/track × 512 B = 262,144 B per track; read a file of **2 sectors = 1024 B**.

**Step 1 — rotation speed `r`.** `r = 7200 / 60 = 120 rev/s`. One revolution = `1/120 = 8.333 ms`.

**Step 2 — average rotational latency `1/(2r)`.** `= 8.333 / 2 = 4.167 ms`.

**Step 3 — transfer time `b/(rN)`** with b = 1024, N = 262,144.
`T = 1024 / (120 × 262144) = 1024 / 31,457,280 = 3.255 × 10⁻⁵ s ≈ 0.0326 ms`.

**Step 4 — total average access time.**
`Ts + 1/2r + b/rN = 8 + 4.167 + 0.0326 ≈ 12.20 ms`.

> Insight: **seek + latency dominate** for small transfers (12.17 ms of positioning vs 0.03 ms of actual reading). That's exactly why sequential/batched I/O and SSDs win — they slash the positioning cost.

**Step 5 — read a whole track instead (b = N = 262,144 B).**
Transfer time = `N/(rN) = 1/r = 1/120 = 8.333 ms`. Total = `8 + 4.167 + 8.333 ≈ 20.5 ms` for the *entire* track — far more efficient per byte than reading scattered sectors.

### Worked example B — RAID capacity & fault tolerance

> **Scenario:** **6 disks of 4 TB each (24 TB raw)**. Compare RAID 0, 1, 5, 6.

| Config | Usable capacity | Overhead | Survives | Reasoning |
|---|---|---|---|---|
| RAID 0 | 6×4 = **24 TB** | 0% | 0 disks | pure stripe, no redundancy |
| RAID 1 (3 mirrored pairs) | **12 TB** | 50% | ≥1 (one per pair) | each pair duplicates data |
| RAID 5 | (6−1)×4 = **20 TB** | 1 disk (16.7%) | **1** | one disk's worth = parity |
| RAID 6 | (6−2)×4 = **16 TB** | 2 disks (33%) | **2** | two disks' worth = parity |

**For a "high-availability DB server with growth":** choose **RAID 5** for the best capacity/redundancy balance and good read rate, OR **RAID 6** if a second failure during the long rebuild of large disks is a real worry (survives 2 failures, at the cost of 4 TB more overhead and a heavier write penalty).

> ✍️ **Check yourself:** With 6×4 TB in RAID 6, two disks die at once. Is data lost?
> <details><summary>Reveal answer</summary>No — RAID 6 (N+2, dual distributed parity) survives <b>two</b> simultaneous failures. A <i>third</i> failure before repair (within the MTTR window) would lose data.</details>

---

## 🧷 One-Page Recap

- Disk = magnetizable platters; **track** (ring), **sector** (smallest block, 512/4096 B), **cylinder** (same track all surfaces, no seek).
- **CAV** = same sectors/track (wastes outer); **MZR** = more sectors on outer tracks (higher capacity, modern).
- **Access time = seek `Ts` + latency `1/2r` + transfer `b/rN`**, with `r = RPM/60`. Positioning dominates small reads.
- **RAID:** 0 stripe (no redundancy), 1 mirror (50%), 2 Hamming, 3 bit parity, 4 block parity (1 dedicated disk), 5 distributed parity (versatile), 6 dual parity (survives 2). Parity levels survive 1; RAID 6 survives 2.
- **SSD** = NAND flash, fast/durable/low-power but costlier and finite writes → **wear leveling**, cache, bad-block mgmt.
- **Optical:** CD-ROM 650 MB, DVD up to 17 GB, **Blu-ray 25 GB/layer (405 nm)**. ROM / R (once) / RW (phase-change).
- **Tape** = sequential, blocks + inter-record gaps; cheap archive (LTO up to 32 TB).

## 📚 Resources

- Stallings, *Computer Organization and Architecture*, 11e — **Chapter 7 (External Memory)**: https://www.pearson.com/en-us/subject-catalog/p/computer-organization-and-architecture/P200000003520
- Neso Academy — Secondary Storage / Hard Disk & RAID: https://www.youtube.com/c/nesoacademy/playlists
- Gate Smashers — RAID & Disk (Operating System / COA playlists): https://www.youtube.com/c/GateSmashers/playlists
- GeeksforGeeks — RAID (Redundant Arrays of Independent Disks): https://www.geeksforgeeks.org/raid-redundant-arrays-of-independent-disks/
- GeeksforGeeks — Disk access time / structure: https://www.geeksforgeeks.org/structure-of-magnetic-disk/
- TutorialsPoint — Computer Organization (Secondary Storage / RAID): https://www.tutorialspoint.com/computer_organization_and_architecture/index.htm
