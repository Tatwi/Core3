local ObjectManager = require("managers.object.object_manager")

RecruiterConvoHandler = Object:new {}

function RecruiterConvoHandler:getNextConversationScreen(pConversationTemplate, pPlayer, selectedOption, pConversingNpc)
	local pConversationSession = CreatureObject(pPlayer):getConversationSession()

	local pLastConversationScreen = nil

	if (pConversationSession ~= nil) then
		local conversationSession = LuaConversationSession(pConversationSession)
		pLastConversationScreen = conversationSession:getLastConversationScreen()
	end

	local conversationTemplate = LuaConversationTemplate(pConversationTemplate)

	if (pLastConversationScreen ~= nil) then
		local lastConversationScreen = LuaConversationScreen(pLastConversationScreen)
		local optionLink = lastConversationScreen:getOptionLink(selectedOption)

		return conversationTemplate:getScreen(optionLink)
	end

	return self:getInitialScreen(pPlayer, pConversingNpc, pConversationTemplate)
end

function RecruiterConvoHandler:runScreenHandlers(conversationTemplate, conversingPlayer, conversingNPC, selectedOption, conversationScreen)
	local pGhost = CreatureObject(conversingPlayer):getPlayerObject()

	if (pGhost == nil) then
		return conversationScreen
	end

	local screen = LuaConversationScreen(conversationScreen)
	local screenID = screen:getScreenID()

	local conversationScreen = screen:cloneScreen()
	local clonedConversation = LuaConversationScreen(conversationScreen)
	if (screenID == "greet_member_start_covert" or screenID == "stay_covert" or screenID == "dont_resign_covert") then
		self:updateScreenWithPromotions(conversingPlayer, conversationTemplate, conversationScreen, recruiterScreenplay:getRecruiterFaction(conversingNPC))
		if (recruiterScreenplay:getFactionFromHashCode(CreatureObject(conversingPlayer):getFaction()) == "rebel") then
			clonedConversation:addOption("@conversation/faction_recruiter_rebel:s_480", "faction_purchase")
		else
			clonedConversation:addOption("@conversation/faction_recruiter_imperial:s_324", "faction_purchase")
		end
	elseif (screenID == "greet_member_start_overt" or screenID == "stay_special_forces" or screenID == "stay_overt" or screenID == "dont_resign_overt") then
		self:updateScreenWithPromotions(conversingPlayer, conversationTemplate, conversationScreen, recruiterScreenplay:getRecruiterFaction(conversingNPC))
		self:updateScreenWithBribe(conversingPlayer, conversingNPC, conversationTemplate, conversationScreen, recruiterScreenplay:getRecruiterFaction(conversingNPC))
		if (recruiterScreenplay:getFactionFromHashCode(CreatureObject(conversingPlayer):getFaction()) == "rebel") then
			clonedConversation:addOption("@conversation/faction_recruiter_rebel:s_480", "faction_purchase")
		else
			clonedConversation:addOption("@conversation/faction_recruiter_imperial:s_324", "faction_purchase")
		end

	elseif (screenID == "accept_join") then
		CreatureObject(conversingPlayer):setFaction(recruiterScreenplay:getRecruiterFactionHashCode(conversingNPC))
		PlayerObject(pGhost):setFactionStatus(1)

	elseif (screenID == "accepted_go_overt") then
		CreatureObject(conversingPlayer):setPvpStatusBit(CHANGEFACTIONSTATUS)
		writeData(CreatureObject(conversingPlayer):getObjectID() .. ":changingFactionStatus", 1)
		createEvent(30000, "recruiterScreenplay", "handleGoOvert", conversingPlayer, "")

	elseif (screenID == "accepted_go_covert") then
		if (CreatureObject(conversingPlayer):hasSkill("force_title_jedi_rank_03")) then
			return
		end
		CreatureObject(conversingPlayer):setPvpStatusBit(CHANGEFACTIONSTATUS)
		writeData(CreatureObject(conversingPlayer):getObjectID() .. ":changingFactionStatus", 1)
		createEvent(300000, "recruiterScreenplay", "handleGoCovert", conversingPlayer, "")

	elseif (screenID == "accepted_go_on_leave") then

		if (CreatureObject(conversingPlayer):hasSkill("force_title_jedi_rank_03")) then
			return
		end
		CreatureObject(conversingPlayer):setPvpStatusBit(CHANGEFACTIONSTATUS)
		writeData(CreatureObject(conversingPlayer):getObjectID() .. ":changingFactionStatus", 1)
		createEvent(300000, "recruiterScreenplay", "handleGoOnLeave", conversingPlayer, "")

	elseif (screenID == "accepted_resign") then
		if (CreatureObject(conversingPlayer):hasSkill("force_title_jedi_rank_03")) then
			return
		end

		if (PlayerObject(pGhost):isOvert()) then
			CreatureObject(conversingPlayer):setPvpStatusBit(CHANGEFACTIONSTATUS)
			writeData(CreatureObject(conversingPlayer):getObjectID() .. ":changingFactionStatus", 1)
			createEvent(300000, "recruiterScreenplay", "handleResign", conversingPlayer, "")
			return conversationScreen
		end
		recruiterScreenplay:handleResign(conversingPlayer)

	elseif (screenID == "accepted_resume_duties") then
		CreatureObject(conversingPlayer):setPvpStatusBit(CHANGEFACTIONSTATUS)
		createEvent(30000, "recruiterScreenplay", "handleGoCovert", conversingPlayer, "")
		writeData(CreatureObject(conversingPlayer):getObjectID() .. ":changingFactionStatus", 1)

	elseif (screenID == "confirm_promotion") then
		local rank = CreatureObject(conversingPlayer):getFactionRank() + 1
		clonedConversation:setDialogTextTO("faction_recruiter", getRankName(rank))

	elseif (screenID == "accepted_promotion") then
		local rank = CreatureObject(conversingPlayer):getFactionRank() + 1
		local requiredPoints = getRankCost(rank)

		if (PlayerObject(pGhost):getFactionStanding(recruiterScreenplay:getRecruiterFaction(conversingNPC)) < (requiredPoints + recruiterScreenplay:getMinimumFactionStanding())) then
			local convoTemplate = LuaConversationTemplate(conversationTemplate)
			local notEnoughScreen = convoTemplate:getScreen("not_enough_points")
			local screenObject = LuaConversationScreen(notEnoughScreen)

			conversationScreen = screenObject:cloneScreen()

			screenObject = LuaConversationScreen(conversationScreen)
			screenObject:setDialogTextTO("faction_recruiter", getRankName(rank))
			screenObject:setDialogTextDI(requiredPoints)
		else
			PlayerObject(pGhost):decreaseFactionStanding(recruiterScreenplay:getRecruiterFaction(conversingNPC), requiredPoints)
			CreatureObject(conversingPlayer):setFactionRank(rank)
		end

	elseif screenID == "confirm_bribe" and CreatureObject(conversingPlayer):hasSkill("combat_smuggler_underworld_04") and (CreatureObject(conversingPlayer):getCashCredits() >= 100000)
		and (getFactionPointsCap(CreatureObject(conversingPlayer):getFactionRank()) >= PlayerObject(pGhost):getFactionStanding(recruiterScreenplay:getRecruiterFaction(conversingNPC)) + 1250) then
		self:add100kBribeOption(conversingNPC, clonedConversation)

	elseif (screenID == "accepted_bribe_20k") and CreatureObject(conversingPlayer):hasSkill("combat_smuggler_underworld_04") and (CreatureObject(conversingPlayer):getCashCredits() >= 20000)
		and (getFactionPointsCap(CreatureObject(conversingPlayer):getFactionRank()) >= PlayerObject(pGhost):getFactionStanding(recruiterScreenplay:getRecruiterFaction(conversingNPC)) + 250) then
		recruiterScreenplay:grantBribe(conversingNPC, conversingPlayer, 20000, 250)

	elseif (screenID == "accepted_bribe_100k") and CreatureObject(conversingPlayer):hasSkill("combat_smuggler_underworld_04") and (CreatureObject(conversingPlayer):getCashCredits() >= 100000)
		and (getFactionPointsCap(CreatureObject(conversingPlayer):getFactionRank()) >= PlayerObject(pGhost):getFactionStanding(recruiterScreenplay:getRecruiterFaction(conversingNPC)) + 1250) then
		recruiterScreenplay:grantBribe(conversingNPC, conversingPlayer, 100000, 1250)

	elseif (screenID == "fp_furniture" or screenID == "fp_weapons_armor" or screenID == "fp_installations" or screenID == "fp_uniforms" or screenID == "fp_hirelings") then
		recruiterScreenplay:sendPurchaseSui(conversingNPC, conversingPlayer, screenID)

	elseif (screenID == "greet_neutral_start") then
		self:addJoinMilitaryOption(recruiterScreenplay:getRecruiterFaction(conversingNPC), clonedConversation, PlayerObject(pGhost), conversingNPC)

	elseif (screenID == "show_gcw_score") then
		local zoneName = SceneObject(conversingNPC):getZoneName()
		clonedConversation:setDialogTextDI(getImperialScore(zoneName))
		clonedConversation:setDialogTextTO(getRebelScore(zoneName))

	end

	return conversationScreen
