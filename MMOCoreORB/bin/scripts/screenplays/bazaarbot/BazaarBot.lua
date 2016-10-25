-- Tarkin AuctionBot
-- A simple way to populate the bazaar with goods
-- Created by R. Bassett Jr. (www.tpot.ca) 2016
--
-- New C++ Lua calls in Director Manager:
-- bazaarBotMakeCraftedItem(): Generates a crafted item or crate and places it into BazaarBot's inventory, returning the object pointer
--  bazaarBotMakeCraftedItem(pBazaarBot, string draftSchematicScript, quantity, quality, AlternateTemplateNumber)
-- bazaarBotMakeLootItem(): Generates a looted item and places it into BazaarBot's inventory, returning the object pointer
--  bazaarBotMakeLootItem(pBazaarBot, string lootGroup, int level, bool maxCondition)
-- bazaarBotMakeResourceStack(): Generates a stack of resources and places it into BazaarBot's inventory, returning the object pointer
--
-- bazaarBotListItem(): Sells the item provided on the desired bazaar
--  bazaarBotListItem(pBazaarBot, itemObjectID, pBazzarTerminal, string description, int price, int duration in seconds, bool auction, bool premium)

includeFile("bazaarbot/table_resources.lua")
includeFile("bazaarbot/table_armor.lua")
includeFile("bazaarbot/table_medicine.lua")
includeFile("bazaarbot/table_food.lua")
includeFile("bazaarbot/table_weapons.lua")
includeFile("bazaarbot/table_item_artisan.lua")

BazaarBot = ScreenPlay:new {
	numberOfActs = 1,
	BazaarBotID = 281474993877563, -- Make a character named BazaarBot and put its PlayerID number here (/getPlayerID BazaarBot).
	terminalID = 3945376, -- Mos Entha, Tatooine
	itemDescription = "Brought to you by Bazaarbot!", -- Optional message in the description window.
	-- Resource Config
	resListingsInit = 100, -- number of listings to start a new server with: resListingsInit * resPerGen
	resGenFreq = 25, -- how often to generate a listing, minutes + random seconds upto 5 minutes
	resPerGen = 2, -- how many resource types per listing
	resStackSizes = {1000, 5000, 10000},
	resStacks = 2, -- how many stacks to list per stack size
	creditsPerUnit = 3, -- Price of resource is stack size * credits per unit
}

registerScreenPlay("BazaarBot", true)

function BazaarBot:start()
	-- Testing trigger object
	local pTerminal = spawnSceneObject("tatooine", "object/tangible/furniture/decorative/foodcart.iff" , 1591, 7, 3031, 0, 0, 0, 0, 0)
	if (pTerminal ~= nil) then
		-- Add menu and custom name
		SceneObject(pTerminal):setObjectMenuComponent("ABTestMenuComponent")
		SceneObject(pTerminal):setCustomObjectName("BazaarBot Trigger")
	end
	
	-- Populate a new server's bazaar 
	local init = getQuestStatus("BazaarBot:Initialized")
	if (init == nil) then
		createServerEvent(120*1000, "BazaarBot", "initializeResources", "BazaarBotInitResources")
	end
	
	-- Schedule the lister events for after server has fully booted
	createServerEvent(240*1000, "BazaarBot", "startEvents", "BazaarBotStartEvents")
end

function BazaarBot:startEvents()
	self:addMoreResources()
	self:addMoreArmor()
	self:addMoreMedicine()
	self:addMoreFood()
	self:addMoreWeapons()
end


function BazaarBot:test(pPlayer, pObject)
	BazaarBot:addMoreArtisanItems()
	CreatureObject(pPlayer):sendSystemMessage("Test Complete!")
end


-- Resource Functions

