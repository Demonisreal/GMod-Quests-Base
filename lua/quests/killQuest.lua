-- KillQuest Class
KillQuest = setmetatable({}, {__index = QuestBase})
KillQuest.__index = KillQuest

function KillQuest:new(args)
    if not args[2] || args[2] == 0 || not args[3] || not args[4] then
        PrintPink("Usage: AddQuest <QuestType> [requiredKills] [roleToBeKilled] [roleForKiller]")
        PrintPink("Innocent: " .. ROLE_INNOCENT)
        PrintPink("Traitor: " .. ROLE_TRAITOR)
        PrintPink("Detective: " .. ROLE_DETECTIVE)
        self.DidntFinishInit = true
        return
    end

    local obj = QuestBase:new("KillQuest", args[1])
    setmetatable(obj, self)
    obj.requiredKills = tonumber(args[2]) or 1
    obj.killedRole = args[3]
    obj.killerRole = args[4]
    obj.currentKills = 0
    for i = 1, 3 do
        table.remove(args, 1) -- Always remove the first element
    end

    -- Rewards
    obj.rewards = args
    --Rewards end

    return obj
end

function KillQuest:OnStart(quest)
    self.requiredKills = tonumber(quest.requiredKills) or 1
    self.killedRole = quest.killedRole
    self.killerRole = quest.killerRole
    self.currentKills = 0
    PrintPink("KillQuest started:")
    PrintPink("Kill " .. self.requiredKills .. " " .. self.killedRole .. ".")
    PrintPink("As role: " .. self.killerRole)
end

function KillQuest:Update(quest)
    quest.currentKills = quest.currentKills + 1    
    PrintPink("KillQuest progress: " .. quest.currentKills .. "/" .. quest.requiredKills)
    if quest.currentKills >= quest.requiredKills then
        KillQuest:Complete(quest)
    end
end

function KillQuest:OnComplete(quest)
    quest.completed = true
    PrintPink("Congratulations! You completed the KillQuest!")
end

function KillQuest:GiveRewards(quest, ply)
    if quest.rewardsClaimed == false then
        PrintPink(quest.rewardsClaimed)
        PrintPink("Giving rewards for KillQuest to Player: " .. ply:Nick())
        ply:PS2_AddStandardPoints(tonumber(quest.rewards[1]))
        ply:PS2_AddPremiumPoints(tonumber(quest.rewards[2]))
        if ply.AddXP then
            ply:AddXP(tonumber(quest.rewards[3]))
        end
        quest.rewardsClaimed = true
        net.Start("SynchronizeActiveQuests")
        net.WriteTable(QuestManager.activeQuests[ply:SteamID64()])
        net.Send(ply)
    end
end

function KillQuest:PlayerKilled(quest)
    if not quest.completed and quest.type == "KillQuest" then
        KillQuest:Update(quest)
    end
end

-- Hook to Track Player Kills
hook.Add("PlayerDeath", "KillQuest_PlayerDeath", function(victim, inflictor, attacker)
    if IsValid(attacker) and attacker:IsPlayer() then
        for _, quest in ipairs(QuestManager.activeQuests[attacker:SteamID64()]) do
            if quest.killerRole == tostring(attacker:GetRole()) and quest.killedRole == tostring(victim:GetRole()) then
                KillQuest:PlayerKilled(quest)
            end
        end
        net.Start("SynchronizeActiveQuests")
        net.WriteTable(QuestManager.activeQuests[attacker:SteamID64()])
        net.Send(attacker)
    end
end)
