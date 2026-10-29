 --====================================================================================================================
-- UnitFlagManager
--====================================================================================================================

Events.SequenceGameInitComplete.Add(function()

-- Per-user display preference
local g_UserData = Modding.OpenUserData("GAIA_UIOptions", 1)
if not g_UserData then
	MapModData.GAIA_UIOptions = MapModData.GAIA_UIOptions or {}
	local t = MapModData.GAIA_UIOptions
	g_UserData = { GetValue = function(k) return t[k] end, SetValue = function(k, v) t[k] = v end }
end
local function IsPromotionFlagsEnabled()
	return g_UserData.GetValue("PromotionFlags") == 1
end

local GameInfoUnitPromotions = GameInfo.UnitPromotions
local GameInfoUnits = GameInfo.Units
local GameInfoUnit_FreePromotions = GameInfo.Unit_FreePromotions

local IsUsingEUI = ContentManager.IsActive("570f793e-fc33-417f-ae19-7cecccdd5f85", ContentType.UISKIN)

include "IconSupport"
local IconLookup = IconLookup
local IconHookup = IconHookup
local ColorGreen = Color( 0, 1, 0, 1 )
local ColorYellow = Color( 1, 1, 0, 1 )
local ColorRed = Color( 1, 0, 0, 1 )
local ColorWhite = Color( 1, 1, 1, 1 )

--====================================================================================================================
-- Minor lua optimizations
--====================================================================================================================

local min = math.min
local pi = math.pi
local cos = math.cos
local sin = math.sin
local pairs = pairs
local pcall = pcall
local insert = table.insert
local remove = table.remove
local type = type

local ContextPtr = ContextPtr
local DOMAIN_AIR = DomainTypes.DOMAIN_AIR
local Events = Events
local GetActivePlayer = Game.GetActivePlayer
local GetActiveTeam = Game.GetActiveTeam
local MouseoverUnit = Game.MouseoverUnit
local GridToWorld = GridToWorld
local GameInfoTypes = GameInfoTypes
local InStrategicView = InStrategicView
local Locale = Locale
local GetPlot = Map.GetPlot
local GetPlotByIndex = Map.GetPlotByIndex
local Mouse = Mouse
local Players = Players
local ToGridFromHex = ToGridFromHex
local GetUnitFlagIcon = UI.GetUnitFlagIcon
local UnitMoving = UnitMoving
local Teams = Teams

local GetPlotNumUnits = GetPlot(0,0).GetNumLayerUnits or GetPlot(0,0).GetNumUnits
local GetPlotUnit = GetPlot(0,0).GetLayerUnit or GetPlot(0,0).GetUnit

local g_HiddenControls = Controls.AirCraftFlags
local g_AirCraftFlags = Controls.AirCraftFlags
local g_CivilianFlags = Controls.CivilianFlags
local g_MilitaryFlags = Controls.MilitaryFlags
local g_GarrisonFlags = Controls.GarrisonFlags
local g_AirbaseControls = Controls.AirbaseFlags
local g_SelectedFlags = Controls.SelectedFlags
g_SelectedFlags:ChangeParent( ContextPtr:LookUpControl( "../SelectedUnitContainer" ) or ContextPtr )

local g_SelectedFlag
local g_SelectedCargo = {}
local g_AirbaseFlags = {}
local foreverEmptyTable = setmetatable( {}, { __newindex = function() end } )
local g_UnitFlags = setmetatable( {}, { __index = function( t, k )
		if Players[k] then
			local v = {}
			t[k] = v
			return v
		else
			return foreverEmptyTable
		end
	end } )
local g_spareNewUnitFlags = {}
local g_spareAirbaseFlags = {}

local g_activePlayerID = GetActivePlayer()
local g_activeTeamID = GetActiveTeam()
local g_activePlayer = Players[ g_activePlayerID ]
local g_activeTeam = Teams[ g_activeTeamID ]

local g_RibbonUnits = foreverEmptyTable
LuaEvents.EUI_UnitRibbonTable.Add( function( t ) g_RibbonUnits = t end )

--====================================================================================================================
-- Debug routines
--====================================================================================================================
local debug_print = print

local function debug_unit( playerID, unitID, ... )
	local player = Players[ playerID ]
	local unit = player and player:GetUnitByID( unitID )
	print( "Player#", playerID, "unit#", unitID, unit and Locale.Lookup(unit:GetNameKey()), "unitXY=", unit and unit:GetX(), unit and unit:GetY(), ... )
end
local function debug_flag( flag, ... )
	if type(flag)=="table" then
		debug_unit( flag.m_PlayerID, flag.m_UnitID, "flagXY=", flag.m_Plot and flag.m_Plot:GetX(), flag.m_Plot and flag.m_Plot:GetY(), ... )
	else
		print( "flag=", flag, ... )
	end
end

--====================================================================================================================
-- Cache promotion data
--====================================================================================================================
local g_sparePromotionIcons = {}
local g_isBasicPromotion = {}
local g_promotionOverrides = {}
local g_visiblePromotions = {}
local g_visiblePromotionsIfOptionIsActive = {}
local g_visiblePromotionsList = {}
do
	local isBlandPromotion = { [57]="ABILITY_ATLAS", [58]="ABILITY_ATLAS", [59]="ABILITY_ATLAS" }
	local isHidePromotion = { PROMOTION_EMBARKATION = 1, PROMOTION_DEFENSIVE_EMBARKATION = 1 , PROMOTION_ALLWATER_EMBARKATION = 1, PROMOTION_HOMELAND_GUARDIAN_BOOGALOO = 1, PROMOTION_FAST_WORKER_1 = 1, PROMOTION_SKILLED_WORKER_1 = 1, PROMOTION_SKILLED_WORKER_2 = 1 }
	-- Promotion data pre-processing
	for promotionInfo in GameInfoUnitPromotions() do
		if isBlandPromotion[ promotionInfo.PortraitIndex ] ~= promotionInfo.IconAtlas
			and not isHidePromotion[ promotionInfo.Type ]
		then
			g_visiblePromotions[ promotionInfo.ID ] = promotionInfo
			insert( g_visiblePromotionsList, promotionInfo.ID )
			if not promotionInfo.PromotionPrereqOr2 then
				g_promotionOverrides[ promotionInfo.ID ] = GameInfoTypes[ promotionInfo.PromotionPrereqOr1 or promotionInfo.PromotionPrereq ]
			end
		end
	end
	-- Basic unit promotions
	for unitInfo in GameInfoUnits() do
		local t = {}
		g_isBasicPromotion[ unitInfo.ID ] = t
		for row in GameInfoUnit_FreePromotions{ UnitType=unitInfo.Type } do
			t[ GameInfoTypes[row.PromotionType] or false ] = true
		end
	end
end

--====================================================================================================================
-- Flag promotions
--====================================================================================================================
local function UpdateFlagPromotions( flag )
	local sparePromotionIcons = g_sparePromotionIcons
	local hiddenControls = g_HiddenControls
	if flag.m_IsAtWar or flag.m_PlayerID == GetActivePlayer() then
		local unitID = flag.m_UnitID
		local unit = flag.m_Player:GetUnitByID( unitID )
		if unit then
			local flag2 = g_RibbonUnits[ unitID ]
			local unitPromotions = {}
			local unitPromotionsOverridden = {}

			local isBasicPromotion = g_isBasicPromotion[ unit:GetUnitType() ] or foreverEmptyTable
			local promotionOverrides = g_promotionOverrides
			local unitPromotionOverride
			for promotionID, promotionInfo in pairs( g_visiblePromotionsIfOptionIsActive ) do
				if not isBasicPromotion[ promotionID ] and unit:IsHasPromotion(promotionID) then
					unitPromotions[ promotionID ] = promotionInfo
					unitPromotionOverride = promotionOverrides[ promotionID ]
					if unitPromotionOverride then
						unitPromotionsOverridden[ unitPromotionOverride ] = true
					end
				end
			end

			local promotionIcon, promotionInfo
			while flag do
				local flagPromotionStack = flag.PromotionStack
				local flagPromotionIcons = flag.m_PromotionIcons
				for _, promotionID in ipairs( g_visiblePromotionsList ) do
					promotionInfo = unitPromotions[ promotionID ]
					promotionIcon = flagPromotionIcons[ promotionID ]
					if promotionInfo and not unitPromotionsOverridden[ promotionID ] then
						if promotionIcon then
							promotionIcon:ChangeParent( flagPromotionStack )
						else
							promotionIcon = remove( sparePromotionIcons )
							if promotionIcon then
								promotionIcon:ChangeParent( flagPromotionStack )
							else
								promotionIcon = {}
								ContextPtr:BuildInstanceForControl( "PromotionIcon", promotionIcon, flagPromotionStack )
								promotionIcon = promotionIcon.Image
								promotionIcon:SetTextureSizeVal( 64, 64 )
							end
							IconHookup( promotionInfo.PortraitIndex, 64, promotionInfo.IconAtlas, promotionIcon )
							promotionIcon:SetToolTipString( Locale.ConvertTextKey( promotionInfo.Description ) )
							flagPromotionIcons[ promotionID ] = promotionIcon
						end
					elseif promotionIcon then
						flagPromotionIcons[ promotionID ] = nil
						insert( sparePromotionIcons, promotionIcon )
						promotionIcon:ChangeParent( hiddenControls )
					end
				end
				flag = flag2
				flag2 = nil
			end
		end
	else
		local flagPromotionIcons = flag.m_PromotionIcons
		for promotionID, promotionIcon in pairs( flagPromotionIcons ) do
			flagPromotionIcons[ promotionID ] = nil
			insert( sparePromotionIcons, promotionIcon )
			promotionIcon:ChangeParent( hiddenControls )
		end
	end
end

LuaEvents.CallFlagManagerUpdateUnitPromotions.Add( function( unit )
	local flag = g_UnitFlags[ unit:GetOwner() ][ unit:GetID() ]
	if flag then
		return UpdateFlagPromotions( flag )
	end
end )

-- In some cases
local function UpdatePlayerFlagPromotions( PlayerID )
	for _, flag in pairs(g_UnitFlags[ PlayerID ]) do
		UpdateFlagPromotions( flag )
	end
end
local function UpdateAllFlagPromotions()
	for PlayerID in pairs(g_UnitFlags) do
		UpdatePlayerFlagPromotions( PlayerID )
	end
end
local function UnitPromoted( playerID, unitID )
	local flag = g_UnitFlags[ playerID ][ unitID ]
	if flag then
		return UpdateFlagPromotions( flag )
	end
end
GameEvents.UnitPromoted.Add( function( playerID, unitID ) return pcall( UnitPromoted, playerID, unitID ) end )

--====================================================================================================================
-- Manage flag interactions with user
--====================================================================================================================
local function UnitFlagClicked( playerID, unitID )
	return Events.SerialEventUnitFlagSelected( playerID, unitID )
end

local function UnitFlagEnterExit( isEnter, playerID, unitID )
	local mouseOverUnit = Players[ playerID ]
	if mouseOverUnit then
		mouseOverUnit = mouseOverUnit:GetUnitByID( unitID )
		if mouseOverUnit then
			return MouseoverUnit( mouseOverUnit, isEnter )
		end
	end
end

local function UnitFlagEnter( ... )
	return UnitFlagEnterExit( true, ... )
end

local function UnitFlagExit( ... )
	return UnitFlagEnterExit( false, ... )
end

local function CargoFlagClicked( playerID, unitID )
	local player = Players[ playerID ]
	local unit = player and player:GetUnitByID( unitID )
	if unit then
		local plot = unit:GetPlot()
		if plot then
			for i = 0, GetPlotNumUnits( plot ) - 1 do
				local cargoUnit = GetPlotUnit( plot, i )
				if cargoUnit:GetTransportUnit() == unit then
					playerID, unitID = cargoUnit:GetOwner(), cargoUnit:GetID()
					if cargoUnit:CanMove() then break end
				end
			end
		end
	end
	return Events.SerialEventUnitFlagSelected( playerID, unitID )
end

local function AirbaseFlagClicked( plotIndex )
	local plot = GetPlotByIndex( plotIndex )
	if plot then
		local playerID, unitID
		for i = 0, GetPlotNumUnits( plot ) - 1 do
			local unit = GetPlotUnit( plot, i )
			if not unit:IsCargo() and unit:GetDomainType() == DOMAIN_AIR then
				playerID, unitID = unit:GetOwner(), unit:GetID()
				if unit:CanMove() then break end
			end
		end
		if playerID and unitID then
			return Events.SerialEventUnitFlagSelected( playerID, unitID )
		end
	end
end

local function SetFlagParent( flag )
	if flag.m_IsSelected then
		flag.Anchor:ChangeParent( g_SelectedFlags )
	elseif flag.m_TransportUnitID or flag.m_IsAirCraft then
		flag.Anchor:ChangeParent( g_AirCraftFlags )
	elseif flag.m_IsCivilian then
		flag.Anchor:ChangeParent( g_CivilianFlags )
	elseif flag.m_IsGarrisoned then
		flag.Anchor:ChangeParent( g_GarrisonFlags )
	else
		flag.Anchor:ChangeParent( g_MilitaryFlags )
	end
end

local function UpdatePlotFlags( plot )
	local flags = {}
	local aflags = {}
	local unit, flag, n
	local city = plot:GetPlotCity()
	if city then
		local l = -43
		local r = 43
		local y = GetActiveTeam() == city:GetTeam() and -39 or -36
		local gflags = {}
		for i = 0, GetPlotNumUnits( plot ) - 1 do
			unit = GetPlotUnit( plot, i )
			flag = g_UnitFlags[ unit:GetOwner() ][ unit:GetID() ]
			if flag and flag.m_Plot then
				if unit:IsCargo() then
				elseif flag.m_IsAirCraft then
					insert( aflags, unit )
				elseif unit:IsGarrisoned() then
					insert( gflags, flag )
				else
					insert( flags, flag )
				end
			end
		end
		n = #flags
		if n == 1 then
			flags[1].Container:SetOffsetVal( r, y )
		elseif n > 1 then
			local a = -min(35/(n-1),20)
			local b = y-a
			for i=n, 1, -1 do
				flags[i].Container:SetOffsetVal( r, a*i+b )
				SetFlagParent( flags[i] )
			end
		end
		n = #gflags
		if n == 1 then
			gflags[1].Container:SetOffsetVal( l, y )
		elseif n > 1 then
			local a = -min(35/(n-1),20)
			local b = y-a
			for i=n, 1, -1 do
				gflags[i].Container:SetOffsetVal( l, a*i+b )
				SetFlagParent( gflags[i] )
			end
		end
	else
		for i = 0, GetPlotNumUnits( plot ) - 1 do
			unit = GetPlotUnit( plot, i )
			flag = g_UnitFlags[ unit:GetOwner() ][ unit:GetID() ]
			if flag and flag.m_Plot then
				if unit:IsCargo() then
				elseif flag.m_IsAirCraft then
					insert( aflags, unit )
				else
					insert( flags, flag )
				end
			end
		end
		n = #flags
		if n == 1 then
			flags[1].Container:SetOffsetVal( 0, 0 )
		elseif n > 1 then
			local a = -min(35/(n-1),20)
			for i=n, 1, -1 do
				flags[i].Container:SetOffsetVal( 0, (i-1)*a )
				SetFlagParent( flags[i] )
			end
		end
	end
	n = #aflags
	local plotIndex = plot:GetPlotIndex()
	flag = g_AirbaseFlags[ plotIndex ]
	if n > 0 then
		if not flag then
			flag = remove( g_spareAirbaseFlags )
			if flag then
				flag.Anchor:ChangeParent( g_AirbaseControls )
			else
				flag = {}
				ContextPtr:BuildInstanceForControl( "AirbaseFlag", flag, g_AirbaseControls )
				flag.Button:RegisterCallback( Mouse.eLClick, AirbaseFlagClicked )
			end
			g_AirbaseFlags[ plotIndex ] = flag
			local x, y, z = GridToWorld( plot:GetX(), plot:GetY() )
			local flatval = 25;
			if city then
				flatval = 35;
			end
			flag.Anchor:SetWorldPositionVal( x, y, z + flatval )
			flag.Button:SetVoid1( plotIndex )
		end
		flag.Anchor:SetHide( not plot:IsVisible( g_activeTeamID, true ) )
		flag.Button:SetText( n )
		flag.Button:SetToolTipString( plot:_GetAirUnitsTooltip() )

		if not IsUsingEUI then
			for i = 0, GetPlotNumUnits( plot ) - 1 do
				unit = GetPlotUnit( plot, i )
				if(unit:HasCargo())then
					local cargoflag = g_UnitFlags[ unit:GetOwner() ][ unit:GetID() ]
					if cargoflag then
						cargoflag.CargoBG:SetHide( true )
					end
				end
			end
		end
	elseif flag then
		g_AirbaseFlags[ plotIndex ] = nil
		flag.Anchor:ChangeParent( g_HiddenControls )
		insert( g_spareAirbaseFlags, flag )
	end
end

local function SetFlagSelected( flag, isSelected )
	flag.m_IsSelected = isSelected
	flag.FlagHighlight:SetHide( not (IsUsingEUI and isSelected) )
	-- RestoreCargoFlagParents
	for i = 1, #g_SelectedCargo do
		SetFlagParent( g_SelectedCargo[i] )
		g_SelectedCargo[i] = nil
	end
	if isSelected then
		local selectedUnit = flag.m_Player:GetUnitByID( flag.m_UnitID )
		local plot = selectedUnit and selectedUnit:GetPlot()
		if plot then
			local transportUnit = selectedUnit:GetTransportUnit()
			local cargoUnit, cargoFlag
			if transportUnit then
				local x, y
				local transportFlag = g_UnitFlags[ transportUnit:GetOwner() ][ transportUnit:GetID() ]
				if transportFlag then
					x, y = transportFlag.Container:GetOffsetVal()
				else
					x, y = 0, 0
				end
				local cargo = transportUnit:GetCargo()
				local a = min( pi / 3, 5.7 / cargo )
				local a0 = -a*(cargo-1)/2 - pi
				local j = 0
				for i = 0, GetPlotNumUnits( plot ) - 1 do
					cargoUnit = GetPlotUnit( plot, i )
					if cargoUnit:GetTransportUnit() == transportUnit then
						cargoFlag = g_UnitFlags[ cargoUnit:GetOwner() ][ cargoUnit:GetID() ]
						if cargoFlag then
							insert( g_SelectedCargo, cargoFlag )
							cargoFlag.Container:SetOffsetVal( cos( a*j + a0 )*38 + x, sin( a*j + a0 )*38 + y )
							cargoFlag.Anchor:ChangeParent( g_SelectedFlags )
						end
						j = j + 1
					end
				end
			elseif flag.m_IsAirCraft then
				local airbase = {}
				for i = 0, GetPlotNumUnits( plot ) - 1 do
					cargoUnit = GetPlotUnit( plot, i )
					cargoFlag = g_UnitFlags[ cargoUnit:GetOwner() ][ cargoUnit:GetID() ]
					if cargoFlag and cargoFlag.m_IsAirCraft and not cargoUnit:GetTransportUnit() then
						insert( airbase, cargoFlag )
					end
				end
				local n=#airbase
				if n > 0 then
					local a = min( 0.5, 2.7 / n )
					local a0 = -a*(n+1)/2 - pi/2
					for i = 1, n do
						cargoFlag = airbase[i]
						insert( g_SelectedCargo, cargoFlag )
						cargoFlag.Anchor:ChangeParent( g_SelectedFlags )
						cargoFlag.Container:SetOffsetVal( cos( a*i + a0 )*80, sin( a*i + a0 )*80 )
					end
				end
			end
		end
		g_SelectedFlag = flag
	elseif g_SelectedFlag == flag then
		g_SelectedFlag = nil
	end
	return SetFlagParent( flag )
end

local function FinishMove( flag, unit )
	local transportUnit = unit:GetTransportUnit()
	local oldTransportUnitID = flag.m_TransportUnitID
	local oldTransportUnit = flag.m_Player:GetUnitByID( oldTransportUnitID )
	if oldTransportUnit ~= transportUnit then
		if oldTransportUnit then
			local oldCarrier = g_UnitFlags[ oldTransportUnit:GetOwner() ][ oldTransportUnitID ]
			if oldCarrier then
				local cargo = oldTransportUnit:GetCargo()
				oldCarrier.CargoBG:SetHide( cargo < 1 )
				oldCarrier.Cargo:SetText( cargo )
			end
		end
		if transportUnit then
			local transportUnitID = transportUnit:GetID()
			flag.m_TransportUnitID = transportUnitID
			local newCarrier = g_UnitFlags[ transportUnit:GetOwner() ][ transportUnitID ]
			if newCarrier then
				local cargo = transportUnit:GetCargo()
				newCarrier.CargoBG:SetHide( cargo < 1 )
				newCarrier.Cargo:SetText( cargo )
			end
		else
			flag.m_TransportUnitID = nil
		end
	end
	local oldPlot = flag.m_Plot
	local newPlot = unit:GetPlot()
	if oldPlot ~= newPlot then
		flag.m_Plot = newPlot
		if oldPlot then
			UpdatePlotFlags( oldPlot )
		end
		if newPlot then
			local x, y, z = GridToWorld( newPlot:GetX(), newPlot:GetY() )
			flag.Anchor:SetWorldPositionVal( x, y, z + 35 )
			return UpdatePlotFlags( newPlot )
		end
	end
end

local function UpdateFlagType( flag, unit )

	local textureName, maskName

	if unit:IsEmbarked() then
		textureName = "UnitFlagEmbark.dds"
		maskName = "UnitFlagEmbarkMask.dds"
		flag.UnitIconShadow:SetOffsetVal( -1, -2 )

	elseif unit:IsGarrisoned() then
		textureName = "UnitFlagBase.dds"
		maskName = "UnitFlagMask.dds"
		flag.UnitIconShadow:SetOffsetVal( -1, 1 )

	elseif unit:GetFortifyTurns() > 0 then
		textureName = "UnitFlagFortify.dds"
		maskName = "UnitFlagFortifyMask.dds"
		flag.UnitIconShadow:SetOffsetVal( -1, 0 )

	elseif flag.m_IsTrade then
		textureName = "UnitFlagTrade.dds"
		maskName = "UnitFlagTradeMask.dds"
		flag.UnitIconShadow:SetOffsetVal( -1, 0 )

	elseif flag.m_IsCivilian then
		textureName = "UnitFlagCiv.dds"
		maskName = "UnitFlagCivMask.dds"
		flag.UnitIconShadow:SetOffsetVal( -1, -3 )
	else
		textureName = "UnitFlagBase.dds"
		maskName = "UnitFlagMask.dds"
		flag.UnitIconShadow:SetOffsetVal( -1, 0 )
	end

	flag.UnitIconShadow:ReprocessAnchoring()

	flag.FlagShadow:SetTexture( textureName )
	flag.FlagBase:SetTexture( textureName )
	flag.FlagBaseOutline:SetTexture( textureName )
	flag.LightEffect:SetTexture( textureName )
	flag.HealthBarBG:SetTexture( textureName )
	flag.AlphaAnim:SetTexture( textureName )
	flag.FlagHighlight:SetTexture( textureName )
	return flag.ScrollAnim:SetMask( maskName )
end

local function UpdateFlagHealth( flag, damage, unit )
	if damage > 0 then
		flag.m_MaxHitPoints = unit:GetMaxHitPoints()
		local healthPercent = 1 - damage / flag.m_MaxHitPoints
		if healthPercent > 0.66 then
			flag.HealthBar:SetFGColor( ColorGreen )
		elseif healthPercent > 0.33 then
			flag.HealthBar:SetFGColor( ColorYellow )
		elseif healthPercent > 0 then
			flag.HealthBar:SetFGColor( ColorRed )
		else
			healthPercent = 0
		end
		flag.HealthBar:SetPercent( healthPercent )
		flag.HealthBarBG:SetHide( false )
		flag.HealthBar:SetHide( false )
		flag.AlphaAnim:SetTextureOffsetVal( 64, 64 )
		flag.FlagHighlight:SetTextureOffsetVal( 64, 128 )
	else
		flag.HealthBarBG:SetHide( true )
		flag.HealthBar:SetHide( true )
		flag.AlphaAnim:SetTextureOffsetVal( 0, 64 )
		flag.FlagHighlight:SetTextureOffsetVal( 0, 128 )
	end
end

local g_EUIToolTipControls = {}
if IsUsingEUI then
	TTManager:GetTypeControlTable( "EUI_UnitTooltip", g_EUIToolTipControls )
end
local UseEUIToolTip = g_EUIToolTipControls.Text ~= nil

local function SealiftFlagToolTipLine( unit )
	if unit:GetTeam() == g_activeTeamID and unit._IsSealiftPending and unit:_IsSealiftPending() then
		local city = unit._GetSealiftCity and unit:_GetSealiftCity()
		if city then
			return Locale.ConvertTextKey( "TXT_KEY_GAIA_SEALIFT_IN_TRANSIT_TT", city:GetNameKey(), Game.GetGameTurn() + unit:_GetSealiftTurnsLeft() )
		end
		return Locale.ConvertTextKey( "TXT_KEY_GAIA_SEALIFT_IN_TRANSIT" )
	end
end

local function EUIUnitFlagToolTip( button )
	local tip = g_EUIToolTipControls
	local player = Players[ button:GetVoid1() ]
	local unit = player and player:GetUnitByID( button:GetVoid2() )
	if unit then
		if tip.Text then
			local sealiftLine = SealiftFlagToolTipLine( unit )
			tip.Text:SetText( Locale.Lookup( unit:GetNameKey() ) .. ( sealiftLine and "[NEWLINE]" .. sealiftLine or "" ) )
		end
		if tip.UnitPortrait then
			local portraitOffset, portraitAtlas = UI.GetUnitPortraitIcon( unit )
			IconHookup( portraitOffset, 128, portraitAtlas, tip.UnitPortrait )
		end
		if tip.CivIcon and CivIconHookup then
			CivIconHookup( unit:GetOwner(), 64, tip.CivIcon, tip.CivIconBG, tip.CivIconShadow, false, true )
		end
		if tip.Box then
			tip.Box:DoAutoSize()
		end
	end
	LuaEvents.UnitFlagToolTip.Call( button )
end

local function UpdateFlagToolTip( flag, unit )
	local player = flag.m_Player
	local adjectiveKey = player:GetCivilizationAdjectiveKey()
	local nameKey = unit:GetNameKey()
	local text
	if PreGame.IsMultiplayerGame() and player:IsHuman() then
		text = Locale.ConvertTextKey( "TXT_KEY_MULTIPLAYER_UNIT_TT", player:GetNickName(), adjectiveKey, nameKey )
	elseif unit:HasName() then
		text = Locale.Lookup( unit:GetNameNoDesc() ) .. "[NEWLINE](" .. Locale.ConvertTextKey( "TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV", adjectiveKey, nameKey ) .. ")"
	else
		text = Locale.ConvertTextKey( "TXT_KEY_PLOTROLL_UNIT_DESCRIPTION_CIV", adjectiveKey, nameKey )
	end
	if player:GetTeam() == g_activeTeamID then
		local religionID = unit:GetReligion()
		if religionID > ReligionTypes.RELIGION_PANTHEON then
			text = text .. " - " .. Locale.Lookup( Game.GetReligionName( religionID ) )
		end
		local sealiftLine = SealiftFlagToolTipLine( unit )
		if sealiftLine then
			text = text .. "[NEWLINE]" .. sealiftLine
		end
		if flag.m_PlayerID == g_activePlayerID then
			text = text .. Locale.ConvertTextKey( "TXT_KEY_UPANEL_CLICK_TO_SELECT" )
		end
	end
	return flag.Button:SetToolTipString( text )
end

local function CreateNewFlag( playerID, unitID, isSelected, isHiddenByFog, isInvisibleToActiveTeam )

	local player = Players[ playerID ]
	local unit = player and player:GetUnitByID( unitID )
	if unit and not unit:IsDead() then

		local teamID = player:GetTeam()
		local isAircraft = false
		local isCivilian = false
		local parentContainer
		if unit:IsCombatUnit() and not unit:IsEmbarked() then
			parentContainer = g_MilitaryFlags
		elseif unit:GetDomainType() == DOMAIN_AIR then
			parentContainer = g_AirCraftFlags
			isAircraft = true
		else
			parentContainer = g_CivilianFlags
			isCivilian = true
		end

		local flag = remove( g_spareNewUnitFlags )
		if flag then
			flag.Anchor:ChangeParent( parentContainer )
			flag.FlagHighlight:SetColor( ColorWhite )
		else
			flag = { m_PromotionIcons = {} }
			ContextPtr:BuildInstanceForControl( "UnitFlag", flag, parentContainer )
			flag.Button:RegisterCallback( Mouse.eLClick, UnitFlagClicked )
			if MouseoverUnit then
	            flag.Button:RegisterCallback( Mouse.eMouseEnter, UnitFlagEnter )
	            flag.Button:RegisterCallback( Mouse.eMouseExit, UnitFlagExit )
			end
			flag.Cargo:RegisterCallback( Mouse.eLClick, CargoFlagClicked )
			if UseEUIToolTip then
				flag.Button:SetToolTipCallback( EUIUnitFlagToolTip )
				flag.Button:SetToolTipType( "EUI_UnitTooltip" )
			end
		end
		flag.Cargo:SetVoids( playerID, unitID )
		flag.Button:SetVoids( playerID, unitID )

		g_UnitFlags[ playerID ][ unitID ] = flag
		flag.m_TransportUnitID = nil
		flag.m_IsAirCraft = isAircraft
		flag.m_IsCivilian = isCivilian
		flag.m_IsGarrisoned = unit:IsGarrisoned()
		flag.m_IsHiddenByFog = isHiddenByFog
		flag.m_IsInvisibleToActiveTeam = isInvisibleToActiveTeam
		flag.m_Plot = nil
		flag.m_IsSelected = isSelected
		flag.m_IsTrade = unit.IsTrade and unit:IsTrade()
		flag.m_MaxHitPoints = unit:GetMaxHitPoints()
		flag.m_Player = player
		flag.m_PlayerID = playerID
		flag.m_UnitID = unitID

		---------------------------------------------------------
		-- Set flag color
		local iconColor, flagColor = player:GetPlayerColors()
		if player:IsMinorCiv() then
			flagColor, iconColor = iconColor, flagColor
		end
		flag.FlagBase:SetColor( flagColor )
		local color = iconColor
		flag.UnitIcon:SetColor( color )
		flag.FlagBaseOutline:SetColor( color )

		---------------------------------------------------------
		-- Set flag textures
		local flagOffset, flagAtlas = GetUnitFlagIcon( unit )
		local textureOffset, textureSheet = IconLookup( flagOffset, 32, flagAtlas )
		flag.UnitIcon:SetTexture( textureSheet )
		flag.UnitIconShadow:SetTexture( textureSheet )
		flag.UnitIcon:SetTextureOffset( textureOffset )
		flag.UnitIconShadow:SetTextureOffset( textureOffset )

		local cargo = unit:GetCargo()
		flag.CargoBG:SetHide( cargo < 1 )
		flag.Cargo:SetText( cargo )

		---------------------------------------------------------
		-- Set up other info
		flag.Anchor:SetHide( isHiddenByFog or isInvisibleToActiveTeam )
		flag.FlagShadow:SetAlpha( unit:CanMove() and 1 or 0.5 )
		flag.Button:SetDisabled( g_activeTeamID ~= teamID )
		flag.Button:SetConsumeMouseOver( g_activeTeamID == teamID )
		if not UseEUIToolTip then
			UpdateFlagToolTip( flag, unit )
		end
		UpdateFlagType( flag, unit )
		UpdateFlagHealth( flag, unit:GetDamage(), unit )
		SetFlagSelected( flag, isSelected )
		if g_activeTeam:IsAtWar( teamID ) then
			flag.m_IsAtWar = true
			flag.FlagHighlight:SetHide( not IsUsingEUI )
			flag.FlagHighlight:SetColor( ColorRed )
		else
			flag.m_IsAtWar = false
		end
		FinishMove( flag, unit )

	end

end

local function DestroyFlag( flag )
	local transportUnit = flag.m_TransportUnitID and flag.m_Player:GetUnitByID( flag.m_TransportUnitID )
	local carrier = transportUnit and g_UnitFlags[ transportUnit:GetOwner() ][ flag.m_TransportUnitID ]
	if carrier then
		local cargo = transportUnit:GetCargo()
		carrier.CargoBG:SetHide( cargo < 1 )
		carrier.Cargo:SetText( cargo )
	end
	flag.Anchor:ChangeParent( g_HiddenControls )
	insert( g_spareNewUnitFlags, flag )
	g_UnitFlags[ flag.m_PlayerID ][ flag.m_UnitID ] = nil
	if flag.m_Plot then
		return UpdatePlotFlags( flag.m_Plot )
	end
end

local function ForceHide( playerID, unitID, isForceHide )
	local flag = g_UnitFlags[ playerID ][ unitID ]
	if flag then
		return flag.Anchor:SetHide( isForceHide or flag.m_IsHiddenByFog or flag.m_IsInvisibleToActiveTeam )
	end
end

--====================================================================================================================
-- GameplayUnitCreated fires upon unit creation
--====================================================================================================================
Events.SerialEventUnitCreated.Add(
function( playerID, unitID, hexPos, unitType, cultureType, civID, primaryColor, secondaryColor, unitFlagIndex, fogState, isSelected, isMilitary, isVisible )
	return CreateNewFlag( playerID, unitID, isSelected, fogState ~= 2, not isVisible )
end)

Events.LocalMachineUnitPositionChanged.Add(
function( playerID, unitID, unitPosition )
	local flag = g_UnitFlags[ playerID ][ unitID ]
	local unit = flag and flag.m_Player:GetUnitByID( unitID )
	if unit then
		flag.Anchor:SetWorldPositionVal( unitPosition.x, unitPosition.y, unitPosition.z + 35 )
		local plot = flag.m_Plot
		if plot then
			if UnitMoving( playerID, unitID ) then
				flag.m_Plot = nil
			end
			local targetPlot = unit:GetPlot()
			if targetPlot ~= plot then
				UpdatePlotFlags( plot )
				return flag.Container:SetOffsetVal( 0, 0 )
			end
		end
	else
	end
end)

local function OnFlagTypeChange( playerID, unitID )
	local flag = g_UnitFlags[ playerID ][ unitID ]
	local unit = flag and flag.m_Player:GetUnitByID( unitID )
	if unit then
		return UpdateFlagType( flag, unit )
	end
end
Events.UnitActionChanged.Add( OnFlagTypeChange )
Events.UnitEmbark.Add( OnFlagTypeChange )

local function OnUnitMoveQueueChanged( playerID, unitID )
	local flag = g_UnitFlags[ playerID ][ unitID ]
	local unit = flag and flag.m_Player:GetUnitByID( unitID )
	if unit then
		return FinishMove( flag, unit )
	end
end
Events.UnitMoveQueueChanged.Add( OnUnitMoveQueueChanged )

Events.SerialEventUnitTeleportedToHex.Add(
function( hexX, hexY, playerID, unitID )
	return OnUnitMoveQueueChanged( playerID, unitID )
end)

Events.UnitVisibilityChanged.Add(
function( playerID, unitID, isVisible, checkFlag )
	if checkFlag then
		local flag = g_UnitFlags[ playerID ][ unitID ]
		if flag then
			flag.m_IsInvisibleToActiveTeam = not isVisible
			return flag.Anchor:SetHide( not isVisible or flag.m_IsHiddenByFog )
		end
	end
end)

Events.SerialEventUnitDestroyed.Add(
function( playerID, unitID )
	local flag = g_UnitFlags[ playerID ][ unitID ]
	if flag then
		return DestroyFlag( flag )
	else
	end
end)

--====================================================================================================================
-- On Unit Selection Change
--====================================================================================================================
Events.UnitSelectionChanged.Add(
function( playerID, unitID, _, _, _, isSelected )
	local flag = g_UnitFlags[ playerID ][ unitID ]
	if flag then
		return SetFlagSelected( flag, isSelected )
	else
	end
end)

Events.SerialEventUnitSetDamage.Add(
function( playerID, unitID, damage )
	local flag = g_UnitFlags[ playerID ][ unitID ]
	if flag then
		local player = Players[ playerID ]
		local unit = player and player:GetUnitByID( unitID )
		if unit  then
			UpdateFlagHealth( flag, damage, unit )
		end
	else
	end
end)

Events.HexFOWStateChanged.Add(
function( hexPos, fogState, isWholeMap )
	local isInvisible = fogState ~= 2
	if isWholeMap then
		for _, flags in pairs( g_UnitFlags ) do
			for _, flag in pairs( flags ) do
				flag.m_IsHiddenByFog = isInvisible
				flag.Anchor:SetHide( isInvisible or flag.m_IsInvisibleToActiveTeam )
			end
		end
		for _, flag in pairs( g_AirbaseFlags ) do
			flag.Anchor:SetHide( isInvisible )
		end
	else
		local plot = GetPlot( ToGridFromHex( hexPos.x, hexPos.y ) )
		if plot then
			for i = 0, GetPlotNumUnits( plot ) - 1 do
				local unit = GetPlotUnit( plot, i )
				local flag = unit and g_UnitFlags[ unit:GetOwner() ][ unit:GetID() ]
				if flag then
					flag.m_IsHiddenByFog = isInvisible
					flag.Anchor:SetHide( isInvisible or flag.m_IsInvisibleToActiveTeam )
				end
			end
			local flag = g_AirbaseFlags[ plot:GetPlotIndex() ]
			if flag then
				flag.Anchor:SetHide( isInvisible )
			end
		end
	end
end)

Events.UnitStateChangeDetected.Add(
function( playerID, unitID, fogState )
	local flag = g_UnitFlags[ playerID ][ unitID ]
	if flag then
		flag.m_IsHiddenByFog = fogState ~= 2
		return flag.Anchor:SetHide( fogState ~=2 or flag.m_IsInvisibleToActiveTeam )
	else
	end
end)

Events.UnitShouldDimFlag.Add(
function( playerID, unitID, isDimmed )
	local flag = g_UnitFlags[ playerID ][ unitID ]
	local unit = flag and flag.m_Player:GetUnitByID( unitID )
	if unit then
		flag.FlagShadow:SetAlpha( isDimmed and 0.5 or 1.0 )
		if isDimmed or not unit:HasMoved() then
			flag.MovementPip:SetHide( true )
		else
			flag.MovementPip:SetTextureOffsetVal( 0, unit:IsCombatUnit() and unit:IsOutOfAttacks() and 96 or 32 )
			flag.MovementPip:SetHide( false )
		end
		local cargo = unit:GetCargo()
		local plot = unit:GetPlot()
		flag.CargoBG:SetHide( cargo < 1 or ( not IsUsingEUI and plot ~= nil and g_AirbaseFlags[ plot:GetPlotIndex() ] ~= nil ) )
		flag.Cargo:SetText( cargo )
		if not UseEUIToolTip then
			UpdateFlagToolTip( flag, unit )
		end
		return UpdateFlagPromotions( flag )
	else
	end
end)

local function OnCity( hexPos )
	local plot = GetPlot( ToGridFromHex( hexPos.x, hexPos.y ) )
	if plot then
		return UpdatePlotFlags( plot )
	end
end
Events.SerialEventCityDestroyed.Add( OnCity )
Events.SerialEventCityCaptured.Add( OnCity )
Events.SerialEventCityCreated.Add( OnCity )

Events.SerialEventEnterCityScreen.Add(
function()
	return g_SelectedFlags:SetHide( true )
end)
Events.SerialEventExitCityScreen.Add(
function()
	return g_SelectedFlags:SetHide( InStrategicView() )
end)

Events.StrategicViewStateChanged.Add( function( isStrategicView, isCityBanners )
	g_CivilianFlags:SetHide( isStrategicView )
	g_MilitaryFlags:SetHide( isStrategicView )
	g_GarrisonFlags:SetHide( isStrategicView and not isCityBanners )
	g_AirbaseControls:SetHide( isStrategicView )
	return g_SelectedFlags:SetHide( isStrategicView )
end)

--====================================================================================================================
-- Hide flag during combat
--====================================================================================================================
Events.RunCombatSim.Add(
function( attackerPlayerID,
		attackerUnitID,
		attackerUnitDamage,
		attackerFinalUnitDamage,
		attackerMaxHitPoints,
		defenderPlayerID,
		defenderUnitID,
		defenderUnitDamage,
		defenderFinalUnitDamage,
		defenderMaxHitPoints,
		bContinuation )
	ForceHide( attackerPlayerID, attackerUnitID, true )
	return ForceHide( defenderPlayerID, defenderUnitID, true )
end)

--====================================================================================================================
-- Show flag after combat
--====================================================================================================================
Events.EndCombatSim.Add(
function( attackerPlayerID,
		attackerUnitID,
		attackerUnitDamage,
		attackerFinalUnitDamage,
		attackerMaxHitPoints,
		defenderPlayerID,
		defenderUnitID,
		defenderUnitDamage,
		defenderFinalUnitDamage,
		defenderMaxHitPoints )
	ForceHide( attackerPlayerID, attackerUnitID, false )
	return ForceHide( defenderPlayerID, defenderUnitID, false )
end)

--====================================================================================================================
-- War Declared
--====================================================================================================================
Events.WarStateChanged.Add(
function( teamID1, teamID2, isAtWar )
	if teamID1 == g_activeTeamID then
		teamID1 = teamID2
	elseif teamID2 ~= g_activeTeamID then
		return
	end
	for playerID, player in pairs( Players ) do
		if player and player:IsAlive() and player:GetTeam() == teamID1 then
			for _, flag in pairs( g_UnitFlags[ playerID ] ) do
				flag.m_IsAtWar = isAtWar
				flag.FlagHighlight:SetHide( not (IsUsingEUI and isAtWar) )
				flag.FlagHighlight:SetColor( isAtWar and ColorRed or ColorWhite )
				UpdateFlagPromotions( flag )
			end
		end
	end
end)

Events.GameplaySetActivePlayer.Add( function( activePlayerID )
	g_activePlayerID = activePlayerID
	g_activeTeamID = GetActiveTeam()
	g_activePlayer = Players[ activePlayerID ]
	g_activeTeam = Teams[ g_activeTeamID ]
	if g_SelectedFlag then
		SetFlagSelected( g_SelectedFlag, false )
	end
	for playerID, player in pairs( Players ) do
		if player and player:IsAlive() then
			local teamID = player:GetTeam()
			local isActiveTeam = teamID == g_activeTeamID
			local isAtWar = g_activeTeam:IsAtWar( teamID )
			for _, flag in pairs( g_UnitFlags[ playerID ] ) do
				flag.m_IsAtWar = isAtWar
				flag.Button:SetDisabled( not isActiveTeam )
				flag.Button:SetConsumeMouseOver( isActiveTeam )
				flag.FlagHighlight:SetHide( not (IsUsingEUI and isAtWar) )
				flag.FlagHighlight:SetColor( isAtWar and ColorRed or ColorWhite )
				UpdateFlagPromotions( flag )
				if not UseEUIToolTip then
					local unit = player:GetUnitByID( flag.m_UnitID )
					if unit then
						UpdateFlagToolTip( flag, unit )
					end
				end
			end
		end
	end
end)

--====================================================================================================================
-- On shutdown
--====================================================================================================================
ContextPtr:SetShutdown( function()
	return g_SelectedFlags:ChangeParent( ContextPtr )
end)

do
--====================================================================================================================
-- Initilize flags for all units 
--====================================================================================================================
	local plot
	for playerID, player in pairs( Players ) do
		-- DestroyFlag any existing unit flags
		for _, flag in pairs( g_UnitFlags[ playerID ] ) do
			DestroyFlag( flag )
		end
		if player and player:IsEverAlive() then
			for unit in player:Units() do
				plot = unit:GetPlot()
				CreateNewFlag( playerID, unit:GetID(), unit:IsSelected(), plot and not plot:IsVisible( g_activeTeamID, true ), unit:IsInvisible( g_activeTeamID, true ) )
			end
		end
	end

--====================================================================================================================
-- Handle flag promotions toggle change
--====================================================================================================================
	local function UpdateOptions()
		g_visiblePromotionsIfOptionIsActive = IsPromotionFlagsEnabled() and g_visiblePromotions or foreverEmptyTable
		UpdateAllFlagPromotions()
	end
	LuaEvents.PromotionFlags.Add( UpdateOptions )
	UpdateOptions()
end
end)