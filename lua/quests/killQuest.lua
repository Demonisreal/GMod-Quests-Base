-- KillQuest Class
KillQuest = setmetatable({}, {__index = QuestBase})
KillQuest.__index = KillQuest

function KillQuest:new(requiredKills, killedRole, killerRole)
    if not requiredKills || requiredKills == 0 || not killedRole || not killerRole then
        PrintPink("Usage: AddQuest <QuestType> [requiredKills] [roleToBeKilled] [roleForKiller]")
        PrintPink("Innocent: " .. ROLE_INNOCENT)
        PrintPink("Traitor: " .. ROLE_TRAITOR)
        PrintPink("Detective: " .. ROLE_DETECTIVE)
        self.DidntFinishInit = true
        return
    end

    local obj = QuestBase:new("KillQuest")
    setmetatable(obj, self)
    obj.requiredKills = tonumber(requiredKills) or 1
    obj.killedRole = killedRole
    obj.killerRole = killerRole
    obj.currentKills = 0

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
    PrintPink(self.player)
end

function KillQuest:Update(quest)
    quest.currentKills = quest.currentKills + 1    
    PrintPink("KillQuest progress: " .. quest.currentKills .. "/" .. quest.requiredKills)
    if quest.currentKills >= quest.requiredKills then
        KillQuest:Complete(quest)
    end
end

function KillQuest:OnComplete(quest)
    PrintPink("Congratulations! You completed the KillQuest by killing " .. quest.requiredKills .. " players.")
end

function KillQuest:PlayerKilled(quest)
    if not quest.completed and quest.type == "KillQuest" then
        KillQuest:Update(quest)
    end
end

-- Hook to Track Player Kills
hook.Add("PlayerDeath", "KillQuest_PlayerDeath", function(victim, inflictor, attacker)
    if IsValid(attacker) and attacker:IsPlayer() then
        PrintPink("Role:")
        PrintPink(attacker:GetRole())
        for _, quest in ipairs(QuestManager.activeQuests[attacker:SteamID64()]) do
            if(quest.killerRole == attacker:GetRole() and quest.killedRole == victim:GetRole()) then
                KillQuest:PlayerKilled(quest)
            end
        end
        net.Start("SynchronizeActiveQuests")
        net.WriteTable(QuestManager.activeQuests[attacker:SteamID64()])
        net.Send(attacker)
    end
end)
