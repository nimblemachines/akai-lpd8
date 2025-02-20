-- From a Lua table representing an LPD8 mk2 preset, generate a file of
-- integers (representing bytes) that can be sent, eg by pure data, to the
-- device.

-- The generated file does *not* include the system exclusive (sysex)
-- header necessary for the device to recognize this as a preset. That job
-- is done externally - again, eg, by pure data.

-- Output a MIDI byte - which really means a 7-bit value.
function byte(n)
    print(n & 127)
end

-- Output as two 7-bit bytes a value that is potentially larger than 127.
function big(n)
    byte(n >> 7)
    byte(n)
end

-- Color component. Make sure it is only a byte of data.
function comp(c)
    big(c & 255)
end

function rgb(color)
    comp(color >> 16)
    comp(color >> 8)
    comp(color)
end

function chan(ch)
    byte((ch == "global") and 16 or (ch - 1))
end

pressure_to_num = {
    none = 0,
    channel = 1,
    poly = 2,
}

function print_as_nums(preset)
    -- Global settings first.
    byte(preset.channel - 1)
    byte(pressure_to_num[preset.pressure])
    byte(preset.full_level and 0 or 1)
    byte((preset.pad_mode == "momentary") and 0 or 1)
    
    -- Pads.
    for _, p in ipairs(preset.pad) do
        byte(p.note)
        byte(p.controller)
        byte(p.program - 1)
        chan(p.channel)
        rgb(p.color[1])
        rgb(p.color[2])
    end

    -- Knobs.
    for _, k in ipairs(preset.knob) do
        byte(k.controller)
        chan(k.channel)
        byte(k.range[1])
        byte(k.range[2])
    end
end


-- Read the file mentioned on the command line as a preset and then print
-- it out as a series of integers.
print_as_nums(dofile(arg[1]))

