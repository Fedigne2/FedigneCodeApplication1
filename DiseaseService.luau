-- Roblox: fedigne_2
-- Discord: fedigne

-- this is the main module of my diseasse system

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

-- merge the default tabl and the customized one by the utent (Script in serverscriptservice)
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
