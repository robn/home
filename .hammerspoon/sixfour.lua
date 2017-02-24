require("xmlSimple")

--[[
function unpack_data (json)
  print("update")
  print(json)
  menu:setTitle("🇦🇺 AUS 174/4")
end
--]]

function unpack_data (data)
  local unpacked = {}

  local teams = {}
  local players = {}
  local player_by_short_name = {}
  local player_by_long_name = {}

  for _,team in ipairs(data.team) do
    teams[team.team_id] = team;
    local player_list = team.player or team.squad
    for _,player in ipairs(player_list) do
      players[player.player_id] = player
      player_by_short_name[player.card_short] = player;
      player_by_long_name[player.card_long] = player;
    end
  end

  unpacked.match_name =
    data.match.team1_name.." v "..data.match.team2_name.."\n"..
    data.series[1].series_name..(data.series[1].match_title and ", "..data.series[1].match_title or "")

  local match_status = data.match.match_status
  if ((not match_status or match_status == "current") and data.match.result ~= "0") then
    match_status = "complete";
  end

  if (match_status == "current" and not data.live.innings.batting_team_id) then
    match_status = "dormant";
  end

  if match_status == "dormant" then

  elseif match_status == "complete" then
    unpacked.lead1 = data.live.status
    unpacked.score = data.match.team1_filename .. " v " .. data.match.team2_filename

  elseif match_status == "current" then
    local innings = data.live.innings

    unpacked.score = table.concat({
      string.upper(teams[innings.batting_team_id].team_abbreviation) .. " " .. innings.runs,
      ((innings.wickets+0) < 10) and "/"..innings.wickets or "",
      (innings.event and innings.event == "declared") and "d" or "",
      " (" .. data.live.innings.overs .. ")"
    })

    unpacked.overs = innings.overs

    if string.len(data.match.scheduled_overs) > 0 and data.match.scheduled_overs+0 > 0 then
      if innings.innings_number == "1" then
        unpacked.lead1 = "Run rate: "..innings.run_rate
      else
        unpacked.lead1 = "Target "..(innings.target).." ("..(math.floor(1-innings.lead)).." from "..innings.remaining_balls..")"
        unpacked.lead2 = "CRR: "..innings.run_rate.."  RRR: "..innings.required_run_rate
      end
    else
      if innings.innings_number == "1" then
        unpacked.lead1 = "First innings"
      elseif innings.innings_number == "4" then
        unpacked.lead1 = "Target "..(innings.target)
      else
        unpacked.lead1 =
            innings.lead+0 < 0 and "Trail by "..math.floor(-innings.lead) or
            innings.lead+0 > 0 and "Lead by "..math.floor(innings.lead) or
                                 "Scores level"
      end
    end

    local striker = (function ()
      for _,player in ipairs(data.live.batting) do
        if player.live_current_name == "striker" then
          return player
        end
      end
    end)()

    local nonstriker = (function ()
      for _,player in ipairs(data.live.batting) do
        if player.live_current_name == "non-striker" then
          return player
        end
      end
    end)()

    if not striker then
      striker = nonstriker
      nonstriker = nil
    end

    if striker then
      unpacked.striker_name = players[striker.player_id].card_long
      unpacked.striker_stats = striker.runs.." ("..striker.balls_faced..")"
    end

    if nonstriker then
      unpacked.nonstriker_name = players[nonstriker.player_id].card_long
      unpacked.nonstriker_stats = nonstriker.runs.." ("..nonstriker.balls_faced..")"
    end

    local bowler = (function ()
      for _,player in ipairs(data.live.bowling) do
        if player.live_current_name == "current bowler" then
          return player
        end
      end
    end)()

    if bowler then
      unpacked.bowler_name = players[bowler.player_id].card_long
      unpacked.bowler_stats = bowler.overs.."-"..bowler.maidens.."-"..bowler.conceded.."-"..bowler.wickets
    end
  end

  local facts = {}

  if data.match.live_state and string.len(data.match.live_state) > 0 then
    table.insert(facts, data.match.live_state);
  end

  for _,over in ipairs(data.comms) do
    for _,ball in ipairs(over.ball) do
      if ball.event and string.len(ball.event) > 0 then
        local event = ball.event
        if string.len(ball.dismissal) > 0 then
          event = "OUT"
        end

        if event == "OUT" then
          table.insert(facts, ball.overs_actual .. " " .. event .. " " .. ball.dismissal)

        elseif event == "SIX" or event == "FOUR" then
          local _, _, player = string.find(ball.players, "to (.+)$")
          table.insert(facts, ball.overs_actual .. " " .. event .. " " .. player)

        end

      end
    end
  end

  if #facts > 0 then
    unpacked.fact = facts[1]
  end

