local MarketplaceService = game:GetService("MarketplaceService")

--[[--------------------
--
	Marketplace2
--
	By Courageous_Canister
	Remix this all you want but please, don't steal my work without credit :)
--
--]]--------------------

local Aliases = {
	["Gamepasses"] = {},
	["Assets"] = {}
}

local playercache = {}

local infocache = {
	["Gamepasses"] = {},
	["Assets"] = {}
}

local Marketplace2 = {}

local function UpdateAssetInfoCache(assetId)
	assert(typeof(assetId) == "number", ("UpdateAssetInfoCache call expecter number, got %s"):format(typeof(assetId)))
	coroutine.wrap(function()
		local info = nil
		local success, errormessage = pcall(function()
			info = MarketplaceService:GetProductInfo(assetId, Enum.InfoType.Asset)
		end)
		if not success then
			assert(nil, "GetProductInfo call failed\n" + errormessage)
		else
			infocache.Aliases[assetId] = info
		end
	end)()
end

local function UpdateGamepassInfoCache(gamepassId)
	assert(typeof(gamepassId) == "number", ("UpdateGamepassInfoCache call expecter number, got %s"):format(typeof(gamepassId)))
	coroutine.wrap(function()
		local info = nil
		local success, errormessage = pcall(function()
			info = MarketplaceService:GetProductInfo(gamepassId, Enum.InfoType.GamePass)
		end)
		if not success then
			assert(nil, "GetProductInfo call failed\n" + errormessage)
		else
			infocache.Gamepasses[gamepassId] = info
		end
	end)()
end

Marketplace2.PurchaseCanGrantRevoked = true

--[[-----
	Misc
--]]-----

function Marketplace2:AssignGamepassAlias(alias, gamepassId)
	assert((typeof(alias) == "string") or (typeof(gamepassId) == "number"), ("AssignGamepassAlias call expected (string, number), got (%s, %s)"):format(typeof(alias), typeof(gamepassId)))
	Aliases.Gamepasses[alias] = gamepassId
end

function Marketplace2:AssignAssetAlias(alias, assetId)
	assert((typeof(alias) == "string") or (typeof(assetId) == "number"), ("AssignAssetAlias call expected (string, number), got (%s, %s)"):format(typeof(alias), typeof(assetId)))
	Aliases.Assets[alias] = assetId
end

Marketplace2.ClearCache = function()
	playercache = {}
	infocache = {
		["Gamepasses"] = {},
		["Assets"] = {}
	}
end

--[[-----
	Grant/Revoke
--]]-----

function Marketplace2:GrantGamepass(playerId, gamepassId)
	if not playercache[playerId] then
		playercache[playerId] = {["Gamepasses"] = {}, ["Assets"] = {}}
	end
	if typeof(gamepassId) == "string" then
		local aliasresult = Aliases.Gamepasses[gamepassId]
		assert(aliasresult, "Invalid alias passed")
		gamepassId = aliasresult
	end
	playercache[playerId].Gamepasses[gamepassId] = true
end

function Marketplace2:GrantAsset(playerId, assetId)
	if not playercache[playerId] then
		playercache[playerId] = {["Gamepasses"] = {}, ["Assets"] = {}}
	end
	if typeof(assetId) == "string" then
		local aliasresult = Aliases.Assets[assetId]
		assert(aliasresult, "Invalid alias passed")
		assetId = aliasresult
	end
	playercache[playerId].Assets[assetId] = true
end
--[[
function Marketplace2:GrantPremium(playerId)
	if not playercache[playerId] then
		playercache[playerId] = {["Gamepasses"] = {}, ["Assets"] = {}}
	end
	playercache[playerId].Premium = true
end
--]]
function Marketplace2:RevokeGamepass(playerId, gamepassId)
	if not playercache[playerId] then
		playercache[playerId] = {["Gamepasses"] = {}, ["Assets"] = {}}
	end
	if typeof(gamepassId) == "string" then
		local aliasresult = Aliases.Gamepasses[gamepassId]
		assert(aliasresult, "Invalid alias passed")
		gamepassId = aliasresult
	end
	playercache[playerId].Gamepasses[gamepassId] = false
