alt = false
alt_lock = false

keycount = 0

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
      clock.sleep(1/60)
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
  keycount = keycount + z
  -- alt logic
  if x==16 and y==1 then
    if z==1 and alt==false then
      keycount = 0
      alt = true
    elseif z==1 and alt_lock==true then
      alt = false
    elseif z==0 and alt_lock==false then
      if keycount == 0  then
        alt_lock = true
      else alt = false end
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
        event({type="stop",group=x})
      else
        --TODO: resume
        --event({type="play",group=x}) 
      end
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
    local grp = track[i+w].group
    -- group
    for n=1,4 do gr:led(n,i+2,alt and 3 or 2) end -- background highlight
    gr:led(grp,i+2,5) -- selected group
    if group[grp].track.n == i+w then
      gr:led(grp,i+2,group[grp].play and 15 or 10) -- active track in group
    end
    -- show active edit track (ui)
    if tr==i+w then
      gr:led(5,i+2,state.follow and 7 or 4)
    end
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
    if state.follow then tr = t end
    if x<5 then
      if alt then
        print("ALT")
        local prev = track[t].group
        if prev ~= x then
          track[t].group = x
          if group[prev].track.n == t and group[prev].play then
            -- bypass event system and stop group immediately
            sc.off(prev)
            group[prev].play = false
          end
        end
      else
        event({type="cut",track=t,pos=1})
      end
    elseif x==5 then
      if alt then
        state.follow = not state.follow
      else
        tr = t
      end
    elseif x>5 and x<15 then
      -- FIXME: UPDATE PARAM, but for now:
      event({type="octave",track=t,octave=x-10})
    elseif x==16 then
      -- FIXME: update PARAM
      event({type="rev",track=t})
    end
    g.dirty = true
    ui.dirty = true
  end
end


-------- CUT

g.redraw.cut = function()
  local w = (state.window-1)*6
  for i=1,6 do
    local t = w+i
    local y = i + 2
    local x = track[t].pos_grid
    local g = track[t].group
    if group[g].play and group[g].track.n == t then
      gr:led(x,y,15)
    end
  end
end

g.key.cut = function(x,y,z)
  if z==1 then
    local w = (state.window-1)*6
    local t = y-2+w
    local g = track[t].group
    event({type="cut",track=t,pos=x})
    event({type="play",group=g})
  end
end


-------- CLIP

g.redraw.clip = function()
  local w = (state.window-1)*6
  for i=1,6 do
    local l = tr==i and 15 or 5
    gr:led(track[i+w].clip.n,i+2,l)
  end
end

g.key.clip = function(x,y,z)
  local w = (state.window-1)*6
  if z==1 then
    tr = y-2+w
    track[tr].clip = clip[x]
    if group[track[tr].group].play then
      sc.set_clip(track[tr].group)
    end
    calc_cuts(tr)
    g.dirty = true
    ui.dirty = true
  end
end


-------- PARAM

g.redraw.param = function() end
g.key.param = function(x,y,z) end
