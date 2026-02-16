-- Ultra Ethernet Consortium (UEC) mock dissector
-- Author: Justin + CP

uec_proto = Proto("uec", "Ultra Ethernet Consortium Transport")

-- Define fields
local f_version     = ProtoField.uint16("uec.version", "Version", base.DEC)
local f_flags       = ProtoField.uint16("uec.flags", "Flags", base.HEX)
local f_flowid      = ProtoField.uint32("uec.flowid", "Flow ID", base.HEX)
local f_seq         = ProtoField.uint32("uec.seq", "Sequence Number", base.DEC)
local f_len         = ProtoField.uint32("uec.length", "Payload Length", base.DEC)

local f_ecn         = ProtoField.uint32("uec.ecn", "ECN Feedback", base.DEC)
local f_rate        = ProtoField.uint32("uec.rate", "Rate Hint (Mbps)", base.DEC)

local f_hopcount    = ProtoField.uint16("uec.hopcount", "Hop Count", base.DEC)
local f_tellen      = ProtoField.uint16("uec.tellen", "Telemetry Length", base.DEC)

uec_proto.fields = {
    f_version, f_flags, f_flowid, f_seq, f_len,
    f_ecn, f_rate,
    f_hopcount, f_tellen
}

function uec_proto.dissector(buffer, pinfo, tree)
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

    -- Telemetry TLVs (optional)
    local tellen = buffer(26,2):uint()
    if tellen > 0 then
        local tel_tree = subtree:add(buffer(28, tellen), "Telemetry Data")
    end
end

-- Register dissector to a UDP port for testing
local udp_port = DissectorTable.get("udp.port")
udp_port:add(5555, uec_proto)