function BazaarBot:initializeResources()
	printf("BazaarBot: Populating bazaar with resources for the first time...\n")
	for i = 1, self.resListingsInit do
		self:listResources()
	end
	setQuestStatus("BazaarBot:Initialized", 1)
	printf("BazaarBot: Initialized " .. tostring(self.resListingsInit * self.resPerGen * #self.resStackSizes * self.resStacks) .. " bazaar listings in " .. tostring(self.resListingsInit * self.resPerGen) .. " random resource selection cycles.\n")
end

function BazaarBot:addMoreResources()
	self:listResources()
	
	local nextTime = self.resGenFreq * 60*1000 + getRandomNumber(1,300000)
	
	if (hasServerEvent("BazaarBotAddResources")) then
		rescheduleServerEvent("BazaarBotAddResources", nextTime)
	else
		createServerEvent(nextTime, "BazaarBot", "addMoreResources", "BazaarBotAddResources")
	end
end

function BazaarBot:pickResource()
	local resourceName = nil
	
	while (resourceName == nil) do
		-- Pick a family
		local famGroup = getRandomNumber(1,#BBResFamWeighted)
		local family = getRandomNumber(1,#BBResFamWeighted[famGroup])
		local familyName = BBResFamWeighted[famGroup][family]
		
		-- Pick a specific resource that is in spawn
		local rand = getRandomNumber(1,#BBResCats[familyName])
		local resourceCategory = BBResCats[familyName][rand]
		resourceName = getRandomInSpawnResource(resourceCategory)
	end
	
	return resourceName
end

function BazaarBot:listResources()
	local pVendor = getSceneObject(self.terminalID)
	local pBazaarBot = getCreatureObject(self.BazaarBotID)
	
	for i = 1, self.resPerGen do -- x number of resources
		local resourceName = self:pickResource()
		
		for j = 1, #self.resStackSizes do -- x number of stack sizes
			for k = 1, self.resStacks do -- x number of stacks
				local pItem = bazaarBotMakeResources(pBazaarBot, resourceName, self.resStackSizes[j])
				local itemForSaleObjectID = SceneObject(pItem):getObjectID()
				local price = self.resStackSizes[j] * self.creditsPerUnit
				
				bazaarBotListItem(pBazaarBot, itemForSaleObjectID, pVendor, self.itemDescription, price)
			end
		end
	end
	
	printf("BazaarBot: Listed " .. tostring(self.resPerGen) .. " more resources.\n")
end


-- Crafted Item Functions

function BazaarBot:addMoreArmor()
	self:addMoreCraftedItems(BBArmorConfig, BBArmorItems)
end

function BazaarBot:addMoreMedicine()
	self:addMoreCraftedItems(BBMedicineConfig, BBMedicineItems)
end

function BazaarBot:addMoreFood()
	self:addMoreCraftedItems(BBFoodConfig, BBMFoodItems)
end

function BazaarBot:addMoreWeapons()
	self:addMoreCraftedItems(BBWeaponsConfig, BBWeaponsItems)
end

function BazaarBot:addMoreArtisanItems()
	self:addMoreCraftedItems(BBArtisanConfig, BBArtisanItems)
end

function BazaarBot:addMoreCraftedItems(configTable, itemTable)
	self:listCraftedItems(configTable, itemTable)
	
	local nextTime = configTable.freq * 1000 + getRandomNumber(1,300000)
	
	if (hasServerEvent(configTable.eventName)) then
		rescheduleServerEvent(configTable.eventName, nextTime)
	else
		createServerEvent(nextTime, "BazaarBot", configTable.functionName, configTable.eventName)
	end
end

function BazaarBot:listCraftedItems(configTable, itemTable)
	local pVendor = getSceneObject(self.terminalID)
	local pBazaarBot = getCreatureObject(self.BazaarBotID)
	
	 
	for j = 1, #itemTable do
		for i = 1, itemTable[j][2] do -- quantity
			for k = 5, #itemTable[j] do -- items in each group/index
				local template = configTable.path .. itemTable[j][k] .. ".iff"
				local altTemplate = itemTable[j][4]
				local crateQuantity = itemTable[j][3]
			
				-- Determine item quality
				local excellent = getRandomNumber(1, 100)
				local minQuality = configTable.qualityMin
				local maxQuality = configTable.qualityAvg
				
				if (excellent > 89) then
					minQuality = configTable.qualityAvg
					maxQuality = configTable.qualityMax
				elseif (excellent > 99) then
					minQuality = configTable.qualityMax + 1
					maxQuality = configTable.qualityMax + 5
				end
			
				local quality = getRandomNumber(minQuality,maxQuality)
				local price = itemTable[j][1] * ((quality/200) + 1) * crateQuantity
				
				local pItem = bazaarBotMakeCraftedItem(pBazaarBot, template, crateQuantity, quality, altTemplate)
				
				if not (pItem == nil) then
					bazaarBotListItem(pBazaarBot, pItem, pVendor, self.itemDescription, price)
				else
					printf("BazaarBot: Error creating  " .. template .. "\n")
				end
			end
		end
	end
end



function BazaarBot:testLootItem(pPlayer, pObject)
	local pVendor = getSceneObject(3945376)
	local description = "This item is for sale!"
	local price = 250
	local pBazaarBot = getCreatureObject(281474993877563)
	
	local pItem = bazaarBotMakeLootItem(pBazaarBot, "weapons_all", 35, false)
	local itemForSaleObjectID = SceneObject(pItem):getObjectID()
	
	bazaarBotListItem(pBazaarBot, itemForSaleObjectID, pVendor, description, price)
	
	CreatureObject(pPlayer):sendSystemMessage("Test Complete!")
end


function BazaarBot:testCraftedItem(pPlayer, pObject)
	local pVendor = getSceneObject(3945376)
	local description = "This item is for sale!"
	local price = 25000
	local pBazaarBot = getCreatureObject(281474993877563)
	
	local pItem = bazaarBotMakeCraftedItem(pPlayer, "object/draft_schematic/clothing/clothing_backpack_field_01.iff", 1, 75, 0)
	local itemForSaleObjectID = SceneObject(pItem):getObjectID()
	
	bazaarBotListItem(pBazaarBot, itemForSaleObjectID, pVendor, description, price)
	
	CreatureObject(pPlayer):sendSystemMessage("Test Complete!")
end

-- Testing Trigger

ABTestMenuComponent = { }

function ABTestMenuComponent:fillObjectMenuResponse(pSceneObject, pMenuResponse, pPlayer)
	local menuResponse = LuaObjectMenuResponse(pMenuResponse)
	menuResponse:addRadialMenuItem(20, 3, "Run Test")
end

function ABTestMenuComponent:handleObjectMenuSelect(pObject, pPlayer, selectedID)
	if (pPlayer == nil or pObject == nil) then
		return 0
	end
	
	if CreatureObject(pPlayer):isInCombat() then
		CreatureObject(pPlayer):sendSystemMessage("Terminal services are not available while you are in combat.")
		return 0
	end
	
	if (selectedID == 20) then
		BazaarBot:test(pPlayer, pObject)
	end 
	
	return 0
end

function ABTestMenuComponent:noCallback(pPlayer, pSui, eventIndex)
	-- do nothing
end
