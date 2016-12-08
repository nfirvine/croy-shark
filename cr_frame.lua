-- declare our protocol
croy_match_frame = Proto("croy_frame", "Clash Royale Match Frame")
croy_match_frame.fields = {}

-- protocol structure
--
-- 10bytes session id
-- 1 bytes length = n1
-- n1 bytes data
-- --- n1=1 for ACK, followed by 1 byte seq no indicating which package it acknowledgs on
-- --- n1=2 for UNKNOWN useage, followed by 2 bytes of binary in series(e.g. 22,23 / e9,ea ...).
-- 1 bytes [packet:DataField] count
-- n [packets:DataField] of data field


--  -- [packet:DataField] structure
--      -- 1 byte sequence id
--      -- 2 byte sender?  8e:d6:02 for server->client, a8:c9:01 for client->server
--      -- 1 byte field length = n2
--      -- n2 bytes data

local header_field={
    [0xa8c901] = "client->server",
    [0x8ed602] = "server->client",
    [0xbc9d01] = "sync"
}
 
local fds = croy_match_frame.fields
-- TODO
fds.seqID = ProtoField.new("Sequence ID", "croy_frame.seqID", ftypes.UINT8)
fds.frameHeader = ProtoField.new("Header", "croy_frame.header", ftypes.UINT32, header_field, base.HEX)
fds.frameLength = ProtoField.new("Length", "croy_frame.frameLength", ftypes.UINT8)
fds.data = ProtoField.new("data", "croy_frame.data", ftypes.BYTES)



function croy_match_frame.dissector(buffer,pinfo,tree)
    local dataptr = 0
    -- pinfo.cols.protocol = "CROY_MATCH"
    local seqID = buffer(dataptr,1):uint()
    local subtree = tree:add(croy_match_frame, buffer(), "Clash Royale Frame #" .. seqID)

    subtree:add(fds.seqID,buffer(dataptr,1))
    dataptr = dataptr + 1
    subtree:add(fds.frameHeader,buffer(dataptr,3))
    dataptr = dataptr + 3
    subtree:add(fds.frameLength,buffer(dataptr,1))
    dataptr = dataptr + 1
    subtree:add(fds.data,buffer(dataptr,buffer:len()-dataptr))
    -- dataptr = dataptr + 1
end

