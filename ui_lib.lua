-- ui_lib.lua
-- LevelHub UI - reusable UI library (no game-specific items)
-- Return a UI table when executed: local UI = loadstring(... )()

--------------------------------------------------
-- CONFIG ICONS (exported to UI)
--------------------------------------------------
local ICON_ARROW_LEFT   = "rbxassetid://127001928102240"
local ICON_ARROW_RIGHT  = "rbxassetid://118483902647846"
local ICON_ARROW_DOWN   = "rbxassetid://74976956154520"
local ICON_ARROW_UP     = "rbxassetid://78380803977611"
local ICON_SIDEBAR_ITEM = "rbxassetid://131678316027088"

--------------------------------------------------
-- Services / helpers
--------------------------------------------------
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local plr = Players.LocalPlayer or Players:GetPlayers()[1]
local parentGui
if plr and plr:FindFirstChild("PlayerGui") then
    parentGui = plr.PlayerGui
else
    parentGui = game:GetService("CoreGui")
end

local function New(className, props)
    local o = Instance.new(className)
    for k,v in pairs(props or {}) do
        if k ~= "Children" then
            o[k] = v
        end
    end
    if props and props.Children then
        for _,c in ipairs(props.Children) do
            c.Parent = o
        end
    end
    return o
end

local function Corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = parent
    return c
end

local function Stroke(parent, color, thk)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thk or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function Hoverify(btn, lighten)
    if btn:IsA("TextButton") or btn:IsA("ImageButton") then
        btn.AutoButtonColor = false
    end
    local baseTrans = btn.BackgroundTransparency
    local baseColor = btn.BackgroundColor3
    btn.MouseEnter:Connect(function()
        if lighten and baseTrans >= 1 then
            btn.BackgroundTransparency = 0
            btn.BackgroundColor3 = Color3.fromRGB(60,60,64)
        else
            btn.BackgroundTransparency = math.clamp(baseTrans - 0.2, 0, 1)
        end
    end)
    btn.MouseLeave:Connect(function()
        if lighten and baseTrans >= 1 then
            btn.BackgroundTransparency = 1
            btn.BackgroundColor3 = baseColor
        else
            btn.BackgroundTransparency = baseTrans
        end
    end)
end

local function tweenProp(inst, goalTable, duration)
    return TweenService:Create(
        inst,
        TweenInfo.new(duration or 0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
        goalTable
    )
end

--------------------------------------------------
-- Toggle / Slider components (exported helpers)
--------------------------------------------------
local function MakeToggle(parent, defaultState, callback)
    local state = defaultState and true or false

    local ToggleBtn = New("TextButton", {
        Parent = parent,
        BackgroundColor3 = state and Color3.fromRGB(40,120,255) or Color3.fromRGB(70,70,75),
        BorderSizePixel = 0,
        Size = UDim2.new(0,44,0,24),
        Text = "",
        AutoButtonColor = false,
        ZIndex = parent.ZIndex,
    })
    Corner(ToggleBtn, 999)

    local Knob = New("Frame", {
        Parent = ToggleBtn,
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BorderSizePixel = 0,
        Size = UDim2.new(0,20,0,20),
        Position = state and UDim2.new(1,-22,0,2) or UDim2.new(0,2,0,2),
        ZIndex = ToggleBtn.ZIndex + 1,
    })
    Corner(Knob,999)

    local function sync()
        ToggleBtn.BackgroundColor3 = state and Color3.fromRGB(40,120,255) or Color3.fromRGB(70,70,75)
        Knob:TweenPosition(
            state and UDim2.new(1,-22,0,2) or UDim2.new(0,2,0,2),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Sine,
            0.15,true
        )
    end

    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        sync()
        if callback then
            local ok,err = pcall(callback, state)
            if not ok then warn("toggle cb:",err) end
        end
    end)

    sync()
    return ToggleBtn
end

