ui = {
  redraw = {},
  key = {},
  enc = {},
  dirty = true,
  update = function()
    while true do
      if ui.dirty then
        ui.dirty = false
        redraw()
      end
      clock.sleep(1/15)
    end
  end,
  init = function()
    norns.enc.sens(1,8)
    clock.run(ui.update)
  end
}

k1 = false
tr = 1


function redraw()
  screen.clear()
  screen.aa(0)
  screen.font_face(1)
  ui.redraw[state.page]()
  screen.update()
end

function key(n,z)
  if n==1 then
    k1 = (z==1)
    ui.dirty = true
  else
    ui.key[state.page](n,z)
  end
end

function enc(n,d)
  -- E1 is track select, or K1+E1 is main volume
  if n==1 then
    if k1 then params:delta("output_level",d)
    else tr = util.clamp(tr+d,1,24) end
    ui.dirty = true
    g.dirty = true
  else
    ui.enc[state.page](n,d)
  end
end

-------- META

function meta_r()
  screen.font_size(16)
  screen.move(47,32)
  screen.text_right(strdec2(track[tr][EMAP[state.emap[1]]]))
  screen.move(107,32)
  screen.text_right(strdec2(track[tr][EMAP[state.emap[2]]]))
  screen.font_size(8)
  screen.move(47,40)
  screen.text_right(EMAP[state.emap[1]])
  screen.move(107,40)
  screen.text_right(EMAP[state.emap[2]])
end

function meta_k(n,z)
  if n==2 and z==1 then
    state.emap[1] = (state.emap[1] % 4)+1
    ui.dirty = true
  elseif n==3 and z==1 then
    state.emap[2] = (state.emap[2] % 4)+1
    ui.dirty = true
  end
end

function meta_e(n,d)
  if n==2 then
    params:delta(tr..EMAP[state.emap[1]],d)
  elseif n==3 then
    params:delta(tr..EMAP[state.emap[2]],d)
  end
  ui.dirty = true
end


-------- TRACK

ui.redraw.track = function()
  screen.level(15)
  screen.move(0,12)
  screen.font_size(16)
  screen.text("track")
  screen.move(127,12)
  screen.text_right(tr)

  meta_r()

  screen.font_size(8)
  screen.move(0,54)
  screen.text(track[tr].clip.n .."/".. track[tr].clip.name)
  screen.move(0,62)
  screen.text("group: "..track[tr].group)
  screen.move(48,62)
  screen.text("octave: "..track[tr].octave)
  screen.move(127,62)
  screen.text_right(track[tr].rev == 1 and ">" or "<")
end

ui.key.track = function(n,z)
  if k1 then
    -- TBD/menu
  else meta_k(n,z) end
end

ui.enc.track = function(n,d)
  if k1 then
    -- TBD
  else meta_e(n,d) end
end


-------- CUT

ui.redraw.cut = function()
  screen.level(15)
  screen.move(0,12)
  screen.font_size(16)
  screen.text("cut")
  screen.move(127,12)
  screen.text_right(tr)

  meta_r()
end

ui.key.cut = function(n,z) meta_k(n,z) end

ui.enc.cut = function(n,d) meta_e(n,d) end


-------- CLIP

