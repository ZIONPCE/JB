-- 建造飞机 - 带智能返回
-- 自动启动、向前飞行，在1300美元时返回以最大利润

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- 角色变量 (重生时会更新)
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- 获取远程事件 (用于发射/返回)
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local LaunchEvents = Remotes:WaitForChild("LaunchEvents", 10)
local LaunchRemote = LaunchEvents:WaitForChild("Launch")
local ReturnRemote = LaunchEvents:WaitForChild("Return")

-- 简单GUI界面
local ScreenGui = PlayerGui:FindFirstChild("SimpleFly")
if ScreenGui then
    ScreenGui:Destroy()
end

ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleFly"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 380)
MainFrame.Position = UDim2.new(0, 10, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.new(0, 1, 0)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- 标题
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.BackgroundColor3 = Color3.new(0, 0.5, 0)
TitleLabel.Text = "✈️ 自动飞行"
TitleLabel.TextColor3 = Color3.new(1, 1, 1)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = MainFrame

-- 现金显示
local MoneyLabel = Instance.new("TextLabel")
MoneyLabel.Size = UDim2.new(0.9, 0, 0, 30)
MoneyLabel.Position = UDim2.new(0.05, 0, 0, 45)
MoneyLabel.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
MoneyLabel.Text = "以赚钱现金: $0 | 距离: 0"
MoneyLabel.TextColor3 = Color3.new(1, 1, 0)
MoneyLabel.TextScaled = true
MoneyLabel.Font = Enum.Font.SourceSansBold
MoneyLabel.Parent = MainFrame

-- 自动农场开关
local AutoFarmToggle = Instance.new("TextButton")
AutoFarmToggle.Size = UDim2.new(0.9, 0, 0, 40)
AutoFarmToggle.Position = UDim2.new(0.05, 0, 0, 80)
AutoFarmToggle.BackgroundColor3 = Color3.new(0.5, 0, 0)
AutoFarmToggle.Text = "自动农场: 关闭"
AutoFarmToggle.TextColor3 = Color3.new(1, 1, 1)
AutoFarmToggle.TextScaled = true
AutoFarmToggle.Font = Enum.Font.SourceSansBold
AutoFarmToggle.Parent = MainFrame

-- 飞行开关
local FlyToggle = Instance.new("TextButton")
FlyToggle.Size = UDim2.new(0.9, 0, 0, 40)
FlyToggle.Position = UDim2.new(0.05, 0, 0, 125)
FlyToggle.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
FlyToggle.Text = "飞行: 关闭"
FlyToggle.TextColor3 = Color3.new(1, 0.3, 0.3)
FlyToggle.TextScaled = true
FlyToggle.Font = Enum.Font.SourceSansBold
FlyToggle.Parent = MainFrame

-- 速度输入
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.4, 0, 0, 30)
SpeedLabel.Position = UDim2.new(0.05, 0, 0, 170)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "速度:"
SpeedLabel.TextColor3 = Color3.new(1, 1, 1)
SpeedLabel.TextScaled = true
SpeedLabel.Font = Enum.Font.SourceSans
SpeedLabel.Parent = MainFrame

local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0.5, 0, 0, 30)
SpeedInput.Position = UDim2.new(0.45, 0, 0, 170)
SpeedInput.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
SpeedInput.Text = "5000"
SpeedInput.TextColor3 = Color3.new(1, 1, 1)
SpeedInput.TextScaled = true
SpeedInput.Font = Enum.Font.SourceSans
SpeedInput.Parent = MainFrame

-- 上升/下降按钮
local UpButton = Instance.new("TextButton")
UpButton.Size = UDim2.new(0.42, 0, 0, 35)
UpButton.Position = UDim2.new(0.05, 0, 0, 210)
UpButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.4)
UpButton.Text = "⬆️ 上升"
UpButton.TextColor3 = Color3.new(1, 1, 1)
UpButton.TextScaled = true
UpButton.Font = Enum.Font.SourceSansBold
UpButton.Parent = MainFrame

local DownButton = Instance.new("TextButton")
DownButton.Size = UDim2.new(0.42, 0, 0, 35)
DownButton.Position = UDim2.new(0.53, 0, 0, 210)
DownButton.BackgroundColor3 = Color3.new(0.4, 0.2, 0.2)
DownButton.Text = "⬇️ 下降"
DownButton.TextColor3 = Color3.new(1, 1, 1)
DownButton.TextScaled = true
DownButton.Font = Enum.Font.SourceSansBold
DownButton.Parent = MainFrame

