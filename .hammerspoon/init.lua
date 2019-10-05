--require("gravity_windows")
require("app_shortcuts")
require("fancybag")
require("place_windows")
--require("sixfour")
--require("slacker")

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

local hyper = {"ctrl", "alt", "cmd"}

hs.loadSpoon("MiroWindowsManager")

hs.window.animationDuration = 0.1
spoon.MiroWindowsManager:bindHotkeys({
  up         = {hyper, "up"},
  right      = {hyper, "right"},
  down       = {hyper, "down"},
  left       = {hyper, "left"},
  fullscreen = {hyper, "space"}
})

