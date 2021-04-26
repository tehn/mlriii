ef = {} -- event function

ef.resume = function(data)
  local g = data.group
  --local t = track[t].group
  --if t ~= group[g].track.n or group[g].play == false then
    ----group[g].track = track[t]
    group[g].play = true
    sc.set_clip(g)
    sc.set_rate(g)
    sc.set_level(g)
  --end
  sc.resume_position(g)
end

ef.stop = function(data)
  local g = data.group
  softcut.query_position(g)
  group[g].play = false
  sc.off(g)
end

ef.cut = function(data)
  local t = data.track
  local g = track[t].group
  if t ~= group[g].track.n or group[g].play == false then
    group[g].track = track[t]
    group[g].play = true
    sc.set_clip(g)
    sc.set_level(g)
    sc.set_rate(g)
  end
  sc.cut_position(g,data.pos)
end

ef.octave = function(data)
  track[data.track].octave = data.octave
  local g = track[data.track].group
  if group[g].play == true and track[data.track].n == group[g].track.n then
    sc.set_rate(g)
  end
end

ef.rev = function(data)
  track[data.track].rev = -track[data.track].rev
  local g = track[data.track].group
  if group[g].play == true and track[data.track].n == group[g].track.n then
    sc.set_rate(g)
  end
end

ef.rec = function(data)
  local g = data.group
  group[g].rec = not group[g].rec
  sc.set_play(g)
end

ef.resize = function(data)
  local g = data.group
  group[g].resize_clip = group[g].track.clip.n
  softcut.query_position(g)
end
  

function event(e)
  ef[e.type](e)

  ui.dirty = true
  g.dirty = true
end
