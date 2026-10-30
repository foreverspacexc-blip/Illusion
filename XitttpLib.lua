-- ================================================================
--  XitttpLib v2 — Mobile-ready, fixed layout
-- ================================================================
local XitttpLib = {}

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local GuiService       = game:GetService("GuiService")
local LocalPlayer      = Players.LocalPlayer
local Mouse            = LocalPlayer:GetMouse()

-- ================================================================
-- MOBILE DETECT
-- ================================================================
local IsMobile = UserInputService.TouchEnabled
    and not UserInputService.KeyboardEnabled
    and not UserInputService.MouseEnabled

-- ================================================================
-- SCALE HELPER — scales numbers for mobile
-- ================================================================
local S = IsMobile and 0.72 or 1
local function sc(n) return math.floor(n * S) end

-- ================================================================
-- ICONS — "rbxassetid://" + id
-- ================================================================
local Icons = {
    Home       = "rbxassetid://170940874",
    Combat     = "rbxassetid://17414627577",
    Player     = "rbxassetid://124871982298256",
    Misc       = "rbxassetid://3057073095",
    UISettings = "rbxassetid://139013812244063",
    Shield     = "rbxassetid://7241575981",
    Aim        = "rbxassetid://11717619752",
    Flash      = "rbxassetid://13160015076",
    Emote      = "rbxassetid://104347264130981",
    Bell       = "rbxassetid://13492315950",
    Gauge      = "rbxassetid://103047744083253",
    Clock      = "rbxassetid://17551409714",
    Eye        = "rbxassetid://13321848342",
    Speed      = "rbxassetid://13492318257",
}
XitttpLib.Icons = Icons

-- ================================================================
-- THEME
-- ================================================================
local T = {
    BG         = Color3.fromRGB(18, 18, 18),
    Sidebar    = Color3.fromRGB(12, 12, 12),
    Panel      = Color3.fromRGB(26, 26, 26),
    PanelHover = Color3.fromRGB(33, 33, 33),
    Border     = Color3.fromRGB(44, 44, 44),
    Text       = Color3.fromRGB(240, 240, 240),
    Dim        = Color3.fromRGB(120, 120, 120),
    Muted      = Color3.fromRGB(65,  65,  65),
    White      = Color3.fromRGB(255, 255, 255),
    NavActive  = Color3.fromRGB(28,  28,  28),
    TogOn      = Color3.fromRGB(210, 210, 210),
    TogOff     = Color3.fromRGB(55,  55,  55),
    SliderFill = Color3.fromRGB(200, 200, 200),
    SliderBG   = Color3.fromRGB(44,  44,  44),
    InputBG    = Color3.fromRGB(20,  20,  20),
    InputBdr   = Color3.fromRGB(52,  52,  52),
    InfoBG     = Color3.fromRGB(20,  20,  20),
    AccentPurp = Color3.fromRGB(138, 80, 220),
}
XitttpLib.Theme = T

-- ================================================================
-- UTIL
-- ================================================================
local function Tw(obj, props, t, sty, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.16, sty or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props
    ):Play()
end

local function New(cls, p, ch)
    local o = Instance.new(cls)
    for k, v in pairs(p or {}) do
        if k ~= "Parent" then o[k] = v end
    end
    for _, c in pairs(ch or {}) do c.Parent = o end
    if p and p.Parent then o.Parent = p.Parent end
    return o
end

local function Crn(r, p)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p; return c
end

local function Stk(col, th, p)
    local s = Instance.new("UIStroke")
    s.Color     = col or T.Border
    s.Thickness = th  or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p; return s
end

local function Pad(t, b, l, r, p)
    local u = Instance.new("UIPadding")
    u.PaddingTop    = UDim.new(0, t or 0)
    u.PaddingBottom = UDim.new(0, b or 0)
    u.PaddingLeft   = UDim.new(0, l or 0)
    u.PaddingRight  = UDim.new(0, r or 0)
    u.Parent = p; return u
end

local function List(sp, fd, p)
    local l = Instance.new("UIListLayout")
    l.Padding              = UDim.new(0, sp or 0)
    l.FillDirection        = fd or Enum.FillDirection.Vertical
    l.SortOrder            = Enum.SortOrder.LayoutOrder
    l.HorizontalAlignment  = Enum.HorizontalAlignment.Left
    l.Parent = p; return l
end

local function Img(id, color, size, pos, parent)
    return New("ImageLabel", {
        Image               = id,
        ImageColor3         = color or T.White,
        Size                = size or UDim2.new(0, 18, 0, 18),
        Position            = pos  or UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Parent              = parent,
    })
end

