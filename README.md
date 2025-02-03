# GMod Quests

## ConCommands:
### ttt_quest_menu
Usage: ttt_quest_menu<br />
No parameters. Just toggles the quest menu on and off.
### AddQuest
Usage: AddQuest [QuestType] [weight] [parameters]<br /><br />

The weight determines how likely it is to appear. The higher, the more likely.<br />
Formula: (weight/Sum(allQuestsWeights)) * 100 = Chance in %<br />
So if the quest has a weight of 50, all quests (including this) have a total weight of 200, theres a ((50/200) * 100)% chance for the quest to appear (25% in this example).
#### Killquest parameters:
[requiredKills] [roleToBeKilled] [roleForKiller] [rewards]<br />
There are (by default) up to 3 rewards in the following order:<br />
Pointshop 2 points, Pointshop 2 premium points, Exp for a proprietary skilltree (You can leave it empty or set it 0. It will still work without it).<br /><br />

| Role ID | Role Name  |  
|---------|------------|  
| 0       | Innocent   |  
| 1       | Traitor    |  
| 2       | Detective  |  
<br />
e.g. AddQuest KillQuest 50 5 0 1 50000 200 25000<br />

WARNING: Some methds return it as number, but we use it as a string, so it may needs to be converted (I personally just tostring the number)

## Development
To add a new quest you must reqister it with:<br />
QuestManager.questTypes = {<br />
    KillQuest = KillQuest,<br />
    WalkerQuest = WalkerQuest<br />
}<br />
e.g. QuestManager.questTypes.CollectQuest = CollectQuest

### Hooks
#### QuestsUpdated
Gets called on the client after it got a new update for the local player's active quests. This sends a table of Quests as argument.

### Fields
The fields a quest type has accessible (e.g. for displaying in a UI)
#### Base
- type - the type of a quest as string value (e.g. "KillQuest").
- completed - wether or not the quest has been completed.
- rewardsClaimed - wether or not the rewards have been claimed.
- uniqueId - the (hopefully) unique Id for each quest. 
- weight - the weighted chance of the quest to be selected.
- player - the player this quest is assigned to.
- rewards - A table with the rewards for completing the quest.
    - A new reward has to be manually added to the GiveRewards method.
    - An example could be adding Points for Pointshop 2 by adding the line `ply:PS2_AddStandardPoints(500)`
#### KillQuest
- requiredKills - The kills that are required to complete the quest.
- killedRole -  The role the victim needs to have to advance the quest.
- killerRole - The role you (the killer) needs to have to advance the quest.
- currentKills - The current amount of kills (progress) you have for this specific quest.
#### WalkerQuest
- requiredSteps - The steps required to finish the quest.
- currentSteps - The already walked steps.

Just a test here
A third test here.
