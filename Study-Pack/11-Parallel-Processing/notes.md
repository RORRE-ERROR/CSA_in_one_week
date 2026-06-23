# Chapter 11 — Parallel Processing

> 🌱 **Starting from zero?** Perfect. This chapter is about one simple idea: *instead of building one super-fast worker, use lots of ordinary workers at the same time.* We'll build the whole picture with everyday comparisons first, then attach the proper technical names. You don't need anything from earlier chapters beyond "a CPU is the brain and memory is the working desk." Read top to bottom, slowly.
>
> ⏱️ Take about 2 hours. Two topics here — **Flynn's taxonomy** and the **MESI protocol** — show up on almost every exam, so we go extra slow on those.

---

## 🤔 First, why does this chapter exist?

For decades, the way to make a computer faster was simple: make the single processor run faster (a higher clock speed). But that hit a wall — push the clock too high and the chip gets too hot, uses too much power, and you run out of clever tricks to squeeze more work out of one instruction stream.

So engineers changed strategy: **if one worker can't go faster, hire more workers.** That's *parallel processing* — many processors working at once. The catch is that workers who share things (like a shared desk, or shared notes) can step on each other's toes. Most of this chapter is about **how the processors are connected** and **how we stop them from confusing each other** when they share memory.

By the end you'll be able to, in your own words:
- sort any computer into one of **Flynn's four boxes** (SISD, SIMD, MISD, MIMD),
- tell apart machines that **share memory** (tightly coupled) from ones that **don't** (loosely coupled),
- describe an **SMP** (a box full of equal processors),
- explain the **cache-coherence problem** and how the **MESI protocol** fixes it,
- compare **SMP vs cluster vs NUMA**.

---

## 🗺️ The big picture before we dive in

Here's the family tree. Everything in this chapter hangs off one question: *do the processors share their memory, or not?*

```text
                    PARALLEL PROCESSING
                            │
        ┌───────────────────┴────────────────────┐
   TIGHTLY COUPLED                          LOOSELY COUPLED
   (share main memory)                      (own memory, msg-passing)
        │                                         │
   ┌────┴─────┐                              ┌─────┴─────┐
  SMP        NUMA                          CLUSTERS    Distributed
 (UMA)      (CC-NUMA)                      (whole nodes + interconnect)
```

- **Tightly coupled** = the processors all share *one* pool of memory (like coworkers sharing one big desk). Examples: **SMP** and **NUMA**.
- **Loosely coupled** = each processor (really, each whole computer) has its *own* memory and they talk by sending messages (like separate offices emailing each other). Example: **clusters**.