local function MakeSlider(parent, startAlpha, onChange)
    local a = math.clamp(startAlpha or 0.5,0,1)

    local Bar = New("Frame", {
        Parent = parent,
        BackgroundColor3 = Color3.fromRGB(60,60,62),
        BorderSizePixel = 0,
        Size = UDim2.new(0,200,0,4),
        AnchorPoint = Vector2.new(1,0.5),
        Position = UDim2.new(1,0,0.5,0),
        ZIndex = parent.ZIndex,
    })
    Corner(Bar,999)

    local Fill = New("Frame", {
        Parent = Bar,
        BackgroundColor3 = Color3.fromRGB(220,30,60),
        BorderSizePixel = 0,
        Size = UDim2.new(a,0,1,0),
        ZIndex = Bar.ZIndex + 1,
    })
    Corner(Fill,999)

    local Handle = New("Frame", {
        Parent = Bar,
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BorderSizePixel = 0,
        Size = UDim2.new(0,18,0,18),
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(a,0,0.5,0),
        ZIndex = Bar.ZIndex + 2,
    })
    Corner(Handle,999)

    local dragging = false
    local function applyFromMouse(x)
        local absPos = Bar.AbsolutePosition.X
        local absSize = Bar.AbsoluteSize.X
        local rel = math.clamp((x-absPos)/absSize,0,1)
        a = rel
        Fill.Size = UDim2.new(a,0,1,0)
        Handle.Position = UDim2.new(a,0,0.5,0)
        local value = math.floor(a*20 + 0.5)
        if onChange then
            local ok,err = pcall(function()
                onChange(value,a)
            end)
            if not ok then warn("slider cb:",err) end
        end
    end

    Handle.InputBegan:Connect(function(ip)
        if ip.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    Handle.InputEnded:Connect(function(ip)
        if ip.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(ip)
        if dragging and ip.UserInputType == Enum.UserInputType.MouseMovement then
            applyFromMouse(ip.Position.X)
        end
    end)

    return {
        SetValue = function(v)
            v = math.clamp(v,0,20)
            local alpha = v/20
            a = alpha
            Fill.Size = UDim2.new(a,0,1,0)
            Handle.Position = UDim2.new(a,0,0.5,0)
        end,
        Instance = Bar,
    }
end

--------------------------------------------------
-- ScreenGui & window state
--------------------------------------------------
local Gui = New("ScreenGui", {
    Name = "LevelHub_UI_Library",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Global,
    Parent = parentGui,
})

local WindowState = {
    Minimized = false,
    IsMaximized = false,

    LastSize = UDim2.new(0,800,0,480),
    LastPos  = UDim2.new(0,200,0,100),

    StoredBeforeMinimize = nil,
}

-- Main Window
local Main = New("Frame", {
    Parent = Gui,
    BackgroundColor3 = Color3.fromRGB(30,30,32),
    BorderSizePixel = 0,
    Size = WindowState.LastSize,
    Position = WindowState.LastPos,
    ClipsDescendants = false,
    ZIndex = 1,
})
Corner(Main,8)
Stroke(Main, Color3.fromRGB(70,70,72),1)

--------------------------------------------------
-- Sidebar (left)
--------------------------------------------------
local Sidebar = New("Frame", {
    Parent = Main,
    BackgroundColor3 = Color3.fromRGB(26,26,28),
    BorderSizePixel = 0,
    Size = UDim2.new(0,220,1,0),
    Position = UDim2.new(0,0,0,0),
    ZIndex = 2,
})
Corner(Sidebar,8)

--------------------------------------------------
-- RightPanel + HeaderBar
--------------------------------------------------
local RightPanel = New("Frame", {
    Parent = Main,
    BackgroundColor3 = Color3.fromRGB(30,30,32),
    BorderSizePixel = 0,
    Size = UDim2.new(1,-220,1,0),
    Position = UDim2.new(0,220,0,0),
    ZIndex = 2,
})
Corner(RightPanel,8)

local HeaderBar = New("Frame", {
    Parent = RightPanel,
    BackgroundColor3 = Color3.fromRGB(40,40,42),
    BorderSizePixel = 0,
    Size = UDim2.new(1,0,0,44),
    ZIndex = 3,
})
Corner(HeaderBar,8)

local HeaderBarBG = New("Frame", {
    Parent = RightPanel,
    BackgroundColor3 = Color3.fromRGB(40,40,42),
    BorderSizePixel = 0,
    Size = UDim2.new(1,0,0,15),
    Position = UDim2.new(0,0,0,29),
    ZIndex = 3,
})

-- drag main window by header
do
    local dragging = false
    local dragOffset = Vector2.new(0,0)
    local function updateDrag(input)
        local mousePos = input.Position
        local newX = mousePos.X - dragOffset.X
        local newY = mousePos.Y - dragOffset.Y
        Main.Position = UDim2.new(0,newX,0,newY)
        WindowState.LastPos = Main.Position
    end
    HeaderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local mousePos = input.Position
            local mainAbs = Main.AbsolutePosition
            dragOffset = Vector2.new(mousePos.X - mainAbs.X, mousePos.Y - mainAbs.Y)
        end
    end)
    HeaderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateDrag(input)
        end
    end)
end


-- Resize handle: place this after the header drag block (after HeaderBar drag code)
do
    local RESIZE_SIZE = 12
    local minW, minH = 360, 200
    local maxW, maxH = math.huge, math.huge -- หรือกำหนดขนาดสูงสุดถ้าต้องการ

    local ResizeHandle = New("Frame", {
        Parent = Main,
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(60,60,64),
        BorderSizePixel = 0,
        Size = UDim2.new(0, RESIZE_SIZE, 0, RESIZE_SIZE),
        AnchorPoint = Vector2.new(1,1),
        Position = UDim2.new(1, 0, 1, 0),
        ZIndex = 50,
    })
    Corner(ResizeHandle, 4)

    -- small visual diagonal lines (optional)
    local diag = New("ImageLabel", {
        Parent = ResizeHandle,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -4, 1, -4),
        Position = UDim2.new(0, 2, 0, 2),
        Image = "",
        ZIndex = 51,
    })

    Hoverify(ResizeHandle, true)

    local dragging = false
    local startMouse = Vector2.new()
    local startSize = UDim2.new()
    local startPos = UDim2.new()

    local function clamp(v, a, b)
        return math.max(a, math.min(b, v))
    end

    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startMouse = input.Position
            startSize = Main.Size
            startPos = Main.Position
            -- capture mouse movement until release
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    ResizeHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

        -- compute delta from starting mouse
        local dx = input.Position.X - startMouse.X
        local dy = input.Position.Y - startMouse.Y

        -- starting absolute size/pos
        local mainAbsPos = Main.AbsolutePosition
        local mainAbsSize = Main.AbsoluteSize

        -- convert startSize (UDim2) to pixel width/height using stored LastSize if needed
        -- safer: use current AbsoluteSize as baseline
        local newW = math.max(minW, math.floor(mainAbsSize.X + dx))
        local newH = math.max(minH, math.floor(mainAbsSize.Y + dy))

        if maxW and maxW ~= math.huge then newW = math.min(maxW, newW) end
        if maxH and maxH ~= math.huge then newH = math.min(maxH, newH) end

        -- Set Main size in pixels using UDim2.new(0, newW, 0, newH)
        Main.Size = UDim2.new(0, newW, 0, newH)
        WindowState.LastSize = Main.Size

        -- Ensure RightPanel and Sidebar layout are consistent
        local sidebarWidth = Sidebar.Size.X.Offset or SidebarState.CurrentWidth or Sidebar.AbsoluteSize.X
        applySidebarLayout(sidebarWidth)
    end)

    -- when releasing mouse anywhere, stop dragging
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

