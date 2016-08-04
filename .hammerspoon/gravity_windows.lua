-- gravity windows
do
  local position = {
    left   = function (w,s,f) return s.x,           s.y,           s.w/f, s.h   end,
    right  = function (w,s,f) return s.x+s.w-s.w/f, s.y,           s.w/f, s.h   end,
    top    = function (w,s,f) return w.x,           s.y,           s.w/f, s.h/f end,
    bottom = function (w,s,f) return w.x,           s.y+s.h-s.h/f, s.w/f, s.h/f end,
    centre = function (w,s,f) return s.x+(s.w-s.w/f)/2, s.y+(s.h-s.h/f)/2, s.w/f, s.h/f end,
  }

  local window_cache = {}

  local gravitateWindow = function (w, gravity, fraction)
    if not w then return end

    fraction = fraction or 2

    local wf = w:frame()
    local s = w:screen()
    local sf = s:frame()

    wf.x, wf.y, wf.w, wf.h = position[gravity](wf,sf,fraction)
    w:setFrame(wf)

    --window_cache[w:id()] = { gravity, fraction }
  end

--[[
  hs.spaces.watcher.new(function (n)
    for id,v in pairs(window_cache) do
      local w = hs.window.get(id)
      print(id, w)
      if not w then
        window_cache[id] = nil
      else
        gravitateWindow(w, v[1], v[2])
      end
    end
  end)
    :start()
--]]

  local focusedWindow = hs.window.focusedWindow
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Left",
    function() gravitateWindow(focusedWindow(), "left", 2) end
  )
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Right",
    function() gravitateWindow(focusedWindow(), "right", 2) end
  )
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Up",
    function() gravitateWindow(focusedWindow(), "top", 2) end
  )
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Down",
    function() gravitateWindow(focusedWindow(), "bottom", 2) end
  )
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Return",
    function() gravitateWindow(focusedWindow(), "centre", 2) end
  )
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Space",
    function() gravitateWindow(focusedWindow(), "centre", 1) end
  )
end