-- ================================================================
-- DRAGGABLE
-- ================================================================
local function Drag(handle, frame)
    local dragging, ds, sp = false, nil, nil
    local function onBegin(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            ds = inp.Position
            sp = frame.Position
        end
    end
    handle.InputBegan:Connect(onBegin)
    UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseMovement
        and inp.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = inp.Position - ds
        frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X,
                                    sp.Y.Scale, sp.Y.Offset + d.Y)
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ================================================================
-- TOGGLE WIDGET
-- ================================================================
local function MakeToggle(parent, default, onChanged)
    local bg = New("Frame", {
        Size             = UDim2.new(0, sc(40), 0, sc(22)),
        BackgroundColor3 = default and T.TogOn or T.TogOff,
        BorderSizePixel  = 0,
        Parent           = parent,
    })
    Crn(sc(11), bg)

    local knob = New("Frame", {
        Size             = UDim2.new(0, sc(16), 0, sc(16)),
        Position         = default and UDim2.new(1, -sc(19), 0.5, -sc(8))
                                    or UDim2.new(0,  sc(3),  0.5, -sc(8)),
        BackgroundColor3 = T.White,
        BorderSizePixel  = 0,
        Parent           = bg,
    })
    Crn(sc(8), knob)

    local btn = New("TextButton", {
        Size = UDim2.new(1,0,1,0), Text = "",
        BackgroundTransparency = 1,
        Parent = bg,
    })

    local state = default == true
    btn.MouseButton1Click:Connect(function()
        state = not state
        Tw(bg,   { BackgroundColor3 = state and T.TogOn or T.TogOff }, 0.18)
        Tw(knob, { Position = state
            and UDim2.new(1, -sc(19), 0.5, -sc(8))
            or  UDim2.new(0,  sc(3),  0.5, -sc(8)) }, 0.18)
        if onChanged then onChanged(state) end
    end)

    return {
        Frame    = bg,
        SetState = function(v)
            state = v
            Tw(bg,   { BackgroundColor3 = v and T.TogOn or T.TogOff }, 0.18)
            Tw(knob, { Position = v
                and UDim2.new(1, -sc(19), 0.5, -sc(8))
                or  UDim2.new(0,  sc(3),  0.5, -sc(8)) }, 0.18)
        end,
        GetState = function() return state end,
    }
end

