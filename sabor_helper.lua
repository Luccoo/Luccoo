-- =========================================
-- SABOR HELPER (UI / MODAL ONLY)
-- =========================================

SaborHelper = Controller:new()

-- carrega sistema
dofile("healing/healing.lua")

-- =========================================
-- MAPA DE VOCAÇÕES (CLIENT ID)
-- =========================================
SaborHelper.VOCATION_MAP = {
    [3] = "sorcerer",
    [4] = "druid",
    [2] = "paladin",
    [1] = "knight",

    [13] = "sorcerer",
    [14] = "druid",
    [12] = "paladin",
    [11] = "knight"
}

-- =========================================
-- TABS (VISUAL)
-- =========================================
SaborHelper.cave    = { clip = { x=0, y=0, width=108, height=20 } }
SaborHelper.combat  = { clip = { x=0, y=0, width=108, height=20 } }
SaborHelper.healing = { clip = { x=0, y=0, width=108, height=20 } }
SaborHelper.support = { clip = { x=0, y=0, width=108, height=20 } }

SaborHelper.arrowLeft  = { clip = { x=0, y=0, width=10, height=34 } }
SaborHelper.arrowRight = { clip = { x=0, y=0, width=10, height=34 } }

SaborHelper.healingToggle = { clip = { x=0, y=0, width=30, height=15 } }

SaborHelper.currentTab = "healing"

SaborHelper.healing.clip = { x=0, y=20, width=108, height=20 }

-- =========================================
-- INIT
-- =========================================
function SaborHelper:onInit()
    self.cave.clip    = { x=0, y=0, width=108, height=20 }
    self.combat.clip  = { x=0, y=0, width=108, height=20 }
    self.healing.clip = { x=0, y=0, width=108, height=20 }
    self.support.clip = { x=0, y=0, width=108, height=20 }

	self.arrowpercentLeft  = { clip = { x=0, y=0, width=10, height=34 } }
	self.arrowpercentRight = { clip = { x=0, y=0, width=10, height=34 } }

    -- 🔥 ADICIONA ISSO
    self.percentIndex = 1
    self.percentValues = {}

    for i = 0, 99 do
        table.insert(self.percentValues, i)
    end
end

-- =========================================
-- VOCAÇÃO
-- =========================================
function SaborHelper:updateVocation()
    local player = g_game.getLocalPlayer()

    if not player then
        self.vocation = "none"
        return
    end

    local voc = nil

    if player.getVocation then
        voc = player:getVocation()
    elseif player.getVocationId then
        voc = player:getVocationId()
    end

    self.vocation = self.VOCATION_MAP[voc] or "none"

    print("[SaborHelper] Voc:", self.vocation)
end

-- =========================================
-- SHOW UI
-- =========================================
function SaborHelper:show()
    if not self.ui or self.ui:isDestroyed() then
        self:loadHtml('sabor_helper.html')
    end

    if not self.ui then return end
	
    self.ui:show()
    self.ui:raise()
    self.ui:focus()
    self:updateHealingButton()
	
    -- 🔥 GARANTE ESTADO AQUI (ESSENCIAL)
    if not self.percentValues then
        self.percentIndex = 1
        self.percentValues = {}

        for i = 0, 99 do
            table.insert(self.percentValues, i)
        end
    end
	
	scheduleEvent(function()

    local player = g_game.getLocalPlayer()
    if not player then return end

    self:updateVocation()

    local level = player:getLevel()
    local voc   = self.vocation

    Healing.load(voc, level)

    -- 🔥 PEGA O LABEL AQUI (DEPOIS DA UI EXISTIR)
    self.percentLabel = self.ui:recursiveGetChildById("healingPercentLabel")

    print("Label capturado:", self.percentLabel)

    self:updateHealingUI()
    self:updatepercentUI()

end, 300)
end

-- =========================================
-- HIDE / TOGGLE
-- =========================================
function SaborHelper:hide()
    if self.ui then
        self.ui:hide()
	end
end

function SaborHelper:toggle()
    if not self.ui then
        self:show()
        return
    end

    if self.ui:isVisible() then
        self:hide()
    else
        self:show()
    end
end

function SaborHelper:toggleHealing()
    Healing.toggle(self)
    self:updateHealingButton()
end

-- =========================================
-- TABS
-- =========================================
function SaborHelper:resetTabsClip()
    self.cave.clip    = { x=0, y=0, width=108, height=20 }
    self.combat.clip  = { x=0, y=0, width=108, height=20 }
    self.healing.clip = { x=0, y=0, width=108, height=20 }
    self.support.clip = { x=0, y=0, width=108, height=20 }
end

function SaborHelper:toggleCaveBotMenu()
    self:resetTabsClip()
    self.currentTab = "cave"
    self.cave.clip = { x=0, y=20, width=108, height=20 }
end

function SaborHelper:toggleCombatMenu()
    self:resetTabsClip()
    self.currentTab = "combat"
    self.combat.clip = { x=0, y=20, width=108, height=20 }
end

function SaborHelper:toggleHealingMenu()
    self:resetTabsClip()
    self.currentTab = "healing"
    self.healing.clip = { x=0, y=20, width=108, height=20 }

    if healingTab then healingTab:show() end
    if supportTab then supportTab:hide() end
    if combatTab then combatTab:hide() end
    if caveTab then caveTab:hide() end

    -- 🔥 ESPERA UI EXISTIR
    scheduleEvent(function()
        self.percentLabel = self.ui:recursiveGetChildById("healingPercentLabel")
        self.healingSlot  = self.ui:recursiveGetChildById("healingPotionSlot")

        print("Label novo:", self.percentLabel)

        self:updatepercentUI()
        self:updateHealingUI()
		
    end, 50)
end

function SaborHelper:toggleSupportMenu()
    self:resetTabsClip()
    self.currentTab = "support"
    self.support.clip = { x=0, y=20, width=108, height=20 }
end

function SaborHelper:updateHealingButton()
    if not self.healingToggle then return end

    if Healing.enabled then
        self.healingToggle.clip = { x=0, y=15, width=30, height=15 } -- ON
    else
        self.healingToggle.clip = { x=0, y=0, width=30, height=15 } -- OFF
    end
end

-- =========================================
-- INPUT (CHAMADO PELO HTML)
-- =========================================

-- POTION
function SaborHelper:onNextPotionDown()
    self:startNextPotion()
end

function SaborHelper:onNextPotionUp()
    self:stopScroll()
end

function SaborHelper:onPrevPotionDown()
    self:startPrevPotion()
end

function SaborHelper:onPrevPotionUp()
    self:stopScroll()
end

-- percent %
function SaborHelper:onNextpercentDown()
    self:startNextpercent()
end

function SaborHelper:onNextpercentUp()
    self:stoppercentScroll()
end

function SaborHelper:onPrevpercentDown()
    self:startPrevpercent()
end

function SaborHelper:onPrevpercentUp()
    self:stoppercentScroll()
end

-- =========================================
-- INIT GLOBAL
-- =========================================
function initSaborHelper()
    print("Sabor Helper carregado!")

    G.toggleSaborHelper = function()
        SaborHelper:toggle()
    end
end
