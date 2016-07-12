-- set up the config reload
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/",
  function (files)
    doReload = false
    for _,file in pairs(files) do
      if file:sub(-4) == ".lua" then
        doReload = true
      end
    end
    if doReload then
      hs.reload()
    end
  end
):start()
hs.alert.show("Hammerspoon config reloaded")


-- gravity windows
do
  local position = {
    left   = function (s,f) return s.x,           s.y,           s.w/f, s.h   end,
    right  = function (s,f) return s.x+s.w-s.w/f, s.y,           s.w/f, s.h   end,
    top    = function (s,f) return s.x,           s.y,           s.w,   s.h/f end,
    bottom = function (s,f) return s.x,           s.y+s.h-s.h/f, s.w,   s.h/f end,
    centre = function (s,f) return s.x+(s.w-s.w/f)/2, s.y+(s.h-s.h/f)/2, s.w/f, s.h/f end,
  }

  local gravitateWindow = function (gravity, fraction)
    fraction = fraction or 2

    local w = hs.window.focusedWindow()
    if not w then return end

    local wf = w:frame()
    local s = w:screen()
    local sf = s:frame()

    wf.x, wf.y, wf.w, wf.h = position[gravity](sf,fraction)
    w:setFrame(wf)
  end

  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Left",
    function() gravitateWindow("left", 2) end
  )
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Right",
    function() gravitateWindow("right", 2) end
  )
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Up",
    function() gravitateWindow("top", 2) end
  )
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Down",
    function() gravitateWindow("bottom", 2) end
  )
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Return",
    function() gravitateWindow("centre", 2) end
  )
  hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Space",
    function() gravitateWindow("centre", 1) end
  )
end
