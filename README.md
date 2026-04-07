# LevelHub UI Library - Quick Start Guide

## 📋 บทนำ

**LevelHub UI Library** คือ Lua UI Library ที่ออกแบบมาสำหรับ Roblox games โดยมี UI components ที่สวยงามและใช้งานง่าย

## 🚀 วิธีใช้

### 1. โหลด UI Library

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/PigaloLido/levelhub-ui-lib/8ebe5945426b84e02bea6d6af991d06f92c5fb13/ui_lib.lua"))()
```

### 2. ตั้งค่า Title

```lua
UI:SetTitle("My App", "v1.0")
```

### 3. สร้างหน้า (Page)

```lua
local homePage = UI:CreatePage("Home")
```

## 📦 Components

### 🔲 Toggle (สวิตช์ เปิด/ปิด)

```lua
local section = homePage:CreateSectionCard()

section:AddToggleRow(
    "🔊",                    -- icon
    "Enable Sound",          -- title
    "เปิด/ปิดเสียง",         -- description
    true,                    -- default state
    function(state)          -- callback
        print("State:", state)
    end
)
```

**พารามิเตอร์:**
* `icon` - อักษรหรือ emoji สำหรับไอคอน
* `title` - ชื่อของ toggle
* `description` - คำอธิบาย
* `defaultState` - สถานะเริ่มต้น (true/false)
* `callback` - ฟังก์ชันเมื่อ toggle เปลี่ยน

### 🎚️ Slider (ปรับค่า)

```lua
section:AddSliderRow(
    "Volume",              -- title
    "ระดับเสียง",          -- description
    50,                    -- default value
    0,                     -- min value
    100,                   -- max value
    "%",                   -- unit (optional)
    function(value)        -- callback
        print("Value:", value)
    end
)
```

**พารามิเตอร์:**
* `title` - ชื่อ slider
* `description` - คำอธิบาย
* `defaultValue` - ค่าเริ่มต้น
* `minValue` - ค่าต่ำสุด
* `maxValue` - ค่าสูงสุด
* `unit` - หน่วยแสดง (ทำให้หรือไม่ก็ได้)
* `callback(value)` - ฟังก์ชันเมื่อค่าเปลี่ยน

### 🎯 Dropdown (เลือกจากรายการ)

```lua
section:AddDropdownRow(
    "Quality",                           -- title
    "เลือกคุณภาพ",                       -- description
    {"Low", "Medium", "High", "Ultra"}, -- options list
    2,                                  -- default index
    function(idx, opt)                  -- callback
        print("Selected:", opt, "Index:", idx)
    end
)
```

**พารามิเตอร์:**
* `title` - ชื่อ dropdown
* `description` - คำอธิบาย
* `options` - ตัวเลือก (table of strings)
* `defaultIndex` - ตัวเลือกเริ่มต้น (เริ่มนับที่ 1)
* `callback(index, option)` - ฟังก์ชันเมื่อเลือก

## 🎨 Structure

```lua
-- โหลด UI
local UI = loadstring(game:HttpGet("..."))()

-- ตั้ง Title
UI:SetTitle("LevelHub", "v1.0")

-- ============================================
-- สร้างหน้า
-- ============================================
local homePage = UI:CreatePage("Home")

-- เพิ่ม Header
homePage:AddStandaloneHeader("⚙️ Settings")

-- สร้าง Section Card
local section = homePage:CreateSectionCard()

-- เพิ่ม Components
section:AddToggleRow(...)
section:AddSliderRow(...)
section:AddDropdownRow(...)

-- ============================================
-- สร้าง Sidebar Navigation
-- ============================================
UI:AddSidebarGroup("Navigation", true)

UI:AddSidebarItem("Navigation", {
    name = "Home",
    icon = UI.ICON_SIDEBAR_ITEM,
    sub = "หน้าหลัก",
    onClick = function()
        UI:SetActiveTab("Home")
    end
})

-- ============================================
-- ตั้งหน้าแรก
-- ============================================
UI:SetActiveTab("Home")
```

## 💾 Complete Example

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/PigaloLido/levelhub-ui-lib/8ebe5945426b84e02bea6d6af991d06f92c5fb13/ui_lib.lua"))()

UI:SetTitle("LevelHub", "v1.0")

-- ============================================
-- หน้า Home
-- ============================================
local homePage = UI:CreatePage("Home")
homePage:AddStandaloneHeader("⚙️ Settings")

local settingsSection = homePage:CreateSectionCard()

settingsSection:AddToggleRow("🔊", "Enable Sound", "เปิด/ปิดเสียง", true, function(state)
    print("Sound:", state)
end)

settingsSection:AddSliderRow("Volume", "ระดับเสียง", 50, 0, 100, "%", function(value)
    print("Volume:", value)
end)

settingsSection:AddDropdownRow("Quality", "เลือกคุณภาพ", {"Low", "Medium", "High", "Ultra"}, 2, function(idx, opt)
    print("Quality:", opt)
end)

-- ============================================
-- หน้า About
-- ============================================
local aboutPage = UI:CreatePage("About")
aboutPage:AddStandaloneHeader("ℹ️ Information")

local aboutSection = aboutPage:CreateSectionCard()

aboutSection:AddToggleRow("📍", "Show Location", "แสดงตำแหน่ง", true, function(state)
    print("Location:", state)
end)

-- ============================================
-- Sidebar Navigation
-- ============================================
UI:AddSidebarGroup("Navigation", true)

UI:AddSidebarItem("Navigation", {
    name = "Home",
    icon = UI.ICON_SIDEBAR_ITEM,
    sub = "หน้าหลัก",
    onClick = function()
        UI:SetActiveTab("Home")
    end
})

UI:AddSidebarItem("Navigation", {
    name = "About",
    icon = UI.ICON_SIDEBAR_ITEM,
    sub = "เกี่ยวกับ",
    onClick = function()
        UI:SetActiveTab("About")
    end
})

UI:SetActiveTab("Home")

print("✅ LevelHub UI Loaded!")
```

