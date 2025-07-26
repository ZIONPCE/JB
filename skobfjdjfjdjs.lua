-- 自动格挡 RayfIeld 脚本 (全功能版)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local PlayerGui = lp:WaitForChild("PlayerGui")
local Humanoid, Animator

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
Name = "自动格挡中心",
LoadingTitle = "自动格挡脚本",
LoadingSubtitle = "由Z某人翻译",
ConfigurationSaving = {
Enabled = true,
FolderName = "AutoBlockHub",
FileName = "设置"
},
Discord = {Enabled = false},
KeySystem = false
})

local AutoBlockTab = Window:CreateTab("自动格挡", 4483362458)
local FakeBlockTab = Window:CreateTab("虚假格挡", 4483362458)
local AutoPunchTab = Window:CreateTab("自动出拳", 4483362458)
local CustomAnimationsTab = Window:CreateTab("自定义动画", 4483362458)


-- 动画 ID
local autoBlockTriggerAnims = {
    "126830014841198", "126355327951215", "121086746534252", "18885909645",
    "98456918873918", "105458270463374", "83829782357897", "125403313786645",
    "118298475669935", "82113744478546", "70371667919898", "99135633258223",
    "97167027849946", "109230267448394", "139835501033932", "126896426760253",
    "109667959938617", "126681776859538", "129976080405072", "121293883585738"
}

-- 状态变量
local autoBlockOn = false
local strictRangeOn = false
local looseFacing = true
local detectionRange = 18

local autoPunchOn = false
local flingPunchOn = false
local flingPower = 10000
local hiddenfling = false
local aimPunch = false

local customBlockEnabled = false
local customBlockAnimId = ""
local customPunchEnabled = false
local customPunchAnimId = ""

local lastBlockTime = 0
local lastPunchTime = 0

local blockAnimIds = {
"72722244508749",
"96959123077498"
}
local punchAnimIds = {
"87259391926321"
}

-- GUI 开关
AutoBlockTab:CreateToggle({
Name = "自动格挡",
CurrentValue = false,
Callback = function(Value) autoBlockOn = Value end
})

AutoBlockTab:CreateToggle({
Name = "严格范围",
CurrentValue = false,
Callback = function(Value) strictRangeOn = Value end
})

AutoBlockTab:CreateDropdown({
Name = "朝向检测",
Options = {"宽松", "严格"},
CurrentOption = "宽松",
Callback = function(Option) looseFacing = Option == "宽松" end
})

AutoBlockTab:CreateInput({
Name = "检测范围",
PlaceholderText = "18",
RemoveTextAfterFocusLost = false,
Callback = function(Text)
detectionRange = tonumber(Text) or detectionRange
end
})

FakeBlockTab:CreateButton({
    Name = "加载虚假格挡",
    Callback = function()
        pcall(function()
            local fakeGui = PlayerGui:FindFirstChild("FakeBlockGui")
            if not fakeGui then
                local success, result = pcall(function()
                    return loadstring(game:HttpGet("https://pastebin.com/raw/ztnYv27k"))()
                end)
                if not success then
                    warn("❌ 加载虚假格挡 GUI 失败:", result)
                end
            else
                fakeGui.Enabled = true
                print("✅ 虚假格挡 GUI 已启用")
            end
        end)
    end
})

AutoPunchTab:CreateToggle({
Name = "自动出拳",
CurrentValue = false,
Callback = function(Value) autoPunchOn = Value end
})

AutoPunchTab:CreateToggle({
Name = "甩动出拳",
CurrentValue = false,
Callback = function(Value) flingPunchOn = Value end
})

AutoPunchTab:CreateToggle({
Name = "瞄准出拳 (注视目标3秒)",
CurrentValue = false,
Callback = function(Value) aimPunch = Value end
})

AutoPunchTab:CreateSlider({
Name = "甩动力度",
Range = {5000, 50000},
Increment = 1000,
CurrentValue = 10000,
Callback = function(Value) flingPower = Value end
})

CustomAnimationsTab:CreateInput({
Name = "自定义格挡动画",
PlaceholderText = "动画 ID",
RemoveTextAfterFocusLost = false,
Callback = function(Text) customBlockAnimId = Text end
})

CustomAnimationsTab:CreateToggle({
Name = "启用自定义格挡动画",
CurrentValue = false,
Callback = function(Value) customBlockEnabled = Value end
})

CustomAnimationsTab:CreateInput({
Name = "自定义出拳动画 (不适应M3/M4)",
PlaceholderText = "动画 ID",
RemoveTextAfterFocusLost = false,
Callback = function(Text) customPunchAnimId = Text end
})

CustomAnimationsTab:CreateToggle({
Name = "启用自定义出拳动画",
CurrentValue = false,
Callback = function(Value) customPunchEnabled = Value end
})

-- 辅助函数
local function fireRemoteBlock()
local args = {"UseActorAbility", "Block"}
ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end

local function isFacing(localRoot, targetRoot)
local dir = (localRoot.Position - targetRoot.Position).Unit
local dot = targetRoot.CFrame.LookVector:Dot(dir)
return looseFacing and dot > -0.3 or dot > 0
end

