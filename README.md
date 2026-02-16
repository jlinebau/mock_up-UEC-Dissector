# UEC Wireshark Dissector (PoC Mock-Up)

This repository contains a **mock-up PoC Wireshark dissector** for a **mock Ultra Ethernet Consortium (UEC) transport header**.

> **Important:**  
> This is **not** an official UEC wire format.  
> It is a **learning and demonstration tool** that models a realistic UEC‑style header:
> - Transport
> - Congestion feedback
> - Per‑hop telemetry

The goal is to:
- Practice reasoning about UEC packet structure.
- Demonstrate understanding of AI fabric transports.
- Provide a concrete Wireshark dissector for labs and PoC work.

---

## Protocol model

The mock UEC packet is carried over **UDP** (for lab convenience):

```text
Ethernet
  → IPv4/IPv6
    → UDP (port 5555 by default)
      → UEC Transport Header
      → UEC Congestion Header
      → UEC Telemetry Block (per-hop TLVs)
      → Payload
