--[[
    Brookhaven Remote Risk Scanner
    Diagnostic / defensive scanner.
    It does NOT execute, fire, invoke, or exploit discovered remotes.

    It scores objects using observable client-side indicators:
    - object type
    - suspicious naming
    - suspicious path/context
    - unusual parent containers
    - nearby script/module names
    - replication/accessibility context

    IMPORTANT:
    A score is NOT proof of a backdoor. Server-side code cannot be verified
    from a normal client-side scan.
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
if not player then return end

pcall(function()
    local old = CoreGui:FindFirstChild("RemoteRiskScanner")
    if old then old:Destroy() end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "RemoteRiskScanner"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
end

local function stroke(obj)
    local s = Instance.new("UIStroke")
    s.Thickness = 1.5
    s.Transparency = 0.15
    s.Color = Color3.fromRGB(120, 20, 20)
    s.Parent = obj
end

local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragStart
    local startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then return end

        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end)
end

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 440, 0, 430)
main.Position = UDim2.new(0.5, -220, 0.5, -215)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
main.Parent = gui
corner(main, 10)
stroke(main)
makeDraggable(main)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -110, 0, 42)
title.Position = UDim2.new(0, 15, 0, 4)
title.BackgroundTransparency = 1
title.Text = "REMOTE RISK SCANNER"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 36, 0, 32)
close.Position = UDim2.new(1, -43, 0, 7)
close.BackgroundColor3 = Color3.fromRGB(65, 10, 10)
close.Text = "×"
close.TextColor3 = Color3.new(1,1,1)
close.Font = Enum.Font.GothamBold
close.TextSize = 22
close.Parent = main
corner(close, 7)
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -30, 0, 35)
info.Position = UDim2.new(0, 15, 0, 47)
info.BackgroundTransparency = 1
info.Text = "Client-side diagnostic • no remote calls are executed"
info.TextColor3 = Color3.fromRGB(170,170,170)
info.Font = Enum.Font.Gotham
info.TextSize = 11
info.TextXAlignment = Enum.TextXAlignment.Left
info.Parent = main

local scanButton = Instance.new("TextButton")
scanButton.Size = UDim2.new(0, 125, 0, 36)
scanButton.Position = UDim2.new(0, 15, 0, 83)
scanButton.BackgroundColor3 = Color3.fromRGB(70, 12, 12)
scanButton.Text = "SCAN"
scanButton.TextColor3 = Color3.new(1,1,1)
scanButton.Font = Enum.Font.GothamBold
scanButton.TextSize = 14
scanButton.Parent = main
corner(scanButton, 7)

local filter = Instance.new("TextBox")
filter.Size = UDim2.new(0, 260, 0, 36)
filter.Position = UDim2.new(0, 150, 0, 83)
filter.BackgroundColor3 = Color3.fromRGB(22,22,22)
filter.PlaceholderText = "Search object / path..."
filter.Text = ""
filter.TextColor3 = Color3.new(1,1,1)
filter.PlaceholderColor3 = Color3.fromRGB(110,110,110)
filter.Font = Enum.Font.Gotham
filter.TextSize = 12
filter.ClearTextOnFocus = false
filter.Parent = main
corner(filter, 7)
stroke(filter)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -30, 0, 25)
status.Position = UDim2.new(0, 15, 0, 124)
status.BackgroundTransparency = 1
status.Text = "Ready."
status.TextColor3 = Color3.fromRGB(180,180,180)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -30, 0, 250)
list.Position = UDim2.new(0, 15, 0, 150)
list.BackgroundColor3 = Color3.fromRGB(8,8,8)
list.BorderSizePixel = 0
list.ScrollBarThickness = 5
list.CanvasSize = UDim2.new()
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.Parent = main
corner(list, 7)
stroke(list)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -30, 0, 22)
footer.Position = UDim2.new(0, 15, 1, -27)
footer.BackgroundTransparency = 1
footer.Text = "Scores indicate suspicion only — not confirmed vulnerabilities."
footer.TextColor3 = Color3.fromRGB(120,120,120)
footer.Font = Enum.Font.Gotham
footer.TextSize = 9
footer.Parent = main

local function lower(s)
    return string.lower(tostring(s or ""))
end

local suspiciousWords = {
    "backdoor", "admin", "loader", "inject", "execute",
    "executor", "command", "cmd", "require", "loadstring",
    "httpget", "getfenv", "setfenv", "server", "ss",
    "remote", "script", "permission"
}

local highWords = {
    "backdoor", "loadstring", "httpget", "getfenv",
    "setfenv", "inject", "executor"
}

local contextWords = {
    "admin", "command", "permission", "permissions",
    "loader", "server", "script", "control", "execute"
}

local function wordScore(name, words)
    local score = 0
    local hits = {}

    for _, word in ipairs(words) do
        if name:find(word, 1, true) then
            score += 1
            table.insert(hits, word)
        end
    end

    return score, hits
end

