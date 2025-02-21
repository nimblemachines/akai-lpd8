-- This is a preset for the Akai LPD8 mk2.
-- See https://github.com/nimblemachines/akai-lpd8 for details.

-- I copied the default preset 3 and added some wacky colors and unusual
-- channel settings.

-- The Solarized colors are "nice", but hard to distinguish. Likewise, the
-- channel settings are weird and completely pointless; however, in both
-- cases this shows what is possible.

-- Since this is Lua code, for any setting we can use variables if we like!

-- Solarized colors?!?
local red     = 0xdc322f
local orange  = 0xcb4b16
local yellow  = 0xb58900
local cyan    = 0x2aa198
local blue    = 0x268bd2  
local green   = 0x859900  
local magenta = 0xd33682
local violet  = 0x6c71c4

return {
  channel = 11, pressure = "poly", full_level = false, pad_mode = "momentary",
  pad = {
    { note = 36, controller = 12, program = 1, channel = 2, color = { red, blue } },
    { note = 37, controller = 13, program = 2, channel = 3, color = { orange, cyan } },
    { note = 38, controller = 14, program = 3, channel = 4, color = { yellow, violet } },
    { note = 39, controller = 15, program = 4, channel = 5, color = { green, magenta } },
    { note = 40, controller = 16, program = 5, channel = "global", color = { blue, red } },
    { note = 41, controller = 17, program = 6, channel = "global", color = { cyan, orange } },
    { note = 42, controller = 18, program = 7, channel = "global", color = { violet, yellow } },
    { note = 43, controller = 19, program = 8, channel = "global", color = { magenta, green } },
  },
  knob = {
    { controller = 70, channel = 6, range = { 0, 127 } },
    { controller = 71, channel = 7, range = { 0, 127 } },
    { controller = 72, channel = 8, range = { 0, 127 } },
    { controller = 73, channel = 9, range = { 0, 127 } },
    { controller = 74, channel = "global", range = { 0, 127 } },
    { controller = 75, channel = "global", range = { 0, 127 } },
    { controller = 76, channel = "global", range = { 0, 127 } },
    { controller = 77, channel = "global", range = { 0, 127 } },
  },
}
