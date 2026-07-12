-- Roblox: fedigne_2
-- Discord: fedigne

local Players = game:GetService("Players")

local InfectionLoop = require(game.ReplicatedStorage.DiseaseSystem.Services.InfectionLoop)
local DiseaseRegistry = require(game.ReplicatedStorage.DiseaseSystem.Services.DiseaseRegistry)


--** local functions

local function CheckIsInAPlr(v)

	local model = v:FindFirstAncestorOfClass("Model")

	if model then
		return Players:GetPlayerFromCharacter(model)
	end

	return nil
end

local function SmartSpread(self, part)
	local target = CheckIsInAPlr(part) or part

	if not DiseaseRegistry:HasDisease(target, self.Disease.Data.Id) then
		self.Disease:SpreadTo(target)
	end
end

local function checkBox(self, obj, distance)
	local size = obj.Size + Vector3.new(distance*2,distance*2,distance*2)

	local parts = workspace:GetPartBoundsInBox(obj.CFrame, size)


	for _, part in ipairs(parts) do
		if part ~= obj then
			SmartSpread(self, part)
		end
	end
end

--


local InfectionComponent = {}
InfectionComponent.__index = InfectionComponent


function InfectionComponent.new(disease)

	local self = setmetatable({}, InfectionComponent)

	self.Disease = disease
	self.Running = false

	return self
end


function InfectionComponent:Start(force)
	if self.Running then
		return
	end

	local data = self.Disease.Data.Propagation

	if not force and math.random() > data.Chance then
		return
	end

	self.Running = true
	self.StartTime = os.clock()
	InfectionLoop:Add(self)
end

function InfectionComponent:Update()

	local obj = self.Disease.Obj
	local data = self.Disease.Data.Propagation


	-- check and stop if not infectous anymore
	if os.clock() - self.StartTime >= data.PropagationDuration then
		self:Stop()
		return
	end

	-- only base parts can infect
	if not obj:IsA("BasePart") then
		return
	end


	if data.Type == "Touch" then
		checkBox(self, obj, 0.5) -- simulate the touch with a little distance
	elseif data.Type == "Air" then
		checkBox(self, obj, data.Distance)
	end
end

function InfectionComponent:Stop()
	self.Running = false
end

function InfectionComponent:Destroy()
	self:Stop()
	self.Disease = nil
end



return InfectionComponent