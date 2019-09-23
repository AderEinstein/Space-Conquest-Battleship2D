--[===================================================================[--
   Copyright © 2016 Pedro Gimeno Fortea. All rights reserved.

   This library is work-in-progress. You may copy it but you may not
   use it in your projects.
--]===================================================================]--

local function pause(timer)
  timer.paused = true
end

local function resume(timer)
  timer.paused = false
end

local function cancel(timer)
  timer.cancelled = true
end

local function reset(timer)
  timer.time = timer.start
end

-- Tweening ancillary functions

local function linear(t)
  return t
end

local function twimer_lerp(from, to, t)
  return t < 0.5 and from + (to-from)*t or to + (from-to)*(1-t)
end


-- Modes

local function twimer_after(self, t, callback)
  local new = {
    mode = "after";
    time = t;
    start = t;
    cb = callback;
    pause = pause;
    resume = resume;
    reset = reset;
    cancel = cancel;
    cancelled = t == 0;
  }
  if t == 0 then
    if callback then callback(new, 0, "end") end
  else
    self[#self + 1] = new
  end
  return new
end

local function twimer_during(self, t, callback)
  local new = {
    mode = "during";
    time = t;
    start = t;
    cb = callback;
    pause = pause;
    resume = resume;
    reset = reset;
    cancel = cancel;
    cancelled = t == 0;
  }
  if t == 0 then
    if callback then callback(new, 0, "end") end
  else
    self[#self + 1] = new
  end
  return new
end

local function twimer_every(self, t, callback)
  local new = {
    mode = "every";
    time = t;
    start = t;
    cb = callback;
    pause = pause;
    resume = resume;
    reset = reset;
    cancel = cancel;
    cancelled = false;
  }
  if t == 0 then
    if callback then
      while not new.cancelled do callback(new, 0, "end") end
    else
      error("Interval is 0s and no callback is provided. This would cause an infinite loop.")
    end
  else
    self[#self + 1] = new
  end
  return new
end

local function twimer_tween(self, from, to, ease, t, callback, param)
  local new = {
    mode = "tween";
    time = t;
    start = t;
    from = from or 0;
    to = to or 1;
    ease = ease or linear;
    cb = callback or nil;
    param = param;
    val = twimer_lerp(from or 0, to or 1, (ease or linear)(0, param));
    pause = pause;
    resume = resume;
    reset = reset;
    cancel = cancel;
    cancelled = false;
  }
  self[#self + 1] = new
  return new
end

local function twimer_manual_tween(self, t, callback, obj)
  local new = {
    mode = "tween";
    time = t;
    start = t;
    from = 0;
    to = 1;
    ease = linear;
    cb = callback or nil;
    val = 0;
    obj = obj;
    pause = pause;
    resume = resume;
    reset = reset;
    cancel = cancel;
    cancelled = false;
  }
  self[#self + 1] = new
  return new
end

local function twimer_update(self, dt)
  for i = #self, 1, -1 do
    local timer = self[i]
    if timer.cancelled then
      table.remove(self, i)
    elseif not timer.paused then
      timer.time = timer.time - dt
      if timer.time <= 0 then
        -- timer expired
        if timer.mode ~= "every" then timer.cancelled = true end
        if timer.mode == "tween" then
          timer.val = twimer_lerp(timer.from, timer.to, timer.ease(1, timer.param))
          if timer.cb then timer:cb(timer.val) end
        else
          if timer.cb then timer:cb(dt, "end") end
        end
        if timer.mode == "every" then
          timer.time = timer.time + timer.start
        else
          table.remove(self, i)
        end

      -- not expired - send continuous callbacks/updates when needed
      elseif timer.mode == "during" then
        if timer.cb then timer:cb(dt, "update") end
      elseif timer.mode == "tween" then
        timer.val = twimer_lerp(timer.from, timer.to, timer.ease(math.min(1-timer.time/timer.start, 1), timer.param))
        if timer.cb then timer:cb(timer.val) end
      end
    end
  end
end

local function new()
  return {
    lerp = twimer_lerp;
    linear = linear;
    after = twimer_after;
    during = twimer_during;
    every = twimer_every;
    tween = twimer_tween;
    manual_tween = twimer_manual_tween;
    update = twimer_update;
  }
end

return new
