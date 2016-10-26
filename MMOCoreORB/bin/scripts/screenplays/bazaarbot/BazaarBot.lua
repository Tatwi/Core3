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
includeFile("bazaarbot/table_structures.lua")
includeFile("bazaarbot/table_loot.lua")

BazaarBot = ScreenPlay:new {
	numberOfActs = 1,
	BazaarBotID = 281474993877563, -- Make a character named BazaarBot and put its PlayerID number here (/getPlayerID BazaarBot).
	terminalID = 3945376, -- Mos Entha, Tatooine
	itemDescription = "", -- Optional message in the description window.
	ListingsInit = 30, -- On first boot after this system is installed, the server will loop this many times through the add functions
	-- Resource Config
	
	resGenFreq = 25, -- how often to generate a listing, minutes + random seconds upto 5 minutes
	resPerGen = 2, -- how many resource types per listing
	resStackSizes = {1000, 5000, 10000},
	resStacks = 2, -- how many stacks to list per stack size
	creditsPerUnit = 3, -- Price of resource is stack size * credits per unit
}

registerScreenPlay("BazaarBot", true)

function BazaarBot:start()
	local pBazaarBot = getCreatureObject(self.BazaarBotID)
	
	if (pBazaarBot == nil) then
		printf("ERROR: BazaarBot character does not exist! Please create it on an ADMIN ACCOUNT and configure bin/screenplays/BazaarBot.lua to use the system.")
		return
	end

	-- Testing trigger object
	self:loadTestingObject()
	
	-- Populate a new server's bazaar 
	local init = getQuestStatus("BazaarBot:Initialized")
	if (init == nil) then
		createServerEvent(120*1000, "BazaarBot", "initializeListings", "BazaarBotInitializeListings")
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
	self:addMoreArtisanItems()
	self:addMoreStructures()
	self:addMoreLoot()
	printf("BazaarBot: All listing events have now started and will repeat on their own periodically.\n")
end

function BazaarBot:initializeListings()
	printf("BazaarBot: Populating bazaar with items and resources for the first time...\n")
	for i = 1, self.resListingsInit do
		self:addMoreResources()
		self:addMoreArmor()
		self:addMoreMedicine()
		self:addMoreFood()
		self:addMoreWeapons()
		self:addMoreArtisanItems()
		self:addMoreStructures()
		self:addMoreLoot()
	end
	setQuestStatus("BazaarBot:Initialized", 1)
	printf("BazaarBot: Initialized!\n")
end

-- A full inventory will prevent the creation and listing of new items
function BazaarBot:cleanInventory()
	local pBazaarBot = getCreatureObject(self.BazaarBotID)
	local pInventory = CreatureObject(pBazaarBot):getSlottedObject("inventory")
	local itemInInventory = math.tointeger(SceneObject(pInventory):getContainerObjectsSize())
	
	if (itemInInventory == 0) then
		return
	end

	printf("BazaarBot: Removing " .. tostring(itemInInventory) .. " items from my inventory...\n")
	
	while (itemInInventory > 0) do
		local pItem = SceneObject(pInventory):getContainerObject(i)
		
		SceneObject(pItem):destroyObjectFromWorld()
		SceneObject(pItem):destroyObjectFromDatabase()
		
		itemInInventory = math.tointeger(SceneObject(pInventory):getContainerObjectsSize())
	end
	
	printf("BazaarBot: Done!\n")
end

function BazaarBot:logListing(message)
	local outputFile = "log/bazaarbot_listings.log"
	logToFile(message, outputFile)
end

-- Resource Functions

