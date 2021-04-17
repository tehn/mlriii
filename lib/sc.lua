sc = {}

function sc.init()
  params:set("softcut_level",1)
  params:set("cut_input_adc",1)

  for i=1,4 do
    softcut.enable(i,1)
    softcut.level_input_cut(1, i, 1.0)
    softcut.level_input_cut(2, i, 1.0)
    softcut.fade_time(i,FADE)
    softcut.level_slew_time(i,0.1)
    softcut.rate_slew_time(i,0)
    softcut.play(i,1)
  end

  for i=1,4 do
    sc.off(i)
    --sc.set_clip(i)
    sc.set_level(i)
    sc.set_rec(i)
    sc.set_play(i)
  end

  softcut.event_phase(phase)
  softcut.poll_start_phase()
end

function sc.off(g)
    -- TODO: make sure rec isn't on!!
    -- stop basically jumps to the "dead second" at the start, for clean cut in/out
  softcut.loop_start(g,0)
  softcut.loop_end(g,0.5)
  softcut.position(g,0)
end 

--function sc.open_loop(g)
  --softcut.loop_start(g,0)
  --softcut.loop_end(g,1000)
--end

function sc.set_clip(g)
  local c = group[g].track.clip
  print(c.n.." SET CLIP")
  print("  start: "..c.pos_start)
  print("  end:   "..c.pos_end)
  --print("  ch:    "..c.ch)

  softcut.loop(g,1) -- FIXME play modes
  softcut.loop_start(g,c.pos_start)
  softcut.loop_end(g,c.pos_end)
  softcut.buffer(g,c.ch)
  --softcut.position(g,c.pos_start)

  local q = c.len/group[g].track.steps

  local off = 0
  while off < c.pos_start do
    off = off + q
  end
  off = off - c.pos_start

  --print(c.n.." SET CLIP")
  --print("  "..q.." "..off)
  softcut.phase_quant(g,q)
  softcut.phase_offset(g,off)
end

function sc.set_clips()
  for i=1,4 do sc.set_clip(i) end
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

function sc.set_rate(g)
  local t = group[g].track
  local oct = math.pow(2,t.octave)
  local trans = math.pow(2,(t.transpose/12))
  local r = oct * t.rev * (1+t.detune) * trans * t.bpm_mod
  --print(g.." RATE: "..r)
  softcut.rate(g,r)
end

function sc.set_play(g)
  if group[g].play then 
    --print(g.." PLAY")
    --sc.set_rate(g)
    --softcut.play(g,1)
    --softcut.rec(g,1)
  else
    --print(g.." STOP")
    --softcut.rate(g,0)
    --softcut.play(g,0)
    --softcut.rec(g,0)
    sc.off(g)
  end
end

function sc.cut_position(g,pos)
  softcut.position(g,group[g].track.cuts[pos])
  --print("> set position",g,group[g].track.n,group[g].track.cuts[pos])
end



-- phase poll callback
function phase(n, x)
  local pp = ((x - group[n].track.clip.pos_start) / group[n].track.clip.len)-- * 16 --TODO 16=div
  --if n==1 then print("> ",x,pp,math.floor(pp*16)) end
  x = math.floor(pp * 16)+1
  if x ~= group[n].track.pos_grid then
    group[n].track.pos_grid = x
    if state.page == "cut" then g.dirty = true end
  end
end
