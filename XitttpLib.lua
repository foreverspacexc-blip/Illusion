-- ================================================================
--  XitttpLib — GUI Library
--  ยังไม่มีระบบ combat/parry ใดๆ เป็นแค่ library shell
-- ================================================================

local XitttpLib = {}

-- ================================================================
-- SERVICES
-- ================================================================
local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService    = game:GetService("RunService")
local LocalPlayer   = Players.LocalPlayer
local Mouse         = LocalPlayer:GetMouse()

-- ================================================================
-- ASSETS (rbxassetid)
-- ================================================================
local Icons = {
    Home      = "rbxassetid://170940874",
    Combat    = "rbxassetid://17414627577",
    Player    = "rbxassetid://124871982298256",
    Misc      = "rbxassetid://3057073095",
    UISettings= "rbxassetid://139013812244063",
    Shield    = "rbxassetid://7241575981",
    Aim       = "rbxassetid://11717619752",
    Flash     = "rbxassetid://13160015076",
}
XitttpLib.Icons = Icons

-- ================================================================
-- THEME
-- ================================================================
local Theme = {
    BG          = Color3.fromRGB(18,  18,  18),   -- window bg
    Sidebar     = Color3.fromRGB(12,  12,  12),   -- left nav
    Panel       = Color3.fromRGB(26,  26,  26),   -- card bg
    PanelHover  = Color3.fromRGB(32,  32,  32),
    Border      = Color3.fromRGB(42,  42,  42),
    Text        = Color3.fromRGB(240, 240, 240),
    TextDim     = Color3.fromRGB(130, 130, 130),
    TextMuted   = Color3.fromRGB(80,  80,  80),
    Accent      = Color3.fromRGB(255, 255, 255),
    ActiveNav   = Color3.fromRGB(30,  30,  30),
    ToggleOn    = Color3.fromRGB(220, 220, 220),
    ToggleOff   = Color3.fromRGB(55,  55,  55),
    ToggleKnob  = Color3.fromRGB(255, 255, 255),
    SliderFill  = Color3.fromRGB(210, 210, 210),
    SliderTrack = Color3.fromRGB(48,  48,  48),
    InputBG     = Color3.fromRGB(22,  22,  22),
    InputBorder = Color3.fromRGB(55,  55,  55),
}
XitttpLib.Theme = Theme