function BazaarBot:addMoreResources()
	self:cleanInventory()
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
	local loggingNames = ""
	
	for i = 1, self.resPerGen do -- x number of resources
		local resourceName = self:pickResource()
		local listedOK = false
		
		for j = 1, #self.resStackSizes do -- x number of stack sizes
			for k = 1, self.resStacks do -- x number of stacks
				local pItem = bazaarBotMakeResources(pBazaarBot, resourceName, self.resStackSizes[j])
				local price = self.resStackSizes[j] * self.creditsPerUnit
				
				if (pItem ~= nil) then
					bazaarBotListItem(pBazaarBot, pItem, pVendor, self.itemDescription, price)
					listedOK = true
				else
					printf("BazaarBot: Failed to generate a stack of resource using the following name: " .. resourceName .. "\n")
				end
			end
		end
		
		if (listedOK == true) then
			self:logListing("Resource: " .. resourceName .. " " .. tostring(#self.resStackSizes * self.resStacks) .. " stacks")
		else
			self:logListing("Resource: " .. resourceName .. " Failed")
		end
	end
	
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

function BazaarBot:addMoreStructures()
	self:addMoreCraftedItems(BBStructuresConfig, BBStructuresItems)
end

function BazaarBot:addMoreCraftedItems(configTable, itemTable)
	self:cleanInventory()
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
	local listedOK = false
	
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
				
				if (pItem ~= nil) then
					bazaarBotListItem(pBazaarBot, pItem, pVendor, self.itemDescription, price)
				else
					self:logListing("Craft: " .. configTable.functionName .. "() Failed: " .. template)
					return
				end
			end
		end
	end
	
	self:logListing("Craft: " .. configTable.functionName .. "() OK")
end


-- Loot functions

function BazaarBot:addMoreLoot()
	self:cleanInventory()
	-- Schedule Event
	local nextTime = BBLootConfig.freq * 1000 + getRandomNumber(1,300000)
	
	if (hasServerEvent(BBLootConfig.eventName)) then
		rescheduleServerEvent(BBLootConfig.eventName, nextTime)
	else
		createServerEvent(nextTime, "BazaarBot", BBLootConfig.functionName, BBLootConfig.eventName)
	end

	-- Create and list the loot
	local pVendor = getSceneObject(self.terminalID)
	local pBazaarBot = getCreatureObject(self.BazaarBotID)
	
	for i = 1, BBLootConfig.quantity do
		local roll = getRandomNumber(1,100)
		local lootGroup = 1 -- Common
		
		if (roll > 95) then
			lootGroup = 3 -- Very Rare
		elseif (roll > 70) then
			lootGroup = 2 -- Rare
		end
	
		local lootName = BBLootItems[lootGroup][getRandomNumber(1,#BBLootItems[lootGroup])]
		local lootLevel = getRandomNumber(BBLootConfig.minLevel,BBLootConfig.maxLevel)
		 
		local pItem = bazaarBotMakeLootItem(pBazaarBot, lootName, lootLevel, false)
	
		if (pItem ~= nil) then
			local price = TangibleObject(pItem):getJunkValue()
			
			if (price == nil) then
				price = 2000 + getRandomNumber(1,2000) + lootLevel
			else
				price = price * 2 + getRandomNumber(1,100) + lootLevel
			end
		
			bazaarBotListItem(pBazaarBot, pItem, pVendor, self.itemDescription, price)
			self:logListing("Loot: " .. SceneObject(pItem):getObjectName() .. " (" .. tostring(lootLevel) .. ") " .. tostring(price) .. "cr")
		else
			self:logListing("Loot: " .. lootName .. " (" .. tostring(lootLevel) .. ") Failed")
		end
	end
end


-- Testing

function BazaarBot:test(pPlayer, pObject)
	self:addMoreResources()
	self:addMoreArmor()
	self:addMoreMedicine()
	self:addMoreFood()
	self:addMoreWeapons()
	self:addMoreArtisanItems()
	self:addMoreStructures()
	self:addMoreLoot()
	CreatureObject(pPlayer):sendSystemMessage("Test Complete!")
end

function BazaarBot:loadTestingObject()
	local pTerminal = spawnSceneObject("tatooine", "object/tangible/furniture/decorative/foodcart.iff" , 1591, 7, 3031, 0, 0, 0, 0, 0)
	
	if (pTerminal ~= nil) then
		-- Add menu and custom name
		SceneObject(pTerminal):setObjectMenuComponent("ABTestMenuComponent")
		SceneObject(pTerminal):setCustomObjectName("BazaarBot Trigger")
	end
end

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
