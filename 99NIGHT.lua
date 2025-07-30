local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/iiivyne/robloxlua/refs/heads/main/lib.lua"))()
local int = lib:CreateInterface("森林中的99个夜晚","脚本由lohjc制作","https://discord.gg/ZNTHTWx7KE","左下","皇家")
local main = int:CreateTab("主界面","主要功能/脚本工具","默认",true)
local autofarmss = int:CreateTab("自动","自动 farming 工具（强力）","强力")
local itemtp = int:CreateTab("物品传送/ESP","将物品带到你身边","物品")
local gametp = int:CreateTab("游戏传送","前往游戏内地点","信息")
local charactertp = int:CreateTab("怪物传送","将怪物带到你身边","非玩家角色")
local plr = int:CreateTab("玩家","修改你的本地玩家","玩家")
local vis = int:CreateTab("视觉效果","修改你的视觉效果","视觉效果")
local misc = int:CreateTab("杂项","各种各样的功能","杂项")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
-- === 主要配置 === 
local Players = game:GetService("Players")
local player = Players.LocalPlayer
-- 安全区设置：网格中的9个底板
local safezoneBaseplates = {}
local baseplateSize = Vector3.new(2048, 1, 2048)
local baseY = 100
local centerPos = Vector3.new(0, baseY, 0) -- 初始中心
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
-- 用于切换所有底板可见性/碰撞的复选框
main:CreateCheckbox("显示安全区", function(enabled)
    for _, baseplate in ipairs(safezoneBaseplates) do
        baseplate.Transparency = enabled and 0.8 or 1
        baseplate.CanCollide = enabled
    end
end)
-- 将"x, y, z"字符串转换为CFrame的工具
local function stringToCFrame(str)
    local x, y, z = str:match("([^,]+),%s*([^,]+),%s*([^,]+)")
    return CFrame.new(tonumber(x), tonumber(y), tonumber(z))
end
-- 带有可选补间持续时间的传送功能
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
local storyCoords = {
    { "[营地] 营地", "0, 8, -0"},
    { "[安全区] 安全区", "0, 110, -0" }
}
local storyDropdown = gametp:CreateDropDown("传送点")
-- 为剧情传送创建下拉菜单
for _, entry in ipairs(storyCoords) do
    local name, coord = entry[1], entry[2]
    storyDropdown:AddButton(name, function()
        teleportToTarget(stringToCFrame(coord), 0.1)
    end)
end
itemtp:CreateCheckbox("物品ESP", function(state)
    local itemFolder = workspace:FindFirstChild("Items")
    if not itemFolder then
        warn("未找到workspace.Items文件夹")
        return
    end
    local itemNames = {
        ["左轮手枪"] = true, ["油桶"] = true, ["电锯"] = true, ["大袋子"] = true, ["兔子脚"] = true,["医疗包"] = true, ["外星人箱子"] = true, ["浆果"] = true,
        ["螺栓"] = true, ["坏掉的风扇"] = true, ["胡萝卜"] = true, ["煤"] = true,
        ["硬币堆"] = true, ["全息发射器"] = true, ["物品箱"] = true,
        ["激光围栏蓝图"] = true, ["木头"] = true, ["旧手电筒"] = true,
        ["旧收音机"] = true, ["金属板"] = true, ["绷带"] = true, ["步枪"] = true
    }
    local connections = {}
    local function createESP(model)
        if not model:IsA("Model") or not itemNames[model.Name] then return end
        if not model.PrimaryPart or model:FindFirstChild("ESP") then return end
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP"
        billboard.Size = UDim2.new(0, 100, 0, 30)
        billboard.Adornee = model.PrimaryPart
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 3, 0)
	
	local customFont = Font.new("rbxassetid://16658246179", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
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
    local function removeAllESP()
        for _, model in itemFolder:GetChildren() do
            local esp = model:FindFirstChild("ESP")
            if esp then esp:Destroy() end
        end
    end
    if state then
        -- 为所有当前物品创建ESP
        for _, model in itemFolder:GetChildren() do
            createESP(model)
        end
        -- 为任何新增物品添加ESP
        local connection = itemFolder.ChildAdded:Connect(function(model)
            if model:IsA("Model") and itemNames[model.Name] then
                model:GetPropertyChangedSignal("PrimaryPart"):Wait()
                createESP(model)
            end
        end)
        table.insert(connections, connection)
    else
        -- 禁用ESP
        removeAllESP()
        -- 断开所有监听器
        for _, conn in connections do
            if conn.Disconnect then conn:Disconnect() end
        end
        table.clear(connections)
    end
end)
-- 传送到物品
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local itemFolder = workspace:WaitForChild("Items")
local itemNames = {
    "左轮手枪", "医疗包", "外星人箱子", "浆果", "螺栓", "坏掉的风扇",
    "胡萝卜", "煤", "硬币堆", "全息发射器", "物品箱",
    "激光围栏蓝图", "木头", "旧手电筒", "旧收音机",
    "金属板", "绷带", "步枪"
}
local function getModelPart(model)
    if model.PrimaryPart then
        return model.PrimaryPart
    end
    for _, part in pairs(model:GetChildren()) do
        if part:IsA("BasePart") then
            return part
        end
    end
    return nil
