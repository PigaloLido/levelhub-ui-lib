-- ===== PUBLIC API EXPOSE =====
local LevelHubUI = {}

-- ให้สคริปต์ข้างนอกสร้างเพจใหม่ (แท็บใหม่) แบบหน้าปกติ + auto สร้างใน Pages + Sidebar
function LevelHubUI:AddTab(tabName, sidebarConfig)
    -- 1) สร้างเพจใหม่
    local newPage = CreatePage(tabName)

    -- 2) ใส่ header เริ่มต้นให้ไม่ว่างเปล่า
    AddStandaloneHeader(newPage.Frame, tabName)

    -- 3) เพิ่มปุ่มใน Sidebar group เดิม หรือกลุ่มใหม่
    --    สมมติ dev บอก groupName ผ่าน sidebarConfig.groupName
    --    ถ้าไม่ส่งมา ก็โยนเข้ากลุ่ม "Macro" เป็นค่าเริ่มต้น (หรือกลุ่มที่คุณอยากให้เป็น default)
    local groupName = (sidebarConfig and sidebarConfig.groupName) or "Macro"
    local subText   = (sidebarConfig and sidebarConfig.sub) or tabName
    local iconId    = (sidebarConfig and sidebarConfig.icon) or ICON_SIDEBAR_ITEM
    local iconSize  = (sidebarConfig and sidebarConfig.iconSize) or 32

    -- หา group holder ของชื่อ groupName ที่ BuildSidebar เคยสร้าง
    local groupData = Groups[groupName]
    if groupData then
        AddSideItem(groupData.ItemsHolder, {
            name = tabName,
            sub  = subText,
            icon = iconId,
            iconSize = iconSize,
        })

        -- อัปเดตความสูง expandedHeight ของ group นี้ใหม่ (เพื่อให้ animation หุบ/กาง ยังถูก)
        local total = 0
        local listPadding = groupData.ItemsList.Padding.Offset
        for _,child in ipairs(groupData.ItemsHolder:GetChildren()) do
            if child:IsA("GuiObject") and child ~= groupData.ItemsList then
                total += child.AbsoluteSize.Y + listPadding
            end
        end
        if total > 0 then
            total -= listPadding
        end
        groupData._setExpandedH(total)
    else
        warn("Group '"..groupName.."' not found for tab "..tabName)
    end

    return {
        PageData = newPage, -- {Frame=...,Rows={...}}
    }
end

