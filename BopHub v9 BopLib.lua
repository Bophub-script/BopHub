local BopLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Bophub-script/BopHub/refs/heads/main/BopLib.lua"
))()

if not BopLib then
    error("[BopHub] ERROR: BopLib no cargo. Verifica la URL de la libreria.")
end

local Players      = game:GetService("Players")
local Workspace    = game:GetService("Workspace")
local UIS          = game:GetService("UserInputService")
local VU           = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local lp           = Players.LocalPlayer
local char         = lp.Character or lp.CharacterAdded:Wait()
local hrp          = char:WaitForChild("HumanoidRootPart")
local hum          = char:WaitForChild("Humanoid")

lp.CharacterAdded:Connect(function(c)
    char = c
    hrp  = c:WaitForChild("HumanoidRootPart")
    hum  = c:WaitForChild("Humanoid")
end)

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

if typeof(newcclosure)       ~= "function" then newcclosure       = function(f) return f end end
if typeof(getnamecallmethod) ~= "function" then getnamecallmethod = function() return nil end end
if typeof(setreadonly)       ~= "function" then setreadonly       = function() end end
if typeof(getrawmetatable)   ~= "function" then getrawmetatable   = function(o) return getmetatable(o) end end
if typeof(firesignal)        ~= "function" then firesignal        = function(s,...) pcall(function() s:Fire(...) end) end end
if typeof(sethiddenproperty) ~= "function" then sethiddenproperty = function(o,p,v) pcall(function() o[p]=v end) end end
if typeof(hookfunction)      ~= "function" then hookfunction      = function(f) return f end end

local IS_DELTA   = (typeof(firesignal)  == "function")
local HAS_HOOK   = (typeof(hookfunction)== "function")
local HAS_HIDDEN = (typeof(sethiddenproperty)=="function")

_G.BOP = {
    AutoFarm=false, AutoBoss=false, AutoQuest=false,
    MobAura=false,  AutoChest=false, AutoRaid=false, AutoBone=false,
    NoClip=false,   AutoPVP=false,   NoStun=false,
    KillAura=false, Instakill=false, InstakillPlayers=false,
    GodMode=false,  AutoBuso=false,  AutoKen=false,
    AutoClick=false,
    FruitSniper=false, FruitNotifier=false, AutoEat=false,
    AutoBounty=false,  BountyHunter=false,
    BountyMin=0, BountyMax=300000000,
    AutoMoney=false, AutoFragment=false, AutoDiamond=false,
    ESPPlayers=false, ESPMobs=false, ESPFruits=false,
    ESPChests=false,  ESPSeaBeast=false,
    SpeedHack=false, FlyHack=false, InfiniteJump=false,
    FullBright=false, AntiAFK=false,
    BypassTP=true,   AntiLog=false,
    SpeedValue=20,   AuraRange=15,
}

local Threads = {}
local function killThread(n) if Threads[n] then pcall(task.cancel,Threads[n]); Threads[n]=nil end end
local function newThread(n,fn) killThread(n); Threads[n]=task.spawn(fn) end

local ESPBoxes = {}

local function safeTP(cf)
    if _G.BOP.BypassTP then
        pcall(function()
            local ti = TweenInfo.new(0.05)
            TweenService:Create(hrp,ti,{CFrame=cf}):Play()
        end)
    else
        pcall(function() hrp.CFrame = cf end)
    end
end

local function findByName(kws)
    for _,o in ipairs(Workspace:GetDescendants()) do
        for _,k in ipairs(kws) do
            if o.Name:lower():find(k:lower()) then return o end
        end
    end
end

local function createESPFor(target, color)
    if ESPBoxes[target] then return end
    pcall(function()
        local h = Instance.new("Highlight")
        h.FillColor, h.OutlineColor = color or Color3.fromRGB(255,50,50), Color3.new(1,1,1)
        h.FillTransparency, h.OutlineTransparency = 0.6, 0
        h.Adornee, h.Parent = target, target
        ESPBoxes[target] = h
        target.AncestryChanged:Connect(function(_,p)
            if p == nil then pcall(function() h:Destroy() end); ESPBoxes[target]=nil end
        end)
    end)
end

local function removeAllESP()
    for _,h in pairs(ESPBoxes) do pcall(function() h:Destroy() end) end
    ESPBoxes = {}
end

local function autoAcceptPrompt()
    task.spawn(function()
        task.wait(0.5)
        for _,g in ipairs(lp.PlayerGui:GetDescendants()) do
            if g:IsA("TextButton") and (g.Text:lower():find("accept") or
               g.Text:lower():find("yes") or g.Text:lower():find("confirm") or
               g.Text:lower():find("ok") or g.Text:lower():find("very well")) then
                pcall(function() g.MouseButton1Click:Fire() end)
            end
        end
    end)
end

local function killMob(mob)
    if not mob then return end
    pcall(function()
        local mh = mob:FindFirstChildOfClass("Humanoid")
        if not mh or mh.Health<=0 then return end
        if IS_DELTA then firesignal(mh.Died); task.wait(0.05) end
        if HAS_HIDDEN then sethiddenproperty(mh,"Health",0) end
        if mh.Health>0 then mh.Health=0 end
    end)
end

