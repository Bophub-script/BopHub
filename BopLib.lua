-- ╔══════════════════════════════════════════════════════════════╗
-- ║              BOP LIB — UI LIBRARY v1.0                      ║
-- ║        Menú desplegable | Morado/Negro | Delta              ║
-- ╚══════════════════════════════════════════════════════════════╝
-- USO:
--   local BopLib = loadstring(game:HttpGet("RAW_URL"))()
--   local Window = BopLib.new("BOP HUB v8")
--   local Tab    = Window:Tab("🌾 Farm")
--   Tab:Toggle("Auto Farm", false, function(v) end)
--   Tab:Slider("Speed", 16, 500, 20, function(v) end)
--   Tab:Button("Reload", function() end)
--   Tab:Label("Texto informativo")
--   Tab:Separator("— Sección —")
--   Window:Notify("Título", "Mensaje", 4)

local BopLib = {}
BopLib.__index = BopLib

-- ══ PALETA DE COLORES ══
local C = {
    BG        = Color3.fromRGB(10,  10,  16),   -- fondo principal
    PANEL     = Color3.fromRGB(18,  14,  30),   -- panel de tabs/contenido
    TAB_OFF   = Color3.fromRGB(28,  20,  46),   -- tab inactivo
    TAB_ON    = Color3.fromRGB(110, 40, 200),   -- tab activo
    ACCENT    = Color3.fromRGB(130, 60, 220),   -- acento morado
    ACCENT2   = Color3.fromRGB(180, 80, 255),   -- morado claro
    TOGGLE_ON = Color3.fromRGB(120, 50, 210),
    TOGGLE_OFF= Color3.fromRGB(50,  40,  70),
    BTN       = Color3.fromRGB(90,  35, 160),
    BTN_HOVER = Color3.fromRGB(130, 60, 210),
    TEXT      = Color3.fromRGB(240, 230, 255),
    TEXT_DIM  = Color3.fromRGB(160, 140, 190),
    BORDER    = Color3.fromRGB(80,  50, 130),
    SEP       = Color3.fromRGB(60,  40, 100),
    HEADER    = Color3.fromRGB(22,  10,  42),
    SLIDER_BG = Color3.fromRGB(40,  28,  70),
    SLIDER_FG = Color3.fromRGB(110, 40, 200),
    NOTIF_BG  = Color3.fromRGB(20,  12,  38),
}

local FONT      = Enum.Font.GothamBold
local FONT_REG  = Enum.Font.Gotham
local CORNER    = UDim.new(0, 10)
local CORNER_SM = UDim.new(0, 6)

local Players   = game:GetService("Players")
local TweenSvc  = game:GetService("TweenService")
local UIS       = game:GetService("UserInputService")
local lp        = Players.LocalPlayer

local function tween(obj, props, t)
    TweenSvc:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad), props):Play()
end

local function corner(parent, r)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = r or CORNER
    return c
end

local function stroke(parent, clr, thick)
    local s = Instance.new("UIStroke", parent)
    s.Color = clr or C.BORDER
    s.Thickness = thick or 1.2
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function gradient(parent, c0, c1, rot)
    local g = Instance.new("UIGradient", parent)
    g.Color = ColorSequence.new(c0, c1)
    g.Rotation = rot or 90
    return g
end

local function makePadding(parent, t,b,l,r)
    local p = Instance.new("UIPadding", parent)
    p.PaddingTop    = UDim.new(0, t or 6)
    p.PaddingBottom = UDim.new(0, b or 6)
    p.PaddingLeft   = UDim.new(0, l or 8)
    p.PaddingRight  = UDim.new(0, r or 8)
    return p
end

local function makeListLayout(parent, dir, pad, align)
    local l = Instance.new("UIListLayout", parent)
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.Padding = UDim.new(0, pad or 4)
    l.HorizontalAlignment = align or Enum.HorizontalAlignment.Center
    l.SortOrder = Enum.SortOrder.LayoutOrder
    return l
end