-- ให้สคริปต์ข้างนอกสร้าง Card ใหม่ในเพจที่มีอยู่ แล้วเติม toggle/slider เหมือนโค้ดภายในคุณ
function LevelHubUI:AddCardToTab(tabName, cardTitle)
    local tabInfo = Pages[tabName]
    if not tabInfo then
        warn("Tab '"..tabName.."' not found.")
        return nil
    end

    -- header ด้านบน card
    AddStandaloneHeader(tabInfo.Frame, cardTitle or tabName)

    -- card + rows control
    local cardApi = CreateSectionCard(tabInfo.Frame, tabInfo.Rows)

    return {
        AddToggleRow = function(iconTxt, titleTxt, descTxt, defaultState, callback)
            -- สร้างแถว toggle แบบเดิม
            -- ต่างแค่เราต้อง pass callback เข้า MakeToggle
            -- โค้ดเดิมของคุณเรียก CardRoom:AddToggleRow(...) ซึ่งภายในใช้ MakeToggle() แต่ไม่มี callback ตอนนี้
            -- ดังนั้นเราจะ copy logic AddToggleRow ของคุณ แบบรวม callback เอง

            local Row = Instance.new("Frame")
            Row.Parent = tabInfo.Frame:FindFirstChild(cardTitle or tabName, true) or tabInfo.Frame -- fallback
            Row.BackgroundTransparency = 1
            Row.Size = UDim2.new(1,0,0,44)
            Row.ZIndex = 5

            local Left = Instance.new("Frame")
            Left.Parent = Row
            Left.BackgroundTransparency = 1
            Left.Size = UDim2.new(1,-80,1,0)
            Left.Position = UDim2.new(0,0,0,0)
            Left.ZIndex = 6

            local IconLbl = Instance.new("TextLabel")
            IconLbl.Parent = Left
            IconLbl.BackgroundTransparency = 1
            IconLbl.Size = UDim2.new(0,20,0,20)
            IconLbl.Position = UDim2.new(0,0,0,2)
            IconLbl.Font = Enum.Font.SourceSansBold
            IconLbl.Text = iconTxt or "◆"
            IconLbl.TextColor3 = Color3.fromRGB(255,255,255)
            IconLbl.TextSize = 16
            IconLbl.TextXAlignment = Enum.TextXAlignment.Left
            IconLbl.ZIndex = 7

            local TxtBlock = Instance.new("Frame")
            TxtBlock.Parent = Left
            TxtBlock.BackgroundTransparency = 1
            TxtBlock.Position = UDim2.new(0,24,0,0)
            TxtBlock.Size = UDim2.new(1,-24,1,0)
            TxtBlock.ZIndex = 7

            local TitleLbl = Instance.new("TextLabel")
            TitleLbl.Parent = TxtBlock
            TitleLbl.BackgroundTransparency = 1
            TitleLbl.Size = UDim2.new(1,0,0,18)
            TitleLbl.Font = Enum.Font.SourceSansBold
            TitleLbl.Text = titleTxt
            TitleLbl.TextColor3 = Color3.fromRGB(235,235,245)
            TitleLbl.TextSize = 17
            TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
            TitleLbl.ZIndex = 8

            local DescLbl = Instance.new("TextLabel")
            DescLbl.Parent = TxtBlock
            DescLbl.BackgroundTransparency = 1
            DescLbl.Size = UDim2.new(1,0,0,16)
            DescLbl.Position = UDim2.new(0,0,0,18)
            DescLbl.Font = Enum.Font.SourceSans
            DescLbl.Text = descTxt
            DescLbl.TextColor3 = Color3.fromRGB(180,180,185)
            DescLbl.TextSize = 14
            DescLbl.TextXAlignment = Enum.TextXAlignment.Left
            DescLbl.ZIndex = 8

            local RightSide = Instance.new("Frame")
            RightSide.Parent = Row
            RightSide.BackgroundTransparency = 1
            RightSide.AnchorPoint = Vector2.new(1,0.5)
            RightSide.Position = UDim2.new(1,0,0.5,0)
            RightSide.Size = UDim2.new(0,60,0,24)
            RightSide.ZIndex = 7

            -- ใช้ MakeToggle เดิมของคุณ ไม่แก้ MakeToggle
            MakeToggle(RightSide, defaultState, callback)

            local Sep = Instance.new("Frame")
            Sep.Parent = Row
            Sep.BackgroundColor3 = Color3.fromRGB(60,60,62)
            Sep.BorderSizePixel = 0
            Sep.Size = UDim2.new(1,0,0,1)
            Sep.Position = UDim2.new(0,0,1,-1)
            Sep.ZIndex = 6

            table.insert(tabInfo.Rows,{
                RowFrame = Row,
                Title    = TitleLbl,
                Desc     = DescLbl,
            })
        end,

        AddSliderRow = function(baseTitle, descTxt, defaultAlpha, onChange)
            -- เรียกของเดิมของคุณโดยตรงเลย
            cardApi:AddSliderRow(baseTitle, descTxt, defaultAlpha)

            -- note: AddSliderRow ดั้งเดิมของคุณ bind callback ภายในให้ update TitleLbl
            -- ถ้าคุณอยากได้ callback ฝั่งนอกด้วย ก็ต้องขยายฟังก์ชันต้นฉบับในอนาคต
            -- ตอนนี้เราจะไม่ฝืนแก้ logic ภายในไฟล์หลัก เพราะคุณบอก "ห้ามเปลี่ยนเด็ดขาด"
        end,
    }
end

-- ให้สคริปต์นอกสลับแท็บผ่าน public API
function LevelHubUI:SetTab(tabName)
    SetActiveTab(tabName)
end

-- dev ภายนอกอาจอยากเข้าถึง object พื้นฐาน (Pages, Gui, ...)
function LevelHubUI:GetPage(tabName)
    return Pages[tabName]
end

function LevelHubUI:GetGui()
    return Gui
end

return LevelHubUI
