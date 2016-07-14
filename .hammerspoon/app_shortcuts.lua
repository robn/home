hs.hotkey.bind({"cmd"}, "F1", function()
  if hs.application.find("iTerm") then
    hs.applescript.applescript([[
      tell application "iTerm"
        create window with default profile
      end tell
    ]])
  else
    hs.application.open("iTerm")
  end
end)
hs.hotkey.bind({"cmd"}, "F2", function()
  if hs.application.find("Google Chrome") then
    hs.applescript.applescript([[
      tell application "Google Chrome"
        make new window
      end tell
    ]])
  else
    hs.application.open("Google Chrome")
  end
end)
