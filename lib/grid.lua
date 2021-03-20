alt = false
alt_lock = false

gr = grid.connect()

g = {
  redraw = {},
  key = {},
  dirty = true,
  update = function()
    while true do
      if g.dirty then
        g.dirty = false
        grid_redraw()
      end
      clock.sync(1/60)
    end
  end,
  init = function() clock.run(g.update) end
}

function grid.add() g.dirty = true end


function grid_redraw()
  gr:all(0)
  grid_redraw_nav()
  g.redraw[state.page]()
  gr:refresh()
end

function gr.key(x,y,z)
  -- alt logic
  if x==16 and y==1 then
    if z==1 and alt==false then
      alt = true
      alt_lock = true
    elseif z==1 and alt_lock==true then
      alt = false
    elseif z==0 and alt_lock==false then
      alt = false
    end
    g.dirty = true
  elseif z==1 then alt_lock = false end

  -- nav and page
  if y==1 or y==2 then grid_key_nav(x,y,z)
  else g.key[state.page](x,y,z) end
end


-------- nav (global)

local page_lookup = { track=1, cut=2, clip=3, param=4 }

grid_redraw_nav = function()
  if alt then gr:led(16,1,15) end

  for i=1,4 do
    gr:led(i,1,group[i].play and 10 or 0)
  end

  gr:led(8+page_lookup[state.page],1,15)

  gr:led(12+state.window,2,15)
end

grid_key_nav = function(x,y,z)
  if y==1 then
    if x<5 and z==1 then
      if group[x].play then
        e = {type="stop",group=x}
      else
        e = {type="play",group=x}
      end
      event(e)
    elseif x>8 and x<13 and z==1 then
      set_page(pages[x-8])
    end
  elseif y==2 then
    if x>12 and z==1 then
      set_window(x-12)
    end
  end
end



-------- TRACK

g.redraw.track = function()
  local w = (state.window-1)*6
  for i=1,6 do 
    -- group
    for n=1,4 do gr:led(n,i+2,2) end
    gr:led(track[i+w].group,i+2,10)
    -- octave + rev
    for n=6,14 do gr:led(n,i+2,2) end
    gr:led(10,i+2,0)
    gr:led(16,i+2,2)
    gr:led(track[i+w].octave+10,i+2,10)
    if track[i+w].rev == -1 then gr:led(16,i+2,10) end
  end
end

g.key.track = function(x,y,z)
  local w = (state.window-1)*6
  if z==1 then
    local t = y-2+w
    tr = t
    if x<5 then
      track[t].group = x
    elseif x>5 and x<15 then
      -- FIXME: UPDATE PARAM, but for now:
      track[t].octave = x-10
    elseif x==16 then
      -- FIXME: update PARAM
      track[t].rev = -track[t].rev
    end
    g.dirty = true
    ui.dirty = true
  end
end


-------- CUT

g.redraw.cut = function() end
g.key.cut = function(x,y,z) end


-------- CLIP

g.redraw.clip = function()
  local w = (state.window-1)*6
  for i=1,6 do
    local l = tr==i and 15 or 5
    gr:led(track[i+w].clip,i+2,l)
  end
end

g.key.clip = function(x,y,z)
  local w = (state.window-1)*6
  if z==1 then
    tr = y-2+w
    track[tr].clip = x
    g.dirty = true
    ui.dirty = true
  end
end


-------- PARAM

g.redraw.param = function() end
g.key.param = function(x,y,z) end
