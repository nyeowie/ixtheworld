if SERVER then
    util.AddNetworkString("Ann_OpenMenu")

    concommand.Add("breen_console", function(ply)
        net.Start("Ann_OpenMenu")
        net.Send(ply)
    end)
end

surface.CreateFont("CourierNewFont", {
    font = "Courier New",
    size = 16,
    weight = 500,
    antialias = true,
    additive = false,
    blursize = 0,
    scanlines = 0,
    outline = false,
})


local function ShowSubtitle(text)
    local subtitlePanel = vgui.Create("DPanel")
    subtitlePanel:SetSize(ScrW(), 30)
    subtitlePanel:CenterHorizontal()
    subtitlePanel:SetPos(subtitlePanel:GetPos(), ScrH() - subtitlePanel:GetTall() - 40)
    subtitlePanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 40, 0))
    end

    local subtitleLabel = vgui.Create("DLabel", subtitlePanel)
    subtitleLabel:SetText("")
    subtitleLabel:SetFont("CourierNewFont")
    subtitleLabel:SetTextColor(Color(220, 220, 220))
    subtitleLabel:SetContentAlignment(5)
    subtitleLabel:SetWide(subtitlePanel:GetWide())

    local currentIndex = 0
    local typingDelay = 0.05 

    local function UpdateSubtitle()
        currentIndex = currentIndex + 1
        local displayedText = string.sub(text, 1, currentIndex)
        subtitleLabel:SetText(displayedText)

        
        local textWidth = surface.GetTextSize(displayedText)
        if textWidth > subtitlePanel:GetWide() then
            subtitleLabel:SetText("") 
            currentIndex = 1 


            local maxCharPerLine = math.floor(subtitlePanel:GetWide() / surface.GetTextSize("W"))


            local wrapIndex = currentIndex + maxCharPerLine - 1
            displayedText = string.sub(text, currentIndex, wrapIndex)
            subtitleLabel:SetText(displayedText)


            currentIndex = wrapIndex + 1
        end

        if currentIndex < #text then
            timer.Simple(typingDelay, UpdateSubtitle)
        else
            local textDuration = #text * typingDelay
            timer.Simple(5 + textDuration, function()
                if IsValid(subtitlePanel) then
                    subtitlePanel:Remove()
                end
            end)
        end
    end


    timer.Simple(typingDelay, UpdateSubtitle)
end