--------------------------------------------------
-- Sidebar Show/Hide logic (TinyNavBtn)
--------------------------------------------------
local SidebarState = {
    ExpandedWidth = 220,
    CurrentWidth  = 220,
    Collapsed     = false,
}

local function applySidebarLayout(width)
    Sidebar.Size    = UDim2.new(0, width, 1, 0)
    SidebarState.CurrentWidth = width

    RightPanel.Position = UDim2.new(0, width, 0, 0)
    RightPanel.Size     = UDim2.new(1, -width, 1, 0)
end

local function CollapseSidebar()
    if SidebarState.Collapsed then return end
    SidebarState.Collapsed = true
    local targetWidth = 0

    local tw1 = tweenProp(Sidebar, {
        Size = UDim2.new(0, targetWidth, 1, 0)
    }, 0.22)

    local tw2 = tweenProp(RightPanel, {
        Position = UDim2.new(0, targetWidth, 0, 0),
        Size     = UDim2.new(1, -targetWidth, 1, 0)
    }, 0.22)

    tw1:Play()
    tw2:Play()

    task.delay(0.22, function()
        SidebarState.CurrentWidth = targetWidth
        Sidebar.Active = false
    end)
end

local function ExpandSidebar()
    if not SidebarState.Collapsed then return end
    SidebarState.Collapsed = false

    local targetWidth = SidebarState.ExpandedWidth
    Sidebar.Active = true

    local tw1 = tweenProp(Sidebar, {
        Size = UDim2.new(0, targetWidth, 1, 0)
    }, 0.22)

    local tw2 = tweenProp(RightPanel, {
        Position = UDim2.new(0, targetWidth, 0, 0),
        Size     = UDim2.new(1, -targetWidth, 1, 0)
    }, 0.22)

    tw1:Play()
    tw2:Play()

    task.delay(0.22, function()
        SidebarState.CurrentWidth = targetWidth
    end)
end

local function ToggleSidebar()
    if SidebarState.Collapsed then
        ExpandSidebar()
    else
        CollapseSidebar()
    end
end

--------------------------------------------------
-- HeaderBar tiny nav buttons (now only sidebar toggle)
--------------------------------------------------
local NavGroup = New("Frame", {
    Parent = HeaderBar,
    BackgroundTransparency = 1,
    Size = UDim2.new(0,36,1,0),
    Position = UDim2.new(0,12,0,0),
    ZIndex = 4,
})

local function TinyNavBtn(imgId, x)
    local b = New("ImageButton", {
        Parent = NavGroup,
        BackgroundColor3 = Color3.fromRGB(50,50,52),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(0,26,0,24),
        Position = UDim2.new(0,x,0,10),
        Image = imgId,
        ImageColor3 = Color3.fromRGB(235,235,245),
        ZIndex = 5,
        AutoButtonColor = false,
    })
    Corner(b,4)
    Hoverify(b)
    return b
end

local BtnSidebar = TinyNavBtn(ICON_SIDEBAR_ITEM, 0)
BtnSidebar.MouseButton1Click:Connect(function()
    ToggleSidebar()
end)

--------------------------------------------------
-- Title (centered app title + subtitle)
-- (you can change title via UI.Title property)
--------------------------------------------------
local TitleBlock = New("Frame", {
    Parent = HeaderBar,
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(0.5,0.5),
    Position = UDim2.new(0.5,0,0.5,0),
    Size = UDim2.new(0,260,1,0),
    ZIndex = 4,
})

local TitleLabel = New("TextLabel", {
    Parent = TitleBlock,
    BackgroundTransparency = 1,
    Size = UDim2.new(1,0,0,20),
    Position = UDim2.new(0,0,0,4),
    Font = Enum.Font.SourceSansBold,
    Text = "LevelHub UI",
    TextColor3 = Color3.fromRGB(235,235,245),
    TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 5,
})

local SubLabel = New("TextLabel", {
    Parent = TitleBlock,
    BackgroundTransparency = 1,
    Size = UDim2.new(1,0,0,16),
    Position = UDim2.new(0,0,0,20),
    Font = Enum.Font.SourceSans,
    Text = "UI Library",
    TextColor3 = Color3.fromRGB(142,142,147),
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 5,
})

