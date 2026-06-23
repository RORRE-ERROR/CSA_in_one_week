# Chapter 06 — External Memory · Quick Self-Test (15 questions)

> 🌱 **How to use this.** Once you've read `notes.md` and tried `exercises.md`, use these 15 to check what stuck. Decide your answer (jot A/B/C/D) **before** opening the explanation — the explanations tell you *why* in plain words, which is what actually sticks.
>
> Don't stress about your score the first time. Re-take it the day before the exam and aim for 14–15.

---

**Q1.** The set of all tracks at the same radius across every platter surface is called a:
- A) Sector
- B) Cylinder
- C) Zone
- D) Cluster

**Q2.** Under Constant Angular Velocity (CAV), bit density is highest on the:
- A) Outermost track
- B) Innermost track
- C) Middle tracks
- D) Density is uniform everywhere

**Q3.** A disk spins at 12,000 RPM. Its average rotational latency is approximately:
- A) 2.5 ms
- B) 5.0 ms
- C) 8.33 ms
- D) 4.17 ms

**Q4.** Average rotational latency for a disk rotating at `r` rev/s is given by:
- A) `1/r`
- B) `1/(2r)`
- C) `2r`
- D) `b/(rN)`

**Q5.** A 7200-RPM drive (r = 120 rev/s) has 500,000 bytes per track. Transfer time to read 50,000 bytes is closest to:
- A) 0.83 ms
- B) 8.33 ms
- C) 0.42 ms
- D) 4.17 ms

**Q6.** Which RAID level uses striping but provides **no** redundancy?
- A) RAID 1
- B) RAID 5
- C) RAID 0
- D) RAID 6

**Q7.** With **6 disks of 2 TB** in RAID 6, the usable capacity is:
- A) 12 TB
- B) 10 TB
- C) 8 TB
- D) 6 TB

**Q8.** The key difference between RAID 4 and RAID 5 is:
- A) RAID 5 has no parity
- B) RAID 4 mirrors data; RAID 5 stripes it
- C) RAID 4 keeps parity on one dedicated disk; RAID 5 distributes parity across all disks
- D) RAID 5 tolerates two disk failures

**Q9.** A single small write in RAID 4/5 requires how many disk operations (the "write penalty")?
- A) 1 write
- B) 2 writes only
- C) 2 reads + 2 writes
- D) 4 reads + 4 writes

**Q10.** Which RAID level can survive **two** simultaneous disk failures?
- A) RAID 1
- B) RAID 5
- C) RAID 6
- D) RAID 0

**Q11.** RAID 2 achieves redundancy using:
- A) Mirroring
- B) A Hamming error-correcting code
- C) Block-interleaved distributed parity
- D) Dual parity

**Q12.** Which technique evenly distributes writes across flash cells to prolong SSD life?
- A) Bad-block management
- B) Wear leveling
- C) Striping
- D) Phase change

**Q13.** Blu-ray achieves higher density than DVD primarily because it uses:
- A) A 405-nm blue-violet laser (shorter wavelength)
- B) Magnetic recording
- C) More platters
- D) A 780-nm infrared laser

**Q14.** A CD-RW achieves rewritability using:
- A) A dye layer changed once
- B) Stamped pits
- C) A phase-change material (amorphous vs crystalline)
- D) Magnetoresistive heads

**Q15.** On magnetic tape, contiguous data blocks (physical records) are separated by:
- A) Sectors
- B) Cylinders
- C) Inter-record gaps
- D) Parity strips

---

## Answers — with the *why*

<details><summary>Q1</summary>**B) Cylinder.** Stack up the same-numbered track on every surface and you get a cylinder — the arm is already in place, so reading it needs no movement (no seek). A sector is one arc of a track; a zone is the MZR grouping of tracks.</details>

<details><summary>Q2</summary>**B) Innermost track.** CAV puts the same number of bits on every track, and the inner track is the shortest circle — same bits squeezed into the least space = highest density. (MZR is what makes density roughly even.)</details>

<details><summary>Q3</summary>**A) 2.5 ms.** Convert first: r = 12000/60 = 200 rev/s. One spin = 1/200 = 5 ms. Average latency is half a spin = **2.5 ms**.</details>

<details><summary>Q4</summary>**B) `1/(2r)`.** On average you wait half a revolution; one revolution takes 1/r, so half is 1/(2r). (Option D is the transfer-time formula, not latency.)</details>

<details><summary>Q5</summary>**A) 0.83 ms.** Transfer = b/(rN) = 50000/(120 × 500000) = 50000/60,000,000 = 8.33×10⁻⁴ s = **0.833 ms**. Quick sanity check: b is 1/10 of N, so it's 1/10 of a revolution = 8.33 ms / 10.</details>

<details><summary>Q6</summary>**C) RAID 0.** Pure striping, nonredundant — fast, but any single drive failing loses *all* the data.</details>

<details><summary>Q7</summary>**C) 8 TB.** RAID 6 spends two disks' worth on parity: (6−2) × 2 TB = **8 TB** usable.</details>

<details><summary>Q8</summary>**C)** Both stripe data and both survive one failure — the *only* difference is *where* parity lives. RAID 4 dumps all parity on one dedicated disk (which becomes a write bottleneck); RAID 5 spreads parity round-robin across every disk, killing the bottleneck. That's why RAID 5 is used and RAID 4 isn't.</details>

<details><summary>Q9</summary>**C) 2 reads + 2 writes.** To keep parity correct: read the old data strip + read the old parity strip → compute the new parity → write the new data strip + write the new parity strip.</details>

<details><summary>Q10</summary>**C) RAID 6.** Its dual distributed parity (N+2) can rebuild two missing disks, so it survives two simultaneous failures. RAID 5 survives one; RAID 0 survives none.</details>

<details><summary>Q11</summary>**B) Hamming ECC.** RAID 2 uses a parallel-access, bit-level Hamming code (corrects single-bit, detects double-bit errors). It's never used commercially.</details>

<details><summary>Q12</summary>**B) Wear leveling.** It spreads writes evenly so no flash block gets hammered and dies early (like rotating tyres). Bad-block management retires already-dead blocks; striping and phase-change are unrelated to flash wear.</details>

<details><summary>Q13</summary>**A) 405-nm blue-violet laser.** A shorter wavelength focuses on smaller, denser pits → ~25 GB/layer vs DVD's ~4.7 GB. (780 nm is the *CD* laser, so D is wrong.)</details>

<details><summary>Q14</summary>**C) Phase-change material.** CD-RW flips between amorphous (dull, poor reflectivity) and crystalline (shiny, good reflectivity) states, so it can be rewritten. CD-R uses a one-time dye layer.</details>

<details><summary>Q15</summary>**C) Inter-record gaps.** On tape, contiguous blocks (physical records) are separated by inter-record gaps, and access is sequential (you wind to the data).</details>

---

> 📊 **Scored low?** Totally normal on a first pass — go back to the matching `notes.md` section for anything you missed, then retry. **Scored 13+?** You've got External Memory down.
