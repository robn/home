require("gravity_windows")
require("app_shortcuts")

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
