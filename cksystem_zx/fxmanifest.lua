fx_version 'cerulean'
game 'gta5'

author 'Zyrox'
description 'CK System - Character Kill System for ESX & QB-Core'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'localization.lua',
    'locales/*.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'ox_lib',
    'oxmysql'
}

lua54 'yes'
