
local dprint = function() end

function SetWidth(control, iWidth)
  local size = control:GetSize()
  size.x = iWidth
  control:SetSize(size)
end

function SetHeight(control, iHeight)
  local size = control:GetSize()
  size.y = iHeight
  control:SetSize(size)
end

function OffsetAgain(control)
  local offsetX, offsetY = control:GetOffsetVal()
  control:SetOffsetVal(offsetX+10, offsetY+10)
  control:SetOffsetVal(offsetX, offsetY)
end

local m_ButtonManager = nil
local iButtonIconSize = nil

function ButtonManagerInit(sInstanceName, rootControl, parentControl)
  dprint("ButtonManagerInit(%s)", sInstanceName)

  m_ButtonManager = InstanceManager:new(sInstanceName, rootControl, parentControl)

  local button = m_ButtonManager:GetInstance()
  local size = button.ButtonBox:GetSize()
  iButtonIconSize = button.Portrait:GetSizeX()

  ButtonManagerReset()

  return size.x, size.y
end

function ButtonManagerReset()
  dprint("ButtonManagerReset()")

  if (m_ButtonManager ~= nil) then
    m_ButtonManager:ResetInstances()
  end
end

function ButtonManagerGetButton(iX, iY, sToolTip, sAtlas, iAtlasIndex, sReqTech)
  local button = m_ButtonManager:GetInstance()
  button.Button:SetOffsetVal(iX, iY)
  button.Button:SetToolTipString(sToolTip)

  button.PortraitFrame:SetHide(IconHookup(iAtlasIndex, iButtonIconSize, sAtlas, button.Portrait) ~= true)

  if (sReqTech) then
    button.ReqTech:SetHide(false)
    button.ReqTech:SetToolTipString(Locale.ConvertTextKey(GameInfo.Technologies[sReqTech].Description))
  else
    button.ReqTech:SetHide(true)
  end

  return button
end

include("FLuaVector")

local m_PipeColours = {
  red   = Color(255,   0,   0, 255),
  green = Color(  0, 255,   0, 255),
  blue  = Color(  0,   0, 255, 255),
  white = Color(255, 255, 255, 255),
  black = Color(  0,   0,   0, 255),
  clear = Color(  0,   0,   0,   0),
}

local m_PipeSize = 32
local m_PipeSizes = {}
      m_PipeSizes[16] = {x=16, y=16}
      m_PipeSizes[24] = {x=24, y=24}
      m_PipeSizes[32] = {x=32, y=32}
      m_PipeSizes[42] = {x=32, y=42}
local m_PipeOffsets = {}
      m_PipeOffsets[16] = {h={x=0, y=3},  v={x=3, y=0},  tl={x=3, y=3},   tr={x=87, y=3},  bl={x=3, y=90},  br={x=87, y=90}}
      m_PipeOffsets[24] = {h={x=0, y=-1}, v={x=-1, y=0}, tl={x=-1, y=-1}, tr={x=83, y=-1}, bl={x=-1, y=86}, br={x=83, y=86}}
      m_PipeOffsets[32] = {h={x=0, y=-5}, v={x=-5, y=0}, tl={x=-5, y=-5}, tr={x=79, y=-5}, bl={x=-5, y=82}, br={x=79, y=82}}
      m_PipeOffsets[42] = {h={x=0, y=0},  v={x=0, y=0},  tl={x=0, y=0},   tr={x=72, y=0},  bl={x=0, y=72},  br={x=72, y=72}}

local m_PipeManager = nil

function PipeManagerInit(iSize, sInstanceName, rootControl, parentControl)
  dprint("PipeManagerInit(%d, %s)", iSize, sInstanceName)

  if (m_PipeOffsets[iSize] ~= nil) then
    m_PipeSize = iSize
  else
    m_PipeSize = 32
  end

  m_PipeManager = InstanceManager:new(sInstanceName, rootControl, parentControl)
end

function PipeManagerReset()
  dprint("PipeManagerReset()")

  if (m_PipeManager ~= nil) then
    m_PipeManager:ResetInstances()
  end
end

function PipeManagerGetPipe(iX, iY, colour)
  local pipe = m_PipeManager:GetInstance()
  pipe.PipeBox:SetOffsetVal(iX, iY)

  if (type(colour) == "string") then
    colour = m_PipeColours[colour]
  end

  if (type(colour) == "table") then
	pipe.PipeBox:SetColor(colour)
  else
	pipe.PipeBox:SetColor(Color(0,0,0,0))
  end

  return pipe
end

function PipeManagerDrawHorizontalPipe(iX, iY, iLength, colour)
  dprint("  draw horizontal pipe at (%i, %i) of length %i", iX, iY, iLength)
  if (iLength > 0) then
    local pipe = PipeManagerGetPipe(iX, iY, colour)
    pipe.PipeBox:SetSize({x=iLength, y=m_PipeSizes[m_PipeSize].y})
    pipe.PipeIcon:SetSize({x=iLength, y=32})

	pipe.PipeIcon:SetTexture("TechBranchH.dds")
	pipe.PipeIcon:SetTextureOffset(m_PipeOffsets[m_PipeSize].h)
  end
end

function PipeManagerDrawVerticalPipe(iX, iY, iHeight, colour)
  dprint("  draw vertical pipe at (%i, %i) of height %i", iX, iY, iHeight)
  if (iHeight > 0) then
    local pipe = PipeManagerGetPipe(iX, iY, colour)
    pipe.PipeBox:SetSize({x=m_PipeSizes[m_PipeSize].x, y=iHeight})
    pipe.PipeIcon:SetSize({x=32, y=iHeight})

	pipe.PipeIcon:SetTexture("TechBranchV.dds")
	pipe.PipeIcon:SetTextureOffset(m_PipeOffsets[m_PipeSize].v)
  end
end

function PipeManagerDrawQuadrantPipe(iX, iY, sType, colour)
  dprint("  draw %s quadrant pipe at (%i, %i)", sType, iX, iY)
  local pipe = PipeManagerGetPipe(iX, iY, colour)
  pipe.PipeBox:SetSize(m_PipeSizes[m_PipeSize])
  pipe.PipeIcon:SetSize({x=32, y=32})

  pipe.PipeIcon:SetTexture("TechBranches.dds")

  if (sType == 'top-right') then
    pipe.PipeIcon:SetTextureOffset(m_PipeOffsets[m_PipeSize].tr)
  elseif (sType == 'bottom-right') then
    pipe.PipeIcon:SetTextureOffset(m_PipeOffsets[m_PipeSize].br)
  elseif (sType == 'top-left') then
    pipe.PipeIcon:SetTextureOffset(m_PipeOffsets[m_PipeSize].tl)
  elseif (sType == 'bottom-left') then
    pipe.PipeIcon:SetTextureOffset(m_PipeOffsets[m_PipeSize].bl)
  end
end