ui.redraw.clip = function()
  screen.level(15)
  screen.move(0,12)
  screen.font_size(16)
  screen.text("clip")
  screen.move(127,12)
  screen.text_right(tr)
  screen.font_size(8)

  if k1 then
    screen.level(10)
    screen.move(0,28)
    screen.text("clip import mode")
    screen.move(127,28)
    screen.text_right(state.clipimport)
    -- position quantization: off, 1/32, 1/16, 1/8, 1/4, 1/2, 1 ---- REF TEMPO?
    -- export clip/all
    -- reset. length (secs vs. bars) + separation
    -- clear all
  else
    -- draw regions
    screen.line_width(1)
    screen.level(2)
    for i=1,16 do
      screen.move(clip[i].pos_start/2.5,16.5+clip[i].ch)
      screen.line(clip[i].pos_end/2.5,16.5+clip[i].ch)
      screen.stroke()
    end
    -- active clip
    local c = track[tr].clip
    screen.level(15)
    screen.move(c.pos_start/2.5,16.5+c.ch)
    screen.line(c.pos_end/2.5,16.5+c.ch)
    screen.stroke()

    screen.level(10)
    screen.move(0,54)
    screen.text(track[tr].clip.n .."/".. track[tr].clip.name)
    screen.move(127,54)
    screen.text_right(string.upper(state.clipaction))
    screen.move(0,62)
    screen.text("S "..strdec2(track[tr].clip.pos_start))
    screen.move(38,62)
    screen.text("E "..strdec2(track[tr].clip.pos_end))
    screen.move(76,62)
    screen.text("L "..strdec2(track[tr].clip.len))
    screen.move(110,62)
    screen.text("ch"..track[tr].clip.ch)
  end
end

function clearclipaction()
  print("set timer")
  clock.sleep(1)
  state.clipaction = ""
  ui.dirty = true
  print("done")
end

function setclipaction(x)
  state.clipaction = x
  state.clipactiontimer = clock.run(clearclipaction)
end

ui.key.clip = function(n,z)
  if n==2 and z==1 then
    if state.clipaction == "clear" then
      local c = track[tr].clip
      -- FIXME: fade time still has clicks??
      softcut.buffer_clear_region_channel(c.ch, c.pos_start, c.len, FADE*2, 0)
      -- FIXME: change name?
      --c.name = "clip-"..string.format("%02d",c.n)
      clock.cancel(state.clipactiontimer)
      print("clear clip")
      state.clipaction = ""
    else setclipaction("clear") end
    ui.dirty = true
  elseif n==3 and z==1 then
    if state.clipaction == "load" then
      clock.cancel(state.clipactiontimer)
      fileselect.enter(paths.audio, function(n) clip_fileselect(n,track[tr].clip.n) end)
      state.clipaction = ""
    else
      setclipaction("load")
      ui.dirty = true
    end
  end
end

function clip_fileselect(path, c)
  print("FILESELECT "..c)
  if path ~= "cancel" and path ~= "" then
    if audio.file_info(path) ~= nil then
      print("file > "..path.." "..clip[c].pos_start)
      local ch, len = audio.file_info(path)
      local l = len/48000
      print("file info",ch,len,rate)
      print("file length: "..l)
      --local l = math.min(len/48000, math.huge) --FIX, huge should be something legit
      if state.clipimport == "whole" then
        -- -1 = read whole file
        softcut.buffer_read_mono(path, 0, clip[c].pos_start, -1, clip[c].ch, 1)
        clip[c].len = l
        clip[c].pos_end = clip[c].pos_start + l
      else
        -- "part" read, preserve clip len
        softcut.buffer_read_mono(path, 0, clip[c].pos_start, clip[c].len, clip[c].ch, 1)
      end
      clip[c].name = path:match("[^/]*$") -- TODO: STRIP extension
      --update_rate(c)
      --params:set(c.."file",path)
      for i=1,4 do --refresh possibly active group-track-clip
        if c == group[i].track.clip.n and group[i].play then sc.set_clip(i) end
      end
      for i=1,24 do -- recalc cuts for tracks using clip
        if track[i].clip.n == c then calc_cuts(i) end
      end
    else
      print("not a sound file")
    end
    ui.dirty = true
  end
end

ui.enc.clip = function(n,d)
    
end


-------- PARAM

ui.redraw.param = function()
  screen.level(15)
  screen.move(0,12)
  screen.font_size(16)
  screen.text("param")
  screen.move(127,12)
  screen.text_right(tr)
end

ui.key.param = function(n,z) end
ui.enc.param = function(n,d) end