end
local dropdown = itemtp:CreateDropDown("传送到物品")
for _, itemName in ipairs(itemNames) do
    dropdown:AddButton("传送到" .. itemName, function()
        -- 在物品文件夹中找到所有以此命名的模型
        local candidates = {}
        for _, model in pairs(itemFolder:GetChildren()) do
            if model:IsA("Model") and model.Name == itemName then
                local part = getModelPart(model)
                if part then
                    table.insert(candidates, part)
                end
            end
        end
        if #candidates == 0 then
            warn("未找到可传送的'" .. itemName .. "'。")
            return
        end
        -- 随机选择一个部件并传送
        local targetPart = candidates[math.random(1, #candidates)]
        local character = localPlayer.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = targetPart.CFrame + Vector3.new(0, 5, 0)
            end
        end
    end)
end
-- 传送到物品
-- 将物品传送到你身边  
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local itemsFolder = workspace:WaitForChild("Items")
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local possibleItems = {
    "外星人箱子",
    "阿尔法狼皮",
    "铁砧前部",
    "铁砧后部",
    "苹果",
    "绷带",
    "熊尸体",
    "熊皮",
    "浆果",
    "生物燃料",
    "螺栓",
    "坏掉的风扇",
    "兔子脚",
    "胡萝卜",
    "煤",
    "硬币堆",
    "煮熟的小块肉",
    "煮熟的牛排",
    "电锯",
    "邪教徒",
    "邪教徒宝石",
    "花",
    "燃料罐",
    "全息发射器",
    "物品箱",
    "激光围栏蓝图",
    "皮革甲",
    "铁甲",
    "荆棘甲",
    "木头",
    "医疗包",
    "小块肉",
    "旧手电筒",
    "旧收音机",
    "好袋子",
    "好斧头",
    "射线枪",
    "大袋子",
    "强斧头",
    "油桶",
    "旧汽车发动机",
    "步枪",
    "步枪弹药",
    "左轮手枪",
    "左轮手枪弹药",
    "树苗",
    "金属板",
    "牛排",
    "狼皮",
    "森林宝石碎片",
    "轮胎",
    "洗衣机",
    "坏掉的微波炉"
}
local bringitemtoyou = itemtp:CreateDropDown("传送物品（批量）：")
local sources = {
    itemsFolder,
    game:GetService("ReplicatedStorage"):WaitForChild("TempStorage")
}
local function teleportItem(itemName)
    local stackOffsetY = 2 -- 堆叠物品之间的高度
    local count = 0
    for _, source in ipairs(sources) do
        for _, item in ipairs(source:GetChildren()) do
            if item.Name == itemName then
                local targetPart = nil
                if itemName == "浆果" then
                    targetPart = item:FindFirstChild("Handle")
                    if not targetPart then
                        for _, child in ipairs(item:GetDescendants()) do
                            if child:IsA("MeshPart") or child:IsA("Part") or child:IsA("UnionOperation") then
                                targetPart = child
                                break
                            end
                        end
                    end
                else
                    for _, child in ipairs(item:GetDescendants()) do
                        if child:IsA("MeshPart") or child:IsA("Part") then
                            targetPart = child
                            break
                        end
                    end
                end
                if targetPart then
                    remoteEvents.RequestStartDraggingItem:FireServer(item)
                    -- 在玩家位置垂直堆叠
                    local offset = Vector3.new(0, count * stackOffsetY, 0)
                    targetPart.CFrame = rootPart.CFrame + offset
                    remoteEvents.StopDraggingItem:FireServer(item)
                    print("已移动", itemName, ":", item:GetFullName())
                    count = count + 1
                else
                    warn("找到" .. itemName .. "，但内部没有MeshPart或Part：", item:GetFullName())
                end
            end
        end
    end
end
for _, itemName in ipairs(possibleItems) do
    bringitemtoyou:AddButton(itemName, function()
        teleportItem(itemName)
    end)
end
-- 将物品传送到你身边 
-- 将角色传送到你身边
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local characterFolder = workspace:WaitForChild("Characters")
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents") -- 如有需要
-- 可传送的角色名称列表（你的标签）
local possibleCharacters = {
    "阿尔法狼",
    "熊",
    "迷路的孩子",
    "迷路的孩子2",
    "迷路的孩子3",
    "迷路的孩子4",
    "狼",
    "兔子",
    "邪教徒",
    "外星人"
}
local bringCharacterToYou = charactertp:CreateDropDown("传送怪物：")
-- 查找主要部件的辅助函数（类似于你的getModelPart）
local function getMainPart(model)
    if model.PrimaryPart then
        return model.PrimaryPart
    end
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            return part
        end
    end
    return nil
end
local function teleportCharacter(characterName)
    local stackOffsetY = 3
    local count = 0
    for _, model in ipairs(characterFolder:GetChildren()) do
        if model.Name == characterName then
            local mainPart = getMainPart(model)
            if mainPart and rootPart then
                -- 移动整个模型，使主要部件对齐到玩家上方，堆叠放置
                local targetCFrame = rootPart.CFrame + Vector3.new(0, count * stackOffsetY, 0)
                -- 如果有PrimaryPart，使用SetPrimaryPartCFrame，否则直接移动主要部件
                if model.PrimaryPart then
                    model:SetPrimaryPartCFrame(targetCFrame)
                else
                    mainPart.CFrame = targetCFrame
                end
                count = count + 1
            else
                warn("未找到角色的主要部件：", model:GetFullName())
            end
        end
    end
end
for _, characterName in ipairs(possibleCharacters) do
    bringCharacterToYou:AddButton(characterName, function()
        teleportCharacter(characterName)
    end)
end
-- 将角色传送到你身边 
-- === 玩家滑块 ===
-- 跳跃力滑块
plr:CreateSlider("跳跃力", 700, 50, function(value)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = value
    end
end)
-- 行走速度滑块（具有持久行为）
plr:CreateSlider("行走速度", 700, 16, function(value)
    _G.HackedWalkSpeed = value
    local function applyWalkSpeed(humanoid)
        if humanoid then
            humanoid.WalkSpeed = _G.HackedWalkSpeed
            humanoid.Changed:Connect(function(property)
                if property == "WalkSpeed" and humanoid.WalkSpeed ~= _G.HackedWalkSpeed then
                    humanoid.WalkSpeed = _G.HackedWalkSpeed
                end
            end)
        end
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        applyWalkSpeed(LocalPlayer.Character.Humanoid)
    end
    LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid")
        applyWalkSpeed(char:FindFirstChild("Humanoid"))
    end)
end)
plr:CreateCheckbox("行走速度切换（50）",function(toggle)
    if toggle == true then 
    _G.HackedWalkSpeed = 50
        else
    _G.HackedWalkSpeed = 16
    end
    local function applyWalkSpeed(humanoid)
        if humanoid then
            humanoid.WalkSpeed = _G.HackedWalkSpeed
            humanoid.Changed:Connect(function(property)
                if property == "WalkSpeed" and humanoid.WalkSpeed ~= _G.HackedWalkSpeed then
                    humanoid.WalkSpeed = _G.HackedWalkSpeed
                end
            end)
        end
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        apply