--------------------------------------------------
-- Search box (right side)
--------------------------------------------------
local SearchBox = New("Frame", {
    Parent = HeaderBar,
    BackgroundColor3 = Color3.fromRGB(50,50,52),
    BorderSizePixel = 0,
    Size = UDim2.new(0,170,0,26),
    AnchorPoint = Vector2.new(1,0.5),
    Position = UDim2.new(1,-12,0.5,0),
    ZIndex = 4,
})
Corner(SearchBox,6)
Stroke(SearchBox, Color3.fromRGB(70,70,72),1)

local SearchIcon = New("TextLabel", {
    Parent = SearchBox,
    BackgroundTransparency = 1,
    Size = UDim2.new(0,20,1,0),
    Position = UDim2.new(0,8,0,0),
    Font = Enum.Font.SourceSans,
    Text = "🔍",
    TextColor3 = Color3.fromRGB(180,180,185),
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5,
})

local SearchInput = New("TextBox", {
    Parent = SearchBox,
    BackgroundTransparency = 1,
    Size = UDim2.new(1,-30,1,0),
    Position = UDim2.new(0,30,0,0),
    Font = Enum.Font.SourceSans,
    PlaceholderText = "Search",
    Text = "",
    TextColor3 = Color3.fromRGB(235,235,245),
    PlaceholderColor3 = Color3.fromRGB(180,180,185),
    TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    ZIndex = 5,
})

--------------------------------------------------
-- ContentHolder (page area under header)
--------------------------------------------------
local ContentHolder = New("Frame", {
    Parent = RightPanel,
    BackgroundTransparency = 1,
    Position = UDim2.new(0,0,0,44),
    Size = UDim2.new(1,0,1,-44),
    ZIndex = 2,
})

--------------------------------------------------
-- Section card builder (reusable)
--------------------------------------------------
local function CreateSectionCard(parent, rowsOutTable)
    local Card = New("Frame", {
        Parent = parent,
        BackgroundColor3 = Color3.fromRGB(40,40,42),
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1,0,0,0),
        ZIndex = 3,
    })
    Corner(Card,6)
    Stroke(Card, Color3.fromRGB(60,60,62),1)

    New("UIPadding", {
        Parent = Card,
        PaddingLeft = UDim.new(0,12),
        PaddingRight = UDim.new(0,12),
        PaddingTop = UDim.new(0,12),
        PaddingBottom = UDim.new(0,12),
    })

    New("UIListLayout", {
        Parent = Card,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0,0),
    })

    local API = {}

    function API:AddToggleRow(iconTxt, titleTxt, descTxt, defaultState, callback)
        local Row = New("Frame", {
            Parent = Card,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,0,44),
            ZIndex = 5,
        })

        local Left = New("Frame", {
            Parent = Row,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,-80,1,0),
            Position = UDim2.new(0,0,0,0),
            ZIndex = 6,
        })

        New("TextLabel", {
            Parent = Left,
            BackgroundTransparency = 1,
            Size = UDim2.new(0,20,0,20),
            Position = UDim2.new(0,0,0,2),
            Font = Enum.Font.SourceSansBold,
            Text = iconTxt or "◆",
            TextColor3 = Color3.fromRGB(255,255,255),
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 7,
        })

        local TxtBlock = New("Frame", {
            Parent = Left,
            BackgroundTransparency = 1,
            Position = UDim2.new(0,24,0,0),
            Size = UDim2.new(1,-24,1,0),
            ZIndex = 7,
        })

        local TitleLbl = New("TextLabel", {
            Parent = TxtBlock,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,0,18),
            Font = Enum.Font.SourceSansBold,
            Text = titleTxt or "",
            TextColor3 = Color3.fromRGB(235,235,245),
            TextSize = 17,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 8,
        })

        local DescLbl = New("TextLabel", {
            Parent = TxtBlock,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,0,16),
            Position = UDim2.new(0,0,0,18),
            Font = Enum.Font.SourceSans,
            Text = descTxt or "",
            TextColor3 = Color3.fromRGB(180,180,185),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 8,
        })

        local RightSide = New("Frame", {
            Parent = Row,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1,0.5),
            Position = UDim2.new(1,0,0.5,0),
            Size = UDim2.new(0,60,0,24),
            ZIndex = 7,
        })
        local toggleInst = MakeToggle(RightSide, defaultState, callback)

        New("Frame", {
            Parent = Row,
            BackgroundColor3 = Color3.fromRGB(60,60,62),
            BorderSizePixel = 0,
            Size = UDim2.new(1,0,0,1),
            Position = UDim2.new(0,0,1,-1),
            ZIndex = 6,
        })

        if rowsOutTable then
            table.insert(rowsOutTable,{
                RowFrame = Row,
                Title = TitleLbl,
                Desc  = DescLbl,
                Toggle = toggleInst,
            })
        end
    end

    function API:AddSliderRow(baseTitle, descTxt, defaultAlpha, onChange)
        local Row = New("Frame", {
            Parent = Card,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,0,44),
            ZIndex = 5,
        })

        local Left = New("Frame", {
            Parent = Row,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,-220,1,0),
            Position = UDim2.new(0,0,0,0),
            ZIndex = 6,
        })

        local TitleLbl = New("TextLabel", {
            Parent = Left,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,0,18),
            Font = Enum.Font.SourceSansBold,
            Text = (baseTitle or "") .. " ( 0 )",
            TextColor3 = Color3.fromRGB(235,235,245),
            TextSize = 17,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 7,
        })

        local DescLbl = New("TextLabel", {
            Parent = Left,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,0,16),
            Position = UDim2.new(0,0,0,18),
            Font = Enum.Font.SourceSans,
            Text = descTxt or "",
            TextColor3 = Color3.fromRGB(180,180,185),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 7,
        })

        local RightSide = New("Frame", {
            Parent = Row,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1,0.5),
            Position = UDim2.new(1,0,0.5,0),
            Size = UDim2.new(0,220,0,24),
            ZIndex = 7,
        })
        local slider = MakeSlider(RightSide, defaultAlpha or 0.5, function(value,alpha)
            TitleLbl.Text = (baseTitle or "") .. " ( "..tostring(value).." )"
            if onChange then
                pcall(onChange, value, alpha)
            end
        end)

        New("Frame", {
            Parent = Row,
            BackgroundColor3 = Color3.fromRGB(60,60,62),
            BorderSizePixel = 0,
            Size = UDim2.new(1,0,0,1),
            Position = UDim2.new(0,0,1,-1),
            ZIndex = 6,
        })

        if rowsOutTable then
            table.insert(rowsOutTable,{
                RowFrame = Row,
                Title = TitleLbl,
                Desc  = DescLbl,
                Slider = slider,
            })
        end
    end

    return API
