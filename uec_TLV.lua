-- Ultra Ethernet Consortium (UEC) mock dissector
-- Extended with per-hop telemetry TLVs

uec_proto = Proto("uec", "Ultra Ethernet Consortium Transport")

-- Transport fields
local f_version   = ProtoField.uint16("uec.version", "Version", base.DEC)
local f_flags     = ProtoField.uint16("uec.flags", "Flags", base.HEX)
local f_flowid    = ProtoField.uint32("uec.flowid", "Flow ID", base.HEX)
local f_seq       = ProtoField.uint32("uec.seq", "Sequence Number", base.DEC)
local f_len       = ProtoField.uint32("uec.length", "Payload Length", base.DEC)

-- Congestion fields
local f_ecn       = ProtoField.uint32("uec.ecn", "ECN Feedback", base.DEC)
local f_rate      = ProtoField.uint32("uec.rate", "Rate Hint (Mbps)", base.DEC)

-- Telemetry header
local f_hopcount  = ProtoField.uint16("uec.hopcount", "Hop Count", base.DEC)
local f_tellen    = ProtoField.uint16("uec.tellen", "Telemetry Length", base.DEC)

-- Telemetry TLVs
local f_tlv_type  = ProtoField.uint8("uec.tel.type", "TLV Type", base.HEX)
local f_tlv_len   = ProtoField.uint8("uec.tel.len", "TLV Length", base.DEC)
local f_tlv_raw   = ProtoField.bytes("uec.tel.value", "TLV Value")

local f_tlv_sw_id = ProtoField.uint32("uec.tel.switch_id", "Switch ID", base.HEX)
local f_tlv_qdepth= ProtoField.uint8("uec.tel.queue_depth", "Queue Depth (%)", base.DEC)
local f_tlv_lat   = ProtoField.uint16("uec.tel.latency", "Hop Latency (µs)", base.DEC)

uec_proto.fields = {
    f_version, f_flags, f_flowid, f_seq, f_len,
    f_ecn, f_rate,
    f_hopcount, f_tellen,
    f_tlv_type, f_tlv_len, f_tlv_raw,
    f_tlv_sw_id, f_tlv_qdepth, f_tlv_lat
}

local function dissect_telemetry_tlvs(buffer, offset, length, tree)
    local end_offset = offset + length
    local hop_index = 1

    while offset < end_offset do
        if offset + 2 > end_offset then break end

        local tlv_type = buffer(offset,1):uint()
        local tlv_len  = buffer(offset+1,1):uint()
        local tlv_val_start = offset + 2
        local tlv_val_end   = tlv_val_start + tlv_len

        if tlv_val_end > end_offset then break end

        local tlv_tree = tree:add(buffer(offset, 2 + tlv_len),
                                  string.format("TLV (Type 0x%02X, Len %d)", tlv_type, tlv_len))
        tlv_tree:add(f_tlv_type, buffer(offset,1))
        tlv_tree:add(f_tlv_len,  buffer(offset+1,1))

        if tlv_type == 0x01 and tlv_len == 4 then
            tlv_tree:add(f_tlv_sw_id, buffer(tlv_val_start,4))
        elseif tlv_type == 0x02 and tlv_len == 1 then
            tlv_tree:add(f_tlv_qdepth, buffer(tlv_val_start,1))
        elseif tlv_type == 0x03 and tlv_len == 2 then
            tlv_tree:add(f_tlv_lat, buffer(tlv_val_start,2))
        else
            tlv_tree:add(f_tlv_raw, buffer(tlv_val_start, tlv_len))
        end

        offset = tlv_val_end
        hop_index = hop_index + 1
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

    -- Telemetry header
    subtree:add(f_hopcount, buffer(24,2))
    subtree:add(f_tellen,   buffer(26,2))

    local tellen = buffer(26,2):uint()
    if tellen > 0 and buffer:len() >= 28 + tellen then
        local tel_tree = subtree:add(buffer(28, tellen), "Telemetry Data")
        dissect_telemetry_tlvs(buffer, 28, tellen, tel_tree)
    end
end

-- Bind to UDP port 5555
local udp_port = DissectorTable.get("udp.port")
udp_port:add(5555, uec_proto)
