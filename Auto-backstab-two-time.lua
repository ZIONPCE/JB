local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- GUI 设置
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BackstabToggleGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = lp:WaitForChild("PlayerGui")

-- 切换按钮
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 150, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 20
toggleButton.Text = "背刺 关闭"
toggleButton.Parent = screenGui

-- 范围标签
local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.new(0, 150, 0, 20)
rangeLabel.Position = UDim2.new(0, 10, 0, 55)
rangeLabel.BackgroundTransparency = 1
rangeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
rangeLabel.Font = Enum.Font.SourceSans
rangeLabel.TextSize = 16
rangeLabel.Text = "Range:"
rangeLabel.Parent = screenGui

-- 范围输入文本框
local rangeBox = Instance.new("TextBox")
rangeBox.Size = UDim2.new(0, 150, 0, 25)
rangeBox.Position = UDim2.new(0, 10, 0, 75)
rangeBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
rangeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
rangeBox.Font = Enum.Font.SourceSans
rangeBox.TextSize = 16
rangeBox.PlaceholderText = "输入范围 (1 - 10)"
rangeBox.Text = "4"
rangeBox.ClearTextOnFocus = false
rangeBox.Parent = screenGui

-- 变量
local enabled = false
local cooldown = false
local lastTarget = nil
local range = 4
local daggerRemote = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
local killerNames = { "Jason", "c00lkidd", "JohnDoe", "1x1x1x1", "Noli" }
local killersFolder = workspace:WaitForChild("Players"):WaitForChild("Killers")

-- GUI 切换
toggleButton.MouseButton1Click:Connect(function()
	enabled = not enabled
	toggleButton.Text = "背刺: " .. (enabled and "开启" or "关闭")
	toggleButton.BackgroundColor3 = enabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(30, 30, 30)
end)

-- 文本范围处理
rangeBox.FocusLost:Connect(function()
	local input = tonumber(rangeBox.Text)
	if input and input >= 1 and input <= 10 then
		range = input
	else
		rangeBox.Text = tostring(range) -- 恢复到最后一个有效值
	end
end)

-- 铺助函数: 检查玩家是否在杀手后方
local function isBehindTarget(hrp, targetHRP)
	local direction = -targetHRP.CFrame.LookVector
	local toPlayer = (hrp.Position - targetHRP.Position)
	local distance = toPlayer.Magnitude
	local isBehind = toPlayer:Dot(direction) > 0.5
	return distance <= range and isBehind
end

-- 主循环
RunService.Heartbeat:Connect(function()
	if not enabled or cooldown then return end

	local char = lp.Character
	if not (char and char:FindFirstChild("HumanoidRootPart")) then return end
	local hrp = char.HumanoidRootPart

	for _, name in ipairs(killerNames) do
		local killer = killersFolder:FindFirstChild(name)
		if killer and killer:FindFirstChild("HumanoidRootPart") then
			local kHRP = killer.HumanoidRootPart

			if isBehindTarget(hrp, kHRP) and killer ~= lastTarget then
				cooldown = true
				lastTarget = killer

				-- 开始1.1秒的持续传送至杀手后方
				local start = tick()
				local didDagger = false

				local connection
				connection = RunService.Heartbeat:Connect(function()
					if not (char and char.Parent and kHRP and kHRP.Parent) then
						if connection then connection:Disconnect() end
						return
					end
					local elapsed = tick() - start
					if elapsed >= 1.1 then
						if connection then connection:Disconnect() end
						return
					end

					-- 持续传送至杀手后方
					local behindPos = kHRP.Position - (kHRP.CFrame.LookVector * 2)
					hrp.CFrame = CFrame.new(behindPos, behindPos + kHRP.CFrame.LookVector)

					-- 对齐朝向 (仅在开始时一次)
					if not didDagger then
						didDagger = true

						-- 对齐至杀手朝向一段时间
						local faceStart = tick()
						local faceConn
						faceConn = RunService.Heartbeat:Connect(function()
							if tick() - faceStart >= 1.3 or not kHRP or not kHRP.Parent then
								if faceConn then faceConn:Disconnect() end
								return
							end
							hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + kHRP.CFrame.LookVector)
						end)

						-- 首次传送并调整朝向之后使用匕首
						daggerRemote:FireServer("UseActorAbility", "Dagger")
					end
				end)

				-- 等待并在离开范围后重置冷却
				task.delay(2, function()
					RunService.Heartbeat:Wait()
					while isBehindTarget(hrp, kHRP) do
						RunService.Heartbeat:Wait()
					end
					lastTarget = nil
					cooldown = false
				end)

				break
			end
		end
	end
end)