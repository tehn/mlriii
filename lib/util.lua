tab = require("tabutil")

function set_page(x)
  state.page = x
  state.menusel = 1
  ui.dirty = true
  g.dirty = true
end

function set_window(x)
  state.window = x
  ui.dirty = true
  g.dirty = true
end

function strdec2(x)
  return string.format("%.2f",x)
end
