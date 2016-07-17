local state = 1

local state_by_name = {
  normal   = 1,
  activity = 2,
  alert    = 3
}

local dot_size = 8

local dot_color = {
  0,
  hs.drawing.color.osx_green,
  hs.drawing.color.osx_red
}

local circle_cache = {}
local circle_current;

local menu = hs.menubar.new()
  :setIcon(os.getenv("HOME") .. "/.hammerspoon/slacker/icon.png")

function update ()
  local circle_old = circle_current

  circle_current = circle_cache[state]
  if not circle_current and dot_color[state] ~= 0 then
    local f = menu:frame()
    circle_cache[state] =
      hs.drawing.circle(hs.geometry.rect(f.x+f.w-dot_size-1, f.y+f.h-dot_size-1, dot_size, dot_size))
      :setBehaviorByLabels({"canJoinAllSpaces", "stationary"})
      :setFillColor(dot_color[state])
      :setStroke(false)
    circle_current = circle_cache[state]
  end

  if circle_old ~= circle_current then
    if circle_old then
      circle_old:hide(0.3)
    end
    if circle_current then
      circle_current:show(0.3)
    end
  end
end

local app_active = false

local slack_watcher = hs.application.watcher.new(
  function (name, type, app)
    if name and name == "Slack" then
      if type == hs.application.watcher.activated then
        app_active = true
        state = 1
        update()
      elseif type == hs.application.watcher.deactivated then
        app_active = false
      end
    end
  end
)
  :start()

local server = hs.httpserver.new(false, false)
  :setPort(5595)
  --:setPassword("z4JXNEZpFR9IT2US")
  :setCallback(
    function (method, path, headers, content)
      local state_name = string.sub(path, 2)
      if state_name == "reset" then
        state = 1
      else
        --if not app_active then
        state = math.max(state_by_name[state_name] or 1, state)
      end
      update()
      return "", 200, {}
    end
  )
  :start()

local task
function start_task ()
  print("starting task")
  task = hs.task.new(os.getenv("HOME") .. "/.hammerspoon/slacker/slacker.pl",
    function (rc, out, err)
      print("task finished, rc "..rc)
      task = nil
      hs.timer.doAfter(1, start_task)
    end
  )
    :start()
  return task
end
start_task()

local reachability = hs.network.reachability.internet():setCallback(
  function (r, flags)
    if flags & hs.network.reachability.flags.reachable > 0 then
      print("network change detected, restarting task")
      if task and task:isRunning() then
        task:terminate()
      end
      start_task()
    end
   end
)
  :start()
