function event(e)
  if e.type == "play" then
    local g = e.group
    group[g].play = true
    sc.set_play(g)
  elseif e.type == "stop" then
    local g = e.group
    group[g].play = false
    sc.set_play(g)
  end

  ui.dirty = true
  g.dirty = true
end
