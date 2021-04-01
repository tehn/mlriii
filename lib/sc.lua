sc = {}

function sc.init()
  params:set("softcut_level",1)
  params:set("cut_input_adc",1)

  FADE = 0.1

  for i=1,4 do
    softcut.enable(i,1)
    softcut.level_input_cut(1, i, 1.0)
    softcut.level_input_cut(2, i, 1.0)
    softcut.fade_time(i,FADE)
    softcut.level_slew_time(i,0.1)
    softcut.rate_slew_time(i,0)
    --softcut.loop(i,1)
  end

  for i=1,4 do
    sc.set_clip(i)
    sc.set_level(i)
    sc.set_rec(i)
    sc.set_play(i)
  end
end

function sc.set_clip(g)
  local c = track[group[g].track].clip
  print(c.." SET CLIP")
  print("  start: "..clip[c].pos_start)
  print("  end:   "..clip[c].pos_end)
  print("  ch:    "..clip[c].ch)

  softcut.loop(g,1) -- FIXME play modes
  softcut.loop_start(g,clip[c].pos_start)
  softcut.loop_end(g,clip[c].pos_end)
  softcut.buffer(g,clip[c].ch)
  softcut.position(g,clip[c].pos_start)

  local q = clip[c].len/track[group[g].track].steps

  local off = 0
  while off < clip[c].pos_start do
    off = off + q
  end
  off = off - clip[c].pos_start

  softcut.phase_quant(g,q)
  softcut.phase_offset(g,off)
end


function sc.set_level(g)
  print(g.." SET LEVELS")
  softcut.level(g,group[g].level)
  softcut.pan(g,group[g].pan)
end

function sc.set_rec(g)
  if group[g].rec then
    softcut.pre_level(g,group[g].overdub)
    softcut.rec_level(g,group[g].input)
  else
    softcut.pre_level(g,1)
    softcut.rec_level(g,0)
  end
end

function sc.set_play(g)
  if group[g].play then 
    print(g.." PLAY")
    softcut.play(g,1)
    softcut.rec(g,1)
  else
    print(g.." STOP")
    softcut.play(g,0)
    softcut.rec(g,0)
  end
end

function sc.set_position(g,pos)
  softcut.position(g,track[group[g].track].cuts[pos])
end

