# 030 – Kernel & Runtime Design (Root and Breath)

> **SB 11.7.43**  
> *yathā taror mūla-niṣecanena tṛpyanti tat-skandha-bhujopaśākhāḥ*  
> *prāṇopahārāc ca yathendriyāṇāṁ tathaiva sarvārhaṇam acyutejyā*  
> "As watering the root nourishes the tree, so too a single, right worship nourishes all."

The kernel is the **root system**; the runtime is the **breath**.  
We keep both small, honest, and legible to children.

---

## 1) System Overview

- **Microkernel-inspired base** (seL4-like constraints):  
  - Minimal trusted code, explicit **capabilities** for everything.  
  - Memory isolation; no ambient authority.  
- **Userspace services** ("Guardian Services"):  
  - **Silence Bell**, **Reflection Log**, **Mercy Mode**, **Inkplate Display Service**, **I/O Gatekeeper**, **Network Ferry**.
- **Policy as Dharma**: Every permission has:
  1) a plain-language reason,  
  2) a visible toggle,  
  3) a logged human-readable event.

---

## 2) Capability Model (Ambient Authority = 0)

Each process starts with **zero** access except:
- **stdio** (its own),  
- a **cap table** listing what it can request.

### Capability Kinds
- `cap.fs.read(path-pattern)` – read-only subtree.  
- `cap.fs.write(path-pattern)` – write-only or read/write subtree.  
- `cap.net.send(domain|ip|iface)` – scoped egress.  
- `cap.net.listen(port|iface)` – limited ingress.  
- `cap.hw.sensor(kind, rate, privacy_budget)` – e.g., `accelerometer, 1 Hz, 5 min/day`.  
- `cap.ui.display(region)` – draw region on e-ink via display server.  
- `cap.power.duty(duty-name)` – permission to request specific power modes.  

> **SB 11.19.33**  
> *satyam dayā tapaḥ śaucam…*  
> "Truthfulness, compassion, austerity, purity… rest upon self-control."  
> _So too do apps rest upon self-control; no capability = no action._

---

## 3) Runtime & Scheduling (Breath and Rest)

### Duty-Cycle Scheduler (E-ink friendly)
- **Interactive bursts**: short, responsive slices; partial refresh.  
- **Idle breaths**: long sleeps; consolidate timers; coalesce wakeups.  
- **Ritual windows**: user-specified "fasting" periods: background network muted, high-power tasks deferred, UI softened (**Mercy Mode**).

### Power Modes
- `awake-interactive`, `reading-calm`, `background-low`, `deep-sleep`.  
- System transitions are logged in clear language:
  - "We entered **reading-calm** to save power and eyes."

---

## 4) Privacy Budgets

Sensors and network access are **metered**:
- Example: an app declares `accelerometer: 1 Hz, 5 min / day` → runtime tracks budget → exceeding prompts user:  
  - "This app asks for more motion data today. Allow 2 more minutes?"

Budgets reset daily; reflection log shows usage with emojis for kids.

---

## 5) Guardian Services (Userspace)

- **Silence Bell**: configurable bell that never startles; integrates with ritual times.  
- **Reflection Log**: local-only gratitude & usage notes; exportable to paper.  
- **Mercy Mode**: toggles low-contrast palette, hides "feeds," slows notifications.  
- **Inkplate Display Service**: centralizes e-ink partial/full refresh strategies:
  - text-first rendering; differential updates; ghosting-clears scheduled gently.  
- **I/O Gatekeeper**: mediates USB, SD, keyboard; shows a human prompt when new devices appear ("A friend is knocking: 'USB Keyboard'. Let it in?").  
- **Network Ferry**: narrow, declared egress (USB-C tether, LAN only, or LoRa). Logs **who** it spoke to in sentence form.

---

## 6) Human-Readable Logs (for Children and Auditors)

Examples:
- `2025-09-23 09:15 Silence Bell: a soft ring reminded you to breathe.`
- `2025-09-23 09:22 Notes app: wrote to /home/you/notes/today.md.`
- `2025-09-23 09:40 Network Ferry: shared 2 messages to room "Village Hall LAN".`

---

## 7) IPC & API Sketch (Rust-flavored)

```rust
// Minimal message bus (serde + ring buffer)
enum Msg {
    Request { svc: String, method: String, payload: Vec<u8> },
    Response { code: u16, payload: Vec<u8> }
}

// Example: ask display service to draw text region
Request {
  svc: "display.inkplate",
  method: "draw_text",
  payload: bincode(&DrawText { x: 10, y: 24, text: "om shanti" })
}
```

**Policy hooks** wrap IPC endpoints with capability checks and plain-language prompts.

---

## 8) Filesystem Conventions (Garden Paths)

* `/home/<user>/` – your garden.
* `/paper/queue/` – **Treasure Ritual** staging for print-to-paper.
* `/shared/village/` – LAN-only share for **Sandalnet** transfers.
* `/system/policy/` – human-readable TOML policies with comments for kids.

---

## 9) Testing Dharma (must remain calm)

1. **Latency under mercy mode** – UI remains smooth for text tasks.
2. **Budget overuse** – prompts are clear, no nags.
3. **Network outage** – system degrades into Sandalnet flow gracefully.
4. **E-ink ghosting** – automatic clears don't jar the user.

> **SB 11.20.9**
> *tāvat karmāṇi kurvīta…*
> "Continue duties until steadiness arises."
> *We iterate until the system is steady and gentle.*

---