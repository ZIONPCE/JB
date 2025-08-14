local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local library
if RunService:IsStudio() then
	library = require(game:GetService("ReplicatedStorage").ModuleScript)
else
	library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Iliankytb/Iliankytb/main/Zentrix"))()
end

local function worldToViewport(point)
	Camera = workspace.CurrentCamera
	return Camera:WorldToViewportPoint(point)
end

library:CreateWindow({
	Title = "暗影脉冲 Alpha Z某人",
	Theme = "Default",
	Icon = 0,
	Intro = true,
	IntroTitle = "暗影脉冲 Alpha",
	KeyPC = Enum.KeyCode.K,
	Data = {
		EnableSavingData = true,
		DisableNotifyingLoadedData = false,
		FolderName = "ShadowPulseAlpha",
		FileName = "MainConfig"
	},
	Discord = {
		Enabled = true,
		DiscordLink = "https://discord.gg/E2TqYRsRP4",
		RememberJoin = true,
		Duration = 10
	},
	KeySystem = false,
	KeySettings = {
		Title = "Shadow Pulse Alpha Key System",
		Note = "the key is ShadowPulseAlpha",
		FileName = "SPAKey",
		SaveKey = true,
		GrabKeyFromSite = false,
		Key = {"ShadowPulseAlpha"},
		AddGetKeyButton = false,
		AddDiscordButton = false,
		DiscordLink = "NoInviteLink",
		GetKeyLink = "NoKeyLink"
	}
}, function(window)
	local tabMain = window:CreateTab("主菜单", 0)
	local tabEntities = window:CreateTab("实体工具", 0)
	local tabESP = window:CreateTab("透视", 0)

	local Entities = {
		["RushMoving"]    = { msg = "Rush Has 已生成!",            color = Color3.fromRGB(255, 0,   0)   },
		["AmbushMoving"]  = { msg = "Ambush Has 已生成!",          color = Color3.fromRGB(0,   255, 0)   },
		["BackdoorRush"]  = { msg = "Blitz Has 已生成!",           color = Color3.fromRGB(0,   255, 0)   },
		["GlitchRush"]    = { msg = "Glitch Rush Has 已生成!",     color = Color3.fromRGB(255, 128, 0)   },
		["GlitchAmbush"]  = { msg = "Glitch Ambush Has 已生成!",   color = Color3.fromRGB(255, 105, 180) },
		["SallyRig"]      = { msg = "Sally Has 已生成!",           color = Color3.fromRGB(255, 192, 203) },
		["GlitchCube"]    = { msg = "Glitch Fragment Has 已生成!", color = Color3.fromRGB(255, 255, 0)   },
		["A-60"]          = { msg = "A-60 Has 已生成!",            color = Color3.fromRGB(255, 0,   0)   },
		["A-120"]         = { msg = "A-120 Has 已生成!",           color = Color3.fromRGB(128, 128, 128) },
		["Eyes"]          = { msg = "Eyes Has 已生成!",            color = Color3.fromRGB(160, 32,  240) },
		["Lookman"]       = { msg = "Lookman Has 已生成!",         color = Color3.fromRGB(0,   0,   0)   }
	}

	local KeyColor = Color3.fromRGB(255, 255, 0)
	local LeverColor = Color3.fromRGB(255, 165, 0)

	local EntityNotifierEnabled = false
	local EntityESPEnabled = false
	local KeyESPEnabled = false
	local LeverESPEnabled = false
	local AntiEyesEnabled = false
	local AutoRoomsEnabled = false

	local DrawingAvailable = (typeof(Drawing) == "table") and (type(Drawing.new) == "function")
	local EntityDrawings = {}
	local KeyHighlights = {}
	local LeverHighlights = {}
	local EyesConn = nil
	local autoRoomsCoroutine = nil
	local autoRoomsFuncRef = nil

	local function getCenterAndSize(inst)
		if not inst then return nil end
		if inst:IsA("Model") then
			local ok, size = pcall(function() return inst:GetExtentsSize() end)
			local ok2, cframe = pcall(function() return inst:GetModelCFrame() end)
			local modelCFrame = nil
			if ok2 and cframe then
				modelCFrame = cframe
			elseif inst.PrimaryPart and inst.PrimaryPart:IsA("BasePart") then
				modelCFrame = inst.PrimaryPart.CFrame
			elseif inst:FindFirstChild("HumanoidRootPart") and inst.HumanoidRootPart:IsA("BasePart") then
				modelCFrame = inst.HumanoidRootPart.CFrame
			end
			if ok and size and modelCFrame then
				return modelCFrame.Position, size
			end
			for _, d in ipairs(inst:GetDescendants()) do
				if d:IsA("BasePart") then
					return d.Position, Vector3.new(d.Size.X, d.Size.Y, d.Size.Z)
				end
			end
			return nil
		elseif inst:IsA("BasePart") then
			return inst.Position, Vector3.new(inst.Size.X, inst.Size.Y, inst.Size.Z)
		else
			for _, d in ipairs(inst:GetDescendants()) do
				if d:IsA("BasePart") then
					return d.Position, Vector3.new(d.Size.X, d.Size.Y, d.Size.Z)
				end
			end
			return nil
		end
	end

	local function createHighlightFallback(targetInst, color)
		if not targetInst then return nil end
		local existing = targetInst:FindFirstChild("ShadowPulse_Highlight")
		if existing and existing:IsA("Highlight") then
			existing.FillColor = color
			existing.OutlineColor = color
			return existing
		end
		local adornee = targetInst
		if not adornee:IsA("Model") and not adornee:IsA("BasePart") then
			for _, d in ipairs(targetInst:GetDescendants()) do
				if d:IsA("BasePart") then
					adornee = d
					break
				end
			end
		end
		local h = Instance.new("Highlight")
		h.Name = "ShadowPulse_Highlight"
		h.Adornee = adornee
		h.FillColor = color
		h.FillTransparency = 0.6
		h.OutlineColor = color
		h.OutlineTransparency = 0
		h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		h.Parent = targetInst
		return h
	end

	local function removeHighlight(map, inst)
		if not inst then return end
		if map[inst] then
			pcall(function() if map[inst] and map[inst].Destroy then map[inst]:Destroy() end end)
			map[inst] = nil
		end
		pcall(function()
			local h = inst:FindFirstChild("ShadowPulse_Highlight")
			if h then h:Destroy() end
		end)
	end

	local function createDrawingCircle(inst, color)
		if not DrawingAvailable then return nil end
		if EntityDrawings[inst] then return EntityDrawings[inst].circle end
		local ok, circ = pcall(function() return Drawing.new("Circle") end)
		if not ok or not circ then return nil end
		circ.Transparency = 1
		circ.Thickness = 2
		circ.Filled = false
		circ.Color = color
		circ.Visible = true
		EntityDrawings[inst] = { circle = circ }
		return circ
	end

	local function destroyDrawing(inst)
		local data = EntityDrawings[inst]
		if data and data.circle then
			pcall(function() data.circle:Remove() end)
		end
		EntityDrawings[inst] = nil
	end

	local function CreateEntityESP(inst)
		if not EntityESPEnabled then return end
		if not Entities[inst.Name] then return end
		if DrawingAvailable then
			createDrawingCircle(inst, Entities[inst.Name].color)
		else
			local h = createHighlightFallback(inst, Entities[inst.Name].color)
			if h then EntityDrawings[inst] = { highlight = h } end
		end
	end

	local function RemoveEntityESP(inst)
		if DrawingAvailable then
			destroyDrawing(inst)
		else
			removeHighlight(EntityDrawings, inst)
		end
	end

	local function CreateKeyESPForPart(part)
		if not KeyESPEnabled or not part then return end
		local existing = part:FindFirstChild("ShadowPulse_KeyESP")
		if existing then return end
		local h = createHighlightFallback(part, KeyColor)
		if h then KeyHighlights[part] = h end
	end

	local function RemoveKeyESPForPart(part)
		removeHighlight(KeyHighlights, part)
	end

	local function CreateLeverESPForPart(part)
		if not LeverESPEnabled or not part then return end
		local existing = part:FindFirstChild("ShadowPulse_LeverESP")
		if existing then return end
		local h = createHighlightFallback(part, LeverColor)
		if h then LeverHighlights[part] = h end
	end

	local function RemoveLeverESPForPart(part)
		removeHighlight(LeverHighlights, part)
	end

	local function NotifyEntity(name, message)
		window:Notify({
			Title = "Shadow Pulse Alpha",
			Message = message or (name .. " spawned"),
			Duration = 5
		})
	end

	local function stopAntiEyes()
		if EyesConn then
			pcall(function() EyesConn:Disconnect() end)
			EyesConn = nil
		end
	end

	local function applyAntiEyesTo(instance)
		for _, d in ipairs(instance:GetDescendants()) do
			if d.Name == "MotorReplication" then
				pcall(function()
					if d:IsA("BoolValue") then
						d.Value = false
					elseif d:IsA("IntValue") or d:IsA("NumberValue") then
						d.Value = 0
					else
						if instance.SetAttribute then
							instance:SetAttribute("MotorReplication", false)
						end
					end
				end)
			end
		end
	end

	local function startAntiEyes()
		stopAntiEyes()
		EyesConn = RunService.Heartbeat:Connect(function()
			if not AntiEyesEnabled then return end
			for _, obj in ipairs(Workspace:GetDescendants()) do
				if obj.Name == "Eyes" then
					applyAntiEyesTo(obj)
				end
			end
		end)
	end

	local function scanCurrentRoomsOnce()
		if not Workspace:FindFirstChild("CurrentRooms") then return end
		for _, room in pairs(Workspace.CurrentRooms:GetChildren()) do
			local assets = room:FindFirstChild("Assets")
			if assets then
				local key = assets:FindFirstChild("KeyObtain")
				if key then
					if KeyESPEnabled then
						CreateKeyESPForPart(key)
					else
						RemoveKeyESPForPart(key)
					end
				end
				local lever = assets:FindFirstChild("LeverForGate")
				if lever then
					if LeverESPEnabled then
						CreateLeverESPForPart(lever)
					else
						RemoveLeverESPForPart(lever)
					end
				end
			end
		end
	end

	if Workspace:FindFirstChild("CurrentRooms") then
		Workspace.CurrentRooms.ChildAdded:Connect(function(room)
			local assets = room:FindFirstChild("Assets")
			if assets then
				assets.ChildAdded:Connect(function(ch)
					if ch.Name == "KeyObtain" then
						if KeyESPEnabled then CreateKeyESPForPart(ch) end
					elseif ch.Name == "LeverForGate" then
						if LeverESPEnabled then CreateLeverESPForPart(ch) end
					end
				end)
				if assets:FindFirstChild("KeyObtain") then
					if KeyESPEnabled then CreateKeyESPForPart(assets.KeyObtain) end
				end
				if assets:FindFirstChild("LeverForGate") then
					if LeverESPEnabled then CreateLeverESPForPart(assets.LeverForGate) end
				end
			end
		end)
	end

	tabMain:AddToggle({
		Text = "自动房间",
		Name = "AutoRoomsToggle",
		Flag = "AutoRoomsToggle",
		Default = false,
		Callback = function(state)
			AutoRoomsEnabled = state
			if state then
				getgenv().ShadowPulseAutoRoomsStop = false
				local ok, fn = pcall(function() return loadstring(game:HttpGet("https://pastebin.com/raw/U4FaFJAt")) end)
				if ok and fn then
					autoRoomsFuncRef = fn
					autoRoomsCoroutine = coroutine.create(function()
						pcall(function() fn() end)
					end)
					coroutine.resume(autoRoomsCoroutine)
					window:Notify({Title = "Shadow Pulse Alpha", Message = "自动房间已启动", Duration = 4})
				else
					window:Notify({Title = "Shadow Pulse Alpha", Message = "加载自动房间失败", Duration = 5})
				end
			else
				getgenv().ShadowPulseAutoRoomsStop = true
				if autoRoomsCoroutine then
					pcall(function()
						if coroutine.close then
							coroutine.close(autoRoomsCoroutine)
						end
					end)
					autoRoomsCoroutine = nil
				end
				if autoRoomsFuncRef and type(autoRoomsFuncRef) == "function" then
					pcall(function()
						if autoRoomsFuncRef.Stop then
							pcall(autoRoomsFuncRef.Stop)
						end
					end)
				end
				window:Notify({Title = "Shadow Pulse Alpha", Message = "已尝试停止自动房间", Duration = 4})
			end
		end
	})

	tabEntities:AddToggle({
		Text = "启用实体通知",
		Name = "EntityNotifierToggle",
		Flag = "EntityNotifierToggle",
		Default = false,
		Callback = function(state)
			EntityNotifierEnabled = state
		end
	})

	tabEntities:AddToggle({
		Text = "启用实体透视",
		Name = "EntityESPToggle",
		Flag = "EntityESPToggle",
		Default = false,
		Callback = function(state)
			EntityESPEnabled = state
			if not state then
				for inst, _ in pairs(EntityDrawings) do
					destroyDrawing(inst)
				end
				for _, h in pairs(Workspace:GetDescendants()) do
					local hh = h:FindFirstChild("ShadowPulse_Highlight")
					if hh then
						pcall(function() hh:Destroy() end)
					end
				end
				EntityDrawings = {}
			else
				for _, obj in ipairs(Workspace:GetDescendants()) do
					if Entities[obj.Name] then
						CreateEntityESP(obj)
					end
				end
			end
		end
	})

	tabESP:AddToggle({
		Text = "钥匙透视 (当前房间)",
		Name = "KeyESPToggle",
		Flag = "KeyESPToggle",
		Default = false,
		Callback = function(state)
			KeyESPEnabled = state
			scanCurrentRoomsOnce()
		end
	})

	tabESP:AddToggle({
		Text = "杠杠透视 (当前房间)",
		Name = "LeverESPToggle",
		Flag = "LeverESPToggle",
		Default = false,
		Callback = function(state)
			LeverESPEnabled = state
			scanCurrentRoomsOnce()
		end
	})

	tabEntities:AddToggle({
		Text = "防眼镜 (简易)",
		Name = "AntiEyesToggle",
		Flag = "AntiEyesToggle",
		Default = false,
		Callback = function(state)
			AntiEyesEnabled = state
			if state then
				startAntiEyes()
			else
				stopAntiEyes()
			end
		end
	})

	Workspace.DescendantAdded:Connect(function(obj)
		if Entities[obj.Name] then
			if EntityNotifierEnabled then
				NotifyEntity(obj.Name, Entities[obj.Name].msg)
			end
			CreateEntityESP(obj)
			return
		end
		if Workspace:FindFirstChild("CurrentRooms") and obj.Parent and obj.Parent.Name == "Assets" then
			if obj.Name == "KeyObtain" then
				if KeyESPEnabled then CreateKeyESPForPart(obj) end
				return
			elseif obj.Name == "LeverForGate" then
				if LeverESPEnabled then CreateLeverESPForPart(obj) end
				return
			end
		end
	end)

	Workspace.DescendantRemoving:Connect(function(obj)
		if EntityDrawings[obj] then
			destroyDrawing(obj)
		end
		if KeyHighlights[obj] then
			RemoveKeyESPForPart(obj)
		end
		if LeverHighlights[obj] then
			RemoveLeverESPForPart(obj)
		end
	end)

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if Entities[obj.Name] then
			CreateEntityESP(obj)
		elseif Workspace:FindFirstChild("CurrentRooms") and obj.Parent and obj.Parent.Name == "Assets" then
			if obj.Name == "KeyObtain" then CreateKeyESPForPart(obj)
			elseif obj.Name == "LeverForGate" then CreateLeverESPForPart(obj) end
		end
	end

	if DrawingAvailable then
		RunService.RenderStepped:Connect(function()
			Camera = workspace.CurrentCamera
			for inst, data in pairs(EntityDrawings) do
				if not inst or not inst.Parent then
					destroyDrawing(inst)
				else
					local center, size = getCenterAndSize(inst)
					if center and size then
						local sx, sy, depth = Camera:WorldToViewportPoint(center)
						local onScreen = (depth > 0)
						local maxExtent = math.max(size.X, size.Y, size.Z)
						local offsetWorld = center + (Camera.CFrame.RightVector * (maxExtent * 0.5))
						local ox, oy = Camera:WorldToViewportPoint(offsetWorld)
						local radius = 0
						if ox and oy then
							radius = math.sqrt((sx - ox) ^ 2 + (sy - oy) ^ 2)
						end
						if radius < 4 then
							radius = math.clamp(maxExtent / (depth + 0.001) * 50, 4, 1000)
						end
						local circ = data.circle
						if circ then
							circ.Position = Vector2.new(sx, sy)
							circ.Radius = radius
							circ.Color = Entities[inst.Name].color
							circ.Visible = onScreen
							local t = math.clamp(1 - (depth / 200), 0.2, 1)
							circ.Transparency = 1 - t
						end
					else
						if data.circle then
							data.circle.Visible = false
						end
					end
				end
			end
			if Workspace:FindFirstChild("CurrentRooms") then
				for _, room in pairs(Workspace.CurrentRooms:GetChildren()) do
					local assets = room:FindFirstChild("Assets")
					if assets then
						local key = assets:FindFirstChild("KeyObtain")
						if key then
							if KeyESPEnabled then
								CreateKeyESPForPart(key)
							else
								RemoveKeyESPForPart(key)
							end
						end
						local lever = assets:FindFirstChild("LeverForGate")
						if lever then
							if LeverESPEnabled then
								CreateLeverESPForPart(lever)
							else
								RemoveLeverESPForPart(lever)
							end
						end
					end
				end
			end
		end)
	end

	library:LoadData()
end)