local function killPlayer(p)
    if not p or not p.Character then return end
    pcall(function()
        local ph = p.Character:FindFirstChildOfClass("Humanoid")
        if ph then ph.Health=0 end
    end)
end

local function tp(pos) safeTP(CFrame.new(pos)) end

local function applyAntiKick()
    if not HAS_HOOK then return end
    pcall(function()
        local mt = getrawmetatable(game); if not mt then return end
        local old = mt.__namecall
        setreadonly(mt,false)
        local wrap = (typeof(newcclosure)=="function") and newcclosure or function(f) return f end
        mt.__namecall = wrap(function(self,...)
            local m = (typeof(getnamecallmethod)=="function") and getnamecallmethod()
            if m=="Kick" then Window:Notify("Anti-Kick","Kick bloqueado!"); return end
            return old(self,...)
        end)
        setreadonly(mt,true)
    end)
end

local Window = BopLib.new("HUB v9 — Top 1 Blox Fruits")

task.spawn(function()
    task.wait(2)
    applyAntiKick()
    Window:Notify("BOP HUB v9","Cargado correctamente!")
end)

-- TAB FARM
local Farm = Window:Tab("Farm")
Farm:Separator("--- Farm Principal ---")
Farm:Toggle("Auto Farm Level", false, function(v)
    _G.BOP.AutoFarm = v
    newThread("AutoFarm", function()
        while _G.BOP.AutoFarm do
            pcall(function()
                local t,d = nil,math.huge
                for _,m in ipairs(Workspace:GetDescendants()) do
                    if m:FindFirstChild("Humanoid") and m:FindFirstChild("HumanoidRootPart")
                        and m.Humanoid.Health>0 and not Players:GetPlayerFromCharacter(m) then
                        local dist=(m.HumanoidRootPart.Position-hrp.Position).Magnitude
                        if dist<d then t,d=m,dist end
                    end
                end
                if t then safeTP(t.HumanoidRootPart.CFrame*CFrame.new(0,0,-4)) end
            end)
            task.wait(0.1)
        end
    end)
end)
Farm:Toggle("Auto Quest", false, function(v)
    _G.BOP.AutoQuest = v
    newThread("AutoQuest", function()
        while _G.BOP.AutoQuest do
            pcall(function()
                local qg = findByName({"QuestGiver","Quest"})
                if qg then
                    local bp=qg:FindFirstChildWhichIsA("BasePart")
                    if bp then safeTP(bp.CFrame*CFrame.new(0,0,-5)) end
                    autoAcceptPrompt()
                end
            end)
            task.wait(5)
        end
    end)
end)
Farm:Toggle("Mob Aura (Mata cercanos)", false, function(v)
    _G.BOP.MobAura = v
    newThread("MobAura", function()
        while _G.BOP.MobAura do
            pcall(function()
                for _,m in ipairs(Workspace:GetDescendants()) do
                    if m:FindFirstChild("Humanoid") and m:FindFirstChild("HumanoidRootPart")
                        and not Players:GetPlayerFromCharacter(m)
                        and (m.HumanoidRootPart.Position-hrp.Position).Magnitude<=_G.BOP.AuraRange then
                        killMob(m)
                    end
                end
            end)
            task.wait(0.05)
        end
    end)
end)
Farm:Slider("Aura Range", 5, 100, 15, function(v) _G.BOP.AuraRange=v end)
Farm:Toggle("No Clip", false, function(v)
    _G.BOP.NoClip=v
    newThread("NoClip", function()
        while _G.BOP.NoClip do
            pcall(function()
                for _,p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide=false end
                end
            end)
            task.wait(0.1)
        end
    end)
end)
Farm:Separator("--- Mastery Farm ---")
Farm:Toggle("Auto Farm Fruit Mastery", false, function(v)
    newThread("FMastery", function()
        while v do
            pcall(function()
                for _,m in ipairs(Workspace:GetDescendants()) do
                    if m:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(m) and m.Humanoid.Health>0 then
                        safeTP(m.HumanoidRootPart.CFrame*CFrame.new(0,0,-4)); break
                    end
                end
            end)
            task.wait(0.15)
        end
    end)
end)
Farm:Toggle("Auto Farm Sword Mastery", false, function(v)
    newThread("SMastery", function()
        while v do
            pcall(function()
                for _,m in ipairs(Workspace:GetDescendants()) do
                    if m:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(m) and m.Humanoid.Health>0 then
                        safeTP(m.HumanoidRootPart.CFrame*CFrame.new(0,2,-5)); break
                    end
                end
            end)
            task.wait(0.18)
        end
    end)
end)
Farm:Toggle("Auto Farm Gun Mastery", false, function(v)
    newThread("GMastery", function()
        while v do
            pcall(function()
                for _,m in ipairs(Workspace:GetDescendants()) do
                    if m:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(m) and m.Humanoid.Health>0 then
                        safeTP(m.HumanoidRootPart.CFrame*CFrame.new(0,5,-8)); break
                    end
                end
            end)
            task.wait(0.2)
        end
    end)
end)
Farm:Separator("--- Bosses & Drops ---")
Farm:Toggle("Auto Farm Boss", false, function(v)
    _G.BOP.AutoBoss=v
    newThread("AutoBoss", function()
        while _G.BOP.AutoBoss do
            pcall(function()
                for _,m in ipairs(Workspace:GetDescendants()) do
                    if m.Name:find("Boss") and m:FindFirstChild("HumanoidRootPart") then
                        safeTP(m.HumanoidRootPart.CFrame*CFrame.new(0,0,-5)); break
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end)
Farm:Toggle("Auto Raid", false, function(v)
    newThread("AutoRaid", function()
        while v do
            pcall(function()
                for _,m in ipairs(Workspace:GetDescendants()) do
                    if m:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(m) and m.Humanoid.Health>0 then
                        safeTP(m.HumanoidRootPart.CFrame*CFrame.new(0,0,-4)); break
                    end
                end
            end)
            task.wait(0.3)
        end
    end)
end)
Farm:Toggle("Auto Farm Chest", false, function(v)
    newThread("AutoChest", function()
        while v do
            pcall(function()
                for _,o in ipairs(Workspace:GetDescendants()) do
                    if o.Name:lower():find("chest") and o:IsA("Model") then
                        local cp=o:FindFirstChildWhichIsA("BasePart")
                        if cp then safeTP(cp.CFrame*CFrame.new(0,0,-3)); task.wait(0.5) end
                    end
                end
            end)
            task.wait(2)
        end
    end)
end)
Farm:Toggle("Auto Farm Bone", false, function(v)
    newThread("AutoBone", function()
        while v do
            pcall(function()
                for _,o in ipairs(Workspace:GetDescendants()) do
                    if o.Name:lower():find("bone") then
                        local bp=o:IsA("BasePart") and o or o:FindFirstChildWhichIsA("BasePart")
                        if bp then safeTP(bp.CFrame*CFrame.new(0,2,0)); task.wait(0.3) end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end)

-- TAB COMBAT
local Combat = Window:Tab("Combat")
Combat:Separator("--- PVP Core ---")
Combat:Toggle("Auto PVP", false, function(v)
    _G.BOP.AutoPVP=v
    newThread("AutoPVP", function()
        while _G.BOP.AutoPVP do
            pcall(function()
                local cl,d=nil,math.huge
                for _,p in ipairs(Players:GetPlayers()) do
                    if p~=lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local dist=(p.Character.HumanoidRootPart.Position-hrp.Position).Magnitude
                        if dist<d then cl,d=p,dist end
                    end
                end
                if cl then safeTP(cl.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,-3)); killPlayer(cl) end
            end)
            task.wait(0.05)
        end
    end)
end)
Combat:Toggle("Kill Aura (Players)", false, function(v)
    newThread("KillAura", function()
        while v do
            pcall(function()
                for _,p in ipairs(Players:GetPlayers()) do
                    if p~=lp and p.Character then
                        local ph=p.Character:FindFirstChild("Humanoid")
                        local pp=p.Character:FindFirstChild("HumanoidRootPart")
                        if ph and pp and (pp.Position-hrp.Position).Magnitude<_G.BOP.AuraRange then ph.Health=0 end
                    end
                end
            end)
            task.wait(0.05)
        end
    end)
end)
Combat:Toggle("Auto Dodge", false, function(v)
    newThread("AutoDodge", function()
        while v do
            pcall(function()
                if hum.Health<hum.MaxHealth*0.3 then
                    safeTP(hrp.CFrame*CFrame.new(math.random(-20,20),0,math.random(-20,20)))
                end
            end)
            task.wait(0.1)
        end
    end)
end)
Combat:Toggle("No Stun", false, function(v)
    newThread("NoStun", function()
        while v do
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
            end)
            task.wait(0.1)
        end
    end)
end)
Combat:Separator("--- Instakill ---")
Combat:Toggle("Instakill (Mobs)", false, function(v)
    _G.BOP.Instakill=v
    newThread("IKMobs", function()
        while _G.BOP.Instakill do
            pcall(function()
                for _,m in ipairs(Workspace:GetDescendants()) do
                    if m:FindFirstChild("Humanoid") and m:FindFirstChild("HumanoidRootPart")
                        and not Players:GetPlayerFromCharacter(m) and m.Humanoid.Health>0
                        and (m.HumanoidRootPart.Position-hrp.Position).Magnitude<=_G.BOP.AuraRange then
                        killMob(m)
                    end
                end
            end)
            task.wait(0.05)
        end
    end)
end)
Combat:Toggle("Instakill (Players)", false, function(v)
    newThread("IKPlayers", function()
        while v do
            pcall(function()
                for _,p in ipairs(Players:GetPlayers()) do
                    if p~=lp and p.Character then
                        local pp=p.Character:FindFirstChild("HumanoidRootPart")
                        if pp and (pp.Position-hrp.Position).Magnitude<=_G.BOP.AuraRange then killPlayer(p) end
                    end
                end
            end)
            task.wait(0.05)
        end
    end)
end)
Combat:Toggle("God Mode (HP Infinita)", false, function(v)
    _G.BOP.GodMode=v
    newThread("GodMode", function()
        while _G.BOP.GodMode do pcall(function() hum.Health=hum.MaxHealth end); task.wait(0.05) end
    end)
end)
Combat:Separator("--- Skills & Haki ---")
Combat:Toggle("Auto Buso Haki", false, function(v)
    newThread("AutoBuso", function()
        while v do
            pcall(function() local b=lp.PlayerGui:FindFirstChild("BusoKey",true); if b then b:FireServer() end end)
            task.wait(1)
        end
    end)
end)
Combat:Toggle("Auto Ken (Observation)", false, function(v)
    newThread("AutoKen", function()
        while v do
            pcall(function() local k=lp.PlayerGui:FindFirstChild("KenKey",true); if k then k:FireServer() end end)
            task.wait(1)
        end
    end)
end)
Combat:Toggle("Auto Skills ZXCV", false, function(v)
    newThread("AutoSkills", function()
        while v do
            pcall(function()
                local sg=lp.PlayerGui:FindFirstChild("Main",true) or lp.PlayerGui:FindFirstChild("SkillFrame",true)
                if sg then for _,b in ipairs(sg:GetDescendants()) do if b:IsA("ImageButton") or b:IsA("TextButton") then pcall(function() b.MouseButton1Click:Fire() end); task.wait(0.12) end end end
            end)
            task.wait(0.3)
        end
    end)
end)
Combat:Toggle("Auto Clicker (Touch)", false, function(v)
    newThread("AutoClick", function()
        while v do
            pcall(function()
                local cam=Workspace.CurrentCamera
                VU:CaptureController()
                VU:ClickButton1(Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2),cam.CFrame)
            end)
            task.wait(0.033)
        end
    end)
end)

-- TAB BOUNTY
local Bounty = Window:Tab("Bounty")
Bounty:Separator("--- Bounty Farm ---")
Bounty:Toggle("Auto Bounty Farm", false, function(v)
    _G.BOP.AutoBounty=v
    newThread("AutoBounty", function()
        while _G.BOP.AutoBounty do
            pcall(function()
                local cl,d=nil,math.huge
                for _,p in ipairs(Players:GetPlayers()) do
                    if p~=lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local dist=(p.Character.HumanoidRootPart.Position-hrp.Position).Magnitude
                        if dist<d then cl,d=p,dist end
                    end
                end
                if cl then safeTP(cl.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,-3)); killPlayer(cl) end
            end)
            task.wait(0.1)
        end
    end)
end)
Bounty:Toggle("Bounty Hunter (max bounty)", false, function(v)
    newThread("BHunter", function()
        while v do
            pcall(function()
                local tgt,mx=nil,0
                for _,p in ipairs(Players:GetPlayers()) do
                    if p~=lp and p.Character then
                        local bv=p.leaderstats and p.leaderstats:FindFirstChild("Bounty")
                        local ba=bv and bv.Value or 0
                        if ba>mx then tgt,mx=p,ba end
                    end
                end
                if tgt and tgt.Character:FindFirstChild("HumanoidRootPart") then
                    safeTP(tgt.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,-3)); killPlayer(tgt)
                    Window:Notify("Bounty Hunter","Eliminado: "..tgt.Name.." "..mx)
                end
            end)
            task.wait(0.5)
        end
    end)
