TOOL.Category   = "Construction"      -- Name of the category
TOOL.Name       = "#Surface Friction" -- Name to display
TOOL.Command    = nil                 -- Command on click (nil for default)
TOOL.ConfigName = ""                  -- Config file name (nil for default)

TOOL.ClientConVar =
{ 
  [ "multy" ] = "1", -- Default Surface friction multiplyer
  [ "advic" ] = "1"  -- Advisor
}

if CLIENT then
  language.Add( "Tool.surfacefriction.name", "Surface Friction Multiplyer" )
  language.Add( "Tool.surfacefriction.desc", "Multiplyes the surface friction of a prop by a given amount" )
  language.Add( "Tool.surfacefriction.0"   , "Left Click apply, Right to copy, Reload to turn it back to normal" )
  language.Add( "Undone.surfacefriction"   , "Undone Surface Friction" )
  language.Add( "Cleanup.surfacefriction"  , "Surface Friction" )
  language.Add( "Cleaned.surfacefriction"  , "Cleaned up Surface Friction" )
end

if SERVER then
  cleanup.Register("SurfaceFrictionMultyplyerTool")
end

function isPropTr(oTrace)
  if(!oTrace) then return false end
  if(oTrace.Entity   and
    !oTrace.HitWorld and
     oTrace.Entity:IsValid() and
     oTrace.Entity:GetPhysicsObject():IsValid() and
    !oTrace.Entity:IsPlayer()) then
    return true
  end
  return false
end



function SetSufaceFriction(oPly,oEnt,tData)
  if not SERVER then return end
  if(tData.FrictionMul) then
    oEnt:SetFriction(tData.FrictionMul)
    oEnt:PhysWake()
    duplicator.StoreEntityModifier(oEnt,"surfacefriction_data",tData)
  end
end
duplicator.RegisterEntityModifier("surfacefriction_data", SetSufaceFriction)

function TOOL:LeftClick( oTrace )
  if CLIENT then return true end
  if(!isPropTr(oTrace)) then return false end
  local nMulty = tonumber(self:GetClientInfo("multy")) or 0
        nMulty = math.Clamp(nMulty,-1000,1000)
  local oPly   = self:GetOwner() 
  SetSufaceFriction(oPly,oTrace.Entity,{ FrictionMul = nMulty })
  return true
end

function TOOL:RightClick( tTrace )
  if CLIENT  then return true end
  if(!isPropTr(tTrace)) then return false end
  local nMulty = tTrace.Entity:GetFriction()
  local oPly   = self:GetOwner()
  oPly:ConCommand("surfacefriction_multy "..nMulty);
  return true
end

function TOOL:Reload(tTrace)
  if(isPropTr(tTrace)) then
    local oPly = self:GetOwner()
    SetSufaceFriction(Ply,tTrace.Entity,{FrictionMul = 1})
    return true
  end
end


function TOOL:Think()
  local tTrace = self:GetOwner():GetEyeTrace()
  if(tTrace) then
    local oEnt = tTrace.Entity
    if(oEnt and oEnt:IsValid() and SERVER) then
      oEnt:SetNWFloat("surffric_nw_fric",oEnt:GetFriction())
    end
  end
  
end

function TOOL:DrawHUD()
  local nAdv = tonumber(self:GetClientInfo("advic")) or 0
  local tTrace = self:GetOwner():GetEyeTrace()
  if(tTrace and CLIENT) then
  local oEnt = tTrace.Entity
    if((nAdv > 0) and oEnt and oEnt:IsValid()) then
      local nMultyEnt = oEnt:GetNWFloat("surffric_nw_fric")
            nMultyEnt = math.Clamp(nMultyEnt,-1000,1000)
      local nMultyClt = tonumber(self:GetClientInfo("multy"))
            nMultyClt = math.Clamp(nMultyClt,-1000,1000)
      local nX = surface.ScreenWidth()/2
      local nY = surface.ScreenHeight()/2
      if(nMultyEnt ~= 1) then
        surface.DrawCircle(nX,nY,30,Color(112-nMultyEnt*0.112,112+nMultyEnt*0.112,0,255))
        surface.DrawCircle(nX,nY,25,Color(112-nMultyClt*0.112,112+nMultyClt*0.112,0,255))
      else
        surface.DrawCircle(nX,nY,30,Color(0,0,255,255))
        surface.DrawCircle(nX,nY,25,Color(112-nMultyClt*0.112,112+nMultyClt*0.112,0,255))
      end
    end
  end
end

function TOOL.BuildCPanel( CPanel )
  Header = CPanel:AddControl( "Header", { Text = "#Tool.surfacefriction.name", Description  = "#Tool.surfacefriction.desc" }  )
  
  CPanel:AddControl("Slider", { 
            Label  = "Friction factor: ",
            Type  = "float",
            Min    = -1000,
            Max    =  1000,
            Command = "surfacefriction_multy"})
             
  CPanel:AddControl("Checkbox", {
            Label = "Enable Advisor",
            Command = "surfacefriction_advic"})      
end