-- ================================================================
-- CREATE WINDOW
-- ================================================================
function XitttpLib:CreateWindow(cfg)
    cfg = cfg or {}
    local title     = cfg.Title     or "Xittp"
    local subtitle  = cfg.Subtitle  or "Better Gameplay\nBigger Results"
    local footer    = cfg.Footer    or "Play Smart · Stay Ahead"
    local toggleKey = cfg.ToggleKey or Enum.KeyCode.RightShift
    local logoId    = cfg.Logo      or nil

    -- Window size — smaller on mobile
    local WIN_W = sc(IsMobile and 640 or 760)
    local WIN_H = sc(IsMobile and 440 or 510)
    local SB_W  = sc(IsMobile and 150 or 185)

    -- ScreenGui
    local sg = New("ScreenGui", {
        Name           = "XitttpGui",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        Parent         = LocalPlayer.PlayerGui,
    })

    -- Root window
    local win = New("Frame", {
        Name             = "Window",
        Size             = UDim2.new(0, WIN_W, 0, WIN_H),
        Position         = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2),
        BackgroundColor3 = T.BG,
        BorderSizePixel  = 0,
        Parent           = sg,
    })
    Crn(10, win)
    Stk(T.Border, 1, win)

    -- Shadow
    local shad = New("Frame", {
        Size                   = UDim2.new(1, 24, 1, 24),
        Position               = UDim2.new(0, -12, 0, 8),
        BackgroundColor3       = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.6,
        ZIndex                 = 0,
        BorderSizePixel        = 0,
        Parent                 = win,
    })
    Crn(14, shad)

    -- ============================================================
    -- SIDEBAR
    -- ============================================================
    local sb = New("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, SB_W, 1, 0),
        BackgroundColor3 = T.Sidebar,
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = win,
    })
    Crn(10, sb)
    -- fill right side of sidebar (square corner)
    New("Frame", {
        Size             = UDim2.new(0, 10, 1, 0),
        Position         = UDim2.new(1, -10, 0, 0),
        BackgroundColor3 = T.Sidebar,
        BorderSizePixel  = 0,
        Parent           = sb,
    })

    -- Logo area
    local logoArea = New("Frame", {
        Size                   = UDim2.new(1, 0, 0, sc(90)),
        BackgroundTransparency = 1,
        Parent                 = sb,
    })
    Pad(sc(16), 0, sc(16), sc(10), logoArea)

    -- Logo row
    local logoRow = New("Frame", {
        Size                   = UDim2.new(1, 0, 0, sc(34)),
        BackgroundTransparency = 1,
        Parent                 = logoArea,
    })

    -- checkmark
    New("TextLabel", {
        Text             = "✓",
        Font             = Enum.Font.GothamBold,
        TextSize         = sc(13),
        TextColor3       = T.Dim,
        Size             = UDim2.new(0, sc(16), 0, sc(16)),
        Position         = UDim2.new(0, 0, 0, -sc(4)),
        BackgroundTransparency = 1,
        Parent           = logoRow,
    })

    -- Logo image
    if logoId then
        Img(logoId, T.White, UDim2.new(0, sc(28), 0, sc(28)),
            UDim2.new(0, sc(18), 0.5, -sc(14)), logoRow)
    end

    local titleOff = logoId and sc(50) or sc(18)
    New("TextLabel", {
        Text             = title,
        Font             = Enum.Font.GothamBold,
        TextSize         = sc(20),
        TextColor3       = T.Text,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Size             = UDim2.new(1, -titleOff, 1, 0),
        Position         = UDim2.new(0, titleOff, 0, 0),
        BackgroundTransparency = 1,
        Parent           = logoRow,
    })

    New("TextLabel", {
        Text             = subtitle,
        Font             = Enum.Font.Gotham,
        TextSize         = sc(9),
        TextColor3       = T.Dim,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Size             = UDim2.new(1, 0, 0, sc(28)),
        Position         = UDim2.new(0, 0, 0, sc(38)),
        BackgroundTransparency = 1,
        Parent           = logoArea,
    })

    -- Divider under logo
    New("Frame", {
        Size             = UDim2.new(1, -sc(20), 0, 1),
        Position         = UDim2.new(0, sc(10), 0, sc(86)),
        BackgroundColor3 = T.Border,
        BorderSizePixel  = 0,
        Parent           = sb,
    })

    -- Nav list
    local navList = New("Frame", {
        Size                   = UDim2.new(1, 0, 1, -sc(96)),
        Position               = UDim2.new(0, 0, 0, sc(96)),
        BackgroundTransparency = 1,
        Parent                 = sb,
    })
    Pad(sc(4), sc(4), sc(8), sc(8), navList)
    List(sc(2), Enum.FillDirection.Vertical, navList)

    -- Sidebar drag
    Drag(logoArea, win)

    -- ============================================================
    -- CONTENT AREA
    -- ============================================================
    local contentWrap = New("Frame", {
        Name                   = "ContentWrap",
        Size                   = UDim2.new(1, -SB_W, 1, -sc(36)),
        Position               = UDim2.new(0, SB_W, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants       = true,
        Parent                 = win,
    })

    local pageContainer = New("Frame", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent                 = contentWrap,
    })

    -- ============================================================
    -- TITLEBAR (close + minimize + drag)
    -- ============================================================
    local titleBar = New("Frame", {
        Size                   = UDim2.new(1, -SB_W, 0, sc(36)),
        Position               = UDim2.new(0, SB_W, 0, 0),
        BackgroundTransparency = 1,
        ZIndex                 = 10,
        Parent                 = win,
    })
    Drag(titleBar, win)

    -- Close
    local closeBtn = New("TextButton", {
        Text             = "×",
        Font             = Enum.Font.GothamBold,
        TextSize         = sc(16),
        TextColor3       = T.Dim,
        Size             = UDim2.new(0, sc(28), 0, sc(28)),
        Position         = UDim2.new(1, -sc(34), 0.5, -sc(14)),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 11,
        Parent           = titleBar,
    })
    closeBtn.MouseButton1Click:Connect(function()
        Tw(win, { Size = UDim2.new(0, 0, 0, 0) }, 0.2)
        task.delay(0.25, function() sg:Destroy() end)
    end)
    closeBtn.MouseEnter:Connect(function()
        Tw(closeBtn, { TextColor3 = Color3.fromRGB(255, 75, 75) }, 0.1)
    end)
    closeBtn.MouseLeave:Connect(function()
        Tw(closeBtn, { TextColor3 = T.Dim }, 0.1)
    end)

    -- Minimize
    local minBtn = New("TextButton", {
        Text             = "−",
        Font             = Enum.Font.GothamBold,
        TextSize         = sc(16),
        TextColor3       = T.Dim,
        Size             = UDim2.new(0, sc(28), 0, sc(28)),
        Position         = UDim2.new(1, -sc(66), 0.5, -sc(14)),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 11,
        Parent           = titleBar,
    })
    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tw(win, { Size = UDim2.new(0, SB_W, 0, WIN_H) }, 0.2)
            contentWrap.Visible = false
        else
            Tw(win, { Size = UDim2.new(0, WIN_W, 0, WIN_H) }, 0.2)
            task.delay(0.21, function() contentWrap.Visible = true end)
        end
    end)
    minBtn.MouseEnter:Connect(function() Tw(minBtn, { TextColor3 = T.Text }, 0.1) end)
    minBtn.MouseLeave:Connect(function() Tw(minBtn, { TextColor3 = T.Dim  }, 0.1) end)

    -- ============================================================
    -- FOOTER
    -- ============================================================
    local foot = New("Frame", {
        Size             = UDim2.new(1, -SB_W, 0, sc(36)),
        Position         = UDim2.new(0, SB_W, 1, -sc(36)),
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = win,
    })
    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = T.Border,
        BorderSizePixel  = 0,
        Parent           = foot,
    })
    Pad(0, 0, sc(14), sc(14), foot)

    local footRow = New("Frame", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent                 = foot,
    })
    New("TextLabel", {
        Text             = title,
        Font             = Enum.Font.GothamBold,
        TextSize         = sc(10),
        TextColor3       = T.Muted,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Size             = UDim2.new(0, sc(60), 1, 0),
        BackgroundTransparency = 1,
        Parent           = footRow,
    })
    New("Frame", {
        Size             = UDim2.new(0, 1, 0, sc(14)),
        Position         = UDim2.new(0, sc(68), 0.5, -sc(7)),
        BackgroundColor3 = T.Muted,
        BorderSizePixel  = 0,
        Parent           = footRow,
    })
    New("TextLabel", {
        Text             = footer,
        Font             = Enum.Font.Gotham,
        TextSize         = sc(9),
        TextColor3       = T.Muted,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Size             = UDim2.new(0.6, 0, 1, 0),
        Position         = UDim2.new(0, sc(76), 0, 0),
        BackgroundTransparency = 1,
        Parent           = footRow,
    })
    New("TextLabel", {
        Text             = "♛  Made for Players",
        Font             = Enum.Font.Gotham,
        TextSize         = sc(9),
        TextColor3       = T.Muted,
        TextXAlignment   = Enum.TextXAlignment.Right,
        Size             = UDim2.new(0, sc(140), 1, 0),
        Position         = UDim2.new(1, -sc(140), 0, 0),
        BackgroundTransparency = 1,
        Parent           = footRow,
    })

    -- ============================================================
    -- FLOATING TOGGLE BUTTON (drag + click to show/hide window)
    -- ============================================================
    local floatBtn = New("Frame", {
        Name             = "FloatToggle",
        Size             = UDim2.new(0, sc(44), 0, sc(44)),
        Position         = UDim2.new(1, -sc(58), 0.5, -sc(22)),
        BackgroundColor3 = T.AccentPurp,
        BorderSizePixel  = 0,
        ZIndex           = 20,
        Parent           = sg,
    })
    Crn(sc(22), floatBtn)
    Stk(Color3.fromRGB(160, 100, 255), 2, floatBtn)

    New("TextLabel", {
        Text             = "«»",
        Font             = Enum.Font.GothamBold,
        TextSize         = sc(14),
        TextColor3       = T.White,
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex           = 21,
        Parent           = floatBtn,
    })

    -- Drag float button
    Drag(floatBtn, floatBtn)

    -- Click to toggle window (if didn't drag)
    local fbDragDist = 0
    local fbDragStart = nil
    floatBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            fbDragStart = inp.Position
        end
    end)
    floatBtn.InputEnded:Connect(function(inp)
        if (inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch) and fbDragStart then
            local d = (inp.Position - fbDragStart).Magnitude
            if d < 6 then
                win.Visible = not win.Visible
                local arrow = floatBtn:FindFirstChildOfClass("TextLabel")
                if arrow then
                    arrow.Text = win.Visible and "«»" or "»«"
                end
            end
            fbDragStart = nil
        end
    end)

    -- Keyboard toggle
    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == toggleKey then
            win.Visible = not win.Visible
        end
    end)

    -- ============================================================
    -- WINDOW OBJECT
    -- ============================================================
    local Window = {
        _sg            = sg,
        _win           = win,
        _navList       = navList,
        _pageContainer = pageContainer,
        _activePage    = nil,
        _activeNav     = nil,
        _pages         = {},
    }

    -- ============================================================
    -- ADD TAB
    -- ============================================================
    function Window:AddTab(tabCfg)
        tabCfg = tabCfg or {}
        local tName = tabCfg.Name or "Tab"
        local tIcon = tabCfg.Icon or nil
        local tSub  = tabCfg.Sub  or nil

        -- Nav button
        local navBtn = New("TextButton", {
            Name                   = tName,
            Size                   = UDim2.new(1, 0, 0, sc(38)),
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Text                   = "",
            LayoutOrder            = #self._pages + 1,
            Parent                 = self._navList,
        })
        Crn(sc(6), navBtn)

        -- Active indicator
        local activeBar = New("Frame", {
            Size             = UDim2.new(0, 2, 0, sc(18)),
            Position         = UDim2.new(0, 0, 0.5, -sc(9)),
            BackgroundColor3 = T.White,
            BorderSizePixel  = 0,
            Visible          = false,
            Parent           = navBtn,
        })
        Crn(2, activeBar)

        -- Nav icon
        local navIcon = nil
        if tIcon then
            navIcon = Img(tIcon, T.Dim,
                UDim2.new(0, sc(18), 0, sc(18)),
                UDim2.new(0, sc(12), 0.5, -sc(9)),
                navBtn)
        end

        local iconOff = tIcon and sc(34) or sc(12)
        local navLabel = New("TextLabel", {
            Name             = "Label",
            Text             = tName,
            Font             = Enum.Font.GothamBold,
            TextSize         = sc(12),
            TextColor3       = T.Dim,
            TextXAlignment   = Enum.TextXAlignment.Left,
            Size             = UDim2.new(1, -iconOff - sc(8), 1, 0),
            Position         = UDim2.new(0, iconOff, 0, 0),
            BackgroundTransparency = 1,
            Parent           = navBtn,
        })

        -- Page
        local page = New("Frame", {
            Name                   = tName,
            Size                   = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible                = false,
            Parent                 = self._pageContainer,
        })

        -- Page header
        local hdr = New("Frame", {
            Size                   = UDim2.new(1, 0, 0, sc(62)),
            BackgroundTransparency = 1,
            Parent                 = page,
        })
        Pad(sc(16), 0, sc(18), sc(18), hdr)

        -- Header icon (large) — centered right
        if tIcon then
            local bigIcon = New("Frame", {
                Size             = UDim2.new(0, sc(52), 0, sc(52)),
                Position         = UDim2.new(1, -sc(60), 0.5, -sc(26)),
                BackgroundColor3 = Color3.fromRGB(22, 22, 22),
                BorderSizePixel  = 0,
                Parent           = hdr,
            })
            Crn(sc(12), bigIcon)
            Stk(T.AccentPurp, 2, bigIcon)
            Img(tIcon, T.White,
                UDim2.new(0, sc(32), 0, sc(32)),
                UDim2.new(0.5, -sc(16), 0.5, -sc(16)),
                bigIcon)
        end

        local hIconOff = sc(0)
        New("TextLabel", {
            Text             = tName,
            Font             = Enum.Font.GothamBold,
            TextSize         = sc(20),
            TextColor3       = T.Text,
            TextXAlignment   = Enum.TextXAlignment.Left,
            Size             = UDim2.new(0.7, 0, 0, sc(26)),
            Position         = UDim2.new(0, hIconOff, 0, sc(8)),
            BackgroundTransparency = 1,
            Parent           = hdr,
        })

        if tSub then
            New("TextLabel", {
                Text             = tSub,
                Font             = Enum.Font.Gotham,
                TextSize         = sc(8),
                TextColor3       = T.Muted,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Size             = UDim2.new(0.7, 0, 0, sc(12)),
                Position         = UDim2.new(0, hIconOff, 0, sc(36)),
                BackgroundTransparency = 1,
                Parent           = hdr,
            })
        end

        -- Divider
        New("Frame", {
            Size             = UDim2.new(1, -sc(16), 0, 1),
            Position         = UDim2.new(0, sc(8), 0, sc(60)),
            BackgroundColor3 = T.Border,
            BorderSizePixel  = 0,
            Parent           = page,
        })

        -- Scroll
        local scroll = New("ScrollingFrame", {
            Size                = UDim2.new(1, 0, 1, -sc(70)),
            Position            = UDim2.new(0, 0, 0, sc(70)),
            BackgroundTransparency = 1,
            BorderSizePixel     = 0,
            ScrollBarThickness  = 2,
            ScrollBarImageColor3= T.Muted,
            CanvasSize          = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent              = page,
        })
        Pad(sc(8), sc(12), sc(10), sc(10), scroll)

        -- Two-column container
        local cols = New("Frame", {
            Size              = UDim2.new(1, 0, 0, 0),
            AutomaticSize     = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent            = scroll,
        })

        local leftCol = New("Frame", {
            Name              = "Left",
            Size              = UDim2.new(0.5, -sc(5), 0, 0),
            Position          = UDim2.new(0, 0, 0, 0),
            AutomaticSize     = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent            = cols,
        })
        List(sc(8), Enum.FillDirection.Vertical, leftCol)

        local rightCol = New("Frame", {
            Name              = "Right",
            Size              = UDim2.new(0.5, -sc(5), 0, 0),
            Position          = UDim2.new(0.5, sc(5), 0, 0),
            AutomaticSize     = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent            = cols,
        })
        List(sc(8), Enum.FillDirection.Vertical, rightCol)

        -- Nav activation
        local function activate()
            if self._activePage then self._activePage.Visible = false end
            if self._activeNav then
                local on = self._activeNav
                Tw(on, { BackgroundTransparency = 1 }, 0.15)
                local l = on:FindFirstChild("Label")
                local i = on:FindFirstChildOfClass("ImageLabel")
                local b = on:FindFirstChild("ActiveBar")
                if l then Tw(l, { TextColor3 = T.Dim }, 0.15) end
                if i then Tw(i, { ImageColor3 = T.Dim }, 0.15) end
                if b then b.Visible = false end
            end
            self._activePage = page
            self._activeNav  = navBtn
            page.Visible = true
            navBtn.BackgroundColor3 = T.NavActive
            Tw(navBtn, { BackgroundTransparency = 0 }, 0.15)
            Tw(navLabel, { TextColor3 = T.Text }, 0.15)
            if navIcon then Tw(navIcon, { ImageColor3 = T.White }, 0.15) end
            activeBar.Visible = true
        end
        navBtn.MouseButton1Click:Connect(activate)
        navBtn.MouseEnter:Connect(function()
            if self._activeNav ~= navBtn then
                navBtn.BackgroundColor3 = T.PanelHover
                Tw(navBtn, { BackgroundTransparency = 0 }, 0.12)
            end
        end)
        navBtn.MouseLeave:Connect(function()
            if self._activeNav ~= navBtn then
                Tw(navBtn, { BackgroundTransparency = 1 }, 0.12)
            end
        end)

        if #self._pages == 0 then activate() end
        table.insert(self._pages, page)

        -- ============================================================
        -- TAB OBJECT
        -- ============================================================
        local Tab = { _left = leftCol, _right = rightCol }

        local function autoCol()
            local lc = #leftCol:GetChildren()  - 1
            local rc = #rightCol:GetChildren() - 1
            return lc <= rc and leftCol or rightCol
        end

        -- --------------------------------------------------------
        -- CARD BUILDER
        -- --------------------------------------------------------
        local function makeCard(cfg2)
            local col = cfg2 and cfg2.Column == "right" and rightCol
                      or cfg2 and cfg2.Column == "left"  and leftCol
                      or autoCol()
            local card = New("Frame", {
                Size              = UDim2.new(1, 0, 0, 0),
                AutomaticSize     = Enum.AutomaticSize.Y,
                BackgroundColor3  = T.Panel,
                BorderSizePixel   = 0,
                Parent            = col,
            })
            Crn(sc(8), card)
            Stk(T.Border, 1, card)

            local inner = New("Frame", {
                Size              = UDim2.new(1, -sc(24), 0, 0),
                Position          = UDim2.new(0, sc(12), 0, sc(12)),
                AutomaticSize     = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent            = card,
            })
            List(sc(8), Enum.FillDirection.Vertical, inner)

            -- bottom spacer
            New("Frame", {
                Size                   = UDim2.new(1, 0, 0, sc(12)),
                BackgroundTransparency = 1,
                LayoutOrder            = 9999,
                Parent                 = inner,
            })
            return card, inner
        end

        -- --------------------------------------------------------
        -- ADD TOGGLE
        -- --------------------------------------------------------
        function Tab:AddToggle(cfg2)
            cfg2 = cfg2 or {}
            local card, inner = makeCard(cfg2)

            -- Row: [icon] [title + desc]  ... [toggle]
            local topRow = New("Frame", {
                Size                   = UDim2.new(1, 0, 0, sc(36)),
                BackgroundTransparency = 1,
                LayoutOrder            = 1,
                Parent                 = inner,
            })

            local xOff = 0
            if cfg2.Icon then
                Img(cfg2.Icon, T.Dim,
                    UDim2.new(0, sc(18), 0, sc(18)),
                    UDim2.new(0, 0, 0.5, -sc(9)),
                    topRow)
                xOff = sc(26)
            end

            -- title
            New("TextLabel", {
                Text             = cfg2.Name or "Toggle",
                Font             = Enum.Font.GothamBold,
                TextSize         = sc(12),
                TextColor3       = T.Text,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Size             = UDim2.new(1, -xOff - sc(50), 0, sc(17)),
                Position         = UDim2.new(0, xOff, 0, 0),
                BackgroundTransparency = 1,
                Parent           = topRow,
            })

            -- description under title
            if cfg2.Description then
                New("TextLabel", {
                    Text             = cfg2.Description,
                    Font             = Enum.Font.Gotham,
                    TextSize         = sc(9),
                    TextColor3       = T.Dim,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Size             = UDim2.new(1, -xOff - sc(50), 0, sc(13)),
                    Position         = UDim2.new(0, xOff, 0, sc(18)),
                    BackgroundTransparency = 1,
                    Parent           = topRow,
                })
            end

            -- Toggle (right-aligned, vertically centered)
            local tog = MakeToggle(topRow, cfg2.Default, cfg2.Callback)
            tog.Frame.Position = UDim2.new(1, -sc(40), 0.5, -sc(11))

            -- Keybind sub-row
            if cfg2.SubLabel then
                local subRow = New("Frame", {
                    Size                   = UDim2.new(1, 0, 0, sc(28)),
                    BackgroundTransparency = 1,
                    LayoutOrder            = 2,
                    Parent                 = inner,
                })
                New("TextLabel", {
                    Text             = cfg2.SubLabel,
                    Font             = Enum.Font.Gotham,
                    TextSize         = sc(10),
                    TextColor3       = T.Dim,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Size             = UDim2.new(0.45, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Parent           = subRow,
                })

                local keyBox = New("TextButton", {
                    Text             = cfg2.Key or "F",
                    Font             = Enum.Font.GothamBold,
                    TextSize         = sc(11),
                    TextColor3       = T.Text,
                    Size             = UDim2.new(0.55, 0, 1, -sc(4)),
                    Position         = UDim2.new(0.45, 0, 0, sc(2)),
                    BackgroundColor3 = T.InputBG,
                    BorderSizePixel  = 0,
                    AutoButtonColor  = false,
                    Parent           = subRow,
                })
                Crn(sc(6), keyBox)
                Stk(T.InputBdr, 1, keyBox)

                local listening = false
                keyBox.MouseButton1Click:Connect(function()
                    listening = true
                    keyBox.Text = "..."
                    keyBox.TextColor3 = T.Dim
                end)
                UserInputService.InputBegan:Connect(function(inp, gp)
                    if not listening then return end
                    if inp.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        keyBox.Text = inp.KeyCode.Name
                        keyBox.TextColor3 = T.Text
                        if cfg2.KeyCallback then cfg2.KeyCallback(inp.KeyCode) end
                    end
                end)
            end

            return tog
        end

        -- --------------------------------------------------------
        -- ADD SLIDER
        -- --------------------------------------------------------
        function Tab:AddSlider(cfg2)
            cfg2 = cfg2 or {}
            local minV  = cfg2.Min     or 0
            local maxV  = cfg2.Max     or 100
            local defV  = cfg2.Default or 50
            local sfx   = cfg2.Suffix  or "%"

            local card, inner = makeCard(cfg2)

            -- ── TOP ROW: icon | title + desc | [toggle] ──────────────
            local topRow = New("Frame", {
                Size                   = UDim2.new(1, 0, 0, sc(36)),
                BackgroundTransparency = 1,
                LayoutOrder            = 1,
                Parent                 = inner,
            })

            local xOff = 0
            if cfg2.Icon then
                Img(cfg2.Icon, T.Dim,
                    UDim2.new(0, sc(18), 0, sc(18)),
                    UDim2.new(0, 0, 0.5, -sc(9)),
                    topRow)
                xOff = sc(26)
            end

            -- How much space the toggle takes on the right
            local togW = cfg2.HasToggle and sc(50) or 0

            New("TextLabel", {
                Text             = cfg2.Name or "Slider",
                Font             = Enum.Font.GothamBold,
                TextSize         = sc(12),
                TextColor3       = T.Text,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Size             = UDim2.new(1, -xOff - togW, 0, sc(17)),
                Position         = UDim2.new(0, xOff, 0, 0),
                BackgroundTransparency = 1,
                Parent           = topRow,
            })
            if cfg2.Description then
                New("TextLabel", {
                    Text             = cfg2.Description,
                    Font             = Enum.Font.Gotham,
                    TextSize         = sc(9),
                    TextColor3       = T.Dim,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Size             = UDim2.new(1, -xOff - togW, 0, sc(13)),
                    Position         = UDim2.new(0, xOff, 0, sc(18)),
                    BackgroundTransparency = 1,
                    Parent           = topRow,
                })
            end

            -- Optional toggle (right side of top row)
            local togObj = nil
            if cfg2.HasToggle then
                togObj = MakeToggle(topRow, cfg2.ToggleDefault, cfg2.ToggleCallback)
                togObj.Frame.Position = UDim2.new(1, -sc(40), 0.5, -sc(11))
            end

            -- ── VALUE ROW: SubLabel left, value right ─────────────────
            -- Placed BELOW the top row as a separate row
            local valRow = New("Frame", {
                Size                   = UDim2.new(1, 0, 0, sc(18)),
                BackgroundTransparency = 1,
                LayoutOrder            = 2,
                Parent                 = inner,
            })

            if cfg2.SubLabel then
                New("TextLabel", {
                    Text             = cfg2.SubLabel,
                    Font             = Enum.Font.Gotham,
                    TextSize         = sc(10),
                    TextColor3       = T.Dim,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Size             = UDim2.new(0.7, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Parent           = valRow,
                })
            end

            local valLabel = New("TextLabel", {
                Text             = tostring(defV) .. sfx,
                Font             = Enum.Font.GothamBold,
                TextSize         = sc(12),
                TextColor3       = T.Text,
                TextXAlignment   = Enum.TextXAlignment.Right,
                Size             = UDim2.new(0.3, 0, 1, 0),
                Position         = UDim2.new(0.7, 0, 0, 0),
                BackgroundTransparency = 1,
                Parent           = valRow,
            })

            -- ── SLIDER TRACK ──────────────────────────────────────────
            local sliderHolder = New("Frame", {
                Size                   = UDim2.new(1, 0, 0, sc(18)),
                BackgroundTransparency = 1,
                LayoutOrder            = 3,
                Parent                 = inner,
            })

            local track = New("Frame", {
                Size             = UDim2.new(1, 0, 0, sc(5)),
                Position         = UDim2.new(0, 0, 0.5, -sc(2)),
                BackgroundColor3 = T.SliderBG,
                BorderSizePixel  = 0,
                Parent           = sliderHolder,
            })
            Crn(sc(3), track)

            local pct  = (defV - minV) / (maxV - minV)
            local fill = New("Frame", {
                Size             = UDim2.new(pct, 0, 1, 0),
                BackgroundColor3 = T.SliderFill,
                BorderSizePixel  = 0,
                Parent           = track,
            })
            Crn(sc(3), fill)

            local thumb = New("Frame", {
                Size             = UDim2.new(0, sc(14), 0, sc(14)),
                Position         = UDim2.new(pct, -sc(7), 0.5, -sc(7)),
                BackgroundColor3 = T.White,
                BorderSizePixel  = 0,
                Parent           = track,
            })
            Crn(sc(7), thumb)

            local sliderBtn = New("TextButton", {
                Size = UDim2.new(1, 0, 0, sc(22)),
                Position = UDim2.new(0, 0, 0.5, -sc(11)),
                Text = "",
                BackgroundTransparency = 1,
                Parent = track,
            })

            local currentVal = defV
            local draggingS  = false

            sliderBtn.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    draggingS = true
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    draggingS = false
                end
            end)

            local function updateSlider(inputPos)
                local abs  = track.AbsolutePosition.X
                local absW = track.AbsoluteSize.X
                local p    = math.clamp((inputPos - abs) / absW, 0, 1)
                local v    = math.floor(minV + (maxV - minV) * p + 0.5)
                currentVal = v
                Tw(fill,  { Size     = UDim2.new(p, 0, 1, 0) },            0.05)
                Tw(thumb, { Position = UDim2.new(p, -sc(7), 0.5, -sc(7)) },0.05)
                valLabel.Text = tostring(v) .. sfx
                if cfg2.Callback then cfg2.Callback(v) end
            end

            RunService.RenderStepped:Connect(function()
                if not draggingS then return end
                local pos = IsMobile
                    and UserInputService:GetTouchState()[1] and UserInputService:GetTouchState()[1].Position.X
                    or Mouse.X
                if pos then updateSlider(pos) end
            end)

            -- Mobile touch move
            sliderBtn.TouchMoved:Connect(function(touch)
                if draggingS then updateSlider(touch.Position.X) end
            end)

            -- ── INFO BOX ─────────────────────────────────────────────
            if cfg2.Info then
                local infoBox = New("Frame", {
                    Size             = UDim2.new(1, 0, 0, sc(40)),
                    BackgroundColor3 = T.InfoBG,
                    BorderSizePixel  = 0,
                    LayoutOrder      = 4,
                    Parent           = inner,
                })
                Crn(sc(6), infoBox)
                Stk(T.Border, 1, infoBox)
                Pad(sc(7), sc(7), sc(10), sc(10), infoBox)

                if cfg2.InfoIcon then
                    Img(cfg2.InfoIcon, T.Muted,
                        UDim2.new(0, sc(14), 0, sc(14)),
                        UDim2.new(0, 0, 0.5, -sc(7)),
                        infoBox)
                end
                New("TextLabel", {
                    Text             = cfg2.Info,
                    Font             = Enum.Font.Gotham,
                    TextSize         = sc(9),
                    TextColor3       = T.Dim,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    TextWrapped      = true,
                    Size             = UDim2.new(1, cfg2.InfoIcon and -sc(20) or 0, 1, 0),
                    Position         = UDim2.new(0, cfg2.InfoIcon and sc(20) or 0, 0, 0),
                    BackgroundTransparency = 1,
                    Parent           = infoBox,
                })
            end

            return {
                SetValue = function(v)
                    currentVal = v
                    local p = math.clamp((v - minV) / (maxV - minV), 0, 1)
                    Tw(fill,  { Size     = UDim2.new(p, 0, 1, 0) }, 0.1)
                    Tw(thumb, { Position = UDim2.new(p, -sc(7), 0.5, -sc(7)) }, 0.1)
                    valLabel.Text = tostring(v) .. sfx
                end,
                GetValue = function() return currentVal end,
                Toggle   = togObj,
            }
        end

        -- --------------------------------------------------------
        -- ADD LABEL
        -- --------------------------------------------------------
        function Tab:AddLabel(text, col)
            local parent = col == "right" and rightCol or col == "left" and leftCol or autoCol()
            New("TextLabel", {
                Text             = text or "",
                Font             = Enum.Font.GothamBold,
                TextSize         = sc(9),
                TextColor3       = T.Muted,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Size             = UDim2.new(1, 0, 0, sc(18)),
                BackgroundTransparency = 1,
                Parent           = parent,
            })
        end

        -- --------------------------------------------------------
        -- ADD SEPARATOR
        -- --------------------------------------------------------
        function Tab:AddSeparator(col)
            local parent = col == "right" and rightCol or col == "left" and leftCol or autoCol()
            New("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = T.Border,
                BorderSizePixel  = 0,
                Parent           = parent,
            })
        end

        return Tab
    end

    return Window
