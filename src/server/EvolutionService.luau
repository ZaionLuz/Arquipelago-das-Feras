--!nonstrict
local RS = game:GetService("ReplicatedStorage")
local Data = require(script.Parent.DataService)
local System = require(RS.Shared.EvolutionSystem)
local Service = {}
local last = setmetatable({}, { __mode = "k" })
function Service.info(player, uid)
 if typeof(uid) ~= "string" or #uid > 80 then return {ok=false, code="INVALID_UID"} end
 local profile=Data.get(player)
 if not profile or not profile.creatures[uid] then return {ok=false, code="NOT_OWNED"} end
 local info=System.info(profile.creatures[uid])
 if not info then return {ok=false, code="INVALID_CREATURE"} end
 info.ok=true
 return info
end
function Service.start()
 local remotes=assert(RS:FindFirstChild("EvolutionRemotes"),"EvolutionRemotes ausente")
 local function info(player,uid)
  local now=os.clock()
  if last[player] and now-last[player]<0.15 then return {ok=false,code="RATE_LIMIT"} end
  last[player]=now
  return Service.info(player,uid)
 end
 remotes.GetEvolutionInfo.OnServerInvoke=info
 remotes.RequestEvolution.OnServerInvoke=function(player,uid)
  local result=info(player,uid)
  if result.ok then result.code="AUTOMATIC_LEVEL";result.msg="A evolução é automática nos níveis 7 e 15." end
  return result
 end
 remotes.EvolutionHistory.OnServerInvoke=function(player,uid)
  local result=info(player,uid)
  if not result.ok then return result end
  return {ok=true, entries={}, tracked=false, msg="Histórico de datas não é registrado nesta versão."}
 end
 remotes.CancelEvolution.OnServerEvent:Connect(function() end)
 -- A apresentação no cliente não modifica nível, espécie, inventário ou progresso.
end
return Service
