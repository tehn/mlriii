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
    softcut.loop(i,1)
  end
end

function sc.set_clip(g)
  local c = track[group[g].track].clip
  softcut.loop_start(g,clip[c].pos_start)
  softcut.loop_end(g,clip[c].pos_end)
  softcut.buffer(g,clip[c].ch)

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
    softcut.play(g,1)
    softcut.rec(g,1)
  else
    softcut.play(g,0)
    softcut.rec(g,0)
  end
end

