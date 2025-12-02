MyAddonDB = MyAddonDB or {}

trackedQuests = {
	Undermine = { 85869, 85879, 85881 },
}

function WeeklyCheckList_OnLoad(self)
	self:SetMovable(true)
	self:EnableMouse(true)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	-- Optional: set your own icon
	local icon = self:CreateTexture(nil, "BACKGROUND")
	icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
	icon:SetAllPoints(self)
	self.icon = icon

	self:RegisterEvent("PLAYER_LOGIN")
end

function WeeklyCheckList_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetText("WeeklyCheckList", 1, 1, 1)

	--[[ for questID, completed in pairs(MyAddon.questStatus) do
        local color = completed and "|cff00ff00" or "|cffff0000"
        local status = completed and "Completed" or "Not Completed"

        GameTooltip:AddLine(color .. "Quest " .. questID .. ": " .. status .. "|r")
    end ]]


	for groupName, questList in pairs(trackedQuests) do
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("|cffffff00" .. groupName .. "|r") -- group header

		for _, questID in ipairs(questList) do
			local completed = MyAddonDB.questStatus[groupName][questID]
			local name = C_QuestLog.GetTitleForQuestID(questID) or ("Quest " .. questID)

			if completed then
				GameTooltip:AddLine("   |cff00ff00 ✔ " .. name .. "|r")
			else
				GameTooltip:AddLine("   |cffff0000 ✘ " .. name .. "|r")
			end
		end
	end

	GameTooltip:Show()
end

function WeeklyCheckList_OnLeave(self)
	GameTooltip:Hide()
end

function WeeklyCheckList_OnClick(self, button)
	print("You clicked the minimap button with " .. button)
end

function WeeklyCheckList_OnEvent(self, event)
	-- Create DB if missing
	MyAddonDB.questStatus = MyAddonDB.questStatus or {}

	-- Iterate groups
	for groupName, questList in pairs(trackedQuests) do
		-- Ensure the group exists in the DB
		MyAddonDB.questStatus[groupName] = MyAddonDB.questStatus[groupName] or {}

		-- Iterate quests inside each group
		for _, questID in ipairs(questList) do
			local completed = C_QuestLog.IsQuestFlaggedCompleted(questID)

			-- Only save TRUE (never overwrite true with false)
			if completed then
				MyAddonDB.questStatus[groupName][questID] = true
			end

			-- Preload quest name for tooltip
			C_QuestLog.RequestLoadQuestByID(questID)
		end
	end
end
