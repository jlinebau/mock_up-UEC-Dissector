# UEC Header Format (Mock-Up Specification)

This document defines the mock UEC header format used by the Wireshark dissector in this repository.

This is **not** an official UEC wire format.  
It is a teaching model that reflects the architectural ideas of UEC:

- A new transport header  
- A congestion‑feedback header  
- A per‑hop telemetry block  

The header sits on top of UDP for lab and dissector development convenience.

---

# Overall Packet Layout

The mock UEC packet is carried over UDP:

Ethernet  
→ IPv4/IPv6  
→ UDP  
→ UEC Transport Header  
→ UEC Congestion Header  
→ UEC Telemetry Block  
→ Payload  

---

# 1. UEC Transport Header (16 bytes)

### Field: Version  
Header: UEC Transport Header  
Size: 2 bytes  
Type: uint16  
Description: Indicates the protocol version (e.g., 1). Used for forward compatibility and feature negotiation.

### Field: Flags  
Header: UEC Transport Header  
Size: 2 bytes  
Type: uint16  
Description: Bitmask controlling transport behavior. Example bits include: reliable delivery, ordered delivery, control‑packet indicator, telemetry‑only indicator. The dissector displays the raw hex value.

### Field: Flow ID  
Header: UEC Transport Header  
Size: 4 bytes  
Type: uint32  
Description: Identifies the UEC flow. Similar in purpose to a RoCEv2 QP number or a QUIC connection ID. Used for flow correlation and congestion‑control state.

### Field: Sequence Number  
Header: UEC Transport Header  
Size: 4 bytes  
Type: uint32  
Description: Per‑flow sequence number used for ordering, reliability, and loss detection.

### Field: Payload Length  
Header: UEC Transport Header  
Size: 4 bytes  
Type: uint32  
Description: Length of the payload following the telemetry block. Used by the receiver to validate packet integrity.

---

# 2. UEC Congestion Header (8 bytes)

### Field: ECN Feedback  
Header: UEC Congestion Header  
Size: 4 bytes  
Type: uint32  
Description: Encodes congestion feedback from the fabric. Models UEC’s fabric‑assisted congestion control, where switches and NICs can embed congestion state directly into packets.

### Field: Rate Hint  
Header: UEC Congestion Header  
Size: 4 bytes  
Type: uint32 (Mbps)  
Description: Suggests a sending rate to the transmitter. Represents the idea that the fabric can provide rate guidance to the sender, unlike DCQCN which is purely NIC‑driven.

---

# 3. UEC Telemetry Block (variable length)

The telemetry block contains per‑hop telemetry written into the packet as it traverses the fabric.  
This models UEC’s in‑band telemetry concept, where switches contribute real‑time state.

### Field: Hop Count  
Header: UEC Telemetry Block  
Size: 2 bytes  
Type: uint16  
Description: Number of hops that inserted telemetry TLVs into the packet.

### Field: Telemetry Length  
Header: UEC Telemetry Block  
Size: 2 bytes  
Type: uint16  
Description: Total length (in bytes) of all telemetry TLVs that follow.

### Field: Telemetry TLVs  
Header: UEC Telemetry Block  
Size: variable  
Type: TLV (Type‑Length‑Value)  
Description: Per‑hop telemetry information. Each hop may insert one or more TLVs describing its state (queue depth, latency, switch ID, etc.).

---

# 4. Telemetry TLV Format

Each TLV is structured as:

### Field: TLV Type  
Header: Telemetry TLV  
Size: 1 byte  
Type: uint8  
Description: Identifies the type of telemetry data contained in the TLV.

### Field: TLV Length  
Header: Telemetry TLV  
Size: 1 byte  
Type: uint8  
Description: Length of the TLV value field.

### Field: TLV Value  
Header: Telemetry TLV  
Size: variable  
Type: bytes  
Description: The telemetry data itself. Interpretation depends on the TLV type.

---

# 5. Example TLV Types (Mock)

These TLV types are used by the mock dissector and represent realistic UEC‑style telemetry.

### TLV Type 0x01 — Switch ID  
Header: Telemetry TLV  
Field: Switch ID  
Size: 4 bytes  
Type: uint32  
Description: Identifies the switch that inserted telemetry. Useful for reconstructing the path.

### TLV Type 0x02 — Queue Depth  
Header: Telemetry TLV  
Field: Queue Depth  
Size: 1 byte  
Type: uint8  
Description: Queue occupancy percentage (0–100%). Models congestion state at the hop.

### TLV Type 0x03 — Hop Latency  
Header: Telemetry TLV  
Field: Hop Latency  
Size: 2 bytes  
Type: uint16  
Description: Per‑hop latency in microseconds. Represents the time spent in the switch pipeline and buffers.

---

# 6. Example Interpretation

If a packet contains:

- Hop Count = 2  
- Telemetry Length = 8 bytes  
- TLVs:  
  - Type 0x01, Length 4 → Switch ID  
  - Type 0x02, Length 1 → Queue depth  
  - Type 0x03, Length 2 → Hop latency  

Then the receiver (or Wireshark) can reconstruct:

- Hop 1:  
  - Switch ID  
  - Queue depth  
  - Latency  

This models UEC’s fabric‑aware telemetry model, where each hop contributes real‑time congestion and performance data.

---
