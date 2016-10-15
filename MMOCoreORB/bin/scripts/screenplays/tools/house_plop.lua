-- Admin tool for placing a structure into the world as a player structure.
-- Door points in the direction the character is facing.
-- Custom Lua calls: adminPlaceStructure(pPlayer, templateString)

local ObjectManager = require("managers.object.object_manager")
includeFile("tools/house_plop_table.lua")

HousePlop = ScreenPlay:new {
	numberOfActs = 1,
}
registerScreenPlay("HousePlop", true)

function HousePlop:openWindow(pPlayer)
	if (pPlayer == nil) then
		return
	end

	self:showCategories(pPlayer)
end

function HousePlop:showCategories(pPlayer)
	local sui = SuiListBox.new("HousePlop", "showItems") -- calls showItems on SUI window event

	sui.setTargetNetworkId(SceneObject(pPlayer):getObjectID())

	sui.setTitle("Place Structure")

	local promptText = "This tool adds a structure to the world that is classed the same as a player structure. It works for normal player structures as well as NPC structures.\n\n"
	promptText = (promptText .. "Instructions:\n")
	promptText = (promptText .. "1. Stand where you want the center of structure to be.\n")
	promptText = (promptText .. "2. Face the direction you want the door to face.\n")
	promptText = (promptText .. "3. Select the desired structure from the list.\n\n")
	promptText = (promptText .. "TIP: Use /tarkin showRuler to show a green line that will help you better visualize the alignment.\n\n")
	promptText = (promptText .. "WARNING: This tool bypasses all placement rules, allowing you to place a structure anywhere, good or bad.")
	sui.setPrompt(promptText)

	for i = 1, #housePlopTable, 1 do
		sui.add(housePlopTable[i].catName, "")
	end

	sui.sendTo(pPlayer)
end

function HousePlop:showItems(pPlayer, pSui, eventIndex, args)
	local cancelPressed = (eventIndex == 1)

	if (cancelPressed) then
		return
	end


	if (args == "-1") then
		CreatureObject(pPlayer):sendSystemMessage("No category was selected...")
		return
	end


	local selectedIndex = tonumber(args) + 1

	writeScreenPlayData(pPlayer, "HousePlop", "categorySelected", selectedIndex) 

	local sui = SuiListBox.new("HousePlop", "itemSelection") -- calls itemSelection on SUI window event

	sui.setTargetNetworkId(SceneObject(pPlayer):getObjectID())

	sui.setTitle("Place Structure")
	sui.setPrompt(housePlopTable[selectedIndex].catName .. "\n\n Press Cancel to return to the main menu.")

	for i = 1, #housePlopTable[selectedIndex].items, 2 do
		sui.add(housePlopTable[selectedIndex].items[i], housePlopTable[selectedIndex].items[i+1])
	end

	sui.sendTo(pPlayer)
end

function HousePlop:itemSelection(pPlayer, pSui, eventIndex, args)
	local cancelPressed = (eventIndex == 1)

	if (cancelPressed) then
		return self:showCategories(pPlayer)
	end

	if (args == "-1") then
		CreatureObject(pPlayer):sendSystemMessage("No item was selected...")
		return
	end

	if not (SceneObject(pPlayer):getParent() == nil) then
		CreatureObject(pPlayer):sendSystemMessage("You must be outside to place a structure.")
		return
	end

	local selectedItemIndex = tonumber(args) + 1
	local catIndex = tonumber(readScreenPlayData(pPlayer, "HousePlop", "categorySelected"))

	adminPlaceStructure(pPlayer, housePlopTable[catIndex].items[selectedItemIndex*2])

	CreatureObject(pPlayer):sendSystemMessage("Structure placed into the world.")

	self:showItems(pPlayer, pSui, eventIndex, catIndex-1) -- Opens the current screen again
end
