local placement = {

  Firefox = function (w,f,i) w:move({
    x = f.x + f.w - 1250 - 10 * (i - 1),
    y = f.y + 10 * (i - 1),
    w = 1250,
    h = 850
  }) end,

  Slack = function (w,f,i) w:move({
    x = f.x + 10 * (i - 1),
    y = f.y + 10 * (i - 1),
    w = 1150,
    h = 750
  }) end,

  Textual = function (w,f,i) w:move({
    x = f.x + 10 * (i - 1),
    y = f.y + f.h - 700 - 10 * (i - 1),
    w = 1100,
    h = 700
  }) end

}

function resize_app (name, move_fn)
  local app = hs.application.find(name)
  if (app) then
    local windows = app:visibleWindows()
    for i, window in ipairs(windows) do
      local frame = window:screen():frame()
      if (string.len(window:title()) > 0) then
        move_fn(window, frame, i)
      end
    end
  end
end

function resize_all_apps ()
  for name, move_fn in pairs(placement) do
    resize_app(name, move_fn)
  end
end

local resize_menu  = hs.menubar.new()
resize_menu:setTitle("★")
resize_menu:setClickCallback(resize_all_apps)
