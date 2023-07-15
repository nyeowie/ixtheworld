
if CLIENT then
    local staminaBarX = 20 -- move bar to left
    local staminaBarY = 20 -- move bar to top

    function DrawStaminaBar()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local stamina = ply:GetNWInt("Stamina", 0)
        local maxStamina = ply:GetNWInt("MaxStamina", 0)
        local staminaPercent = math.Clamp(stamina / maxStamina, 0, 1)


        local barWidth = 400
        local barHeight = 16
        local outlineThickness = 2

        local staminaPercent = ply:GetLocalVar("stm", 0) / 100

        if staminaPercent < 1 then
            -- Draw background with outline
            draw.RoundedBox(8, staminaBarX - outlineThickness, staminaBarY - outlineThickness, barWidth + outlineThickness * 2, barHeight + outlineThickness * 2, Color(0, 0, 0, 128))
            draw.RoundedBox(8, staminaBarX, staminaBarY, barWidth, barHeight, Color(0, 0, 0, 128))

            -- Draw stamina bar

            draw.RoundedBox(8, staminaBarX, staminaBarY, barWidth * staminaPercent, barHeight, Color(50, 50, 50, 256))
        end
    end


    hook.Add("HUDPaint", "DrawStaminaBar", DrawStaminaBar)
end

