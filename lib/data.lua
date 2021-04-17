FADE = 0.01

state = {
  page = "track",
  window = 1,
  menusel = 1,
  follow = false,
  clipimport = "whole", -- vs. "part",
  clipaction = "", -- "clear" or "load"
  clipactiontimer = nil
}

pages = {"track", "cut", "clip", "param"}

clip = {}

for i=1,16 do
  local l = 40
  local s = 1+((i-1)%8)*l -- leave first second for fades, mod 8 to span two channels
  clip[i] = {
    n = i,
    pos_start = s,
    pos_end = s + l,
    len = l,
    ch = math.floor((i-1)/8)+1,
    name = "clip-"..string.format("%02d",i)
  }
end

track = {}

for i=1,24 do
  track[i] = {
    n = i,
    group = ((i-1)%4)+1,
    clip = clip[((i-1)%16)+1],
    mode = "normal", -- also "shift" (move loop) "hold" (slice)
    loop = true,
    loop_start = 1,
    loop_end = 16,
    loop_len = 16,
    steps = 16,
    cuts = {},
    level = 1.0,
    pan = 0,
    --filter
    --echo
    octave = 0,
    transpose = 0,
    detune = 0,
    rev = 1,
    bpm_sync = false,
    bpm_mod = 1.0,
    pos_grid = 0
  }
end

group = {}

for i=1,4 do
  group[i] = {
    play = false,
    rec = false,
    overdub = 0,
    input = 1.0,
    level = 1.0,
    pan = 0,
    mute = 1,
    track = track[i]
  }
end



function calc_cuts(t)
  track[t].cuts = {}
  local stepsize = track[t].clip.len / track[t].steps
  for i=1,track[t].steps do
    track[t].cuts[i] = track[t].clip.pos_start + (i-1)*stepsize
  end
end

data = {}

function data.init()
  for i=1,24 do calc_cuts(i) end
end
