ef = {} -- event function

ef.play = function(data)
  local g = data.group
  group[g].play = true
  sc.set_play(g)
end

ef.stop = function(data)
  local g = data.group
  group[g].play = false
  sc.set_play(g)
end

ef.cut = function(data)
  local t = data.track
  local g = track[t].group
  if t ~= group[g].track.n then
    group[g].track = track[t]
    sc.set_clip(g)
    sc.set_level(g)
  end
  sc.set_position(g,e.pos)
end

ef.octave = function(data)
  track[data.track].octave = data.octave
end

ef.reverse = function(data)
  track[data.track].rev = -track[data.track].rev
end

function event(e)
  ef[e.type](e)

  ui.dirty = true
  g.dirty = true
end
