# mlr

## TODO

NOW
  - transpose param needs to be OPTION
    - display correctly ie re-build options based on trans_n and trans_d tables (also put in params)

FIXES/IDEAS/WHAT
  - CUT, show stopped play position if group START would resume there
    - RESUME needs a new softcut function to get current position (async) to store for future resume
  - params: sync with data. which to add and where.
  - FADES?
  - alt+enc val edit = global? ie for levels, overdub/etc
  - mute (group) or use meta/pattern


- TRACK
  - PLAYING/RECORDING vis?
  - screen ui ALT edit menu: overdub (group), #steps, cut mode, bmp follow/map
  
- CUT
  - grid key loop set
  - cut mode: cut/clearloop, cut/moveloop, cut/stop(at end or loopend), momentary
  - screen ui: waveform, playback position (obey follow). cut mode.
  - alt shapes:
    - select/follow single tap (ie, quiet select)
    - octave shift(1+,1-), reverse(1--,1++), stop(321)

- CLIP
  - adjust clip positions/len/ch (with quantization?)
  - waveform (full and region)
  - ALT
    - export clip/all
    - clear clip/all
    - reset all positions (len/separation settings? currently 2s/0sep. bar size? bpm?)
    ? move clip start to end of previous clip

- REC
  - rec enables/disables record
  - alt+rec: rec single loop (ie, set length at second rec touch) --- hint: use Q
  - overdub setting (preserve existing)

- QUEUE: like recall but one-off. tap once, queue a bunch of whatever. tap again: does all at once.
  - alt-queue: redo last (if stopped) or cancel (if rec'ing)

- Q1/Q2: toggle between and off. if held then event-pressed, toggle off after. alt-q to config (while held) with e2/e3
  - blink tempo divisions
  - new events hit queue quantizer before pattern recorders
    - might need an event origin var (live vs. pattern)

- PATTERN
  - pattern: tap to start, tap to stop (use q's)
  - empty. alt-start = recall
  - recording. alt-stop = cancel/clear
  - data/stopped. alt-start = clear
  - X some sort of arp-quantization? ie step input w/ playback rate modulation.
  - X pattern modifications (?) ie quantize, modulate rate


- PARAM
  - show one track (for recall/patterns event recording)
  - volume, pan, filter, transpose, detune, $echo
  - slews?




- BONUS
  - echo
  - transpose scale: set as ratios (et is x/12)

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

## modes (screens)

E1: track selector
E2/E3 scroll/edit params

- A track --- 4:group bpm-follow(menu?) 9:octave rev
- B cut
- C clip
- D param: level, pan, transpose, filter, echo

## q

- queue: like recall but one-off. tap once, queue a bunch of whatever. tap again: does all at once.
	- alt-queue: redo last (if stopped) or cancel (if rec'ing)
- q1/q2: toggle between and off. if held then event-pressed, toggle off after. alt-q to config (while held) with e2/e3
- blink tempo

## alt

- tap alone to toggle (blink fast to indicate latched). hold+key(s) releases after

### cut mode

- alt = shapes. octave up/down. rev.

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