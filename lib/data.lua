state = {
  page = "track",
  window = 1,
}

pages = {"track", "cut", "clip", "param"}

clip = {}

for i=1,16 do
  clip[i] = {
    n = i,
    pos_start = (i-1)*4,
    pos_end = i*4,
    len = 4,
    ch = 1,
    name = "clip"..i -- TODO leading zeroes
  }
end

track = {}

for i=1,24 do
  track[i] = {
    n = i,
    group = ((i-1)%4)+1,
    clip = clip[((i-1)%8)+1],
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
    rev = 1,
    bpm_sync = false,
    bpm_mod = 1.0,
    rate_mod = 1.0,
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
