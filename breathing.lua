local particleCount = 5
local spawnInterval = 7
local particleDelay = 0.1

local function CreateSmokeParticle(ply)
    local mouthOffset = Vector(0, 0, -2.5)
    local mouthPos = ply:EyePos() + ply:EyeAngles():Forward() * 8 + mouthOffset
    local mouthDir = ply:EyeAngles():Forward()

    local success, particle = pcall(function()
        return ParticleEmitter(mouthPos):Add("particle/particle_smokegrenade1", mouthPos)
    end)
    if success then
        particle:SetVelocity(mouthDir * 15)
        particle:SetDieTime(0.4)
        particle:SetStartAlpha(255) 
        particle:SetEndAlpha(0) 
        particle:SetStartSize(3) 
        particle:SetEndSize(3) 
        particle:SetGravity(Vector(0, 0, 50)) 
        particle:SetCollide(true) 
        particle:SetBounce(0.5) 
    end
end


local function PlayRadioChatter(ply)
    if ply:Team() == FACTION_CITIZEN and ply:GetMoveType() ~= MOVETYPE_NOCLIP then
        if IsValid(ply.radioChatterSound) and ply.radioChatterSound:IsPlaying() then
            return 
        end

        local soundPaths = {
            "breathing.mp3",
            "breathing2.mp3"
        }
        local randomSoundPath = soundPaths[math.random(1, #soundPaths)]

        local soundLevel = 100

        ply.radioChatterSound = CreateSound(ply, randomSoundPath)
        ply.radioChatterSound:SetSoundLevel(soundLevel)
        ply.radioChatterSound:PlayEx(1, 100, 0, true) 

        for i = 1, particleCount do
            timer.Simple(i * particleDelay, function()
                if IsValid(ply) and ply:Alive() then
                    CreateSmokeParticle(ply)
                end
            end)
        end

        timer.Simple(SoundDuration(randomSoundPath), function()
            if IsValid(ply) and IsValid(ply.radioChatterSound) then
                ply.radioChatterSound:Stop()
                ply.radioChatterSound = nil
                timer.Simple(10, function()
                    if IsValid(ply) then
                        PlayRadioChatter(ply)
                    end
                end)
            end
        end)
    end
end


hook.Add("PlayerInitialSpawn", "CombineRadioChatter", function(ply)
    timer.Simple(5, function()
        PlayRadioChatter(ply)
    end)
end)

hook.Add("Think", "SmokeEffect", function()
    for _, ply in ipairs(player.GetAll()) do
        if ply:Alive() then
            if not ply.SmokeEffectTime or CurTime() - ply.SmokeEffectTime >= spawnInterval then
                PlayRadioChatter(ply)
                ply.SmokeEffectTime = CurTime()
            end
        end
    end
end)