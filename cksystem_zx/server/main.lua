local ESX = nil
local QBCore = nil
local Framework = nil

-- Framework detection
CreateThread(function()
    if Config.Framework == 'auto' then
        if GetResourceState('es_extended') == 'started' then
            ESX = exports['es_extended']:getSharedObject()
            Framework = 'ESX'
            print('^2[CK-System]^7 ESX Framework detected')
        elseif GetResourceState('qb-core') == 'started' then
            QBCore = exports['qb-core']:GetCoreObject()
            Framework = 'QB'
            print('^2[CK-System]^7 QB-Core Framework detected')
        else
            print('^1[CK-System]^7 No supported framework found!')
        end
    elseif Config.Framework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
        Framework = 'ESX'
    elseif Config.Framework == 'qb' then
        QBCore = exports['qb-core']:GetCoreObject()
        Framework = 'QB'
    end
end)

-- Function to check if player has permission
local function HasPermission(source)
    if Framework == 'ESX' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return false end
        
        for _, group in pairs(Config.AllowedGroups) do
            if xPlayer.getGroup() == group then
                return true
            end
        end
    elseif Framework == 'QB' then
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return false end
        
        for _, group in pairs(Config.AllowedGroups) do
            if QBCore.Functions.HasPermission(source, group) then
                return true
            end
        end
    end
    return false
end

-- Function to check if player has instant CK permission
local function HasInstaPermission(source)
    if Framework == 'ESX' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return false end
        
        for _, group in pairs(Config.AllowedGroupsInsta) do
            if xPlayer.getGroup() == group then
                return true
            end
        end
    elseif Framework == 'QB' then
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return false end
        
        for _, group in pairs(Config.AllowedGroupsInsta) do
            if QBCore.Functions.HasPermission(source, group) then
                return true
            end
        end
    end
    return false
end

-- Function to get player identifier
local function GetPlayerIdentifier(source)
    if Framework == 'ESX' then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer and xPlayer.identifier or nil
    elseif Framework == 'QB' then
        local Player = QBCore.Functions.GetPlayer(source)
        return Player and Player.PlayerData.citizenid or nil
    end
    return nil
end

-- Function to delete character from database
local function DeleteCharacter(targetId, callback)
    local identifier = GetPlayerIdentifier(targetId)
    if not identifier then
        callback(false, 'player_not_found')
        return
    end

    local dbConfig = Framework == 'ESX' and Config.Database.ESX or Config.Database.QB
    
    MySQL.query('DELETE FROM ' .. dbConfig.table .. ' WHERE ' .. dbConfig.identifier_column .. ' = ?', {
        identifier
    }, function(result)
        if result.affectedRows > 0 then
            callback(true, 'success')
        else
            callback(false, 'database_error')
        end
    end)
end

-- CK Command
RegisterCommand('ck', function(source, args, rawCommand)
    if not HasPermission(source) then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = _U('no_permission')
        })
        return
    end

    if not args[1] then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = _U('invalid_usage')
        })
        return
    end

    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = _U('invalid_player_id')
        })
        return
    end

    local targetPlayer = GetPlayerPed(targetId)
    if not targetPlayer or targetPlayer == 0 then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = _U('player_not_online')
        })
        return
    end

    -- Send confirmation to target player
    TriggerClientEvent('cksystem:showConfirmation', targetId, source)
    
    -- Notify admin
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'info',
        description = _U('ck_request_sent', GetPlayerName(targetId))
    })
end, false)

-- Handle CK confirmation response
RegisterNetEvent('cksystem:confirmCK', function(adminId, confirmed)
    local source = source
    
    if confirmed then
        -- Delete character
        DeleteCharacter(source, function(success, reason)
            if success then
                -- Notify admin
                TriggerClientEvent('ox_lib:notify', adminId, {
                    type = 'success',
                    description = _U('ck_success', GetPlayerName(source))
                })
                
                -- Notify target player
                TriggerClientEvent('ox_lib:notify', source, {
                    type = 'info',
                    description = _U('character_deleted')
                })
                
                -- Kick player after short delay
                SetTimeout(3000, function()
                    DropPlayer(source, _U('character_deleted_kick'))
                end)
            else
                TriggerClientEvent('ox_lib:notify', adminId, {
                    type = 'error',
                    description = _U('ck_failed', reason)
                })
            end
        end)
    else
        -- Notify admin that player declined
        TriggerClientEvent('ox_lib:notify', adminId, {
            type = 'warning',
            description = _U('ck_declined', GetPlayerName(source))
        })
    end
end)

-- CK Instant Command (without confirmation)
RegisterCommand('ckinsta', function(source, args, rawCommand)
    if not HasInstaPermission(source) then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = _U('no_permission_insta')
        })
        return
    end

    if not args[1] then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = _U('invalid_usage_insta')
        })
        return
    end

    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = _U('invalid_player_id')
        })
        return
    end

    local targetPlayer = GetPlayerPed(targetId)
    if not targetPlayer or targetPlayer == 0 then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = _U('player_not_online')
        })
        return
    end

    -- Delete character instantly without confirmation
    DeleteCharacter(targetId, function(success, reason)
        if success then
            -- Notify admin
            TriggerClientEvent('ox_lib:notify', source, {
                type = 'success',
                description = _U('ck_insta_success', GetPlayerName(targetId))
            })
            
            -- Notify target player
            TriggerClientEvent('ox_lib:notify', targetId, {
                type = 'info',
                description = _U('character_deleted')
            })
            
            -- Kick player after short delay
            SetTimeout(3000, function()
                DropPlayer(targetId, _U('character_deleted_kick'))
            end)
        else
            TriggerClientEvent('ox_lib:notify', source, {
                type = 'error',
                description = _U('ck_failed', reason)
            })
        end
    end)
end, false)

print('^2[CK-System]^7 Successfully loaded by ^3Zyrox^7')