-- ================================================================
-- UTIL
-- ================================================================
local function Tween(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function Make(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then obj[k] = v end
    end
    for _, child in pairs(children or {}) do
        child.Parent = obj
    end
    if props and props.Parent then obj.Parent = props.Parent end
    return obj
end

local function Corner(radius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

local function Stroke(color, thickness, parent)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function Padding(t, b, l, r, parent)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.Parent = parent
    return p
end

local function ListLayout(spacing, fillDir, parent)
    local l = Instance.new("UIListLayout")
    l.Padding           = UDim.new(0, spacing or 0)
    l.FillDirection     = fillDir or Enum.FillDirection.Vertical
    l.SortOrder         = Enum.SortOrder.LayoutOrder
    l.HorizontalAlignment = Enum.HorizontalAlignment.Left
    l.Parent = parent
    return l
end

-- ================================================================
-- DRAGGING
-- ================================================================
local function MakeDraggable(handle, frame)
    local dragging, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ================================================================
-- WINDOW
-- ================================================================
function XitttpLib:CreateWindow(config)
    config = config or {}
    local title    = config.Title    or "Xittp"
    local subtitle = config.Subtitle or "Better Gameplay\nBigger Results"
    local footer   = config.Footer   or "Play Smart · Stay Ahead"
    local size     = config.Size     or UDim2.new(0, 760, 0, 510)
    local logo     = config.Logo     or nil  -- optional rbxassetid

    -- ScreenGui
    local sg = Make("ScreenGui", {
        Name             = "XitttpGui",
        ResetOnSpawn     = false,
        ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset   = true,
        Parent           = LocalPlayer.PlayerGui,
    })

    -- Root window frame
    local win = Make("Frame", {
        Name             = "Window",
        Size             = size,
        Position         = UDim2.new(0.5, -380, 0.5, -255),
        BackgroundColor3 = Theme.BG,
        BorderSizePixel  = 0,
        Parent           = sg,
    })
    Corner(10, win)
    Stroke(Theme.Border, 1, win)
    Make("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 28)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 14, 14)),
        }),
        Rotation = 135,
        Parent = win,
    })

    -- Drop shadow illusion
    Make("Frame", {
        Name             = "Shadow",
        Size             = UDim2.new(1, 20, 1, 20),
        Position         = UDim2.new(0, -10, 0, 8),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.65,
        ZIndex           = 0,
        BorderSizePixel  = 0,
        Parent           = win,
    })
    Corner(14, win:FindFirstChild("Shadow"))

    -- ============================================================
    -- SIDEBAR
    -- ============================================================
    local sidebar = Make("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, 185, 1, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = win,
    })
    Corner(10, sidebar)
    -- right-side square corners
    Make("Frame", {
        Size             = UDim2.new(0, 10, 1, 0),
        Position         = UDim2.new(1, -10, 0, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel  = 0,
        Parent           = sidebar,
    })

    -- Logo area
    local logoArea = Make("Frame", {
        Name             = "LogoArea",
        Size             = UDim2.new(1, 0, 0, 90),
        BackgroundTransparency = 1,
        Parent           = sidebar,
    })
    Padding(18, 0, 18, 12, logoArea)

    -- Logo icon + text row
    local logoRow = Make("Frame", {
        Size             = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent           = logoArea,
    })
    if logo then
        Make("ImageLabel", {
            Size             = UDim2.new(0, 32, 0, 32),
            Position         = UDim2.new(0, 0, 0.5, -16),
            Image            = logo,
            BackgroundTransparency = 1,
            Parent           = logoRow,
        })
    end

    -- Crown decoration (SVG-style via Frame)
    local crownDecor = Make("ImageLabel", {
        Size             = UDim2.new(0, 18, 0, 18),
        Position         = UDim2.new(0, 0, 0, -6),
        Image            = "rbxassetid://7072706620", -- crown icon
        ImageColor3      = Color3.fromRGB(220, 220, 220),
        BackgroundTransparency = 1,
        Parent           = logoRow,
    })

    Make("TextLabel", {
        Text             = title,
        Font             = Enum.Font.GothamBold,
        TextSize         = 22,
        TextColor3       = Theme.Text,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Size             = UDim2.new(1, 0, 1, 0),
        Position         = UDim2.new(0, logo and 38 or 22, 0, 0),
        BackgroundTransparency = 1,
        Parent           = logoRow,
    })

    Make("TextLabel", {
        Text             = subtitle,
        Font             = Enum.Font.Gotham,
        TextSize         = 10,
        TextColor3       = Theme.TextDim,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Size             = UDim2.new(1, 0, 0, 28),
        Position         = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent           = logoArea,
    })

    -- Divider under logo
    Make("Frame", {
        Size             = UDim2.new(1, -24, 0, 1),
        Position         = UDim2.new(0, 12, 0, 88),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel  = 0,
        Parent           = sidebar,
    })

    -- Nav list
    local navList = Make("Frame", {
        Name             = "NavList",
        Size             = UDim2.new(1, 0, 1, -130),
        Position         = UDim2.new(0, 0, 0, 98),
        BackgroundTransparency = 1,
        Parent           = sidebar,
    })
    Padding(6, 6, 10, 10, navList)
    ListLayout(4, Enum.FillDirection.Vertical, navList)

    -- Bottom watermark in sidebar
    local sideBottom = Make("TextLabel", {
        Text             = "♛",
        Font             = Enum.Font.GothamBold,
        TextSize         = 28,
        TextColor3       = Color3.fromRGB(40, 40, 40),
        TextXAlignment   = Enum.TextXAlignment.Center,
        Size             = UDim2.new(1, 0, 0, 40),
        Position         = UDim2.new(0, 0, 1, -48),
        BackgroundTransparency = 1,
        Parent           = sidebar,
    })

    -- ============================================================
    -- CONTENT AREA
    -- ============================================================
    local contentWrap = Make("Frame", {
        Name             = "ContentWrap",
        Size             = UDim2.new(1, -185, 1, -44),
        Position         = UDim2.new(0, 185, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent           = win,
    })

    -- Page container (pages go here)
    local pageContainer = Make("Frame", {
        Name             = "Pages",
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent           = contentWrap,
    })

    -- ============================================================
    -- TITLEBAR (top-right: minimize + close)
    -- ============================================================
    local titleBar = Make("Frame", {
        Name             = "TitleBar",
        Size             = UDim2.new(1, -185, 0, 36),
        Position         = UDim2.new(0, 185, 0, 0),
        BackgroundTransparency = 1,
        ZIndex           = 10,
        Parent           = win,
    })
    MakeDraggable(titleBar, win)

    -- Close button
    local closeBtn = Make("TextButton", {
        Text             = "×",
        Font             = Enum.Font.GothamBold,
        TextSize         = 16,
        TextColor3       = Theme.TextDim,
        Size             = UDim2.new(0, 28, 0, 28),
        Position         = UDim2.new(1, -36, 0.5, -14),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 11,
        Parent           = titleBar,
    })
    closeBtn.MouseButton1Click:Connect(function()
        Tween(win, { Size = UDim2.new(0, 0, 0, 0) }, 0.22)
        task.delay(0.25, function() sg:Destroy() end)
    end)
    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, { TextColor3 = Color3.fromRGB(255, 80, 80) }, 0.1)
    end)
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, { TextColor3 = Theme.TextDim }, 0.1)
    end)

    -- Minimize
    local minBtn = Make("TextButton", {
        Text             = "−",
        Font             = Enum.Font.GothamBold,
        TextSize         = 16,
        TextColor3       = Theme.TextDim,
        Size             = UDim2.new(0, 28, 0, 28),
        Position         = UDim2.new(1, -68, 0.5, -14),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 11,
        Parent           = titleBar,
    })
    local minimized = false
    local fullSize  = size
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(win, { Size = UDim2.new(0, 185, 0, 510) }, 0.22)
            contentWrap.Visible  = false
            titleBar.Visible     = false
        else
            Tween(win, { Size = fullSize }, 0.22)
            contentWrap.Visible  = true
            titleBar.Visible     = true
        end
    end)
    minBtn.MouseEnter:Connect(function()
        Tween(minBtn, { TextColor3 = Theme.Text }, 0.1)
    end)
    minBtn.MouseLeave:Connect(function()
        Tween(minBtn, { TextColor3 = Theme.TextDim }, 0.1)
    end)

    -- Sidebar also draggable
    MakeDraggable(logoArea, win)

    -- ============================================================
    -- FOOTER
    -- ============================================================
    local footerBar = Make("Frame", {
        Name             = "Footer",
        Size             = UDim2.new(1, -185, 0, 36),
        Position         = UDim2.new(0, 185, 1, -36),
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = win,
    })
    Make("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel  = 0,
        Parent           = footerBar,
    })

    -- Footer left
    Make("TextLabel", {
        Text             = title,
        Font             = Enum.Font.GothamBold,
        TextSize         = 11,
        TextColor3       = Color3.fromRGB(90, 90, 90),
        TextXAlignment   = Enum.TextXAlignment.Left,
        Size             = UDim2.new(0, 80, 1, 0),
        Position         = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Parent           = footerBar,
    })
    Make("Frame", {
        Size             = UDim2.new(0, 1, 0, 16),
        Position         = UDim2.new(0, 96, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        BorderSizePixel  = 0,
        Parent           = footerBar,
    })
    Make("TextLabel", {
        Text             = footer,
        Font             = Enum.Font.Gotham,
        TextSize         = 10,
        TextColor3       = Color3.fromRGB(70, 70, 70),
        TextXAlignment   = Enum.TextXAlignment.Left,
        Size             = UDim2.new(0, 220, 1, 0),
        Position         = UDim2.new(0, 106, 0, 0),
        BackgroundTransparency = 1,
        Parent           = footerBar,
    })

    -- Footer right "Made for Players"
    Make("TextLabel", {
        Text             = "♛  Made for Players",
        Font             = Enum.Font.Gotham,
        TextSize         = 10,
        TextColor3       = Color3.fromRGB(70, 70, 70),
        TextXAlignment   = Enum.TextXAlignment.Right,
        Size             = UDim2.new(0, 160, 1, 0),
        Position         = UDim2.new(1, -170, 0, 0),
        BackgroundTransparency = 1,
        Parent           = footerBar,
    })

    -- ============================================================
    -- WINDOW OBJECT
    -- ============================================================
    local Window = {
        _sg            = sg,
        _win           = win,
        _sidebar       = sidebar,
        _navList       = navList,
        _pageContainer = pageContainer,
        _activePage    = nil,
        _activeNav     = nil,
        _pages         = {},
    }

    -- ============================================================
    -- ADD TAB
    -- ============================================================
    function Window:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name  or "Tab"
        local tabIcon = tabConfig.Icon  or nil  -- rbxassetid string
        local tabSub  = tabConfig.Sub   or nil  -- subtitle under name (e.g. "PARRY · AUTO SPAM · ACCURACY")

        -- Nav button
        local navBtn = Make("TextButton", {
            Name             = tabName,
            Size             = UDim2.new(1, 0, 0, 38),
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            Text             = "",
            LayoutOrder      = #self._pages + 1,
            Parent           = self._navList,
        })
        Corner(6, navBtn)

        -- Active indicator bar (left edge)
        local activeBar = Make("Frame", {
            Name             = "ActiveBar",
            Size             = UDim2.new(0, 2, 0, 18),
            Position         = UDim2.new(0, 0, 0.5, -9),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel  = 0,
            Visible          = false,
            Parent           = navBtn,
        })
        Corner(2, activeBar)

        -- Icon
        if tabIcon then
            Make("ImageLabel", {
                Image            = tabIcon,
                ImageColor3      = Theme.TextDim,
                Size             = UDim2.new(0, 18, 0, 18),
                Position         = UDim2.new(0, 12, 0.5, -9),
                BackgroundTransparency = 1,
                Parent           = navBtn,
            })
        end

        local iconOffset = tabIcon and 36 or 12
        Make("TextLabel", {
            Text             = tabName,
            Font             = Enum.Font.GothamBold,
            TextSize         = 13,
            TextColor3       = Theme.TextDim,
            TextXAlignment   = Enum.TextXAlignment.Left,
            Size             = UDim2.new(1, -iconOffset - 8, 1, 0),
            Position         = UDim2.new(0, iconOffset, 0, 0),
            BackgroundTransparency = 1,
            Name             = "Label",
            Parent           = navBtn,
        })

        -- Page frame
        local page = Make("Frame", {
            Name             = tabName,
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible          = false,
            Parent           = self._pageContainer,
        })

        -- Page header
        local pageHeader = Make("Frame", {
            Name             = "Header",
            Size             = UDim2.new(1, 0, 0, 64),
            BackgroundTransparency = 1,
            Parent           = page,
        })
        Padding(18, 0, 20, 20, pageHeader)

        -- Header icon
        if tabIcon then
            Make("ImageLabel", {
                Image            = tabIcon,
                ImageColor3      = Theme.Text,
                ImageTransparency = 0.1,
                Size             = UDim2.new(0, 26, 0, 26),
                Position         = UDim2.new(0, 0, 0, 14),
                BackgroundTransparency = 1,
                Parent           = pageHeader,
            })
        end

        local hIconOff = tabIcon and 36 or 0
        Make("TextLabel", {
            Text             = tabName,
            Font             = Enum.Font.GothamBold,
            TextSize         = 22,
            TextColor3       = Theme.Text,
            TextXAlignment   = Enum.TextXAlignment.Left,
            Size             = UDim2.new(1, -hIconOff, 0, 28),
            Position         = UDim2.new(0, hIconOff, 0, 10),
            BackgroundTransparency = 1,
            Parent           = pageHeader,
        })

        if tabSub then
            Make("TextLabel", {
                Text             = tabSub,
                Font             = Enum.Font.Gotham,
                TextSize         = 9,
                TextColor3       = Theme.TextMuted,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Size             = UDim2.new(1, -hIconOff, 0, 14),
                Position         = UDim2.new(0, hIconOff, 0, 38),
                BackgroundTransparency = 1,
                Parent           = pageHeader,
            })
        end

        -- Divider
        Make("Frame", {
            Size             = UDim2.new(1, -20, 0, 1),
            Position         = UDim2.new(0, 10, 0, 62),
            BackgroundColor3 = Theme.Border,
            BorderSizePixel  = 0,
            Parent           = page,
        })

        -- Scrolling content
        local scroll = Make("ScrollingFrame", {
            Name             = "Scroll",
            Size             = UDim2.new(1, 0, 1, -72),
            Position         = UDim2.new(0, 0, 0, 72),
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60),
            CanvasSize       = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent           = page,
        })
        Padding(8, 12, 12, 12, scroll)

        -- Two-column layout inside scroll
        local cols = Make("Frame", {
            Size             = UDim2.new(1, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent           = scroll,
        })

        local leftCol = Make("Frame", {
            Name             = "Left",
            Size             = UDim2.new(0.5, -6, 0, 0),
            Position         = UDim2.new(0, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent           = cols,
        })
        ListLayout(8, Enum.FillDirection.Vertical, leftCol)

        local rightCol = Make("Frame", {
            Name             = "Right",
            Size             = UDim2.new(0.5, -6, 0, 0),
            Position         = UDim2.new(0.5, 6, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent           = cols,
        })
        ListLayout(8, Enum.FillDirection.Vertical, rightCol)

        -- Nav click → show page
        local function activate()
            -- deactivate old
            if self._activePage then
                self._activePage.Visible = false
            end
            if self._activeNav then
                local oldLabel = self._activeNav:FindFirstChild("Label")
                local oldIcon  = self._activeNav:FindFirstChildOfClass("ImageLabel")
                local oldBar   = self._activeNav:FindFirstChild("ActiveBar")
                self._activeNav.BackgroundTransparency = 1
                if oldLabel then Tween(oldLabel, { TextColor3 = Theme.TextDim }, 0.15) end
                if oldIcon  then Tween(oldIcon,  { ImageColor3 = Theme.TextDim }, 0.15) end
                if oldBar   then oldBar.Visible = false end
            end
            -- activate new
            self._activePage = page
            self._activeNav  = navBtn
            page.Visible = true
            Tween(navBtn, { BackgroundTransparency = 0 }, 0.15)
            navBtn.BackgroundColor3 = Theme.ActiveNav
            local lbl = navBtn:FindFirstChild("Label")
            local ico = navBtn:FindFirstChildOfClass("ImageLabel")
            if lbl then Tween(lbl, { TextColor3 = Theme.Text }, 0.15) end
            if ico then Tween(ico, { ImageColor3 = Theme.Accent }, 0.15) end
            activeBar.Visible = true
        end
        navBtn.MouseButton1Click:Connect(activate)
        navBtn.MouseEnter:Connect(function()
            if self._activeNav ~= navBtn then
                Tween(navBtn, { BackgroundTransparency = 0.8 }, 0.1)
                navBtn.BackgroundColor3 = Theme.PanelHover
            end
        end)
        navBtn.MouseLeave:Connect(function()
            if self._activeNav ~= navBtn then
                Tween(navBtn, { BackgroundTransparency = 1 }, 0.1)
            end
        end)

        -- auto-activate first tab
        if #self._pages == 0 then
            activate()
        end

        table.insert(self._pages, page)

        -- ============================================================
        -- TAB OBJECT
        -- ============================================================
        local Tab = { _leftCol = leftCol, _rightCol = rightCol }

        -- helper: which column next element goes to
        local function nextCol()
            local lCount = #leftCol:GetChildren() - 1  -- minus UIListLayout
            local rCount = #rightCol:GetChildren() - 1
            return lCount <= rCount and leftCol or rightCol
        end

        -- --------------------------------------------------------
        -- CARD
        -- --------------------------------------------------------
        local function makeCard(col, cardConfig)
            cardConfig = cardConfig or {}
            local col = cardConfig.Column == "right" and rightCol
                     or cardConfig.Column == "left"  and leftCol
                     or nextCol()

            local card = Make("Frame", {
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.Panel,
                BorderSizePixel  = 0,
                Parent           = col,
            })
            Corner(8, card)
            Stroke(Theme.Border, 1, card)
            Padding(12, 12, 14, 14, card)

            local cardList = Make("Frame", {
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent           = card,
            })
            ListLayout(10, Enum.FillDirection.Vertical, cardList)

            return card, cardList
        end

        -- --------------------------------------------------------
        -- TOGGLE
        -- --------------------------------------------------------
        function Tab:AddToggle(cfg)
            cfg = cfg or {}
            local card, cardList = makeCard(nil, cfg)

            -- Top row: icon + title + toggle
            local topRow = Make("Frame", {
                Size             = UDim2.new(1, 0, 0, 34),
                BackgroundTransparency = 1,
                Parent           = cardList,
            })

            -- Icon shield/aim/flash
            if cfg.Icon then
                Make("ImageLabel", {
                    Image            = cfg.Icon,
                    ImageColor3      = Theme.TextDim,
                    Size             = UDim2.new(0, 20, 0, 20),
                    Position         = UDim2.new(0, 0, 0.5, -10),
                    BackgroundTransparency = 1,
                    Parent           = topRow,
                })
            end

            local iconOff = cfg.Icon and 28 or 0

            local titleLbl = Make("TextLabel", {
                Text             = cfg.Name or "Toggle",
                Font             = Enum.Font.GothamBold,
                TextSize         = 13,
                TextColor3       = Theme.Text,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Size             = UDim2.new(1, -iconOff - 52, 0, 18),
                Position         = UDim2.new(0, iconOff, 0, 0),
                BackgroundTransparency = 1,
                Parent           = topRow,
            })

            if cfg.Description then
                Make("TextLabel", {
                    Text             = cfg.Description,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 10,
                    TextColor3       = Theme.TextDim,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Size             = UDim2.new(1, -iconOff - 52, 0, 14),
                    Position         = UDim2.new(0, iconOff, 0, 19),
                    BackgroundTransparency = 1,
                    Parent           = topRow,
                })
            end

            -- Toggle switch
            local togBG = Make("Frame", {
                Size             = UDim2.new(0, 40, 0, 22),
                Position         = UDim2.new(1, -40, 0.5, -11),
                BackgroundColor3 = cfg.Default and Theme.ToggleOn or Theme.ToggleOff,
                BorderSizePixel  = 0,
                Parent           = topRow,
            })
            Corner(11, togBG)

            local knob = Make("Frame", {
                Size             = UDim2.new(0, 16, 0, 16),
                Position         = cfg.Default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                BackgroundColor3 = Theme.ToggleKnob,
                BorderSizePixel  = 0,
                Parent           = togBG,
            })
            Corner(8, knob)

            local togBtn = Make("TextButton", {
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = "",
                Parent           = togBG,
            })

            local state = cfg.Default == true
            togBtn.MouseButton1Click:Connect(function()
                state = not state
                Tween(togBG, { BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff }, 0.18)
                Tween(knob,  { Position = state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8) }, 0.18)
                if cfg.Callback then cfg.Callback(state) end
            end)

            -- Sub-label row (e.g. "Parry Key")
            if cfg.SubLabel then
                local subRow = Make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent           = cardList,
                })
                Make("TextLabel", {
                    Text             = cfg.SubLabel,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 11,
                    TextColor3       = Theme.TextDim,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Size             = UDim2.new(0.5, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Parent           = subRow,
                })
                -- Keybind box
                local keyBox = Make("TextButton", {
                    Text             = cfg.Key or "F",
                    Font             = Enum.Font.GothamBold,
                    TextSize         = 12,
                    TextColor3       = Theme.Text,
                    Size             = UDim2.new(0.5, 0, 1, -4),
                    Position         = UDim2.new(0.5, 0, 0, 2),
                    BackgroundColor3 = Theme.InputBG,
                    BorderSizePixel  = 0,
                    AutoButtonColor  = false,
                    Parent           = subRow,
                })
                Corner(6, keyBox)
                Stroke(Theme.InputBorder, 1, keyBox)

                local listening = false
                keyBox.MouseButton1Click:Connect(function()
                    listening = true
                    keyBox.Text = "..."
                    keyBox.TextColor3 = Theme.TextDim
                end)
                UserInputService.InputBegan:Connect(function(inp, gp)
                    if not listening then return end
                    if inp.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        local keyName = inp.KeyCode.Name
                        keyBox.Text = keyName
                        keyBox.TextColor3 = Theme.Text
                        if cfg.KeyCallback then cfg.KeyCallback(inp.KeyCode) end
                    end
                end)
            end

            return {
                SetState = function(v)
                    state = v
                    Tween(togBG, { BackgroundColor3 = v and Theme.ToggleOn or Theme.ToggleOff }, 0.18)
                    Tween(knob,  { Position = v and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8) }, 0.18)
                end,
                GetState = function() return state end,
            }
        end

        -- --------------------------------------------------------
        -- SLIDER
        -- --------------------------------------------------------
        function Tab:AddSlider(cfg)
            cfg = cfg or {}
            local col = cfg.Column == "right" and rightCol
                     or cfg.Column == "left"  and leftCol
                     or nextCol()

            local minV  = cfg.Min     or 0
            local maxV  = cfg.Max     or 100
            local defV  = cfg.Default or 50
            local sfx   = cfg.Suffix  or "%"

            local card, cardList = makeCard(nil, cfg)

            -- Top row: icon + title + toggle (optional)
            local topRow = Make("Frame", {
                Size             = UDim2.new(1, 0, 0, 34),
                BackgroundTransparency = 1,
                Parent           = cardList,
            })

            if cfg.Icon then
                Make("ImageLabel", {
                    Image            = cfg.Icon,
                    ImageColor3      = Theme.TextDim,
                    Size             = UDim2.new(0, 20, 0, 20),
                    Position         = UDim2.new(0, 0, 0.5, -10),
                    BackgroundTransparency = 1,
                    Parent           = topRow,
                })
            end
            local iconOff = cfg.Icon and 28 or 0

            Make("TextLabel", {
                Text             = cfg.Name or "Slider",
                Font             = Enum.Font.GothamBold,
                TextSize         = 13,
                TextColor3       = Theme.Text,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Size             = UDim2.new(1, -iconOff - 52, 0, 18),
                Position         = UDim2.new(0, iconOff, 0, 0),
                BackgroundTransparency = 1,
                Parent           = topRow,
            })
            if cfg.Description then
                Make("TextLabel", {
                    Text             = cfg.Description,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 10,
                    TextColor3       = Theme.TextDim,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Size             = UDim2.new(1, -iconOff - 52, 0, 14),
                    Position         = UDim2.new(0, iconOff, 0, 19),
                    BackgroundTransparency = 1,
                    Parent           = topRow,
                })
            end

            -- Toggle in top-right (optional)
            if cfg.HasToggle then
                local togBG2 = Make("Frame", {
                    Size             = UDim2.new(0, 40, 0, 22),
                    Position         = UDim2.new(1, -40, 0.5, -11),
                    BackgroundColor3 = cfg.ToggleDefault and Theme.ToggleOn or Theme.ToggleOff,
                    BorderSizePixel  = 0,
                    Parent           = topRow,
                })
                Corner(11, togBG2)
                local knob2 = Make("Frame", {
                    Size             = UDim2.new(0, 16, 0, 16),
                    Position         = cfg.ToggleDefault and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
                    BackgroundColor3 = Theme.ToggleKnob,
                    BorderSizePixel  = 0,
                    Parent           = togBG2,
                })
                Corner(8, knob2)
                local togBtn2 = Make("TextButton", {
                    Size = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1, Text = "",
                    Parent = togBG2,
                })
                local togState = cfg.ToggleDefault == true
                togBtn2.MouseButton1Click:Connect(function()
                    togState = not togState
                    Tween(togBG2, { BackgroundColor3 = togState and Theme.ToggleOn or Theme.ToggleOff }, 0.18)
                    Tween(knob2, { Position = togState and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8) }, 0.18)
                    if cfg.ToggleCallback then cfg.ToggleCallback(togState) end
                end)
            end

            -- Value label
            local valueLabel = Make("TextLabel", {
                Text             = tostring(defV) .. sfx,
                Font             = Enum.Font.GothamBold,
                TextSize         = 12,
                TextColor3       = Theme.Text,
                TextXAlignment   = Enum.TextXAlignment.Right,
                Size             = UDim2.new(0, 50, 1, 0),
                Position         = UDim2.new(1, -50, 0, 0),
                BackgroundTransparency = 1,
                Parent           = topRow,
            })

            -- Slider row
            local sliderRow = Make("Frame", {
                Size             = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Parent           = cardList,
            })

            -- Sub label (Speed, Accuracy, etc)
            if cfg.SubLabel then
                Make("TextLabel", {
                    Text             = cfg.SubLabel,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 11,
                    TextColor3       = Theme.TextDim,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Size             = UDim2.new(1, 0, 0, 14),
                    BackgroundTransparency = 1,
                    Parent           = cardList,
                })
            end

            local track = Make("Frame", {
                Size             = UDim2.new(1, 0, 0, 6),
                Position         = UDim2.new(0, 0, 0.5, -3),
                BackgroundColor3 = Theme.SliderTrack,
                BorderSizePixel  = 0,
                Parent           = sliderRow,
            })
            Corner(3, track)

            local pct = (defV - minV) / (maxV - minV)
            local fill = Make("Frame", {
                Size             = UDim2.new(pct, 0, 1, 0),
                BackgroundColor3 = Theme.SliderFill,
                BorderSizePixel  = 0,
                Parent           = track,
            })
            Corner(3, fill)

            local thumb = Make("Frame", {
                Size             = UDim2.new(0, 14, 0, 14),
                Position         = UDim2.new(pct, -7, 0.5, -7),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel  = 0,
                Parent           = track,
            })
            Corner(7, thumb)

            local currentValue = defV
            local draggingSlider = false

            local sliderBtn = Make("TextButton", {
                Size = UDim2.new(1, 0, 1, 0), Text = "",
                BackgroundTransparency = 1,
                Parent = track,
            })
            sliderBtn.MouseButton1Down:Connect(function()
                draggingSlider = true
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = false
                end
            end)
            RunService.RenderStepped:Connect(function()
                if not draggingSlider then return end
                local absPos  = track.AbsolutePosition.X
                local absSize = track.AbsoluteSize.X
                local mouseX  = Mouse.X
                local newPct  = math.clamp((mouseX - absPos) / absSize, 0, 1)
                local newVal  = math.floor(minV + (maxV - minV) * newPct + 0.5)
                currentValue  = newVal
                local dp = newVal / (maxV - minV) -- normalized display
                Tween(fill,  { Size = UDim2.new(newPct, 0, 1, 0) }, 0.05)
                Tween(thumb, { Position = UDim2.new(newPct, -7, 0.5, -7) }, 0.05)
                valueLabel.Text = tostring(newVal) .. sfx
                if cfg.Callback then cfg.Callback(newVal) end
            end)

            -- Info box (optional, like "Higher accuracy = better timing")
            if cfg.Info then
                local infoBox = Make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 42),
                    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                    BorderSizePixel  = 0,
                    Parent           = cardList,
                })
                Corner(6, infoBox)
                Stroke(Theme.Border, 1, infoBox)
                Padding(8, 8, 10, 10, infoBox)

                local infoRow = Make("Frame", {
                    Size             = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Parent           = infoBox,
                })
                if cfg.InfoIcon then
                    Make("ImageLabel", {
                        Image            = cfg.InfoIcon,
                        ImageColor3      = Theme.TextMuted,
                        Size             = UDim2.new(0, 16, 0, 16),
                        Position         = UDim2.new(0, 0, 0.5, -8),
                        BackgroundTransparency = 1,
                        Parent           = infoRow,
                    })
                end
                Make("TextLabel", {
                    Text             = cfg.Info,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 10,
                    TextColor3       = Theme.TextDim,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    TextWrapped      = true,
                    Size             = UDim2.new(1, cfg.InfoIcon and -22 or 0, 1, 0),
                    Position         = UDim2.new(0, cfg.InfoIcon and 22 or 0, 0, 0),
                    BackgroundTransparency = 1,
                    Parent           = infoRow,
                })
            end

            return {
                SetValue = function(v)
                    currentValue = v
                    local p = math.clamp((v - minV) / (maxV - minV), 0, 1)
                    Tween(fill,  { Size = UDim2.new(p, 0, 1, 0) }, 0.1)
                    Tween(thumb, { Position = UDim2.new(p, -7, 0.5, -7) }, 0.1)
                    valueLabel.Text = tostring(v) .. sfx
                end,
                GetValue = function() return currentValue end,
            }
        end

        -- --------------------------------------------------------
        -- LABEL (section header)
        -- --------------------------------------------------------
        function Tab:AddLabel(text, col)
            local parent = col == "right" and rightCol or col == "left" and leftCol or nextCol()
            Make("TextLabel", {
                Text             = text or "",
                Font             = Enum.Font.GothamBold,
                TextSize         = 10,
                TextColor3       = Theme.TextMuted,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Size             = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Parent           = parent,
            })
        end

        -- --------------------------------------------------------
        -- SEPARATOR
        -- --------------------------------------------------------
        function Tab:AddSeparator(col)
            local parent = col == "right" and rightCol or col == "left" and leftCol or nextCol()
            Make("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.Border,
                BorderSizePixel  = 0,
                Parent           = parent,
            })
        end

        return Tab
    end

    -- ============================================================
    -- KEYBIND (toggle window visibility)
    -- ============================================================
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == toggleKey then
            win.Visible = not win.Visible
        end
    end)

    return Window