end

-- ================================================================
-- NOTIFY
-- ================================================================
function XitttpLib:Notify(cfg)
    cfg = cfg or {}
    local sg = LocalPlayer.PlayerGui:FindFirstChild("XitttpGui")
        or LocalPlayer.PlayerGui

    local toast = New("Frame", {
        Size             = UDim2.new(0, sc(250), 0, sc(58)),
        Position         = UDim2.new(1, -sc(264), 1, -sc(74)),
        BackgroundColor3 = T.Panel,
        BackgroundTransparency = 1,
        ZIndex           = 100,
        BorderSizePixel  = 0,
        Parent           = sg,
    })
    Crn(sc(8), toast)
    Stk(T.Border, 1, toast)

    New("TextLabel", {
        Text             = cfg.Title or "Notification",
        Font             = Enum.Font.GothamBold,
        TextSize         = sc(11),
        TextColor3       = T.Text,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Size             = UDim2.new(1, -sc(14), 0, sc(18)),
        Position         = UDim2.new(0, sc(10), 0, sc(9)),
        BackgroundTransparency = 1,
        ZIndex           = 101,
        Parent           = toast,
    })
    New("TextLabel", {
        Text             = cfg.Message or "",
        Font             = Enum.Font.Gotham,
        TextSize         = sc(9),
        TextColor3       = T.Dim,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        Size             = UDim2.new(1, -sc(14), 0, sc(18)),
        Position         = UDim2.new(0, sc(10), 0, sc(29)),
        BackgroundTransparency = 1,
        ZIndex           = 101,
        Parent           = toast,
    })

    local prog = New("Frame", {
        Size             = UDim2.new(1, -sc(2), 0, 2),
        Position         = UDim2.new(0, sc(1), 1, -sc(3)),
        BackgroundColor3 = T.SliderFill,
        BorderSizePixel  = 0,
        ZIndex           = 102,
        Parent           = toast,
    })
    Crn(1, prog)

    local dur = cfg.Duration or 3
    Tw(toast, { BackgroundTransparency = 0 }, 0.2)
    Tw(prog,  { Size = UDim2.new(0, 0, 0, 2) }, dur, Enum.EasingStyle.Linear)
    task.delay(dur, function()
        Tw(toast, { BackgroundTransparency = 1,
            Position = UDim2.new(1, -sc(264), 1, -sc(60)) }, 0.2)
        task.delay(0.25, function() toast:Destroy() end)
    end)
end

return XitttpLib
