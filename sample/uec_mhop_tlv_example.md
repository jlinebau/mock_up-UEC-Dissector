# UEC Telemetry Examples

This document provides examples of how to interpret per-hop telemetry in the
mock UEC header format. These examples correspond to the sample packets in
`sample/uec-multi-hop_tlvs.txt`.

The goal is to demonstrate how a receiver (or Wireshark) can reconstruct
fabric behavior and identify congestion hotspots.

---

# Example 1 — Hop 1 Congested

Packet: `UEC SAMPLE PACKET 1`

Hop Count: 2  
Telemetry Length: 20 bytes  

## Hop 1 Telemetry
- Switch ID: `0xA1`
- Queue Depth: **80%**
- Latency: **100 µs**
- ECN Probability: **64%**

Interpretation:

Hop 1 is experiencing moderate-to-high congestion.  
The queue depth and ECN probability both indicate pressure, and the latency
is elevated relative to Hop 2.

## Hop 2 Telemetry
- Switch ID: `0xB7`
- Queue Depth: 16%
- Latency: 32 µs
- Output Interface: 2

Interpretation:

Hop 2 is healthy.  
Low queue depth and low latency indicate no congestion.

## Summary

The congestion is localized to **Hop 1**.  
This is a classic “ingress bottleneck” scenario.

---

# Example 2 — Hop 2 Congested

Packet: `UEC SAMPLE PACKET 2`

Hop Count: 2  
Telemetry Length: 20 bytes  

## Hop 1 Telemetry
- Switch ID: `0xA1`
- Queue Depth: 16%
- Latency: 32 µs
- ECN Probability: 16%

Interpretation:

Hop 1 is healthy.

## Hop 2 Telemetry
- Switch ID: `0xB7`
- Queue Depth: **112%** (mock overflow)
- Latency: **500 µs**
- Output Interface: 3

Interpretation:

Hop 2 is severely congested.  
Queue depth exceeds 100% (mock overflow), and latency is significantly higher.

## Summary

The congestion is localized to **Hop 2**.  
This is a “mid-fabric bottleneck” scenario, often caused by:

- Oversubscribed uplinks  
- Hotspot traffic patterns  
- Uneven ECMP hashing  
- Flow collisions

---

# Why This Matters

UEC’s in-band telemetry model allows:

- Per-hop visibility  
- Real-time congestion detection  
- Path reconstruction  
- Flow-level diagnostics  
- Feedback into congestion control and routing

These examples illustrate how a receiver or analysis tool can identify where
congestion occurs and how severe it is.
