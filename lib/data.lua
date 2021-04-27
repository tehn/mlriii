FADE = 0.01

EMAP = {"level", "pan", "detune", "transpose"}

trans_n = {-4,-3,-2,-1,0,1,2,3,4,5,6,7,8,9,10,11}
trans_d = {12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12}

state = {
  page = "track",
  window = 1,
  emap = {1,2},
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
  local g = {1,2,3,3,4,4, 1,1,1,2,3,4, 1,1,1,2,2,2, 1,1,1,1,1,1}
  track[i] = {
    n = i,
    group = g[i],
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
    transpose = 5,
    transpose_ratio = 0, -- this is just pre-computed from the table
    detune = 0,
    rev = 1,
    bpm_sync = false,
    bpm_mod = 1.0,
  }
end

group = {}

for i=1,4 do
  local t = {1,2,3,5}
  group[i] = {
    play = false,
    rec = false,
    overdub = 0.5,
    input = 1.0,
    level = 1.0,
    --pan = 0,
    mute = 1,
    track = track[t[i]],
    position = 0,
    pos_grid = 0
  }
end



function calc_cuts(t)
  track[t].cuts = {}
  local stepsize = track[t].clip.len / track[t].steps
  for i=1,track[t].steps do
    track[t].cuts[i] = track[t].clip.pos_start + (i-1)*stepsize
  end
end

function restore_clip(c)
  clip[c].len = 40
  clip[c].pos_end = clip[c].pos_start + 40
  for i=1,4 do --refresh possibly active group-track-clip
    if c == group[i].track.clip.n and group[i].play then sc.set_clip(i) end
  end
  for i=1,24 do -- recalc cuts for tracks using clip
    if track[i].clip.n == c then calc_cuts(i) end
  end
end


function set_level(i,x)
  track[i].level = x
  local g = group[track[i].group]
  if g.track.n == i and g.play then
    sc.set_level(i)
  end
end

function set_pan(i,x)
  track[i].pan = x
  local g = group[track[i].group]
  if g.track.n == i and g.play then
    sc.set_level(i)
  end
end

function set_detune(i,x)
  track[i].detune = x
  local g = group[track[i].group]
  if g.track.n == i and g.play then
    sc.set_rate(i)
  end
end

function set_transpose(i,x)
  track[i].transpose = x
  track[i].transpose_ratio = trans_n[x] / trans_d[x]
  local g = group[track[i].group]
  if g.track.n == i and g.play then
    sc.set_rate(i)
  end
end



data = {}

function data.init()
  for i=1,24 do calc_cuts(i) end

  for i=1,24 do
    params:add_group(i.."track",4)
    params:add_control(i.."level", i.."level", 
      controlspec.new(0, 1, 'lin', 0, 1, ""))
    params:set_action(i.."level", function(x) set_level(i,x) end)
    params:add_control(i.."pan", i.."pan", 
      controlspec.new(-1, 1, 'lin', 0, 0, ""))
    params:set_action(i.."pan", function(x) set_pan(i,x) end)
    params:add_control(i.."detune", i.."detune", 
      controlspec.new(-1, 1, 'lin', 0, 0, ""))
    params:set_action(i.."detune", function(x) set_detune(i,x) end)
    params:add_number(i.."transpose", i.."transpose", 1,16, 5)
    params:set_action(i.."transpose", function(x) set_transpose(i,x) end)
  end
end
