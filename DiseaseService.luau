-- Roblox: fedigne_2
-- Discord: fedigne

local DiseaseClass = require(game.ReplicatedStorage.DiseaseSystem.Classes.Disease)
local InfectionLoop = require(game.ReplicatedStorage.DiseaseSystem.Services.InfectionLoop)
local DiseaseRegistry = require(game.ReplicatedStorage.DiseaseSystem.Services.DiseaseRegistry)

-- singleton
local DiseaseService = {}

local function GetDefaultData()

	local data = {

		Id = "Disease",
		
		Power = 1, -- dominance over other diseases
		Duration = nil, -- only for players
		
		Visual = {
			Enabled = true,
			Color = BrickColor.new("Really red"),
			Material = nil,
			
			-- for the billboard
			BillChance = 0.1,
			BillSize = UDim2.fromScale(8,8),
			BillOver = 3,
			BillImage = nil,
			
			-- particles
			ParticleEmitterEnabled = false,
			ParticleEmitterData = {},
			
			-- plr
			IllFace = nil,
		},

		Propagation = {
			Type = "None",
			Distance = 0,
			Cooldown = {2,5}, -- from 2 to 5 sec
			Chance = 1, -- probability the infection activates(1 = sure, 0 = no propagation)
			PropagationDuration = 5,
			MaxInfected = math.huge,
		},

		Symptoms = {
			Damage = 0,
			Slow = 1, -- the speed will be multiplied by this number
			VisualImage = 176533208,
		},
		
		Behavior = {
			Destroy = {Enabled = false, Cooldown = {5,10}}, -- from 5 to 10 sec
		}
	}

	data.Visual.TorsoImage = data.Visual.Image


	return data
end

--** local functions

local function MergeData(default, custom)
	local result = {}

	for key, value in default do
		if type(value) == "table" then
			result[key] = MergeData(value, custom[key] or {})
		else
			if custom[key] ~= nil then
				result[key] = custom[key]
			else
				result[key] = value
			end
		end
	end

	for key, value in custom do
		if result[key] == nil then
			result[key] = value
		end
	end

	return result
end

--**

function DiseaseService.InitDisease(Obj, customData)
	
	-- start the centralized infection loop
	InfectionLoop:Start()
	
	local data = MergeData(GetDefaultData(), customData)
	
	-- registry the desease
	DiseaseRegistry:RegisterDiseaseType(
		data.Id,
		data.Propagation.MaxInfected
	)
	
	local disease = DiseaseClass.new(Obj, data)

	return disease
end

return DiseaseService




















--[[
	
	DATA STRUCTURE:
	
	Visual = {
		
		Enabled : boolean
			-- enable/disable all visual effects
		
		Color : BrickColor
			-- changes the color of BaseParts
		
		Material : Enum.Material
			-- changes the material of BaseParts
			-- Example: Enum.Material.Slime
		
		Transparency : number
			-- object transparency (0 - 1)
		
		Reflectance : number
			-- object reflectance (0 - 1)
		
		Image : number
			-- Decal/Texture id
			-- creates decals on object faces
		
		DecalFace : string
			-- "All" | "Front" | "Back" | "Top" | "Bottom" | "Left" | "Right"
			-- which faces receive the image
		
		Particle : {
			Enabled : boolean,
			Texture : number,
			Rate : number,
			Lifetime : NumberRange,
			Speed : NumberRange
		}
			-- optional particle effects
		
		Light : {
			Enabled : boolean,
			Color : Color3,
			Brightness : number,
			Range : number
		}
			-- optional light effect
	}



	Propagation = {
		
		Type : string
			-- "None" | "Touch" | "Air" | "Water" | ...
		
		Distance : number
			-- max propagation distance
		
		Cooldown : {number, number}
			-- random cooldown between values
			-- Example: {2,5} = random between 2 and 5 seconds
		
		Chance : number
			-- probability of infecting
			-- 0 - 1
		
		MaxInfections : number
			-- maximum number of objects infected
		
		Targets : {
			"Player",
			"Part"
		}
			-- what can be infected
	}



	Symptoms = {
		
		Damage : number
			-- damage per tick
		
		DamageCooldown : number
			-- time between damages
		
		Slow : number
			-- walkspeed reduction
		
		JumpPowerReduction : number
		
		Blur : number
			-- screen blur intensity
		
		Shake : number
			-- camera shake
		
		Duration : number
			-- symptom duration
		
		Death : boolean
			-- can kill player
		
	}



	EXAMPLE:

	{
		Visual = {
			Color = BrickColor.new("Black"),
			Material = Enum.Material.Slime,
			Image = 123456
		},

		Propagation = {
			Type = "Touch",
			Distance = 15,
			Cooldown = {2,5},
			Chance = 0.5
		},

		Symptoms = {
			Damage = 5,
			Slow = 4
		}
	}

]]