-- Roblox: fedigne_2
-- Discord: fedigne

local InfectionLoop = require(game.ReplicatedStorage.DiseaseSystem.Services.InfectionLoop)
local DiseaseRegistry = require(game.ReplicatedStorage.DiseaseSystem.Services.DiseaseRegistry)

-- class
local DiseaseClass = {}
DiseaseClass.__index = DiseaseClass


local ComponentsFolder = script.Components
local VisualComponent = require(ComponentsFolder.VisualComponent)
local InfectionComponent = require(ComponentsFolder.InfectionComponent)
local SymptomsComponent = require(ComponentsFolder.SymptomsComponent)
local BehaviorComponent = require(ComponentsFolder.BehaviorComponent)


function DiseaseClass.new(obj, data)
	
	---------- CHECKS
	-- is a infectious obj
	if obj:GetAttribute("CanBeInfected") ~= true then
		return
	end
	
	-- check the priority of the disease TODO for now just see if is the same
	
	local diseases = DiseaseRegistry:GetDiseases(obj)
	
	-- don't do anything if has already a disease (DEPRECATED)
	--if diseases and #diseases == 1 then return diseases[1] end]]
	
	-- to handle more diseases (Powers)
	
	if diseases then
		for _, disease in ipairs(diseases) do
			if disease.Data.Id == data.Id then
				if disease.Components.Infection and not disease.Components.Infection.Running then
					disease.Components.Infection:Start(true)
				end

				return disease
			end
		end
		
		-- power war
		local oldDisease = diseases[1]

		local attack = data.Power
		local defense = oldDisease.Data.Power
		local chance = attack / (attack + defense * 5) -- formula
		if math.random() < chance then
			oldDiseaseClass:Destroy()
		else
			return oldDisease
		end
	end
	
	------------
	
	
	
	local self = setmetatable({}, Disease)

	self.Obj = obj
	self.Data = data

	self.Components = {}

	-- save th reference to the part
	DiseaseRegistry:AddDisease(obj, self)
	
	-- visual
	if data.Visual then
		self.Components.Visual = VisualComponent.new(self)
		-- apply automatically handled in the module
	end

	-- infection
	if data.Propagation.Type ~= "None" then
		self.Components.Infection = InfectionComponent.new(self)
		self.Components.Infection:Start()
	end

	-- symptoms
	if data.Symptoms then
		self.Components.Symptoms = SymptomsComponent.new(self)
		-- apply automatically handled in the module
	end
	
	-- behavior
	
	if data.Behavior then
		self.Components.Behavior = BehaviorComponent.new(self)
		-- apply automatically handled in the module
	end
	
	-- plr recovery
	if self.Data.Duration and obj:IsA("Player") then
		task.delay(self.Data.Duration, function()
			self:Destroy()
		end)
	end
	
	return self
end

function DiseaseClass:SpreadTo(obj)
	if not DiseaseRegistry:CanInfect(self.Data.Id) then
		return
	end

	local newDisease = Disease.new(obj, self.Data)

	return newDisease
end

function DiseaseClass:GetComponent(componentName)
	return self.Components[componentName]
end

function DiseaseClass:Destroy()
	DiseaseRegistry:RemoveDisease(self.Obj, self)
	
	if not self.Components then return end
	
	for _,component in self.Components do
		if component.Destroy then
			component:Destroy()
		end
	end

	self.Components = nil
	self.Obj = nil
end





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
