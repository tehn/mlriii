state = {
  page = "track",
  window = 1,
}

pages = {"track", "cut", "clip", "param"}


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
    track = 1
  }
end

track = {}

for i=1,24 do
  track[i] = {
    group = 1,
    clip = 1,
    mode = "normal", -- also "shift" (move loop) "hold" (slice)
    loop = true,
    loop_start = 1,
    loop_end = 16,
    loop_len = 16,
    steps = 16,
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


clip = {}

for i=1,16 do
  clip[i] = {
    pos_start = (i-1)*2,
    pos_end = i*2,
    len = 2,
    ch = 1,
    name = i
  }
end
