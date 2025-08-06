local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

OrionLib:MakeNotification({
	Name = "霜中心",
	Content = "正在加载 霜中心",
	Image = "rbxthumb://type=Asset&id=5107182114&w=150&h=150",
	Time = 2
})

local Window = OrionLib:MakeWindow({Name = "霜中心 | 您使用的注入器：" ..(identifyexecutor and identifyexecutor() or syn and "Synapse X" or "Unknown"), HidePremium = false, SaveConfig = true, IntroText = "霜中心", ConfigFolder = "BeiFengCenter"})

local statement = Window:MakeTab({
	Name = "关于",
	Icon = "rbxassetid://14359155637",
	PremiumOnly = false
})

statement:AddParagraph("警告", "脚本不在指定游戏执行，会发生无法使用的情况，请明细")
statement:AddLabel("霜中心作者ROBLOX用户名：PB_cyt")
statement:AddLabel("我可是霜👿")
statement:AddLabel("联系方式 - QQ：3557706928")
statement:AddLabel("更新时间 2024/11/30")

local Currency = Window:MakeTab({
	Name = "通用功能",
	Icon = "rbxassetid://14481493145",
	PremiumOnly = false
})

Currency:AddButton({
	Name = "Infinite Yield",
	Callback = function()
		loadstring(game:HttpGet(("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"), true))()
	end
})

Currency:AddButton({
	Name = "光影V4",
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/MZEEN2424/Graphics/main/Graphics.xml", true))()
	end
})

Currency:AddButton({
	Name = "光影BrickoIcko版",
	Callback = function()
		loadstring(game:HttpGet("https://pastebin.com/raw/Qunce5TP", true))()
	end
})

Currency:AddButton({
	Name = "飞行GUI-V3",
	Callback = function()
		loadstring(game:HttpGet(("https://raw.githubusercontent.com/UWUBeiFeng/Scripts/main/FlyGUIV3.lua"), true))()
	end
})

Currency:AddButton({
	Name = "飞车",
	Callback = function()
		loadstring(game:HttpGet("https://pastebin.com/raw/MHE1cbWF"))()
	end
})

Currency:AddButton({
	Name = "踏空行走",
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostPlayer352/Test4/main/Float"))()
	end
})

Currency:AddButton({
	Name = "爬墙",
	Callback = function()
		loadstring(game:HttpGet("https://pastebin.com/raw/zXk4Rq2r"))()
	end
})

Currency:AddButton({
	Name = "跟踪玩家",
	Callback = function()
		loadstring(game:HttpGet(("https://raw.githubusercontent.com/UWUBeiFeng/Scripts/main/Follow.lua"), true))()
	end
})

Currency:AddButton({
	Name = "黑客脚本",
	Callback = function()
		loadstring(game:HttpGet(("https://raw.githubusercontent.com/BirthScripts/Scripts/main/c00l.lua"), true))()
	end
})

Currency:AddToggle({
	Name = "夜视",
	Default = false,
	Callback = function(Value)
		if Value then
			game.Lighting.Ambient = Color3.new(1, 1, 1)
		else
			game.Lighting.Ambient = Color3.new(0, 0, 0)
		end
	end
})

Currency:AddButton({
	Name = "建筑工具",
	Callback = function()
		Hammer = Instance.new("HopperBin")
		Hammer.Name = "锤子"
		Hammer.BinType = 4
		Hammer.Parent = game.Players.LocalPlayer.Backpack
		Clone = Instance.new("HopperBin")
		Clone.Name = "克隆"
		Clone.BinType = 3
		Clone.Parent = game.Players.LocalPlayer.Backpack
		Grab = Instance.new("HopperBin")
		Grab.Name = "抓取"
		Grab.BinType = 2
	end
})

Currency:AddToggle({
	Name = "锁头（有队伍检测）",
	Default = false,
	Callback = function(Value)
		_G.AimbotEnabled = Value

		local Camera = workspace.CurrentCamera
		local Players = game:GetService("Players")
		local RunService = game:GetService("RunService")
		local UserInputService = game:GetService("UserInputService")
		local TweenService = game:GetService("TweenService")
		local LocalPlayer = Players.LocalPlayer
		local Holding = false

		_G.TeamCheck = true
		_G.AimPart = "Head"
		_G.Sensitivity = 0

		_G.CircleSides = 64
		_G.CircleColor = Color3.fromRGB(255, 255, 255)
		_G.CircleTransparency = 0.7
		_G.CircleRadius = 80
		_G.CircleFilled = false
		_G.CircleVisible = false
		_G.CircleThickness = 0

		local FOVCircle = Drawing.new("Circle")
		FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
		FOVCircle.Radius = _G.CircleRadius
		FOVCircle.Filled = _G.CircleFilled
		FOVCircle.Color = _G.CircleColor
		FOVCircle.Visible = _G.CircleVisible
		FOVCircle.Radius = _G.CircleRadius
		FOVCircle.Transparency = _G.CircleTransparency
		FOVCircle.NumSides = _G.CircleSides
		FOVCircle.Thickness = _G.CircleThickness

		local function GetClosestPlayer()
			local MaximumDistance = _G.CircleRadius
			local Target = nil

			for _, v in next, Players:GetPlayers() do
				if v.Name ~= LocalPlayer.Name then
					if _G.TeamCheck == true then
						if v.Team ~= LocalPlayer.Team then
							if v.Character ~= nil then
								if v.Character:FindFirstChild("HumanoidRootPart") ~= nil then
									if v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("Humanoid").Health ~= 0 then
										local ScreenPoint = Camera:WorldToScreenPoint(v.Character:WaitForChild("HumanoidRootPart", math.huge).Position)
										local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude

										if VectorDistance < MaximumDistance then
										
local Currency = Window:MakeTab({
	Name = "bf",
	Icon = "rbxassetid://14481493145",
	PremiumOnly = false
})

Currency:AddButton({
	Name = "annie hub",
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/Anniecuti/Free-Scr/main/Annie-Hub.lua"))()
	end
})					

Currency:AddButton({
	Name = "redz",
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/REDzHUB/BloxFruits/main/redz9999"))()
	end
})