--[[
	Author:      ET:Legacy Team
	Description: Ensure the server is connected to IRC - see irc_* cvars. Set irc_mode flag 1 and 2.
]]--

modname = "IRC announcer"
version = "1.0"

function et_InitGame()
  et.RegisterModname(modname.." "..version)
end

function ircColorStr(str)
    local escape = "\003"
    local q3colorescape = "%^"
    str = str:gsub(q3colorescape .. "[7Ww]", escape .. "0")
    str = str:gsub(q3colorescape .. "[0Pp]", escape .. "1")
    str = str:gsub(q3colorescape .. "[4Tt]", escape .. "2")
    str = str:gsub(q3colorescape .. "[Hh]", escape .. "3")
    str = str:gsub(q3colorescape .. "[Jj1QqIi]", escape .. "4")
    str = str:gsub(q3colorescape .. "[Kk@%+%?]", escape .. "5")
    str = str:gsub(q3colorescape .. "[CcEe]", escape .. "6")
    str = str:gsub(q3colorescape .. "[Ll8XxAa]", escape .. "7")
    str = str:gsub(q3colorescape .. "[Mm3%/%-SsOoNn]", escape .. "8")
    str = str:gsub(q3colorescape .. "[2RrGg]", escape .. "9")
    str = str:gsub(q3colorescape .. "[Bb]", escape .. "10")
    str = str:gsub(q3colorescape .. "[5Uu]", escape .. "11")
    str = str:gsub(q3colorescape .. "[DdFf]", escape .. "12")
    str = str:gsub(q3colorescape .. "[6Vv]", escape .. "13")
    str = str:gsub(q3colorescape .. "[9Yy]", escape .. "14")
    str = str:gsub(q3colorescape .. "[Zz]", escape .. "15")
    return str .. "\015"
end

function getTeamInfo()
  local temp = et.trap_GetConfigstring(0)
  temp = et.Info_ValueForKey(temp, "P")

  local team_free_cnt, team_ax_cnt, team_al_cnt, team_spec_cnt = 0, 0, 0, 0

  for i = 1, #temp do
    if (string.sub(temp, i, i) == "0") then
      team_free_cnt = team_free_cnt + 1
    end
    if (string.sub(temp, i, i) == "1") then
      team_ax_cnt = team_ax_cnt + 1
    end
    if (string.sub(temp, i, i) == "2") then
      team_al_cnt = team_al_cnt + 1
    end
    if (string.sub(temp, i, i) == "3") then
      team_spec_cnt = team_spec_cnt + 1
    end
  end

  return team_free_cnt, team_ax_cnt, team_al_cnt, team_spec_cnt
end

function getBotInfo()
  local cs = et.trap_GetConfigstring(0)
  local bots_cnt = et.Info_ValueForKey(cs, "omnibot_playing")

  return bots_cnt
end

function et_ClientConnect(_clientNum, _firstTime, _isBot)
  -- skip bots
  if _isBot == 1 then return end

  if _firstTime == 1 then
    local clientname
    -- note pers.netname is empty on first connect
    clientname = ircColorStr(et.Info_ValueForKey(et.trap_GetUserinfo(_clientNum), "name"))

    -- get player type and team count
    local free, axis, allies, spec = 0, 0, 0, 0
    free, axis, allies, spec = getTeamInfo()

    -- count humans players
    local bots, humans = 0, 0
    bots = getBotInfo()

    if bots then
      humans = free + axis + allies + spec - bots
    else
      humans = free + axis + allies + spec
    end

    -- float to int conversion
    humans = math.floor(humans)

    -- current player is connecting but doesn't show up in the total yet
    -- let's add it manually
    humans = humans + 1

    -- send message
    local msg        = "irc_say  \"" .. clientname .. " connected to server. Now online:^7 " .. humans .. "^9(+" .. bots .. ")\""
    et.trap_SendConsoleCommand(et.EXEC_NOW , ircColorStr(msg))
  end
end

-- function et_ClientDisconnect(_clientNum)
--  local clientname = ircColorStr(et.gentity_get(_clientNum ,"pers.netname"))
--  local msg        = "irc_say  \"" .. clientname .. " disconnected from server\""
--  et.trap_SendConsoleCommand(et.EXEC_NOW , ircColorStr(msg))
-- end