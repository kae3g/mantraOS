# Guardian Services – Overview

> **SB 11.19.41** – "Hearing, knowledge, renunciation… self-control."

The Guardian group is a tiny constellation of userspace daemons:

- `guardian-silence` – mindful ring scheduler (never startles).
- `guardian-reflect` – local gratitude & usage journaling. `guardian-mercy` –
- one-toggle calm mode (theme + notifier gates). `guardian-display` – e-ink
- orchestrator (partial/full refresh, ghost
clearing).
- `guardian-io` – device gatekeeper with friendly prompts. `guardian-network` –
- LAN/LoRa ferry; narrow, declared egress.

### Configuration (TOML, child-legible)
```toml
[silence]
interval_min = 25
bell = "soft_temple.wav"

[mercy]
feeds_hidden = true
dim_colors = true

[network]
allow_lan = true
allow_wan = false
lora_rate = "low"
```

Logs always read like a story, not a riddle.
