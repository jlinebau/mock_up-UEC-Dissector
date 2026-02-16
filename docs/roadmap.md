
---

### docs/roadmap.md

```markdown
# UEC Dissector Roadmap

This document outlines ideas for extending the mock UEC Wireshark dissector and turning this into a richer lab/teaching tool.

---

## 1. Telemetry TLV expansion

- **Add more TLV types**, for example:
  - `0x04` – ECN mark probability
  - `0x05` – Output interface ID
  - `0x06` – Path ID / SR‑TE policy ID
  - `0x07` – Buffer occupancy (bytes)
- **Decode TLVs per hop**:
  - Group TLVs by hop index.
  - Show “Hop 1”, “Hop 2”, etc. with nested fields.

---

## 2. Flow correlation

- Track **Flow ID** across packets:
  - Use Wireshark’s conversation or flow APIs.
  - Show aggregate stats per Flow ID (min/max latency, ECN events).
- Add a **custom Wireshark tap** or post‑processing script to:
  - Plot congestion over time for a given flow.
  - Compare paths (SPINE1 vs SPINE2) for the same flow.

---

## 3. SR‑TE / path metadata

- Add a TLV for **SR‑TE policy ID**:
  - E.g., which SR‑TE policy or color was used.
- Add a TLV for **SID stack hash** or path ID:
  - To correlate UEC telemetry with SR‑TE path selection.

---

## 4. Packet generator

- Build a small **Python script** to generate mock UEC packets:
  - Use `scapy` or raw sockets.
  - Randomize:
    - Flow IDs
    - ECN feedback
    - Rate hints
    - Telemetry TLVs
- Generate `.pcapng` files for:
  - “Healthy fabric”
  - “Congested SPINE1”
  - “Dynamic path shift to SPINE2”

---

## 5. RoCEv2 vs UEC comparison

- Add a **second dissector** for a simplified RoCEv2 header:
  - UDP + mock BTH.
- Provide side‑by‑side `.pcapng`:
  - RoCEv2 + DCQCN + PFC (simulated fields).
  - UEC + UEC CC + telemetry.
- Use this to teach:
  - Why UEC’s telemetry and congestion model is different.

---

## 6. Documentation and diagrams

- Add diagrams showing:
  - UEC packet layout.
  - Per‑hop telemetry accumulation.
  - Flow of congestion feedback.
- Add a **“lab guide”**:
  - How to open the pcap.
  - What to look for in the dissector.
  - Questions to ask (e.g., “Which hop is congested?”).

---

## 7. Future: real UEC

When the official UEC wire format is public:

- Update the dissector to:
  - Match real header fields.
  - Use real TLV types.
- Keep this mock version as:
  - A teaching branch.
  - A historical artifact of early exploration.

---
