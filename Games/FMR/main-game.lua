local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local noclipConnection = nil
local camLoopConnection = nil
local camToggleState = false

local origBrightness = Lighting.Brightness
local origClockTime = Lighting.ClockTime
local origFogEnd = Lighting.FogEnd
local origGlobalShadows = Lighting.GlobalShadows

local function GetDoorCode()
    local map = workspace:FindFirstChild("MAP")
    if not map then return "Not Found" end
    local rewards = map:FindFirstChild("Rewards")
    if not rewards then return "Not Found" end
    local keypad = rewards:FindFirstChild("BasementKeypad")
    if not keypad then return "Not Found" end
    local mainCL = keypad:FindFirstChild("Main_CL")
    if not mainCL then return "Not Found" end

    for _, v in pairs(getgc()) do
        if type(v) == "function" and islclosure(v) and getfenv(v).script == mainCL then
            local upvals = getupvalues(v)
            for _, up in pairs(upvals) do
                if type(up) == "table" and #up == 4 and type(up[1]) == "number" then
                    return table.concat(up, " ")
                end
            end
        end
    end
    return "Not Found"
end

local function FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

local function SetWalkSpeed(value)
    if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
        localPlayer.Character.Humanoid.WalkSpeed = value
    end
end

local function SetJumpPower(value)
    if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
        localPlayer.Character.Humanoid.UseJumpPower = true
        localPlayer.Character.Humanoid.JumpPower = value
    end
end

local function SetFullbright(state)
    if state then
        origBrightness = Lighting.Brightness
        origClockTime = Lighting.ClockTime
        origFogEnd = Lighting.FogEnd
        origGlobalShadows = Lighting.GlobalShadows

        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = origBrightness
        Lighting.ClockTime = origClockTime
        Lighting.FogEnd = origFogEnd
        Lighting.GlobalShadows = origGlobalShadows
    end
end

