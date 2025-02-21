# Welcome to the Akai LPD8 project!

I wanted to gather in one place documentation of the communication protocols
for the Akai LPD8 (original) and Akai LPD8 mk2.

I am also trying to write some simple tools - most likely using [puredata
(Pd)](https://msp.ucsd.edu/Pd_documentation/), [Lua](https://www.lua.org/),
and [muforth](https://muforth.dev/) - to read and write the presets.

## Akai protocols

There are several documents on the [Akai Pro downloads
page](https://www.akaipro.com/downloads) that talk about the basic structure
of the protocols for any of their devices.

There are essentially only two variants: a universal "tell me who you are",
and a basic _structure_ for model-specific system exclusives.

The first one - who are you? - is the MIDI Machine Control (MMC) "device
enquiry" message, and is encoded like this:

```
f0 7e 00 06 01 f7
```

The details of the response aren't that interesting - with one exception: the
sixth and seventh bytes - offsets 5 and 6 - are the manufacturer's ID (47 in
the case of Akai) and the model ID (4c for the LPD8 mk2; 75 for the original
LPD8).

Much more interesting are the model-specific system exclusive messages. For
both of the LPD8 devices, those are the "get preset" and "set preset"
messages. This is what the next sections will concentrate on, starting with
the newer device, the LPD8 mk2.

### LPD8 mk2 communication protocol

There are two commands: get preset (03), and set preset (01).

Get preset looks like this:

```
f0 47 7f 4c 03 00 01 pp f7
```

The 4c value is the product model number (the LPD8 mk2). pp is the preset
number. The presets stored in the flash memory are numbered 01 to 04; preset
00 is a temporary "RAM" preset that isn't stored anywhere, but can be useful
or trying things out or testing the preset setting code!

The LPD8 mk2 answers the get preset sysex with a sysex message of its own:

```
f0 47 7f 4c 03 01 29 pp <preset data> f7
```

The 01 29 encodes the payload data length - it counts everything after the
length and before the f7. Because this is MIDI, any value greater than 7f
has to be encoded in two bytes: the first byte contains the high bit (ie, its
value is either 00 or 01), and the second byte contains the low 7 bits.

Thus, 01 29 encodes 80 (hex) + 29 (hex) = 169 (decimal).

pp is the preset number (between 00 and 04).

The preset data has four parts: global settings (4 bytes), pad settings (8
pads, 32 bytes each), and knob settings (8 knobs, 4 bytes each).

The preset data consumes 164 bytes. When we include the one-byte preset
number, the total payload is then 165 bytes. 

This means that the payload length that the device sends (and mostly likely
expects) is actually _wrong_! I'm not sure why the engineers added four to the
correct length!

The four bytes of global settings are as follows:

* global channel (0 to 15, representing channel 1 to 16, in the usual MIDI
  fashion)
* pressure messages (0 = off, 1 = channel, 2 = polyphonic)
* full level (0 = on, 1 = off). On means note velocities and controller values
  are only 0 or 127. Off means the normal range of 0 to 127.
* pad mode (0 = momentary, 1 = toggle). In _momentary_ mode the pad sends
  a note-on when pressed, followed by a note-off when the pad is released. In
_toggle_ mode the pad sends a note-on when pressed, and does nothing until the
pad is released and pressed a second time; the second press sends the
note-off. This behavior only applies when sending note messages from the pads;
if you are sending controller or program change messages, the pad is in
_momentary_ mode.

Each pad has the following settings:

* note number (one byte)
* controller number (one byte)
* program change number (one byte). It seems that 00 means program 1, 01
  means program 2, etc. Like channel numbers.
* channel number. 0 to 15 to specify channel 1 to 16, or 16 to use the global
  channel number (which was set by the first byte of the preset data).
* two RGB values: off (not pressed) and on (pressed). Each RGB value is
  a 24-bit color. Each 8 bit R, G, and B component is encoded like the data
payload length and thus takes _two_ bytes: the first byte contains the 8th
bit; the second byte contains the low 7 bits.

Each knob has the following settings:

* controller number (one byte)
* channel number (like with the pads, this takes values from 0 to 15 to
  specify a channel, or 16 to specify the global channel).
* range (two bytes: low, then high)

Thanks are due to [Stephen Martin](https://github.com/stephensrmmartin) and his
[lpd8mk2](https://github.com/stephensrmmartin/lpd8mk2) project for doing the
hard work of capturing and documenting the USB traffic between Akai's LPD8 mk2
editor program and the device. See in particular the
[README](https://github.com/stephensrmmartin/lpd8mk2/blob/master/README.md)
and [sysex
capture](https://raw.githubusercontent.com/stephensrmmartin/lpd8mk2/refs/heads/master/docs/sysex_captures.md)
files.

### LPD8 (original) communication protocol

I don't have an original LPD8, so I can't vouch for these results or test
them. All of this data comes from [Benjamin
Graf](https://github.com/bennigraf)'s
[lpd8-web-editor](https://github.com/bennigraf/lpd8-web-editor) project. His
[LPD8 protocol
documentation](https://github.com/bennigraf/lpd8-web-editor/blob/main/lpd8-protocol.md)
should prove invaluable to anyone interfacing with this device.

As with the mk2, there are two commands: get preset (63), and set preset (61).

Get preset looks like this:

```
f0 47 7f 75 63 00 01 pp f7
```

The 75 value is the product model number (the original LPD8). pp is the
preset number. The presets stored in the flash memory are numbered 01 to 04.
I'm not sure if the original has a temporary/RAM (00) preset or not.

The LPD8 answers the get preset sysex with a sysex of its own:

```
f0 47 7f 75 63 00 3a pp <preset data> f7
```

pp is the preset number requested and the preset data is as follows:

* channel number
* pad data (8 pads)
* knob data (8 knobs)

For each pad: note number, program change number, controller number,
mode (0 = momentary, 1 = toggle) (4 bytes total).

For each knob: controller number, range (low followed by high) (3 bytes
total).

The 00 3a is the data payload length: 58 bytes.

The set preset is exactly like the get preset, except the 63 is replaced by
61 and the preset number and preset data is sent to, rather than received
from, the device. Easy peasy!
