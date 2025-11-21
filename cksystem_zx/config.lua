Config = {}

-- Framework detection (auto-detect ESX or QB-Core)
Config.Framework = 'auto' -- 'esx', 'qb', or 'auto'

-- Permissions
Config.AllowedGroups = {
    'admin',
    'superadmin',
    'mod',
    'moderator'
}

-- Permissions for instant CK (without confirmation)
Config.AllowedGroupsInsta = {
    'superadmin'
}

-- Database settings
Config.Database = {
    ESX = {
        table = 'users',
        identifier_column = 'identifier'
    },
    QB = {
        table = 'players',
        identifier_column = 'citizenid'
    }
}

-- Locale
Config.Locale = 'en' -- Available: cs, en, de, es, fr
