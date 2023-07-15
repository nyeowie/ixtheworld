if SERVER then
    local breathSounds = {
        ["default"] = {
            "jump1.mp3",
            "jump2.mp3",
            "jump3.mp3",
            "jump4.mp3",
            "jump5.mp3"
        },
        ["combine"] = {
            "breath1gas.ogg",
            "breath2gas.ogg",
            "breath3gas.ogg",
            "breath4gas.ogg"
        }
    }

    local jumpCooldown = {}

    hook.Add("KeyPress", "JumpBreathsPlugin", function(ply, key)
        if key == IN_JUMP and ply:Alive() and ply:IsOnGround() and (not jumpCooldown[ply] or jumpCooldown[ply] <= CurTime()) and ply:GetMoveType() ~= MOVETYPE_NOCLIP then
            local chance = math.random(1, 10)

            local soundCategory = ply:IsCombine() and "combine" or "default"
            local breathSound = breathSounds[soundCategory]

            if chance <= 4 then
                ply:EmitSound(breathSound[1])
            elseif chance <= 1 then
                ply:EmitSound(breathSound[5])    
            elseif chance <= 7 then
                ply:EmitSound(breathSound[2])
            elseif chance <= 9 then
                ply:EmitSound(breathSound[3])
            else 
                ply:EmitSound(breathSound[4])
            end

            jumpCooldown[ply] = CurTime() + 1
        end
    end)

    hook.Add("OnLand", "JumpBreathsPlugin", function(ply, water, vec)
        if ply:Alive() and ply:IsOnGround() and (not jumpCooldown[ply] or jumpCooldown[ply] <= CurTime()) then
            local chance = math.random(1, 10)

            local soundCategory = ply:IsCombine() and "combine" or "default"
            local breathSound = breathSounds[soundCategory]

            if chance <= 4 then
                ply:EmitSound(breathSound[1])
            elseif chance <= 7 then 
                ply:EmitSound(breathSound[2])
            elseif chance <= 9 then 
                ply:EmitSound(breathSound[3])
            else 
                ply:EmitSound(breathSound[4])
            end

            jumpCooldown[ply] = CurTime() + 1 
        end
    end)
end
