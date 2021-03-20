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
      clock.sync(1/15)
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
  screen.aa(1)
  screen.font_face(1)
  ui.redraw[state.page]()
  screen.update()
end

function key(n,z)
  if n==1 then k1 = (z==1)
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


-------- TRACK

ui.redraw.track = function()
  screen.level(15)
  screen.move(0,12)
  screen.font_size(16)
  screen.text("track")
  screen.move(127,12)
  screen.text_right(tr)

  screen.font_size(8)
  screen.move(0,62)
  screen.text("group: "..track[tr].group)
  screen.move(48,62)
  screen.text("octave: "..track[tr].octave)
  screen.move(127,62)
  screen.text_right(track[tr].rev == 1 and ">" or "<")
end

ui.key.track = function(n,z)
  if n==3 and z==1 then
    ui.dirty = true
  end
end

ui.enc.track = function(n,d)
  if n==3 then
    ui.dirty = true
  end
end


-------- CUT

ui.redraw.cut = function()
  screen.level(15)
  screen.move(0,12)
  screen.font_size(16)
  screen.text("cut")
  screen.move(127,12)
  screen.text_right(tr)
end

ui.key.cut = function(n,z) end
ui.enc.cut = function(n,d) end


-------- CLIP

ui.redraw.clip = function()
  screen.level(15)
  screen.move(0,12)
  screen.font_size(16)
  screen.text("clip")
  screen.move(127,12)
  screen.text_right(tr)

  screen.line_width(1)
  for i=1,16 do
    local l = track[tr].clip == i and 15 or 2
    local ch = clip[i].ch == 1 and 0 or 64
    screen.level(l)
    screen.move(clip[i].pos_start + ch,16.5+i)
    screen.line(clip[i].pos_end,16.5+i+0.5)
    screen.stroke()
  end

  screen.level(10)
  screen.font_size(8)
  screen.move(0,62)
  screen.text("st "..clip[track[tr].clip].pos_start)
  screen.move(32,62)
  screen.text("end "..clip[track[tr].clip].pos_end)
  screen.move(64,62)
  screen.text("len "..clip[track[tr].clip].len)
  screen.move(96,62)
  screen.text("ch "..clip[track[tr].clip].ch)
end

ui.key.clip = function(n,z)
  if n==3 and z==1 then
    print("SELECT")
    fileselect.enter(paths.audio, function(n) clip_fileselect(n,track[tr].clip) end)
  end
end

function clip_fileselect(path, c)
  print("FILESELECT "..c)
  if path ~= "cancel" and path ~= "" then
    if audio.file_info(path) ~= nil then
      print("file > "..path.." "..clip[c].pos_start)
      local ch, len = audio.file_info(path)
      print("file length > "..len/48000)
      -- -1 = read whole file
      softcut.buffer_read_mono(path, 0, clip[c].pos_start, -1, 1, 1)
      local l = math.min(len/48000, math.huge) --FIX, huge should be something legit
      --set_clip_length(track[c].clip, l)
      clip[c].name = path:match("[^/]*$")
      -- TODO: STRIP extension
      --set_clip(c,track[c].clip)
      --update_rate(c)
      --params:set(c.."file",path)
    else
      print("not a sound file")
    end
    ui.dirty = true
  end
end

ui.enc.clip = function(n,d) end


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
