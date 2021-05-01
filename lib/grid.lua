alt = false
alt_lock = false
altkeycount = 0

held = {0,0,0,0,0,0}
queue = {{},{},{},{},{},{}}
keystate = {
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0} }

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
  altkeycount = altkeycount + z -- counter for alt hold
  -- held/state logic for gesture tracking
  if y>2 then
    local row = y-2
    keystate[row][x] = z
    held[row] = 0
    for i=1,16 do
      held[row] = held[row] + keystate[row][i]
    end
    queue[row][held[row]] = x -- sortof a queue
  end
  -- alt logic
  if x==16 and y==1 then
    if z==1 and alt==false then
      altkeycount = 0
      alt = true
    elseif z==1 and alt_lock==true then
      alt = false
    elseif z==0 and alt_lock==false then
      if altkeycount == 0  then
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

grid_redraw_nav = function()
  if alt then gr:led(16,1,15) end

  for i=1,4 do
    gr:led(i,1,group[i].play and 10 or 0)
    gr:led(i,2,group[i].rec and (group[i].play and 10 or 3) or 0)
  end

  for i=5,12 do gr:led(i,1,3) end
  gr:led(4+page_lookup[state.page],1,15)

  gr:led(12+state.window,2,15)
end

grid_key_nav = function(x,y,z)
  if y==1 then
    if x<5 and z==1 then
      if group[x].play then
        event({type="stop",group=x})
      else
        event({type="resume",group=x}) 
      end
    elseif x>4 and x<13 and z==1 then
      set_page(pages[x-4])
    end
  elseif y==2 then
    if x<5 and z==1 then
      if alt then
        if group[x].rec and group[x].play then
          event({type="resize",group=x}) 
        elseif not group[x].rec and not group[x].play then
          restore_clip(group[x].track.clip.n)
        end
      else
        event({type="rec",group=x})
      end
    elseif x>12 and z==1 then
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


-------- CUT

g.redraw.cut = function()
  local w = (state.window-1)*6
  for i=1,6 do
    local t = w+i
    local y = i + 2
    local g = track[t].group
    local x = group[g].pos_grid
    if group[g].track.n == t then
      if track[t].loop then -- highlight loop
        for i=track[t].loop_start,track[t].loop_end do
          gr:led(i,y,3)
        end
      end
      if group[g].play then
        gr:led(x,y,15) -- playing
      else
        gr:led(x,y,5) -- stopped but active
      end
    end
  end
end

g.key.cut = function(x,y,z)
  local row = y-2
  local w = (state.window-1)*6
  local t = track[y-2+w]
  local g = t.group
  if z==1 then
    if state.follow then tr = t end
    -- FIXME: all of this needs x limited to steps
    -- FIXME: THESE LOOP SETS MUST BE EVENTS
    if t.mode == "normal" then
      if held[row] == 1 then
        event({type="cut",track=t.n,pos=x})
        if t.loop then
          t.loop = false
          t.loop_start = 1
          t.loop_end = t.steps
          t.loop_len = t.steps
          sc.set_inner_loop(g)
        end
      else 
        if x > queue[t.n][1] then
          t.loop_start = queue[t.n][1]
          t.loop_end = x 
          t.loop_len = x + 1 - t.loop_start
          t.loop = true
          sc.set_inner_loop(g)
        end
      end
    elseif t.mode == "shift" then
      if held[row] == 1 then
        event({type="cut",track=t.n,pos=x})
        if x+t.loop_len > t.steps then
          x = t.steps - t.loop_len + 1
        end
        t.loop_start = x
        t.loop_end = x + t.loop_len - 1
        sc.set_inner_loop(g)
      else 
        if x > queue[t.n][1] then
          t.loop_start = queue[t.n][1]
          t.loop_end = x 
          t.loop_len = x + 1 - t.loop_start
          t.loop = true
          sc.set_inner_loop(g)
        end
      end
    elseif t.mode == "hold" then
      event({type="cut",track=t.n,pos=x})
    end
  else -- z==0
    if t.mode == "hold" then
      if held[row] == 0 then
        event({type="stop",group=g})
      end
    end
  end
end


-------- LEVEL

g.redraw.level = function()
  local w = (state.window-1)*6
  for i=1,6 do
    local level = math.floor(14*params:get((i+w).."level")+1)
    for n=2,level do gr:led(n,i+2,2) end
    gr:led(1+level,i+2,15)
  end
end

g.key.level = function(x,y,z)
  local w = (state.window-1)*6
  if z==1 then
    params:set((y-2+w).."level",(x-2)/14)
  end
  g.dirty = true;
  ui.dirty = true;
end


-------- PAN

g.redraw.pan = function()
  local w = (state.window-1)*6
  for i=1,6 do
    gr:led(9,i+2,3)
    gr:led(math.floor(7*params:get((i+w).."pan")+9),i+2,15)
  end
end

g.key.pan = function(x,y,z)
  local w = (state.window-1)*6
  if z==1 then
    params:set((y-2+w).."pan",(x-9)/7)
  end
  g.dirty = true;
  ui.dirty = true;
end


-------- DETUNE

g.redraw.detune = function()
  local w = (state.window-1)*6
  for i=1,6 do
    gr:led(9,i+2,3)
    gr:led(math.floor(7*params:get((i+w).."detune")+9),i+2,15)
  end
end

g.key.detune = function(x,y,z)
  local w = (state.window-1)*6
  if z==1 then
    params:set((y-2+w).."detune",(x-9)/7)
  end
  g.dirty = true;
  ui.dirty = true;
end


-------- TRANSPOSE

g.redraw.transpose = function()
  local w = (state.window-1)*6
  for i=1,6 do
    gr:led(params:get((i+w).."transpose")+1,i+2,15)
  end
end

g.key.transpose = function(x,y,z)
  local w = (state.window-1)*6
  if z==1 then
    params:set((y-2+w).."transpose",x-1)
  end
  g.dirty = true;
  ui.dirty = true;
end



-------- ONE

g.redraw.one = function()
  local w = (state.window-1)*6
  if tr>w and tr<w+7 then
    gr:led(1,tr-w+2,5)
  end
  local level = 14*params:get(tr.."level")+1
  for i=2,level do gr:led(i,3,2) end
  gr:led(math.floor(1+level),3,15)
  gr:led(9,4,3)
  gr:led(math.floor(7*params:get(tr.."pan")+9),4,15)

  gr:led(9,7,3)
  gr:led(math.floor(7*params:get(tr.."detune")+9),7,15)

  gr:led(params:get(tr.."transpose")+1,8,15)
end

g.key.one= function(x,y,z)
  local w = (state.window-1)*6
  if z==1 then
    if x==1 then
      tr = y-2+w
    elseif x>1 and y==3 then
      params:set(tr.."level",(x-2)/14)
    elseif x>1 and y==4 then
      params:set(tr.."pan",(x-9)/7)
    elseif x>1 and y==7 then
      params:set(tr.."detune",(x-9)/7)
    elseif x>1 and y==8 then
      params:set(tr.."transpose",x-1)
    end
  end
  g.dirty = true;
  ui.dirty = true;
end