-- ══ RIPPLE EFFECT (toque táctil) ══
local function ripple(button)
    local ripFrame = Instance.new("Frame", button)
    ripFrame.BackgroundColor3 = Color3.new(1,1,1)
    ripFrame.BackgroundTransparency = 0.7
    ripFrame.Size = UDim2.new(0,0,0,0)
    ripFrame.AnchorPoint = Vector2.new(0.5,0.5)
    ripFrame.Position = UDim2.new(0.5,0,0.5,0)
    ripFrame.ZIndex = button.ZIndex + 1
    ripFrame.BorderSizePixel = 0
    corner(ripFrame, UDim.new(1,0))
    tween(ripFrame, {Size=UDim2.new(0,120,0,120), BackgroundTransparency=1}, 0.35)
    task.delay(0.4, function() ripFrame:Destroy() end)
end

-- ══ CONSTRUCTOR PRINCIPAL ══
function BopLib.new(title)
    local self = setmetatable({}, BopLib)
    self._tabs      = {}
    self._activeTab = nil
    self._open      = true

    -- ── ScreenGui
    local sg = Instance.new("ScreenGui")
    sg.Name            = "BopLibGui"
    sg.ResetOnSpawn    = false
    sg.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset  = true
    sg.Parent          = lp.PlayerGui
    self._sg = sg

    -- ── ROOT FRAME (se desliza desde arriba)
    local root = Instance.new("Frame", sg)
    root.Name                = "Root"
    root.Size                = UDim2.new(0, 370, 0, 520)
    root.Position            = UDim2.new(0.5, -185, 0, -530) -- fuera de pantalla arriba
    root.BackgroundColor3    = C.BG
    root.BorderSizePixel     = 0
    root.ClipsDescendants    = true
    corner(root, UDim.new(0,14))
    stroke(root, C.BORDER, 1.5)
    gradient(root,
        Color3.fromRGB(22,12,42),
        Color3.fromRGB(10,10,16), 160)
    self._root = root

    -- Sombra exterior
    local shadow = Instance.new("ImageLabel", root)
    shadow.Name                = "Shadow"
    shadow.Size                = UDim2.new(1,30,1,30)
    shadow.Position            = UDim2.new(0,-15,0,-5)
    shadow.BackgroundTransparency = 1
    shadow.Image               = "rbxassetid://6014261993"
    shadow.ImageColor3         = Color3.fromRGB(0,0,0)
    shadow.ImageTransparency   = 0.4
    shadow.ScaleType           = Enum.ScaleType.Slice
    shadow.SliceCenter         = Rect.new(49,49,450,450)
    shadow.ZIndex              = 0

    -- ── HEADER
    local header = Instance.new("Frame", root)
    header.Name              = "Header"
    header.Size              = UDim2.new(1,0,0,46)
    header.BackgroundColor3  = C.HEADER
    header.BorderSizePixel   = 0
    corner(header, UDim.new(0,14))
    gradient(header,
        Color3.fromRGB(110,40,200),
        Color3.fromRGB(22,10,42), 90)

    -- Línea inferior del header
    local headerLine = Instance.new("Frame", header)
    headerLine.Size              = UDim2.new(1,0,0,1)
    headerLine.Position          = UDim2.new(0,0,1,-1)
    headerLine.BackgroundColor3  = C.ACCENT
    headerLine.BackgroundTransparency = 0.4
    headerLine.BorderSizePixel   = 0

    -- Título
    local titleLbl = Instance.new("TextLabel", header)
    titleLbl.Size                = UDim2.new(1,-50,1,0)
    titleLbl.Position            = UDim2.new(0,14,0,0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text                = "⚡ " .. title
    titleLbl.TextColor3          = C.TEXT
    titleLbl.Font                = FONT
    titleLbl.TextSize            = 15
    titleLbl.TextXAlignment      = Enum.TextXAlignment.Left

    -- Botón cerrar/abrir (X / ▼)
    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size                = UDim2.new(0,32,0,28)
    closeBtn.Position            = UDim2.new(1,-40,0.5,-14)
    closeBtn.BackgroundColor3    = Color3.fromRGB(180,40,60)
    closeBtn.Text                = "✕"
    closeBtn.TextColor3          = Color3.new(1,1,1)
    closeBtn.Font                = FONT
    closeBtn.TextSize            = 13
    closeBtn.BorderSizePixel     = 0
    corner(closeBtn, CORNER_SM)

    closeBtn.MouseButton1Click:Connect(function()
        ripple(closeBtn)
        self._open = not self._open
        if self._open then
            tween(root, {Position = UDim2.new(0.5,-185,0,10)}, 0.35)
            closeBtn.Text = "✕"
        else
            tween(root, {Position = UDim2.new(0.5,-185,0,-480)}, 0.3)
            closeBtn.Text = "▼"
        end
    end)

    -- ── TAB BAR (scroll horizontal)
    local tabBarScroll = Instance.new("ScrollingFrame", root)
    tabBarScroll.Name                = "TabBar"
    tabBarScroll.Size                = UDim2.new(1,0,0,38)
    tabBarScroll.Position            = UDim2.new(0,0,0,46)
    tabBarScroll.BackgroundColor3    = C.PANEL
    tabBarScroll.BorderSizePixel     = 0
    tabBarScroll.ScrollBarThickness  = 0
    tabBarScroll.ScrollingDirection  = Enum.ScrollingDirection.X
    tabBarScroll.CanvasSize          = UDim2.new(0,0,0,0)
    tabBarScroll.ClipsDescendants    = true

    -- Línea inferior tabs
    local tabLine = Instance.new("Frame", root)
    tabLine.Size             = UDim2.new(1,0,0,1)
    tabLine.Position         = UDim2.new(0,0,0,84)
    tabLine.BackgroundColor3 = C.ACCENT
    tabLine.BackgroundTransparency = 0.6
    tabLine.BorderSizePixel  = 0

    local tabBarList = Instance.new("Frame", tabBarScroll)
    tabBarList.Name              = "List"
    tabBarList.BackgroundTransparency = 1
    tabBarList.Size              = UDim2.new(0,0,1,0)
    tabBarList.AutomaticSize     = Enum.AutomaticSize.X
    local tabLayout = makeListLayout(tabBarList, Enum.FillDirection.Horizontal, 3)
    makePadding(tabBarList, 6,6,6,6)

    self._tabBarScroll = tabBarScroll
    self._tabBarList   = tabBarList
    self._tabLayout    = tabLayout

    -- ── CONTENT AREA (scroll vertical)
    local contentScroll = Instance.new("ScrollingFrame", root)
    contentScroll.Name               = "Content"
    contentScroll.Size               = UDim2.new(1,0,1,-86)
    contentScroll.Position           = UDim2.new(0,0,0,86)
    contentScroll.BackgroundTransparency = 1
    contentScroll.BorderSizePixel    = 0
    contentScroll.ScrollBarThickness = 3
    contentScroll.ScrollBarImageColor3 = C.ACCENT
    contentScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    contentScroll.CanvasSize         = UDim2.new(0,0,0,0)
    contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self._contentScroll = contentScroll

    -- ── DRAG (arrastra el menú)
    local dragging, dragStart, startPos = false, nil, nil
    header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
            or i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = i.Position
            startPos  = root.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.Touch
            or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = i.Position - dragStart
            root.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
            or i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Animación de apertura al cargar
    task.defer(function()
        tween(root, {Position = UDim2.new(0.5,-185,0,10)}, 0.4)
    end)

    return self
end

-- ══ CREAR TAB ══
function BopLib:Tab(name)
    local tabObj = {_elements = {}, _frame = nil, _btn = nil, _lib = self}

    -- Botón del tab en la barra
    local btn = Instance.new("TextButton", self._tabBarList)
    btn.Name                = name
    btn.AutomaticSize       = Enum.AutomaticSize.X
    btn.Size                = UDim2.new(0,0,1,-8)
    btn.BackgroundColor3    = C.TAB_OFF
    btn.Text                = name
    btn.TextColor3          = C.TEXT_DIM
    btn.Font                = FONT_REG
    btn.TextSize            = 12
    btn.BorderSizePixel     = 0
    btn.AutoButtonColor     = false
    corner(btn, CORNER_SM)
    makePadding(btn, 0,0,10,10)
    tabObj._btn = btn

    -- Frame de contenido del tab
    local frame = Instance.new("Frame", self._contentScroll)
    frame.Name               = name
    frame.Size               = UDim2.new(1,0,0,0)
    frame.AutomaticSize      = Enum.AutomaticSize.Y
    frame.BackgroundTransparency = 1
    frame.Visible            = false
    local frameList = makeListLayout(frame, Enum.FillDirection.Vertical, 5)
    makePadding(frame, 6,10,8,8)
    tabObj._frame = frame

    -- Actualizar canvas width del tab bar
    local function updateTabBarCanvas()
        local total = 0
        for _, c in ipairs(self._tabBarList:GetChildren()) do
            if c:IsA("GuiObject") then total += c.AbsoluteSize.X + 3 end
        end
        self._tabBarScroll.CanvasSize = UDim2.new(0, total + 20, 0, 0)
    end
    btn:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateTabBarCanvas)

    btn.MouseButton1Click:Connect(function()
        ripple(btn)
        -- Desactivar tab anterior
        if self._activeTab then
            tween(self._activeTab._btn, {BackgroundColor3=C.TAB_OFF, TextColor3=C.TEXT_DIM}, 0.12)
            self._activeTab._frame.Visible = false
        end
        -- Activar este tab
        tween(btn, {BackgroundColor3=C.TAB_ON, TextColor3=C.TEXT}, 0.12)
        frame.Visible = true
        self._contentScroll.CanvasPosition = Vector2.new(0,0)
        self._activeTab = tabObj
    end)

    -- Activar primero si no hay ninguno
    if not self._activeTab then
        self._activeTab = tabObj
        frame.Visible = true
        btn.BackgroundColor3 = C.TAB_ON
        btn.TextColor3       = C.TEXT
    end

    table.insert(self._tabs, tabObj)

    -- ══ MÉTODOS DEL TAB ══

    -- ── SEPARATOR / SECTION HEADER
    function tabObj:Separator(text)
        local sep = Instance.new("Frame", self._frame)
        sep.Size             = UDim2.new(1,0,0,24)
        sep.BackgroundColor3 = C.SEP
        sep.BorderSizePixel  = 0
        corner(sep, UDim.new(0,6))
        gradient(sep,
            Color3.fromRGB(80,40,130),
            Color3.fromRGB(30,20,55), 90)

        local lbl = Instance.new("TextLabel", sep)
        lbl.Size             = UDim2.new(1,0,1,0)
        lbl.BackgroundTransparency = 1
        lbl.Text             = text or ""
        lbl.TextColor3       = C.ACCENT2
        lbl.Font             = FONT
        lbl.TextSize         = 11
        lbl.TextXAlignment   = Enum.TextXAlignment.Center
    end

    -- ── LABEL
    function tabObj:Label(text)
        local lbl = Instance.new("TextLabel", self._frame)
        lbl.Size             = UDim2.new(1,0,0,22)
        lbl.BackgroundTransparency = 1
        lbl.Text             = "  " .. (text or "")
        lbl.TextColor3       = C.TEXT_DIM
        lbl.Font             = FONT_REG
        lbl.TextSize         = 11
        lbl.TextXAlignment   = Enum.TextXAlignment.Left
        lbl.TextWrapped      = true
    end

    -- ── BUTTON
    function tabObj:Button(name, callback)
        local btn2 = Instance.new("TextButton", self._frame)
        btn2.Size             = UDim2.new(1,0,0,36)
        btn2.BackgroundColor3 = C.BTN
        btn2.Text             = name
        btn2.TextColor3       = C.TEXT
        btn2.Font             = FONT
        btn2.TextSize         = 13
        btn2.BorderSizePixel  = 0
        btn2.AutoButtonColor  = false
        corner(btn2, CORNER_SM)
        stroke(btn2, C.ACCENT, 1)
        gradient(btn2,
            Color3.fromRGB(110,45,190),
            Color3.fromRGB(70,25,130), 90)

        btn2.MouseButton1Down:Connect(function()
            tween(btn2, {BackgroundColor3=C.BTN_HOVER}, 0.08)
            ripple(btn2)
        end)
        btn2.MouseButton1Up:Connect(function()
            tween(btn2, {BackgroundColor3=C.BTN}, 0.15)
        end)
        btn2.MouseButton1Click:Connect(function()
            pcall(callback)
        end)
    end

    -- ── TOGGLE
    function tabObj:Toggle(name, default, callback)
        local state = default or false

        local row = Instance.new("Frame", self._frame)
        row.Size             = UDim2.new(1,0,0,38)
        row.BackgroundColor3 = C.PANEL
        row.BorderSizePixel  = 0
        corner(row, CORNER_SM)
        stroke(row, C.BORDER, 1)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size             = UDim2.new(1,-60,1,0)
        lbl.Position         = UDim2.new(0,10,0,0)
        lbl.BackgroundTransparency = 1
        lbl.Text             = name
        lbl.TextColor3       = state and C.TEXT or C.TEXT_DIM
        lbl.Font             = FONT_REG
        lbl.TextSize         = 13
        lbl.TextXAlignment   = Enum.TextXAlignment.Left

        -- Switch pill
        local switchBG = Instance.new("Frame", row)
        switchBG.Size            = UDim2.new(0,44,0,22)
        switchBG.Position        = UDim2.new(1,-54,0.5,-11)
        switchBG.BackgroundColor3 = state and C.TOGGLE_ON or C.TOGGLE_OFF
        switchBG.BorderSizePixel = 0
        corner(switchBG, UDim.new(1,0))

        local knob = Instance.new("Frame", switchBG)
        knob.Size             = UDim2.new(0,18,0,18)
        knob.Position         = state and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)
        knob.BackgroundColor3 = Color3.new(1,1,1)
        knob.BorderSizePixel  = 0
        corner(knob, UDim.new(1,0))

        local function setToggle(v)
            state = v
            tween(switchBG, {BackgroundColor3 = state and C.TOGGLE_ON or C.TOGGLE_OFF}, 0.15)
            tween(knob, {Position = state and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)}, 0.15)
            lbl.TextColor3 = state and C.TEXT or C.TEXT_DIM
            pcall(callback, state)
        end

        -- Clickeable en toda la fila
        local clickArea = Instance.new("TextButton", row)
        clickArea.Size   = UDim2.new(1,0,1,0)
        clickArea.BackgroundTransparency = 1
        clickArea.Text   = ""
        clickArea.ZIndex = row.ZIndex + 2
        clickArea.MouseButton1Click:Connect(function()
            ripple(row)
            setToggle(not state)
        end)

        if state then pcall(callback, state) end

        return {
            Set = function(v) setToggle(v) end,
            Get = function() return state end,
        }
    end

    -- ── SLIDER
    function tabObj:Slider(name, min, max, default, callback)
        local value = default or min

        local container = Instance.new("Frame", self._frame)
        container.Size             = UDim2.new(1,0,0,54)
        container.BackgroundColor3 = C.PANEL
        container.BorderSizePixel  = 0
        corner(container, CORNER_SM)
        stroke(container, C.BORDER, 1)

        local topRow = Instance.new("Frame", container)
        topRow.Size             = UDim2.new(1,0,0,24)
        topRow.BackgroundTransparency = 1

        local nameLbl = Instance.new("TextLabel", topRow)
        nameLbl.Size            = UDim2.new(0.7,0,1,0)
        nameLbl.Position        = UDim2.new(0,10,0,0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text            = name
        nameLbl.TextColor3      = C.TEXT_DIM
        nameLbl.Font            = FONT_REG
        nameLbl.TextSize        = 13
        nameLbl.TextXAlignment  = Enum.TextXAlignment.Left

        local valLbl = Instance.new("TextLabel", topRow)
        valLbl.Size             = UDim2.new(0.28,0,1,0)
        valLbl.Position         = UDim2.new(0.72,0,0,0)
        valLbl.BackgroundTransparency = 1
        valLbl.Text             = tostring(value)
        valLbl.TextColor3       = C.ACCENT2
        valLbl.Font             = FONT
        valLbl.TextSize         = 13
        valLbl.TextXAlignment   = Enum.TextXAlignment.Right

        local trackBG = Instance.new("Frame", container)
        trackBG.Size             = UDim2.new(1,-20,0,8)
        trackBG.Position         = UDim2.new(0,10,0,32)
        trackBG.BackgroundColor3 = C.SLIDER_BG
        trackBG.BorderSizePixel  = 0
        corner(trackBG, UDim.new(1,0))

        local trackFill = Instance.new("Frame", trackBG)
        trackFill.Size            = UDim2.new((value-min)/(max-min),0,1,0)
        trackFill.BackgroundColor3 = C.SLIDER_FG
        trackFill.BorderSizePixel = 0
        corner(trackFill, UDim.new(1,0))
        gradient(trackFill,
            Color3.fromRGB(180,80,255),
            Color3.fromRGB(90,30,180), 0)

        local handle = Instance.new("Frame", trackBG)
        handle.Size             = UDim2.new(0,16,0,16)
        handle.AnchorPoint      = Vector2.new(0.5,0.5)
        handle.Position         = UDim2.new((value-min)/(max-min),0,0.5,0)
        handle.BackgroundColor3 = Color3.new(1,1,1)
        handle.BorderSizePixel  = 0
        corner(handle, UDim.new(1,0))
        local handleStroke = stroke(handle, C.ACCENT, 1.5)

        local function updateSlider(inputX)
            local abs = trackBG.AbsolutePosition.X
            local sz  = trackBG.AbsoluteSize.X
            local pct = math.clamp((inputX - abs) / sz, 0, 1)
            value = math.floor(min + (max-min) * pct)
            valLbl.Text = tostring(value)
            tween(trackFill, {Size = UDim2.new(pct,0,1,0)}, 0.05)
            tween(handle,    {Position = UDim2.new(pct,0,0.5,0)}, 0.05)
            pcall(callback, value)
        end

        local sliding = false
        trackBG.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch
                or i.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = true
                updateSlider(i.Position.X)
            end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(i)
            if sliding and (i.UserInputType == Enum.UserInputType.Touch
                or i.UserInputType == Enum.UserInputType.MouseMovement) then
                updateSlider(i.Position.X)
            end
        end)
        game:GetService("UserInputService").InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch
                or i.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = false
            end
        end)

        pcall(callback, value)

        return {
            Set = function(v)
                value = math.clamp(v, min, max)
                local pct = (value-min)/(max-min)
                valLbl.Text = tostring(value)
                trackFill.Size = UDim2.new(pct,0,1,0)
                handle.Position = UDim2.new(pct,0,0.5,0)
                pcall(callback, value)
            end,
            Get = function() return value end,
        }
    end

    -- ── DROPDOWN
    function tabObj:Dropdown(name, options, default, callback)
        local selected = default or options[1] or ""
        local isOpen   = false

        local container = Instance.new("Frame", self._frame)
        container.Size             = UDim2.new(1,0,0,38)
        container.BackgroundColor3 = C.PANEL
        container.BorderSizePixel  = 0
        container.ClipsDescendants = false
        corner(container, CORNER_SM)
        stroke(container, C.BORDER, 1)
        container.ZIndex = 10

        local headerBtn = Instance.new("TextButton", container)
        headerBtn.Size            = UDim2.new(1,0,0,38)
        headerBtn.BackgroundTransparency = 1
        headerBtn.Text            = ""
        headerBtn.ZIndex          = 11

        local nameLbl = Instance.new("TextLabel", container)
        nameLbl.Size              = UDim2.new(0.6,0,1,0)
        nameLbl.Position          = UDim2.new(0,10,0,0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text              = name
        nameLbl.TextColor3        = C.TEXT_DIM
        nameLbl.Font              = FONT_REG
        nameLbl.TextSize          = 13
        nameLbl.TextXAlignment    = Enum.TextXAlignment.Left
        nameLbl.ZIndex            = 11

        local selLbl = Instance.new("TextLabel", container)
        selLbl.Size               = UDim2.new(0.38,0,1,0)
        selLbl.Position           = UDim2.new(0.6,0,0,0)
        selLbl.BackgroundTransparency = 1
        selLbl.Text               = selected .. " ▾"
        selLbl.TextColor3         = C.ACCENT2
        selLbl.Font               = FONT
        selLbl.TextSize           = 12
        selLbl.TextXAlignment     = Enum.TextXAlignment.Right
        selLbl.ZIndex             = 11

        -- Lista desplegable
        local dropList = Instance.new("Frame", container)
        dropList.Size             = UDim2.new(1,0,0,0)
        dropList.Position         = UDim2.new(0,0,1,4)
        dropList.BackgroundColor3 = C.PANEL
        dropList.BorderSizePixel  = 0
        dropList.ClipsDescendants = true
        dropList.ZIndex           = 20
        corner(dropList, CORNER_SM)
        stroke(dropList, C.ACCENT, 1)

        local dropLayout = makeListLayout(dropList, Enum.FillDirection.Vertical, 2)
        makePadding(dropList, 4,4,4,4)

        for _, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton", dropList)
            optBtn.Size             = UDim2.new(1,0,0,28)
            optBtn.BackgroundColor3 = selected == opt and C.TAB_ON or C.TAB_OFF
            optBtn.Text             = opt
            optBtn.TextColor3       = C.TEXT
            optBtn.Font             = FONT_REG
            optBtn.TextSize         = 12
            optBtn.BorderSizePixel  = 0
            optBtn.AutoButtonColor  = false
            optBtn.ZIndex           = 21
            corner(optBtn, UDim.new(0,5))

            optBtn.MouseButton1Click:Connect(function()
                selected = opt
                selLbl.Text = opt .. " ▾"
                for _, c in ipairs(dropList:GetChildren()) do
                    if c:IsA("TextButton") then
                        c.BackgroundColor3 = c.Text == opt and C.TAB_ON or C.TAB_OFF
                    end
                end
                -- cerrar
                isOpen = false
                tween(dropList, {Size=UDim2.new(1,0,0,0)}, 0.15)
                container.ClipsDescendants = true
                pcall(callback, opt)
            end)
        end

        local totalH = #options * 32 + 8

        headerBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            if isOpen then
                container.ClipsDescendants = false
                tween(dropList, {Size=UDim2.new(1,0,0,totalH)}, 0.18)
                selLbl.Text = selected .. " ▴"
            else
                tween(dropList, {Size=UDim2.new(1,0,0,0)}, 0.15)
                task.delay(0.16, function() container.ClipsDescendants = true end)
                selLbl.Text = selected .. " ▾"
            end
        end)

        return {
            Get = function() return selected end,
            Set = function(v)
                selected = v; selLbl.Text = v.." ▾"
                pcall(callback, v)
            end,
        }
    end

    return tabObj