end

--------------------------------------------------
-- Pages / Tabs
--------------------------------------------------
local Pages = {}
local ActiveTab = nil

local function CreatePage(name)
    local Page = New("ScrollingFrame", {
        Parent = ContentHolder,
        BackgroundColor3 = Color3.fromRGB(30,30,32),
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1,0,1,0),
        Position = UDim2.new(0,0,0,0),
        Visible = false,
        ZIndex = 2,
    })
    Corner(Page,8)
    New("UIPadding", {
        Parent = Page,
        PaddingLeft = UDim.new(0,12),
        PaddingRight = UDim.new(0,12),
        PaddingTop = UDim.new(0,12),
        PaddingBottom = UDim.new(0,12),
    })
    New("UIListLayout", {
        Parent = Page,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0,12),
    })

    Pages[name] = {
        Frame = Page,
        Rows  = {},
    }
    return Pages[name]
end

local function SetActiveTab(tabName)
    ActiveTab = tabName

    -- show only that page
    for name, data in pairs(Pages) do
        data.Frame.Visible = (name == tabName)
    end

    -- clear search + reset filter visuals
    SearchInput.Text = ""
end

-- search filter logic
local function refreshSearch()
    local term = string.lower(SearchInput.Text)
    local current = Pages[ActiveTab]
    if not current then return end
    local rows = current.Rows or {}
    for _,rowInfo in ipairs(rows) do
        local t = string.lower(rowInfo.Title.Text or "")
        local d = string.lower(rowInfo.Desc.Text or "")
        local match = (term == "" or string.find(t,term,1,true) or string.find(d,term,1,true))
        rowInfo.RowFrame.Visible = match
    end
end
SearchInput:GetPropertyChangedSignal("Text"):Connect(refreshSearch)

--------------------------------------------------
-- Sidebar Groups / Items (public API)
--------------------------------------------------
local Groups = {}
local SidebarButtons = {}
local HEADER_FONT = Enum.Font.SourceSansBold
local SUB_FONT    = Enum.Font.SourceSans

local function AddGroupHeader(name)
    -- If already exists, return existing
    if Groups[name] then
        return Groups[name].Holder, Groups[name].ItemsHolder
    end

    local Holder = Instance.new("Frame")
    Holder.Name = name .. "_Group"
    Holder.BackgroundTransparency = 1
    Holder.Size = UDim2.new(1,-4,0,20)
    Holder.ZIndex = 4

    local Row = Instance.new("TextButton")
    Row.Parent = Holder
    Row.BackgroundTransparency = 1
    Row.BorderSizePixel = 0
    Row.Size = UDim2.new(1,0,1,0)
    Row.Text = ""
    Row.AutoButtonColor = false
    Row.ZIndex = 5

    local ArrowImg = Instance.new("ImageLabel")
    ArrowImg.Parent = Row
    ArrowImg.BackgroundTransparency = 1
    ArrowImg.Size = UDim2.new(0,14,0,14)
    ArrowImg.Position = UDim2.new(1,-18,0,3)
    ArrowImg.Image = ICON_ARROW_DOWN
    ArrowImg.ImageColor3 = Color3.fromRGB(160,160,170)
    ArrowImg.ZIndex = 6

    local Title = Instance.new("TextLabel")
    Title.Parent = Row
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0,0,0,0)
    Title.Size = UDim2.new(1,-24,1,0)
    Title.Font = HEADER_FONT
    Title.Text = name
    Title.TextColor3 = Color3.fromRGB(160,160,170)
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 6

    local ItemsHolder = Instance.new("Frame")
    ItemsHolder.BackgroundTransparency = 1
    ItemsHolder.Size = UDim2.new(1,0,0,0)
    ItemsHolder.ClipsDescendants = true
    ItemsHolder.ZIndex = 4

    local ItemsList = Instance.new("UIListLayout")
    ItemsList.Parent = ItemsHolder
    ItemsList.Padding = UDim.new(0,2)
    ItemsList.SortOrder = Enum.SortOrder.LayoutOrder

    local collapsed = true
    local tweening = false
    local expandedHeight = 0

    local function SetArrowRotation(rot)
        TweenService:Create(
            ArrowImg,
            TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            { Rotation = rot }
        ):Play()
    end

    local function DoCollapse()
        tweening = true
        TweenService:Create(
            ItemsHolder,
            TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            { Size = UDim2.new(1,0,0,0) }
        ):Play()
        SetArrowRotation(90)
        task.delay(0.22, function() tweening = false end)
    end

    local function DoExpand()
        tweening = true
        TweenService:Create(
            ItemsHolder,
            TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            { Size = UDim2.new(1,0,0,expandedHeight) }
        ):Play()
        SetArrowRotation(0)
        task.delay(0.22, function() tweening = false end)
    end

    Row.MouseButton1Click:Connect(function()
        if tweening then return end
        collapsed = not collapsed
        if collapsed then
            DoCollapse()
        else
            expandedHeight = 0
            for _,child in ipairs(ItemsHolder:GetChildren()) do
                if child:IsA("GuiObject") and child ~= ItemsList then
                    expandedHeight += child.AbsoluteSize.Y + ItemsList.Padding.Offset
                end
            end
            if expandedHeight > 0 then expandedHeight -= ItemsList.Padding.Offset end
            DoExpand()
        end
    end)

    Groups[name] = {
        Holder        = Holder,
        ItemsHolder   = ItemsHolder,
        ArrowImg      = ArrowImg,
        ItemsList     = ItemsList,
        _setExpandedH = function(h) expandedHeight = h end,
        _expandNow    = function()
            collapsed = false
            ItemsHolder.Size = UDim2.new(1,0,0,expandedHeight)
            ArrowImg.Rotation = 0
        end,
        _collapseNow  = function()
            collapsed = true
            ItemsHolder.Size = UDim2.new(1,0,0,0)
            ArrowImg.Rotation = 90
        end,
    }

    return Holder, ItemsHolder