-- 手动发射/返回按钮
local LaunchButton = Instance.new("TextButton")
LaunchButton.Size = UDim2.new(0.42, 0, 0, 35)
LaunchButton.Position = UDim2.new(0.05, 0, 0, 250)
LaunchButton.BackgroundColor3 = Color3.new(0, 0.4, 0.8)
LaunchButton.Text = "🚀 发射"
LaunchButton.TextColor3 = Color3.new(1, 1, 1)
LaunchButton.TextScaled = true
LaunchButton.Font = Enum.Font.SourceSansBold
LaunchButton.Parent = MainFrame

local ReturnButton = Instance.new("TextButton")
ReturnButton.Size = UDim2.new(0.42, 0, 0, 35)
ReturnButton.Position = UDim2.new(0.53, 0, 0, 250)
ReturnButton.BackgroundColor3 = Color3.new(0.5, 0.3, 0)
ReturnButton.Text = "💰 返回"
ReturnButton.TextColor3 = Color3.new(1, 1, 1)
ReturnButton.TextScaled = true
ReturnButton.Font = Enum.Font.SourceSansBold
ReturnButton.Parent = MainFrame

-- 统计显示
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(0.9, 0, 0, 50)
StatsLabel.Position = UDim2.new(0.05, 0, 0, 290)
StatsLabel.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
StatsLabel.Text = "运行次数: 0 | 总计: $0\n状态: 就绪"
StatsLabel.TextColor3 = Color3.new(0.7, 1, 0.7)
StatsLabel.TextScaled = true
StatsLabel.Font = Enum.Font.SourceSans
StatsLabel.Parent = MainFrame

-- 变量
local flying = false
local autoFarm = false
local flyConnection = nil
local monitorConnection = nil
local flySpeed = 5000
local totalRuns = 0
local totalEarned = 0
local startMoney = 0
local currentMoney = 0
local isLaunched = false

-- 更新角色引用的函数
local function updateCharacter()
    Character = Player.Character
    if Character then
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        Humanoid = Character:WaitForChild("Humanoid")
        
        -- 重新后重新启用按钮
        FlyToggle.Active = true
        UpButton.Active = true
        DownButton.Active = true
        SpeedInput.Editable = true
    end
end

-- 获取当前现金 (游戏使用Cash而非Money)
local function getCurrentMoney()
    local leaderstats = Player:WaitForChild("leaderstats", 5)
    if leaderstats then
        local cash = leaderstats:FindFirstChild("Cash")
        if cash then
            return tonumber(cash.Value) or 0
        end
    end
    return 0
end

-- Get current distance
local function getCurrentDistance()
    local leaderstats = Player:WaitForChild("leaderstats", 5)
    if leaderstats then
        local distance = leaderstats:FindFirstChild("Distance")
        if distance then
            return tonumber(distance.Value) or 0
        end
    end
    return 0
end

-- Calculate expected cash from distance (game formula)
local function calculateCashFromDistance(distance)
    if distance <= 0 then return 0 end
    local cash = (distance ^ 0.9) * 0.1
    return math.round(cash)
end

-- Clean up old connections
local function cleanup()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    
    if monitorConnection then
        monitorConnection:Disconnect()
        monitorConnection = nil
    end
    
    -- Remove any BodyMovers
    if HumanoidRootPart and HumanoidRootPart.Parent then
        for _, obj in pairs(HumanoidRootPart:GetChildren()) do
            if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") or obj:IsA("BodyMover") then
                obj:Destroy()
            end
        end
    end
end

-- Start flying forward (SIMPLE VERSION - just teleport)
local function startFlying()
    if not HumanoidRootPart or not HumanoidRootPart.Parent then
        updateCharacter()
        if not HumanoidRootPart then
            return
        end
    end
    
    cleanup() -- Clean up first
    
    flying = true
    FlyToggle.Text = "飞行: 开启"
    FlyToggle.TextColor3 = Color3.new(0.3, 1, 0.3)
    FlyToggle.BackgroundColor3 = Color3.new(0.1, 0.3, 0.1)
    
    -- Simply teleport to target distance at extreme height
    -- 15000 distance = ~$600
    HumanoidRootPart.CFrame = CFrame.new(15030, 9000000000, 0) -- 15000 + 30 (start offset)
    
    task.wait(0.5)
    
    -- Keep at extreme height to avoid any issues
    spawn(function()
        while flying do
            if HumanoidRootPart and HumanoidRootPart.Parent then
                -- Keep at extreme height
                if HumanoidRootPart.Position.Y < 9000000000 then
                    HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position.X, 9000000000, HumanoidRootPart.Position.Z)
                end
            end
            task.wait(0.1)
        end
    end)