end)
Bounty:Slider("Bounty Minimo (M)", 0, 500, 0, function(v) _G.BOP.BountyMin=v*1000000 end)
Bounty:Slider("Bounty Maximo (M)", 0, 500, 300, function(v) _G.BOP.BountyMax=v*1000000 end)
Bounty:Separator("--- Money & Fragments ---")
Bounty:Toggle("Auto Money Farm", false, function(v)
    newThread("AutoMoney", function()
        while v do
            pcall(function()
                local rt,ml=nil,0
                for _,m in ipairs(Workspace:GetDescendants()) do
                    if m:FindFirstChild("Humanoid") and m:FindFirstChild("HumanoidRootPart")
                        and not Players:GetPlayerFromCharacter(m) and m.Humanoid.Health>0 then
                        local lv=m:FindFirstChild("Level") or m:FindFirstChild("level")
                        local lvv=lv and lv.Value or 0
                        if lvv>ml then rt,ml=m,lvv end
                    end
                end
                if rt then safeTP(rt.HumanoidRootPart.CFrame*CFrame.new(0,0,-4)); killMob(rt) end
            end)
            task.wait(0.2)
        end
    end)
end)
Bounty:Toggle("Auto Fragment Farm", false, function(v)
    newThread("AutoFrag", function()
        while v do
            pcall(function()
                for _,o in ipairs(Workspace:GetDescendants()) do
                    if (o.Name:lower():find("fragment") or o.Name:lower():find("frag")) and o:IsA("BasePart") then
                        safeTP(o.CFrame*CFrame.new(0,2,0)); task.wait(0.3)
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end)

-- TAB FRUITS
local Fruits = Window:Tab("Fruits")
Fruits:Separator("--- Fruit Finder ---")
Fruits:Toggle("Fruit Sniper (Auto Grab)", false, function(v)
    newThread("FruitSniper", function()
        while v do
            pcall(function()
                for _,o in ipairs(Workspace:GetDescendants()) do
                    if o:IsA("BasePart") and (o.Name:find("Fruit") or o.Name:find("Devil")) then
                        safeTP(o.CFrame*CFrame.new(0,2,0))
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end)
Fruits:Toggle("Auto Eat Fruit", false, function(v)
    newThread("AutoEat", function()
        while v do
            pcall(function()
                for _,tool in ipairs(lp.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name:find("Fruit") then
                        hum:EquipTool(tool); task.wait(0.3)
                        VU:CaptureController()
                        VU:ClickButton1(Vector2.new(0,0),Workspace.CurrentCamera.CFrame)
                    end
                end
            end)
            task.wait(2)
        end
    end)
end)
Fruits:Separator("--- Fruit Notifier ---")
Fruits:Toggle("Fruit Notifier ACTIVO", false, function(v)
    local known={}
    newThread("FruitNotifier", function()
        while v do
            pcall(function()
                for _,o in ipairs(Workspace:GetDescendants()) do
                    if o:IsA("BasePart") and (o.Name:find("Fruit") or o.Name:find("Devil") or o.Name:find("_Fruit")) and not known[o] then
                        known[o]=true
                        Window:Notify("FRUTA DETECTADA", o.Name.." a "..math.floor((o.Position-hrp.Position).Magnitude).."m")
                        createESPFor(o, Color3.fromRGB(255,215,0))
                        task.spawn(function() task.wait(30); known[o]=nil end)
                    end
                end
            end)
            task.wait(1)
        end
    end)
end)
Fruits:Toggle("Auto TP a Fruta", false, function(v)
    newThread("AutoTPFruit", function()
        while v do
            pcall(function()
                for _,o in ipairs(Workspace:GetDescendants()) do
                    if o:IsA("BasePart") and (o.Name:find("Fruit") or o.Name:find("Devil")) then
                        safeTP(o.CFrame*CFrame.new(0,2,0)); task.wait(1)
                    end
                end
            end)
            task.wait(2)
        end
    end)
end)
Fruits:Toggle("Rain Fruit (Auto Collect)", false, function(v)
    newThread("RainFruit", function()
        while v do
            pcall(function()
                for _,o in ipairs(Workspace:GetDescendants()) do
                    if o.Name:lower():find("fruit") and o:IsA("BasePart") then
                        safeTP(o.CFrame*CFrame.new(0,2,0)); task.wait(0.2)
                    end
                end
            end)
            task.wait(1)
        end
    end)
end)

-- TAB TELEPORT
local Teleport = Window:Tab("TP")
Teleport:Separator("--- First Sea ---")
Teleport:Button("Starter Island",     function() tp(Vector3.new(980,18,-1430))   end)
Teleport:Button("Marine Starter",     function() tp(Vector3.new(-970,18,2138))   end)
Teleport:Button("Jungle",             function() tp(Vector3.new(-1500,40,148))   end)
Teleport:Button("Pirate Village",     function() tp(Vector3.new(-1350,8,950))    end)
Teleport:Button("Desert",             function() tp(Vector3.new(930,9,3940))     end)
Teleport:Button("Frozen Village",     function() tp(Vector3.new(1250,9,400))     end)
Teleport:Button("Marine Fortress",    function() tp(Vector3.new(-4880,15,520))   end)
Teleport:Button("Skylands",           function() tp(Vector3.new(-5000,600,-500)) end)
Teleport:Button("Colosseum",          function() tp(Vector3.new(-1300,9,1700))   end)
Teleport:Separator("--- Second Sea ---")
Teleport:Button("Kingdom of Rose",    function() tp(Vector3.new(-200,50,-3100))   end)
Teleport:Button("Green Zone",         function() tp(Vector3.new(-2082,69,-3584))  end)
Teleport:Button("Graveyard",          function() tp(Vector3.new(350,14,-3200))    end)
Teleport:Button("Snow Mountain",      function() tp(Vector3.new(-1600,140,240))   end)
Teleport:Button("Hot & Cold Island",  function() tp(Vector3.new(-5010,28,-2600))  end)
Teleport:Button("Cursed Ship",        function() tp(Vector3.new(640,5,-3900))     end)
Teleport:Button("Ice Castle",         function() tp(Vector3.new(-4040,30,-2700))  end)
Teleport:Button("Forgotten Island",   function() tp(Vector3.new(-5500,300,-1600)) end)
Teleport:Separator("--- Third Sea ---")
Teleport:Button("Port Town",          function() tp(Vector3.new(-4970,24,-7900))  end)
Teleport:Button("Hydra Island",       function() tp(Vector3.new(-6300,10,-7200))  end)
Teleport:Button("Great Tree",         function() tp(Vector3.new(5400,60,-7900))   end)
Teleport:Button("Floating Turtle",    function() tp(Vector3.new(6150,350,-7590))  end)
Teleport:Button("Haunted Castle",     function() tp(Vector3.new(5780,140,-6630))  end)
Teleport:Button("Sea of Treats",      function() tp(Vector3.new(-11000,10,3800))  end)
Teleport:Button("Kitsune Island",     function() tp(Vector3.new(-11564,10,4321))  end)
Teleport:Button("Prehistoric Island", function() tp(Vector3.new(5983,5,-8000))    end)

-- TAB ESP
local ESP = Window:Tab("ESP")
ESP:Separator("--- ESP Visual ---")
ESP:Toggle("Player ESP", false, function(v)
    _G.BOP.ESPPlayers=v
    if not v then removeAllESP(); return end
    newThread("ESPPl", function()
        while _G.BOP.ESPPlayers do
            pcall(function()
                for _,p in ipairs(Players:GetPlayers()) do
                    if p~=lp and p.Character and not ESPBoxes[p.Character] then
                        createESPFor(p.Character,Color3.fromRGB(255,50,50))
                    end
                end
            end)
            task.wait(1)
        end
        removeAllESP()
    end)
end)
ESP:Toggle("Mob ESP", false, function(v)
    newThread("ESPMob", function()
        while v do
            pcall(function()
                for _,m in ipairs(Workspace:GetDescendants()) do
                    if m:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(m) and not ESPBoxes[m] then
                        createESPFor(m,Color3.fromRGB(255,165,0))
                    end
                end
            end)
            task.wait(2)
        end
    end)
end)
ESP:Toggle("Fruit ESP", false, function(v)
    newThread("ESPFr", function()
        while v do
            pcall(function()
                for _,o in ipairs(Workspace:GetDescendants()) do
                    if o.Name:lower():find("fruit") and not ESPBoxes[o] then
                        createESPFor(o,Color3.fromRGB(50,255,100))
                    end
                end
            end)
            task.wait(2)
        end
    end)
end)
ESP:Toggle("Chest ESP", false, function(v)
    newThread("ESPCh", function()
        while v do
            pcall(function()
                for _,o in ipairs(Workspace:GetDescendants()) do
                    if o.Name:lower():find("chest") and not ESPBoxes[o] then
                        createESPFor(o,Color3.fromRGB(255,215,0))
                    end
                end
            end)
            task.wait(2)
        end
    end)
end)
ESP:Toggle("Boss ESP", false, function(v)
    newThread("ESPBoss", function()
        while v do
            pcall(function()
                for _,o in ipairs(Workspace:GetDescendants()) do
                    if o.Name:find("Boss") and o:FindFirstChild("Humanoid") and not ESPBoxes[o] then
                        createESPFor(o,Color3.fromRGB(255,0,0))
                    end
                end
            end)
            task.wait(2)
        end
    end)
end)
ESP:Button("Limpiar todos los ESPs", function()
    removeAllESP()
    Window:Notify("ESP","Todos los ESPs eliminados")
end)

-- TAB PLAYER
local PlayerTab = Window:Tab("Player")
PlayerTab:Separator("--- Movement ---")
PlayerTab:Toggle("Speed Hack", false, function(v)
    _G.BOP.SpeedHack=v
    newThread("SpeedHack", function()
        while _G.BOP.SpeedHack do pcall(function() hum.WalkSpeed=_G.BOP.SpeedValue end); task.wait(0.1) end
        pcall(function() hum.WalkSpeed=16 end)
    end)
end)
PlayerTab:Slider("Walk Speed", 16, 500, 20, function(v) _G.BOP.SpeedValue=v end)
PlayerTab:Toggle("Fly Hack", false, function(v)
    _G.BOP.FlyHack=v
    newThread("FlyHack", function()
        if not v then return end
        local bg=Instance.new("BodyGyro",hrp); local bv=Instance.new("BodyVelocity",hrp)
        bg.MaxTorque=Vector3.new(1e9,1e9,1e9); bv.MaxForce=Vector3.new(1e9,1e9,1e9)
        while _G.BOP.FlyHack do
            local cam=Workspace.CurrentCamera; local md=hum.MoveDirection
            bv.Velocity=(md.Magnitude>0 and md*_G.BOP.SpeedValue or Vector3.new(0,0,0))+Vector3.new(0,20,0)
            bg.CFrame=cam.CFrame; task.wait()
        end
        pcall(bg.Destroy,bg); pcall(bv.Destroy,bv)
    end)
end)
PlayerTab:Toggle("Infinite Jump", false, function(v)
    _G.BOP.InfiniteJump=v
    newThread("InfJump", function()
        local c; if v then c=UIS.JumpRequest:Connect(function() if _G.BOP.InfiniteJump then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end) end
        while _G.BOP.InfiniteJump do task.wait(1) end
        if c then c:Disconnect() end
    end)
end)
PlayerTab:Separator("--- Misc ---")
PlayerTab:Toggle("Anti AFK", false, function(v)
    newThread("AntiAFK", function()
        while v do VU:CaptureController(); VU:ClickButton2(Vector2.new(0,0),Workspace.CurrentCamera.CFrame); task.wait(60) end
    end)
end)
PlayerTab:Toggle("Full Bright", false, function(v)
    pcall(function()
        local L=game:GetService("Lighting")
        L.Brightness=v and 10 or 1; L.FogEnd=v and 1e6 or 1000
        L.GlobalShadows=not v; L.Ambient=v and Color3.new(1,1,1) or Color3.new(0,0,0)
    end)
end)
PlayerTab:Toggle("Anti-Lag (quitar particulas)", false, function(v)
    if v then
        pcall(function()
            for _,o in ipairs(Workspace:GetDescendants()) do
                if o:IsA("ParticleEmitter") or o:IsA("Smoke") or o:IsA("Fire") or o:IsA("Sparkles") then
                    o.Enabled=false
                end
            end
        end)
        Window:Notify("Anti-Lag","Particulas eliminadas")
    end
end)
PlayerTab:Separator("--- Auto Stats ---")
PlayerTab:Toggle("Auto Stats (Melee)", false, function(v)
    newThread("StMelee", function() while v do pcall(function() local g=lp.PlayerGui:FindFirstChild("StatsGui",true); if g then local b=g:FindFirstChild("Melee",true); if b then b:FireServer("Melee") end end end); task.wait(3) end end)
end)
PlayerTab:Toggle("Auto Stats (Fruit)", false, function(v)
    newThread("StFruit", function() while v do pcall(function() local g=lp.PlayerGui:FindFirstChild("StatsGui",true); if g then local b=g:FindFirstChild("Fruit",true); if b then b:FireServer("Fruit") end end end); task.wait(3) end end)
end)
PlayerTab:Toggle("Auto Stats (Sword)", false, function(v)
    newThread("StSword", function() while v do pcall(function() local g=lp.PlayerGui:FindFirstChild("StatsGui",true); if g then local b=g:FindFirstChild("Sword",true); if b then b:FireServer("Sword") end end end); task.wait(3) end end)
end)

-- TAB EVENTS
local Events = Window:Tab("Events")
local function eventFarm(kws, coord, lbl)
    return function(v)
        newThread("Ev_"..lbl, function()
            while v do
                pcall(function()
                    local isl=findByName(kws)
                    if isl then
                        local bp=isl:IsA("BasePart") and isl or isl:FindFirstChildWhichIsA("BasePart")
                        if bp then safeTP(bp.CFrame*CFrame.new(0,8,0)) end
                    else safeTP(CFrame.new(coord)) end
                    for _,m in ipairs(Workspace:GetDescendants()) do
                        if m:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(m)
                            and m.Humanoid.Health>0
                            and (m.HumanoidRootPart.Position-hrp.Position).Magnitude<60 then
                            safeTP(m.HumanoidRootPart.CFrame*CFrame.new(0,0,-4))
                        end
                    end
                end)
                task.wait(0.3)
            end
        end)
    end
end
Events:Separator("--- Volcano ---")
Events:Toggle("Auto Volcano Event", false, eventFarm({"Volcano","Lava"},Vector3.new(-1177,40,2046),"Volcano"))
Events:Button("TP Volcano", function() safeTP(CFrame.new(-1177,40,2046)) end)
Events:Separator("--- Prehistoric ---")
Events:Toggle("Auto Prehistoric Event", false, eventFarm({"Prehistoric","Dino"},Vector3.new(5983,5,-8000),"Prehist"))
Events:Button("TP Prehistoric", function() safeTP(CFrame.new(5983,5,-8000)) end)
Events:Separator("--- Kitsune ---")
Events:Toggle("Auto Kitsune Event", false, eventFarm({"Kitsune","Fox"},Vector3.new(-11564,10,4321),"Kitsune"))
Events:Button("TP Kitsune", function() safeTP(CFrame.new(-11564,10,4321)) end)
Events:Separator("--- Sea Beast ---")
Events:Toggle("Auto Kill Sea Beast", false, function(v)
    newThread("AutoSB", function()
        while v do
            pcall(function()
                local b=findByName({"SeaBeast","Sea Beast","Leviathan"})
                if b then
                    local bp=b:IsA("BasePart") and b or b:FindFirstChildWhichIsA("BasePart")
                    if bp then safeTP(bp.CFrame*CFrame.new(0,5,-6)); local bh=b:FindFirstChild("Humanoid"); if bh then bh.Health=0 end end
                end
            end)
            task.wait(1)
        end
    end)
end)
Events:Separator("--- Mirage Island ---")
Events:Toggle("Auto Farm Mirage Island", false, function(v)
    newThread("AutoMirage", function()
        while v do
            pcall(function()
                local mi=findByName({"Mirage","MirageIsland"})
                if mi then
                    local bp=mi:IsA("BasePart") and mi or mi:FindFirstChildWhichIsA("BasePart")
                    if bp then safeTP(bp.CFrame*CFrame.new(0,5,0)) end
                    for _,o in ipairs(Workspace:GetDescendants()) do
                        if o.Name:lower():find("fruit") and o:IsA("BasePart") then
                            safeTP(o.CFrame*CFrame.new(0,2,0)); task.wait(0.3)
                        end
                    end
                end
            end)
            task.wait(2)
        end
    end)
end)

-- TAB RACE V4
local RaceV4 = Window:Tab("Race V4")
RaceV4:Separator("--- Human V4 ---")
RaceV4:Toggle("Auto Human Race V4", false, function(v)
    newThread("HumanV4", function()
        safeTP(CFrame.new(-4860,860,-1780)); task.wait(1.5); autoAcceptPrompt()
        local k=0
        while v and k<30 do
            pcall(function()
                for _,m in ipairs(Workspace:GetDescendants()) do
                    if m:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(m) and m.Humanoid.Health>0 then
                        safeTP(m.HumanoidRootPart.CFrame*CFrame.new(0,0,-4)); task.wait(0.5); k+=1; break
                    end
                end
            end)
            task.wait(0.2)
        end
        safeTP(CFrame.new(-4820,870,-1600)); task.wait(1)
        local e=findByName({"Enel","GodEnel"}); if e then local eh=e:FindFirstChild("Humanoid"); if eh then eh.Health=0 end end
        task.wait(1); safeTP(CFrame.new(-4860,860,-1780)); autoAcceptPrompt()
        Window:Notify("Race V4","Human Race V4 completada!")
    end)
end)
RaceV4:Button("TP Alchemist", function() safeTP(CFrame.new(-4860,860,-1780)) end)
RaceV4:Button("TP God Enel",  function() safeTP(CFrame.new(-4820,870,-1600)) end)
RaceV4:Separator("--- Shark V4 ---")
RaceV4:Toggle("Auto Shark Race V4", false, function(v)
    newThread("SharkV4", function()
        local sk=0
        while v and sk<10 do
            pcall(function()
                local b=findByName({"SeaBeast","Sea Beast"})
                if b then local bp=b:FindFirstChildWhichIsA("BasePart"); if bp then safeTP(bp.CFrame*CFrame.new(0,3,-5)); local h=b:FindFirstChild("Humanoid"); if h then h.Health=0;sk+=1 end end end
            end)
            task.wait(1)
        end
        safeTP(CFrame.new(-11432,10,3970)); task.wait(1.5); autoAcceptPrompt()
        Window:Notify("Race V4","Shark Race V4 completada!")
    end)
end)
RaceV4:Button("TP Shark NPC", function() safeTP(CFrame.new(-11432,10,3970)) end)
RaceV4:Separator("--- Angel V4 ---")
RaceV4:Toggle("Auto Angel Race V4", false, function(v)
    newThread("AngelV4", function()
        safeTP(CFrame.new(-4980,620,-530)); task.wait(1)
        local k=0
        while v and k<5 do
            pcall(function()
                local b=findByName({"Guan","GuanYu","HeavenBoss"})
                if b then local bp=b:FindFirstChildWhichIsA("BasePart"); if bp then safeTP(bp.CFrame*CFrame.new(0,0,-4)); local h=b:FindFirstChild("Humanoid"); if h then h.Health=0;k+=1 end end end
            end)
            task.wait(2)
        end
        safeTP(CFrame.new(-4980,620,-530)); autoAcceptPrompt()
        Window:Notify("Race V4","Angel Race V4 completada!")
    end)
end)
RaceV4:Button("TP Heaven", function() safeTP(CFrame.new(-4980,620,-530)) end)
RaceV4:Separator("--- Cyborg V4 ---")
RaceV4:Toggle("Auto Cyborg Race V4", false, function(v)
    newThread("CyborgV4", function()
        safeTP(CFrame.new(-1600,140,240)); task.wait(1)
        local k=0
        while v and k<3 do
            pcall(function()
                local ice=findByName({"IceAdmiral","Ice Admiral"})
                if ice then local bp=ice:FindFirstChildWhichIsA("BasePart"); if bp then safeTP(bp.CFrame*CFrame.new(0,0,-4)); local h=ice:FindFirstChild("Humanoid"); if h then h.Health=0;k+=1 end end end
            end)
            task.wait(2)
        end
        safeTP(CFrame.new(430,184,1296)); task.wait(1.5); autoAcceptPrompt()
        Window:Notify("Race V4","Cyborg Race V4 completada!")
    end)
end)
RaceV4:Button("TP Ice Admiral", function() safeTP(CFrame.new(-1600,140,240)) end)
RaceV4:Button("TP Cyborg NPC",  function() safeTP(CFrame.new(430,184,1296))  end)

-- TAB CONFIG
local Config = Window:Tab("Config")
Config:Separator("--- Anti-Cheat ---")
Config:Toggle("Bypass Teleport (TweenTP)", true, function(v)
    _G.BOP.BypassTP=v
    Window:Notify("Bypass TP", v and "TweenTP activo" or "TP directo")
end)
Config:Toggle("Anti-Kick (Hook)", false, function(v)
    if v then applyAntiKick(); Window:Notify("Anti-Kick","Hook aplicado") end
end)
Config:Toggle("Simular Movimiento Humano", false, function(v)
    newThread("HumanMov", function()
        while v do
            pcall(function() hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(math.random(-5,5)),0) end)
            task.wait(math.random(3,8))
        end
    end)
end)
Config:Separator("--- RAM & Performance ---")
Config:Toggle("Auto RAM Cleaner", true, function(v)
    newThread("RAMClean", function()
        while v do
            task.wait(8)
            local ram=math.floor(gcinfo()/1024)
            if ram>1400 then
                collectgarbage("collect")
                for obj,hl in pairs(ESPBoxes) do
                    if not obj.Parent then pcall(function() hl:Destroy() end); ESPBoxes[obj]=nil end
                end
                Window:Notify("RAM Shield","RAM limpiada: "..ram.."MB")
            end
        end
    end)
end)
Config:Button("Limpiar RAM Ahora", function()
    collectgarbage("collect")
    Window:Notify("RAM","Limpiada: "..math.floor(gcinfo()/1024).."MB")
end)
Config:Separator("--- Control ---")
Config:Button("KILL SWITCH (Desactiva TODO)", function()
    for k,v in pairs(_G.BOP) do if type(v)=="boolean" then _G.BOP[k]=false end end
    for n in pairs(Threads) do killThread(n) end
    removeAllESP()
    Window:Notify("Kill Switch","Todo desactivado")
end)
Config:Button("Reload Character", function() lp:LoadCharacter() end)
Config:Button("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId,lp)
end)
Config:Label("BOP HUB v9.0 | Delta Optimizado")

newThread("RAMClean", function()
    while true do
        task.wait(8)
        if math.floor(gcinfo()/1024)>1400 then
            collectgarbage("collect")
            for obj,hl in pairs(ESPBoxes) do
                if not obj.Parent then pcall(function() hl:Destroy() end); ESPBoxes[obj]=nil end
            end
        end
    end
end)
