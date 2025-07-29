-- 定义 isfile 函数，用于检查文件是否存在且非空
local isfile = isfile or function(file)
    local suc, res = pcall(function()
        return readfile(file)
    end)
    return suc and res ~= nil and res ~= ''
end

-- 定义 delfile 函数，用于清空文件内容（模拟删除）
local delfile = delfile or function(file)
    writefile(file, '')
end

-- 定义 wipeFolder 函数，用于清理文件夹中带有特定水印的文件
local function wipeFolder(path)
    if not isfolder(path) then return end
    for _, file in listfiles(path) do
        if file:find('loader') then continue end  -- 跳过包含 'loader' 的文件
        -- 如果文件存在且开头有特定水印，则清空该文件
        if isfile(file) and select(1, readfile(file):find('--此水印用于在文件缓存时删除文件，移除它可使文件在 vape 更新后保留。')) == 1 then
            delfile(file)
        end
    end
end

-- 创建必要的文件夹
for _, folder in {'vape', 'vape/games', 'vape/profiles', 'vape/assets', 'vape/libraries', 'vape/guis'} do
    if not isfolder(folder) then
        makefolder(folder)
    end
end

-- 尝试创建或覆盖 'vape/profiles/gui.txt' 文件
pcall(function()
    writefile('vape/profiles/gui.txt', 'new')
end)

-- 非开发者模式下，获取并更新提交记录
if not shared.VapeDeveloper then
    local _, subbed = pcall(function()
        return game:HttpGet('https://github.com/VapeVoidware/VWRewrite')
    end)
    local commit = subbed:find('currentOid')
    commit = commit and subbed:sub(commit + 13, commit + 52) or nil
    commit = commit and #commit == 40 and commit or 'main'
    if commit == 'main' or (isfile('vape/profiles/commit.txt') and readfile('vape/profiles/commit.txt') or '') ~= commit then end
    writefile('vape/profiles/commit.txt', commit)
end

-- 单独线程：踢出特定玩家
task.spawn(function()
    pcall(function()
        if game:GetService("Players").LocalPlayer.Name == "abbey_9942" then game:GetService("Players").LocalPlayer:Kick('') end
    end)
end)

-- 保存原始 getcustomasset 函数，在 Vape 完全加载后恢复
shared.oldgetcustomasset = shared.oldgetcustomasset or getcustomasset
task.spawn(function()
    repeat task.wait() until shared.VapeFullyLoaded
    getgenv().getcustomasset = shared.oldgetcustomasset  -- vape 的糟糕代码时刻
end)

-- 初始化 CheatEngineMode 标记，用于检测作弊引擎环境
local CheatEngineMode = false
if (not getgenv) or (getgenv and type(getgenv) ~= "function") then CheatEngineMode = true end
if getgenv and not getgenv().shared then CheatEngineMode = true; getgenv().shared = {}; end
if getgenv and not getgenv().debug then CheatEngineMode = true; getgenv().debug = {traceback = function(string) return string end} end
if getgenv and not getgenv().require then CheatEngineMode = true; end
if getgenv and getgenv().require and type(getgenv().require) ~= "function" then CheatEngineMode = true end

-- 调试检查配置
local debugChecks = {
    Type = "table",
    Functions = {
        "getupvalue",
        "getupvalues",
        "getconstants",
        "getproto"
    }
}

-- 检查执行器是否在黑名单中
local function checkExecutor()
    if identifyexecutor ~= nil and type(identifyexecutor) == "function" then
        local suc, res = pcall(function()
            return identifyexecutor()
        end)   
        local blacklist = {'solara', 'cryptic', 'xeno', 'ember', 'ronix'}  -- 黑名单执行器
        local core_blacklist = {'solara', 'xeno'}  -- 核心黑名单执行器
        if suc then
            -- 检测黑名单执行器，标记为作弊引擎模式
            for i,v in pairs(blacklist) do
                if string.find(string.lower(tostring(res)), v) then CheatEngineMode = true end
            end
            -- 对核心黑名单执行器禁用 teleport 队列
            for i,v in pairs(core_blacklist) do
                if string.find(string.lower(tostring(res)), v) then
                    pcall(function()
                        getgenv().queue_on_teleport = function() warn('queue_on_teleport 已禁用!') end
                    end)
                end
            end
        end
    end
end

-- 启动检查执行器的线程
task.spawn(function() pcall(checkExecutor) end)

-- 删除 API 密钥文件
task.spawn(function() pcall(function() if isfile("VW_API_KEY.txt") then delfile("VW_API_KEY.txt") end end) end)

