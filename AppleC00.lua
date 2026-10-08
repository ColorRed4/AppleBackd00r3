--[[
    BROOKHAVEN PROP GUI
    Reworked from the uploaded Brookhaven prop mechanics.
    UI style follows the supplied c00lgui-style reference.

    Included prop operations:
      • Prop name/category selection
      • Spawn selected prop
      • Scan/select your spawned props
      • Duplicate selected prop
      • Move selected prop to your character
      • Move selected prop forward
      • Rotate selected prop
      • Set selected prop color
      • Clear all props
      • Refresh prop list
      • Mobile draggable main window + draggable Open/Close button

    This rewrite intentionally does NOT include player-targeting/admin-abuse
    actions from the source file (kidnap/kill/void/freeze/swap/etc.).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Remove only our previous copy
pcall(function()
    local old = PlayerGui:FindFirstChild("BrookhavenPropGui")
    if old then old:Destroy() end
end)

--// COLORS / STYLE OF THE SECOND SCRIPT
local BLACK = Color3.new(0, 0, 0)
local RED = Color3.fromRGB(170, 0, 0)
local WHITE = Color3.new(1, 1, 1)
local GREY = Color3.fromRGB(35, 35, 35)
local DARK_RED = Color3.fromRGB(90, 0, 0)
local FONT = Enum.Font.SourceSans

local gui = Instance.new("ScreenGui")
gui.Name = "BrookhavenPropGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PlayerGui

--// MOBILE/PC DRAG
local function makeDraggable(object, handle)
    handle = handle or object

    local dragging = false
    local dragStart
    local startPos
    local dragInput

    local function update(input)
        local delta = input.Position - dragStart
        object.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPos = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

--// MAIN WINDOW
local frame = Instance.new("Frame")
frame.Parent = gui
frame.BackgroundColor3 = BLACK
frame.BorderColor3 = RED
frame.BorderSizePixel = 3
frame.Name = "Frame"
frame.Position = UDim2.new(0, 3, 0.3, 0)
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Active = true

--// TITLE
local title = Instance.new("TextLabel")
title.Parent = frame
title.BackgroundColor3 = BLACK
title.BorderColor3 = RED
title.BorderSizePixel = 3
title.Name = "Title"
title.Position = UDim2.new(0, 0, 0, 0)
title.Size = UDim2.new(1, 0, 0, 40)
title.ZIndex = 2
title.Font = FONT
title.TextSize = 22
title.Text = "Brookhaven Props"
title.TextColor3 = WHITE
title.Active = true

makeDraggable(frame, title)

--// OPEN / CLOSE BUTTON
local toggle = Instance.new("TextButton")
toggle.Parent = gui
toggle.Active = true
toggle.AutoButtonColor = false
toggle.BackgroundColor3 = BLACK
toggle.BorderColor3 = RED
toggle.BorderSizePixel = 3
toggle.Name = "OpenClose"
toggle.Position = UDim2.new(0, 3, 0.3, 380)
toggle.Size = UDim2.new(0, 300, 0, 20)
toggle.ZIndex = 10
toggle.Font = FONT
toggle.TextSize = 18
toggle.Text = "Close"
toggle.TextColor3 = WHITE

makeDraggable(toggle)

toggle.MouseButton1Click:Connect(function()
    if frame.Visible then
        frame.Visible = false
        toggle.Text = "Open"
    else
        frame.Visible = true
        toggle.Text = "Close"
    end
end)

-- Keep toggle visually attached to the same X/Y when the main frame moves.
local lastFramePos = frame.Position
local syncing = false
UserInputService.InputChanged:Connect(function()
    if syncing then return end
    if frame.Position ~= lastFramePos then
        syncing = true
        local p = frame.Position
        toggle.Position = UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset + 380)
        lastFramePos = p
        syncing = false
    end
end)

--// PAGES
local pages = {}
for i = 1, 5 do
    local p = Instance.new("Frame")
    p.Parent = frame
    p.BackgroundColor3 = BLACK
    p.BorderColor3 = RED
    p.BorderSizePixel = 3
    p.Name = "Page" .. i
    p.Position = UDim2.new(0, 0, 0, 83)
    p.Size = UDim2.new(1, 0, 1, -106)
    p.ZIndex = 2
    p.Visible = (i == 1)
    pages[i] = p
end

local left = Instance.new("TextButton")
left.Parent = frame
left.BackgroundColor3 = BLACK
left.BorderColor3 = RED
left.BorderSizePixel = 3
left.Name = "<"
left.Position = UDim2.new(0, 0, 0, 40)
left.Size = UDim2.new(0.5, -3, 0, 40)
left.ZIndex = 2
left.Font = FONT
left.TextSize = 48
left.Text = "<"
left.TextColor3 = WHITE

local right = Instance.new("TextButton")
right.Parent = frame
right.BackgroundColor3 = BLACK
right.BorderColor3 = RED
right.BorderSizePixel = 3
right.Name = ">"
right.Position = UDim2.new(0.5, 3, 0, 40)
right.Size = UDim2.new(0.5, -3, 0, 40)
right.ZIndex = 2
right.Font = FONT
right.TextSize = 48
right.Text = ">"
right.TextColor3 = WHITE

local currentPage = 1

local function showPage(n)
    currentPage = math.clamp(n, 1, #pages)
    for i, p in ipairs(pages) do
        p.Visible = (i == currentPage)
    end
end

left.MouseButton1Click:Connect(function()
    showPage(currentPage == 1 and #pages or currentPage - 1)
end)

right.MouseButton1Click:Connect(function()
    showPage(currentPage == #pages and 1 or currentPage + 1)
end)

--// HELPERS
local function makeButton(parent, text, y, callback)
    local b = Instance.new("TextButton")
    b.Parent = parent
    b.BackgroundColor3 = BLACK
    b.BorderColor3 = RED
    b.BorderSizePixel = 2
    b.Position = UDim2.new(0, 5, 0, y)
    b.Size = UDim2.new(1, -10, 0, 30)
    b.Font = FONT
    b.TextSize = 18
    b.Text = text
    b.TextColor3 = WHITE
    b.AutoButtonColor = false
    b.MouseEnter:Connect(function()
        b.BackgroundColor3 = GREY
    end)
    b.MouseLeave:Connect(function()
        b.BackgroundColor3 = BLACK
    end)
    b.MouseButton1Click:Connect(function()
        if callback then
            pcall(callback)
        end
    end)
    return b
end

local function makeLabel(parent, text, y)
    local l = Instance.new("TextLabel")
    l.Parent = parent
    l.BackgroundColor3 = BLACK
    l.BorderColor3 = RED
    l.BorderSizePixel = 2
    l.Position = UDim2.new(0, 5, 0, y)
    l.Size = UDim2.new(1, -10, 0, 25)
    l.Font = FONT
    l.TextSize = 17
    l.Text = text
    l.TextColor3 = WHITE
    return l
end

local function makeBox(parent, placeholder, y, default)
    local box = Instance.new("TextBox")
    box.Parent = parent
    box.BackgroundColor3 = BLACK
    box.BorderColor3 = RED
    box.BorderSizePixel = 2
    box.Position = UDim2.new(0, 5, 0, y)
    box.Size = UDim2.new(1, -10, 0, 30)
    box.Font = FONT
    box.TextSize = 17
    box.PlaceholderText = placeholder
    box.Text = default or ""
    box.TextColor3 = WHITE
    box.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
    box.ClearTextOnFocus = false
    return box
end

local status = makeLabel(pages[1], "Status: ready", 0)

local function setStatus(s)
    status.Text = "Status: " .. tostring(s)
end

--// BROOKHAVEN REMOTES USED BY THE UPLOADED PROP CODE
local RE = ReplicatedStorage:FindFirstChild("RE")
local ToolRemote = RE and RE:FindFirstChild("1Too1l")
local ClearRemote = RE and RE:FindFirstChild("1Clea1rTool1s")

local function refreshRemotes()
    RE = ReplicatedStorage:FindFirstChild("RE")
    ToolRemote = RE and RE:FindFirstChild("1Too1l")
    ClearRemote = RE and RE:FindFirstChild("1Clea1rTool1s")
    return ToolRemote ~= nil and ClearRemote ~= nil
end

local selectedProp = nil
local propList = {}

local function getWorkspaceCom()
    return workspace:FindFirstChild("WorkspaceCom")
end

local function isOwnProp(p)
    if not p then return false end
    local myName = "Prop" .. LocalPlayer.Name
    return p.Name == myName or p.Name:find(LocalPlayer.Name, 1, true) ~= nil
end

local function getOwnProps()
    local wc = getWorkspaceCom()
    local result = {}

    if not wc then
        return result
    end

    for _, folder in ipairs(wc:GetChildren()) do
        for _, p in ipairs(folder:GetChildren()) do
            if isOwnProp(p) then
                table.insert(result, p)
            end
        end
    end

    return result
end

local function getPropRemote(prop, name)
    if not prop then return nil end
    return prop:FindFirstChild(name) or prop:FindFirstChildWhichIsA("RemoteFunction", true)
end

local function getPropCFrameRemote(prop)
    if not prop then return nil end
    return prop:FindFirstChild("SetCurrentCFrame")
        or prop:FindFirstChildWhichIsA("RemoteFunction", true)
end

local function getPropColorRemote(prop)
    if not prop then return nil end
    return prop:FindFirstChild("ChangePropColor")
end

local function getRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function selectFirstProp()
    local props = getOwnProps()
    propList = props
    selectedProp = props[1]
    return selectedProp
end

local function spawnProp(propName, category)
    if not refreshRemotes() then
        setStatus("Brookhaven remotes not found")
        return false
    end

    if propName == "" then
        setStatus("enter a prop name first")
        return false
    end

    local propMaker

    -- Same PropMaker acquisition route used by the uploaded file.
    if ToolRemote then
        pcall(function()
            ToolRemote:InvokeServer("PickingTools", "PropMaker")
        end)
        task.wait(0.25)
    end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character

    if char then
        propMaker = char:FindFirstChild("PropMaker")
    end
    if not propMaker and backpack then
        propMaker = backpack:FindFirstChild("PropMaker")
    end

    if not propMaker then
        setStatus("PropMaker was not received")
        return false
    end

    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and propMaker.Parent ~= char then
        pcall(function()
            hum:EquipTool(propMaker)
        end)
        task.wait(0.2)
    end

    local toolPropMake = propMaker:FindFirstChild("Tool_PropMake")
    if not toolPropMake then
        setStatus("Tool_PropMake not found")
        return false
    end

    if ClearRemote then
        pcall(function()
            ClearRemote:FireServer("OpenPropMenu")
        end)
        task.wait(0.15)

        pcall(function()
            ClearRemote:FireServer("RequestingPropName", propName, category)
        end)
        task.wait(0.2)
    end

    local before = {}
    local wc = getWorkspaceCom()

    if wc then
        for _, folder in ipairs(wc:GetChildren()) do
            for _, p in ipairs(folder:GetChildren()) do
                before[p] = true
            end
        end
    end

    local root = getRoot()
    local spawnPos = root and root.Position or Vector3.new(0, 5, 0)

    local ok = pcall(function()
        toolPropMake:FireServer(workspace.Terrain, spawnPos)
    end)

    if not ok then
        setStatus("spawn request failed")
        return false
    end

    -- Wait for the newly-created prop.
    local found
    local start = tick()

    while tick() - start < 4 do
        wc = getWorkspaceCom()

        if wc then
            for _, folder in ipairs(wc:GetChildren()) do
                for _, p in ipairs(folder:GetChildren()) do
                    if isOwnProp(p) and not before[p] then
                        found = p
                        break
                    end
                end
                if found then break end
            end
        end

        if found then break end
        task.wait(0.08)
    end

    if ClearRemote then
        pcall(function()
            if ToolRemote then
                ToolRemote:InvokeServer("PickingTools", "PropMaker")
            end
            ClearRemote:FireServer("ClosePropMenu")
        end)
    end

    if found then
        selectedProp = found
        setStatus("spawned: " .. found.Name)
        return true
    end

    setStatus("prop did not appear")
    return false
end

--// PAGE 1 — SPAWN
makeLabel(pages[1], "Prop name", 32)
local propNameBox = makeBox(pages[1], "Example: Block1", 58, "Block1")

makeLabel(pages[1], "Category", 93)
local categoryBox = makeBox(pages[1], "Example: Building", 119, "Building")

makeButton(pages[1], "Spawn Prop", 155, function()
    spawnProp(propNameBox.Text, categoryBox.Text)
end)

makeButton(pages[1], "Refresh / Select My Prop", 190, function()
    local p = selectFirstProp()
    if p then
        setStatus("selected: " .. p.Name)
    else
        setStatus("no own props found")
    end
end)

makeButton(pages[1], "Show Selected Prop", 225, function()
    if selectedProp and selectedProp.Parent then
        setStatus("selected: " .. selectedProp.Name)
    else
        setStatus("nothing selected")
    end
end)

--// PAGE 2 — TRANSFORM
makeLabel(pages[2], "Selected prop transform", 0)

makeButton(pages[2], "Move To Me", 35, function()
    if not selectedProp or not selectedProp.Parent then
        selectFirstProp()
    end

    local scf = getPropCFrameRemote(selectedProp)
    local root = getRoot()

    if not scf or not root then
        setStatus("selected prop / CFrame remote missing")
        return
    end

    pcall(function()
        scf:InvokeServer(root.CFrame)
    end)

    setStatus("moved to you")
end)

makeButton(pages[2], "Move 5 Studs Forward", 70, function()
    if not selectedProp or not selectedProp.Parent then
        selectFirstProp()
    end

    local scf = getPropCFrameRemote(selectedProp)
    local root = getRoot()

    if not scf or not root then
        setStatus("selected prop / CFrame remote missing")
        return
    end

    local cf = root.CFrame * CFrame.new(0, 0, -5)

    pcall(function()
        scf:InvokeServer(cf)
    end)

    setStatus("moved forward")
end)

makeButton(pages[2], "Rotate 90°", 105, function()
    if not selectedProp or not selectedProp.Parent then
        selectFirstProp()
    end

    local scf = getPropCFrameRemote(selectedProp)
    if not scf then
        setStatus("CFrame remote missing")
        return
    end

    local current = selectedProp:GetPivot()
    local newCF = current * CFrame.Angles(0, math.rad(90), 0)

    pcall(function()
        scf:InvokeServer(newCF)
    end)

    setStatus("rotated 90°")
end)

makeButton(pages[2], "Rotate 180°", 140, function()
    if not selectedProp or not selectedProp.Parent then
        selectFirstProp()
    end

    local scf = getPropCFrameRemote(selectedProp)
    if not scf then
        setStatus("CFrame remote missing")
        return
    end

    local current = selectedProp:GetPivot()
    local newCF = current * CFrame.Angles(0, math.rad(180), 0)

    pcall(function()
        scf:InvokeServer(newCF)
    end)

    setStatus("rotated 180°")
end)

makeButton(pages[2], "Refresh Selection", 175, function()
    local p = selectFirstProp()
    if p then
        setStatus("selected: " .. p.Name)
    else
        setStatus("no own props found")
    end
end)

--// PAGE 3 — DUPLICATION
makeLabel(pages[3], "Duplicate selected prop", 0)

local amountBox = makeBox(pages[3], "Amount (1-50)", 32, "1")

makeButton(pages[3], "Duplicate", 68, function()
    if not selectedProp or not selectedProp.Parent then
        selectFirstProp()
    end

    if not selectedProp then
        setStatus("no own prop selected")
        return
    end

    local remote = selectedProp:FindFirstChild("DuplicateProp")
    if not remote then
        setStatus("DuplicateProp remote missing")
        return
    end

    local amount = math.clamp(tonumber(amountBox.Text) or 1, 1, 50)

    for i = 1, amount do
        pcall(function()
            remote:InvokeServer()
        end)
        task.wait(0.08)
    end

    setStatus("duplicated x" .. amount)
end)

makeButton(pages[3], "Duplicate x5", 103, function()
    amountBox.Text = "5"
end)

makeButton(pages[3], "Duplicate x10", 138, function()
    amountBox.Text = "10"
end)

makeButton(pages[3], "Refresh Props", 173, function()
    local props = getOwnProps()
    propList = props

    if #props > 0 then
        selectedProp = props[1]
        setStatus("found " .. #props .. " own props")
    else
        selectedProp = nil
        setStatus("no own props")
    end
end)

--// PAGE 4 — COLOR
makeLabel(pages[4], "Prop color", 0)

local colorR = makeBox(pages[4], "Red 0-255", 32, "255")
local colorG = makeBox(pages[4], "Green 0-255", 67, "255")
local colorB = makeBox(pages[4], "Blue 0-255", 102, "255")

local colorPreview = Instance.new("Frame")
colorPreview.Parent = pages[4]
colorPreview.BackgroundColor3 = WHITE
colorPreview.BorderColor3 = RED
colorPreview.BorderSizePixel = 2
colorPreview.Position = UDim2.new(0, 5, 0, 137)
colorPreview.Size = UDim2.new(1, -10, 0, 25)

local function updatePreview()
    local r = math.clamp(tonumber(colorR.Text) or 255, 0, 255)
    local g = math.clamp(tonumber(colorG.Text) or 255, 0, 255)
    local b = math.clamp(tonumber(colorB.Text) or 255, 0, 255)
    colorPreview.BackgroundColor3 = Color3.fromRGB(r, g, b)
end

colorR:GetPropertyChangedSignal("Text"):Connect(updatePreview)
colorG:GetPropertyChangedSignal("Text"):Connect(updatePreview)
colorB:GetPropertyChangedSignal("Text"):Connect(updatePreview)

makeButton(pages[4], "Apply Color", 170, function()
    if not selectedProp or not selectedProp.Parent then
        selectFirstProp()
    end

    local cpc = getPropColorRemote(selectedProp)

    if not cpc then
        setStatus("ChangePropColor remote missing")
        return
    end

    local r = math.clamp(tonumber(colorR.Text) or 255, 0, 255)
    local g = math.clamp(tonumber(colorG.Text) or 255, 0, 255)
    local b = math.clamp(tonumber(colorB.Text) or 255, 0, 255)

    local color = Color3.fromRGB(r, g, b)

    pcall(function()
        cpc:InvokeServer(color)
    end)

    setStatus(("color: %d,%d,%d"):format(r, g, b))
end)

makeButton(pages[4], "Black", 205, function()
    colorR.Text = "0"
    colorG.Text = "0"
    colorB.Text = "0"
    updatePreview()
end)

makeButton(pages[4], "White", 240, function()
    colorR.Text = "255"
    colorG.Text = "255"
    colorB.Text = "255"
    updatePreview()
end)

--// PAGE 5 — CLEANUP / INFO
makeLabel(pages[5], "Prop cleanup", 0)

makeButton(pages[5], "Clear All Props", 35, function()
    if not refreshRemotes() or not ClearRemote then
        setStatus("clear remote not found")
        return
    end

    pcall(function()
        ClearRemote:FireServer("ClearAllProps")
    end)

    selectedProp = nil
    propList = {}
    setStatus("all props cleared")
end)

makeButton(pages[5], "Refresh Remotes", 70, function()
    if refreshRemotes() then
        setStatus("Brookhaven remotes found")
    else
        setStatus("required remotes not found")
    end
end)

makeButton(pages[5], "Select First Own Prop", 105, function()
    local p = selectFirstProp()
    if p then
        setStatus("selected: " .. p.Name)
    else
        setStatus("no own prop found")
    end
end)

makeLabel(
    pages[5],
    "Prop actions from source: spawn / CFrame / duplicate / color / clear",
    145
)

makeLabel(
    pages[5],
    "Mobile: drag the title or Close/Open button",
    175
)

-- Initial remote check
task.defer(function()
    if refreshRemotes() then
        setStatus("Brookhaven remotes ready")
    else
        setStatus("waiting for Brookhaven remotes")
    end
end)
