modifier_plant = class({})

function modifier_plant:CheckState()
	local hPlant = self:GetParent()
	local state = {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_UNSELECTABLE] = not hPlant.harvest or hPlant.harvest <= 0,
	}
 
	return state
end


function modifier_plant:OnCreated()
	if IsServer() then
		local hPlant = self:GetParent()
		hPlant.plantTime = Time()
		self.tick = hPlant.plantTime
		hPlant.progress = 0
		self:StartIntervalThink(1)
	end
end


function modifier_plant:OnIntervalThink()
	if IsServer() then
		local hPlant = self:GetParent()
		local duration = 5
		local delta = Time() - self.tick
		self.tick = Time()
		local growthRate = self:GetSoilGrowthRate()
		hPlant.progress = hPlant.progress + (delta * growthRate) / duration
		if hPlant.progress >= 1 then
			hPlant:SetModel("models/corn_low_03_full.vmdl")
			hPlant.harvest = 3
			self:StartIntervalThink(-1)
		elseif hPlant.progress >= 0.75 then
			hPlant:SetModel("models/corn_low_02.vmdl")
		elseif hPlant.progress >= 0.5 then
			hPlant:SetModel("models/corn_low_01.vmdl")
		elseif hPlant.progress >= 0.25 then
			hPlant:SetModel("models/corn_low_00.vmdl")
		end
	end
end


function modifier_plant:DropHarvest(hOwner)
	local hPlant = self:GetParent()
	if hPlant.harvest <= 0 then return end
	for i=1, hPlant.harvest do
		print(hOwner)
		local hItem = CreateItem("item_harvest_corn", hOwner, hOwner)
		local hPhysItem = CreateItemOnPositionForLaunch(hPlant:GetAbsOrigin() + Vector(0, 0, RandomInt(64, 128)), hItem)
		hPhysItem:SetAngles(0, RandomInt(1, 360), 0)
		hItem:LaunchLoot(false, RandomInt(64, 128), 0.4, hPlant:GetAbsOrigin() + RandomVector(1):Normalized() * 64)
	end
	hPlant:SetModel("models/corn_low_03.vmdl")
	hPlant.harvest = 0
end


function modifier_plant:GetSoilGrowthRate()
	local hPlant = self:GetParent()
	local hSoil = hPlant.soil
	if hSoil == nil then return 0 end
	local hSoilModifier = hSoil:FindModifierByName("modifier_soil")
	if hSoilModifier == nil then return 0 end
	return hSoilModifier:GetGrowthRate()
end


function modifier_plant:GetProgress()
	return self:GetParent().progress
end