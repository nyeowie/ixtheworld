PLUGIN.name = "Keyhole View"
PLUGIN.author = "enaruu"
PLUGIN.description = "Allows players to look through door keyholes."


PLUGIN.isEnabled = true


PLUGIN.command = "keyhole"

--[ [ THIS CODE IS NOT STABLE, IF YOU ARE GOING TO USE IT THEN YOU HAVE TO HEAVILY MODIFY IT. ] ]--

if SERVER then
    util.AddNetworkString("KeyholeViewStart")
    util.AddNetworkString("KeyholeViewEnd")

    function PLUGIN:KeyPress(player, key)
        if player:GetViewEntity():IsDoor() and key ~= IN_USE then
            net.Start("KeyholeViewEnd")
            net.Send(player)

            player:SetViewEntity(nil)

            if player.KeyholeViewOriginalPos then
                player:SetPos(player.KeyholeViewOriginalPos)
                player.KeyholeViewOriginalPos = nil
            end
        end
    end

    net.Receive("KeyholeViewStart", function(len, ply)
        if IsValid(ply) then
            local trace = ply:GetEyeTrace()

            if IsValid(trace.Entity) and trace.Entity:IsDoor() then
                local door = trace.Entity

                if door:HasSpawnFlags(256) then
                    if ply:GetPos():DistToSqr(door:GetPos()) <= 10000 then
                        ply:SetEyeAngles((door:WorldSpaceCenter() - ply:GetShootPos()):Angle())
                        ply:SetViewEntity(door)

                        ply.KeyholeViewOriginalPos = ply:GetPos()
                    end
                end
            end
        end
    end)

else
    if CLIENT then
        local keyHoldStartTime = 0
        local keyHoldDuration = 2
        local keyHoldColor = Color(0, 0, 255) -- Blue coloooooooooooo
        local hasShownKeyholeView = false

        surface.CreateFont("KeyholeFont", {
            font = "Arial",
            size = 60,
            weight = 500,
            antialias = true,
            additive = false,
        })

        surface.CreateFont("KeyholeFontSmall", {
            font = "Arial", 
            size = 30,
            weight = 500,
            antialias = true,
            additive = false,
        })

        function PLUGIN:HUDPaint()
            local ply = LocalPlayer()
            local trace = ply:GetEyeTrace()

            if IsValid(trace.Entity) and trace.Entity:IsDoor() then
                local door = trace.Entity
                local doorPos = door:GetPos()
                local doorMin, doorMax = door:GetCollisionBounds()

                local doorCenter = doorPos + (doorMax + doorMin) / 2

                local doorCenterScreen = doorCenter:ToScreen()

               
                local panelWidth = 70
                local panelHeight = 70
                local panelX = doorCenterScreen.x - panelWidth / 2
                local panelY = doorCenterScreen.y - panelHeight / 2

                local distance = ply:EyePos():Distance(doorPos)

                if distance <= 100 then 
                    local progress = 0
                    if input.IsKeyDown(KEY_K) then
                        local holdTime = RealTime() - keyHoldStartTime
                        progress = math.Clamp(holdTime / keyHoldDuration, 0, 1)
                    else
                        keyHoldStartTime = RealTime()
                    end

                    local currentColor = Color(
                        Lerp(progress, 0, keyHoldColor.r),
                        Lerp(progress, 0, keyHoldColor.g),
                        Lerp(progress, 0, keyHoldColor.b)
                    )

                    surface.SetDrawColor(currentColor.r, currentColor.g, currentColor.b, 180)
                    surface.DrawRect(panelX, panelY, panelWidth, panelHeight)

                    if progress == 1 and currentColor == keyHoldColor then
                        if not hasShownKeyholeView then
                            hasShownKeyholeView = true

                            net.Start("KeyholeViewStart")
                            net.SendToServer()

                            hasShownKeyholeView = false
                        end
                    else
                        surface.SetFont("KeyholeFont")
                        local text = "Press K to look under the keyhole"
                        local textWidth, textHeight = surface.GetTextSize(text)
                        local textX = panelX + panelWidth / 2
                        local textY = panelY + panelHeight / 2 + 25 - textHeight / 2 + 5

                        draw.SimpleText("K", "KeyholeFont", textX, textY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        draw.SimpleText(text, "KeyholeFontSmall", textX, textY + textHeight + 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                end
            end
        end






        net.Receive("KeyholeViewStart", function()
            print("received")
            local player = net.ReadEntity()

            if IsValid(player) then
                local trace = player:GetEyeTrace()

                if IsValid(trace.Entity) and trace.Entity:IsDoor() then
                    local door = trace.Entity

                    if door:HasSpawnFlags(256) then
                        if player:GetPos():DistToSqr(door:GetPos()) <= 10000 then
                            local doorAngles = door:GetAngles()
                            local keyholePosition = door:WorldToLocal(door:WorldSpaceCenter()) + Vector(0, 0, -5)
                            keyholePosition:Rotate(doorAngles)

                            local playerPosition = door:LocalToWorld(keyholePosition + Vector(0, 0, 5))

                            player:SetPos(playerPosition)
                            player:SetEyeAngles((door:WorldSpaceCenter() - player:GetShootPos()):Angle())
                        end
                    end
                end
            end
        end)
    end
end