local function SetNoclip(state)
    if state then
        noclipConnection = RunService.Stepped:Connect(function()
            local character = localPlayer.Character
            if character then
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end

local function SetInterfaceSpoof(selected)
    if not localPlayer then return end

    local value = 1
    if selected == "Mobile" then
        value = 3
    elseif selected == "PC" then
        value = 1
    elseif selected == "Console" then
        value = 2
    end

    local inputTypeObj = localPlayer:FindFirstChild("InputType")
    if inputTypeObj then
        if inputTypeObj:IsA("ValueBase") then
            inputTypeObj.Value = value
        else
            pcall(function()
                localPlayer.InputType = value
            end)
        end
    else
        pcall(function()
            localPlayer.InputType = value
        end)
    end
end

local function SetCamsGuiEnabled(state)
    camToggleState = state
    
    if camLoopConnection then
        camLoopConnection:Disconnect()
        camLoopConnection = nil
    end

    if state then
        camLoopConnection = RunService.Heartbeat:Connect(function()
            if localPlayer then
                local playerGui = localPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    local camSystem = playerGui:FindFirstChild("CamSystem")
                    if camSystem and camSystem:IsA("ScreenGui") then
                        if not camSystem.Enabled and camToggleState then
                            camSystem.Enabled = true
                        end
                    end
                end
            end
        end)
    else
        if localPlayer then
            local playerGui = localPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                local camSystem = playerGui:FindFirstChild("CamSystem")
                if camSystem and camSystem:IsA("ScreenGui") then
                    camSystem.Enabled = false
                end
            end
        end
    end
end

local function SetNightAnims(state)
    local gameFolder = ReplicatedStorage:FindFirstChild("GAME")
    if gameFolder then
        local isDay = gameFolder:FindFirstChild("IsDay")
        if isDay then
            isDay:SetAttribute("NightAnims", state)
        end
    end
end

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/ukinabr/WindUI-Skibidi/refs/heads/main/loader.lua"))()

WindUI:SetFont("rbxasset://fonts/families/AccanthisADFStd.json")

local Window = WindUI:CreateWindow({
    Title = "Aureal B-X",
    Icon = "rbxassetid://88471639577194",
    Author = "by uk",
    Size = UDim2.fromOffset(490, 260),
    HideSearchBar = false,
    Theme = "Indigo",
    User = { Enabled = false, Anonymous = false, Callback = function() end },
})

Window:SetIconSize(40)

Window:EditOpenButton({
    Title = "Aureal B-X",
    Icon = "",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("FF00FF"),
        Color3.fromHex("4B0082")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = false
})

local function LoadTabs()
    local TabInfo = Window:Tab({
        Title = "Info",
        Icon = "info",
    })

    local ServerSection = TabInfo:Section({
        Title = "Server Information",
        Icon = "app-window",
        Box = true,
        Opened = true
    })

    local InfoParagraph = ServerSection:Paragraph({
        Title = "Server Data",
        Desc = "Players In Server: " .. #Players:GetPlayers() .. "\nTime Elapsed: 00:00:00\nKyper Door Code: " .. GetDoorCode()
    })

    task.spawn(function()
        local startTime = os.time()
        while task.wait(1) do
            local elapsedTime = os.time() - startTime
            InfoParagraph:SetDesc("Players In Server: " .. #Players:GetPlayers() .. "\nTime Elapsed: " .. FormatTime(elapsedTime) .. "\nKyper Door Code: " .. GetDoorCode())
        end
    end)

    Window:Divider()

    local MainTab = Window:Tab({
        Title = "Main",
        Icon = "house",
    })

    local MainSection = MainTab:Section({
        Title = "Player Settings",
        Icon = "user",
        Box = true,
        Opened = true
    })

    MainSection:Slider({
        Title = "WalkSpeed",
        Value = {
            Min = 16,
            Max = 250,
            Default = 16
        },
        Callback = SetWalkSpeed
    })

    MainSection:Slider({
        Title = "JumpPower",
        Value = {
            Min = 50,
            Max = 500,
            Default = 50
        },
        Callback = SetJumpPower
    })

    MainSection:Divider()

    MainSection:Toggle({
        Title = "Fullbright",
        Callback = SetFullbright
    })

    MainSection:Toggle({
        Title = "Noclip",
        Callback = SetNoclip
    })

    local TabInterface = Window:Tab({
        Title = "Interface",
        Icon = "smartphone",
        Locked = false,
    })

    local IntSection = TabInterface:Section({
        Title = "Game Interface",
        Box = true,
        Opened = true
    })

    IntSection:Dropdown({
        Title = "Spoof Interface",
        Desc = "Switch your interface to other devices",
        Search = true,
        Values = {
            "Mobile",
            "PC",
            "Console"
        },
        Callback = SetInterfaceSpoof
    })

    IntSection:Divider()

    IntSection:Toggle({
        Title = "Show Cams GUI",
        Desc = "Activate the security cameras.",
        Callback = SetCamsGuiEnabled
    })

    local AnimSection = TabInterface:Section({
        Title = "Animatronics",
        Box = true,
        Opened = true
    })

    AnimSection:Button({
        Title = "Enable Night Animations",
        Desc = "Turn night animations on",
        Callback = function()
            SetNightAnims(true)
        end
    })

    AnimSection:Button({
        Title = "Disable Night Animations",
        Desc = "Turn night animations off",
        Callback = function()
            SetNightAnims(false)
        end
    })

    Window:Divider()

    local TabBadges = Window:Tab({
        Title = "Auto Get Badges",
        Icon = "award",
    })

    local PizzariaSection = TabBadges:Section({
        Title = "Main Pizzaria",
        Box = true,
        Opened = false
    })

    PizzariaSection:Button({
        Title = "Shadow Freddy",
        Desc = "(Hidden)",
        Callback = function()
            local lp = Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            local nc = RunService.Stepped:Connect(function()
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)

            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            bv.Parent = hrp

            hrp.CFrame = CFrame.new(-79, 30, 52)

            task.wait(1)

            local targetPrompt = workspace.MAP.Rewards.SFreddyArcade.SCREEN:FindFirstChild("ProximityPrompt")

            if targetPrompt then
                targetPrompt.RequiresLineOfSight = false
                targetPrompt.MaxActivationDistance = 9e9
                targetPrompt.HoldDuration = 0
                targetPrompt.Enabled = true
                fireproximityprompt(targetPrompt)
            end

            task.wait(0.5)

            local event = ReplicatedStorage:WaitForChild("Func"):WaitForChild("WorldTeleport")
            event:InvokeServer("MAP_Parkinglot", false)
            nc:Disconnect()
            bv:Destroy()
        end
    })

    PizzariaSection:Button({
        Title = "Shadow Springtrap",
        Desc = "(Hidden)",
        Callback = function()
            local player = Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()

            local function enableNoclip()
                local function noclipLoop()
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
                
                noclipLoop()
                character.DescendantAdded:Connect(function(child)
                    if child:IsA("BasePart") then
                        child.CanCollide = false
                    end
                end)
            end

            local bodyVelocity

            local function enableFly()
                bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
                bodyVelocity.Parent = character:WaitForChild("HumanoidRootPart")
            end

            local function disableFly()
                if bodyVelocity then
                    bodyVelocity:Destroy()
                    bodyVelocity = nil
                end
            end

            enableNoclip()
            enableFly()

            character:MoveTo(Vector3.new(63, 5, 80))

            task.wait(1)

            local proximityPrompt = workspace.MAP.Rewards.SSpringbonnieHunt.Box.Main.ProximityPrompt
            if proximityPrompt then
                fireproximityprompt(proximityPrompt)
            end

            task.wait(0.5)

            disableFly()

            local Event = ReplicatedStorage.Func.WorldTeleport
            Event:InvokeServer("MAP_Parkinglot", false)
        end
    })

    PizzariaSection:Button({
        Title = "Shadow Chica",
        Desc = "(Hidden)",
        Callback = function()
            local lp = Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            local nc = RunService.Stepped:Connect(function()
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)

            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            bv.Parent = hrp

            local targets = {
                {
                    cframe = CFrame.new(-34, 31, -32),
                    parent = workspace.MAP.Rewards.SChicaHunt.ShadowCarl1.Cupcake
                },
                {
                    cframe = CFrame.new(-32, 31, 108),
                    parent = workspace.MAP.Rewards.SChicaHunt.ShadowCarl2.Cupcake
                },
                {
                    cframe = CFrame.new(-28, 31, 53),
                    parent = workspace.MAP.Rewards.SChicaHunt.ShadowCarl3.Cupcake
                }
            }

            for _, v in ipairs(targets) do
                hrp.CFrame = v.cframe
                task.wait(1)
                
                local prompt = v.parent:FindFirstChild("ProximityPrompt")
                if prompt then
                    prompt.RequiresLineOfSight = false
                    prompt.MaxActivationDistance = 6
                    prompt.HoldDuration = 0
                    prompt.Enabled = true
                    fireproximityprompt(prompt)
                end
                
                task.wait(1)
            end

            task.wait(0.5)

            local event = ReplicatedStorage:WaitForChild("Func"):WaitForChild("WorldTeleport")
            event:InvokeServer("MAP_Parkinglot", false)

            nc:Disconnect()
            bv:Destroy()
        end
    })

    PizzariaSection:Button({
        Title = "Shadow Bonnie",
        Desc = "(Hidden)",
        Callback = function()
            local lp = Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            local nc = RunService.Stepped:Connect(function()
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)

            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            bv.Parent = hrp

            hrp.CFrame = CFrame.new(-87, 31, -56)

            task.wait(1)

            local prompt = workspace.MAP.Rewards.SBonnie:FindFirstChild("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
            end

            task.wait(1)

            local event = ReplicatedStorage:WaitForChild("Func"):WaitForChild("WorldTeleport")
            event:InvokeServer("MAP_Parkinglot", false)

            nc:Disconnect()
            bv:Destroy()
        end
    })

    PizzariaSection:Divider()

    PizzariaSection:Button({
        Title = "Bread",
        Desc = "(Hidden)",
        Callback = function()
            local lp = Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            local nc = RunService.Stepped:Connect(function()
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)

            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            bv.Parent = hrp

            hrp.CFrame = CFrame.new(46, 31, -117)

            task.wait(1)

            local prompt = workspace.MAP.Rewards.Bread.Bread:FindFirstChild("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
            end

            task.wait(1)

            local event = ReplicatedStorage:WaitForChild("Func"):WaitForChild("WorldTeleport")
            event:InvokeServer("MAP_Parkinglot", false)

            nc:Disconnect()
            bv:Destroy()
        end
    })

    PizzariaSection:Divider()

    PizzariaSection:Button({
        Title = "Alter",
        Desc = "(Hidden)",
        Callback = function()
            local lp = Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            local nc = RunService.Stepped:Connect(function()
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)

            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            bv.Parent = hrp

            hrp.CFrame = CFrame.new(-58, -6, 135)

            task.wait(1)

            local prompt = workspace.MAP.Rewards.Alter:FindFirstChild("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
            end

            task.wait(1)

            local event = ReplicatedStorage:WaitForChild("Func"):WaitForChild("WorldTeleport")
            event:InvokeServer("MAP_Parkinglot", false)

            nc:Disconnect()
            bv:Destroy()
        end
    })

    PizzariaSection:Divider()

    PizzariaSection:Button({
        Title = "Thirty Nine",
        Desc = "(Hidden)",
        Callback = function()
            local lp = Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            local nc = RunService.Stepped:Connect(function()
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)

            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            bv.Parent = hrp

            hrp.CFrame = CFrame.new(-79, 43, -24)

            task.wait(1)

            local prompt = workspace.MAP.Rewards.ThirtyNine:FindFirstChild("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
            end

            task.wait(1)

            local event = ReplicatedStorage:WaitForChild("Func"):WaitForChild("WorldTeleport")
            event:InvokeServer("MAP_Parkinglot", false)

            nc:Disconnect()
            bv:Destroy()
        end
    })

    PizzariaSection:Divider()

    PizzariaSection:Button({
        Title = "Treasure Foxy",
        Desc = "(Hidden)",
        Callback = function()
            local lp = Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            local nc = RunService.Stepped:Connect(function()
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)

            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            bv.Parent = hrp

            hrp.CFrame = CFrame.new(-354, 23, -142)

            task.wait(1)

            local prompt = workspace.MAP.Rewards.GoldenFoxyTreasure.Chest.Lid:FindFirstChild("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
            end

            task.wait(1)

            local event = ReplicatedStorage:WaitForChild("Func"):WaitForChild("WorldTeleport")
            event:InvokeServer("MAP_Parkinglot", false)

            nc:Disconnect()
            bv:Destroy()
        end
    })

    PizzariaSection:Divider()

    PizzariaSection:Button({
        Title = "Toy Freddy",
        Desc = "(Insta)",
        Callback = function()
            local lp = Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            local nc = RunService.Stepped:Connect(function()
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)

            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            bv.Parent = hrp

            hrp.CFrame = CFrame.new(-37, 42, -130)

            task.wait(1)

            local prompt = workspace.MAP.Rewards.Plush_ToyFreddy:FindFirstChild("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
            end

            task.wait(1)

            local event = ReplicatedStorage:WaitForChild("Func"):WaitForChild("WorldTeleport")
            event:InvokeServer("MAP_Parkinglot", false)

            nc:Disconnect()
            bv:Destroy()
        end
    })

    PizzariaSection:Button({
        Title = "Toy Bonnie",
        Desc = "(Hidden)",
        Callback = function()
            local Event = Players.LocalPlayer.PlayerGui.MinigameUI.ToyBonnieHideNSeek.Event
            Event:FireServer("Aureal B-X Its the best!", true)
        end
    })

    PizzariaSection:Divider()

    PizzariaSection:Button({
        Title = "Spare Springbonnie",
        Desc = "(Hidden)",
        Callback = function()
            local lp = Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            local nc = RunService.Stepped:Connect(function()
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)

            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            bv.Parent = hrp

            local buttonsContainer = workspace.MAP.Rewards.SpringbonnieButtonHunt.Buttons
            local buttonIds = {
                "1_1", "1_2", "1_3",
                "2_1", "2_2", "2_3",
                "3_1", "3_2", "3_3"
            }

            for _, id in ipairs(buttonIds) do
                local buttonName = "Button" .. id
                local button = buttonsContainer:FindFirstChild(buttonName)
                
                if button then
                    local prompt = button:FindFirstChild("ProximityPrompt", true)
                    if prompt then
                        fireproximityprompt(prompt)
                    end
                    task.wait(0.2)
                end
            end

            hrp.CFrame = CFrame.new(-56, 32, 64)
            task.wait(1)

            local maskPrompt = workspace.MAP.Rewards.SpringbonnieButtonHunt.GoldenMask.Head:FindFirstChild("ProximityPrompt")
            if maskPrompt then
                fireproximityprompt(maskPrompt)
            end

            task.wait(1)

            local event = ReplicatedStorage:WaitForChild("Func"):WaitForChild("WorldTeleport")
            event:InvokeServer("MAP_Parkinglot", false)

            nc:Disconnect()
            bv:Destroy()
        end
    })

    PizzariaSection:Divider()

    PizzariaSection:Button({
        Title = "Bite Fredbear & Bite Springbonnie",
        Desc = "(Hidden)",
        Callback = function()
            local lp = Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            local nc = RunService.Stepped:Connect(function()
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)

            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            bv.Parent = hrp

            hrp.CFrame = CFrame.new(135, 30, -7)

            task.wait(1)

            local prompt = workspace.MAP.Rewards.TheBitePizzaHunt["Crying Child"]:FindFirstChild("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
            end

            task.wait(1)

            local event = ReplicatedStorage:WaitForChild("Func"):WaitForChild("WorldTeleport")
            event:InvokeServer("MAP_Parkinglot", false)

            nc:Disconnect()
            bv:Destroy()
        end
    })

    PizzariaSection:Divider()

    PizzariaSection:Button({
        Title = "Sun",
        Desc = "(Insta)",
        Callback = function()
            local Event = workspace.MAP.Rewards.DaycareGenerators.Event
            Event:FireServer()
        end
    })

    PizzariaSection:Button({
        Title = "Monty",
        Desc = "(Hidden)",
        Callback = function()
            local lp = Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            local nc = RunService.Stepped:Connect(function()
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)

            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            bv.Parent = hrp

            hrp.CFrame = CFrame.new(99, 31, 100)

            task.wait(1)

            local prompt = workspace.MAP.Rewards.MontyGolfBall.Barrel:FindFirstChild("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
            end

            task.wait(1)

            local event = ReplicatedStorage:WaitForChild("Func"):WaitForChild("WorldTeleport")
            event:InvokeServer("MAP_Parkinglot", false)

            nc:Disconnect()
            bv:Destroy()
        end
    })

    PizzariaSection:Button({
        Title = "Ruin Monty",
        Desc = "(Hidden)",
        Callback = function()
            local lp = Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            local nc = RunService.Stepped:Connect(function()
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)

            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            bv.Parent = hrp

            hrp.CFrame = CFrame.new(-65, -153, 135)

            task.wait(1)

            local prompt = workspace.MAP.Rewards.RuinMonty:FindFirstChild("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
            end

            task.wait(1)

            local event = ReplicatedStorage:WaitForChild("Func"):WaitForChild("WorldTeleport")
            event:InvokeServer("MAP_Parkinglot", false)

            nc:Disconnect()
            bv:Destroy()
        end
    })

    PizzariaSection:Button({
        Title = "Ruin Chica, Roxy and Freddy",
        Desc = "(Insta)",
        Callback = function()
            local Event = workspace.MAP.Rewards.Ruin_ChicaRoxy.EVENT_GiveBadge
            Event:FireServer()
        end
    })

    PizzariaSection:Divider()

    PizzariaSection:Button({
        Title = "Reversionette",
        Desc = "(Players can see You.)",
        Callback = function()
            local lp = Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            local nc = RunService.Stepped:Connect(function()
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)

            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            bv.Parent = hrp

            hrp.CFrame = CFrame.new(-130, 33, -146)

            task.wait(1)

            local prompt = workspace.MAP.Rewards.Reversionette:FindFirstChild("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
            end

            task.wait(1)

            local event = ReplicatedStorage:WaitForChild("Func"):WaitForChild("WorldTeleport")
            event:InvokeServer("MAP_Parkinglot", false)

            nc:Disconnect()
            bv:Destroy()
        end
    })

    PizzariaSection:Button({
        Title = "The Puppet",
        Desc = "(Insta - Group Reward)",
        Callback = function()
            local Event = ReplicatedStorage.Func.GroupRewards
            Event:InvokeServer()
        end
    })

    local HouseSection = TabBadges:Section({
        Title = "Afton House",
        Box = true,
        Opened = false
    })

    HouseSection:Button({
        Title = "Nightmare Freddy & Bonnie",
        Desc = "(Hidden)",
        Callback = function()
            local args1 = { false }
            workspace:WaitForChild("HOUSE"):WaitForChild("Rewards"):WaitForChild("NFreddyBonniePics"):WaitForChild("Event"):FireServer(unpack(args1))

            task.wait(1)

            local args2 = { true }
            workspace:WaitForChild("HOUSE"):WaitForChild("Rewards"):WaitForChild("NFreddyBonniePics"):WaitForChild("Event"):FireServer(unpack(args2))
        end
    })

    HouseSection:Button({
        Title = "Nightmare Foxy",
        Desc = "(Hidden)",
        Callback = function()
            local Event = workspace.HOUSE.Rewards.NFoxyRace.Event
            Event:FireServer()
        end
    })

    HouseSection:Button({
        Title = "Nightmare Chica",
        Desc = "(Players can see You.)",
        Callback = function()
            local lp = Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            local nc = RunService.Stepped:Connect(function()
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)

            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            bv.Parent = hrp

            hrp.CFrame = CFrame.new(-629, 489, 3448)

            task.wait(1)

            local prompt = workspace.HOUSE.Rewards.NChicaHunt.Cupcake3:FindFirstChild("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
            end

            task.wait(1)

            local Event = ReplicatedStorage.Func.WorldTeleport
            Event:InvokeServer("HOUSE_Upstairs", false)

            nc:Disconnect()
            bv:Destroy()
        end
    })

    HouseSection:Divider()

    HouseSection:Button({
        Title = "Mangle",
        Desc = "(Hidden)",
        Callback = function()
            local lp = Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            local nc = RunService.Stepped:Connect(function()
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)

            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            bv.Parent = hrp

            hrp.CFrame = CFrame.new(-649, 467, 3425)

            task.wait(1)

            local prompt = workspace.HOUSE.Rewards.Mangle.Main:FindFirstChild("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
            end

            local Event = ReplicatedStorage.Func.WorldTeleport
            Event:InvokeServer("HOUSE_Upstairs", false)

            nc:Disconnect()
            bv:Destroy()
        end
    })

    local FazbearSection = TabBadges:Section({
        Title = "Freddy Fazbear Pizzeria",
        Box = true,
        Opened = false
    })

    FazbearSection:Button({
        Title = "Rockstar Freddy",
        Desc = "(Hidden)",
        Callback = function()
            local lp = Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            local nc = RunService.Stepped:Connect(function()
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)

            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            bv.Parent = hrp

            local coinPrompt = workspace.HFL.Rewards.RFreddy.FazCoin2.Att:FindFirstChild("ProxPrompt")
            if coinPrompt then
                for i = 1, 5 do
                    fireproximityprompt(coinPrompt)
                    task.wait(0.3)
                end
            end

            hrp.CFrame = CFrame.new(2200, 289, 3089)
            task.wait(1)

            local headPrompt = workspace.HFL.Rewards.RFreddy.Head.Main:FindFirstChild("ProxPrompt")
            if headPrompt then
                fireproximityprompt(headPrompt)
            end

            task.wait(1)

            local Event = ReplicatedStorage.Func.WorldTeleport
            Event:InvokeServer("HFL_Street", false)

            nc:Disconnect()
            bv:Destroy()
        end
    })

    FazbearSection:Button({
        Title = "Rockstar Bonnie & Chica",
        Desc = "(Hidden)",
        Callback = function()
            local target = workspace.HFL.Rewards.RBonChica:WaitForChild("EVENT_GiveBadge")

            if target:IsA("RemoteEvent") then
                target:FireServer("race")
                task.wait(0.5)
                target:FireServer("sim")
            elseif target:IsA("RemoteFunction") then
                target:InvokeServer("race")
                task.wait(0.5)
                target:InvokeServer("sim")
            end
        end
    })

    FazbearSection:Button({
        Title = "Rockstar Foxy",
        Desc = "(Hidden)",
        Callback = function()
            local target = workspace.HFL.Rewards.RFoxy:WaitForChild("EVENT_GiveBadge")

            if target:IsA("RemoteEvent") then
                target:FireServer()
            elseif target:IsA("RemoteFunction") then
                target:InvokeServer()
            end
        end
    })

    FazbearSection:Button({
        Title = "The Igniteds",
        Desc = "(Hidden)",
        Callback = function()
            local lp = Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            local morphEvent = ReplicatedStorage:WaitForChild("Func"):WaitForChild("CharacterMorph")
            morphEvent:InvokeServer("withered bonnie")

            local nc = RunService.Stepped:Connect(function()
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)

            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            bv.Parent = hrp

            hrp.CFrame = CFrame.new(2327, 295, 3048)

            task.wait(1)

            local prompt = workspace.HFL.Rewards.Ignited_MatchBox.Main:FindFirstChild("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
            end

            task.wait(1)

            local Event = ReplicatedStorage.Func.WorldTeleport
            Event:InvokeServer("HFL_Street", false)

            nc:Disconnect()
            bv:Destroy()
        end
    })

    local FrightSection = TabBadges:Section({
        Title = "Fazbear Fright",
        Box = true,
        Opened = false
    })

    FrightSection:Button({
        Title = "Phantom Balloon Boy",
        Desc = "(Hidden)",
        Callback = function()
            local lp = Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local clockLabel = lp.PlayerGui:WaitForChild("HUD"):WaitForChild("Clock"):WaitForChild("TXT")

            local function getPrompt(path)
                local current = workspace
                for _, name in ipairs(path) do
                    current = current:FindFirstChild(name)
                    if not current then return nil end
                end
                return current
            end

            local paths = {
                {"FRIGHT", "Rewards", "PhantomBB_Balloons", "Pop1", "Balloon", "ProxPrompt"},
                {"FRIGHT", "Rewards", "PhantomBB_Balloons", "Pop2", "Balloon", "ProxPrompt"},
                {"FRIGHT", "Rewards", "PhantomBB_Balloons", "Pop3", "Balloon", "ProxPrompt"},
                {"FRIGHT", "Rewards", "PhantomBB_Balloons", "Pop4", "Balloon", "ProxPrompt"}
            }

            local function parseTime(text)
                local hour, min, period = text:match("(%d+):(%d+) (%a+)")
                if not hour or not min or not period then return 12 end
                hour = tonumber(hour)
                min = tonumber(min)
                
                if period == "PM" and hour < 12 then hour = hour + 12 end
                if period == "AM" and hour == 12 then hour = 0 end
                
                return hour + (min / 60)
            end

            local nc = RunService.Stepped:Connect(function()
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)

            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            bv.Parent = hrp

            local currentTimeText = clockLabel.Text
            local timeVal = parseTime(currentTimeText)

            local isDay = (timeVal >= 6 and timeVal <= 21.75)
            local isNight = (timeVal >= 22 or timeVal < 6)

            for _, path in ipairs(paths) do
                local prompt = getPrompt(path)
                if prompt then
                    local parent = prompt.Parent
                    if parent and parent:IsA("BasePart") then
                        if isDay then
                            hrp.CFrame = parent.CFrame
                        elseif isNight then
                            hrp.CFrame = CFrame.new(parent.Position.X, 337, parent.Position.Z)
                        end
                        task.wait(0.3)
                        fireproximityprompt(prompt)
                        task.wait(2)
                    end
                end
            end

            task.wait(1)

            local Event = ReplicatedStorage.Func.WorldTeleport
            Event:InvokeServer("FRIGHT_ParkinglotBack", false)

            nc:Disconnect()
            bv:Destroy()
        end
    })

    FrightSection:Button({
        Title = "Phantom Puppet",
        Desc = "(Hidden)",
        Callback = function()
            local lp = Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")

            local nc = RunService.Stepped:Connect(function()
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)

            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            bv.Parent = hrp

            hrp.CFrame = CFrame.new(3364, 336, -711)

            task.wait(1)

            local prompt = workspace.FRIGHT.Rewards.PhantomPuppetPoint:FindFirstChild("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
            end

            task.wait(1)

            local event = ReplicatedStorage:WaitForChild("Func"):WaitForChild("WorldTeleport")
            event:InvokeServer("FRIGHT_ParkinglotBack", false)

            nc:Disconnect()
            bv:Destroy()
        end
    })

    local TabGames = Window:Tab({
        Title = "Games",
        Icon = "plane",
    })

    local isDelta = false
    local executor = identifyexecutor or getexecutorname

    if executor then
        local name = string.lower(executor())
        if string.find(name, "delta") then
            isDelta = true
        end
    end

    local paragraph = TabGames:Paragraph({
        Title = "Warning!",
        Desc = "If your executor has an anti-teleport feature, disable it for this function to work correctly."
    })

    if isDelta then
        paragraph:SetTitle("Delta Executor <font color='rgb(255, 255, 0)'>Detected.</font>")
        paragraph:SetDesc("If your anti-teleport feature is enabled, try disabling it for it to work. \n\nHow To Disable Anti Teleport:\n\n1 - Delete everything that is in your autoexec\n2 - Rejoin your game\n3 - Dont Execute Nothing and Disable Anti-Teleport")
    end

Tab:Divider()

local Button = Tab:Button({
    Title = "Teleport to XOR Minigame",
    Desc = "",
    Locked = false,
    Callback = function()
game:GetService("TeleportService"):Teleport(540382210)
    end
})

local Button = Tab:Button({
    Title = "Teleport to ITP Minigame",
    Desc = "",
    Locked = false,
    Callback = function()
local Event = workspace.MAP.Rewards.IntoThePitTP.Event
Event:FireServer()
    end
})

local Button = Tab:Button({
    Title = "Teleport to FNAF 1 Minigame",
    Desc = "",
    Locked = false,
    Callback = function()
game:GetService("TeleportService"):Teleport(108015301318511)
    end
})

local Button = Tab:Button({
    Title = "Teleport to Sister Location Minigame",
    Desc = "",
    Locked = false,
    Callback = function()
game:GetService("TeleportService"):Teleport(17673168111)
    end
})

local Button = Tab:Button({
    Title = "Teleport to Golden Freddy Minigame",
    Desc = "",
    Callback = function()
game:GetService("TeleportService"):Teleport(12402976334)
    end
})

local Button = Tab:Button({
    Title = "Teleport to Brutal Practice Minigame",
    Desc = "(PigPatch & Happy Frog)",
    Callback = function()
game:GetService("TeleportService"):Teleport(79589802006248)
    end
})

local Button = Tab:Button({
    Title = "Teleport to Foxy Minigame",
    Desc = "",
    Callback = function()
game:GetService("TeleportService"):Teleport(92827819645934)
    end
})

local Button = Tab:Button({
    Title = "Teleport to Endo-02 Minigame",
    Desc = "",
    Callback = function()
game:GetService("TeleportService"):Teleport(17163559210)
    end
})

local Button = Tab:Button({
    Title = "Teleport to Moon Minigame",
    Desc = "",
    Callback = function()
game:GetService("TeleportService"):Teleport(74221148357881)
    end
})

local Button = Tab:Button({
    Title = "Teleport to Phantoms Minigame",
    Desc = "",
    Callback = function()
game:GetService("TeleportService"):Teleport(70930677544808)
    end
})

local Button = Tab:Button({
    Title = "Teleport to Duct Recovery Minigame",
    Desc = "",
    Callback = function()
game:GetService("TeleportService"):Teleport(71731529216768)
    end
})

local Button = Tab:Button({
    Title = "Teleport to FNAF 6 Minigame",
    Locked = true,
    Desc = "(Under development, please check back later!)",
    Callback = function()

    end
})

    Window:Divider()

local TabCredits = Window:Tab({
    Title = "Credits",
    Icon = "users-round",
})

local Card = TabCredits:DiscordCard({
    Title = "WindUI Community",
    Invite = "ftgs-development-hub-1300692552005189632",
})

TabCredits:Paragraph({
    Title = "lol!",
    Desc = "created by uk."
})


Window:Dialog({
    Title = "Clarification",
    Content = 'You accept that by using this script you may end up being banned, and me (uk) am not responsible for this, use at your own <font color="rgb(255, 0, 0)">Risk</font>.',
    Buttons = {
        {
            Title = "Ok.",
            Callback = function()
                LoadTabs()
            end
        }
    }
})
