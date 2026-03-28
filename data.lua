-- =========================================
-- HEALING DATA (POTIONS + SPELLS)
-- Estrutura base para todos os módulos
-- =========================================

HEALING_DATA = {

    -- =========================================
    -- KNIGHT
    -- =========================================
    knight = {
        potions = {
            health = {
                {id=266, name="Health Potion", level=1},
                {id=236, name="Strong Health Potion", level=50},
                {id=239, name="Great Health Potion", level=80},
                {id=7643, name="Ultimate Health Potion", level=130},
                {id=23375, name="Supreme Health Potion", level=200},
            },
            mana = {
                {id=268, name="Mana Potion", level=1},
                {id=237, name="Strong Mana Potion", level=50},
            }
        },

        spells = {
            {name="exura ico", level=8},
            {name="exura med ico", level=300},
            {name="exura gran ico", level=80},
        }
    },

    -- =========================================
    -- PALADIN
    -- =========================================
    paladin = {
        potions = {
            health = {
                {id=266, name="Health Potion", level=1},
                {id=236, name="Strong Health Potion", level=50},
                {id=239, name="Great Health Potion", level=80},
                {id=7642, name="Great Spirit Potion", level=80},
                {id=23374, name="Ultimate Spirit Potion", level=130},
            },
            mana = {
                {id=268, name="Mana Potion", level=1},
                {id=237, name="Strong Mana Potion", level=50},
                {id=238, name="Great Mana Potion", level=80},
                {id=7642, name="Great Spirit Potion", level=80},
                {id=23374, name="Ultimate Spirit Potion", level=130},
            }
        },

        spells = {
            {name="exura", level=8},
            {name="exura san", level=35},
            {name="exura gran san", level=60},
        }
    },

    -- =========================================
    -- DRUID
    -- =========================================
    druid = {
        potions = {
            health = {
                {id=266, name="Health Potion", level=1},
            },
            mana = {
                {id=268, name="Mana Potion", level=1},
                {id=237, name="Strong Mana Potion", level=50},
                {id=238, name="Great Mana Potion", level=80},
                {id=23373, name="Ultimate Mana Potion", level=130},
            }
        },

        spells = {
            {name="exura", level=8},
            {name="exura gran", level=20},
            {name="exura vita", level=30},
            {name="exura sio", level=20},
        }
    },

    -- =========================================
    -- SORCERER
    -- =========================================
    sorcerer = {
        potions = {
            health = {
                {id=266, name="Health Potion", level=1},
            },
            mana = {
                {id=268, name="Mana Potion", level=1},
                {id=237, name="Strong Mana Potion", level=50},
                {id=238, name="Great Mana Potion", level=80},
                {id=23373, name="Ultimate Mana Potion", level=130},
            }
        },

        spells = {
            {name="exura", level=8},
            {name="exura gran", level=20},
            {name="exura vita", level=30},
        }
    }
}
