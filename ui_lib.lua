-- ui_lib.lua
-- Lightweight UI helpers & section/card builders for Level Hub style
-- Export table UI for require() / loadstring() use

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

----------------------------------------------------------------
-- ICON CONFIG (ใช้เหมือนตัวหลัก)
----------------------------------------------------------------
local ICON_ARROW_RIGHT  = "rbxassetid://118483902647846"
local ICON_ARROW_DOWN   = "rbxassetid://74976956154520"

----------------------------------------------------------------
-- Smart parentGui detect
----------------------------------------------------------------
local function getParentGui()
    local plr = Players.LocalPlayer or Players:GetPlayers()[1]
    if plr and plr:FindFirstChild("PlayerGui") then
        return plr.PlayerGui
    end
    return game:GetService("CoreGui")
end

----------------------------------------------------------------
-- Primitive helpers
----------------------------------------------------------------
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
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = parent
    return c
end

local function Stroke(parent, color, thk)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(70,70,72)
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

----------------------------------------------------------------
-- Toggle component
----------------------------------------------------------------
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
        ZIndex = (parent.ZIndex or 1) + 1,
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

    return {
        Instance = ToggleBtn,
        Get = function() return state end,
        Set = function(v)
            state = v and true or false
            sync()
        end,
    }
end

----------------------------------------------------------------
-- Slider component
-- Display value 0..20 and also returns alpha 0..1
----------------------------------------------------------------
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
        ZIndex = (parent.ZIndex or 1) + 1,
    })
    Corner(Fill,999)

    local Handle = New("Frame", {
        Parent = Bar,
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BorderSizePixel = 0,
        Size = UDim2.new(0,18,0,18),
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(a,0,0.5,0),
        ZIndex = (parent.ZIndex or 1) + 2,
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
        Bar = Bar,
        GetAlpha = function() return a end,
        SetValue = function(v) -- v 0..20
            v = math.clamp(v,0,20)
            local alpha = v/20
            a = alpha
            Fill.Size = UDim2.new(a,0,1,0)
            Handle.Position = UDim2.new(a,0,0.5,0)
        end
    }
end

----------------------------------------------------------------
-- Standalone header (big text before card block)
----------------------------------------------------------------
local function AddStandaloneHeader(parent, titleText)
    local Header = New("Frame", {
        Parent = parent,
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1,0,0,0),
        ZIndex = 5,
    })

    New("TextLabel", {
        Parent = Header,
        BackgroundTransparency = 1,
        Font = Enum.Font.SourceSansBold,
        Text = titleText or "Header",
        TextColor3 = Color3.fromRGB(235,235,245),
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,0,0,20),
        ZIndex = 6,
    })

    return Header
end