if CLIENT then
    local soundQueue = {} 
    local isSoundPlaying = false

    local function PlayNextSound()
        if not isSoundPlaying and #soundQueue > 0 then
            isSoundPlaying = true
            local soundData = table.remove(soundQueue, 1)
            surface.PlaySound(soundData.path)
            ShowSubtitle(soundData.subtitleText) 
            timer.Simple(soundData.duration, function()
                isSoundPlaying = false
                PlayNextSound()
            end)
        end
    end


    net.Receive("Ann_OpenMenu", function()
        local frame = vgui.Create("DFrame")
        frame:SetSize(ScrW() * 0.8, ScrH() * 0.8)
        frame:Center()
        frame:SetTitle("")
        frame:SetVisible(true)
        frame:SetDraggable(false)
        frame:ShowCloseButton(false)
        frame.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40))
        end

        local closeButton = vgui.Create("DButton", frame)
        closeButton:SetText("X")
        closeButton:SetPos(frame:GetWide() - 30, 5)
        closeButton:SetSize(20, 20)
        closeButton:SetTextColor(Color(220, 220, 220))
        closeButton.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(70, 70, 70))
        end
        closeButton.DoClick = function()
            frame:Close()
        end

        local title = vgui.Create("DLabel", frame)
        title:SetText("Announcement Terminal")
        title:SetFont("DermaLarge")
        title:SetTextColor(Color(220, 220, 220))
        title:SizeToContents()
        title:SetPos(frame:GetWide() * 0.5 - title:GetWide() * 0.5, 10)

        local buttonPanel = vgui.Create("DScrollPanel", frame)
        buttonPanel:SetSize(frame:GetWide() - 20, frame:GetTall() - 70)
        buttonPanel:SetPos(10, 40)

        local buttonLayout = vgui.Create("DIconLayout", buttonPanel)
        buttonLayout:Dock(FILL)
        buttonLayout:SetSpaceY(5)

        local addButton = function(text, soundPath, subtitleText)
            local buttonContainer = vgui.Create("DPanel")
            buttonContainer:SetSize(buttonPanel:GetWide(), 60)
            buttonContainer.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, Color(60, 60, 60))
            end

            local buttonTitle = vgui.Create("DLabel", buttonContainer)
            buttonTitle:SetText(text)
            buttonTitle:SetFont("DermaDefaultBold")
            buttonTitle:SetTextColor(Color(220, 220, 220))
            buttonTitle:SizeToContents()
            buttonTitle:SetPos(10, buttonContainer:GetTall() * 0.5 - buttonTitle:GetTall() * 0.5)

            local button = vgui.Create("DButton", buttonContainer)
            button:SetSize(100, 30)
            button:SetPos(buttonContainer:GetWide() - button:GetWide() - 10, buttonContainer:GetTall() * 0.5 - button:GetTall() * 0.5)
            button:SetText("Play")
            button:SetTextColor(Color(220, 220, 220))
            button.DoClick = function()
                local soundData = {
                    path = soundPath,
                    duration = SoundDuration(soundPath),
                    subtitleText = subtitleText 
                }
                table.insert(soundQueue, soundData) 
                PlayNextSound() 
            end


            buttonLayout:Add(buttonContainer)
        end

        addButton("MTF Arrive", "Announc.ogg", "Mobile Task Force Unit Epsilon-11, designated Nine-Tailed Fox, has entered the facility. All remaining survivors are advised to stay in the evacuation shelter or any other safe area until the unit has secured the facility.")
        addButton("049 Contained", "Announc049Contain.ogg", "SCP-049 contained successfully by Foxtrot Unit 2")
        addButton("096 Contained", "Announc096Contain.ogg", "SCP-096 contained successfully by Foxtrot Unit 2")
        addButton("106 Contained", "Announc106Contain.ogg", "SCP-106 contained successfully by Foxtrot Unit 1.")
        addButton("173 Contained", "Announc173Contain.ogg", "SCP-173 contained successfully by Foxtrot Unit 1.")
        addButton("939 Contained", "Announc939Contain.ogg", "SCP-939 specimens 1 through 4 has been contained successfully by Foxtrot Unit 3.")
        addButton("966 Contained", "Announc966Contain.ogg", "All SCP-966 specimens has been contained successfully by Foxtrot Unit 3.")
        addButton("After 1", "AnnouncAfter1.ogg", "We'd like to advise all surviving personnel, once again: do not attempt to reach the exits. Either find a safe area or go into one of the many evacuation shelters inside the facility.")
        addButton("After 2", "AnnouncAfter2.ogg", "An announcement to all personnel: The lift to Gate B has been locked down to ensure the safety of the upper areas of the facility. Please remember to stay inside the evacuation shelters until the facility has been secured.")
        addButton("All Contained", "AnnouncAllContain.ogg", "Mobile Task Force Nine-Tailed Fox and Secondary Security Force would clear in have secured all remaining hostile SCPs inside the facility. All personnel are still advised to remain secure until any remaining threats have been neutralized.")
        addButton("Camera Check", "AnnouncCameraCheck.ogg", "Control to Nine-Tailed Fox: We are now checking the camera feeds for potential threats. You should see any unauthorized intruders or escapees pinged on your navigation devices.")
        addButton("Camera Found 1", "AnnouncCameraFound1.ogg", "Control to Nine-Tailed Fox: Camera scan complete. Multiple stragglers their positions are now being broadcasted to you.")
        addButton("Camera Found 2", "AnnouncCameraFound2.ogg", "Control to Nine-Tailed Fox: Camera scan complete. Only a single Class-D remains.")
        addButton("Camera Not Found", "AnnouncCameraNoFound.ogg", "Control to Nine-Tailed Fox: Camera scan complete. No signs of unauthorized survivors, over.")


        local scrollBar = buttonPanel:GetVBar()
        scrollBar:SetWide(10)
        function scrollBar:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(80, 80, 80))
        end
        function scrollBar.btnUp:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(60, 60, 60))
        end
        function scrollBar.btnDown:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(60, 60, 60))
        end
        function scrollBar.btnGrip:Paint(w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(100, 100, 100))
        end

        frame:MakePopup()
    end)
end
