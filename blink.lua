if SERVER then return end 

local progress = 30 
local blinkDuration = 1 
local fadeDuration = 0.2 

local screenWidth = ScrW()
local screenHeight = ScrH()

surface.CreateFont("CourierNewFont", {
    font = "Courier New",
    size = 15,
    weight = 500,
    antialias = true,
    additive = false,
    blursize = 0,
    scanlines = 0,
    outline = false,
})

local textPanel = vgui.Create("DPanel")
textPanel:SetSize(screenWidth * 0.1, screenHeight * 0.05)
textPanel:SetPos(screenWidth * 0.01, screenHeight - textPanel:GetTall())
textPanel.Paint = function(self, w, h)
    draw.SimpleText("Next Blink: " .. progress .. "s", "CourierNewFont", w * 0.05, h * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end


local blackScreen = vgui.Create("DPanel")
blackScreen:SetSize(screenWidth, screenHeight)
blackScreen:SetPos(0, 0)
blackScreen:SetAlpha(0)
blackScreen.Paint = function(self, w, h)
    local alpha = self:GetAlpha()
    surface.SetDrawColor(0, 0, 0, alpha)
    surface.DrawRect(0, 0, w, h)
end
blackScreen:SetVisible(false)


local function UpdateProgress()
    progress = progress - 1
    if progress <= 0 then
        progress = 0
        blackScreen:SetVisible(true)
        blackScreen:AlphaTo(255, fadeDuration, 0, function()
            timer.Simple(blinkDuration, function()
                blackScreen:AlphaTo(0, fadeDuration, 0, function()
                    blackScreen:SetVisible(false)
                    progress = 30 
                end)
            end)
        end)
    end
    textPanel:InvalidateLayout()
end

timer.Create("BlinkingProgress", 1, 0, UpdateProgress)
