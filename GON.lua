-- 独特UI脚本 by [Z某人]
-- 版本: 1.0
-- 功能: 动态3D卡片式UI系统

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- 创建主屏幕GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DynamicCardUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = gui

-- 背景模糊效果
local blur = Instance.new("BlurEffect")
blur.Name = "UIBlur"
blur.Size = 0
blur.Parent = game:GetService("Lighting")

-- 3D卡片容器
local cardContainer = Instance.new("Frame")
cardContainer.Name = "CardContainer"
cardContainer.AnchorPoint = Vector2.new(0.5, 0.5)
cardContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
cardContainer.Size = UDim2.new(0.8, 0, 0.7, 0)
cardContainer.BackgroundTransparency = 1
cardContainer.Parent = screenGui

-- 卡片数据
local cards = {
    {
        Title = "角色状态",
        Icon = "rbxassetid://123456789",
        Color = Color3.fromRGB(85, 170, 255),
        Content = function()
            -- 动态生成内容
        end
    },
    {
        Title = "物品栏",
        Icon = "rbxassetid://987654321",
        Color = Color3.fromRGB(255, 170, 0),
        Content = function()
            -- 动态生成内容
        end
    },
    -- 添加更多卡片...
}

local activeCards = {}
local currentAngle = 0
local targetAngle = 0

-- 创建3D卡片
local function create3DCard(cardData, index)
    local card = Instance.new("Frame")
    card.Name = "Card_"..index
    card.Size = UDim2.new(0.25, 0, 0.8, 0)
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.new(0.5, 0, 0.5, 0)
    card.BackgroundColor3 = cardData.Color
    card.BackgroundTransparency = 0.2
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.ZIndex = index
    
    -- 3D效果
    local cardRotator = Instance.new("Frame")
    cardRotator.Name = "Rotator"
    cardRotator.Size = UDim2.new(1, 0, 1, 0)
    cardRotator.BackgroundTransparency = 1
    cardRotator.Parent = card
    
    -- 卡片标题
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0.1, 0)
    title.Position = UDim2.new(0, 0, 0.05, 0)
    title.Text = cardData.Title
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.BackgroundTransparency = 1
    title.Parent = cardRotator
    
    -- 卡片内容
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(0.9, 0, 0.7, 0)
    contentFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
    contentFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    contentFrame.BackgroundTransparency = 0.5
    contentFrame.Parent = cardRotator
    
    -- 生成动态内容
    cardData.Content(contentFrame)
    
    -- 交互效果
    local button = Instance.new("TextButton")
    button.Name = "CardButton"
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = card
    
    button.MouseEnter:Connect(function()
        targetAngle = (index - 1) * (360 / #cards)
        card.BackgroundTransparency = 0
    end)
    
    button.MouseLeave:Connect(function()
        card.BackgroundTransparency = 0.2
    end)
    
    button.MouseButton1Click:Connect(function()
    
    -- 卡片点击效果
        local originalSize = card.Size
        local tween = TweenService:Create(card, TweenInfo.new(0.2), {
            Size = UDim2.new(originalSize.X.Scale * 1.1, 0, originalSize.Y.Scale * 1.1, 0)
        })
        tween:Play()
        tween.Completed:Wait()
        tween = TweenService:Create(card, TweenInfo.new(0.1), {
            Size = originalSize
        })
        tween:Play()
        
        -- 执行卡片特定动作
        print("Selected:", cardData.Title)
    end)
    
    card.Parent = cardContainer
    table.insert(activeCards, {
        Instance = card,
        Index = index,
        Angle = (index - 1) * (360 / #cards)
    })
end

-- 初始化所有卡片
for i, cardData in ipairs(cards) do
    create3DCard(cardData, i)
end

-- 3D旋转效果
local function updateCardPositions()
    local center = Vector2.new(cardContainer.AbsoluteSize.X / 2, cardContainer.AbsoluteSize.Y / 2)
    local radius = cardContainer.AbsoluteSize.X * 0.4
    
    for _, cardData in ipairs(activeCards) do
        local angle = math.rad(cardData.Angle + currentAngle)
        local x = center.x + math.cos(angle) * radius - cardData.Instance.AbsoluteSize.X / 2
        local y = center.y + math.sin(angle) * cardContainer.AbsoluteSize.Y * 0.2 - cardData.Instance.AbsoluteSize.Y / 2
        
        -- 3D深度效果
        local depthScale = 0.7 + math.cos(angle) * 0.3
        cardData.Instance.Size = UDim2.new(0.25 * depthScale, 0, 0.8 * depthScale, 0)
        cardData.Instance.ZIndex = math.floor(depthScale * 10)
        
        -- 更新位置
        cardData.Instance.Position = UDim2.new(0, x, 0, y)
        
        -- 旋转卡片使其始终面向玩家
        local rotator = cardData.Instance:FindFirstChild("Rotator")
        if rotator then
            rotator.Rotation = -math.deg(angle) * 0.2
        end
    end
end
-- 自动旋转
local function autoRotate()
    while true do
        targetAngle = (targetAngle + 0.1) % 360
        wait(0.05)
    end
end
-- 平滑动画
local function smoothUpdate()
    RunService.Heartbeat:Connect(function(dt)
        currentAngle = currentAngle + (targetAngle - currentAngle) * dt * 5
        updateCardPositions()
    end)
    
    -- 初始化UI状态
local function toggleUI(visible)
    local targetBlur = visible and 10 or 0
    local targetTransparency = visible and 0 or 1
    
    local tween = TweenService:Create(blur, TweenInfo.new(0.5), {
        Size = targetBlur
    })
    tween:Play()
    
    for _, cardData in ipairs(activeCards) do
        local tween = TweenService:Create(cardData.Instance, TweenInfo.new(0.5), {
            BackgroundTransparency = visible and 0.2 or 1
        })
        tween:Play()
    end
end

-- 键盘快捷键
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Tab then
        toggleUI(screenGui.Enabled)
        screenGui.Enabled = not screenGui.Enabled
    end
end
)
-- 启动效果
coroutine.wrap(autoRotate)()
smoothUpdate()
toggleUI(true)
screenGui.Enabled = true