end

function RecruiterConvoHandler:getInitialScreen(pPlayer, pNpc, conversationTemplate)
	local convoTemplate = LuaConversationTemplate(conversationTemplate)
	local pGhost = CreatureObject(pPlayer):getPlayerObject()

	if (pGhost == nil) then
		return convoTemplate:getScreen("greet_neutral_start")
	end

	local faction = CreatureObject(pPlayer):getFaction()
	local factionStanding = PlayerObject(pGhost):getFactionStanding(recruiterScreenplay:getRecruiterFaction(pNpc))

	if (CreatureObject(pPlayer):isChangingFactionStatus() and readData(CreatureObject(pPlayer):getObjectID() .. ":changingFactionStatus") ~= 1) then
		recruiterScreenplay:handleGoCovert(pPlayer)
	end

	if (faction == recruiterScreenplay:getRecruiterEnemyFactionHashCode(pNpc)) then
		return convoTemplate:getScreen("greet_enemy")
	elseif factionStanding < -200 and PlayerObject(pGhost):getFactionStanding(recruiterScreenplay:getRecruiterEnemyFaction(pNpc)) > 0 then
		return convoTemplate:getScreen("greet_hated")
	elseif (CreatureObject(pPlayer):isChangingFactionStatus()) then
		return convoTemplate:getScreen("greet_changing_status")
	elseif (faction == recruiterScreenplay:getRecruiterFactionHashCode(pNpc)) then
		if (PlayerObject(pGhost):isOnLeave()) then
			return convoTemplate:getScreen("greet_onleave_start")
		elseif (PlayerObject(pGhost):isCovert()) then
			return convoTemplate:getScreen("greet_member_start_covert")
		else
			return convoTemplate:getScreen("greet_member_start_overt")
		end
	else
		return convoTemplate:getScreen("greet_neutral_start")
	end
	return nil
