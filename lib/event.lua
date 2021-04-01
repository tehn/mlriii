function event(e)
  if e.type == "play" then
    local g = e.group
    group[g].play = true
    sc.set_play(g)
  elseif e.type == "stop" then
    local g = e.group
    group[g].play = false
    sc.set_play(g)
  elseif e.type == "cut" then -- implied possible chip change
    local t = e.track
    local g = track[t].group
    if t ~= group[g].track then
      group[g].track = t
      sc.set_clip(g)
      sc.set_level(g)
    end
    sc.set_position(g,e.pos)
  end

  ui.dirty = true
  g.dirty = true
end
