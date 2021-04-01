-- mlriii
-- 1.0.0 @tehn
-- l.llllllll.co/mlriii

p = params
s = softcut

fileselect = require("fileselect")

include("lib/util")
include("lib/data")
include("lib/event")
include("lib/ui")
include("lib/grid")
include("lib/sc")

function init()
  ui.init()
  g.init()
  sc.init()
  data.init()
end