----------------------------------------------------------------
-- Card builder
----------------------------------------------------------------
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
            Text = titleTxt or "Title",
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
            Text = descTxt or "Description",
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

        local toggleObj = MakeToggle(RightSide, defaultState, callback)

        New("Frame", {
            Parent = Row,
            BackgroundColor3 = Color3.fromRGB(60,60,62),
            BorderSizePixel = 0,
            Size = UDim2.new(1,0,0,1),
            Position = UDim2.new(0,0,1,-1),
            ZIndex = 6,
        })

        table.insert(rowsOutTable, {
            RowFrame = Row,
            Title    = TitleLbl,
            Desc     = DescLbl,
            Toggle   = toggleObj,
        })

        return toggleObj
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
            Text = (baseTitle or "Slider") .. " ( 0 )",
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

        local sliderObj = MakeSlider(RightSide, defaultAlpha or 0.5, function(value, alpha)
            TitleLbl.Text = (baseTitle or "Slider") .. " ( "..tostring(value).." )"
            if onChange then
                onChange(value, alpha)
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

        table.insert(rowsOutTable, {
            RowFrame = Row,
            Title    = TitleLbl,
            Desc     = DescLbl,
            Slider   = sliderObj,
        })

        return sliderObj
    end

    return API
end

----------------------------------------------------------------
-- Page builder
----------------------------------------------------------------
local function CreatePage(parent, name, isVisibleDefault)
    local Page = New("ScrollingFrame", {
        Parent = parent,
        Name = name or "Page",
        BackgroundColor3 = Color3.fromRGB(30,30,32),
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        Visible = (isVisibleDefault == true),
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Size = UDim2.new(1,0,1,0),
        Position = UDim2.new(0,0,0,0),
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

    return {
        Frame = Page,
        Rows  = {},
    }
end

----------------------------------------------------------------
-- Sidebar group / item builder
-- เราจะ handle active style (ปุ่มชมพู) ในนี้เลย
----------------------------------------------------------------
local function CreateSidebarGroup(parent, groupName)
    -- returns {GroupHeader, ItemsHolder, AddItem, TweenExpanded, SetExpandedInstant, RecalcHeight}

    local Holder = Instance.new("Frame")
    Holder.Name = groupName .. "_Group"
    Holder.Parent = parent
    Holder.BackgroundTransparency = 1
    Holder.Size = UDim2.new(1,-4,0,20)
    Holder.ZIndex = 4

    local HeaderBtn = Instance.new("TextButton")
    HeaderBtn.Parent = Holder
    HeaderBtn.BackgroundTransparency = 1
    HeaderBtn.BorderSizePixel = 0
    HeaderBtn.Size = UDim2.new(1,0,1,0)
    HeaderBtn.Text = ""
    HeaderBtn.AutoButtonColor = false
    HeaderBtn.ZIndex = 5

    local ArrowImg = Instance.new("ImageLabel")
    ArrowImg.Parent = HeaderBtn
    ArrowImg.BackgroundTransparency = 1
    ArrowImg.Size = UDim2.new(0,14,0,14)
    ArrowImg.Position = UDim2.new(1,-18,0,3)
    ArrowImg.Image = ICON_ARROW_DOWN
    ArrowImg.ImageColor3 = Color3.fromRGB(160,160,170)
    ArrowImg.ZIndex = 6

    local Title = Instance.new("TextLabel")
    Title.Parent = HeaderBtn
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0,0,0,0)
    Title.Size = UDim2.new(1,-24,1,0)
    Title.Font = Enum.Font.SourceSansBold
    Title.Text = groupName
    Title.TextColor3 = Color3.fromRGB(160,160,170)
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 6

    -- ItemsHolder แยกเป็นอีก Frame ถัดลงมา (layout ใน parent เดียวกับ Holder)
    local ItemsHolder = Instance.new("Frame")
    ItemsHolder.Parent = parent
    ItemsHolder.BackgroundTransparency = 1
    ItemsHolder.Size = UDim2.new(1,0,0,0)
    ItemsHolder.ClipsDescendants = true
    ItemsHolder.ZIndex = 4

    local ItemsList = Instance.new("UIListLayout")
    ItemsList.Parent = ItemsHolder
    ItemsList.Padding = UDim.new(0,2)
    ItemsList.SortOrder = Enum.SortOrder.LayoutOrder

    ----------------------------------------------------------------
    -- expand / collapse logic
    ----------------------------------------------------------------
    local collapsed = true
    local expandedHeight = 0
    local tweening = false

    local function recalcHeight()
        local total = 0
        local pad = ItemsList.Padding.Offset
        for _,child in ipairs(ItemsHolder:GetChildren()) do
            if child:IsA("GuiObject") and child ~= ItemsList then
                total += child.AbsoluteSize.Y + pad
            end
        end
        if total > 0 then
            total -= pad
        end
        expandedHeight = total
    end

    local function setExpandedInstant(open)
        collapsed = not open
        recalcHeight()
        if open then
            ItemsHolder.Size = UDim2.new(1,0,0,expandedHeight)
            ArrowImg.Rotation = 0
        else
            ItemsHolder.Size = UDim2.new(1,0,0,0)
            ArrowImg.Rotation = 90
        end
    end

    local function tweenExpanded(open)
        if tweening then return end
        tweening = true
        recalcHeight()

        local targetSize = open and UDim2.new(1,0,0,expandedHeight) or UDim2.new(1,0,0,0)
        local targetRot  = open and 0 or 90

        TweenService:Create(
            ItemsHolder,
            TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            { Size = targetSize }
        ):Play()

        TweenService:Create(
            ArrowImg,
            TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            { Rotation = targetRot }
        ):Play()

        task.delay(0.23,function()
            collapsed = not open
            tweening = false
        end)
    end

    HeaderBtn.MouseButton1Click:Connect(function()
        tweenExpanded(collapsed) -- toggle
    end)

    ----------------------------------------------------------------
    -- active state mgmt for sidebar items
    ----------------------------------------------------------------
    local currentActiveBtn = nil

    local function applyActive(btn, info, isActive)
        -- info.TitleLabel, info.SubLabel, info.Icon
        if isActive then
            btn.BackgroundColor3      = Color3.fromRGB(255,0,80)
            btn.BackgroundTransparency = 0
            if info.SubLabel then
                info.SubLabel.TextColor3 = Color3.fromRGB(255,255,255)
            end
            if info.Icon then
                info.Icon.ImageColor3 = Color3.fromRGB(255,255,255)
            end
        else
            btn.BackgroundColor3      = Color3.fromRGB(45,45,50)
            btn.BackgroundTransparency = 1
            if info.SubLabel then
                info.SubLabel.TextColor3 = Color3.fromRGB(160,160,170)
            end
            if info.Icon then
                info.Icon.ImageColor3 = Color3.fromRGB(255,0,80)
            end
        end
    end

    local function AddItem(cfg)
        -- cfg.name
        -- cfg.sub
        -- cfg.icon
        -- cfg.iconSize
        -- cfg.iconMarginLeft
        -- cfg.onClick(tabName)

        local tabName = cfg.name or "Tab"

        local ICON_SIZE        = cfg.iconSize or 18
        local ICON_LEFT_MARGIN = cfg.iconMarginLeft or 10
        local TEXT_GAP         = 8
        local BTN_HEIGHT       = 40

        local textStartX = ICON_LEFT_MARGIN + ICON_SIZE + TEXT_GAP

        local btn = Instance.new("TextButton")
        btn.Parent = ItemsHolder
        btn.Name = tabName
        btn.BorderSizePixel = 0
        btn.Size = UDim2.new(1,-4,0,BTN_HEIGHT)
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.ZIndex = 5
        Corner(btn,6)

        -- default inactive look
        btn.BackgroundColor3      = Color3.fromRGB(45,45,50)
        btn.BackgroundTransparency = 1

        local IconImg = Instance.new("ImageLabel")
        IconImg.Parent = btn
        IconImg.BackgroundTransparency = 1
        IconImg.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
        IconImg.Position = UDim2.new(0, ICON_LEFT_MARGIN, 0, math.floor((BTN_HEIGHT-ICON_SIZE)/2))
        IconImg.Image = cfg.icon or ""
        IconImg.ImageColor3 = Color3.fromRGB(255,0,80)
        IconImg.ZIndex = 6

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
        TitleLbl.Font = Enum.Font.SourceSansBold
        TitleLbl.Text = tabName
        TitleLbl.TextColor3 = Color3.fromRGB(255,255,255)
        TitleLbl.TextSize = 13
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        TitleLbl.ZIndex = 7

        local SubLbl = Instance.new("TextLabel")
        SubLbl.Parent = TxtBlock
        SubLbl.BackgroundTransparency = 1
        SubLbl.Size = UDim2.new(1,0,0,14)
        SubLbl.Position = UDim2.new(0,0,0,20)
        SubLbl.Font = Enum.Font.SourceSans
        SubLbl.Text = cfg.sub or ""
        SubLbl.TextSize = 11
        SubLbl.TextXAlignment = Enum.TextXAlignment.Left
        SubLbl.ZIndex = 7
        SubLbl.TextColor3 = Color3.fromRGB(160,160,170)

        local ArrowImg2 = Instance.new("ImageLabel")
        ArrowImg2.Parent = btn
        ArrowImg2.BackgroundTransparency = 1
        ArrowImg2.AnchorPoint = Vector2.new(1,0.5)
        ArrowImg2.Position = UDim2.new(1,-8,0.5,0)
        ArrowImg2.Size = UDim2.new(0,14,0,14)
        ArrowImg2.Image = ICON_ARROW_RIGHT
        ArrowImg2.ImageColor3 = Color3.fromRGB(255,255,255)
        ArrowImg2.ZIndex = 7

        -- hover effect (only when not active)
        btn.MouseEnter:Connect(function()
            if currentActiveBtn ~= btn then
                btn.BackgroundTransparency = 0
                btn.BackgroundColor3 = Color3.fromRGB(60,60,64)
            end
        end)
        btn.MouseLeave:Connect(function()
            if currentActiveBtn ~= btn then
                btn.BackgroundColor3 = Color3.fromRGB(45,45,50)
                btn.BackgroundTransparency = 1
            end
        end)

        btn.MouseButton1Click:Connect(function()
            -- update active ui styles
            if currentActiveBtn and currentActiveBtn ~= btn then
                local oldInfo = currentActiveBtn.__ui_info
                applyActive(currentActiveBtn, oldInfo, false)
            end
            currentActiveBtn = btn
            applyActive(btn, btn.__ui_info, true)

            -- callback to user (e.g. switch page)
            if cfg.onClick then
                cfg.onClick(tabName, btn, btn.__ui_info)
            end
        end)

        -- store info for active styling
        btn.__ui_info = {
            TitleLabel = TitleLbl,
            SubLabel   = SubLbl,
            Icon       = IconImg,
            Arrow      = ArrowImg2,
        }

        return btn
    end

    return {
        GroupHeader        = Holder,
        ItemsHolder        = ItemsHolder,
        AddItem            = AddItem,
        RecalcHeight       = recalcHeight,
        SetExpandedInstant = setExpandedInstant, -- open bool
        TweenExpanded      = tweenExpanded,      -- open bool
    }
end

----------------------------------------------------------------
-- Public API
----------------------------------------------------------------
local UI = {
    GetParentGui        = getParentGui,
    New                 = New,
    Corner              = Corner,
    Stroke              = Stroke,
    Hoverify            = Hoverify,

    MakeToggle          = MakeToggle,
    MakeSlider          = MakeSlider,

    AddStandaloneHeader = AddStandaloneHeader,
    CreateSectionCard   = CreateSectionCard,
    CreatePage          = CreatePage,

    CreateSidebarGroup  = CreateSidebarGroup,

    TweenService        = TweenService,
    UIS                 = UIS,
}

return UI
