MyAddonDB = MyAddonDB or {}
MyAddonDB.minimapButton = MyAddonDB.minimapButton or {}
MyAddonDB.minimapButton.angle = MyAddonDB.minimapButton.angle or 45

trackedGroups = {
	"CouncilOfDornogal", "TheAssemblyOfTheDeeps", "Hallowfall", "SeveredThreads", "Undermine", "FlameRadiance", "Karesh"
}

trackedQuests = {
	CouncilOfDornogal = { 83240 },
	TheAssemblyOfTheDeeps = { 82946, 83333 },
	Hallowfall = { 76586 },
	SeveredThreads = { 80670, 80671, 80672 },
	Undermine = { 85869, 85879, 86775 },
	FlameRadiance = { 89295 },
	Karesh = { 91093, 85460 }
}

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		CheckTrackedQuests()
	end
end)

local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("WeeklyCheckList", {
	type = "data source",
	text = "Weekly CheckList",
	icon = "Interface\\Icons\\INV_Misc_Bandage_10",

	-- Left/right click behavior
	OnClick = function(_, button)
		if button == "LeftButton" then
			print("Left click on minimap button!")
		elseif button == "RightButton" then
			print("Right click - could open settings")
		end
	end,

	-- Tooltip when hovering
	OnTooltipShow = function(tt)
		tt:SetText("Weekly CheckList")

		for _, groupName in ipairs(trackedGroups) do
			local questList = trackedQuests[groupName]
			tt:AddLine(" ")
			tt:AddLine("|cffffff00" .. groupName .. "|r")
			for _, questID in ipairs(questList) do
				local completed = MyAddonDB.questStatus[groupName][questID]
				local name = C_QuestLog.GetTitleForQuestID(questID) or ("Quest " .. questID)
				local status = completed and "|cff00ff00 " or "|cffff0000 "
				tt:AddLine("   " .. status .. name .. "|r")
				if (groupName == "SeveredThreads") then
					break
				end
			end
		end
	end,
})

local LDBIcon = LibStub("LibDBIcon-1.0")
LDBIcon:Register("WeeklyCheckList", LDB, MyAddonDB.minimap)

function CheckTrackedQuests()
	for groupName, questList in pairs(trackedQuests) do
		-- Ensure the SavedVariables table exists
		MyAddonDB.questStatus[groupName] = MyAddonDB.questStatus[groupName] or {}

		for _, questID in ipairs(questList) do
			if C_QuestLog.IsQuestFlaggedCompleted(questID) then
				MyAddonDB.questStatus[groupName][questID] = true
			else
				MyAddonDB.questStatus[groupName][questID] = MyAddonDB.questStatus[groupName][questID] or false
			end
		end
	end
end

-- Check for quest completion when a quest is completed
--[[ if event == "QUEST_TURNED_IN" then
		local questID = ...

		-- Loop through groups
		for groupName, questList in pairs(trackedQuests) do
			for _, id in ipairs(questList) do
				if id == questID then
					-- Mark as completed in DB
					MyAddonDB.questStatus[groupName][id] = true
				end
			end
		end
	end ]]
