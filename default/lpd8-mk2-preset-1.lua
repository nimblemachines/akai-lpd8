-- This is a preset for the Akai LPD8 mk2.
-- See https://github.com/nimblemachines/akai-lpd8 for details.
return {
  channel = 1, pressure = "none", full_level = false, pad_mode = "momentary",
  pad = {
    { note = 36, controller = 12, program = 1, channel = 10, color = { 0xff0000, 0x0000ff } },
    { note = 37, controller = 13, program = 2, channel = 10, color = { 0xff0000, 0x0000ff } },
    { note = 38, controller = 14, program = 3, channel = 10, color = { 0xff0000, 0x0000ff } },
    { note = 39, controller = 15, program = 4, channel = 10, color = { 0xff0000, 0x0000ff } },
    { note = 40, controller = 16, program = 5, channel = 10, color = { 0xff0000, 0x0000ff } },
    { note = 41, controller = 17, program = 6, channel = 10, color = { 0xff0000, 0x0000ff } },
    { note = 42, controller = 18, program = 7, channel = 10, color = { 0xff0000, 0x0000ff } },
    { note = 43, controller = 19, program = 8, channel = 10, color = { 0xff0000, 0x0000ff } },
  },
  knob = {
    { controller = 70, channel = "global", range = { 0, 127 } },
    { controller = 71, channel = "global", range = { 0, 127 } },
    { controller = 72, channel = "global", range = { 0, 127 } },
    { controller = 73, channel = "global", range = { 0, 127 } },
    { controller = 74, channel = "global", range = { 0, 127 } },
    { controller = 75, channel = "global", range = { 0, 127 } },
    { controller = 76, channel = "global", range = { 0, 127 } },
    { controller = 77, channel = "global", range = { 0, 127 } },
  },
}
