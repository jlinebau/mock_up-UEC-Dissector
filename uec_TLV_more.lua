-- Ultra Ethernet Consortium (UEC) mock dissector
-- Extended with per-hop telemetry TLVs and hop grouping

uec_proto = Proto("uec", "Ultra Ethernet Consortium Transport")

-- Transport fields
local f_version    = ProtoField.uint16("uec.version", "Version", base.DEC)
local f_flags      = ProtoField.uint16("uec.flags", "Flags", base.HEX)
local f_flowid     = ProtoField.uint32("uec.flowid", "Flow ID", base.HEX)
local f_seq        = ProtoField.uint32("uec.seq", "Sequence Number", base.DEC)
local f_len        = ProtoField.uint32("uec.length", "Payload Length", base.DEC)

-- Congestion fields
local f_ecn        = ProtoField.uint32("uec.ecn", "ECN Feedback", base.DEC)
local f_rate       = ProtoField.uint32("uec.rate", "Rate Hint (Mbps)", base.DEC)

-- Telemetry header
local f_hopcount   = ProtoField.uint16("uec.hopcount", "Hop Count", base.DEC)
local f_tellen     = ProtoField.uint16("uec.tellen", "Telemetry Length", base.DEC)

-- Telemetry TLVs (generic)
local f_tlv_type   = ProtoField.uint8("uec.tel.type", "TLV Type", base.HEX)
local f_tlv_len    = ProtoField.uint8("uec.tel.len", "TLV Length", base.DEC)
local f_tlv_raw    = ProtoField.bytes("uec.tel.value", "TLV Value")

-- Specific TLV interpretations
local f_tlv_sw_id  = ProtoField.uint32("uec.tel.switch_id", "Switch ID", base.HEX)
local f_tlv_qdepth = ProtoField.uint8("uec.tel.queue_depth", "Queue Depth (%)", base.DEC)
local f_tlv_lat    = ProtoField.uint16("uec.tel.latency", "Hop Latency (µs)", base.DEC)
local f_tlv_ecn_p  = ProtoField.uint8("uec.tel.ecn_prob", "ECN Mark Probability (%)", base.DEC)
local f_tlv_if     = ProtoField.uint16("uec.tel.ifindex", "Output Interface ID", base.DEC)

uec_proto.fields = {
    f_version, f_flags, f_flowid, f_seq, f_len,
    f_ecn, f_rate,
    f_hopcount, f_tellen,
    f_tlv_type, f_tlv_len, f_tlv_raw,
    f_tlv_sw_id, f_tlv_qdepth, f_tlv_lat,
    f_tlv_ecn_p, f_tlv_if
}

-- TLV type constants (mock)
local TLV_SWITCH_ID   = 0x01
local TLV_QUEUE_DEPTH = 0x02
local TLV_LATENCY     = 0x03
local TLV_ECN_PROB    = 0x04
local TLV_IFINDEX     = 0x05

local function dissect_telemetry_tlvs(buffer, offset, length, hop_tree)
    local end_offset = offset + length

    while offset + 2 <= end_offset do
        local tlv_type = buffer(offset,1):uint()
        local tlv_len  = buffer(offset+1,1):uint()
        local val_start = offset + 2
        local val_end   = val_start + tlv_len

        if val_end > end_offset then break end

        local tlv_node = hop_tree:add(buffer(offset, 2 + tlv_len),
                                      string.format("TLV Type 0x%02X, Len %d", tlv_type, tlv_len))
        tlv_node:add(f_tlv_type, buffer(offset,1))
        tlv_node:add(f_tlv_len,  buffer(offset+1,1))

        if tlv_type == TLV_SWITCH_ID and tlv_len == 4 then
            tlv_node:add(f_tlv_sw_id, buffer(val_start,4))
        elseif tlv_type == TLV_QUEUE_DEPTH and tlv_len == 1 then
            tlv_node:add(f_tlv_qdepth, buffer(val_start,1))
        elseif tlv_type == TLV_LATENCY and tlv_len == 2 then
            tlv_node:add(f_tlv_lat, buffer(val_start,2))
        elseif tlv_type == TLV_ECN_PROB and tlv_len == 1 then
            tlv_node:add(f_tlv_ecn_p, buffer(val_start,1))
        elseif tlv_type == TLV_IFINDEX and tlv_len == 2 then
            tlv_node:add(f_tlv_if, buffer(val_start,2))
        else
            tlv_node:add(f_tlv_raw, buffer(val_start, tlv_len))
        end

        offset = val_end
    end
end

local function dissect_telemetry(buffer, subtree)
    local hopcount = buffer(24,2):uint()
    local tellen   = buffer(26,2):uint()

    subtree:add(f_hopcount, buffer(24,2))
    subtree:add(f_tellen,   buffer(26,2))

    if tellen == 0 or buffer:len() < 28 + tellen then
        return
    end

    local tel_root = subtree:add(buffer(28, tellen), "Telemetry Data")

    -- Simple model: divide TLVs evenly per hop (mock behavior)
    -- In a real spec, there would be explicit hop delimiters.
    local per_hop_len = math.floor(tellen / math.max(hopcount, 1))
    local offset = 28

    for hop = 1, hopcount do
        local remaining = (28 + tellen) - offset
        if remaining <= 0 then break end

        local this_len = (hop == hopcount) and remaining or math.min(per_hop_len, remaining)
        local hop_tree = tel_root:add(buffer(offset, this_len),
                                      string.format("Hop %d Telemetry", hop))

        dissect_telemetry_tlvs(buffer, offset, this_len, hop_tree)
        offset = offset + this_len
    end
end

function uec_proto.dissector(buffer, pinfo, tree)
    if buffer:len() < 28 then return end

    pinfo.cols.protocol = "UEC"

    local subtree = tree:add(uec_proto, buffer(), "UEC Transport")

    -- Transport header
    subtree:add(f_version, buffer(0,2))
    subtree:add(f_flags,   buffer(2,2))
    subtree:add(f_flowid,  buffer(4,4))
    subtree:add(f_seq,     buffer(8,4))
    subtree:add(f_len,     buffer(12,4))

    -- Congestion header
    subtree:add(f_ecn,     buffer(16,4))
    subtree:add(f_rate,    buffer(20,4))

    -- Telemetry (header + TLVs)
    dissect_telemetry(buffer, subtree)
end

-- Bind to UDP port 5555
local udp_port = DissectorTable.get("udp.port")
udp_port:add(5555, uec_proto)
