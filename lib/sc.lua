sc = {}

function sc.init()
  params:set("softcut_level",1)
  params:set("cut_input_adc",1)

  for i=1,4 do
    softcut.enable(i,1)
    --softcut.level_input_cut(1, i, 0.7) -- this is set my param system
    --softcut.level_input_cut(2, i, 0.7)
    softcut.fade_time(i,FADE)
    softcut.level_slew_time(i,0.1) -- FIXME could be too big
    softcut.rate_slew_time(i,0)
    softcut.play(i,1)
    softcut.rec(i,1)
  end

  for i=1,4 do
    sc.off(i)
    --sc.set_clip(i)
    --sc.set_level(i)
    --sc.set_play(i)
  end

  softcut.event_phase(phase)
  softcut.poll_start_phase()

  softcut.event_position(report_position)
end

function sc.off(g)
  -- TODO: make sure rec isn't on!!
  -- stop basically jumps to the "dead second" at the start, for clean cut in/out
  softcut.rec_level(g,0)
  softcut.level(g,0)
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
  local t = group[g].track
  --print(c.n.." SET CLIP")
  --print("  start: "..c.pos_start)
  --print("  end:   "..c.pos_end)
  --print("  ch:    "..c.ch)

  softcut.buffer(g,c.ch)
  softcut.loop(g,1) -- FIXME play modes
   sc.set_inner_loop(g)

  sc.set_phase(g)
end

function sc.set_clips()
  for i=1,4 do sc.set_clip(i) end
end

function sc.set_inner_loop(g)
  local c = group[g].track.clip
  local t = group[g].track
  if t.loop then
    softcut.loop_start(g,t.cuts[t.loop_start])
    softcut.loop_end(g,t.cuts[t.loop_end+1])
  else
    softcut.loop_start(g,c.pos_start)
    softcut.loop_end(g,c.pos_end)
  end
end

function sc.set_phase(g)
  local c = group[g].track.clip
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

function sc.set_level(g)
  --print(g.." SET LEVELS")
  softcut.level(g,group[g].level*group[g].track.level)
  --softcut.pan(g,group[g].pan) -- TODO if we want group pan, gotta do weird compensation/mix
  softcut.pan(g,group[g].track.pan)
  sc.set_rec(g)
end

function sc.set_rec(g)
  --print("set_rec",group[g].rec,group[g].play)
  if group[g].rec and group[g].play then
    --print("set_rec REC",group[g].overdub,group[g].input)
    softcut.pre_level(g,group[g].overdub)
    softcut.rec_level(g,group[g].input)
  else
    --print("set_rec PLAY")
    softcut.pre_level(g,1)
    softcut.rec_level(g,0)
  end
end

function sc.set_rate(g)
  local t = group[g].track
  local oct = math.pow(2,t.octave)
  local trans = math.pow(2,(t.transpose_ratio))
  local r = oct * t.rev * (1+t.detune*0.1) * trans * t.bpm_mod
  --print(g.." RATE: ",r,oct,trans)
  softcut.rate(g,r)
end

function sc.set_play(g)
  if group[g].play then 
    --print(g.." PLAY")
    --sc.set_rate(g)
    --softcut.play(g,1)
    --softcut.rec(g,1)
    sc.set_rec(g)
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

function sc.resume_position(g)
  softcut.position(g,group[g].position)
end




-- phase poll callback
function phase(n, x)
  local pp = ((x - group[n].track.clip.pos_start) / group[n].track.clip.len)-- * 16 --TODO 16=div
  --if n==1 then print("> ",x,pp,math.floor(pp*16)) end
  x = math.floor(pp * 16)+1
  if x ~= group[n].pos_grid and group[n].play then
    group[n].pos_grid = x
    if state.page == "cut" then g.dirty = true end
  end
end

-- position query callback
report_position = function(i,p)
  --print("report_position",i,p)
  group[i].position = p
  if group[i].resize_clip then
    local c = clip[group[i].resize_clip]
    group[i].resize_clip = nil
    c.pos_end = p
    c.len = c.pos_end - c.pos_start
    sc.set_clip(i)
    calc_cuts(i)
    group[i].rec = false
    sc.set_rec(i)
  end
end

