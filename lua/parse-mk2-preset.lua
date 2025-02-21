-- Code to "parse" into a Lua table a preset uploaded from an Akai LPD8 mk2.

-- The uploaded preset file contains a series of integers on separate
-- lines, each one representing a single byte. So the first task is to read
-- it in and turn it into a string of bytes. The preset consumes exactly
-- 173 bytes, including the system exclusive (sysex) header and trailer.

fmt = string.format

-- Read stdin, expecting a number on each line.
function read_preset()
    local p = {}
    for i = 1,173 do
        p[i] = io.read "n"
    end
    return p
end

num_to_pressure = {
    [0] = "none",
    [1] = "channel",
    [2] = "poly",
}

-- Combine two bytes, which together represent a 14-bit value, into a
-- single number. The most significant byte is first.

function combine(p, i)
    return p[i] * 128 + p[i+1]
end

function parse_rgb(p, i)
    local r, g, b
    r = combine(p, i)
    g = combine(p, i+2)
    b = combine(p, i+4)
    return (r << 16) + (g << 8) + b
end

-- If the byte representing a channel number is less than 16, add one and
-- return it; otherwise, it represents the use of the "global" channel, so
-- return a string to indicate this.

function parse_channel(ch)
    return (ch < 16) and (ch + 1) or "global"
end

-- Given p and starting index i, parse bytes as a pad; return pad structure
-- and new index.
--
-- Format of a pad: note number, controller number, program change number,
-- channel, two RGB values.

function parse_pad(p, i)
    return {
        note = p[i],
        controller = p[i+1],
        program = p[i+2] + 1,
        channel = parse_channel(p[i+3]),
        color = { parse_rgb(p, i+4), parse_rgb(p, i+10) }
    }, i+16
end

-- Given p and starting index i, parse bytes as a knob; return knob structure
-- and new index.
--
-- Format of a knob: controller number, channel, range (low, high).

function parse_knob(p, i)
    return {
        controller = p[i],
        channel = parse_channel(p[i+1]),
        range = { p[i+2], p[i+3] },
    }, i+4
end

-- pressure = off, channel, poly (0, 1, 2)
function parse_global(p, i)
    return {
        channel = p[i] + 1,
        pressure = num_to_pressure[p[i+1]],
        full_level = (p[i+2] == 0),
        pad_mode = (p[i+3] == 0) and "momentary" or "toggle",
    }, i+4
end

function parse_preset(p)
    -- Starting at index 9 skips the sysex header.
    local global, i = parse_global(p, 9)

    local pad = {}
    for n = 1,8 do
        pad[n], i = parse_pad(p, i)
    end

    local knob = {}
    for n = 1,8 do
        knob[n], i = parse_knob(p, i)
    end

    return { global = global, pad = pad, knob = knob }
end

function print_as_lua(preset)
    local out = print

    out "-- This is a preset for the Akai LPD8 mk2."
    out "-- See https://github.com/nimblemachines/akai-lpd8 for details."
    out "return {"

    -- Even though we parsed them into a separate table, let's output the
    -- global settings as fields in the main table.
    local g = preset.global
    out(fmt("  channel = %q, pressure = %q, full_level = %q, pad_mode = %q,",
        g.channel, g.pressure, g.full_level, g.pad_mode))

    out "  pad = {"
    for _,p in ipairs(preset.pad) do
        out(fmt("    { note = %q, controller = %q, program = %q, channel = %q, color = { 0x%06x, 0x%06x } },",
            p.note, p.controller, p.program, p.channel, p.color[1], p.color[2]))
    end

    out "  },\n  knob = {"
    for _,k in ipairs(preset.knob) do
        out(fmt("    { controller = %q, channel = %q, range = { %q, %q } },",
            k.controller, k.channel, k.range[1], k.range[2]))
    end

    out "  },\n}"
end

print_as_lua(parse_preset(read_preset()))