end

-- ================================================================
-- NOTIFY (toast notification)
-- ================================================================
function XitttpLib:Notify(config)
    config = config or {}
    local title = config.Title   or "Notification"
    local msg   = config.Message or ""
    local dur   = config.Duration or 3

    local sg = LocalPlayer.PlayerGui:FindFirstChild("XitttpGui")
    local parent = sg or LocalPlayer.PlayerGui

    local toast = Make("Frame", {
        Name             = "Toast",
        Size             = UDim2.new(0, 260, 0, 60),
        Position         = UDim2.new(1, -276, 1, -76),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel  = 0,
        BackgroundTransparency = 1,
        ZIndex           = 100,
        Parent           = parent,
    })
    Corner(8, toast)
    Stroke(Theme.Border, 1, toast)

    Make("TextLabel", {
        Text             = title,
        Font             = Enum.Font.GothamBold,
        TextSize          = 12,
        TextColor3       = Theme.Text,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Size             = UDim2.new(1, -16, 0, 20),
        Position         = UDim2.new(0, 12, 0, 10),
        BackgroundTransparency = 1,
        ZIndex           = 101,
        Parent           = toast,
    })
    Make("TextLabel", {
        Text             = msg,
        Font             = Enum.Font.Gotham,
        TextSize          = 10,
        TextColor3       = Theme.TextDim,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        Size             = UDim2.new(1, -16, 0, 20),
        Position         = UDim2.new(0, 12, 0, 30),
        BackgroundTransparency = 1,
        ZIndex           = 101,
        Parent           = toast,
    })

    -- Progress bar
    local prog = Make("Frame", {
        Size             = UDim2.new(1, -2, 0, 2),
        Position         = UDim2.new(0, 1, 1, -3),
        BackgroundColor3 = Theme.ToggleOn,
        BorderSizePixel  = 0,
        ZIndex           = 102,
        Parent           = toast,
    })
    Corner(1, prog)

    Tween(toast, { BackgroundTransparency = 0 }, 0.2)
    Tween(prog,  { Size = UDim2.new(0, 0, 0, 2) }, dur, Enum.EasingStyle.Linear)

    task.delay(dur, function()
        Tween(toast, { BackgroundTransparency = 1, Position = UDim2.new(1,-276,1,-56) }, 0.2)
        task.delay(0.25, function() toast:Destroy() end)
    end)
end

return XitttpLib