end

-- Stop flying
local function stopFlying()
    flying = false
    FlyToggle.Text = "飞行: 关闭"
    FlyToggle.TextColor3 = Color3.new(1, 0.3, 0.3)
    FlyToggle.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    
    cleanup()
end

-- Auto return when reaching optimal cash (NOT NEEDED WITH INSTANT TELEPORT)
local function checkMoneyAndReturn()
    -- This function is no longer needed with instant teleport method
    -- Keep it empty for compatibility
end

-- Start auto farm cycle (INSTANT TELEPORT VERSION)
function startAutoFarmCycle()
    if not autoFarm then return end
    
    -- Update character if needed
    if not HumanoidRootPart or not HumanoidRootPart.Parent then
        updateCharacter()
    end
    
    -- Record starting cash BEFORE launching
    startMoney = getCurrentMoney()
    currentMoney = startMoney
    local startDistance = getCurrentDistance()
    
    MoneyLabel.Text = "现金: $0 | 距离: 0"
    print(string.format("开始 - 现金: $%d, 距离: %d", startMoney, startDistance))
    
    -- Launch
    LaunchRemote:FireServer()
    isLaunched = true
    StatsLabel.Text = string.format("运行次数: %d | 总计: $%d\n正在发射...", totalRuns, totalEarned)
    
    task.wait(2) -- Wait for launch to register
    
    -- INSTANT TELEPORT to 15000 distance at extreme height  
    print("传送到15000距离...")
    HumanoidRootPart.CFrame = CFrame.new(15030, 9000000000, 0) -- X=15030 for 15000 distance
    
    task.wait(3) -- Wait longer for position to register
    
    -- Auto return
    print("正在返回...")
    ReturnRemote:FireServer()
    isLaunched = false
    
    task.wait(2) -- Wait for reward
    
    local finalCash = getCurrentMoney()
    local earnedThisRun = finalCash - startMoney
    
    if earnedThisRun > 0 then
        totalRuns = totalRuns + 1
        totalEarned = totalEarned + earnedThisRun
        StatsLabel.Text = string.format("运行次数: %d | 总计: $%d\n本次赚取: $%d", totalRuns, totalEarned, earnedThisRun)
        MoneyLabel.Text = string.format("上次赚取: $%d", earnedThisRun)
        print(string.format("第 %d 次运行赚取: $%d", totalRuns, earnedThisRun))
    else
        print("未赚取金钱 - 重试...")
    end
    
    -- Continue auto farm
    if autoFarm then
        task.wait(1)
        startAutoFarmCycle()
    end
end

-- Button Handlers
AutoFarmToggle.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    if autoFarm then
        AutoFarmToggle.Text = "自动农场: 开启"
        AutoFarmToggle.BackgroundColor3 = Color3.new(0, 0.7, 0)
        AutoFarmToggle.TextColor3 = Color3.new(1, 1, 1)
        startAutoFarmCycle()
    else
        AutoFarmToggle.Text = "自动农场: 关闭"
        AutoFarmToggle.BackgroundColor3 = Color3.new(0.5, 0, 0)
        AutoFarmToggle.TextColor3 = Color3.new(1, 1, 1)
        stopFlying()
        isLaunched = false
    end
end)

LaunchButton.MouseButton1Click:Connect(function()
    if not HumanoidRootPart or not HumanoidRootPart.Parent then
        updateCharacter()
    end
    
    -- Get cash before launch
    startMoney = getCurrentMoney()
    currentMoney = startMoney
    print("起始现金:", startMoney)
    
    LaunchRemote:FireServer()
    isLaunched = true
    MoneyLabel.Text = "传送到15000..."
    LaunchButton.Text = "✅ 已发射"
    
    task.wait(2)
    
    -- INSTANT TELEPORT to 15000 distance
    print("传送到15000距离...")
    HumanoidRootPart.CFrame = CFrame.new(15030, 9000000000, 0)
    
    spawn(function()
        task.wait(0.5)
        LaunchButton.Text = "🚀 发射"
    end)
end)

FlyToggle.MouseButton1Click:Connect(function()
    if not HumanoidRootPart or not HumanoidRootPart.Parent then
        updateCharacter()
    end
    
    if flying then
        stopFlying()
    else
        -- Instant teleport method - no need for speed
        startFlying()
    end
end)