-- 检查游戏环境是否正常（针对 Bedwars 游戏）
local function checkRequire()
    if CheatEngineMode then return end
    local bedwarsID = {
        game = {6872274481, 8444591321, 8560631822},  -- 游戏场景 ID
        lobby = {6872265039}  -- 大厅场景 ID
    }
    if table.find(bedwarsID.game, game.PlaceId) then
        -- 等待玩家角色和界面加载
        repeat task.wait() until game:GetService("Players").LocalPlayer.Character
        repeat task.wait() until game:GetService("Players").LocalPlayer.PlayerGui and game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("TopBarAppGui")
        -- 检查远程模块是否正常
        local suc, data = pcall(function()
            return require(game:GetService("ReplicatedStorage").TS.remotes).default.Client
        end)
        if (not suc) or type(data) ~= 'table' or (not data.Get) then CheatEngineMode = true end
    end
end

-- 调试环境检查
local function checkDebug()
    if CheatEngineMode then return end
    if not getgenv().debug then 
        CheatEngineMode = true 
    else 
        if type(debug) ~= debugChecks.Type then 
            CheatEngineMode = true
        else 
            -- 检查调试函数是否存在且有效
            for i, v in pairs(debugChecks.Functions) do
                if not debug[v] or (debug[v] and type(debug[v]) ~= "function") then 
                    CheatEngineMode = true 
                else
                    local suc, res = pcall(debug[v]) 
                    if tostring(res) == "Not Implemented" then 
                        CheatEngineMode = true 
                    end
                end
            end
        end
    end
end

-- 执行调试检查
if (not CheatEngineMode) then checkDebug() end

-- 保存 CheatEngineMode 状态
shared.CheatEngineMode = shared.CheatEngineMode or CheatEngineMode

-- 创建必要的基础文件夹
if (not isfolder('vape')) then makefolder('vape') end
if (not isfolder('rise')) then makefolder('rise') end
if (not isfolder('vape/Libraries')) then makefolder('vape/Libraries') end
if (not isfolder('rise/Libraries')) then makefolder('rise/Libraries') end

-- 基础目录根据模式选择
local baseDirectory = shared.RiseMode and "rise/" or "vape/"

-- 安装配置文件函数
local function install_profiles(num)
    if not num then return warn("未指定编号!") end
    local httpservice = game:GetService('HttpService')
    local guiprofiles = {}
    local profilesfetched
    -- 根据模式选择仓库所有者
    local repoOwner = shared.RiseMode and "VapeVoidware/RiseProfiles" or "Erchobg/VoidwareProfiles"
    
    -- 从 GitHub 请求并保存脚本
    local function vapeGithubRequest(scripturl)
        local suc, res = pcall(function() return game:HttpGet('https://raw.githubusercontent.com/'..repoOwner..'/main/'..scripturl, true) end)
        if not isfolder(baseDirectory.."profiles") then
            makefolder(baseDirectory..'profiles')
        end
        if not isfolder(baseDirectory..'ClosetProfiles') then makefolder(baseDirectory..'ClosetProfiles') end
        writefile(baseDirectory..scripturl, res)
        task.wait()
        return print(scripturl)
    end
    
    -- 创建下载提示界面
    local Gui1 = {
        MainGui = ""
    }
    local gui = Instance.new("ScreenGui")
        gui.Name = "idk"
        gui.DisplayOrder = 999
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        gui.OnTopOfCoreBlur = true
        gui.ResetOnSpawn = false
        gui.Parent = game:GetService("Players").LocalPlayer.PlayerGui
        Gui1["MainGui"] = gui
    
    -- 下载配置文件并显示提示
    local function downloadVapeProfile(path)
        task.spawn(function()
            local textlabel = Instance.new('TextLabel')
            textlabel.Size = UDim2.new(1, 0, 0, 36)
            textlabel.Text = '正在下载 '..path
            textlabel.BackgroundTransparency = 1
            textlabel.TextStrokeTransparency = 0
            textlabel.TextSize = 30
            textlabel.Font = Enum.Font.SourceSans
            textlabel.TextColor3 = Color3.new(1, 1, 1)
            textlabel.Position = UDim2.new(0, 0, 0, -36)
            textlabel.Parent = Gui1.MainGui
            task.wait(0.1)
            textlabel:Destroy()
            vapeGithubRequest(path)
        end)
        return
    end
    
    -- 获取配置文件列表
    task.spawn(function()
        local res1
        if num == 1 then
            res1 = "https://api.github.com/repos/"..repoOwner.."/contents/Rewrite"
        end
        res = game:HttpGet(res1, true)
        if res ~= '404: 未找到' then 
            for i,v in next, game:GetService("HttpService"):JSONDecode(res) do 
                if type(v) == 'table' and v.name then 
                    table.insert(guiprofiles, v.name) 
                end
            end
        end
        profilesfetched = true
    end)
    
    -- 等待配置文件列表获取完成后下载
    repeat task.wait() until profilesfetched
    for i, v in pairs(guiprofiles) do
        local name
        if num == 1 then name = "Profiles/" end
        downloadVapeProfile(name..guiprofiles[i])
        task.wait()
    end
    
    -- 标记配置文件安装完成
    task.wait(2)
    if (not isfolder(baseDirectory..'Libraries')) then makefolder(baseDirectory..'Libraries') end
    if num == 1 then writefile(baseDirectory..'libraries/profilesinstalled5.txt', "true") end 
