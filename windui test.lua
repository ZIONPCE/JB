-- 卡密系统开始
local validKeys = {
    "Z123-4567-890A", -- 示例卡密
}

local function checkKey(key)
    for _, validKey in pairs(validKeys) do
        if key == validKey then
            return true
        end
    end
    return false
end

-- 创建卡密验证窗口
local KeyAuthWindow = WindUI:CreateWindow({
    Title = "Z脚本 - 卡密验证",
    Icon = "lock",
    Size = UDim2.fromOffset(400, 250),
    Theme = "Dark",
    Resizable = false
})

local AuthTab = KeyAuthWindow:Tab({
    Title = "验证",
    Icon = "key"
})

local AuthSection = AuthTab:Section({
    Title = "请输入您的卡密"
})

local KeyInput = AuthSection:Textbox({
    Title = "卡密",
    Placeholder = "XXXX-XXXX-XXXX"
})

local StatusLabel = AuthSection:Label({
    Title = "状态: 等待验证",
    TextXAlignment = "Left"
})

AuthSection:Button({
    Title = "验证",
    Callback = function()
        local key = KeyInput:GetValue()
        if checkKey(key) then
            StatusLabel:SetTitle("状态: 验证成功!")
            wait(1)
            KeyAuthWindow:Destroy()
            -- 验证通过后继续执行原脚本
            print("反挂机开启")
            local vu = game:GetService("VirtualUser")
            -- 这里继续您原来的脚本内容...
        else
            StatusLabel:SetTitle("状态: 卡密无效!")
        end
    end
})

AuthSection:Label({
    Title = "没有卡密? 请联系作者获取",
    TextXAlignment = "Center"
})

return -- 阻止直接执行后面的代码，直到验证通过
-- 卡密系统结束

print("反挂机开启")
		local vu = game:GetService("VirtualUser")
		game:GetService("Players").LocalPlayer.Idled:connect(function()
		   vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
		   wait(1)
		   vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
		end)

local Sound = Instance.new("Sound")
        Sound.Parent = game.SoundService
        Sound.SoundId = "rbxassetid://4590662766"
        Sound.Volume = 3
        Sound.PlayOnRemove = true
        Sound:Destroy()

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/CNHM/asg/refs/heads/main/wind%20ui.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Z脚本",
    Icon = "user-check",
    Author = "作者:Z某人",
    Folder = "CloudHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    Background = "", -- rbxassetid only
    BackgroundImageTransparency = 0.42,
    HideSearchBar = false,
    ScrollBarEnabled = true,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            print("clicked")
        end,
    },
})

Window:EditOpenButton({
    Title = "   打开Z脚本   ",
    Icon = "shield-check",
    CornerRadiu = UDim.new(0,16),
    StrokeThickness = 3,
    Color = ColorSequence.new( 
        Color3.fromHex("000000"), 
        Color3.fromHex("FFFFFF"), 
        Color3.fromHex("000000")   
    ),
    Draggable = true,
})

local Tab = Window:Tab({
    Title = "公告",
    Icon = "app-window",
    Locked = false,
})

local Section = Tab:Section({ 
    Title = "重做脚本",
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
})

local Section = Tab:Section({ 
    Title = "QQ群11007580643",
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
})

local Section = Tab:Section({ 
    Title = "QQ群21045061775",
    TextXAlignment = "Left",
    TextSize = 17, -- Default Size
})

local Tab = Window:Tab({
    Title = "通用",
    Icon = "bolt",
    Locked = false,
})

