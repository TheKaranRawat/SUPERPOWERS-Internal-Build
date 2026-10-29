
-------------------------------------------------
-- Bombardment
-------------------------------------------------

local redColor = Vector4( 0.7, 0, 0, 1 );
local highlightColor = Vector4( 0.7, 0.7, 0, 1 );
local ms_CityBombardPlayer = -1;
local ms_CityBombardID = -1;

function RangedStrikeHighlight()
	local pHeadSelectedCity = UI.GetHeadSelectedCity();
	local pHeadSelectedUnit = UI.GetHeadSelectedUnit();
	local thingThatCanActuallyFire = nil;
	
	local iRange;
	local bIndirectFireAllowed;
	local bDomainOnly;
	local thisPlot = nil;
	local thisX;
	local thisY;
	local thisTeam;
	local thisDomain;

	if pHeadSelectedCity and pHeadSelectedCity:CanRangeStrike() then
		if pHeadSelectedCity._GetBombardRange then
			local iIndirect
			iRange, iIndirect = pHeadSelectedCity:_GetBombardRange();
			bIndirectFireAllowed = (iIndirect == 1);
		else
			iRange = 2;
			bIndirectFireAllowed = false;
		end
		thisPlot = pHeadSelectedCity:Plot();
		thisX = pHeadSelectedCity:GetX();
		thisY = pHeadSelectedCity:GetY();
		thisTeam = pHeadSelectedCity:GetTeam();
		thingThatCanActuallyFire = pHeadSelectedCity;
		bDomainOnly = false;
	elseif pHeadSelectedUnit and pHeadSelectedUnit:CanRangeStrike() then
		iRange = pHeadSelectedUnit:Range();
		bIndirectFireAllowed = pHeadSelectedUnit:IsRangeAttackIgnoreLOS();
		thisPlot = pHeadSelectedUnit:GetPlot();
		thisX = pHeadSelectedUnit:GetX();
		thisY = pHeadSelectedUnit:GetY();
		thisTeam = pHeadSelectedUnit:GetTeam();
		thingThatCanActuallyFire = pHeadSelectedUnit;
		bDomainOnly = pHeadSelectedUnit:IsRangeAttackOnlyInDomain();
		thisDomain = pHeadSelectedUnit:GetDomainType();
	end
	if thingThatCanActuallyFire ~= nil and thisPlot then
		local NO_DIRECTION = -1;
		for iDX = -iRange, iRange do
			for iDY = -iRange, iRange do
				local pTargetPlot = Map.GetPlotXY(thisX, thisY, iDX, iDY);
				local bCanRangeStrike = true;

				if pTargetPlot then
					if not bIndirectFireAllowed then
						if not thisPlot:CanSeePlot(pTargetPlot, thisTeam, iRange - 1, NO_DIRECTION, thisDomain) then
							bCanRangeStrike = false;
						end
					end
					
					if bDomainOnly then
						if thingThatCanActuallyFire:GetDomainType() == DomainTypes.DOMAIN_LAND and pTargetPlot:IsWater() then
							bCanRangeStrike = false;
						elseif thingThatCanActuallyFire:GetDomainType() == DomainTypes.DOMAIN_SEA and not pTargetPlot:IsWater() then
							bCanRangeStrike = false;
						end
					end

					if bCanRangeStrike then
						if pTargetPlot:IsVisible(thisTeam, false) then
							local plotX = pTargetPlot:GetX();
							local plotY = pTargetPlot:GetY();
							local plotDistance = Map.PlotDistance(thisX, thisY, plotX, plotY);
							if plotDistance <= iRange then
								local hexID = ToHexFromGrid( Vector2( plotX, plotY) );
								if thingThatCanActuallyFire:CanRangeStrikeAt(plotX,plotY) then
									Events.SerialEventHexHighlight( hexID, true, highlightColor, "FireRangeBorder" );
									Events.SerialEventHexHighlight( hexID, true, redColor, "ValidFireTargetBorder");
								else
									Events.SerialEventHexHighlight( hexID, true, highlightColor, "FireRangeBorder" );
								end
							end
						end
					end
				end
			end
		end
	end
end