end

function Marketplace2:RevokeAsset(playerId, assetId)
	if not playercache[playerId] then
		playercache[playerId] = {["Gamepasses"] = {}, ["Assets"] = {}}
	end
	if typeof(assetId) == "string" then
		local aliasresult = Aliases.Assets[assetId]
		assert(aliasresult, "Invalid alias passed")
		assetId = aliasresult
	end
	playercache[playerId].Assets[assetId] = false
end
--[[
function Marketplace2:RevokePremium(playerId)
	if not playercache[playerId] then
		playercache[playerId] = {["Gamepasses"] = {}, ["Assets"] = {}}
	end
	playercache[playerId].Premium = false
end
--]]
--[[-----
	Get
--]]-----

function Marketplace2:UserOwnsGamepass(playerId, gamepassId)
	if typeof(gamepassId) == "string" then
		local aliasresult = Aliases.Gamepasses[gamepassId]
		assert(aliasresult, "Invalid alias passed")
		gamepassId = aliasresult
	end
	if not playercache[playerId] then
		playercache[playerId] = {["Gamepasses"] = {}, ["Assets"] = {}}
	end
	local cacheget = playercache[playerId].Gamepasses[gamepassId]
	if cacheget ~= nil then
		if cacheget == true then
			return true
		else
			return false
		end
	else
		local userhaspass = false
		local success, errormessage = pcall(function()
			MarketplaceService:UserOwnsGamePassAsync(playerId, gamepassId)
		end)
		if not success then
			warn("Marketplace2: An error occurred while calling :UserOwnsGamepassAsync()\n" + errormessage)
			return false
		else
			playercache[playerId].Gamepasses[gamepassId] = userhaspass
			UpdateGamepassInfoCache(gamepassId)
			return userhaspass
		end
	end
end

function Marketplace2:UserOwnsAsset(playerId, assetId)
	if typeof(assetId) == "string" then
		local aliasresult = Aliases.Assets[assetId]
		assert(aliasresult, "Invalid alias passed")
		assetId = aliasresult
	end
	if not playercache[playerId] then
		playercache[playerId] = {["Gamepasses"] = {}, ["Assets"] = {}}
	end
	local cacheget = playercache[playerId].Assets[assetId]
	if cacheget ~= nil then
		if cacheget == true then
			return true
		else
			return false
		end
	else
		local userhasasset = false
		local player = game.Players:GetPlayerByUserId(playerId)
		if not player then
			warn("Player not found in game.")
			return nil
		end
		local success, errormessage = pcall(function()
			userhasasset = MarketplaceService:PlayerOwnsAsset(player, assetId)
		end)
		if not success then
			warn("Marketplace2: An error occurred while calling :PlayerOwnsAsset()\n" + errormessage)
			return false
		else
			playercache[playerId].Assets[assetId] = userhasasset
			UpdateAssetInfoCache(assetId)
			return userhasasset
		end
	end
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamepassId, waspurchased)
	if not waspurchased then return end
	if not playercache[player.UserId] then
		playercache[player.UserId] = {["Gamepasses"] = {}, ["Assets"] = {}}
	end
	if playercache[player.UserId].Gamepasses[gamepassId] == false then
		if Marketplace2.PurchaseCanGrantRevoked then
			playercache[player.UserId].Gamepasses[gamepassId] = true
		end
	elseif playercache[player.UserId].Gamepasses[gamepassId] == nil then
		playercache[player.UserId].Gamepasses[gamepassId] = true
	end
end)

MarketplaceService.PromptPurchaseFinished:Connect(function(player, assetId, waspurchased)
	if not waspurchased then return end
	if not playercache[player.UserId] then
		playercache[player.UserId] = {["Gamepasses"] = {}, ["Assets"] = {}}
	end
	if playercache[player.UserId].Assets[assetId] == false then
		if Marketplace2.PurchaseCanGrantRevoked then
			playercache[player.UserId].Assets[assetId] = true
		end
	elseif playercache[player.UserId].Assets[assetId] == nil then
		playercache[player.UserId].Assets[assetId] = true
	end
end)

return Marketplace2
