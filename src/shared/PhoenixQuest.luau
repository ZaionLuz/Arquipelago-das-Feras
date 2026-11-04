--!nonstrict
local Text = require(script.Parent.Strings).Text
local Config = require(script.Parent.Config)
local Q = { Glyphs = { duneHidden = true, duneRuin = true, skyPeak = true } }
function Q.stage(profile)
	local n = 0
	for id, value in (profile.phoenix and profile.phoenix.glyphs or {}) do
		if value == true and Q.Glyphs[id] then
			n += 1
		end
	end
	return math.min(3, n)
end
function Q.public(profile)
	local stage = Q.stage(profile)
	if stage == 0 then
		return { stage = 0 }
	end
	if stage == 1 then
		return {
			stage = 1,
			title = Text.ECO_DE_FOGO_ANTIGO_40525F,
			hint = Text.UMA_INSCRICAO_MENCIONA_DOIS_SINAIS_ENTRE_AREIA_E_4D4A59,
		}
	end
	if stage == 2 then
		return {
			stage = 2,
			title = Text.VESTIGIOS_513BA0,
			hint = Text.AS_RUINAS_DAS_DUNAS_RESPONDEM_AOS_SINAIS_DAS_ALT_695E0C,
		}
	end
	return {
		stage = 3,
		title = Text.VESTIGIOS_513BA0,
		hint = Text.OFERECA_UMA_CHAMA_NO_ALTAR_DAS_RUINAS_24F74A,
		nextAttemptAt = profile.phoenix.nextAttemptAt,
		captured = (profile.phoenix.captureCount or (profile.phoenix.captured and 1 or 0))
			>= Config.PhoenixMaxPerAccount,
	}
end
function Q.check(profile, now)
	if not Config.V7.PhoenixSanctuary then
		return false, "DISABLED"
	end
	if (profile.playerLevel or 1) < 45 or not (profile.unlocked and profile.unlocked.Dunas) then
		return false, "REQUIREMENTS"
	end
	if Q.stage(profile) < 3 then
		return false, "GLYPHS"
	end
	if (profile.phoenix.captureCount or (profile.phoenix.captured and 1 or 0)) >= Config.PhoenixMaxPerAccount then
		return false, "CAPTURED"
	end
	if profile.phoenix.encounterId then
		return false, "ACTIVE"
	end
	if now < (profile.phoenix.nextAttemptAt or 0) then
		return false, "COOLDOWN"
	end
	return true
end
return Q
