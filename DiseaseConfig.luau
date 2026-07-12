-- Roblox: fedigne_2
-- Discord: fedigne

-- this module is the disease configuration. The disease tables will be merged with the default table in order to make an utent-friendly service

-- here are just mentioned the properties to change by the default disease table (for each disease)

local Diseases = {
	["Black Plague"] = {

		Id = "Black Plague",
		
		Power = 1.5,
		
		Visual = {
			Color = BrickColor.new("Black"),
		},

		Propagation = {
			Type = "Air",
			Distance = 1,
			Cooldown = {1,5},
			MaxInfected = 10000,
			PropagationDuration = 5,
		},

		Symptoms = {
			Damage = 20,
			Slow = .5,
			Image = 524781417,
		}
	},


	["67"] = {

		Id = "67",
		
		Power = 1,
		
		Duration = 5,

		Visual = {
			Color = BrickColor.new("Electric blue"),
			
			BillImage = 110444066627259,
			BillOver = 10,
			BillSize = UDim2.fromScale(25,25),
			BillChance = 0.04,	
		},

		Propagation = {
			Type = "Air",
			Distance = 5,
			Chance = 0.8,
			Cooldown = {1,4},
			PropagationDuration = 4,
		},
	},
	
	["Fire"] = {
		Id = "Fire",
		Power = 1.3,
		
		Visual = {
			Color = BrickColor.new("Neon orange"),
			--Material = Enum.Material.SmoothPlastic,
			
			ParticleEmitterEnabled = true,
			ParticleEmitterData = {
				--Texture = "rbxassetid://241594314", -- doesnt work the texture, choose aother
				Color = ColorSequence.new(
					Color3.fromRGB(255, 170, 0),
					Color3.fromRGB(255, 50, 0)
				),

				Rate = 40,
				Lifetime = NumberRange.new(0.5, 1),
				Speed = NumberRange.new(5, 10),
				Size = NumberSequence.new(1),
				LightEmission = 0.5,
				SpreadAngle = Vector2.new(20,20)
			},
		},
		
		Propagation = {
			Type = "Air",
			Distance = 2,
			Chance = 0.8,
			Cooldown = {5,10},
			PropagationDuration = 15,
		},
		
		Symptoms = {
			VisualImage = 18236334126,
		},
		
		Behavior = {
			Destroy = {Enabled = true, Cooldown = {7,10}},
		}
	}
	
}

return Diseases