function AirStrikeHighlight()
	local pHeadSelectedUnit = UI.GetHeadSelectedUnit();
	local thingThatCanActuallyFire = nil;
	
	local iRange;
	local bIndirectFireAllowed;
	local thisPlot;
	local thisX;
	local thisY;
	local thisTeam;
	
	if pHeadSelectedUnit and pHeadSelectedUnit:CanRangeStrike() then
		iRange = pHeadSelectedUnit:Range();
		thisPlot = pHeadSelectedUnit:GetPlot();
		thisX = pHeadSelectedUnit:GetX();
		thisY = pHeadSelectedUnit:GetY();
		thisTeam = pHeadSelectedUnit:GetTeam();
		thingThatCanActuallyFire = pHeadSelectedUnit;
	end
	if thingThatCanActuallyFire ~= nil then
		local NO_DIRECTION = -1;
		for iDX = -iRange, iRange, 1 do
			for iDY = -iRange, iRange, 1 do
				local pTargetPlot = Map.GetPlotXY(thisX, thisY, iDX, iDY);
				if pTargetPlot ~= nil then
					local plotX = pTargetPlot:GetX();
					local plotY = pTargetPlot:GetY();
					local plotDistance = Map.PlotDistance(thisX, thisY, plotX, plotY);
					if plotDistance <= iRange then
						local hexID = ToHexFromGrid( Vector2( plotX, plotY) );
						if thingThatCanActuallyFire:CanRangeStrikeAt(plotX,plotY) then
							Events.SerialEventHexHighlight( hexID, true, highlightColor, "FireRangeBorder" );
							Events.SerialEventHexHighlight( hexID, true, redColor, "ValidFireTargetBorder");
						else
							Events.SerialEventHexHighlight( hexID, true, highlightColor, "FireRangeBorder" );
						end
					end
				end
			end
		end
	end
end



function NukeStrikeHighlight()
	local pHeadSelectedUnit = UI.GetHeadSelectedUnit();
	local thingThatCanActuallyFire = nil;
	
	local iRange;
	local thisPlot;
	local thisX;
	local thisY;
	local thisTeam;
	
	if pHeadSelectedUnit and pHeadSelectedUnit:CanNuke() then
		iRange = pHeadSelectedUnit:Range();
		thisPlot = pHeadSelectedUnit:GetPlot();
		thisX = pHeadSelectedUnit:GetX();
		thisY = pHeadSelectedUnit:GetY();
		thisTeam = pHeadSelectedUnit:GetTeam();
		thingThatCanActuallyFire = pHeadSelectedUnit;
	end
	if thingThatCanActuallyFire ~= nil then
		local NO_DIRECTION = -1;
		for iDX = -iRange, iRange, 1 do
			for iDY = -iRange, iRange, 1 do
				local pTargetPlot = Map.GetPlotXY(thisX, thisY, iDX, iDY);
				if pTargetPlot ~= nil then
					local plotX = pTargetPlot:GetX();
					local plotY = pTargetPlot:GetY();
					local plotDistance = Map.PlotDistance(thisX, thisY, plotX, plotY);
					if plotDistance <= iRange then
						local hexID = ToHexFromGrid( Vector2( plotX, plotY) );
						if thingThatCanActuallyFire:CanNukeAt(plotX,plotY) then
							Events.SerialEventHexHighlight( hexID, true, highlightColor, "FireRangeBorder" );
						end
					end
				end
			end
		end
	end
end


function DisplayBombardArrow( hexX, hexY )
	local unit = UI.GetHeadSelectedUnit();
	local city = UI.GetHeadSelectedCity();
	local attacker;
	if city and city:CanRangeStrike() then
		attacker = city;
	elseif unit and unit:CanRangeStrike() then
		attacker = unit
	end
	
	if attacker == nil then
		return
	end
	
	if attacker:CanRangeStrikeAt( hexX, hexY ) then
		Events.SpawnArrowEvent( attacker:GetX(), attacker:GetY(), hexX, hexY );
	else
		Events.RemoveAllArrowsEvent();
	end
	
end


function DisplayNukeArrow( hexX, hexY )
	local unit = UI.GetHeadSelectedUnit();
	local attacker;
	if unit and unit:CanNuke() then
		attacker = unit
	end
	
	if attacker == nil then
		return
	end
	
	if attacker:CanNukeAt( hexX, hexY ) then
		Events.SpawnArrowEvent( attacker:GetX(), attacker:GetY(), hexX, hexY );
	else
		Events.RemoveAllArrowsEvent();
	end
	
end