local Slider = Tab:Slider({
    Title = "移动速度",
    
    Step = 1,
    
    Value = {
        Min = 0,
        Max = 320,
        Default = 16,
    },
    Callback = function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

local Slider = Tab:Slider({
    Title = "跳跃高度",
    
    Step = 1,
    
    Value = {
        Min = 50,
        Max = 1000,
        Default = 50,
    },
    Callback = function(value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
    end
})

local Slider = Tab:Slider({
    Title = "重力",
    
    -- To make float number supported, 
    -- make the Step a float number.
    -- example: Step = 0.1
    Step = 1,
    
    Value = {
        Min = 0,
        Max = 1000,
        Default = 196,
    },
    Callback = function(value)
    game.Workspace.Gravity = value
    end
})

local Button = Tab:Button({
    Title = "爬墙",
    Desc = "",
    Locked = false,
    Callback = function()
    loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Wall-Walk-9153"))()
    end
})

local Button = Tab:Button({
    Title = "无限跳",
    Desc = "",
    Locked = false,
    Callback = function()
    loadstring(game:HttpGet("https://pastebin.com/raw/V5PQy3y0", true))()
    end
})

local Button = Tab:Button({
    Title = "选人甩飞",
    Desc = "",
    Locked = false,
    Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Auto%20Fling%20Player'))()
    end
})

local Button = Tab:Button({
    Title = "飞行V3",
    Desc = "",
    Locked = false,
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/CNHM/asg/refs/heads/main/fly.lua"))()
    end
})

local Button = Tab:Button({
    Title = "穿墙",
    Desc = "大部分服务器通用",
    Locked = false,
    Callback = function()
    local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.Name = "NoclipGUI"

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 150)
frame.Position = UDim2.new(0.5, -125, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.BorderSizePixel = 2
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
titleBar.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "穿墙"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextScaled = true
titleLabel.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0.1, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeButton.Text = "关闭"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Parent = titleBar

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 25, 0, 25)
minimizeButton.Position = UDim2.new(1, -60, 0.1, 0)
minimizeButton.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
minimizeButton.Text = "收缩"
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.Parent = titleBar

local toggleNoclipButton = Instance.new("TextButton")
toggleNoclipButton.Size = UDim2.new(0.8, 0, 0, 40)
toggleNoclipButton.Position = UDim2.new(0.1, 0, 0.4, 0)
toggleNoclipButton.Text = "穿墙: 关闭"
toggleNoclipButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
toggleNoclipButton.TextColor3 = Color3.new(1, 1, 1)
toggleNoclipButton.Parent = frame

local creditLabel = Instance.new("TextLabel")
creditLabel.Size = UDim2.new(1, 0, 0, 20)
creditLabel.Position = UDim2.new(0, 0, 0.85, 0)
creditLabel.BackgroundTransparency = 1
creditLabel.Text = ""
creditLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
creditLabel.TextScaled = true
creditLabel.Font = Enum.Font.SourceSansBold
creditLabel.Parent = frame

-- Noclip Functionality
local noclip = false
local function toggleNoclip()
    noclip = not noclip
    toggleNoclipButton.Text = noclip and "穿墙: 开启" or "穿墙: 关闭"
    toggleNoclipButton.BackgroundColor3 = noclip and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)

    while noclip do
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
        task.wait()
    end
end

toggleNoclipButton.MouseButton1Click:Connect(toggleNoclip)

-- Minimize GUI Function
local minimized = false
minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, obj in pairs(frame:GetChildren()) do
        if obj ~= titleBar and obj ~= creditLabel then
            obj.Visible = not minimized
        end
    end
    frame.Size = minimized and UDim2.new(0, 250, 0, 30) or UDim2.new(0, 250, 0, 150)
    minimizeButton.Text = minimized and "展开" or "收缩"
end)

-- Close GUI Function
closeButton.MouseButton1Click:Connect(function()
    noclip = false
    screenGui:Destroy()
end)

print("穿墙UI加载成功！")
    end
})

local Button = Tab:Button({
    Title = "快速互动",
    Desc = "",
    Locked = false,
    Callback = function()
    game.ProximityPromptService.PromptButtonHoldBegan:Connect(function(v)
    v.HoldDuration = 0
end)
    end
})

local Button = Tab:Button({
    Title = "电脑键盘",
    Desc = "高级版",
    Locked = false,
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Xxtan31/Ata/main/deltakeyboardcrack.txt", true))()
    end
})

local Button = Tab:Button({
    Title = "透视",
    Desc = "Z某制作",
    Locked = false,
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ZIONPCE/raw/refs/heads/main/ESP.lua"))()
    end
})

local Button = Tab:Button({
    Title = "导",
    Desc = "",
    Locked = false,
    Callback = function()
    loadstring(game:HttpGet("https://pastebin.com/raw/FWwdST5Y"))()
    end
})

local Tab = Window:Tab({
    Title = "99天",
    Icon = "trees",
    Locked = false,
})

local Button = Tab:Button({
    Title = "VEX",
    Desc = "Z某汉化",
    Locked = false,
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ZIONPCE/JB/refs/heads/main/99%20nights%20in%20the%20forest.lua"))()
    end
})

local Tab = Window:Tab({
    Title = "建造一架飞机",
    Icon = "plane",
    Locked = false,
})

local Button = Tab:Button({
    Title = "NEPT",
    Desc = "Z某汉化",
    Locked = false,
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ZIONPCE/JB/refs/heads/main/b.lua"))()
    end
})

local Tab = Window:Tab({
    Title = "死铁轨",
    Icon = "train-track",
    Locked = false,
})

local Button = Tab:Button({
    Title = "攻速",
    Desc = "",
    Locked = false,
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/HeadHarse/DeadRails/refs/heads/main/V4SWING"))()
    end
})

local Button = Tab:Button({
    Title = "NovazHub",
    Desc = "Z某汉化",
    Locked = false,
    Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ZIONPCE/JB/refs/heads/main/autofarmbond.lua"))()
    end
})

local Tab = Window:Tab({
    Title = "被遗弃",
    Icon = "drama",
    Locked = false,
})

local Button = Tab:Button({
    Title = "Sigmasaken V9",
    Desc = "",
    Locked = false,
    Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/sigmaboy-sigma-boy/sigmaboy-sigma-boy/refs/heads/main/StaminaSettings.ESP.PIDC.raw'))()
    end
})

local Button = Tab:Button({
    Title = "XA",
    Desc = "",
    Locked = false,
    Callback = function()
    loadstring(game:HttpGet(('https://github.com/DevSloPo/Main/raw/main/Forsaken')))()
    end
})

local Button = Tab:Button({
    Title = "Httadmin",
    Desc = "",
    Locked = false,
    Callback = function()
    loadstring(game:HttpGet"https://raw.githubusercontent.com/OWOWOWWOW/HTT/main/HT.lua")()
    end
})