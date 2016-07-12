hs.hotkey.bind({"cmd"}, "F1",
  function ()
    hs.application.launchOrFocus("ITerm")
    hs.eventtap.keyStroke({"cmd"}, "n")
  end
)
hs.hotkey.bind({"cmd"}, "F2",
  function ()
    hs.application.launchOrFocus("Google Chrome")
    hs.eventtap.keyStroke({"cmd"}, "n")
  end
)
