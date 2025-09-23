# 010 – Modular Diagrams & Service Architecture

> **SB 11.19.36**  
> "Compassion, satisfaction, tolerance, self-control, non-violence, truthfulness, honesty — cultivate these."

---

## 1) Exploded Text Diagram (MantraBox)

```
[ Top Cover ]
├── Perimeter Gasket (TPE/EPDM)
├── Bezel + E-paper (Inkplate) + Foam Isolation
├── Inner Sled (standoffs + elastomer mounts)
│     ├── Mainboard (SoC + PMIC)
│     ├── RAM Mezzanine Module (retention bracket)
│     ├── Storage (microSD or socketed Flash)
│     └── LoRa Module (u.FL) + gasketed antenna pass-through
├── Battery Sled (pull-tab, JST/XT30)
└── Button Boots + Membrane Vents
[ Bottom Shell ]
└── Screw Bosses (torque spec silk-screen)
```

**Service flow** (back cover off, 4–6 screws):
- Swap **battery** (2 min) → swap **RAM** (5 min) → swap **screen** (10–15 min).

---

## 2) RAM Mezzanine Concept

- **Connector**: low-profile board-to-board; keyed.  
- **Retention**: steel or composite bracket + 2 screws.  
- **Label**: QR code with density, date, refurb grade.  
- **EE Markers**: keep-out zones for future 64/128 GB signal integrity.

**Sustainability**: RAM moves between devices as needs change; modules get second lives.

---

## 3) E-paper Module

- **Frame**: foam gasket around glass perimeter; no shear load on panel.  
- **Cable**: FPC with latch (ZIF) connector; label shows release direction.  
- **Service**: open bezel → unlatch FPC → lift panel from foam bed → replace.

---

## 4) Waterproofing (IPX4) Without Toxic Potting

- **Perimeter compression** with TPE/EPDM; screws provide even load.  
- **Mic/Speaker** covered by hydrophobic membrane + acoustic mesh.  
- **USB-C** with replaceable rubber cap; internal drip-ledge channels.  
- **Pressure equalization** via ePTFE vent; no foams, no epoxies.

---

## 5) Drop Resistance with E-paper Empathy

- **Inner sled** floats on elastomer posts; corners absorb energy.  
- **Bezel standoff** ensures impacts load the frame, not the e-paper.  
- **Screen "rest mode"**: display service sets a safe pattern before high-risk transport to reduce ghosting artifacts.

---

## 6) Minimal Pin Map (abstract)

```
J1 (RAM mezz)
1: VDD_1V1   2: VDD_3V3
3: GND       4: GND
5: DQ0       6: DQ1
...
n-1: RESET#  n: I2C_ID (module EEPROM for size/grade)
```

**I2C_ID** lets firmware learn RAM size and show friendly messages:
> "Hello, a 16 GB memory seed has been planted 🌱."

---

## 7) Field-Replaceable Unit (FRU) Cards

Add a small card inside the back cover with QR links to:
- Battery replacement guide  
- Screen replacement guide  
- RAM upgrade steps  
- Waterproofing gasket part numbers

> **SB 11.29.34** – "See the Divine in all beings."  
> _We see value in every part: replace, not discard._