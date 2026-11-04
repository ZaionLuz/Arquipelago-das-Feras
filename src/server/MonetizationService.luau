--!nonstrict
-- Só itens opcionais: gemas (pacotes), passe de ouro em dobro e aura cosmética. Nada bloqueia o jogo gratuito.
local MPS = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local Data = require(script.Parent.DataService)
-- Crie os itens em create.roblox.com e cole os IDs aqui (0 = desativado).
local Products = { Gems100 = { id = 0, gems = 100 }, Gems500 = { id = 0, gems = 500 } }
local Passes = { Dobro = 0, Aura = 0 }
local S = {}
function S.refresh(p)
	local d = Data.get(p)
	if not d then
		return
	end
	for k, id in Passes do
		if id > 0 then
			local ok, own = pcall(function()
				return MPS:UserOwnsGamePassAsync(p.UserId, id)
			end)
			if ok and own then
				d.pass[k] = true
			end
		end
	end
end
function S.buy(p, key)
	if true then
		return false, "Compras reais desativadas nesta versão de testes"
	end
	local pr = Products[key]
	if pr then
		if pr.id == 0 then
			return false, "Produto ainda não configurado"
		end
		MPS:PromptProductPurchase(p, pr.id)
		return true
	end
	if Passes[key] then
		if Passes[key] == 0 then
			return false, "Passe ainda não configurado"
		end
		MPS:PromptGamePassPurchase(p, Passes[key])
		return true
	end
	return false, "Item inválido"
end
MPS.ProcessReceipt = function(info)
	local N = Enum.ProductPurchaseDecision
	local p = Players:GetPlayerByUserId(info.PlayerId)
	local d = p and Data.get(p)
	if not d then
		return N.NotProcessedYet
	end
	local key = tostring(info.PurchaseId)
	if d.receipts[key] then
		return N.PurchaseGranted
	end
	for _, pr in Products do
		if pr.id == info.ProductId then
			d.gems += pr.gems
			d.receipts[key] = true
			if Data.save(p) then
				return N.PurchaseGranted
			end
			d.gems -= pr.gems
			d.receipts[key] = nil
			return N.NotProcessedYet
		end
	end
	return N.NotProcessedYet
end
MPS.PromptGamePassPurchaseFinished:Connect(function(p, id, bought)
	local d = Data.get(p)
	if not (d and bought) then
		return
	end
	for k, v in Passes do
		if v == id then
			d.pass[k] = true
		end
	end
end)
return S
