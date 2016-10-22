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

BazaarBot = ScreenPlay:new {
	numberOfActs = 1,
	BazaarBotID = 281474993877563, -- Make a character named BazaarBot and put its PlayerID number here (/getPlayerID BazaarBot).
}

registerScreenPlay("BazaarBot", true)


function BazaarBot:start()
	-- Testing trigger object
	local pTerminal = spawnSceneObject("tatooine", "object/tangible/furniture/decorative/foodcart.iff" , 1591, 7, 3031, 0, 0, 0, 0, 0)
	if (pTerminal ~= nil) then
		-- Add menu and custom name
		SceneObject(pTerminal):setObjectMenuComponent("ABTestMenuComponent")
		SceneObject(pTerminal):setCustomObjectName("AuctionBot Trigger")
	end
end


function BazaarBot:test(pPlayer, pObject)
	local pVendor = getSceneObject(3945376)
	local description = "This item is for sale!"
	local price = 250
	local pBazaarBot = getCreatureObject(281474993877563)
	
	local pItem = bazaarBotMakeResources(pBazaarBot, "Abesis", 1000)
	local itemForSaleObjectID = SceneObject(pItem):getObjectID()
	
	bazaarBotListItem(pBazaarBot, itemForSaleObjectID, pVendor, description, price)
	
	CreatureObject(pPlayer):sendSystemMessage("Test Complete!")
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