function BeginRangedAttack()
	local pHeadSelectedCity = UI.GetHeadSelectedCity();
	local pHeadSelectedUnit = UI.GetHeadSelectedUnit();
	
	-- Validate the Interface Mode
	local interfaceMode = UI.GetInterfaceMode();
	if (interfaceMode == InterfaceModeTypes.INTERFACEMODE_CITY_RANGE_ATTACK) then
		if (pHeadSelectedCity == nil) then
			UI.SetInterfaceMode(InterfaceModeTypes.INTERFACEMODE_SELECTION);
			return;
		else
			ms_CityBombardPlayer = pHeadSelectedCity:GetOwner();
			ms_CityBombardID = pHeadSelectedCity:GetID();
		end
	end

	if (interfaceMode == InterfaceModeTypes.INTERFACEMODE_RANGE_ATTACK) then
		if (pHeadSelectedUnit == nil) then
			UI.SetInterfaceMode(InterfaceModeTypes.INTERFACEMODE_SELECTION);
			return;
		end
	end
	
	if (pHeadSelectedCity and pHeadSelectedCity:CanRangeStrike()) or (pHeadSelectedUnit and pHeadSelectedUnit:CanRangeStrike()) then
		Events.SerialEventMouseOverHex.Add( DisplayBombardArrow );
		RangedStrikeHighlight();
	end

end

function OnCityInfoDirty()
	local interfaceMode = UI.GetInterfaceMode();
	if (interfaceMode == InterfaceModeTypes.INTERFACEMODE_CITY_RANGE_ATTACK) then
		local pHeadSelectedCity = UI.GetHeadSelectedCity();
		if (pHeadSelectedCity == nil) then
			UI.SetInterfaceMode(InterfaceModeTypes.INTERFACEMODE_SELECTION);
			return;
		end
		if (pHeadSelectedCity:GetOwner() ~= ms_CityBombardPlayer or pHeadSelectedCity:GetID() ~= ms_CityBombardID) then
			UI.SetInterfaceMode(InterfaceModeTypes.INTERFACEMODE_SELECTION);
		end
	end
end
Events.SerialEventCityInfoDirty.Add(OnCityInfoDirty);

function EndRangedAttack()
	Events.RemoveAllArrowsEvent();
	Events.SerialEventMouseOverHex.Remove( DisplayBombardArrow );
	ClearUnitHexHighlights();
end

function BeginAirAttack()
	local pHeadSelectedUnit = UI.GetHeadSelectedUnit();
	
	if (pHeadSelectedUnit and pHeadSelectedUnit:CanRangeStrike()) then
		Events.SerialEventMouseOverHex.Add( DisplayBombardArrow );
		AirStrikeHighlight();
	end

end

function AirRangeHighlight()
	local pSelUnit = UI.GetHeadSelectedUnit()
	local selUnitPlot = pSelUnit:GetPlot()
	local selX = selUnitPlot:GetX()
	local selY = selUnitPlot:GetY()
	local range = pSelUnit:Range()
	for x = -range,range do
		for y = -range,range do
			local tPlot = Map.GetPlotXY(selX,selY,x,y)
			if tPlot ~= nil then
				local tX = tPlot:GetX()
				local tY = tPlot:GetY()
				local tdist = Map.PlotDistance(selX,selY,tX,tY)
				if tdist <= range then
					local hex = ToHexFromGrid(Vector2(tX,tY))
					Events.SerialEventHexHighlight(hex,true,Vector4(0.7,0.7,0,1),"MovementRangeBorder")
				end
			end
		end
	end
end

function EndAirAttack()
	Events.RemoveAllArrowsEvent();
	Events.SerialEventMouseOverHex.Remove( DisplayBombardArrow );
	ClearUnitHexHighlights();
end

function BeginNukeAttack()
	local pHeadSelectedUnit = UI.GetHeadSelectedUnit();
	print("pHeadSelectedUnit:"..tostring(pHeadSelectedUnit))
	if (pHeadSelectedUnit and pHeadSelectedUnit:CanNuke()) then
		Events.SerialEventMouseOverHex.Add( DisplayNukeArrow );
		NukeStrikeHighlight();
	end

end

function EndNukeAttack()
	Events.RemoveAllArrowsEvent();
	Events.SerialEventMouseOverHex.Remove( DisplayNukeArrow );
	ClearUnitHexHighlights();
end