local function getRisk(obj)
    local score = 0
    local reasons = {}

    local n = lower(obj.Name)
    local full = lower(obj:GetFullName())

    local suspiciousCount, hits = wordScore(n, suspiciousWords)
    if suspiciousCount > 0 then
        score += math.min(20, suspiciousCount * 6)
        table.insert(reasons, "suspicious name: " .. table.concat(hits, ", "))
    end

    local highCount, highHits = wordScore(n, highWords)
    if highCount > 0 then
        score += math.min(30, highCount * 15)
        table.insert(reasons, "high-risk keyword: " .. table.concat(highHits, ", "))
    end

    local contextCount, contextHits = wordScore(full, contextWords)
    if contextCount > 0 then
        score += math.min(20, contextCount * 4)
        table.insert(reasons, "suspicious path context: " .. table.concat(contextHits, ", "))
    end

    if obj:IsA("RemoteFunction") then
        score += 8
        table.insert(reasons, "RemoteFunction requires server-side verification")
    elseif obj:IsA("RemoteEvent") then
        score += 4
        table.insert(reasons, "RemoteEvent requires server-side verification")
    elseif obj:IsA("ModuleScript") then
        score += 3
        table.insert(reasons, "ModuleScript is potentially security-relevant")
    elseif obj:IsA("Script") then
        score += 3
        table.insert(reasons, "server Script cannot be verified from client")
    elseif obj:IsA("LocalScript") then
        score += 1
    end

    local parent = obj.Parent
    if parent then
        local pn = lower(parent.Name)
        local pc, ph = wordScore(pn, contextWords)
        if pc > 0 then
            score += math.min(12, pc * 4)
            table.insert(reasons, "parent context: " .. table.concat(ph, ", "))
        end
    end

    -- Do not pretend this proves a backdoor.
    score = math.clamp(score, 0, 100)

    local level
    if score >= 70 then
        level = "HIGH"
    elseif score >= 40 then
        level = "MEDIUM"
    elseif score >= 15 then
        level = "LOW"
    else
        level = "INFO"
    end

    return score, level, reasons
end

local function clear()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
end

local results = {}

local function addResult(obj, score, level, reasons)
    local card = Instance.new("TextButton")
    card.Size = UDim2.new(1, -10, 0, 76)
    card.BackgroundColor3 = Color3.fromRGB(18,18,18)
    card.Text = ""
    card.AutoButtonColor = true
    card.Parent = list
    corner(card, 6)

    local head = Instance.new("TextLabel")
    head.Size = UDim2.new(1, -20, 0, 22)
    head.Position = UDim2.new(0, 10, 0, 5)
    head.BackgroundTransparency = 1
    head.Text = string.format("[%s] %d/100  %s", level, score, obj.Name)
    head.TextColor3 =
        level == "HIGH" and Color3.fromRGB(255,90,90)
        or level == "MEDIUM" and Color3.fromRGB(255,180,70)
        or level == "LOW" and Color3.fromRGB(220,220,120)
        or Color3.fromRGB(180,180,180)
    head.Font = Enum.Font.GothamBold
    head.TextSize = 12
    head.TextXAlignment = Enum.TextXAlignment.Left
    head.Parent = card

    local path = Instance.new("TextLabel")
    path.Size = UDim2.new(1, -20, 0, 20)
    path.Position = UDim2.new(0, 10, 0, 27)
    path.BackgroundTransparency = 1
    path.Text = obj:GetFullName()
    path.TextColor3 = Color3.fromRGB(150,150,150)
    path.Font = Enum.Font.Code
    path.TextSize = 9
    path.TextTruncate = Enum.TextTruncate.AtEnd
    path.TextXAlignment = Enum.TextXAlignment.Left
    path.Parent = card

    local why = Instance.new("TextLabel")
    why.Size = UDim2.new(1, -20, 0, 20)
    why.Position = UDim2.new(0, 10, 0, 49)
    why.BackgroundTransparency = 1
    why.Text = reasons[1] or "No strong client-side indicator"
    why.TextColor3 = Color3.fromRGB(185,185,185)
    why.Font = Enum.Font.Gotham
    why.TextSize = 9
    why.TextTruncate = Enum.TextTruncate.AtEnd
    why.TextXAlignment = Enum.TextXAlignment.Left
    why.Parent = card

    card.MouseButton1Click:Connect(function()
        pcall(function()
            setclipboard(obj:GetFullName())
        end)
        status.Text = "Copied: " .. obj:GetFullName()
    end)
end

local function shouldInclude(obj)
    return obj:IsA("RemoteEvent")
        or obj:IsA("RemoteFunction")
        or obj:IsA("BindableEvent")
        or obj:IsA("BindableFunction")
        or obj:IsA("ModuleScript")
        or obj:IsA("Script")
        or obj:IsA("LocalScript")
end

local function runScan()
    clear()
    results = {}

    status.Text = "Scanning..."
    scanButton.Text = "SCANNING..."

    task.wait()

    local all = game:GetDescendants()
    local scanned = 0

    for _, obj in ipairs(all) do
        if shouldInclude(obj) then
            scanned += 1

            local score, level, reasons = getRisk(obj)

            -- Show anything with an actual signal.
            if score >= 15 then
                table.insert(results, {
                    obj = obj,
                    score = score,
                    level = level,
                    reasons = reasons
                })
            end
        end
    end

    table.sort(results, function(a,b)
        return a.score > b.score
    end)

    local query = lower(filter.Text)
    local shown = 0

    for _, r in ipairs(results) do
        local path = lower(r.obj:GetFullName())
        local name = lower(r.obj.Name)

        if query == "" or path:find(query, 1, true) or name:find(query, 1, true) then
            addResult(r.obj, r.score, r.level, r.reasons)
            shown += 1
        end
    end

    status.Text = string.format(
        "Scanned %d objects • %d suspicious candidates",
        scanned,
        shown
    )

    scanButton.Text = "SCAN"
end

scanButton.MouseButton1Click:Connect(runScan)

filter:GetPropertyChangedSignal("Text"):Connect(function()
    if #results == 0 then return end

    clear()

    local query = lower(filter.Text)
    local shown = 0

    for _, r in ipairs(results) do
        local path = lower(r.obj:GetFullName())
        local name = lower(r.obj.Name)

        if query == "" or path:find(query, 1, true) or name:find(query, 1, true) then
            addResult(r.obj, r.score, r.level, r.reasons)
            shown += 1
        end
    end

    status.Text = string.format("Filtered: %d candidates", shown)
end)

-- Initial scan
task.spawn(function()
    task.wait(0.5)
    runScan()
end)
