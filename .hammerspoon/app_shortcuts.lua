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
  if hs.application.find("FirefoxDeveloperEdition") then
    hs.applescript.applescript([[
      tell application "FirefoxDeveloperEdition"
        activate
        delay 1.2
        tell application "System Events"
          tell process "FirefoxDeveloperEdition"
            keystroke "n" using {command down} # open new tab
          end tell
        end tell
      end tell
    ]])
  else
    hs.application.open("FirefoxDeveloperEdition")
  end
end)
