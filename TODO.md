# mlr

## TODO

- CUT, show stopped play position if group START would resume there
- params: sync with data

---


## grid: function rows:

- 4:stop 4:rec mode:abcd queue q1 q2 alt
  12:patr 4:page

## tracks

- 24 total, 6x4.
- values: group, clip, octave, rev, level, pan, filter, transpose, echo, # of steps
- state: loop-st, loop-end
- setting: bpm map
- setting: steps (default 16)

## clips

- 16 total, 40sec each if evenly split
- use both channels
- values: start, stop, dur, ch
- interface to change clip positions/len/ch. quantized and unquantized.
- file import at clip position: trim to clip size, or whole clip
- pset includes optional tape load
	- external "save" function which sets audio path param and sets load flag param
- clip export (mono/stereo)
- clear buffer
- reset clip positions (bar size, spacing)
- clip position, move to end of previous clip


## groups

- "voice" ie mute group
- stop/play buttons on top row
	stopped. alt-play = cut to loop start (resume otherwise?)
	stopped. alt-rec = rec single loop (ie, set length at second rec touch) --- hint: use Q
- setting: play mode: cut-clear, cut-move, moment
- setting: rec mode:
- // stereo modes: 1+2, 3+4 (each optional) selector lights up 1+2 and 3+4

## modes (screens)

E1: track selector
E2/E3 scroll/edit params

- A track --- 4:group bpm-follow(menu?) 9:octave rev
- B cut
- C clip
- D param: level, pan, transpose, filter, echo
	E2 change-param (K2/K3 also) E3 modify

## q

- queue: like recall but one-off. tap once, queue a bunch of whatever. tap again: does all at once.
	- alt-queue: redo last (if stopped) or cancel (if rec'ing)
- q1/q2: toggle between and off. if held then event-pressed, toggle off after. alt-q to config (while held) with e2/e3
- blink tempo

## alt

- tap alone to toggle (blink fast to indicate latched). hold+key(s) releases after

### cut mode

- alt = shapes. octave up/down. rev. stop/start.

### clip mode

- alt = shapes. resize? clear?
- E1=track E2/E3 assignable params (menu onscreen?)

## pattern-recall

- pattern: tap to start, tap to stop (use q's)
- empty. alt-start = recall
- recording. alt-stop = cancel/clear
- data/stopped. alt-start = clear
- some sort of arp-quantization? ie step input w/ playback rate modulation.
- pattern modifications (?) ie quantize, modulate rate


## else

- scales for transpose
