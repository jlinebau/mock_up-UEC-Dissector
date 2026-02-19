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




# Disclaimer

The UEC header format defined in this repository is a **mock protocol** created
for learning, experimentation, and Wireshark dissector development.

The Ultra Ethernet Consortium has **not yet published** a public wire‑format
specification for:

- UEC Transport
- UEC Congestion Control
- UEC Telemetry
- TLV structures
- Packet layouts

This mock header is based on **public architectural descriptions** from UEC and
UEC member companies, but it is **not** an official or reverse‑engineered
specification.

It exists solely as a teaching and demonstration tool.


## Why a Mock Header?

UEC has publicly described the architecture of its transport, congestion control,
and telemetry systems, but has not yet released a byte‑level wire format.

To explore the concepts and demonstrate some understanding of UEC’s
architecture, this repository defines a **realistic mock header** that reflects:

- A transport layer
- A congestion‑feedback layer
- A per‑hop telemetry layer

This mock format allows for Wireshark dissector development, packet‑walk
explanations, and educational purposes while remaining fully transparent about its
non‑official status.





# How This Mock Maps to UEC Architecture

Although the exact UEC wire format is not public, UEC has described the following
architectural components:

- A new transport protocol (UET)
- Fabric‑assisted congestion control
- In‑band telemetry
- Switch/NIC cooperation
- Multi‑path awareness

The mock header in this repository maps to these concepts as follows:

- **UEC Transport Header** → models UET flow ID, sequencing, and flags
- **UEC Congestion Header** → models fabric‑assisted congestion feedback
- **UEC Telemetry Block** → models per‑hop in‑band telemetry (IOAM‑like)
- **TLVs** → model extensible telemetry and metadata

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
```






# Sources and References

This mock UEC header format and dissector are based on publicly available,
high‑level architectural information from the following sources:

1. **Ultra Ethernet Consortium – Official Website**  
   Mission, goals, specification overview, and public white papers.  
   

2. **Cisco – Ultra Ethernet for Scalable AI Network Deployment**  
   Describes the motivation for UEC and the challenges it addresses in AI/HPC fabrics.  
   

3. **Ultra Ethernet Consortium – Specification Update (2024)**  
   Provides details on UEC Transport (UET), congestion control, link‑layer behavior,
   and software APIs.  
   

4. **Asterfusion – UEC Technology Standards & Future**  
   Offers a detailed breakdown of the UEC protocol stack, transport layer,
   congestion control, and UEC vs RDMA comparison.  
   

5. **Demystifying Ultra Ethernet**  
   Explains the industry context and architectural motivations behind UEC.  
   

These sources describe UEC’s architecture and goals but do **not** publish a final
wire format. Therefore, the header defined in this repository is a **mock protocol**
designed for learning, demonstration, and Wireshark dissector development.
