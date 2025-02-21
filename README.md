# Welcome to the Akai LPD8 project!

I wanted to gather in one place documentation of the communication protocols
for the Akai LPD8 (original) and Akai LPD8 mk2.

I am also trying to write some simple tools - using [puredata
(Pd)](https://msp.ucsd.edu/Pd_documentation/) and [Lua](https://www.lua.org/)
- to read and write the presets.

Since most people reading this probably aren't interested in the protocols,
let's start with the tools.

## Tools of the trade

I wanted to be able to do three things: read presets from the device, write
presets to the device, and convert between the stream-of-bytes format that the
device wants to exchange and something more suitable to reading, writing,
editing, and archiving by _humans_.

I initially wanted to use [muforth](https://muforth.dev/) for the reading and
writing process, as it's a nice tool for this kind of work. As I have been
using [WSL (the Windows Subsystem for
Linux)](https://learn.microsoft.com/en-us/windows/wsl/about) for a lot of my
work lately, I connected the device to my Windows 11 machine and passed it
through to Linux, but the Linux kernel failed to recognize it. I think there
are drivers missing from the kernel used by WSL. While I have already
successfully compiled and used my own Linux kernel for WSL (I wanted to add
a USB serial device), I could not quickly figure out how to add the drivers
I needed, so I looked for another approach.

I knew about puredata (aka Pd), and I used its predecessor Max decades ago;
there is a Windows version, and installing it was easy. It's a bit clunky, and
I had to mess around to make the interface something other than unreadably
tiny, but I got it working, plugged in the LDP8, and was quickly seeing MIDI
when using Pd's "Test audio and MIDI" patch.

Within a day of messing around I was able to send a sysex message to the
device and read one of the presets. After a second day I managed to send a sysex
to _set_ a preset. On the third day I wrote some Lua code to convert between
numeric and human-readable formats.

The tools are simple, perhaps a bit primitive, but eminently useful. And,
after all, this isn't something you do every day. You figure out how you
intend to use the device, you write a few presets, program them, and then
forget about it.

The Pd code lives in the `puredata/` subdirectory, and consists of three patch
files:

* `puredata/input-test.pd`
* `puredata/sysex-in-experiments.pd`
* `puredata/set-presets.pd`

This is probably the order you will want to use them in. `input-test` is great
for testing that Pd is getting input. You can see which channels the LPD8 is
using, which note or controller is being used by a pad or knob, etc.

`sysex-in-experiments` should perhaps be renamed, since it is past the point
of experiments. If you press the message boxes numbered 1 through 4, where it
says "get preset #" in the middle-right of the patch, it will request each
patch from the device and store it in a file. The patch assumes that this
project lives directly in your home directory; the destination file for each
patch is `~/akai-lpd8/lpd8-mk2-get-preset-<n>.txt`.

This file contains a sysex message, encoded as a series of integers. This is
also the form consumed by `puredata/set-presets.pd`, which is used to send
presets to the device. But first you have to create one - assuming the default
factory four don't meet your needs.

The second set of tools are two Lua scripts for converting between streams of
ints and relatively friendly Lua tables:

* `lua/parse-mk2-preset.lua`
* `lua/gen-mk2-preset.lua`

Parse turns a stream-of-ints into Lua; gen goes the other way.

As an example, try the following. Assuming you have used Pd to get the four
factory presets, you can convert one and print it out, like this:

```
lua lua/parse-mk2-preset.lua < lpd8-mk2-get-preset-<n>.txt
```
(Note the redirected input.)

It should print out a nicely-formatted version of the preset. By redirecting
the output to a file and editing the resulting Lua code, you now have a way to
easily create a set of custom presets (and check them into version control or
whatever).

Once you have a preset you like in Lua form, just do

```
lua lua/gen-mk2-preset.lua path/to/preset.lua > lpd8-mk2-set-preset-<n>.txt
```

(Note that, in this case, the input is _not_ redirected.)

n can range from 0 to 4. The zeroth preset is a temporary "RAM-based" one; it
changes the current settings, but these go away when switching to another
preset or power cycling. However, it can be a nice way to test things out
without disturbing the existing presets.

Unfortunately, the Pd code expects preset files (in a stream-of-ints form,
ready to send to the device) named in the style shown above. Once you put the
file(s) in place, open `puredata/set-presets.pd` and press one of the "set
preset" message boxes (marked 1 to 4 or 0).

## Akai protocols

In case you _are_ here for the protocols, here are the gory details.

There are several documents on the [Akai Pro downloads
page](https://www.akaipro.com/downloads) that talk about the basic structure
of the protocols for all of their devices.

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

Much more interesting are the model-specific system exclusive messages. They
all have exactly the same form:

```
f0  Begin system exclusive
47  Akai manufacturer ID
7f  Broadcast (any connected device with correct model ID)
ii  Model ID (this is 75 for LPD8 and 4c for LPD8 mk2)
mm  Message type (in our case, get preset or set preset)
aa  High 7 bits of payload length
bb  Low 7 bits of payload length
..
..  Payload data
..
f7  End system exclusive

For both of the LPD8 devices, those are the "get preset" and "set preset"
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