end

local function AddSideItem(parentHolder, cfg)
    local thisTabName = cfg.name
    local ICON_SIZE        = cfg.iconSize or 18
    local ICON_LEFT_MARGIN = cfg.iconMarginLeft or 10
    local TEXT_GAP = 8
    local textStartX = ICON_LEFT_MARGIN + ICON_SIZE + TEXT_GAP

    local btn = Instance.new("TextButton")
    btn.Parent = parentHolder
    btn.Name = thisTabName
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(1,-4,0,40)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 5
    Corner(btn,6)

    local isInitiallyActive = (thisTabName == ActiveTab)
    btn.BackgroundColor3      = isInitiallyActive and Color3.fromRGB(255,0,80) or Color3.fromRGB(45,45,50)
    btn.BackgroundTransparency = isInitiallyActive and 0 or 1

    local IconImg = Instance.new("ImageLabel")
    IconImg.Parent = btn
    IconImg.BackgroundTransparency = 1
    IconImg.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
    local yOff = math.floor((40 - ICON_SIZE)/2)
    IconImg.Position = UDim2.new(0, ICON_LEFT_MARGIN, 0, yOff)
    IconImg.Image = cfg.icon or ICON_SIDEBAR_ITEM
    IconImg.ZIndex = 6
    IconImg.ImageColor3 = isInitiallyActive and Color3.fromRGB(255,255,255)
                                        or Color3.fromRGB(255,0,80)

    local TxtBlock = Instance.new("Frame")
    TxtBlock.Parent = btn
    TxtBlock.BackgroundTransparency = 1
    TxtBlock.Position = UDim2.new(0, textStartX, 0, 0)
    TxtBlock.Size = UDim2.new(1, -textStartX-24, 1, 0)
    TxtBlock.ZIndex = 6

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Parent = TxtBlock
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Size = UDim2.new(1,0,0,18)
    TitleLbl.Position = UDim2.new(0,0,0,6)
    TitleLbl.Font = HEADER_FONT
    TitleLbl.Text = thisTabName
    TitleLbl.TextColor3 = Color3.fromRGB(255,255,255)
    TitleLbl.TextSize = 13
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.ZIndex = 7

    local SubLbl = Instance.new("TextLabel")
    SubLbl.Parent = TxtBlock
    SubLbl.BackgroundTransparency = 1
    SubLbl.Size = UDim2.new(1,0,0,14)
    SubLbl.Position = UDim2.new(0,0,0,20)
    SubLbl.Font = SUB_FONT
    SubLbl.Text = cfg.sub or ""
    SubLbl.TextSize = 11
    SubLbl.TextXAlignment = Enum.TextXAlignment.Left
    SubLbl.ZIndex = 7
    SubLbl.TextColor3 = isInitiallyActive and Color3.fromRGB(255,255,255)
                                        or Color3.fromRGB(160,160,170)

    local ArrowImg = Instance.new("ImageLabel")
    ArrowImg.Parent = btn
    ArrowImg.BackgroundTransparency = 1
    ArrowImg.AnchorPoint = Vector2.new(1,0.5)
    ArrowImg.Position = UDim2.new(1,-8,0.5,0)
    ArrowImg.Size = UDim2.new(0,14,0,14)
    ArrowImg.Image = ICON_ARROW_RIGHT
    ArrowImg.ImageColor3 = Color3.fromRGB(255,255,255)
    ArrowImg.ZIndex = 7

    btn.MouseEnter:Connect(function()
        if ActiveTab ~= thisTabName then
            btn.BackgroundTransparency = 0
            btn.BackgroundColor3 = Color3.fromRGB(60,60,64)
        end
    end)
    btn.MouseLeave:Connect(function()
        if ActiveTab ~= thisTabName then
            btn.BackgroundColor3 = Color3.fromRGB(45,45,50)
            btn.BackgroundTransparency = 1
        end
    end)

    btn.MouseButton1Click:Connect(function()
        if cfg.onClick then
            pcall(cfg.onClick)
        else
            SetActiveTab(thisTabName)
        end
    end)

    SidebarButtons[thisTabName] = {
        Button   = btn,
        SubLabel = SubLbl,
        Icon     = IconImg,
    }