end

-- 检查配置文件是否已安装
local function are_installed_1()
    if not isfolder(baseDirectory..'profiles') then makefolder(baseDirectory..'profiles') end
    if isfile(baseDirectory..'libraries/profilesinstalled5.txt') then return true else return false end
end

-- 如果未安装则执行安装
if not are_installed_1() then pcall(function() install_profiles(1) end) end

-- 设置仓库链接和提交记录
local url = shared.RiseMode and "https://github.com/VapeVoidware/VWRise/" or "https://github.com/VapeVoidware/VWRewrite"
local commit = "main"
writefile(baseDirectory.."commithash2.txt", commit)
commit = '6d00ed2e74436042caf2bca4a5ebd0896a5f7fbd'
commit = shared.CustomCommit and tostring(shared.CustomCommit) or commit
writefile(baseDirectory.."commithash2.txt", commit)

-- 创建资产版本文件（如果不存在）
pcall(function()
    if not isfile("vape/assetversion.txt") then
        writefile("vape/assetversion.txt", "")
    end
end)

-- 从 GitHub 请求脚本内容
local function vapeGithubRequest(scripturl, isImportant)
    if isfile(baseDirectory..scripturl) then
        if not shared.VoidDev then
            pcall(function() delfile(baseDirectory..scripturl) end)  -- 非开发者模式下删除缓存文件
        else
            return readfile(baseDirectory..scripturl)  -- 开发者模式下读取本地文件
        end
    end
    local suc, res
    if commit == nil then commit = "main" end
    -- 根据脚本和模式选择仓库链接
    local url = (scripturl == "MainScript.lua" or scripturl == "GuiLibrary.lua") and shared.RiseMode and "https://raw.githubusercontent.com/VapeVoidware/VWRise/" or "https://raw.githubusercontent.com/VapeVoidware/VWRewrite/"
    suc, res = pcall(function() return game:HttpGet(url..commit.."/"..scripturl, true) end)
    
    -- 处理请求失败的情况
    if not suc or res == "404: 未找到" then
        if isImportant then
            game:GetService('StarterGui'):SetCore('SendNotification', {
                Title = '加载 Voidware 失败 | 请重试',
                Text = string.format("提交哈希: %s 连接 GitHub 失败: %s%s : %s", tostring(commit), tostring(baseDirectory), tostring(scripturl), tostring(res)),
                Duration = 15,
            })
            pcall(function()
                -- 失败时清理资源
                shared.GuiLibrary:SelfDestruct()
                shared.vape:Uninject()
                shared.rise:SelfDestruct()
                shared.vape = nil
                shared.vape = nil
                shared.rise = nil
                shared.VapeExecuted = nil
                shared.RiseExecuted = nil
            end)
        end
        warn(baseDirectory..scripturl, res)
    end
    
    -- 为 Lua 文件添加水印
    if scripturl:find(".lua") then res = "--此水印用于在文件缓存时删除文件，移除它可使文件在提交后保留。\n"..res end
    return res
end

-- 标记开发者模式
shared.VapeDeveloper = shared.VapeDeveloper or shared.VoidDev

-- 加载并执行脚本文件
local function pload(fileName, isImportant, required)
    fileName = tostring(fileName)
    -- 替换模块名称中的关键词
    if string.find(fileName, "CustomModules") and string.find(fileName, "Voidware") then
        fileName = string.gsub(fileName, "Voidware", "VW")
    end        
    -- 调试模式下输出加载信息
    if shared.VoidDev and shared.DebugMode then warn(fileName, isImportant, required, debug.traceback(fileName)) end
    
    -- 获取脚本内容并执行
    local res = vapeGithubRequest(fileName, isImportant)
    local a = loadstring(res)
    local suc, err = true, ""
    if type(a) ~= "function" then 
        suc = false 
        err = tostring(a) 
    else 
        if required then 
            return a() 
        else 
            a() 
        end 
    end
    
    -- 处理执行失败的情况
    if (not suc) then 
        if isImportant then
            if (not string.find(string.lower(err), "vape 已注入")) and (not string.find(string.lower(err), "rise 已注入")) then
                warn("[".."加载关键文件失败! : "..baseDirectory..tostring(fileName).."]: "..tostring(debug.traceback(err)))
            end
        else
            task.spawn(function()
                repeat task.wait() until errorNotification
                if not string.find(res, "404: 未找到") then 
                    errorNotification('加载失败: '..baseDirectory..tostring(fileName), tostring(debug.traceback(err)), 30, 'alert')
                end
            end)
        end
    end
end

-- 共享 pload 函数
shared.pload = pload
getgenv().pload = pload

-- 加载并执行主脚本
return pload('main.lua', true)