--[[
  var factBall = localStorage.getItem("lastFactBall") || 0;

  console.log("lastFactBall: "+factBall);

  var newLastFactBall = factBall;
  data.comms.forEach(function (over) {
      over.ball.forEach(function (ball) {
          if (ball.overs_unique > newLastFactBall) {
              newLastFactBall = ball.overs_unique;
          }

          if (ball.event) {
              var fact;

              var ev = ball.event.match(/OUT|SIX|FOUR/);
              if (!ev && ball.dismissal) {
                  ev = ["OUT"];
              }

              if (ev) switch (ev[0]) {

                  case "OUT":
                      var dismissal =
                          ball.dismissal
                          .replace(/\s+/g, " ")
                          .replace("&dagger;", "\u2020")
                          .replace("&amp;", "&")
                          .match(/(.+?) (lbw b|hit wicket b|run out|retired hurt|c \& b|c|b|st) ((?:.(?! (?:b|\d+)))+.)/);

                      fact = player_pretty_name(player_by_short_name[dismissal[1] ] || player_by_long_name[dismissal[1] ]) +
                              " " + dismissal[2] +
                              (dismissal[2].match(/run out|retired hurt/) ? "" : " " + dismissal[3]);
                      break;

                  case "SIX":
                  case "FOUR":
                      var name = ball.players.match(/to (.+)$/)[1];
                      fact = ev[0] + " " + player_pretty_name(player_by_short_name[name] || player_by_long_name[name]);
                      break;
              }

              if (fact) {
                  facts.push([ball.overs_actual,fact].join(' '));
              }
          }
      });
  });

  facts.forEach(function (fact) { console.log("FACT: "+fact); });

  console.log("newLastFactBall: "+newLastFactBall);
  if (newLastFactBall > factBall) {
      localStorage.setItem("lastFactBall", newLastFactBall);
  }

  // XXX send the lot to watch and have it cycle
  if (facts.length > 0) {
      out.fact = facts[0];
  }
--]]

-- XXX
for _,v in ipairs(facts) do
  print("FACT: "..v)
end

--[[
    switch (match_status) {
        case "dormant":
            out.score = data.match.team1_abbreviation.toUpperCase()+" v "+data.match.team2_abbreviation.toUpperCase();

            if (data.live["break"]) {
                out.fact = data.live["break"];
            }

            if (data.match.match_clock && data.match.match_clock !== "") {
                out.lead = "Match starts in "+data.match.match_clock;
            }
            else if (out.fact !== "") {
                out.lead = out.fact;
                out.fact = "";
            }

            if (data.match.toss_decision && data.match.toss_decision !== "" && data.match.toss_decision !== "0") {
                out.striker_name = teams[data.match.toss_winner_team_id].team_short_name+" won toss,";
                out.nonstriker_name = "will "+data.match.toss_decision_name;
            }
            break;

        case "complete": {
            out.score = data.match.team1_abbreviation.toUpperCase()+" v "+data.match.team2_abbreviation.toUpperCase();

            if (data.match.winner_team_id == "0") {
                out.striker_name = "Match drawn";
            }
            else {
                out.striker_name = teams[data.match.winner_team_id].team_short_name+" won by";
                if (data.match.amount_name === "innings") {
                    out.nonstriker_name = "innings and "+data.match.amount+" runs";
                }
                else {
                    out.nonstriker_name = data.match.amount+" "+data.match.amount_name;
                    if (data.match.amount_balls && data.match.amount_balls > 0) {
                        out.bowler_name = "(" + data.match.amount_balls + " balls remaining)";
                    }
                }
            }
            break;
        }

        case "current": {



            var facts = [];

            if (data.match.live_state) {
                facts.push(data.match.live_state);
            }

            var factBall = localStorage.getItem("lastFactBall") || 0;

            console.log("lastFactBall: "+factBall);

            var newLastFactBall = factBall;
            data.comms.forEach(function (over) {
                over.ball.forEach(function (ball) {
                    if (ball.overs_unique > newLastFactBall) {
                        newLastFactBall = ball.overs_unique;
                    }

                    if (ball.event) {
                        var fact;

                        var ev = ball.event.match(/OUT|SIX|FOUR/);
                        if (!ev && ball.dismissal) {
                            ev = ["OUT"];
                        }

                        if (ev) switch (ev[0]) {

                            case "OUT":
                                var dismissal =
                                    ball.dismissal
                                    .replace(/\s+/g, " ")
                                    .replace("&dagger;", "\u2020")
                                    .replace("&amp;", "&")
                                    .match(/(.+?) (lbw b|hit wicket b|run out|retired hurt|c \& b|c|b|st) ((?:.(?! (?:b|\d+)))+.)/);

                                fact = player_pretty_name(player_by_short_name[dismissal[1] ] || player_by_long_name[dismissal[1] ]) +
                                        " " + dismissal[2] +
                                        (dismissal[2].match(/run out|retired hurt/) ? "" : " " + dismissal[3]);
                                break;

                            case "SIX":
                            case "FOUR":
                                var name = ball.players.match(/to (.+)$/)[1];
                                fact = ev[0] + " " + player_pretty_name(player_by_short_name[name] || player_by_long_name[name]);
                                break;
                        }

                        if (fact) {
                            facts.push([ball.overs_actual,fact].join(' '));
                        }
                    }
                });
            });

            facts.forEach(function (fact) { console.log("FACT: "+fact); });

            console.log("newLastFactBall: "+newLastFactBall);
            if (newLastFactBall > factBall) {
                localStorage.setItem("lastFactBall", newLastFactBall);
            }

            // XXX send the lot to watch and have it cycle
            if (facts.length > 0) {
                out.fact = facts[0];
            }

            break;
        }
    }
}
--]]

  return unpacked