end

-- Side scroll container
local SideScroll = New("ScrollingFrame", {
    Parent = Sidebar,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.new(0,0,0,45),
    Size = UDim2.new(0.991,0,1,-45),
    ScrollBarThickness = 2,
    CanvasSize = UDim2.new(0,0,0,0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ZIndex = 3,
})
Corner(SideScroll,8)

New("UIPadding", {
    Parent = SideScroll,
    PaddingLeft = UDim.new(0,12),
    PaddingRight = UDim.new(0,12),
    PaddingTop = UDim.new(0,4),
    PaddingBottom = UDim.new(0,12),
})
New("UIListLayout", {
    Parent = SideScroll,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0,4),
})

--------------------------------------------------
-- DockButton (minimize restore)
--------------------------------------------------
local DockButton = New("ImageButton", {
    Parent = Gui,
    Name = "LevelHubDockButton",
    BackgroundColor3 = Color3.fromRGB(30,30,32),
    BorderSizePixel = 0,
    Size = UDim2.new(0,36,0,36),
    Position = UDim2.new(0,12,0,12),
    Visible = false,
    AutoButtonColor = false,
    Image = ICON_SIDEBAR_ITEM,
    ImageColor3 = Color3.fromRGB(255,0,80),
    ZIndex = 9999,
})
Corner(DockButton,8)
Stroke(DockButton, Color3.fromRGB(70,70,72),1)

DockButton.MouseEnter:Connect(function()
    DockButton.BackgroundColor3 = Color3.fromRGB(50,50,52)
    DockButton.ImageColor3 = Color3.fromRGB(255,255,255)
end)
DockButton.MouseLeave:Connect(function()
    DockButton.BackgroundColor3 = Color3.fromRGB(30,30,32)
    DockButton.ImageColor3 = Color3.fromRGB(255,0,80)
end)

local function MinimizeWindow()
    WindowState.StoredBeforeMinimize = {
        IsMaximized = WindowState.IsMaximized,
        Size        = Main.Size,
        Pos         = Main.Position,
        LastSize    = WindowState.LastSize,
        LastPos     = WindowState.LastPos,
    }

    WindowState.Minimized = true
    Main.Visible = false
    DockButton.Visible = true
end

local function RestoreFromDock()
    if not WindowState.StoredBeforeMinimize then
        WindowState.Minimized = false
        Main.Visible = true
        DockButton.Visible = false
        return
    end

    local snap = WindowState.StoredBeforeMinimize

    WindowState.IsMaximized = snap.IsMaximized
    WindowState.LastSize    = snap.LastSize
    WindowState.LastPos     = snap.LastPos

    Main.Size     = snap.Size
    Main.Position = snap.Pos

    WindowState.Minimized = false
    Main.Visible = true
    DockButton.Visible = false
end

DockButton.MouseButton1Click:Connect(function()
    RestoreFromDock()
end)

local function MaximizeWindow()
    if WindowState.IsMaximized then return end
    WindowState.LastPos  = Main.Position
    WindowState.LastSize = Main.Size
    WindowState.IsMaximized = true

    local targetSize = UDim2.new(1,-80,1,-80)
    local targetPos  = UDim2.new(0,40,0,40)

    TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        Size     = targetSize,
        Position = targetPos,
    }):Play()
end

local function RestoreWindow()
    if not WindowState.IsMaximized then return end
    WindowState.IsMaximized = false

    TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        Size     = WindowState.LastSize,
        Position = WindowState.LastPos,
    }):Play()
end

--------------------------------------------------
-- macOS dots (red / yellow / green)
--------------------------------------------------
local MacBar = New("Frame", {
    Parent = Sidebar,
    BackgroundTransparency = 1,
    Size = UDim2.new(1,0,0,28),
    Position = UDim2.new(0,12,0,8),
    ZIndex = 4,
})

local function MakeMacDot(color, offsetX, onClick)
    local b = New("TextButton", {
        Parent = MacBar,
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Size = UDim2.new(0,12,0,12),
        Position = UDim2.new(0,offsetX,0,4),
        Text = "",
        AutoButtonColor = false,
        ZIndex = 2,
    })
    Corner(b,6)
    if onClick then
        b.MouseButton1Click:Connect(onClick)
    end
    return b
end

local RedBtn = MakeMacDot(Color3.fromRGB(255,95,86), 0, function()
    Gui:Destroy()
end)

local YellowBtn = MakeMacDot(Color3.fromRGB(255,189,46), 20, function()
    if Main.Visible then
        MinimizeWindow()
    else
        RestoreFromDock()
    end
end)

local GreenBtn = MakeMacDot(Color3.fromRGB(52,199,89), 40, function()
    if not WindowState.IsMaximized then
        MaximizeWindow()
    else
        RestoreWindow()
    end
end)

