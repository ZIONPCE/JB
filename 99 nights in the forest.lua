-- ✅ VEX OP Hub X 森林中的99个夜晚Z某人汉化

-- 加载 WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "VEX OP - 森林中的99个夜晚",
    Icon = "rbxassetid://86958834463274",
    Folder = "VEX OP",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    Background = "rbxassetid://108597781932956",
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
})

local Tabs = {
    Discord = Window:Tab({ Title = "Discord", Icon = "bell" }),
    Main = Window:Tab({ Title = "主要功能", Icon = "swords" }),
    ESP = Window:Tab({ Title = "物品透视", Icon = "radar" }),
    Bring = Window:Tab({ Title = "物品召唤", Icon = "box" }),
    Visual = Window:Tab({ Title = "视觉设置", Icon = "eye" }),
    Teleports = Window:Tab({ Title = "传送功能", Icon = "map" }),
    Auto = Window:Tab({ Title = "自动功能", Icon = "cog" }),
}

-- 服务
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

LocalPlayer.CharacterAdded:Connect(function(chr)
    character = chr
    humanoid = chr:WaitForChild("Humanoid")
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- 杀戮光环状态
local killAuraToggle = false
local radius = 200

-- 工具检测
local toolsDamageIDs = {
    ["旧斧头"] = "1_8982038982",
    ["好斧头"] = "112_8982038982",
    ["强斧头"] = "116_8982038982",
    ["电锯"] = "647_8992824875",
    ["长矛"] = "196_8999010016"
}


local function getAnyToolWithDamageID()
    for toolName, damageID in pairs(toolsDamageIDs) do
        local tool = LocalPlayer:FindFirstChild("Inventory") and LocalPlayer.Inventory:FindFirstChild(toolName)
        if tool then
            return tool, damageID
        end
    end
    return nil, nil
end

local function equipTool(tool)
    if tool then
        RemoteEvents.EquipItemHandle:FireServer("FireAllClients", tool)
    end
end

local function unequipTool(tool)
    if tool then
        RemoteEvents.UnequipItemHandle:FireServer("FireAllClients", tool)
    end
end

local function killAuraLoop()
    while killAuraToggle do
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local tool, damageID = getAnyToolWithDamageID()
            if tool and damageID then
                equipTool(tool)

                for _, mob in ipairs(Workspace.Characters:GetChildren()) do
                    if mob:IsA("Model") then
                        local part = mob:FindFirstChildWhichIsA("BasePart")
                        if part and (part.Position - hrp.Position).Magnitude <= radius then
                            pcall(function()
                                RemoteEvents.ToolDamageObject:InvokeServer(
                                    mob,
                                    tool,
                                    damageID,
                                    CFrame.new(part.Position)
                                )
                            end)
                        end
                    end
                end
                task.wait(0.1)
            else
                task.wait(1)
            end
        else
            task.wait(0.5)
        end
    end
end

local itemESPEnabled = false
local itemESPConnections = {}

local itemNamesForESP = {
    ["左轮手枪"] = true, ["油桶"] = true, ["电锯"] = true, ["大袋子"] = true,
    ["兔子脚"] = true, ["医疗包"] = true, ["外星宝箱"] = true, ["浆果"] = true,
    ["螺栓"] = true, ["坏掉的风扇"] = true, ["胡萝卜"] = true, ["煤炭"] = true,
    ["金币堆"] = true, ["全息发射器"] = true, ["物品箱"] = true,
    ["激光围栏蓝图"] = true, ["木头"] = true, ["旧手电筒"] = true,
    ["旧收音机"] = true, ["金属板"] = true, ["绷带"] = true, ["步枪"] = true
}

local customFont = Font.new("rbxassetid://16658246179", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

local function createItemESP(model)
    if not model:IsA("Model") or not itemNamesForESP[model.Name] then return end
    if not model.PrimaryPart or model:FindFirstChild("ESP") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.Adornee = model.PrimaryPart
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.TextSize = 17
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0.5
    label.TextScaled = false
    label.FontFace = customFont
    label.Text = model.Name
    label.Parent = billboard

    billboard.Parent = model
end

local function removeAllItemESP()
    local itemFolder = workspace:FindFirstChild("Items")
    if not itemFolder then return end
    for _, model in itemFolder:GetChildren() do
        local esp = model:FindFirstChild("ESP")
        if esp then esp:Destroy() end
    end
end

-- 将类似"0, 110, 0"的字符转换为CFrame
local function stringToCFrame(str)
    local x, y, z = str:match("([^,]+),%s*([^,]+),%s*([^,]+)")
    return CFrame.new(tonumber(x), tonumber(y), tonumber(z))
end

-- 使用可选的补回持续时间传送玩家
local function teleportToTarget(cf, duration)
    local char = game.Players.LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if duration and duration > 0 then
        local ts = game:GetService("TweenService")
        local info = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local goal = { CFrame = cf }
        local tween = ts:Create(hrp, info, goal)
        tween:Play()
    else
        hrp.CFrame = cf
    end
end


-- Discord标签页
Tabs.Discord:Section({ Title = "Discord" })

Tabs.Discord:Button({
    Title = "加入 Discord",
    Description = "Discord 链接",
    Callback = function()
        setclipboard("https://discord.gg/FvMePtyJrq")
        WindUI:Notify({ Title = "Discord", Content = "已复制Discord 链接!", Duration = 2 })
    end
})


-- 主要功能标签页
Tabs.Main:Section({ Title = "主要功能" })

-- 夜间自动传送到篝火
local bonfirePosition = Vector3.new(0.32, 6.15, -0.22)
local teleportEnabled = false
local teleportConnection = nil

Tabs.Main:Toggle({
    Title = "夜间自动传送到篝火",
    Default = false,
    Callback = function(value)
        teleportEnabled = value

        if teleportConnection then teleportConnection:Disconnect() end
        teleportConnection = nil

        if value then
            teleportConnection = RunService.Heartbeat:Connect(function()
                if character and character:FindFirstChild("HumanoidRootPart") then
                    if Lighting.ClockTime >= 18 or Lighting.ClockTime <= 6 then
                        local hrp = character.HumanoidRootPart
                        hrp.CFrame = CFrame.new(bonfirePosition)
                        hrp.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end)
        end
    end
})

-- 无限跳跃
local infiniteJump = false
local jumpConnection = nil

Tabs.Main:Toggle({
    Title = "无限跳跃",
    Default = false,
    Callback = function(value)
        infiniteJump = value

        if jumpConnection then jumpConnection:Disconnect() end
        jumpConnection = nil

        if value then
            jumpConnection = UserInputService.JumpRequest:Connect(function()
                if infiniteJump and humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end
})

-- 速度控制
local speedEnabled = false
local currentSpeed = 16
local speedConnection = nil

Tabs.Main:Toggle({
    Title = "改变速度",
    Default = false,
    Callback = function(value)
        speedEnabled = value

        if speedConnection then speedConnection:Disconnect() end
        speedConnection = nil

        if value and humanoid then
            humanoid.WalkSpeed = currentSpeed
            speedConnection = RunService.Heartbeat:Connect(function()
                if humanoid and speedEnabled then
                    humanoid.WalkSpeed = currentSpeed
                end
            end)
        elseif humanoid then
            humanoid.WalkSpeed = 16
        end
    end
})

Tabs.Main:Slider({
    Title = "速度值",
    Step = 1,
    Value = {
        Min = 16,
        Max = 1000,
        Default = 16,
    },
    Callback = function(value)
        currentSpeed = value
        if speedEnabled and humanoid then
            humanoid.WalkSpeed = value
        end
    end
})


-- 穿墙
local noclipEnabled = false
local noclipConnection = nil

local function noclipLoop()
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

Tabs.Main:Toggle({
    Title = "穿墙",
    Default = false,
    Callback = function(value)
        noclipEnabled = value

        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = nil

        if value then
            noclipConnection = RunService.Stepped:Connect(noclipLoop)
        end
    end
})

-- 无坠落伤害
Tabs.Main:Toggle({
    Title = "无坠落伤害",
    Default = false,
    Callback = function(value)
        if value then
            humanoid.StateChanged:Connect(function(_, newState)
                if newState == Enum.HumanoidStateType.FallingDown or newState == Enum.HumanoidStateType.PlatformStanding then
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
            end)
        end
    end
})

Tabs.Main:Toggle({
    Title = "杀戮光环",
    Default = false,
    Callback = function(value)
        killAuraToggle = value
        if value then
            task.spawn(killAuraLoop)
        else
            local tool, _ = getAnyToolWithDamageID()
            unequipTool(tool)
        end
    end
})

Tabs.Main:Slider({
    Title = "杀戮光环范围",
    Step = 5,
    Value = {
        Min = 20,
        Max = 500,
        Default = 200,
    },
    Callback = function(value)
        radius = math.clamp(value, 20, 500)
    end
})

Tabs.ESP:Section({ Title = "物品透视" })

Tabs.ESP:Toggle({
    Title = "物品透视",
    Default = false,
    Callback = function(state)
        itemESPEnabled = state

        local itemFolder = workspace:FindFirstChild("Items")
        if not itemFolder then
            warn("未找到workspace.Items文件夹")
            return
        end

        -- 清理之前的
        removeAllItemESP()
        for _, conn in ipairs(itemESPConnections) do
            if conn.Disconnect then conn:Disconnect() end
        end
        table.clear(itemESPConnections)

        if state then
            -- 添加到所有现有物品
            for _, model in itemFolder:GetChildren() do
                createItemESP(model)
            end

            -- 添加新物品
            local conn = itemFolder.ChildAdded:Connect(function(model)
                model:GetPropertyChangedSignal("PrimaryPart"):Wait()
                createItemESP(model)
            end)
            table.insert(itemESPConnections, conn)
        end
    end
})

-- 物品召唤标签页
Tabs.Bring:Section({ Title = "物品召唤" })

local function bringItems(itemName, offsetY)
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local offset = 0
    for _, item in ipairs(workspace:GetDescendants()) do
        if item:IsA("Model") and item.Name == itemName then
            local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
            if part then
                item:SetPrimaryPartCFrame(root.CFrame * CFrame.new(offset, offsetY or 2, 0))
                offset = offset + 2
                task.wait(0.1)
            end
        end
    end
end

Tabs.Bring:Button({
    Title = "召唤木头",
    Callback = function()
        bringItems("木头")
    end
})

Tabs.Bring:Button({
    Title = "召唤煤炭",
    Callback = function()
        bringItems("煤炭")
    end
})

Tabs.Bring:Button({
    Title = "召唤燃料",
    Callback = function()
        bringItems("燃料罐")
    end
})

Tabs.Bring:Button({
    Title = "召唤金属板",
    Callback = function()
        bringItems("金属板")
    end
})

-- 视觉设置标签页
Tabs.Visual:Section({ Title = "视觉设置" })

local brightnessEnabled = false
local originalBrightness = Lighting.Brightness

Tabs.Visual:Toggle({
    Title = "亮度增强",
    Default = false,
    Callback = function(value)
        brightnessEnabled = value
        if value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 12
        else
            Lighting.Brightness = originalBrightness
        end
    end
})

Tabs.Visual:Toggle({
    Title = "全亮度",
    Default = false,
    Callback = function(value)
        if value then
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.GlobalShadows = false
        else
            Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
            Lighting.GlobalShadows = true
        end
    end
})

local fovEnabled = false
local currentFOV = 70
local fovConnection = nil

Tabs.Visual:Toggle({
    Title = "视野修改",
    Default = false,
    Callback = function(value)
        fovEnabled = value

        if fovConnection then fovConnection:Disconnect() end
        fovConnection = nil

        if value then
            fovConnection = RunService.RenderStepped:Connect(function()
                if workspace.CurrentCamera then
                    workspace.CurrentCamera.FieldOfView = currentFOV
                end
            end)
        elseif workspace.CurrentCamera then
            workspace.CurrentCamera.FieldOfView = 70
        end
    end
})

Tabs.Visual:Slider({
    Title = "视野值",
    Step = 1,
    Value = {
        Min = 70,
        Max = 120,
        Default = 70,
    },
    Callback = function(value)
        currentFOV = value
        if fovEnabled and workspace.CurrentCamera then
            workspace.CurrentCamera.FieldOfView = value
        end
    end
})


-- 传送功能标签
Tabs.Teleports:Section({ Title = "传送功能" })

local waypoints = {
    ["篝火"] = CFrame.new(0.32, 6.15, -0.22),
    ["小屋"] = CFrame.new(-100, 5, 50),
    ["河流"] = CFrame.new(150, 3, -200),
}

for name, cf in pairs(waypoints) do
    Tabs.Teleports:Button({
        Title = "传送到" .. name,
        Callback = function()
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = cf
            end
        end
    })
end

Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        if teleportConnection then teleportConnection:Disconnect() end
        if jumpConnection then jumpConnection:Disconnect() end
        if speedConnection then speedConnection:Disconnect() end
        if noclipConnection then noclipConnection:Disconnect() end
        if noAggroConnection then noAggroConnection:Disconnect() end
        if fovConnection then fovConnection:Disconnect() end

        Lighting.Brightness = originalBrightness
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        Lighting.GlobalShadows = true

        if workspace.CurrentCamera then
            workspace.CurrentCamera.FieldOfView = 70
        end

        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end
end)




Tabs.Teleports:Button({
    Title = "传送到安全区",
    Callback = function()
        local safezoneBaseplates = {}
        local baseplateSize = Vector3.new(2048, 1, 2048)
        local baseY = 100
        local centerPos = Vector3.new(0, baseY, 0)
        
        for dx = -1, 1 do
            for dz = -1, 1 do
                local pos = centerPos + Vector3.new(dx * baseplateSize.X, 0, dz * baseplateSize.Z)
                local baseplate = Instance.new("Part")
                baseplate.Name = "SafeZoneBaseplate"
                baseplate.Size = baseplateSize
                baseplate.Position = pos
                baseplate.Anchored = true
                baseplate.CanCollide = true
                baseplate.Transparency = 1
                baseplate.Color = Color3.fromRGB(255, 255, 255)
                baseplate.Parent = workspace
                table.insert(safezoneBaseplates, baseplate)
            end
        end
        task.wait(0.5)
        teleportToTarget(stringToCFrame("0, 110, -0"), 0.1)
    end
})


-- === 自动功能标签 ===
local autoTab = Tabs.Auto

-- === 服务器和基础引用 ===
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local itemsFolder = Workspace:WaitForChild("Items")
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local remoteConsume = remoteEvents:WaitForChild("RequestConsumeItem")

-- === 位置和物品列表 ===
local campfireDropPos = Vector3.new(0, 19, 0)
local machineDropPos = Vector3.new(21, 16, -5)

local campfireFuelItems = {"木头", "煤炭", "燃料罐", "油桶", "生物燃料"}
local autocookItems = {"小块肉", "牛排"}
local autoGrindItems = {"UFO残骸", "UFO组件", "旧汽车发动机", "坏掉的风扇", "旧微波炉", "螺栓", "木头", "邪教徒宝石", "金属板", "旧收音机", "轮胎", "洗衣机", "邪教徒实验品", "邪教徒组件", "森林宝石碎片", "坏掉的微波炉"}
local autoEatFoods = {"熟牛排", "熟小块肉", "浆果", "胡萝卜", "苹果"}
local biofuelItems = {"胡萝卜", "煮熟的食物", "小块肉", "牛排", "熟牛排", "木头"}

local alwaysFeed = {}
local hpFeed = {}
local cookItems = {}
local grindItems = {}
local biofuelEnabled = {}
local autoEatEnabled = false
local autoEatHPEnabled = false

-- === DROPDOWNS ===
local function setupMultiDropdown(title, itemList, storage)
    autoTab:Dropdown({
        Title = title,
        Values = itemList,
        Multi = true,
        AllowNone = true,
        Value = {},
        Callback = function(selected)
            table.clear(storage)
            for _, name in ipairs(selected) do
                storage[name] = true
            end
        end
    })
end

setupMultiDropdown("篝火燃料 (一次性全部)", campfireFuelItems, alwaysFeed)
setupMultiDropdown("根据篝火生命值添加篝火燃料", campfireFuelItems, hpFeed)
setupMultiDropdown("自动亨饪", autocookItems, cookItems)
setupMultiDropdown("自动机器研磨", autoGrindItems, grindItems)
setupMultiDropdown("自动生物燃料", biofuelItems, biofuelEnabled)

autoTab:Toggle({
    Title = "自己进食",
    Default = false,
    Callback = function(val) autoEatEnabled = val end
})

autoTab:Toggle({
    Title = "根据生命值自动进食",
    Default = false,
    Callback = function(val) autoEatHPEnabled = val end
})

-- === 移动物品功能 ===
local function moveItemToPos(item, position)
    local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")
    if not part then return end
    if not item.PrimaryPart then pcall(function() item.PrimaryPart = part end) end

    pcall(function()
        remoteEvents.RequestStartDraggingItem:FireServer(item)
        task.wait(0.05)
        item:SetPrimaryPartCFrame(CFrame.new(position))
        task.wait(0.05)
        remoteEvents.StopDraggingItem:FireServer(item)
    end)
end

-- === 后台循环 ===
coroutine.wrap(function()
    while task.wait(2) do
        for itemName in pairs(alwaysFeed) do
            for _, item in ipairs(itemsFolder:GetChildren()) do
                if item.Name == itemName then
                    moveItemToPos(item, campfireDropPos)
                end
            end
        end
    end
end)()

coroutine.wrap(function()
    local fill = Workspace:WaitForChild("Map"):WaitForChild("Campground"):WaitForChild("MainFire").Center.BillboardGui.Frame.Background.Fill
    while task.wait(2) do
        if fill.Size.X.Scale < 0.7 then
            repeat
                for itemName in pairs(hpFeed) do
                    for _, item in ipairs(itemsFolder:GetChildren()) do
                        if item.Name == itemName then
                            moveItemToPos(item, campfireDropPos)
                        end
                    end
                end
                task.wait(0.5)
            until fill.Size.X.Scale >= 1
        end
    end
end)()

coroutine.wrap(function()
    while task.wait(2.5) do
        for itemName in pairs(cookItems) do
            for _, item in ipairs(itemsFolder:GetChildren()) do
                if item.Name == itemName then
                    moveItemToPos(item, campfireDropPos)
                end
            end
        end
    end
end)()

coroutine.wrap(function()
    while task.wait(2.5) do
        for itemName in pairs(grindItems) do
            for _, item in ipairs(itemsFolder:GetChildren()) do
                if item.Name == itemName then
                    moveItemToPos(item, machineDropPos)
                end
            end
        end
    end
end)()

coroutine.wrap(function()
    while task.wait(3) do
        if autoEatEnabled then
            local foods = {}
            for _, item in ipairs(itemsFolder:GetChildren()) do
                if table.find(autoEatFoods, item.Name) then
                    table.insert(foods, item)
                end
            end
            if #foods > 0 then
                pcall(function()
                    remoteConsume:InvokeServer(foods[math.random(1, #foods)])
                end)
            end
        end
    end
end)()

coroutine.wrap(function()
    local hungerBar = player:WaitForChild("PlayerGui"):WaitForChild("Interface"):WaitForChild("StatBars"):WaitForChild("HungerBar"):WaitForChild("Bar")
    while task.wait(3) do
        if autoEatHPEnabled and hungerBar.Size.X.Scale <= 0.5 then
            repeat
                local foods = {}
                for _, item in ipairs(itemsFolder:GetChildren()) do
                    if table.find(autoEatFoods, item.Name) then
                        table.insert(foods, item)
                    end
                end
                if #foods > 0 then
                    pcall(function()
                        remoteConsume:InvokeServer(foods[math.random(1, #foods)])
                    end)
                else
                    break
                end
                task.wait(1)
            until hungerBar.Size.X.Scale >= 0.99 or not autoEatHPEnabled
        end
    end
end)()

-- === 树木传送 ===
local originalTreeCFrames, treesBrought = {}, false
local function getAllSmallTrees()
    local trees, map = {}, Workspace:FindFirstChild("Map")
    if map then
        for _, folder in pairs({ "Foliage", "Landmarks" }) do
            local section = map:FindFirstChild(folder)
            if section then
                for _, obj in ipairs(section:GetChildren()) do
                    if obj:IsA("Model") and obj.Name == "Small Tree" then
                        table.insert(trees, obj)
                    end
                end
            end
        end
    end
    return trees
end

local function bringAllTrees()
    local target = CFrame.new(rootPart.Position + rootPart.CFrame.LookVector * 10)
    for _, tree in ipairs(getAllSmallTrees()) do
        local trunk = tree:FindFirstChild("Trunk", true)
        if trunk then
            originalTreeCFrames[tree] = trunk.CFrame
            tree.PrimaryPart = trunk
            trunk.Anchored = false
            trunk.CanCollide = false
            tree:SetPrimaryPartCFrame(target + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
            trunk.Anchored = true
        end
    end
    treesBrought = true
end

local function restoreTrees()
    for tree, cf in pairs(originalTreeCFrames) do
        local trunk = tree:FindFirstChild("Trunk", true)
        if trunk then
            tree.PrimaryPart = trunk
            tree:SetPrimaryPartCFrame(cf)
            trunk.Anchored = true
            trunk.CanCollide = true
        end
    end
    originalTreeCFrames = {}
    treesBrought = false
end

autoTab:Toggle({
    Title = "自动召唤所有小树",
    Default = false,
    Callback = function(v)
        if v and not treesBrought then bringAllTrees()
        elseif not v and treesBrought then restoreTrees() end
    end
})

Window:SelectTab(1)
WindUI:Notify({ Title = "VEX OP", Content = "Loaded Successfully!", Icon = "rbxassetid://82233980503615", Duration = 3, Icon = "bell" })
