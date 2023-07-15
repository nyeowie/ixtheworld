if SERVER then
    local breathSound = nil -- variable thingie to hold the breath sound object

    hook.Add("PlayerTick", "StaminaSoundPlugin", function(ply, mv)
        if ply:Alive() and ply:GetMoveType() ~= MOVETYPE_NOCLIP then
            local stamina = ply:GetLocalVar("stm", 0) / 100
            local isRunning = ply:IsRunning()

            if (stamina < 1 and isRunning) then
                local soundPath = "breath3.mp3"

                if ply:IsCombine() then
                    soundPath = "breath0gas.ogg"
                end

                if not IsValid(breathSound) or not breathSound:IsPlaying() and ply:GetMoveType() ~= MOVETYPE_NOCLIP then
                    breathSound = CreateSound(ply, soundPath)
                    breathSound:SetSoundLevel(0)
                    breathSound:PlayEx(0.5, 100)
                end
            elseif stamina > 0 or (isRunning and IsValid(breathSound) and breathSound:IsPlaying()) and ply:GetMoveType() ~= MOVETYPE_NOCLIP then
                if IsValid(breathSound) then
                    breathSound:Stop()
                end
            elseif stamina <= 0 then
                local soundPathh = "breath0.mp3" 
                if not IsValid(breathSound) or not breathSound:IsPlaying() then
                    breathSound = CreateSound(ply, soundPathh)
                    breathSound:SetSoundLevel(0)
                    breathSound:PlayEx(0.5, 100)
                end
            end
        end
    end)
end
