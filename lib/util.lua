function set_page(x)
  state.page = x
  ui.dirty = true
  g.dirty = true
end

function set_window(x)
  state.window = x
  ui.dirty = true
  g.dirty = true
end


