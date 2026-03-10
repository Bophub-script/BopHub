local BopLib = {}
BopLib.__index = BopLib

local C = {
    BG        = Color3.fromRGB(10,  10,  16),
    PANEL     = Color3.fromRGB(18,  14,  30),
    TAB_OFF   = Color3.fromRGB(28,  20,  46),
    TAB_ON    = Color3.fromRGB(110, 40, 200),
    ACCENT    = Color3.fromRGB(130, 60, 220),
    ACCENT2   = Color3.fromRGB(180, 80, 255),
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

local Players  = game:GetService("Players")
local TweenSvc = game:GetService("TweenService")
local UIS      = game:GetService("UserInputService")
local lp       = Players.LocalPlayer

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

local function makePadding(parent, t, b, l, r)
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
    l.SortOrder = Enum.S​​​​​​​​​​​​​​​​
