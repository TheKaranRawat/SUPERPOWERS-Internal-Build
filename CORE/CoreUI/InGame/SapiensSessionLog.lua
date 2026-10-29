local function BuildSessionSnapshot()
	local insert = table.insert
	local format = string.format
	local concat = table.concat

	local t = {}

	-- Active MODs with versions
	insert(t, "Activated MODs:")
	if Modding and Modding.GetActivatedMods then
		local bAny = false
		for _, v in pairs(Modding.GetActivatedMods()) do
			bAny = true
			local name = Modding.GetModProperty(v.ID, v.Version, "Name") or "(no name)"
			insert(t, format("   %s  v%s  [%s]", tostring(name), tostring(v.Version), tostring(v.ID)))
		end
		if not bAny then
			insert(t, "   (none)")
		end
	else
		insert(t, "   (Modding API unavailable)")
	end

	if ContentManager and ContentManager.GetAllPackageIDs then
		insert(t, "Active DLC / packages:")
		for _, v in pairs(ContentManager.GetAllPackageIDs()) do
			if ContentManager.IsActive(v, ContentType.GAMEPLAY) then
				local desc = ""
				if Locale and ContentManager.GetPackageDescription then
					desc = Locale.Lookup(ContentManager.GetPackageDescription(v)) or ""
				end
				insert(t, format("   %s  %s", tostring(v), tostring(desc)))
			end
		end

		-- EUI (bc1 standard UISKIN GUID)
		local bEUI = ContentManager.IsActive("570f793e-fc33-417f-ae19-7cecccdd5f85", ContentType.UISKIN)
		insert(t, bEUI and "EUI: detected and active" or "EUI: not detected")
	end

	if Locale and Locale.GetCurrentLanguage then
		local lang = Locale.GetCurrentLanguage()
		insert(t, "Language: " .. tostring(lang and lang.Type or "(unknown)"))
	end

	-- Difficulty (active player), game speed, victory conditions
	if Game and Players and GameInfo then
		local iActive = Game.GetActivePlayer()
		local pPlayer = (iActive ~= nil) and Players[iActive] or nil
		if pPlayer then
			local iHandicap = pPlayer:GetHandicapType()
			for row in GameInfo.HandicapInfos() do
				if iHandicap == row.ID then
					insert(t, "Difficulty: " .. Locale.Lookup(row.Description))
					break
				end
			end
		end

		local gsRow = GameInfo.GameSpeeds[Game.GetGameSpeedType()]
		if gsRow then
			insert(t, "Game Speed: " .. Locale.Lookup(gsRow.Description))
		end

		-- All victory conditions on one line
		local vics = {}
		for row in GameInfo.Victories() do
			insert(vics, Locale.Lookup(row.Description) .. (Game.IsVictoryValid(row.ID) and " [x]" or " [ ]"))
		end
		insert(t, "Victory Conditions: " .. concat(vics, "   "))

		local nMax = (GameDefines and GameDefines.MAX_MAJOR_CIVS) or 22
		local civs = {}
		local iCiv, iCivAlive = 0, 0
		for i = 0, nMax - 1 do
			local p = Players[i]
			if p and p:IsEverAlive() then
				iCiv = iCiv + 1
				if p:IsAlive() then iCivAlive = iCivAlive + 1 end
				local civ = GameInfo.Civilizations[p:GetCivilizationType()]
				local civName = (civ and Locale.Lookup(civ.ShortDescription)) or "(unknown civ)"
				local status = p:IsHuman() and "  (human)" or ""
				if not p:IsAlive() then status = status .. "  (eliminated)" end
				insert(civs, "   " .. civName .. status)
			end
		end
		if iCivAlive == iCiv then
			insert(t, format("Players: %d", iCiv))
		else
			insert(t, format("Players: %d started, %d alive", iCiv, iCivAlive))
		end
		for _, line in ipairs(civs) do
			insert(t, line)
		end

		local nMinorMax = (GameDefines and GameDefines.MAX_MINOR_CIVS) or 41
		local iCS, iCSAlive = 0, 0
		for i = nMax, nMax + nMinorMax - 1 do
			local p = Players[i]
			if p and p:IsEverAlive() and p:IsMinorCiv() then
				iCS = iCS + 1
				if p:IsAlive() then iCSAlive = iCSAlive + 1 end
			end
		end
		if iCSAlive == iCS then
			insert(t, format("City-States: %d", iCS))
		else
			insert(t, format("City-States: %d started, %d alive", iCS, iCSAlive))
		end
	end

	if PreGame and PreGame.GetMapScript then
		local sScript = tostring(PreGame.GetMapScript())
		insert(t, "Map Script: " .. (sScript:match("([^\\/]+)$") or sScript))
	end

	if Map and Map.GetGridSize then
		local iW, iH = Map.GetGridSize()
		local sSize = nil
		if Map.GetWorldSize and GameInfo then
			local world = GameInfo.Worlds[Map.GetWorldSize()]
			if world then sSize = Locale.Lookup(world.Description) end
		end
		if sSize then
			insert(t, format("Map Dimensions: %s (%dx%d)", sSize, iW, iH))
		else
			insert(t, format("Map Dimensions: %dx%d", iW, iH))
		end
	end

	return concat(t, "\n")
end

do
	local bOk, snapshot = pcall(BuildSessionSnapshot)
	if bOk and snapshot then
		if Game and Game._LogSapiensSession then
			Game._LogSapiensSession(snapshot)
		else
			print("=== SESSION SNAPSHOT ===\n" .. snapshot)
		end
	end
	if Game and Game._LogSapiensModOptions then
		Game._LogSapiensModOptions()
	end
end