local function playCustomAnim(animId, isPunch)
    if not Humanoid then
        warn("缺少人形对象")
        return
    end

    if not animId or animId == "" then
        warn("未提供动画 ID")
        return
    end

    local now = tick()
    local lastTime = isPunch and lastPunchTime or lastBlockTime
    if now - lastTime < 1 then
        return
    end

    -- 停止其他已知动画
    for _, track in ipairs(Humanoid:GetPlayingAnimationTracks()) do
        local animNum = tostring(track.Animation.AnimationId):match("%d+")
        if table.find(isPunch and punchAnimIds or blockAnimIds, animNum) then
            track:Stop()
        end
    end

    -- 创建并加载动画
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. animId

    local success, track = pcall(function()
        return Humanoid:LoadAnimation(anim)
    end)

    if success and track then
        print("✅ 正在播放自定义" .. (isPunch and "出拳" or "格挡") .. " 动画:", animId)
        track:Play()
        if isPunch then
            lastPunchTime = now
        else
            lastBlockTime = now
        end
    else
        warn("❌ 加载或播放自定义动画失败: " .. animId)
    end
end

-- 甩动协程
coroutine.wrap(function()
    local hrp, c, vel, movel = nil, nil, nil, 0.1
    while true do
        RunService.Heartbeat:Wait()
        if hiddenfling then
            while hiddenfling and not (c and c.Parent and hrp and hrp.Parent) do
                RunService.Heartbeat:Wait()
                c = lp.Character
                hrp = c and c:FindFirstChild("HumanoidRootPart")
            end
            if hiddenfling then
                vel = hrp.Velocity
                hrp.Velocity = vel * flingPower + Vector3.new(0, flingPower, 0)
                RunService.RenderStepped:Wait()
                hrp.Velocity = vel
                RunService.Stepped:Wait()
                hrp.Velocity = vel + Vector3.new(0, movel, 0)
                movel = movel * -1
            end
        end
    end
end)()

-- 自动格挡 + 出拳检测循环
RunService.Heartbeat:Connect(function()
local myChar = lp.Character
if not myChar then return end
local myRoot = myChar:FindFirstChild("HumanoidRootPart")
Humanoid = myChar:FindFirstChildOfClass("Humanoid")

for _, plr in ipairs(Players:GetPlayers()) do  
    if plr ~= lp and plr.Character then  
        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")  
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")  
        local animTracks = hum and hum:FindFirstChildOfClass("Animator") and hum:FindFirstChildOfClass("Animator"):GetPlayingAnimationTracks()  
        if hrp and myRoot and (hrp.Position - myRoot.Position).Magnitude <= detectionRange then  
            for _, track in ipairs(animTracks or {}) do  
                local id = tostring(track.Animation.AnimationId):match("%d+")  
                if table.find(autoBlockTriggerAnims, id) then  
                    if autoBlockOn and (not strictRangeOn or (hrp.Position - myRoot.Position).Magnitude <= detectionRange) then  
                        if isFacing(myRoot, hrp) then  
                            fireRemoteBlock()  
                            if customBlockEnabled and customBlockAnimId ~= "" then  
                                playCustomAnim(customBlockAnimId, false)  
                            end  
                        end  
                    end  
                end  
            end  
        end  
    end  
end  

-- 自动出拳
if autoPunchOn then  
    local gui = PlayerGui:FindFirstChild("MainUI")  
    local punchBtn = gui and gui:FindFirstChild("AbilityContainer") and gui.AbilityContainer:FindFirstChild("Punch")  
    local charges = punchBtn and punchBtn:FindFirstChild("Charges")  
    if charges and charges.Text == "1" then  
        for _, player in ipairs(Players:GetPlayers()) do  
            if player ~= lp and player.Character then  
                local root = player.Character:FindFirstChild("HumanoidRootPart")  
                if root and myRoot and (root.Position - myRoot.Position).Magnitude <= 10 then  
                    -- 面向玩家
                    if aimPunch then
                       myRoot.CFrame = CFrame.lookAt(myRoot.Position, root.Position)
                    end
                    -- 出拳 
                    for _, conn in ipairs(getconnections(punchBtn.MouseButton1Click)) do  
                        pcall(function() conn:Fire() end)  
                    end  
                    if flingPunchOn then  
                        hiddenfling = true  
                        TweenService:Create(myRoot, TweenInfo.new(0.04, Enum.EasingStyle.Linear), {CFrame = root.CFrame}):Play()  
                        task.delay(1.5, function() hiddenfling = false end)  
                    end  
                    if customPunchEnabled and customPunchAnimId ~= "" then  
                        playCustomAnim(customPunchAnimId, true)  
                    end  
                    break  
                end  
            end  
        end  
    end  
end

end)
-- 持续自定义动画替换器 (启用后永久运行)
task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()

        local char = lp.Character
        if not char then continue end

        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
        if not animator then continue end

        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            local animId = tostring(track.Animation.AnimationId):match("%d+")

            -- 格挡动画替换
            if customBlockEnabled and customBlockAnimId ~= "" and table.find(blockAnimIds, animId) then
                track:Stop()
                local newAnim = Instance.new("Animation")
                newAnim.AnimationId = "rbxassetid://" .. customBlockAnimId
                local newTrack = animator:LoadAnimation(newAnim)
                newTrack:Play()
                break
            end

            -- 出拳动画替换
            if customPunchEnabled and customPunchAnimId ~= "" and table.find(punchAnimIds, animId) then
                track:Stop()
                local newAnim = Instance.new("Animation")
                newAnim.AnimationId = "rbxassetid://" .. customPunchAnimId
                local newTrack = animator:LoadAnimation(newAnim)
                newTrack:Play()
                break
            end
        end
    end
end)
