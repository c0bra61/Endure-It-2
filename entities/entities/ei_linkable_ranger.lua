
AddCSLuaFile()

ENT.PrintName		= "Ranger"
ENT.Author			= "C0BRA"
ENT.Contact			= "c0bra@xiatek.org"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.RenderGroup 	= RENDERGROUP_OPAQUE
ENT.Base			= "ei_linkable_ent"

ENT.Model 			= "models/jaanus/wiretool/wiretool_range.mdl"
ENT.Thrust			= 0
ENT.Enabled 		= 0

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

function ENT:Initialize()
	self.BaseClass.Initialize(self)
end


function ENT:Draw()
	self.BaseClass.Draw( self )
end

function ENT:Think()
	self.BaseClass.Think( self )
end

function ENT:OnTakeDamage( dmginfo )
end

local DensityTbl = {}
DensityTbl[MAT_ANTLION] = 0.01
DensityTbl[MAT_BLOODYFLESH] = 0.01
DensityTbl[MAT_DIRT] = 1.51
DensityTbl[MAT_FLESH] = 0.01
DensityTbl[MAT_GRATE] = 8.6
DensityTbl[MAT_ALIENFLESH] = 0.01
DensityTbl[MAT_CLIP] = 8.6
DensityTbl[MAT_PLASTIC] = 0.8
DensityTbl[MAT_METAL] = 8.6
DensityTbl[MAT_SAND] = 2.65
DensityTbl[MAT_FOLIAGE] = 0.2
DensityTbl[MAT_COMPUTER] = 0.9
DensityTbl[MAT_SLOSH] = 0
DensityTbl[MAT_TILE] = 12.2
DensityTbl[MAT_VENT] = 8.6
DensityTbl[MAT_WOOD] = 0.63
DensityTbl[MAT_GLASS] =  4.35

function ENT:GetLinkTable()
	return {
		Query = function(chip, x, y)
			if not chip:GetJoules(4) then return 1000000 end
			
			x = x or 0
			y = y or 0
						
			local trace = {}
			trace.start = self:GetPos() + self:GetUp() * 2
			
			local ang = self:GetUp():Angle()
			
			ang:RotateAroundAxis(self:GetRight(), x / 1.325)
			ang:RotateAroundAxis(self:GetForward(), y / 1.325)
			
			trace.endpos = trace.start + ang:Forward() * 1000000
			
			trace.filter = { self }
			local tr = util.TraceLine(trace)
			
			if tr.HitSky then
				debugoverlay.Line(trace.start, tr.HitPos, 0.25)
				return 1000000
			end
			
			for k,v in pairs(ents.FindByClass("ei_linkable_geigercounter")) do
				local dist = v:GetPos():Distance(tr.HitPos)
				
				local rand = 0 //math.random(0, 10)
				
				if math.random(0, dist) < 250 then
					rand = 1
				end
				
				dist = v:GetPos():Distance(trace.start)
				
				rand = math.Clamp(rand, 0, 1)
				
				if rand != 0 and math.random(0, dist) > 5000 then
					rand = 0
				end
				
				v.Counts = v.Counts + rand
				
				if rand >= 1 then
					if rand <= 3 then
						v:EmitSound("player/geiger" .. rand .. ".wav")
					else
						v:EmitSound("player/geiger" .. math.random(1, 3) .. ".wav")
					end
				end
			end
			
			debugoverlay.Line(trace.start, tr.HitPos, 0.25)
			
			local density = DensityTbl[tr.MatType]
			
			return (trace.start - tr.HitPos):Length(), density
		end
	}
end