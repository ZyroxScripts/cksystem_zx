-- Handle CK confirmation dialog
RegisterNetEvent('cksystem:showConfirmation', function(adminId)
    local alert = lib.alertDialog({
        header = _U('ck_confirmation_title'),
        content = _U('ck_confirmation_message'),
        centered = true,
        cancel = true,
        labels = {
            confirm = _U('yes'),
            cancel = _U('no')
        }
    })

    if alert == 'confirm' then
        TriggerServerEvent('cksystem:confirmCK', adminId, true)
    else
        TriggerServerEvent('cksystem:confirmCK', adminId, false)
    end
end)
