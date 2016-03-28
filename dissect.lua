-- declare our protocol
croy_match_proto = Proto("croy_match", "Clash Royale Match Protocol")
croy_match_proto.fields = {}

local cmds_map = {
    [0] = "op",
    [1] = "ack"
}

local subcmds_map = {
    [0] = "init",
    [1] = "delta"
}

local delta_dirs = {
    [1] = "client_server",
    [2] = "server_client"
}

local fds = croy_match_proto.fields
-- TODO
fds.session_token = ProtoField.new("Session Token", "croy_match.session", ftypes.BYTES)

fds.cmd = ProtoField.new("cmd", "croy_match.cmd", ftypes.UINT8, cmds_map)
fds.subcmd = ProtoField.new("Subcmd", "croy_match.subcmd", ftypes.UINT8, subcmds_map)

fds.seq_i = ProtoField.new("seq no", "croy_match.seq_i", ftypes.UINT8)

-- always 0x00 * 1387?
fds.init_data = ProtoField.new("init data", "croy_match.init_data", ftypes.BYTES)

-- TODO
fds.sender = ProtoField.new("sender", "croy_match.sender", ftypes.UINT16, nil, base.HEX)

fds.delta_dir = ProtoField.new("dir", "croy_match.delta_dir", ftypes.UINT8, delta_dirs, base.HEX)
fds.delta_len = ProtoField.new("delta len", "croy_match.delta_len", ftypes.UINT8)

-- TODO
fds.data = ProtoField.new("data", "croy_match.data", ftypes.BYTES)

function croy_match_proto.dissector(buffer,pinfo,tree)
    pinfo.cols.protocol = "CROY_MATCH"
    local subtree = tree:add(croy_match_proto, buffer(), "Clash Royale Match")
    subtree:add(fds.session_token, buffer(0, 10))
    local data_start = 10
    if buffer:len() > 10 then
        data_start = 11
        local c = buffer(10, 1)
        subtree:add(fds.cmd, c)
        local cs = cmds_map[c:uint()]
        if cs == "ack" then
            subtree:add(fds.seq_i, buffer(11, 1))
            data_start = 12
        elseif cs == "op" then
            local sc = buffer(11, 1)
            local scs = subcmds_map[sc:uint()]
            subtree:add(fds.subcmd, buffer(11, 1))
            subtree:add(fds.seq_i, buffer(12, 1))
            data_start = 13
            if scs == "init" then
                subtree:add(fds.init_data, buffer(data_start, buffer:len() - data_start))
                data_start = buffer:len()
            elseif scs == "delta" then
                subtree:add(fds.sender, buffer(13, 2))
                subtree:add(fds.delta_dir, buffer(15, 1))
                subtree:add(fds.delta_len, buffer(16, 1))
                data_start = 16+1
            end
        end
    end

    if data_start < buffer:len() then
        local data = buffer(data_start, buffer:len() - data_start)
        subtree:add(fds.data, data)
    end
end
-- load the udp.port table
udp_table = DissectorTable.get("udp.port")
udp_table:add(9339, croy_match_proto)
