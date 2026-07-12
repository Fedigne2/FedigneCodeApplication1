local DiseaseRegistry = require(game.ReplicatedStorage.DiseaseSystem.Services.DiseaseRegistry)

local Disease = {}
Disease.__index = Disease


local ComponentsFolder = script.Components
local VisualComponent = require(ComponentsFolder.VisualComponent)
local InfectionComponent = require(ComponentsFolder.InfectionComponent)
local SymptomsComponent = require(ComponentsFolder.SymptomsComponent)
local BehaviorComponent = require(ComponentsFolder.BehaviorComponent)


function Disease.new(obj, data)
	
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
			oldDisease:Destroy()
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

function Disease:SpreadTo(obj)
	if not DiseaseRegistry:CanInfect(self.Data.Id) then
		return
	end

	local newDisease = Disease.new(obj, self.Data)

	return newDisease
end

function Disease:GetComponent(componentName)
	return self.Components[componentName]
end

function Disease:Destroy()
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


return Disease