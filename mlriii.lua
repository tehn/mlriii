-- mlr
-- 3.0.0 @tehn
-- l.llllllll.co/mlr

p = params
s = softcut

fileselect = require("fileselect")

include("lib/data")
include("lib/event")
include("lib/ui")
include("lib/grid")
include("lib/sc")

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

num = 0
num2 = 0
num3 = 1


function init()
  ui.init()
  g.init()
  sc.init()
end