The one headache that keeps coming back in every shared-memory design is **cache coherence** (keeping everyone's private copies in agreement). On a shared bus we fix it with the **MESI** protocol; on bigger NUMA systems we use **directory** protocols. Hold that thought — we'll get there.

---

## 1. Flynn's Taxonomy — sorting computers into four boxes

Imagine you want to label every type of computer ever built. Back in 1972 a man named **Flynn** found a brilliantly simple way to do it. He asked just two yes/no-ish questions:

1. **How many different instruction streams are running?** (An *instruction stream* is just "a list of commands being followed." One worker following one to-do list = one instruction stream.)
2. **How many different data streams are being worked on?** (A *data stream* is "the batch of data being processed.")

Each question can be answered "**Single**" (one) or "**Multiple**" (many). Two questions × two answers = **four boxes**:

```text
                    DATA STREAMS
                Single            Multiple
              ┌─────────────┬──────────────────┐
   Single     │   SISD      │      SIMD         │
  INSTRUCTION │ uniprocessor│ vector/array proc │
   STREAMS    ├─────────────┼──────────────────┤
   Multiple   │   MISD      │      MIMD         │
              │ (none built)│ SMP, cluster,NUMA │
              └─────────────┴──────────────────┘
```

Reading the names is easy once you decode them: the first two letters are about **I**nstructions (**SI** = single instruction, **MI** = multiple instruction), the last two are about **D**ata (**SD** = single data, **MD** = multiple data).

Now the four boxes in plain English, each with an analogy:

| Class | Streams (I × D) | Plain-English picture | What it does | Examples |
|-------|-----------------|------------------------|--------------|----------|
| **SISD** | 1 × 1 | **One cook, one recipe, one dish.** | One processor follows one instruction stream on one data stream | Classic **uniprocessor** (an old single-core PC) |
| **SIMD** | 1 × N | **One boss shouting one order; many workers all do it at once, in lockstep, each on their own pile.** | One instruction controls **lockstep** execution across many processing elements | **Vector & array processors**, GPUs |
| **MISD** | N × 1 | **Many cooks each following a different recipe, but only one dish passed down the line.** Weird and impractical. | A data sequence flows through processors each running a *different* instruction sequence | **Never commercially built** |
| **MIMD** | N × N | **A whole kitchen of independent cooks, each with their own recipe and their own ingredients.** | Many processors run *different* instructions on *different* data | **SMP, clusters, NUMA** |

Two things worth burning into memory:

- **MISD is the empty box.** Nobody builds real MISD machines. If an exam offers you a "real MISD product," it's almost always a trap (some textbooks mention systolic arrays or fault-tolerant lockstep machines as the *closest* analogy, but treat MISD as "the imaginary one").
- **A multicore CPU running different threads is MIMD, NOT SIMD.** This trips people up constantly. SIMD needs *one* instruction driving many data lanes **in lockstep**. Your 8-core laptop has 8 cores each doing their own thing → that's *multiple* instruction streams → **MIMD**.

And MIMD splits one level further by *how the processors share memory* (the family tree from earlier):
- **Tightly coupled** (shared memory): **SMP** (UMA) and **NUMA**.
- **Loosely coupled** (separate memory, message passing): **clusters**.

> 🧠 Memory hook: **"SI/MI" = instructions, "SD/MD" = data.** Read left→right: SISD (one-one, your laptop core), SIMD (one boss, many workers in lockstep — *vector*), MISD (many bosses, one data line — the *imaginary* one), MIMD (everyone independent — *real multicore/clusters*). Mnemonic: **"Sip a SIMD, MISD it, go MIMD"** — only **MISD** has no real product.

> ⚠️ Exam trap: A **multicore CPU running different threads** is **MIMD**, *not* SIMD. SIMD requires **one instruction** driving many data lanes in lockstep. Also: **MISD is the empty category** — if a question offers a "real example of MISD," it's a distractor (some texts cite systolic arrays / fault-tolerant lockstep as the closest analog).

> ✍️ Quick check: A GPU executing the same shader instruction across thousands of pixels is which class?
<details><summary>Answer</summary>SIMD — one instruction stream applied to many data elements simultaneously (lockstep).</details>

---

## 2. Tightly vs Loosely Coupled — sharing a desk vs separate offices

Stay with the workplace analogy. There are two ways to organise a team of processors:

- **Tightly coupled** = everyone shares **one big desk** (one shared main memory). To pass information, you just leave it on the shared desk and a coworker picks it up. Fast, but you can collide.
- **Loosely coupled** = everyone has their **own private office** with their own desk. To share, you **send a message** (email it across). No collisions over a shared desk, but communicating is more deliberate.

```text
TIGHTLY COUPLED (shared memory)        LOOSELY COUPLED (clusters)
┌────┐ ┌────┐ ┌────┐                   ┌──────┐   ┌──────┐
│P1  │ │P2  │ │P3  │                   │Node1 │   │Node2 │
└─┬──┘ └─┬──┘ └─┬──┘                   │P+M+IO│   │P+M+IO│
  └──────┼──────┘                      └──┬───┘   └──┬───┘
    SHARED MAIN MEMORY                    └─ network ─┘
   (one address space)                  (message passing, no shared MM)
```

The diagram: on the left, three processors all wired to **one shared main memory** (one address space — one big shared desk). On the right, two **nodes**, where each node is a *whole computer* (its own Processor + Memory + I/O), and they talk over a **network** by passing messages.

| Property | Tightly coupled (SMP/NUMA) | Loosely coupled (cluster) |
|----------|----------------------------|---------------------------|
| Memory | Shared main memory, one address space | Each node has its **own** memory |
| Communication | Loads/stores to shared memory | **Message passing** over interconnect |
| Coupling | Processors inside one box | Whole independent computers (nodes) |
| Coherence issue | Yes — needs cache-coherence protocol | No shared cache lines to keep coherent |

The big takeaway: **sharing memory is convenient but creates the coherence problem; not sharing avoids it but means you have to pass messages.**

---

## 3. Symmetric Multiprocessors (SMP) — a box full of equal workers

An **SMP** is the simplest tightly-coupled design. "Symmetric" just means **all the processors are equals** — no boss processor, no special processor. Like a kitchen of equally-skilled cooks, any of whom can do any job.

Formally, an **SMP** is a standalone computer with these characteristics:
- Two or more **similar** processors of comparable capability.
- Processors **share** the same main memory and I/O facilities, connected by a **bus** (the shared road/hallway between them).
- All processors share access to I/O devices (same channels, or different channels to the same device).
- All processors can perform the **same functions** (that's the "symmetric" part).
- Controlled by a **single integrated OS** managing all processors and resources (one manager runs the whole kitchen).

### SMP Organisation (block diagram)

```text
   ┌────────┐   ┌────────┐   ┌────────┐
   │ CPU 1  │   │ CPU 2  │   │ CPU n  │
   │ +cache │   │ +cache │   │ +cache │   ← each CPU has its own L1/L2 cache
   └───┬────┘   └───┬────┘   └───┬────┘
       │            │            │
 ══════╪════════════╪════════════╪═══════  SHARED SYSTEM BUS
       │            │            │
   ┌───┴────┐   ┌───┴────┐   ┌───┴────┐
   │  Main  │   │  I/O    │   │  I/O   │
   │ Memory │   │ subsys  │   │ adapter│
   └────────┘   └────────┘   └────────┘
```

Reading it: several CPUs across the top, each with its **own private cache** (a small fast personal notepad). They all hang off **one shared system bus** (the central road). At the bottom, the shared **main memory** and **I/O** they all reach over that bus. Notice everyone uses the *same single road* — remember that, because it's both the strength and the weakness.

### Advantages of the bus organisation
- **Simplicity** — the simplest multiprocessor approach (one shared road, easy to understand).
- **Flexibility** — easy to expand: just attach more processors to the bus.
- **Reliability** — the bus is a *passive* medium (just wires); one attached device failing shouldn't crash the whole system.

### Disadvantages
- **Performance** is the main drawback: **all** memory references cross the **common bus**, so the whole system's throughput is capped by the **bus cycle time**. (One road, everybody driving on it → traffic jam.)
- **The fix:** give **each processor its own cache** so it doesn't have to drive to memory so often. But this creates a brand-new headache — the **cache-coherence problem** (next section). Coherence is handled **in hardware**, not by the OS.

### SMP OS design considerations
The single OS has to juggle several things at once:
- **Simultaneous concurrent processes** — OS code must be **reentrant** (safe to run by several processors at once); tables protected against deadlock.
- **Scheduling** — any processor may schedule work; avoid conflicts.
- **Synchronization** — mutual exclusion + event ordering for shared address spaces (stop two processors clobbering the same data).
- **Memory management** — coordinate paging across processors for consistency.
- **Reliability / fault tolerance** — degrade gracefully if a processor fails.

> ✍️ Quick check: Why does adding caches to an SMP both *help* and *hurt*?
<details><summary>Answer</summary>Helps: caches reduce bus traffic, raising performance. Hurts: copies of the same line in multiple caches can become inconsistent → the cache-coherence problem.</details>

---

## 4. Cache Coherence — the problem of out-of-date copies

Here's the trouble that caches cause. Imagine three coworkers each photocopy a shared document to their own desk. If one person scribbles a change on *their* copy, everyone else's copy is now **out of date** — but they don't know it.

Same with caches. When each CPU keeps its own copy of a shared memory line, a write in one cache makes the others **stale** (old, wrong).

### Coherence example

```text
Initial: X = 5 in main memory; no caches hold it.

Step 1  CPU A reads X   → A's cache: X=5,  B's cache: --,  MM: X=5   ✔ consistent
Step 2  CPU B reads X   → A: X=5,          B: X=5,         MM: X=5   ✔ consistent
Step 3  CPU A writes X=9 (write-back, no announce)
        → A: X=9,        B: X=5 (STALE!),  MM: X=5         ✘ INCOHERENT
```

Walking through it: both A and B grab their own copy of X (=5) — fine, everyone agrees. Then A changes its copy to 9 but keeps it in its own cache (write-back) **without telling anyone**. Now A thinks X=9, but B still thinks X=5, and main memory still says 5. If B reads X now, it gets the **wrong value**. That's *incoherence*.

The fix: a coherence protocol must, the moment A writes, either **invalidate** B's copy (tell B "throw yours away") or **update** it (tell B "here's the new value").

### Solutions overview

```text
CACHE COHERENCE SOLUTIONS
 ├─ SOFTWARE (compiler/OS)  → moves cost to compile-time; conservative → inefficient
 └─ HARDWARE (protocols)    → dynamic, run-time; transparent to programmer
      ├─ SNOOPY  (bus broadcast; each cache "snoops")
      │     ├─ WRITE-INVALIDATE  → on write, invalidate all other copies  ⇒ MESI
      │     └─ WRITE-UPDATE      → on write, broadcast new value to copies
      └─ DIRECTORY (central directory tracks who holds each line; used in NUMA)
```

Two broad families:

- **Software solutions** — lean on the compiler/OS to mark shared data as "don't cache this." Cheap on hardware, but the compiler has to play it safe and assume the worst → it's **conservative**, so it wastes cache opportunities → **inefficient**.
- **Hardware solutions (cache-coherence protocols)** — the hardware itself notices inconsistency **at run time, only when it actually happens** → better performance, and completely **invisible to the programmer**. Two styles:
  - **Snoopy** — picture each cache controller as a worker who **eavesdrops on the shared bus**. Whenever someone writes to a shared line, that write is **broadcast** on the bus; every other cache **snoops** (listens) and reacts. Perfect for **bus-based SMP** (everyone's already on the one road). Risk: too much snoop/broadcast chatter can eat the speed gains.
    - **Write-invalidate**: many caches can *read*, but only **one writer at a time**; on a write, **invalidate** every other copy, so the writer gets cheap exclusive access. This is the common one (used by x86) — **this is MESI.**
    - **Write-update (write-broadcast)**: instead of invalidating, **broadcast the new value** to all copies.
  - **Directory protocols** — a central **directory** (usually in the main-memory controller) keeps a list of *which caches hold each line*. Coherence requests go through this directory instead of being shouted to everyone. Scales much better for systems **without a single shared bus** — i.e. **NUMA**.

> ⚠️ Exam trap: **Snoopy = broadcast on a shared bus; Directory = central lookup, no broadcast.** Snoopy suits SMP (one bus); directory suits NUMA (many nodes where broadcast is too expensive).

---

## 5. MESI Protocol — the four states (read this twice)

This is the single most-tested topic in the chapter, so we'll go slowly. MESI is a write-invalidate snoopy protocol. The idea: tag **every cache line** with one of **four states**, and those tags let the caches coordinate without confusion. The four states are **M**odified, **E**xclusive, **S**hared, **I**nvalid.

Think of each cache line as a sticky note on your photocopy, telling you *how trustworthy and how private your copy is*:

- **M (Modified)** = "**I changed this and nobody else knows.**" My copy is the only correct one; memory itself is now out of date (dirty). Only I have it.
- **E (Exclusive)** = "**Only I have this, and it still matches memory.**" Clean, private. Nobody else has a copy, and I haven't changed it yet.
- **S (Shared)** = "**Several of us have this same clean copy.**" It matches memory; others *might* hold it too.
- **I (Invalid)** = "**My copy is junk — ignore it.**" No valid data here.

| State | Line valid? | Memory copy | Other caches may have it? | A write to this line… |
|-------|-------------|-------------|---------------------------|-----------------------|
| **M** Modified | Yes | **out of date** | **No** | does **not** go to bus |
| **E** Exclusive | Yes | valid | **No** | does **not** go to bus |
| **S** Shared | Yes | valid | **Maybe** | **goes to bus** & updates cache |
| **I** Invalid | **No** | — | Maybe | goes **directly** to bus |

The most important pair to understand: **E and M both mean "only I have this copy."** The only difference is whether I've *changed* it. E = clean (memory still agrees with me), M = dirty (memory is stale, my copy is the truth). This matters because if I'm in **E** and I decide to write, I can flip silently to **M with zero bus traffic** — nobody else has a copy to worry about. That's the entire reason the E state exists.

### MESI state-transition diagram (per cache line)

Below is the official diagram. It looks scary, but it's just "which sticky note do I switch to when something happens." There are two kinds of "something": **things this processor does** (its own reads and writes) and **things it overhears another processor doing** (snooped events).

```text
 Legend: RH=read hit  RMS=read miss(shared)  RME=read miss(exclusive)
         WH=write hit  WM=write miss  SHR=snooped read  SHW=snooped RWITM/write
 (UPPER = events caused by THIS processor;  lower-ish notes = bus-snooped events)

        ┌───────────────────────────────────────────────┐
        │                                               │
   RME  ▼                       WH                       │
 ┌──────────┐   WH          ┌──────────┐                 │
 │   INVALID├──────────────►│ MODIFIED │◄───┐            │
 │    (I)   │  WM (RWITM)   │   (M)    │    │ WH         │
 │          │──────────────►│          │    │            │
 └──┬───┬───┘               └──┬───┬───┘    │            │
    │   │ RMS                  │   │ SHR     │            │
    │   │                      │   │(→write  │            │
    │   ▼                      │   │ back,   │            │
    │ ┌──────────┐  SHW        │   │ →S)     │            │
    │ │ SHARED   │◄────────────┘   ▼         │            │
    │ │   (S)    │            ┌──────────┐   │            │
    │ │          │   WH ──────│EXCLUSIVE │───┘            │
    │ └──┬───────┘  (→M, inv  │   (E)    │  RH (stay E)   │
    │    │ RH(stay S)  others)└──┬───────┘                │
    │    │  SHW→I                │ RH (stay E)            │
    └────┴───────────────────────┴────────────────────────┘
   (any state) SHW (other CPU's RWITM) → I ;  SHR on M → write back, → S
```

In plain words, here's what the arrows are saying:
- From **Invalid**, a *read miss* takes you to **E** (if you're the only one) or **S** (if someone else has it); a *write miss* (which fires an **RWITM**, explained below) takes you straight to **M**.
- From **Exclusive**, a read keeps you in E; a *write* slides you silently to **M** (no bus).
- From **Shared**, a read keeps you in S; a *write* makes you shout on the bus to invalidate everyone else, then you go to **M**.
- From **Modified**, your own reads/writes keep you in M.
- **Snooped events** (overhearing others): if you're in **M** and you hear someone else read it, you **write your value back to memory** and drop to **S**; if you hear someone else *write* it (an RWITM), you go to **I** no matter what state you were in.

### Simplified transition rules (the part exams test)

| From | Event (this CPU) | To | Notes |
|------|------------------|----|----|
| I | Read miss, no other cache has it | **E** | sole copy, matches memory |
| I | Read miss, another cache has it | **S** | shared copy |
| I | Write miss (issues **RWITM**) | **M** | load then immediately modify; others invalidated |
| E | Read hit | E | stays |
| E | Write hit | **M** | silent, no bus |
| S | Read hit | S | stays |
| S | Write hit | **M** | broadcast → **invalidate** others, then modify |
| M | Read/Write hit | M | silent, no bus |
| any | **Snoop** another CPU's read (SHR) | M→S (write back) / E,S unaffected→S | supply data, downgrade |
| any | **Snoop** another CPU's RWITM/write (SHW) | **I** | invalidate own copy |

Key bus events explained:
- **Read miss** → the cache reads from memory and signals so others can snoop. If another cache holds the line as **Modified**, that cache writes its value back first and supplies the line.
- **Write miss** → fires an **RWITM** (*read-with-intent-to-modify*): "I'm reading this, but I'm about to change it, so everyone else throw your copies away." The line is loaded then marked **Modified**.
- **Write hit on S** → I share this line, so I must first **gain exclusive ownership**: signal the bus → other S copies go **I** → my S becomes **M**.
- **Write hit on E** → I'm already the only one, so just E→**M** (no bus needed).
- **Write hit on M** → already exclusive and dirty, so just update it.

> 🧠 Memory hook: **MESI = "Mine, Exclusively-mine, Shared, Invalid."** **M** = dirty & only mine; **E** = clean & only mine; **S** = clean & maybe others have it; **I** = useless. Only **M** and **S** can downgrade on a snoop; only **M** forces a write-back.

> ⚠️ Exam trap: **E and M both mean "only I have it."** Difference: **E is clean** (memory up-to-date, no write happened) and **M is dirty** (memory stale). A write hit on **E goes silently to M** (no bus traffic) — that's the whole point of having E.

---

## 6. Multithreading & Chip Multiprocessors — keeping a processor busy

There's a handy formula for how much work a processor gets done:

**MIPS rate = f × IPC** — where **f** = clock frequency (how fast the clock ticks) and **IPC** = average instructions completed per cycle. To go faster you boost either f or IPC.

**Multithreading** is a clever way to raise the work-per-cycle *without* adding more circuitry or burning more power: split the instruction stream into separate **threads** (independent strands of work) and run them in parallel, so when one thread is stuck waiting (say, for memory), another can use the idle hardware. It's like a single chef who, while a pot is boiling, chops vegetables for the next dish instead of standing around.

```text
EXPLICIT (separate, real threads — all commercial CPUs)
 ├─ Interleaved / FINE-GRAINED : switch thread every clock cycle; skip blocked thread
 ├─ Blocked / COARSE-GRAINED   : run a thread until a stall event, then switch
 ├─ Simultaneous (SMT)         : issue from MULTIPLE threads to a superscalar's units
 │                                in the SAME cycle  (e.g. Intel Hyper-Threading)
 └─ Chip Multiprocessing (CMP) : replicate whole processor on one chip (multicore);
                                  each core runs its own thread

IMPLICIT : multiple threads extracted from ONE sequential program,
           defined statically by the compiler or dynamically by hardware
```

In plain words:
- **Explicit** multithreading uses genuinely separate threads (every commercial CPU does this). Four flavours:
  - **Interleaved / fine-grained** — switch to a different thread *every clock cycle*; if a thread is blocked, skip it.
  - **Blocked / coarse-grained** — stick with one thread until it *stalls* (e.g. waiting on memory), then switch.
  - **Simultaneous (SMT)** — the powerful one: in the *same* cycle, issue instructions from *several* threads into a superscalar processor's many execution units (this is Intel's **Hyper-Threading**).
  - **Chip multiprocessing (CMP)** — just put *whole extra processors* on one chip (this is **multicore**); each core runs its own thread.
- **Implicit** multithreading is different: the threads are squeezed out of *one ordinary sequential program*, either by the compiler ahead of time (statically) or by the hardware on the fly (dynamically).

> ✍️ Quick check: Hyper-Threading lets two threads issue instructions to the same core's execution units in one cycle. Which approach?
<details><summary>Answer</summary>Simultaneous multithreading (SMT). Coarse-grained switches on stalls; fine-grained switches every cycle; SMT issues from several threads in the same cycle.</details>

---

## 7. Clusters — a team of whole computers pretending to be one

A **cluster** is a group of interconnected **whole computers** working together as one unified resource — they create the *illusion of a single machine*. Think of it as a team of separate, fully-capable employees coordinated to look like one super-employee. Each computer in the cluster is called a **node** (and a node can run perfectly well on its own). Clusters are the loosely-coupled alternative to SMP, aimed at **high performance + high availability**, which is why they're so popular for servers.

**Benefits:** absolute scalability · incremental scalability · high availability · superior price/performance.
(In plain words: you can build them very big, grow them a node at a time, keep running when a node dies, and you get a lot of power per dollar because nodes are ordinary computers.)

### Cluster configurations (by how they handle disks)

The different setups are mostly about *how the nodes share their disks and back each other up*:

| Method | Description | Benefit | Limitation |
|--------|-------------|---------|-----------|
| **Passive standby** | Secondary takes over if primary fails | Easy to implement | Costly — secondary idle |
| **Active secondary** | Secondary also processes work | Lower cost, uses spare | More complex |
| **Separate servers** | Each has own disks; data copied primary→secondary | High availability | High network/server overhead (copying) |
| **Servers connected to disks** | Cabled to shared disks but each owns its own; takeover on failure | Less overhead (no copying) | Needs RAID/mirroring |
| **Servers share disks** | Multiple servers access disks simultaneously | Low overhead, low downtime risk | Needs **lock manager**; RAID/mirroring |

(The progression is "spare sitting idle" → "spare doing work too" → "fully separate, copy the data" → "cabled to shared disks, take over on failure" → "all share the disks at once, but now you need a **lock manager** so two servers don't clobber the same file.")

---

## 8. NUMA / CC-NUMA — shared memory, but some of it is "far away"

One more shared-memory design. The key word is **access time** — how long it takes a processor to reach a piece of memory.

- **UMA (Uniform Memory Access)** — every processor reaches *all* memory in the **same** amount of time, no matter which region. Like an office where every filing cabinet is equally close to everyone. **SMP is UMA.**
- **NUMA (Nonuniform Memory Access)** — every processor can still reach all memory, but the time **depends on where the memory is**: your **local** memory (in your own node) is fast; **remote** memory (in another node) is slow because the request has to travel across the interconnect. Like having your own filing cabinet right next to you, but having to walk to another floor for someone else's.
- **CC-NUMA (Cache-Coherent NUMA)** — a NUMA system that also **keeps the caches coherent** across all nodes, using **directory** protocols (the central-lookup approach from Section 4).

```text
CC-NUMA ORGANIZATION
 NODE 0                         NODE 1
 ┌─────────────────┐           ┌─────────────────┐
 │ P P P + caches  │           │ P P P + caches  │
 │ Local memory M0 │◄──────────┤ Local memory M1 │
 │ Directory       │  inter-   │ Directory       │
 └────────┬────────┘  connect  └────────┬────────┘
          └────────── network ──────────┘
  access M0 from Node0 = FAST (local)
  access M0 from Node1 = SLOW (remote, crosses interconnect)
```

The diagram shows two nodes, each with its own processors, caches, **local memory**, and a **directory**. They're joined by an interconnect/network. The punchline at the bottom: Node 0 reaching its own M0 is **fast** (local); Node 1 reaching M0 is **slow** (remote — it has to cross the interconnect).

**Pros:** can reach **higher parallelism than SMP** without major software rewrites; each node's bus traffic stays manageable.
**Cons:** if too many accesses turn out to be **remote**, performance **falls apart**; it doesn't *transparently* behave like an SMP (the OS/apps may need changes to keep data local); and there are availability concerns.

### SMP vs Cluster vs NUMA — comparison

| Feature | **SMP** | **Cluster** | **NUMA / CC-NUMA** |
|---------|---------|-------------|--------------------|
| Coupling | Tightly coupled | Loosely coupled | Tightly coupled |
| Memory | Single shared (**UMA**) | Each node private | Shared, **nonuniform** access |
| Communication | Shared memory via **bus** | **Message passing** / interconnect | Shared memory over interconnect |
| Address space | Single | Multiple (one per node) | Single (global) |
| Coherence | **MESI** (snoopy) | Not needed (no shared lines) | **Directory** (CC-NUMA) |
| Scalability | Limited by bus | High (add nodes) | Higher than SMP |
| OS | Single integrated OS | OS per node + cluster middleware | Modified single OS |
| Availability | Lower | **High** (node failover) | Moderate |

> ⚠️ Exam trap: **NUMA still has a single shared address space** (like SMP) — what's "non-uniform" is the *access time*, not the addressing. Clusters, by contrast, have **separate** address spaces and use message passing.

---

## ✅ You now understand…

Take a breath. Here's the whole chapter in plain words:

1. **Why parallel processing exists:** one processor can't keep getting faster (heat/power limits), so we run **many processors at once**.
2. **Flynn's taxonomy** sorts machines by instruction streams × data streams into four boxes: **SISD** (one cook), **SIMD** (one order, many lockstep workers — GPU/vector), **MISD** (the imaginary empty box), **MIMD** (everyone independent — SMP/cluster/NUMA). *Multicore = MIMD; lockstep = SIMD.*
3. **Tightly coupled** = share one memory (SMP, NUMA); **loosely coupled** = own memory + message passing (clusters).
4. **SMP** = a box of equal processors sharing memory over one bus, run by one OS. The bus is simple/flexible/reliable but **bandwidth-limited** → add caches → which creates the **coherence problem** (fixed in hardware).
5. **Cache coherence:** private copies go stale when someone writes; fix by **invalidate** or **update**, via **snoopy** (broadcast on a bus) or **directory** (central lookup) protocols.
6. **MESI**: four sticky-note states — **M** (dirty, only mine), **E** (clean, only mine), **S** (shared clean), **I** (junk). Write miss fires **RWITM**; writing a Shared line invalidates the others; only one M or E exists at a time.
7. **Multithreading** keeps a processor busy: explicit (fine-grained / coarse-grained / SMT / CMP) vs implicit (threads from one program).
8. **Clusters** = whole computers as one resource (high availability + scalability). **NUMA** = one shared address space but **non-uniform access time** (local fast, remote slow); **CC-NUMA** keeps caches coherent with a directory.

If MESI or Flynn still feels shaky, re-read those sections, then do `exercises.md` and `mcq.md`.

---

## 🎓 When you're revising for the exam

Everything above is the understanding. For the exam, examiners reward precise wording — keep these crisp:

- **Flynn in 5 sec**: count instruction streams, count data streams → pick the cell. **Multicore = MIMD**, **lockstep = SIMD**, **MISD = the trick answer** (never built).
- **MESI traces**: draw a tiny table, one column per cache. Apply two rules — *my action* (read/write, hit/miss) and *snoop* (someone else **reads** → an M holder **writes back & →S**; someone else **writes/RWITM** → everyone else **→I**). Enforce the **invariant**: at most **one** cache in **M or E** at a time; if any cache is **M**, memory is stale.
- **Coherence protocol picker**: bus + few CPUs → **snoopy/MESI**; many nodes/NUMA → **directory**.
- **SMP vs cluster**: shared memory + one OS + one box = SMP; whole computers + network + per-node OS = cluster.
- **UMA vs NUMA**: same access time everywhere = UMA (SMP); local-fast / remote-slow = NUMA.
- **E vs M**: both "only mine"; **E clean** (silent write→M), **M dirty** (forces write-back on snoop).

> 🧠 Mnemonics: **SI/MI = instructions, SD/MD = data; MISD = the imaginary one.** **MESI = Mine-dirty, Exclusive-clean, Shared, Invalid.** **UMA = Uniform = SMP; NUMA = local-fast/remote-slow.** **Snoopy = broadcast on bus; Directory = central lookup.**

**Likely exam question (worked example):** *"Trace MESI for two cores reading and writing a shared line L (starting uncached)."*
<details><summary>Model answer</summary>

Start: L not cached anywhere; main memory holds L. (`--`/I = Invalid)

| # | Action | Core 0 | Core 1 | Bus / notes |
|---|--------|--------|--------|-------------|
| 0 | (init) | I | I | memory valid |
| 1 | **Core 0 reads L** | **E** | I | read miss, no other copy → Exclusive |
| 2 | **Core 1 reads L** | S | **S** | Core 0 snoops read → downgrades **E→S**; Core 1 loads as **S** |
| 3 | **Core 0 writes L** | **M** | I | Core 0 broadcasts intent; Core 1 snoops → **S→I**; Core 0 **S→M** |
| 4 | **Core 1 reads L** | S | S | Core 1 read miss; Core 0 snoops, **writes back** L (M→S), supplies data; Core 1 loads **S** |
| 5 | **Core 1 writes L** | I | **M** | Core 1 issues RWITM; Core 0 snoops → **S→I**; Core 1 **S→M** |

Invariant: at most **one** cache is ever in **M** or **E**; if any cache is **M**, memory is stale; multiple caches may share **S**.
</details>

---

## 📚 Want to see/hear it explained another way?

- Stallings, *Computer Organization and Architecture*, 11e — **Chapter 20: Parallel Processing**. Publisher page: https://www.pearson.com/en-us/subject-catalog/p/computer-organization-and-architecture/P200000003520
- Neso Academy — Parallel Processing / Flynn's Classification: https://www.youtube.com/c/nesoacademy
- Gate Smashers — Flynn's Classification of Computers: https://www.youtube.com/watch?v=YurRWnId5SU
- Gate Smashers — Cache Coherence Problem: https://www.youtube.com/watch?v=Hd9Sahd2Og8
- GeeksforGeeks — Flynn's Taxonomy: https://www.geeksforgeeks.org/computer-organization-architecture/computer-organization-flynns-taxonomy/
- GeeksforGeeks — Cache Coherence: https://www.geeksforgeeks.org/cache-coherence/
- TutorialsPoint — Parallel Computer Architecture: https://www.tutorialspoint.com/parallel_computer_architecture/index.htm
