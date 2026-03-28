Healing = Healing or {}

Healing.filteredPotions = {}

Healing.slots = Healing.slots or {
    { potionIndex = 0, percentIndex = 1 },
    { potionIndex = 0, percentIndex = 1 },
    { potionIndex = 0, percentIndex = 1 }
}

dofile("data.lua")

SaborHelper.arrowpercentLeft = { clip = { x=0, y=0, width=10, height=34 } }
SaborHelper.arrowpercentRight = { clip = { x=0, y=0, width=10, height=34 } }

-- =========================================
-- LOAD
-- =========================================
function Healing.load(playerVoc, playerLevel)

    Healing.filteredPotions = {}

    local data = HEALING_DATA[playerVoc]
    if not data or not data.potions then return end

    -- HEALTH
    for _, p in ipairs(data.potions.health or {}) do
        if playerLevel >= p.level then
            table.insert(Healing.filteredPotions, {
                id = p.id,
                name = p.name,
                level = p.level,
                type = "health"
            })
        end
    end

    -- MANA
    for _, p in ipairs(data.potions.mana or {}) do
        if playerLevel >= p.level then
            table.insert(Healing.filteredPotions, {
                id = p.id,
                name = p.name,
                level = p.level,
                type = "mana"
            })
        end
    end

    print("[Healing] Potions carregadas:", #Healing.filteredPotions)
end

-- =========================================
-- NAV
-- =========================================
function Healing.next()
    local slot = Healing.slots[Healing.currentSlot]
    if not slot then return end

    if #Healing.filteredPotions == 0 then return end

    slot.potionIndex = slot.potionIndex + 1

    if slot.potionIndex > #Healing.filteredPotions then
        slot.potionIndex = 0
    end
end

function Healing.prev()
    local slot = Healing.slots[Healing.currentSlot]
    if not slot then return end

    if #Healing.filteredPotions == 0 then return end

    slot.potionIndex = slot.potionIndex - 1

    if slot.potionIndex < 0 then
        slot.potionIndex = #Healing.filteredPotions
    end
end

-- =========================================
-- GET (RETORNA OBJETO)
-- =========================================
function Healing.getPotion(slotId)
    local slot = Healing.slots[slotId]

    if not slot then return nil end
    if slot.potionIndex == 0 then return nil end

    return Healing.filteredPotions[slot.potionIndex]
end

-- =========================================
-- UI UPDATE
-- =========================================
function SaborHelper:updateHealingUI()
    if not self.ui then return end

    for i = 1, 2 do -- depois muda pra 3

        local item = self.ui:recursiveGetChildById("healingPotionSlot"..i)
        local bg = self.ui:recursiveGetChildById("healingSlotBg"..i)
        local nameLabel = self.ui:recursiveGetChildById("healingPotionName"..i)
        local percentLabel = self.ui:recursiveGetChildById("healingPercentLabel"..i) -- 🔥 NOVO

        print("LABEL "..i..":", nameLabel)

        if not item then goto continue end

        local potion = Healing.getPotion(i)

        if potion then
            print("SETANDO SLOT "..i..":", potion.name)

            item:setItemId(potion.id)

            if nameLabel then
                nameLabel:setText("")
                scheduleEvent(function()
                    if nameLabel then
                        nameLabel:setText(potion.name)
                    end
                end, 1)
            end

            if bg then
                bg:setImageSource("/modules/sabor_helper/images/slot-green")
            end
        else
            item:setItemId(0)

            if nameLabel then
                nameLabel:setText("None")
            end

            if bg then
                bg:setImageSource("/modules/sabor_helper/images/slot-red")
            end
        end

        -- 🔥 ATUALIZA A % (ISSO QUE FALTAVA)
        if percentLabel then
            local slot = Healing.slots[i]
            local percent = self.percentValues[slot.percentIndex or 1]
            percentLabel:setText(percent .. "%")
        end

        ::continue::
    end
end

-- =========================================
-- SCROLL POTION
-- =========================================
function SaborHelper:startNextPotion(slotId)
    self.scrollEvents = self.scrollEvents or {}

    if self.scrollEvents[slotId] then return end

    self.arrowRight.clip = { x=10, y=0, width=10, height=34 }
	
    self.scrollEvents[slotId] = cycleEvent(function()
        Healing.currentSlot = slotId
        Healing.next()
        self:updateHealingUI()
    end, 80)
end

function SaborHelper:startPrevPotion(slotId)
    self.scrollEvents = self.scrollEvents or {}

    if self.scrollEvents[slotId] then return end

    self.arrowLeft.clip = { x=10, y=0, width=10, height=34 }

    self.scrollEvents[slotId] = cycleEvent(function()
        Healing.currentSlot = slotId
        Healing.prev()
        self:updateHealingUI()
    end, 80)
end

function SaborHelper:stopScroll(slotId)
    if not self.scrollEvents then return end

    if slotId then
        if self.scrollEvents[slotId] then
            removeEvent(self.scrollEvents[slotId])
            self.scrollEvents[slotId] = nil
        end
    else
        for i, ev in pairs(self.scrollEvents) do
            removeEvent(ev)
        end
        self.scrollEvents = {}
    end

    self.arrowLeft.clip = { x=0, y=0, width=10, height=34 }
    self.arrowRight.clip = { x=0, y=0, width=10, height=34 }
end

-- =========================================
-- percent SCROLL
-- =========================================
function SaborHelper:startNextpercent(slotId)
    self.percentScroll = self.percentScroll or {}

    if self.percentScroll[slotId] then return end

    self.percentScroll[slotId] = cycleEvent(function()
        local slot = Healing.slots[slotId]
        if not slot then return end

        slot.percentIndex = slot.percentIndex + 1

        if slot.percentIndex > #self.percentValues then
            slot.percentIndex = 1
        end

        self:updateHealingUI()
    end, 80)
end

function SaborHelper:startPrevpercent(slotId)
    self.percentScroll = self.percentScroll or {}

    if self.percentScroll[slotId] then return end

    self.percentScroll[slotId] = cycleEvent(function()
        local slot = Healing.slots[slotId]
        if not slot then return end

        slot.percentIndex = slot.percentIndex - 1

        if slot.percentIndex < 1 then
            slot.percentIndex = #self.percentValues
        end

        self:updateHealingUI()
    end, 80)
end

function SaborHelper:stoppercentScroll(slotId)
    if not self.percentScroll then return end

    if slotId and self.percentScroll[slotId] then
        removeEvent(self.percentScroll[slotId])
        self.percentScroll[slotId] = nil
    end
end

-- =========================================
-- UPDATE percent UI
-- =========================================
function SaborHelper:updatepercentUI()
    if not self.percentLabel then
        print("? label nil")
        return
    end

    local value = self.percentValues[self.percentIndex]

    self.percentLabel:setText(value .. "%")
end

--=====================================
-- MODELO DE POTIONS
--=====================================
function Healing.getAllPotions(vocationData)
    local list = {}

    if not vocationData or not vocationData.potions then
        return list
    end

    -- health
    for _, potion in ipairs(vocationData.potions.health or {}) do
        table.insert(list, {
            id = potion.id,
            name = potion.name,
            level = potion.level,
            type = "health"
        })
    end

    -- mana
    for _, potion in ipairs(vocationData.potions.mana or {}) do
        table.insert(list, {
            id = potion.id,
            name = potion.name,
            level = potion.level,
            type = "mana"
        })
    end

    return list
end

--==========================================
-- ON OFF
--==========================================
function Healing.toggle(helper)
    Healing.enabled = not Healing.enabled

    print("[Healing] Status:", Healing.enabled and "ON" or "OFF")

    if Healing.enabled then
        Healing.start(helper)
    else
        Healing.stop()
    end
end

-- =========================================
-- START
-- =========================================
function Healing.start(helper)
    if Healing.event then return end

    Healing.event = cycleEvent(function()

        if not Healing.enabled then return end

        local player = g_game.getLocalPlayer()
        if not player then return end

        local hp = (player:getHealth() / player:getMaxHealth()) * 100
        local mana = (player:getMana() / player:getMaxMana()) * 100

        -- 🔥 coleta slots válidos
        local validSlots = {}

        for i = 1, 3 do
            local slot = Healing.slots[i]
            local potion = Healing.getPotion(i)

            if slot and potion then
                local percent = helper.percentValues[slot.percentIndex or 1]

                table.insert(validSlots, {
                    slotId = i,
                    potion = potion,
                    percent = percent
                })
            end
        end

        -- 🔥 ordena por menor % (maior prioridade)
        table.sort(validSlots, function(a, b)
            return a.percent < b.percent
        end)

        -- 🔥 executa prioridade
        for _, data in ipairs(validSlots) do
            local potion = data.potion
            local percent = data.percent

            if potion.type == "health" and hp <= percent then
                g_game.useInventoryItemWith(potion.id, player)
                return
            end

            if potion.type == "mana" and mana <= percent then
                g_game.useInventoryItemWith(potion.id, player)
                return
            end
        end

    end, 1000)
end

-- =========================================
-- STOP
-- =========================================
function Healing.stop()
    if Healing.event then
        removeEvent(Healing.event)
        Healing.event = nil
    end
end