--------------------------------------------------
-- API assembly (returned object)
--------------------------------------------------
local UI = {}

-- Expose constants & helpers
UI.ICON_ARROW_LEFT = ICON_ARROW_LEFT
UI.ICON_ARROW_RIGHT = ICON_ARROW_RIGHT
UI.ICON_ARROW_DOWN = ICON_ARROW_DOWN
UI.ICON_ARROW_UP = ICON_ARROW_UP
UI.ICON_SIDEBAR_ITEM = ICON_SIDEBAR_ITEM

UI.Gui = Gui
UI.Main = Main
UI.Sidebar = Sidebar
UI.RightPanel = RightPanel
UI.HeaderBar = HeaderBar
UI.ContentHolder = ContentHolder
UI.SideScroll = SideScroll

-- Title customization
function UI:SetTitle(title, subtitle)
    TitleLabel.Text = title or TitleLabel.Text
    SubLabel.Text = subtitle or SubLabel.Text
end

-- Pages
function UI:CreatePage(name)
    if Pages[name] then return Pages[name] end
    local p = CreatePage(name)
    -- expose convenience: create section card attached to this page
    function p:AddStandaloneHeader(titleText)
        local Header = New("Frame", {
            Parent = p.Frame,
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1,0,0,0),
            ZIndex = 5,
        })

        New("TextLabel", {
            Parent = Header,
            BackgroundTransparency = 1,
            Font = Enum.Font.SourceSansBold,
            Text = titleText,
            TextColor3 = Color3.fromRGB(235,235,245),
            TextSize = 20,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1,0,0,20),
            ZIndex = 6,
        })

        return Header
    end
    function p:CreateSectionCard()
        return CreateSectionCard(p.Frame, p.Rows)
    end
    return p
end

function UI:SetActiveTab(name)
    if not Pages[name] then return end
    SetActiveTab(name)
    -- recolor sidebar buttons if present
    for tabKey, pack in pairs(SidebarButtons) do
        local btn   = pack.Button
        local sub   = pack.SubLabel
        local icon  = pack.Icon
        local isActive = (tabKey == name)

        if isActive then
            btn.BackgroundColor3      = Color3.fromRGB(255,0,80)
            btn.BackgroundTransparency = 0
            sub.TextColor3            = Color3.fromRGB(255,255,255)
            icon.ImageColor3          = Color3.fromRGB(255,255,255)
        else
            btn.BackgroundColor3      = Color3.fromRGB(45,45,50)
            btn.BackgroundTransparency = 1
            sub.TextColor3            = Color3.fromRGB(160,160,170)
            icon.ImageColor3          = Color3.fromRGB(255,0,80)
        end
    end
end

-- Sidebar groups + items
function UI:AddSidebarGroup(name, expand)
    local h, items = AddGroupHeader(name)
    h.Parent = SideScroll
    items.Parent = SideScroll

    -- ถ้าผู้เรียกต้องการให้ขยายตอนสร้าง ให้เรียก _expandNow()
    if expand and Groups[name] and Groups[name]._expandNow then
        -- ให้เดเลย์สั้น ๆ เล็กน้อยก่อนขยาย เพื่อให้ AbsoluteSize ถูกคำนวณเรียบร้อย
        task.defer(function()
            -- safety: รีคัลคูลเล็กน้อย ถ้ามีปุ่มในกลุ่มแล้ว
            local total = 0
            local listPadding = Groups[name].ItemsList.Padding.Offset
            for _,child in ipairs(Groups[name].ItemsHolder:GetChildren()) do
                if child:IsA("GuiObject") and child ~= Groups[name].ItemsList then
                    total = total + child.AbsoluteSize.Y + listPadding
                end
            end
            if total > 0 then total = total - listPadding end
            Groups[name]._setExpandedH(total)
            Groups[name]._expandNow()
        end)
    end

    return Groups[name]
end

function UI:AddSidebarItem(groupName, cfg)
    -- ensure group exists
    if not Groups[groupName] then
        UI:AddSidebarGroup(groupName)
    end
    local itemsHolder = Groups[groupName].ItemsHolder
    AddSideItem(itemsHolder, cfg)
    -- recalc expanded height for group
    local total = 0
    local listPadding = Groups[groupName].ItemsList.Padding.Offset
    for _,child in ipairs(itemsHolder:GetChildren()) do
        if child:IsA("GuiObject") and child ~= Groups[groupName].ItemsList then
            total += child.AbsoluteSize.Y + listPadding
        end
    end
    if total > 0 then total -= listPadding end
    Groups[groupName]._setExpandedH(total)
end

-- Section card creation (attached to any parent frame)
function UI:CreateSectionCard(parent)
    return CreateSectionCard(parent, nil)
end

-- Direct helpers
UI.MakeToggle = MakeToggle
UI.MakeSlider = MakeSlider

-- Window controls
function UI:Minimize()
    MinimizeWindow()
end
function UI:Restore()
    RestoreFromDock()
end
function UI:Maximize()
    MaximizeWindow()
end
function UI:RestoreWindow()
    RestoreWindow()
end

-- Search API
function UI:GetSearchBox()
    return SearchInput
end

-- Init: make minimal visible state
applySidebarLayout(SidebarState.ExpandedWidth)

-- Return UI object
print("LevelHub UI library loaded ✅")
return UI