end

-- ══ NOTIFICACIÓN ══
function BopLib:Notify(title, msg, duration)
    pcall(function()
        local sg2 = self._sg

        local notif = Instance.new("Frame", sg2)
        notif.Size             = UDim2.new(0, 280, 0, 64)
        notif.Position         = UDim2.new(1, 10, 1, -80)
        notif.BackgroundColor3 = C.NOTIF_BG
        notif.BorderSizePixel  = 0
        notif.ZIndex           = 100
        corner(notif, CORNER_SM)
        stroke(notif, C.ACCENT, 1.2)
        gradient(notif,
            Color3.fromRGB(110,40,200),
            Color3.fromRGB(18,12,32), 90)

        -- Barra lateral izquierda
        local bar = Instance.new("Frame", notif)
        bar.Size             = UDim2.new(0,3,1,0)
        bar.BackgroundColor3 = C.ACCENT2
        bar.BorderSizePixel  = 0
        bar.ZIndex           = 101
        corner(bar, UDim.new(0,2))

        local titleN = Instance.new("TextLabel", notif)
        titleN.Size            = UDim2.new(1,-14,0,24)
        titleN.Position        = UDim2.new(0,10,0,6)
        titleN.BackgroundTransparency = 1
        titleN.Text            = title
        titleN.TextColor3      = C.TEXT
        titleN.Font            = FONT
        titleN.TextSize        = 13
        titleN.TextXAlignment  = Enum.TextXAlignment.Left
        titleN.ZIndex          = 101

        local msgN = Instance.new("TextLabel", notif)
        msgN.Size              = UDim2.new(1,-14,0,26)
        msgN.Position          = UDim2.new(0,10,0,28)
        msgN.BackgroundTransparency = 1
        msgN.Text              = msg
        msgN.TextColor3        = C.TEXT_DIM
        msgN.Font              = FONT_REG
        msgN.TextSize          = 11
        msgN.TextXAlignment    = Enum.TextXAlignment.Left
        msgN.TextWrapped       = true
        msgN.ZIndex            = 101

        -- Slide in
        tween(notif, {Position=UDim2.new(1,-290,1,-80)}, 0.3)

        task.delay(duration or 4, function()
            tween(notif, {Position=UDim2.new(1,10,1,-80), BackgroundTransparency=1}, 0.3)
            task.delay(0.35, function() notif:Destroy() end)
        end)
    end)
end

-- ══ DESTROY ══
function BopLib:Destroy()
    if self._sg then self._sg:Destroy() end
end

return BopLib