end

local matchlist
local game_code

local menu = hs.menubar.new()

function rebuild_menu (unpacked)
  for k,v in pairs(unpacked) do
    print(k..": "..v)
  end

  menu:setTitle(unpacked.score)

  function menutext (text)
    return hs.styledtext.new(text, {
      font = hs.styledtext.defaultFonts.menuBar,
    })
  end

  local menutable = {
    { title = menutext(unpacked.lead1), disabled = true },
  }

  if unpacked.fact then
    table.insert(menutable,
      { title = menutext(unpacked.fact), disabled = true }
    )
  end

  if unpacked.lead2 then
    table.insert(menutable,
      { title = menutext(unpacked.lead2), disabled = true }
    )
  end

  if unpacked.striker_name or unpacked.nonstriker_name then
    table.insert(menutable, { title = "-" })
    if unpacked.striker_name then
      table.insert(menutable,
        { title = menutext(unpacked.striker_name..' '..unpacked.striker_stats), disabled = true }
      )
    end
    if unpacked.nonstriker_name then
      table.insert(menutable,
        { title = menutext(unpacked.nonstriker_name..' '..unpacked.nonstriker_stats), disabled = true }
      )
    end
  end
  if unpacked.bowler_stats then
    table.insert(menutable,
      { title = "-" }
    )
    table.insert(menutable,
      { title = menutext(unpacked.bowler_name..' '..unpacked.bowler_stats), disabled = true }
    )
  end

  table.insert(menutable,
    { title = "-" }
  )
  table.insert(menutable,
    { title = menutext(unpacked.match_name), menu = matchlist }
  )

  menu:setMenu(menutable)
end

function update_scores ()
  local url = "http://www.espncricinfo.com/ci/engine/match/"..game_code..".json"
  print("sixfour: updating "..game_code)
  hs.http.asyncGet(url, nil, function (status, body, headers)
    local data = hs.json.decode(body)
    local unpacked = unpack_data(data)
    rebuild_menu(unpacked)
    hs.timer.doAfter(30, update_scores)
  end)
end

function update_matchlist ()
  local url = "http://static.cricinfo.com/rss/livescores.xml"
  print("sixfour: updating match list")
  hs.http.asyncGet(url, nil, function (status, body, headers)
    local p = xml.newParser()
    local data = p:ParseXmlText(body)
    local new_matchlist = {}
    for _,item in ipairs(data.rss.channel.item) do
      local desc = item.description:value()
      local guid = item.guid:value()
      local new_game_code = string.match(guid, "[0-9]+")
      table.insert(new_matchlist, {
        title = desc,
        fn = function ()
          if not game_code or game_code ~= new_game_code then
            game_code = new_game_code
            update_scores()
          end
        end,
        checked = game_code == new_game_code,
      })
    end
    matchlist = new_matchlist
    if not game_code then
      menu:setTitle("🏏")
      menu:setMenu(matchlist)
    end
    hs.timer.doAfter(120, update_matchlist)
  end)
end

--update_scores()
update_matchlist ()

--[[
io.input("/Users/robn/code/pebble/sixfour/wbbl-innings-break.json")
local input = io.read("*all")
local data = hs.json.decode(input)
local unpacked = unpack_data(data)
rebuild_menu(unpacked)
--]]