## 🎮 Window Controls

| ปุ่ม | ฟังก์ชัน |
|------|----------|
| 🔴 Red Button | ปิด UI ทั้งหมด |
| 🟡 Yellow Button | ย่อ/แสดง UI |
| 🟢 Green Button | ขยาย/ปกติ UI |
| ☰ Hamburger | ซ่อน/แสดง Sidebar |

## 🔍 Search Feature

ใช้ Search Box ด้านบนขวาเพื่อค้นหา components ในหน้าปัจจุบัน

```lua
local searchBox = UI:GetSearchBox()
searchBox.Text = "search term"
```

## 🎯 API Reference

### Pages

```lua
UI:CreatePage(name)           -- สร้างหน้าใหม่
UI:SetActiveTab(tabName)      -- เปลี่ยนหน้า
```

### Sidebar

```lua
UI:AddSidebarGroup(name, expand)     -- สร้างกลุ่ม Sidebar
UI:AddSidebarItem(groupName, config) -- เพิ่มไอเทมใน Sidebar
```

### Window

```lua
UI:Minimize()       -- ย่อหน้าต่าง
UI:Restore()        -- แสดงหน้าต่าง
UI:Maximize()       -- ขยายหน้าต่าง
UI:RestoreWindow()  -- กลับเป็นปกติ
```

### UI Elements

```lua
UI:SetTitle(title, subtitle)  -- เปลี่ยน Title
UI:GetSearchBox()             -- เอา Search Input
UI:CreateSectionCard(parent)  -- สร้าง Section ใหม่
```

## ⚙️ ข้อกำหนด

✅ ต้องใช้ Roblox Script Executor (Synapse X, Script-Ware, Fluxus ฯลฯ)  
✅ ต้องเปิด `loadstring()` ใน Executor  
✅ ต้องออนไลน์เพื่อโหลด Library จาก GitHub  

## 📝 ตัวอย่างการใช้งาน

### ตัวอย่าง 1: Settings UI

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/PigaloLido/levelhub-ui-lib/8ebe5945426b84e02bea6d6af991d06f92c5fb13/ui_lib.lua"))()
UI:SetTitle("Game Settings", "v1.0")

local settingsPage = UI:CreatePage("Settings")
settingsPage:AddStandaloneHeader("⚙️ Gameplay")

local section = settingsPage:CreateSectionCard()

section:AddToggleRow("👥", "Show Players", "แสดงผู้เล่น", true, function(state)
    -- โค้ดของคุณ
end)

section:AddSliderRow("Speed", "ความเร็ว", 1, 1, 5, "x", function(value)
    -- โค้ดของคุณ
end)

UI:SetActiveTab("Settings")
```

### ตัวอย่าง 2: Multiple Pages

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/PigaloLido/levelhub-ui-lib/8ebe5945426b84e02bea6d6af991d06f92c5fb13/ui_lib.lua"))()

local home = UI:CreatePage("Home")
local settings = UI:CreatePage("Settings")
local about = UI:CreatePage("About")

-- เพิ่ม content ในแต่ละหน้า
home:CreateSectionCard():AddToggleRow(...)
settings:CreateSectionCard():AddSliderRow(...)
about:CreateSectionCard():AddDropdownRow(...)

UI:AddSidebarGroup("Menu", true)
UI:AddSidebarItem("Menu", {name="Home", sub="หน้าหลัก", onClick=function() UI:SetActiveTab("Home") end})
UI:AddSidebarItem("Menu", {name="Settings", sub="ตั้งค่า", onClick=function() UI:SetActiveTab("Settings") end})
UI:AddSidebarItem("Menu", {name="About", sub="เกี่ยวกับ", onClick=function() UI:SetActiveTab("About") end})

UI:SetActiveTab("Home")
```

## 🐛 Troubleshooting

### UI ไม่แสดงผล
✅ ตรวจสอบ Executor มีการเปิด `loadstring()`  
✅ ตรวจสอบว่าเชื่อมต่อ Internet แล้ว  
✅ รันใน Roblox Game ไม่ใช่ Studio  

### Search ไม่ทำงาน
✅ ตรวจสอบว่า Components มี Title และ Description  
✅ กด Enter หลังจากพิมพ์คำค้นหา  

### Components ไม่ตอบสนอง
✅ ตรวจสอบ Callback Function มีข้อผิดพลาดหรือไม่  
✅ ตรวจสอบ Console สำหรับข้อมูลข้อผิดพลาด  

## 📚 GitHub

Repository: https://github.com/PigaloLido/levelhub-ui-lib  
Author: PigaloLido  
License: MIT  

## 💡 Tips & Tricks

**ใช้ Emoji สำหรับ Icon**

```lua
section:AddToggleRow("🎮", "Title", "Desc", ...)
```

**ปรับแต่ง Title**

```lua
UI:SetTitle("Your Game", "Version 2.0")
```

**ซ่อน Sidebar**

```lua
-- คลิกปุ่ม Hamburger (☰) ด้านบน
```

**ใช้ Dropdown เป็นเมนู**

```lua
section:AddDropdownRow("Actions", "เลือกการกระทำ", {"Action 1", "Action 2"}, 1, function(idx, opt)
    if opt == "Action 1" then
        print("Action 1 executed")
    end
end)
```

Happy Scripting! 🎉
