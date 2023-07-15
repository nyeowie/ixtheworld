local BobbingSpeed = 4.5 
local BobbingAmount = 0.1 
local RollSmoothing = 0.2 

local rollAngle = 0
local pitchOffset = 0
local rollOffset = 0
local verticalBobbingAmount = 0.1
local customBobbingSpeed = 1.4

ix.config.Add("EnableViewBobbing", true, "Whether to enable viewbobbing", nil, {
    category = "View",
    server = true
})

hook.Add("CalcView", "ViewBobbingPlugin", function(ply, origin, angles, fov)
    local walkSpeed = ply:GetVelocity():Length()
    local bobbingOffset = math.sin(CurTime() * BobbingSpeed * customBobbingSpeed) * BobbingAmount
    local verticalBobbingOffset = math.sin(CurTime() * BobbingSpeed * 2 * customBobbingSpeed) * verticalBobbingAmount

    if ix.config.Get("EnableViewBobbing", true) then
        if ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) then
            rollAngle = Lerp(RollSmoothing, rollAngle, bobbingOffset * 3)

            pitchOffset = verticalBobbingOffset

            local rollDirection = ply:GetVelocity():Dot(angles:Right()) > 0 and 1 or -1
            rollOffset = math.cos(CurTime() * BobbingSpeed * customBobbingSpeed) * BobbingAmount * rollDirection
        else
            rollAngle = 0
            pitchOffset = 0
            rollOffset = 0
        end

        if walkSpeed < 30 then
            BobbingSpeed = 2
            BobbingAmount = 0.1
            verticalBobbingAmount = 0.1
            customBobbingSpeed = 1.2
        elseif walkSpeed > 100 then -- this shit is like, if your running and your walkspeed is like bigger than 100 just adjust the bobbing amount to make the running effect  
            BobbingSpeed = 4
            BobbingAmount = 0.2
            verticalBobbingAmount = 0.2
            customBobbingSpeed = 1.8
        else
            BobbingSpeed = 4.5
            BobbingAmount = 0.1
            verticalBobbingAmount = 0.1
            customBobbingSpeed = 1.4
        end

        angles.roll = angles.roll + rollAngle

        angles.pitch = angles.pitch + pitchOffset

        angles.roll = angles.roll + rollOffset
    end

    return {
        origin = origin,
        angles = angles,
        fov = fov
    }
end)