end

function RecruiterConvoHandler:addRankReviewOption(faction, screen)
	if (faction == "rebel") then
		screen:addOption("@conversation/faction_recruiter_rebel:s_468", "confirm_promotion")
	elseif (faction == "imperial") then
		screen:addOption("@conversation/faction_recruiter_imperial:s_312", "confirm_promotion")
	end
end

function RecruiterConvoHandler:addJoinMilitaryOption(faction, screen, playerObject, conversingNPC)
	if (faction == "rebel") then
		if (playerObject:getFactionStanding(recruiterScreenplay:getRecruiterFaction(conversingNPC)) < recruiterScreenplay.minimumFactionStanding) then
			screen:addOption("@conversation/faction_recruiter_rebel:s_580", "neutral_need_more_points")
		else
			screen:addOption("@conversation/faction_recruiter_rebel:s_580", "join_military")
		end
	elseif (faction == "imperial") then
		if (playerObject:getFactionStanding(recruiterScreenplay:getRecruiterFaction(conversingNPC)) < recruiterScreenplay.minimumFactionStanding) then
			screen:addOption("@conversation/faction_recruiter_imperial:s_428", "neutral_need_more_points")
		else
			screen:addOption("@conversation/faction_recruiter_imperial:s_428", "join_military")
		end
	end
end

function RecruiterConvoHandler:getRejectPromotionString(faction)
	if (faction == "rebel") then
		return "@conversation/faction_recruiter_rebel:s_476"
	elseif (faction == "imperial") then
		return "@conversation/faction_recruiter_imperial:s_320"
	end
end

function RecruiterConvoHandler:addBribeOption(pNpc, screen)
	local faction = recruiterScreenplay:getRecruiterFaction(pNpc)
	if (faction == "rebel") then
		screen:addOption("@conversation/faction_recruiter_rebel:s_568", "confirm_bribe")
	elseif (faction == "imperial") then
		screen:addOption("@conversation/faction_recruiter_imperial:s_398", "confirm_bribe")
	end
end

function RecruiterConvoHandler:add100kBribeOption(pNpc, screen)
	local faction = recruiterScreenplay:getRecruiterFaction(pNpc)
	if (faction == "rebel") then
		screen:addOption("@conversation/faction_recruiter_rebel:s_576", "accepted_bribe_100k")
	elseif (faction == "imperial") then
		screen:addOption("@conversation/faction_recruiter_imperial:s_406", "accepted_bribe_100k")
	end
end

function RecruiterConvoHandler:updateScreenWithBribe(pPlayer, pNpc, conversationTemplate, screen, faction)
	local pGhost = CreatureObject(pPlayer):getPlayerObject()

	if (pGhost == nil) then
		return
	end

	local screenObject = LuaConversationScreen(screen)

	if (CreatureObject(pPlayer):hasSkill("combat_smuggler_underworld_04") and (CreatureObject(pPlayer):getCashCredits() >= 20000)
		and (getFactionPointsCap(CreatureObject(pPlayer):getFactionRank()) >= PlayerObject(pGhost):getFactionStanding(faction) + 250)) then
		self:addBribeOption(pNpc, screenObject)
	end
end

function RecruiterConvoHandler:updateScreenWithPromotions(pPlayer, conversationTemplate, screen, faction)
	local pGhost = CreatureObject(pPlayer):getPlayerObject()

	if (pGhost == nil) then
		return
	end

	local screenObject = LuaConversationScreen(screen)
	local rank = CreatureObject(pPlayer):getFactionRank()

	if rank < 0 or isHighestRank(rank) == true then
		return
	end

	local requiredPoints = getRankCost(rank + 1)
	local currentPoints = PlayerObject(pGhost):getFactionStanding(faction)

	if (currentPoints < requiredPoints + recruiterScreenplay:getMinimumFactionStanding()) then
		return
	end

	self:addRankReviewOption(faction, screenObject)
end