SpeedInput.FocusLost:Connect(function()
    flySpeed = tonumber(SpeedInput.Text) or 5000
end)

UpButton.MouseButton1Click:Connect(function()
    if not HumanoidRootPart or not HumanoidRootPart.Parent then
        updateCharacter()
    end
    
    if HumanoidRootPart then
        -- Teleport up 50 studs
        HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + Vector3.new(0, 50, 0)
    end
end)

DownButton.MouseButton1Click:Connect(function()
    if not HumanoidRootPart or not HumanoidRootPart.Parent then
        updateCharacter()
    end
    
    if HumanoidRootPart then
        -- Don't go below 400 to avoid ALL obstacles
        local newY = math.max(HumanoidRootPart.Position.Y - 30, 400)
        HumanoidRootPart.CFrame = CFrame.new(
            HumanoidRootPart.Position.X,
            newY,
            HumanoidRootPart.Position.Z
        )
    end
end)

ReturnButton.MouseButton1Click:Connect(function()
    if not isLaunched then return end
    
    -- Get final distance before returning
    local finalX = HumanoidRootPart and HumanoidRootPart.Position.X or 0
    local finalDistance = math.max(finalX - 30, 0)
    
    stopFlying()
    ReturnRemote:FireServer()
    
    -- Wait for cash to update
    task.wait(1)
    
    local finalCash = getCurrentMoney()
    local earned = finalCash - startMoney
    
    if earned > 0 then
        totalRuns = totalRuns + 1
        totalEarned = totalEarned + earned
        MoneyLabel.Text = string.format("赚取现金: $%d | 距离: %d", earned, math.round(finalDistance))
        StatsLabel.Text = string.format("运行次数: %d | 总计: $%d\n上次赚取 earned: $%d", totalRuns, totalEarned, earned)
        print(string.format("第 %d - 次运行: $%d, 赚取: %d", totalRuns, earned, math.round(finalDistance)))
    else
        StatsLabel.Text = string.format("运行次数: %d | 总计: $%d\n未赚取现金", totalRuns, totalEarned)
    end
    
    isLaunched = false
    ReturnButton.Text = "✅ 已返回"
    
    spawn(function()
        task.wait(1)
        ReturnButton.Text = "💰 返回"
    end)
end)

-- Monitor for display updates only
spawn(function()
    while true do
        if isLaunched and HumanoidRootPart then
            local currentX = HumanoidRootPart.Position.X
            local distance = math.max(currentX - 30, 0)
            local expectedCash = calculateCashFromDistance(distance)
            MoneyLabel.Text = string.format("Distance: %d | Expected: $%d", math.round(distance), expectedCash)
        end
        task.wait(0.5)
    end
end)

-- Update cash display periodically
spawn(function()
    while true do
        local cash = getCurrentMoney()
        local distance = getCurrentDistance()
        
        -- Only update total cash display when not flying
        if not isLaunched then
            local cashText = string.format("Total Cash: $%d | Best Distance: %d", cash, distance)
            -- Don't override the earned display during runs
        end
        
        task.wait(1)
    end
end)

-- Handle character respawn
Player.CharacterAdded:Connect(function(char)
    task.wait(1) -- Wait for character to load
    updateCharacter()
    
    -- Reset states
    flying = false
    isLaunched = false
    FlyToggle.Text = "飞行: 关闭"
    FlyToggle.TextColor3 = Color3.new(1, 0.3, 0.3)
    FlyToggle.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    
    -- Continue auto farm if it was on
    if autoFarm then
        task.wait(2)
        startAutoFarmCycle()
    end
end)

-- Clean up on character death
if Humanoid then
    Humanoid.Died:Connect(function()
        cleanup()
        flying = false
        isLaunched = false
    end)
end

print("=== 自动农场飞行脚本已加载 ===")
print("")
print("游戏信息:")
print("• 现金公式: (距离^0.9) * 0.1")
print("• 距离 = X 坐标 - 30")
print("• 传送到15000距离 (~$600)")
print("")
print("功能:")
print("✅ 直接传送到15000距离")
print("✅ 极高位置（90亿）以避免所有障碍")
print("✅ 每次运行约600美元（比更高距离更安全）")
print("✅ 自动农场模式持续运行")
print("✅ 重生后继续工作")
print("")
print("使用方法:")
print("1. 点击自动农场开始")
print("2. 脚本自动发射、传送和返回")
print("3. 每次运行稳定赚取约600美元")