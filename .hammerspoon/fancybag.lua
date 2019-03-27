local w = hs.caffeinate.watcher.new(function (e)
  if e == hs.caffeinate.watcher.systemWillSleep then
    print("fancybag: about to sleep")
    if hs.wifi.currentNetwork() == "bag" then
      print("fancybag: disconnecting wifi")
      hs.wifi.disassociate()
    end
  end
end)
w:start()
