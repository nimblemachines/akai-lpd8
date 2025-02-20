-- This is a preset for the Akai LPD8 mk2.
return {
  channel = 1, pressure = "poly", full_level = false, pad_mode = "momentary",
  pad = {
    { note = 36, controller = 12, program = 1, channel = 10, color = { 0x00ff00, 0xff0000 } },
    { note = 37, controller = 13, program = 2, channel = 10, color = { 0x00ff00, 0xff0000 } },
    { note = 38, controller = 14, program = 3, channel = 10, color = { 0x00ff00, 0xff0000 } },
    { note = 39, controller = 15, program = 4, channel = 10, color = { 0x00ff00, 0xff0000 } },
    { note = 40, controller = 16, program = 5, channel = 10, color = { 0x00ff00, 0xff0000 } },
    { note = 41, controller = 17, program = 6, channel = 10, color = { 0x00ff00, 0xff0000 } },
    { note = 42, controller = 18, program = 7, channel = 10, color = { 0x00ff00, 0xff0000 } },
    { note = 43, controller = 19, program = 8, channel = 10, color = { 0x00ff00, 0xff0000 } },
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
