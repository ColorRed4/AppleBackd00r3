-- Exact source-derived Prop engine from AppleLoaderXZ.lua.
local _Players = game:GetService("Players")
local _lp = _Players.LocalPlayer
local _Vector3New = Vector3.new
local _CFrameNew = CFrame.new
local _CFrameAngles = CFrame.Angles
local _abs = math.abs

local PropStateManager = {
    CurrentSession = 0,
    ActiveCategory = nil,
    IsBusy = false,
    LastToggleTime = 0
}

function PropStateManager.newSession(categoryName)
    PropStateManager.CurrentSession = PropStateManager.CurrentSession + 1
    PropStateManager.ActiveCategory = categoryName
    PropStateManager.LastToggleTime = tick()
    return PropStateManager.CurrentSession
end

function PropStateManager.isCurrent(sessionId)
    return PropStateManager.CurrentSession == sessionId
end

function PropStateManager.canToggle()
    local now = tick()
    if now - PropStateManager.LastToggleTime < 0.15 then
        return false 
    end
    PropStateManager.LastToggleTime = now
    return true
end

function PropStateManager.forceGlobalCleanup()
    pcall(function()
        local lp = game:GetService("Players").LocalPlayer
        local char = lp and lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:UnequipTools() end
    end)
    pcall(function()
        local RE = game:GetService("ReplicatedStorage"):FindFirstChild("RE")
        local clr = RE and RE:FindFirstChild("1Clea1rTool1s")
        if clr then
            clr:FireServer("ClearAllTools")
            clr:FireServer("ClosePropMenu")
        end
    end)
end

    
    
    
    
    
    local function _0xH_3f1()
        local lp = game:GetService("Players").LocalPlayer
        if not lp then return end
        local RE = game:GetService("ReplicatedStorage"):FindFirstChild("RE")
        pcall(function()
            local clr = RE and RE:FindFirstChild("1Clea1rTool1s")
            if clr then
                clr:FireServer("ClearAllTools")
                clr:FireServer("ClosePropMenu")
                clr:FireServer("ClosePropMenu")
            end
        end)
        pcall(function()
            local char = lp.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum:UnequipTools() end
        end)
        pcall(function()
            local toolRemote = RE and RE:FindFirstChild("1Too1l")
            local tool = (lp.Character and lp.Character:FindFirstChild("PropMaker")) or (lp.Backpack and lp.Backpack:FindFirstChild("PropMaker"))
            if tool then
                if toolRemote then
                    pcall(function() toolRemote:InvokeServer("PickingTools", "PropMaker") end)
                end
                pcall(function() tool:Destroy() end)
            end
        end)
    end

local function _0xH_3f2()
    local lp = game:GetService("Players").LocalPlayer
    if not lp then return nil end
    local backpack = lp:FindFirstChild("Backpack")
    local character = lp.Character
    if not backpack or not character then return nil end
    local tool = character:FindFirstChild("PropMaker") or backpack:FindFirstChild("PropMaker")
    if not tool then
        local RE = game:GetService("ReplicatedStorage"):FindFirstChild("RE")
        local toolRemote = RE and RE:FindFirstChild("1Too1l")
        if toolRemote then
            pcall(function() toolRemote:InvokeServer("PickingTools", "PropMaker") end)
            local start = tick()
            while tick() - start < 1.5 do
                tool = character:FindFirstChild("PropMaker") or backpack:FindFirstChild("PropMaker")
                if tool then break end
                task.wait(0.03)
            end
        end
    end
    if tool and tool.Parent ~= character then
        local hum = character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:EquipTool(tool)
            local eqStart = tick()
            while tick() - eqStart < 1 do
                if tool.Parent == character then break end
                task.wait(0.03)
            end
        end
    end
    return tool
end

local function _0xH_3f3(firstProp, countNeeded, delayBetween)
    if not firstProp then return false end
    local dupRemote = firstProp:FindFirstChild("DuplicateProp") or firstProp:WaitForChild("DuplicateProp", 1.5)
    if not dupRemote then return false end

    for i = 1, countNeeded do
        pcall(function() dupRemote:InvokeServer() end)
        if delayBetween and delayBetween > 0 then
            task.wait(delayBetween)
        end
    end
    return true
end

local function _0xH_3f4(toolPropMake, spawnPos, totalCount, delayBetween)
    local lp = game:GetService("Players").LocalPlayer
    if not lp or not toolPropMake then return false end
    local myPropName = "Prop" .. lp.Name
    local wc = workspace:FindFirstChild("WorkspaceCom")
    if not wc then return false end

    local existingProps = {}
    for _, folder in pairs(wc:GetChildren()) do
        for _, prop in pairs(folder:GetChildren()) do
            if prop.Name == myPropName then
                existingProps[prop] = true
            end
        end
    end

    pcall(function() toolPropMake:FireServer(workspace.Terrain, spawnPos) end)

    local firstProp = nil
    local t0 = tick()
    while tick() - t0 < 3.0 do
        for _, folder in pairs(wc:GetChildren()) do
            for _, prop in pairs(folder:GetChildren()) do
                if prop.Name == myPropName and not existingProps[prop] then
                    firstProp = prop
                    break
                end
            end
            if firstProp then break end
        end
        if firstProp then break end
        task.wait(0.05)
    end

    if not firstProp then return false end

    if totalCount and totalCount > 1 then
        return _0xH_3f3(firstProp, totalCount - 1, delayBetween)
    end
    return true
end

                                                                 

_G.TrollTarget = nil
_G.TrollTargetDest = "---"
_G.SelectedPropName = "FurnitureToilet"
_G.SelectedPropCategory = "Furniture"
_G.AutoLoopTroll = false
_G.BringMethod = "Smart"

_G.BringToiletCount = 1
local bringToiletCount = 1

_0xH_43c = {}
_0xH_43c.Active = false
_0xH_43c.Target = nil
_0xH_43c.SessionId = 0
_0xH_43c.StopCounter = 0

function _0xH_43c.stop()
    _0xH_43c.StopCounter = _0xH_43c.StopCounter + 1
    if _0xH_43c.Stopping then
        
        
        _0xH_43c.Active = false
        _0xH_43c.Target = nil
        return
    end
    _0xH_43c.Stopping = true
    _0xH_43c.Active = false
    _0xH_43c.Target = nil
    if _0xH_43c.CurrentToggle then
        local oldToggle = _0xH_43c.CurrentToggle
        _0xH_43c.CurrentToggle = nil
        pcall(function() oldToggle:Set(false) end)
    end
    local eu = game:GetService("Players").LocalPlayer
    if workspace.CurrentCamera and eu.Character and eu.Character:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = eu.Character.Humanoid
    end
                                                                                                    
    local RE = game:GetService("ReplicatedStorage"):FindFirstChild("RE")
    if RE then
        local clearRemote = RE:FindFirstChild("1Clea1rTool1s")
        if clearRemote then pcall(function() clearRemote:FireServer("ClearAllProps") end) end
        task.wait(0.2)
        local toolRemote = RE:FindFirstChild("1Too1l")
        
    end
    
    
    task.wait(0.1)
    local myChar = eu.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if myHum then pcall(function() myHum:UnequipTools() end) end
    local myRE = game:GetService("ReplicatedStorage"):FindFirstChild("RE")
    if myRE then
        local clr = myRE:FindFirstChild("1Clea1rTool1s")
        if clr then pcall(function() clr:FireServer("ClosePropMenu") end) end
    end
    _0xH_3f1()
    
    if _G.AdminStopAll then pcall(_G.AdminStopAll) end
    _0xH_43c.Stopping = false
end

function _0xH_43c.bringPlayer(targetPlayer, actionType, noCamera, callerName, flySpeed)
    
    
    
    local stopCounterAtStart = _0xH_43c.StopCounter
    local spamGuard = 0
    while _0xH_43c.Stopping and spamGuard < 40 do
        task.wait(0.05)
        spamGuard = spamGuard + 1
    end
    
    
    if _0xH_43c.Stopping or _0xH_43c.StopCounter ~= stopCounterAtStart then return end
    if not targetPlayer or not targetPlayer.Character then return end
    if _0xH_43c.Active then
        _0xH_43c.Stopping = true
        _0xH_43c.Active = false
        _0xH_43c.Target = nil
        _0xH_43c.SessionId = _0xH_43c.SessionId + 1
        local RE2 = game:GetService("ReplicatedStorage"):FindFirstChild("RE")
        if RE2 then
            local ct2 = RE2:FindFirstChild("1Too1l")
            
        end
        _0xH_3f1()
        _0xH_43c.Stopping = false
        task.wait(0.1)
    end
    _0xH_43c.SessionId = _0xH_43c.SessionId + 1
    local mySession = _0xH_43c.SessionId
    _0xH_43c.Active = true
    _0xH_43c.Target = targetPlayer
    _0xH_43c.CurrentAction = actionType
    _0xH_43c.FlySpeed = (tonumber(flySpeed) and tonumber(flySpeed) > 0) and tonumber(flySpeed) or 65.0

    local eu = game:GetService("Players").LocalPlayer
    local tchar = targetPlayer.Character
    local thum = tchar:FindFirstChild("Humanoid")
    local troot = tchar:FindFirstChild("HumanoidRootPart")
    if not thum or not troot then return end

    if not noCamera and not _G.AutoLoopTroll and actionType ~= "Fly" and workspace.CurrentCamera then
        workspace.CurrentCamera.CameraSubject = thum
    end

    local character = eu.Character or eu.CharacterAdded:Wait()
    local RE = game:GetService("ReplicatedStorage"):WaitForChild("RE")
    local clearTools = RE:WaitForChild("1Clea1rTool1s")
    
    
    local propsTool = _0xH_3f2()
    if not propsTool then
        _0xH_43c.stop()
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:EquipTool(propsTool)
        local startEq = tick()
        while tick() - startEq < 2 do
            if propsTool.Parent == character then break end
            task.wait(0.05)
        end
    end

    pcall(function() clearTools:FireServer("OpenPropMenu") end)
    task.wait(0.2)

    local propName
    local propCategory = "Furniture"
    if actionType == "Fly" then
        propName = "FurnitureBeanBag"
    elseif callerName then
        
        propName = "FurnitureToilet"
        propCategory = "Furniture"
    else
        
        propName = _G.SelectedPropName or "FurnitureToilet"
        propCategory = _G.SelectedPropCategory or "Furniture"
    end
    pcall(function() clearTools:FireServer("RequestingPropName", propName, propCategory) end)
    task.wait(0.3)

    
    local toolPropMake = propsTool:FindFirstChild("Tool_PropMake")
    local waitStart = tick()
    while not toolPropMake and tick() - waitStart < 6 and _0xH_43c.SessionId == mySession do
        toolPropMake = propsTool:FindFirstChild("Tool_PropMake")
        if not toolPropMake then
            local bpTool = character.Parent and character.Parent:FindFirstChild("Backpack") and character.Parent.Backpack:FindFirstChild("PropMaker")
            if bpTool then toolPropMake = bpTool:FindFirstChild("Tool_PropMake") end
        end
        if not toolPropMake then task.wait(0.1) end
    end
    if toolPropMake then
        local myRoot = character:FindFirstChild("HumanoidRootPart")
        local myPos = myRoot and myRoot.Position or _Vector3New(0,0,0)
        local countToSpawn = math.clamp(_G.BringToiletCount or bringToiletCount or 1, 1, 15)

        local curChar = eu.Character
        local curHum = curChar and curChar:FindFirstChildOfClass("Humanoid")
        if curHum and propsTool.Parent ~= curChar then
            pcall(function() curHum:EquipTool(propsTool) end)
            task.wait(0.1)
        end

        local spawnPos = myPos + _Vector3New(0, 0, -2)
        local spawned = _0xH_3f4(toolPropMake, spawnPos, countToSpawn, 0)
        if not spawned then
            pcall(function() toolPropMake:FireServer(workspace.Terrain, spawnPos) end)
        end
    else
        return
    end

    
    if _0xH_43c.SessionId ~= mySession or not _0xH_43c.Active then return end

    
    task.spawn(function()
        pcall(function() local h = eu.Character and eu.Character:FindFirstChildOfClass("Humanoid"); if h then h:UnequipTools() end end)
        task.wait(1.0)
        pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Too1l"):InvokeServer("PickingTools", "PropMaker") end)
        _0xH_3f1()
    end)

    task.spawn(function()
        local myPropName = "Prop" .. eu.Name
        local loopSession = mySession
        
        
        
        local bringSenders = {} 
        
        
        
        local bringSendHalted = false
        local function _0xH_3ef(_0xSRF, _0xCF_IN)
            local _0xQ_MAP = { 10, 20, 30, 40 }
            local _0xQ_PC = 1
            local _0xENT

            while _0xQ_PC ~= 0 do
                local _0xOP = _0xQ_MAP[_0xQ_PC]
                if _0xOP == 10 then
                    if not _0xH_43c.Active or bringSendHalted then return end
                    _0xENT = bringSenders[_0xSRF]
                    _0xQ_PC = _0xENT and 3 or 2
                elseif _0xOP == 20 then
                    _0xENT = { lastCF = nil, dirty = false }
                    _0xENT.thread = task.spawn(function()
                        while _0xH_43c.Active do
                            task.wait(0.025)
                            if not _0xH_43c.Active then return end
                            if bringSendHalted then
                                _0xENT.dirty = false
                                _0xENT.lastCF = nil
                            elseif _0xENT.dirty and _0xENT.lastCF then
                                _0xENT.dirty = false
                                pcall(function() _0xSRF:InvokeServer(_0xENT.lastCF) end)
                            end
                        end
                    end)
                    bringSenders[_0xSRF] = _0xENT
                    _0xQ_PC = 4
                elseif _0xOP == 30 then
                    _0xQ_PC = 4
                elseif _0xOP == 40 then
                    _0xENT.lastCF = _0xCF_IN
                    _0xENT.dirty = true
                    _0xQ_PC = 0
                else
                    _0xQ_PC = 0
                end
            end
        end

        
        
        
        
        
        local function antiRollbackHammer(scfRef, destCF)
            local hammerStart = tick()
            while tick() - hammerStart < 0.6 do
                if not _0xH_43c.Active then return false end
                pcall(function() scfRef:InvokeServer(destCF) end)
                task.wait(0.025)
            end
            return true
        end

        
        
        
        
        local function _0xH_3f0(scfRef, getPosFn, duration)
            local hammerStart = tick()
            while tick() - hammerStart < (duration or 0.6) do
                if not _0xH_43c.Active then return false end
                local p = getPosFn()
                if p then pcall(function() scfRef:InvokeServer(p) end) end
                task.wait(0.025)
            end
            return true
        end

        
        local predictedVel = _Vector3New(0, 0, 0)
        local lastSamplePos = nil
        local lastSampleTime = tick()
        local phase1Props = nil
        local phase1PropsExpired = 0
        local flyPos = nil
        local flyHeading = nil
        local flyLastTick = nil
        local flySlot1Tool = nil
        local flySlot2Tool = nil
        local hasEverSeatedFly = false
        local flySenderThread = nil
        local flySenderThreadScf = nil
        local flySenderCF = nil

        while _0xH_43c.Active and _0xH_43c.Target == targetPlayer and _0xH_43c.SessionId == loopSession do
            repeat 
            local char = targetPlayer.Character
            local currentTargetRoot = char and char:FindFirstChild("HumanoidRootPart")
            local targetHum = char and char:FindFirstChild("Humanoid")

            if not currentTargetRoot or not targetHum or targetHum.Health <= 0 then
                if _G.AutoLoopTroll and actionType ~= "Fly" and targetPlayer:IsDescendantOf(game:GetService("Players")) then
                    local respawned = false
                    local startTime = os.clock()
                    while os.clock() - startTime < 15 do
                        task.wait(0.1)
                        if not targetPlayer:IsDescendantOf(game:GetService("Players")) then break end
                        if not _G.AutoLoopTroll then break end
                        local c = targetPlayer.Character
                        local h = c and c:FindFirstChild("Humanoid")
                        local r = c and c:FindFirstChild("HumanoidRootPart")
                        if c and h and r and h.Health > 0 then respawned = true break end
                    end
                    if respawned and _G.AutoLoopTroll and _0xH_43c.CurrentAction then
                        
                        task.wait(0.4)
                        task.spawn(function()
                            _0xH_43c.bringPlayer(targetPlayer, _0xH_43c.CurrentAction, noCamera, callerName, flySpeed)
                        end)
                        return
                    end
                else
                    if _0xH_43c.CurrentToggle then pcall(function() _0xH_43c.CurrentToggle:Set(false) end) end
                end
                break
            end

            local myRoot = eu.Character and eu.Character:FindFirstChild("HumanoidRootPart")
            if callerName then
                local cp = game:GetService("Players"):FindFirstChild(callerName)
                if cp and cp.Character and cp.Character:FindFirstChild("HumanoidRootPart") then
                    myRoot = cp.Character.HumanoidRootPart
                end
            end
            if not targetHum or not myRoot then break end

            
            if not (targetHum.Sit and targetHum.SeatPart and targetHum.SeatPart:FindFirstAncestor(myPropName)) then
                if actionType == "Fly" and hasEverSeatedFly then
                    pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllProps") end)
                    if _0xH_43c.CurrentToggle then
                        pcall(function() _0xH_43c.CurrentToggle:Set(false) end)
                    end
                    _0xH_43c.stop()
                    break
                end
                
                if not phase1Props or phase1PropsExpired < tick() then
                    phase1Props = {}
                    pcall(function()
                        local wc = workspace:FindFirstChild("WorkspaceCom")
                        if wc then
                            for _, folder in pairs(wc:GetChildren()) do
                                for _, prop in pairs(folder:GetChildren()) do
                                    if prop.Name == myPropName then
                                        local scf = prop:FindFirstChild("SetCurrentCFrame")
                                        if scf then table.insert(phase1Props, scf) end
                                    end
                                end
                            end
                        end
                    end)
                    phase1PropsExpired = tick() + 0.5
                end
                local currentProps = phase1Props

                if #currentProps > 0 then
                
                
                
                local nowS = tick()
                if not lastSamplePos then
                    lastSamplePos = currentTargetRoot.Position
                    lastSampleTime = nowS
                else
                    local dtS = nowS - lastSampleTime
                    if dtS >= 0.03 then
                        local measuredVel = (currentTargetRoot.Position - lastSamplePos) / dtS
                        predictedVel = predictedVel:Lerp(measuredVel, 0.6)
                        lastSamplePos = currentTargetRoot.Position
                        lastSampleTime = nowS
                    end
                end
                
                
                
                
                
                local speed = predictedVel.Magnitude
                local leadTime = (speed > 40) and 0.35 or ((speed > 15) and 0.20 or 0.08)
                local feetOffset = 2.5
                if targetHum.HipHeight and targetHum.HipHeight > 0 then
                    feetOffset = targetHum.HipHeight + 0.8
                elseif targetHum.RigType == Enum.HumanoidRigType.R6 then
                    feetOffset = 3.0
                end
                local isAirborne = (targetHum:GetState() == Enum.HumanoidStateType.Jumping or targetHum:GetState() == Enum.HumanoidStateType.Freefall or _abs(predictedVel.Y) > 5)

                for i, scf in ipairs(currentProps) do
                    local targetCF
                    if targetHum.Sit and targetHum.SeatPart then
                        targetCF = _CFrameNew(targetHum.SeatPart.Position + _Vector3New(0, 0.5, 0))
                    elseif _G.SelectedPropName == "FuturisticLargeBed" then
                        
                        local forwardBackSwing = _sin(tick() * 18) * 1.6
                        local targetLook = currentTargetRoot.CFrame.LookVector
                        local bedPos = currentTargetRoot.Position + (predictedVel * leadTime) + (targetLook * forwardBackSwing)
                        targetCF = _CFrameNew(bedPos.X, currentTargetRoot.Position.Y - 0.3, bedPos.Z)
                    elseif #currentProps == 1 or #currentProps > 1 then
                        local method = _G.BringMethod or "Smart"
                        local baseLeadTime = (speed > 40) and 0.35 or ((speed > 15) and 0.20 or 0.08)
                        
                        if method == "Basic" then
                                                                                           
                            targetCF = _CFrameNew(currentTargetRoot.Position.X, currentTargetRoot.Position.Y - feetOffset, currentTargetRoot.Position.Z)
                        elseif method == "Vortex Quasar" then
                                                                                                       
                            local vT = tick() * 32 + (i * 1.57)
                            local vRadius = 0.55 + _sin(tick() * 18) * 0.25
                            local vOffset = _Vector3New(_cos(vT) * vRadius, -feetOffset + _sin(vT * 2) * 0.25, _sin(vT) * vRadius)
                            targetCF = _CFrameNew(currentTargetRoot.Position + (predictedVel * (baseLeadTime * 0.7)) + vOffset)
                        elseif method == "Hyper-Magnet" then
                                                                                        
                            local magLead = baseLeadTime * 1.45
                            local interceptPos = currentTargetRoot.Position + (predictedVel * magLead)
                            if isAirborne and (i % 2 == 0) then
                                targetCF = _CFrameNew(currentTargetRoot.Position.X, currentTargetRoot.Position.Y - (feetOffset * 0.5), currentTargetRoot.Position.Z)
                            else
                                targetCF = _CFrameNew(interceptPos.X, interceptPos.Y - feetOffset, interceptPos.Z)
                            end
                        else
                                                                              
                            local predicted3DPos = currentTargetRoot.Position + (predictedVel * baseLeadTime)
                            if isAirborne then
                                targetCF = _CFrameNew(predicted3DPos.X, predicted3DPos.Y - feetOffset, predicted3DPos.Z)
                            else
                                local rayParams = RaycastParams.new()
                                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                rayParams.FilterDescendantsInstances = {char}
                                local rayResult = workspace:Raycast(predicted3DPos, _Vector3New(0, -15, 0), rayParams)
                                local finalY = rayResult and (rayResult.Position.Y - 0.2) or (predicted3DPos.Y - feetOffset)
                                targetCF = _CFrameNew(predicted3DPos.X, finalY, predicted3DPos.Z)
                            end
                            if #currentProps > 1 and i > 1 then
                                local total = math.max(#currentProps, 2)
                                local phi = math.acos(1 - 2 * (i - 1) / (total - 1))
                                local theta = _pi * (1 + math.sqrt(5)) * (i - 1)
                                local radius = 0.8
                                local offset = _Vector3New(radius * _sin(phi) * _cos(theta), radius * _cos(phi), radius * _sin(phi) * _sin(theta))
                                targetCF = _CFrameNew(targetCF.Position + offset)
                            end
                        end
                    end
                    
                    
                    
                    _0xH_3ef(scf, targetCF)
                end
                task.wait(0.03)
                break 
            end
            end
            
            
            if actionType == "Fly" then
                if targetHum.Sit and targetHum.SeatPart then
                    hasEverSeatedFly = true
                    bringSendHalted = true
                    for _, e in pairs(bringSenders) do e.dirty = false end
                    local seat = targetHum.SeatPart
                    local propModel = seat and seat:FindFirstAncestor(myPropName)
                    if propModel then
                        local scf = propModel:FindFirstChild("SetCurrentCFrame")
                        if scf then
                            local now = tick()
                            local dt = math.clamp(now - (flyLastTick or now), 0.01, 0.1)
                            flyLastTick = now

                            if not flyPos then
                                flyPos = currentTargetRoot.Position
                                flyHeading = currentTargetRoot.Orientation.Y
                            end

                            local rawMove = targetHum.MoveDirection
                            local moveHoriz = _Vector3New(rawMove.X, 0, rawMove.Z)
                            local _0xH_434 = moveHoriz.Magnitude > 0.05

                            local targetSpeed = (_0xH_43c and _0xH_43c.FlySpeed) or 65.0
                            if _0xH_434 then
                                local moveDir = moveHoriz.Unit
                                flyPos = flyPos + (moveDir * (targetSpeed * dt))
                                flyHeading = _deg(math.atan2(-moveDir.X, -moveDir.Z))
                            end

                            
                            
                            
                            
                            local bp = targetPlayer:FindFirstChildOfClass("Backpack")
                            local allTools = {}
                            if char then
                                for _, it in ipairs(char:GetChildren()) do
                                    if it:IsA("Tool") then table.insert(allTools, it) end
                                end
                            end
                            if bp then
                                for _, it in ipairs(bp:GetChildren()) do
                                    if it:IsA("Tool") then table.insert(allTools, it) end
                                end
                            end

                            if not flySlot1Tool and allTools[1] then flySlot1Tool = allTools[1] end
                            if not flySlot2Tool and allTools[2] then flySlot2Tool = allTools[2] end

                            local equippedTool = char and char:FindFirstChildOfClass("Tool")
                            local vertSpeed = 0
                            local climbSpeed = targetSpeed * (28.0 / 65.0)
                            if equippedTool then
                                if flySlot1Tool and equippedTool == flySlot1Tool then
                                    vertSpeed = climbSpeed
                                elseif flySlot2Tool and equippedTool == flySlot2Tool then
                                    vertSpeed = -climbSpeed
                                end
                            end

                            flyPos = flyPos + _Vector3New(0, vertSpeed * dt, 0)

                            local targetCF = _CFrameNew(flyPos) * _CFrameAngles(0, _rad(flyHeading + 180), 0)
                            if not flySenderThread or flySenderThreadScf ~= scf then
                                flySenderThreadScf = scf
                                flySenderCF = targetCF
                                flySenderThread = task.spawn(function()
                                    while _0xH_43c.Active and _0xH_43c.SessionId == loopSession and flySenderThreadScf == scf do
                                        if flySenderCF then
                                            local cfToSend = flySenderCF
                                            pcall(function() scf:InvokeServer(cfToSend) end)
                                        end
                                        task.wait(0.015)
                                    end
                                end)
                            else
                                flySenderCF = targetCF
                            end
                        end
                    end
                    task.wait(0.015)
                else
                    if hasEverSeatedFly then
                        pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllProps") end)
                        if _0xH_43c.CurrentToggle then
                            pcall(function() _0xH_43c.CurrentToggle:Set(false) end)
                        end
                        _0xH_43c.stop()
                        break
                    end
                    flyPos = nil
                    flyHeading = nil
                    flyLastTick = nil
                    flySlot1Tool = nil
                    flySlot2Tool = nil
                end
            elseif targetHum.Sit and targetHum.SeatPart then
                local seat = targetHum.SeatPart
                local propModel = seat:FindFirstAncestor(myPropName)
                if propModel then
                    local scf = propModel:FindFirstChild("SetCurrentCFrame")
                    if scf then
                        if actionType == "Kill" then
                            
                            bringSendHalted = true
                            for _, e in pairs(bringSenders) do e.dirty = false end
                            antiRollbackHammer(scf, _CFrameNew(0, -50000, 0))
                            task.wait(0.05)
                            pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllProps") end)
                            if _G.AutoLoopTroll and _0xH_43c.CurrentAction then
                                local savedToggle = _0xH_43c.CurrentToggle
                                local savedAction = _0xH_43c.CurrentAction
                                task.spawn(function()
                                    local died = false
                                    for _ = 1, 50 do
                                        
                                        task.wait(0.3)
                                        if not _G.AutoLoopTroll then return end
                                        local ch = targetPlayer.Character
                                        if not ch or not ch:FindFirstChild("HumanoidRootPart") then died = true break end
                                        local h = ch:FindFirstChild("Humanoid")
                                        if h and h.Health <= 0 then died = true break end
                                    end
                                    if died and _G.AutoLoopTroll then
                                        local respawned = false
                                        local startTime = os.clock()
                                        while os.clock() - startTime < 15 do
                                            task.wait(0.1)
                                            if not targetPlayer:IsDescendantOf(game:GetService("Players")) then break end
                                            if not _G.AutoLoopTroll then break end
                                            local c = targetPlayer.Character
                                            local h = c and c:FindFirstChild("Humanoid")
                                            local r = c and c:FindFirstChild("HumanoidRootPart")
                                            if c and h and r and h.Health > 0 then respawned = true break end
                                        end
                                        if respawned and _G.AutoLoopTroll then
                                            local toggleStillOn = true
                                            if savedToggle then
                                                pcall(function() toggleStillOn = savedToggle:GetValue() end)
                                            else
                                                toggleStillOn = _G.AutoLoopTroll
                                            end
                                            if not toggleStillOn then return end
                                            task.wait(0.3)
                                            _0xH_43c.CurrentToggle = savedToggle
                                            _0xH_43c.CurrentAction = savedAction
                                            _0xH_43c.bringPlayer(targetPlayer, savedAction, noCamera, callerName)
                                        end
                                    end
                                end)
                                return 
                            else
                                if _0xH_43c.CurrentToggle then pcall(function() _0xH_43c.CurrentToggle:Set(false) end) end
                                break
                            end
                        elseif actionType == "Jail" then
                            
                            bringSendHalted = true
                            for _, e in pairs(bringSenders) do e.dirty = false end
                            antiRollbackHammer(scf, _CFrameNew(-582, 10, 57))
                            if not _G.AutoLoopTroll then
                                pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllProps") end)
                                _0xH_43c.Active = false
                                if _0xH_43c.CurrentToggle then pcall(function() _0xH_43c.CurrentToggle:Set(false) end) end
                                break
                            end
                        elseif actionType == "Cliff" then
                            
                            bringSendHalted = true
                            for _, e in pairs(bringSenders) do e.dirty = false end
                            antiRollbackHammer(scf, _CFrameNew(-1796.89, -30.46, 106.37))
                            if not _G.AutoLoopTroll then
                                pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllProps") end)
                                _0xH_43c.Active = false
                                if _0xH_43c.CurrentToggle then pcall(function() _0xH_43c.CurrentToggle:Set(false) end) end
                                break
                            end
                        elseif actionType == "JailV2" then
                            
                            bringSendHalted = true
                            for _, e in pairs(bringSenders) do e.dirty = false end
                            antiRollbackHammer(scf, _CFrameNew(498.80, -18.21, 225.37))
                            if not _G.AutoLoopTroll then
                                pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllProps") end)
                                _0xH_43c.Active = false
                                if _0xH_43c.CurrentToggle then pcall(function() _0xH_43c.CurrentToggle:Set(false) end) end
                                break
                            end
                        elseif actionType == "Freeze" then
                            
                            bringSendHalted = true
                            for _, e in pairs(bringSenders) do e.dirty = false end
                            antiRollbackHammer(scf, _CFrameNew(21.03, 63.05, -479.78))
                            if not _G.AutoLoopTroll then
                                pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllProps") end)
                                _0xH_43c.Active = false
                                if _0xH_43c.CurrentToggle then pcall(function() _0xH_43c.CurrentToggle:Set(false) end) end
                                break
                            end
                        elseif actionType == "Exile" then
                            
                            bringSendHalted = true
                            for _, e in pairs(bringSenders) do e.dirty = false end
                            antiRollbackHammer(scf, _CFrameNew(999999, 999999, 999999))
                            if not _G.AutoLoopTroll then
                                pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllProps") end)
                                _0xH_43c.Active = false
                                if _0xH_43c.CurrentToggle then pcall(function() _0xH_43c.CurrentToggle:Set(false) end) end
                                break
                            end
                        elseif actionType == "VoidGlitch" then
                            bringSendHalted = true
                            for _, e in pairs(bringSenders) do e.dirty = false end
                            antiRollbackHammer(scf, _CFrameNew(869658880, 1528186880, 529643328))
                            if not _G.AutoLoopTroll then
                                pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllProps") end)
                                _0xH_43c.Active = false
                                if _0xH_43c.CurrentToggle then pcall(function() _0xH_43c.CurrentToggle:Set(false) end) end
                                break
                            end
                        else
                            
                            
                            
                            
                            
                            bringSendHalted = true
                            for _, e in pairs(bringSenders) do e.dirty = false end
                            local targetCF = myRoot.CFrame * _CFrameNew(0, 0, -4)
                            pcall(function() scf:InvokeServer(targetCF) end)
                            
                            bringSendHalted = false
                            if (currentTargetRoot.Position - myRoot.Position).Magnitude < 8 then
                                if not _G.AutoLoopTroll then
                                    pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Clea1rTool1s"):FireServer("ClearAllProps") end)
                                    _0xH_43c.Active = false
                                    if _0xH_43c.CurrentToggle then pcall(function() _0xH_43c.CurrentToggle:Set(false) end) end
                                    break
                                end
                            end
                        end
                    end
                end
            end 
            task.wait(0.015)
            until true 
        end
        _0xH_43c.stop()
    end)
end

                                           

do
    local function getTrollPlayers()
        local list = {}
        for _, p in pairs(game:GetService("Players"):GetPlayers()) do
            if p ~= game:GetService("Players").LocalPlayer then
                table.insert(list, p.Name)
            end
        end
        return list

    do
        local adminRunning = false
        local adminMode = "Pull"
        local adminLocked = false
        local adminToggle = nil

        local adminWhitelist = { [1] = "", [2] = "", [3] = "" }
        local function isAdminWhitelisted(p)
            if not p then return false end
            local name = p.Name
            local lp = game:GetService("Players").LocalPlayer
            if name == lp.Name then return true end
            for i = 1, 3 do
                if adminWhitelist[i] and adminWhitelist[i] ~= "" and adminWhitelist[i] ~= "---" and adminWhitelist[i] == name then
                    return true
                end
            end
            return false
        end

        local adminNotifHistory = {}
        local function safeAdminNotify(title, text, duration)
            if not text or type(text) ~= "string" or text == "" or text:find("nil") then return end
            local now = os.clock()

            
            for i = #adminNotifHistory, 1, -1 do
                if now - adminNotifHistory[i].time > 3.0 then
                    table.remove(adminNotifHistory, i)
                end
            end

            
            for _, item in ipairs(adminNotifHistory) do
                if item.text == text then return end
            end

            
            if #adminNotifHistory >= 2 then
                return
            end

            table.insert(adminNotifHistory, { text = text, time = now })

            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = title or "Admin",
                    Text = text,
                    Duration = duration or 3
                })
            end)
        end

        local function _0xH_413()
            local RE = game:GetService("ReplicatedStorage"):FindFirstChild("RE")
            local cr = RE and RE:FindFirstChild("1Clea1rTool1s")
            if cr then pcall(function() cr:FireServer("ClearAllProps") end) end
        end

        local adminStarting = false

        local function adminStopAll(fromToggle)
            if adminLocked then return end
            
            
            if not adminRunning then return end
            
            
            
            if fromToggle and fromToggle ~= "__force__" and fromToggle ~= adminToggle then return end
            adminLocked = true
            adminRunning = false
                                                                                    
            _0xH_413()
            task.wait(0.25)
            local RE = game:GetService("ReplicatedStorage"):FindFirstChild("RE")
            if RE then
                local toolRemote = RE:FindFirstChild("1Too1l")
                
            end
            
            
            task.wait(0.1)
            local myRE = game:GetService("ReplicatedStorage"):FindFirstChild("RE")
            if myRE then
                local clr = myRE:FindFirstChild("1Clea1rTool1s")
                if clr then
                    pcall(function() clr:FireServer("ClearAllTools") end)
                    task.wait(0.1)
                    pcall(function() clr:FireServer("ClosePropMenu") end)
                end
            end
            local lpChar = game:GetService("Players").LocalPlayer.Character
            local lpHum = lpChar and lpChar:FindFirstChildOfClass("Humanoid")
            if lpHum then pcall(function() lpHum:UnequipTools() end) end
            _0xH_3f1()
            task.wait(0.1)
            
            
            local forceUncheck = (fromToggle == "__force__")
            if adminToggle and (not adminStarting or forceUncheck) then
                local tg = adminToggle
                adminToggle = nil
                pcall(function() tg:Set(false) end)
            else
                adminToggle = nil
            end
            adminLocked = false
            adminStarting = false
        end
        _G.AdminStopAll = adminStopAll

        local function runAdmin(mode, toggle, callerName, customTargets, isLoop)
            adminMode = mode
            adminToggle = toggle
            adminRunning = true
            adminStarting = true
            local lp = game:GetService("Players").LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local myRoot = char:FindFirstChild("HumanoidRootPart")

            local allPlayers = (customTargets and #customTargets > 0) and customTargets or game:GetService("Players"):GetPlayers()
            local validPlayers = {}
            for _, p in ipairs(allPlayers) do
                local isFakeAdmin = (not (customTargets and #customTargets > 0)) and ((fakeAdminEnabled and fakeAdminTarget and p.Name == fakeAdminTarget) or (callerName and p.Name == callerName))
                if p ~= lp and not isFakeAdmin and not isAdminWhitelisted(p) then
                    table.insert(validPlayers, p)
                end
            end
            if #validPlayers == 0 then
                safeAdminNotify("Admin", "No targets found!", 3)
                adminStopAll("__force__")
                return
            end

            local RE = game:GetService("ReplicatedStorage"):WaitForChild("RE")
            local clearTools = RE:WaitForChild("1Clea1rTool1s")

            local propsTool = _0xH_3f2()
            if not propsTool then
                local fetchStart = tick()
                while not propsTool and tick() - fetchStart < 3.5 do
                    task.wait(0.3)
                    propsTool = _0xH_3f2()
                end
            end
            if not propsTool then
                adminStopAll("__force__")
                return
            end

            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and propsTool.Parent ~= char then
                pcall(function() hum:EquipTool(propsTool) end)
                task.wait(0.2)
            end

            pcall(function() clearTools:FireServer("OpenPropMenu") end)
            task.wait(0.1)

                                                                         
            
            local propName = _G.AdminMassProp or "FurnitureToilet"
            if mode == "Fly" or mode == "Noclip" then
                propName = "FurnitureBeanBag"
            elseif callerName then
                propName = "FurnitureToilet"
            end
            local propCategory = "Furniture"
            pcall(function() clearTools:FireServer("RequestingPropName", propName, propCategory) end)
            task.wait(0.1)

            local toolPropMake = propsTool:FindFirstChild("Tool_PropMake") or propsTool:WaitForChild("Tool_PropMake", 3)
            if not toolPropMake or not myRoot then
                adminStopAll("__force__")
                return
            end

            local myPropName = "Prop" .. lp.Name
            local currentPropsCount = 0
            pcall(function()
                local wc = workspace:FindFirstChild("WorkspaceCom")
                if wc then
                    for _, folder in pairs(wc:GetChildren()) do
                        for _, prop in pairs(folder:GetChildren()) do
                            if prop.Name == myPropName then currentPropsCount = currentPropsCount + 1 end
                        end
                    end
                end
            end)

            local needed = math.min(14, #validPlayers)
            local toSpawn = needed - currentPropsCount
            if toSpawn > 0 then
                local duplicated = _0xH_3f4(toolPropMake, myRoot.Position, toSpawn, 0)
                if not duplicated then
                    for i = 1, toSpawn do
                        if not adminRunning then break end
                        local curChar = lp.Character
                        local curHum = curChar and curChar:FindFirstChildOfClass("Humanoid")
                        if curHum and propsTool.Parent ~= curChar then
                            pcall(function() curHum:EquipTool(propsTool) end)
                            task.wait(0.1)
                        end
                        local angle = (i / toSpawn) * 2 * _pi
                        local offset = _Vector3New(_cos(angle) * 4, 0, _sin(angle) * 4)
                        pcall(function() toolPropMake:FireServer(workspace.Terrain, myRoot.Position + offset) end)
                        task.wait(0.85)
                    end
                end
            end

            
            pcall(function() local h = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid"); if h then h:UnequipTools() end end)
            task.spawn(function()
                task.wait(1.0)
                pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Too1l"):InvokeServer("PickingTools", "PropMaker") end)
                pcall(function() clearTools:FireServer("ClosePropMenu") end)
                local hNow = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                if hNow then pcall(function() hNow:UnequipTools() end) end
                _0xH_3f1()
            end)

            adminStarting = false
            task.spawn(function()
                local staticDestPos = nil
                if mode == "Kill" then
                    staticDestPos = _Vector3New(0, workspace.FallenPartsDestroyHeight - 100, 0)
                elseif mode == "Freeze" then
                    staticDestPos = _Vector3New(21.03, 63.05, -479.78)
                elseif mode == "Void" or mode == "Exile" then
                    staticDestPos = _Vector3New(999999, 999999, 999999)
                elseif mode == "Jail" then
                    staticDestPos = _Vector3New(-582, 10, 57)
                elseif mode == "JailV2" then
                    staticDestPos = _Vector3New(498.80, -18.21, 225.37)
                elseif mode == "Cliff" then
                    staticDestPos = _Vector3New(-1796.89, -30.46, 106.37)
                end

                local playerVelocities = {}
                local adminFlyPositions = {}
                local adminFlyHeadings = {}
                local adminFlySlot1Tools = {}
                local adminFlySlot2Tools = {}
                local adminFlyLastTick = tick()
                local adminStartTime = tick()
                local adminDuration = (mode == "Bring") and 10 or 20

                while adminRunning do
                    
                    
                    if callerName and not isLoop and (tick() - adminStartTime >= adminDuration) then
                        adminStopAll()
                        break
                    end

                    local currentProps = {}
                    pcall(function()
                        local wc = workspace:FindFirstChild("WorkspaceCom")
                        if wc then
                            for _, folder in pairs(wc:GetChildren()) do
                                for _, prop in pairs(folder:GetChildren()) do
                                    if prop.Name == myPropName then
                                        local scf = prop:FindFirstChild("SetCurrentCFrame")
                                        if scf then table.insert(currentProps, {scf = scf, model = prop}) end
                                    end
                                end
                            end
                        end
                    end)

                    if #currentProps > 0 then
                    local allTargets = {}
                    local targetsSource = (customTargets and #customTargets > 0) and customTargets or game:GetService("Players"):GetPlayers()
                    for _, p in ipairs(targetsSource) do
                        local isFakeAdmin = (not (customTargets and #customTargets > 0)) and ((fakeAdminEnabled and fakeAdminTarget and p.Name == fakeAdminTarget) or (callerName and p.Name == callerName))
                        if p ~= lp and not isFakeAdmin and not isAdminWhitelisted(p) then
                            if p.Character and p.Character:FindFirstChild("Humanoid") and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                                table.insert(allTargets, p)
                            end
                        end
                    end

                    if customTargets and #customTargets > 0 and not isLoop and mode == "Kill" and (tick() - adminStartTime >= 3) and #allTargets == 0 then
                        task.wait(0.5)
                        adminStopAll()
                        break
                    end

                    if #allTargets > 0 then
                    local currentDestPos = staticDestPos
                    local destRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                    if mode == "Bring" then
                        if callerName then
                            local cp = game:GetService("Players"):FindFirstChild(callerName)
                            if cp and cp.Character and cp.Character:FindFirstChild("HumanoidRootPart") then
                                destRoot = cp.Character.HumanoidRootPart
                            end
                        end
                        if destRoot then
                            currentDestPos = destRoot.Position
                        end
                    end

                    local unseatedTargets = {}
                    local benchStatus = {}

                    for _, p in ipairs(allTargets) do
                        local thum = p.Character.Humanoid
                        local troot = p.Character.HumanoidRootPart
                        local seated = false
                        if thum.Sit and thum.SeatPart then
                            local propModel = thum.SeatPart:FindFirstAncestor(myPropName)
                            if propModel then
                                seated = true
                                for _, pData in ipairs(currentProps) do
                                    if pData.model == propModel then
                                        benchStatus[pData.scf] = p
                                        break
                                    end
                                end
                            end
                        end

                        if not seated then
                            table.insert(unseatedTargets, p)
                        end
                    end

                    
                    for _, pData in ipairs(currentProps) do
                        if not adminRunning then break end
                        local scf = pData.scf
                        local seatedPlayer = benchStatus[scf]

                        if seatedPlayer then
                            if mode == "Kill" then
                                pcall(function() scf:InvokeServer(_CFrameNew(0, workspace.FallenPartsDestroyHeight + 2, 0)) end)
                            elseif mode == "Freeze" then
                                pcall(function() scf:InvokeServer(_CFrameNew(21.03, 63.05, -479.78)) end)
                            elseif mode == "Void" or mode == "Exile" then
                                pcall(function() scf:InvokeServer(_CFrameNew(0, workspace.FallenPartsDestroyHeight + 5, 0)) end)
                            elseif mode == "VoidGlitch" then
                                pcall(function() scf:InvokeServer(_CFrameNew(869658880, 1528186880, 529643328)) end)
                            elseif mode == "Jail" then
                                pcall(function() scf:InvokeServer(_CFrameNew(-582, 10, 57)) end)
                            elseif mode == "JailV2" then
                                pcall(function() scf:InvokeServer(_CFrameNew(498.80, -18.21, 225.37)) end)
                            elseif mode == "Cliff" then
                                pcall(function() scf:InvokeServer(_CFrameNew(-1796.89, -30.46, 106.37)) end)
                            elseif mode == "Bring" then
                                if destRoot then
                                    pcall(function() scf:InvokeServer(destRoot.CFrame * _CFrameNew(0, 0, -3.5)) end)
                                end
                            elseif mode == "Fly" or mode == "Noclip" then
                                local pChar = seatedPlayer.Character
                                local pRoot = pChar and pChar:FindFirstChild("HumanoidRootPart")
                                local pHum = pChar and pChar:FindFirstChildOfClass("Humanoid")
                                if pRoot and pHum then
                                    local nowA = tick()
                                    local dtA = math.clamp(nowA - (adminFlyLastTick or nowA), 0.01, 0.1)
                                    adminFlyLastTick = nowA

                                    local curPos = adminFlyPositions[scf] or pRoot.Position
                                    local curHeading = adminFlyHeadings[scf] or pRoot.Orientation.Y

                                    local rawMove = pHum.MoveDirection
                                    local moveHoriz = _Vector3New(rawMove.X, 0, rawMove.Z)
                                    if moveHoriz.Magnitude > 0.05 then
                                        local moveDir = moveHoriz.Unit
                                        curPos = curPos + (moveDir * (65.0 * dtA))
                                        curHeading = _deg(math.atan2(-moveDir.X, -moveDir.Z))
                                    end

                                    local bp = seatedPlayer:FindFirstChildOfClass("Backpack")
                                    local pTools = {}
                                    if pChar then
                                        for _, it in ipairs(pChar:GetChildren()) do
                                            if it:IsA("Tool") then table.insert(pTools, it) end
                                        end
                                    end
                                    if bp then
                                        for _, it in ipairs(bp:GetChildren()) do
                                            if it:IsA("Tool") then table.insert(pTools, it) end
                                        end
                                    end

                                    if not adminFlySlot1Tools[scf] and pTools[1] then adminFlySlot1Tools[scf] = pTools[1] end
                                    if not adminFlySlot2Tools[scf] and pTools[2] then adminFlySlot2Tools[scf] = pTools[2] end

                                    local eqTool = pChar and pChar:FindFirstChildOfClass("Tool")
                                    local vertA = 0
                                    if eqTool then
                                        if adminFlySlot1Tools[scf] and eqTool == adminFlySlot1Tools[scf] then
                                            vertA = 28.0
                                        elseif adminFlySlot2Tools[scf] and eqTool == adminFlySlot2Tools[scf] then
                                            vertA = -28.0
                                        end
                                    end

                                    curPos = curPos + _Vector3New(0, vertA * dtA, 0)

                                    adminFlyPositions[scf] = curPos
                                    adminFlyHeadings[scf] = curHeading

                                    local targetCF = _CFrameNew(curPos) * _CFrameAngles(0, _rad(curHeading + 180), 0)
                                    pcall(function() scf:InvokeServer(targetCF) end)
                                end
                            end
                        else
                            if #unseatedTargets > 0 then
                                local target = table.remove(unseatedTargets, 1)
                                local troot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                                local thum = target.Character and target.Character:FindFirstChild("Humanoid")
                                if troot and thum then
                                    task.spawn(function()
                                        local heightOffset = thum.HipHeight and (thum.HipHeight * 0.5) or 1.0
                                        local nowT = tick()
                                        local vEntry = playerVelocities[target]
                                        if not vEntry then
                                            vEntry = { lastPos = troot.Position, lastTime = nowT, vel = _Vector3New(0,0,0) }
                                            playerVelocities[target] = vEntry
                                        else
                                            local dt = nowT - vEntry.lastTime
                                            if dt >= 0.03 then
                                                local curVel = (troot.Position - vEntry.lastPos) / dt
                                                vEntry.vel = vEntry.vel:Lerp(curVel, 0.6)
                                                vEntry.lastPos = troot.Position
                                                vEntry.lastTime = nowT
                                            end
                                        end
                                        local horizontalVel = _Vector3New(vEntry.vel.X, 0, vEntry.vel.Z)
                                        local speed = horizontalVel.Magnitude
                                        local predictionTime = math.clamp(speed * 0.005, 0, 0.15)
                                        local placePos = troot.Position + (horizontalVel * predictionTime) - _Vector3New(0, heightOffset, 0)
                                        pcall(function() scf:InvokeServer(_CFrameNew(placePos)) end)
                                    end)
                                end
                            end
                        end
                    end
                    end
                    end

                    task.wait(0.08)
                end
            end)
        end

        _G.BTR_AdminStartMass = function(mode)
            if not _G.BTR_UI_READY then return false end
            local actualMode = mode
            local callerName = nil
            if mode == "Bring10s" then
                actualMode = "Bring"
                callerName = "__BringAll10s__"
            end
            if adminRunning and adminMode == actualMode then
                adminStopAll("__force__")
                return false
            end
            if adminRunning then
                adminStopAll("__force__")
                task.wait(0.2)
            end
            runAdmin(actualMode, nil, callerName)
            return true
        end

        _G.BTR_AdminStopMass = function()
            adminStopAll("__force__")
        end

        _G.BTR_AdminIsRunning = function()
            return adminRunning, adminMode
        end

        _G.BTR_AdminSetProp = function(value)
            if value == "Toilet" then
                _G.AdminMassProp = "FurnitureToilet"
            elseif value == "BeanBag" then
                _G.AdminMassProp = "FurnitureBeanBag"
            elseif value == "Bleachers" then
                _G.AdminMassProp = "FurnitureBleachers"
            elseif value == "Silver Throne" then
                _G.AdminMassProp = "FurnitureSilverThrone"
            elseif value == "Futuristic Large Bed" then
                _G.AdminMassProp = "FuturisticLargeBed"
            end
            _G.AdminMassCategory = "Furniture"
        end

    end

-- UI REPLACEMENT: c00lgui style, with the first Admin section added.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

pcall(function()
    local old = pg:FindFirstChild("c00lPropGui")
    if old then old:Destroy() end
end)

local blak = Color3.new(0,0,0)
local rede = Color3.new(1,0,0)
local whit = Color3.new(1,1,1)
local grey = Color3.fromRGB(25,25,25)
local tef = Enum.Font.SourceSans

local cka = Instance.new("ScreenGui")
cka.Name = "c00lPropGui"
cka.ResetOnSpawn = false
cka.Parent = pg

local frame = Instance.new("Frame")
frame.Parent = cka
frame.BackgroundColor3 = blak
frame.BorderColor3 = rede
frame.BorderSizePixel = 3
frame.Name = "Frame"
frame.Position = UDim2.new(0,3,0.3,0)
frame.Size = UDim2.new(0,300,0,400)
frame.Active = true

local title = Instance.new("TextLabel")
title.Parent = frame
title.BackgroundColor3 = blak
title.BorderColor3 = rede
title.BorderSizePixel = 3
title.Name = "Title"
title.Position = UDim2.new(0,0,0,0)
title.Size = UDim2.new(1,0,0,40)
title.ZIndex = 2
title.Font = tef
title.TextSize = 24
title.Text = "c00lgui Reborn Rc7 by v3rx"
title.TextColor3 = whit

local cope = Instance.new("TextButton")
cope.Parent = cka
cope.Active = true
cope.AutoButtonColor = true
cope.BackgroundColor3 = blak
cope.BorderColor3 = rede
cope.BorderSizePixel = 3
cope.Name = "Close/Open"
cope.Position = UDim2.new(0,3,0.3,380)
cope.Size = UDim2.new(0,300,0,20)
cope.ZIndex = 3
cope.Font = tef
cope.TextSize = 18
cope.Text = "Close"
cope.TextColor3 = whit

local function dragify(obj, handle)
    handle = handle or obj
    local dragging, start, startPos, input
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            start = i.Position
            startPos = obj.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            input = i
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i == input then
            local d = i.Position-start
            obj.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
end

dragify(frame,title)

dragify(cope)
cope.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
    cope.Text = frame.Visible and "Close" or "Open"
end)

-- keep Open/Close directly below the main frame while dragging it
local lastPos = frame.Position
UserInputService.InputChanged:Connect(function()
    if frame.Position ~= lastPos then
        local p = frame.Position
        cope.Position = UDim2.new(p.X.Scale,p.X.Offset,p.Y.Scale,p.Y.Offset+380)
        lastPos = p
    end
end)

local pages={}
for i=1,6 do
    local p=Instance.new("Frame")
    p.Parent=frame
    p.BackgroundColor3=blak
    p.BorderColor3=rede
    p.BorderSizePixel=3
    p.Name="Page"..i
    p.Position=UDim2.new(0,0,0,83)
    p.Size=UDim2.new(1,0,1,-106)
    p.ZIndex=2
    p.Visible=(i==1)
    pages[i]=p
end

local left=Instance.new("TextButton")
left.Parent=frame
left.BackgroundColor3=blak
left.BorderColor3=rede
left.BorderSizePixel=3
left.Name="<"
left.Position=UDim2.new(0,0,0,40)
left.Size=UDim2.new(0.5,-3,0,40)
left.ZIndex=2
left.Font=tef
left.TextSize=48
left.Text="<"
left.TextColor3=whit

local right=Instance.new("TextButton")
right.Parent=frame
right.BackgroundColor3=blak
right.BorderColor3=rede
right.BorderSizePixel=3
right.Name=">"
right.Position=UDim2.new(0.5,3,0,40)
right.Size=UDim2.new(0.5,-3,0,40)
right.ZIndex=2
right.Font=tef
right.TextSize=48
right.Text=">"
right.TextColor3=whit

local currentPage=1
local function showPage(n)
    currentPage=((n-1)%6)+1
    for i,p in ipairs(pages) do p.Visible=(i==currentPage) end
end
left.MouseButton1Click:Connect(function() showPage(currentPage-1) end)
right.MouseButton1Click:Connect(function() showPage(currentPage+1) end)

local function btn(parent,text,y,fn)
    local b=Instance.new("TextButton")
    b.Parent=parent
    b.BackgroundColor3=blak
    b.BorderColor3=rede
    b.BorderSizePixel=3
    b.Position=UDim2.new(0,5,0,y)
    b.Size=UDim2.new(1,-10,0,22)
    b.Font=tef
    b.TextSize=15
    b.Text=text
    b.TextColor3=whit
    b.MouseButton1Click:Connect(function() pcall(fn) end)
    return b
end
local function label(parent,text,y,h)
    local l=Instance.new("TextLabel")
    l.Parent=parent
    l.BackgroundColor3=blak
    l.BorderColor3=rede
    l.BorderSizePixel=2
    l.Position=UDim2.new(0,5,0,y)
    l.Size=UDim2.new(1,-10,0,h or 26)
    l.Font=tef
    l.TextSize=15
    l.Text=text
    l.TextColor3=whit
    return l
end
local function box(parent,text,y)
    local b=Instance.new("TextBox")
    b.Parent=parent
    b.BackgroundColor3=blak
    b.BorderColor3=rede
    b.BorderSizePixel=2
    b.Position=UDim2.new(0,5,0,y)
    b.Size=UDim2.new(1,-10,0,22)
    b.Font=tef
    b.TextSize=15
    b.Text=text or ""
    b.PlaceholderText=""
    b.TextColor3=whit
    b.ClearTextOnFocus=false
    return b
end


-- First part of the original Admin tab: everything before White List.
_G.BTR_UI_READY = true
_G.AdminMassProp = _G.AdminMassProp or "FurnitureBleachers"
_G.AdminMassCategory = _G.AdminMassCategory or "Furniture"

local adminPropLabel = label(pages[5], "Prop: Bleachers", 0, 28)
local adminMassButtons = {}

local function setAdminProp(value)
    _G.BTR_AdminSetProp(value)
    adminPropLabel.Text = "Prop: " .. value
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Admin Prop",
            Text = "Admin prop changed to: " .. value,
            Duration = 2
        })
    end)
end

btn(pages[5], "Use Bleachers", 30, function() setAdminProp("Bleachers") end)
btn(pages[5], "Use Toilet", 54, function() setAdminProp("Toilet") end)
btn(pages[5], "Use BeanBag", 78, function() setAdminProp("BeanBag") end)
btn(pages[5], "Use Silver Throne", 102, function() setAdminProp("Silver Throne") end)
btn(pages[5], "Use Futuristic Large Bed", 126, function() setAdminProp("Futuristic Large Bed") end)

local function massButton(parent, text, y, mode)
    local b
    b = btn(parent, text, y, function()
        local running, current = _G.BTR_AdminIsRunning()
        if running and current == mode then
            _G.BTR_AdminStopMass()
            b.Text = text
            return
        end
        if running then _G.BTR_AdminStopMass(); task.wait(0.2) end
        local started = _G.BTR_AdminStartMass(mode)
        if started then
            for _, other in ipairs(adminMassButtons) do
                other.Text = other._baseText
            end
            b.Text = "ON: " .. text
        end
    end)
    b._baseText = text
    table.insert(adminMassButtons, b)
    return b
end

massButton(pages[5], "Pull All", 152, "Bring")
massButton(pages[5], "Kill All", 174, "Kill")
massButton(pages[5], "Freeze All", 196, "Freeze")
massButton(pages[5], "Void All", 218, "Void")
massButton(pages[5], "Void Glitch All", 240, "VoidGlitch")
massButton(pages[5], "Jail All", 262, "Jail")

local bringAllButton = btn(pages[6], "Bring All (10s)", 0, function()
    local running = _G.BTR_AdminIsRunning()
    if running then
        _G.BTR_AdminStopMass()
        bringAllButton.Text = bringAllButton._baseText
        return
    end
    local started = _G.BTR_AdminStartMass("Bring10s")
    if started then bringAllButton.Text = "ON: Bring All (10s)" end
end)
bringAllButton._baseText = "Bring All (10s)"

-- The source uses a special caller name for this 10-second Bring All mode.
-- The wrapper above starts the exact Bring mode; the special 10-second source path is exposed separately below.
btn(pages[6], "Stop Admin / Clear Props", 34, function()
    _G.BTR_AdminStopMass()
    for _, b in ipairs(adminMassButtons) do b.Text = b._baseText end
    bringAllButton.Text = bringAllButton._baseText
end)
label(pages[6], "Exact Admin section before White List", 68, 28)
label(pages[6], "Prop selection + mass actions", 102, 28)



-- Target / destination state exactly matching the source naming.
_G.TrollTarget = _G.TrollTarget or "---"
_G.TrollTargetDest = _G.TrollTargetDest or "---"
_G.SelectedPropName = _G.SelectedPropName or "FurnitureToilet"
_G.SelectedPropCategory = _G.SelectedPropCategory or "Furniture"
_G.AutoLoopTroll = false
_G.BringToiletCount = _G.BringToiletCount or 1

local targetBox=box(pages[1],"---",0)
local destBox=box(pages[1],"---",34)
local propBox=box(pages[1],"FurnitureToilet",68)
local countBox=box(pages[1],tostring(_G.BringToiletCount),102)
label(pages[1],"TARGET / DESTINATION / PROP / COUNT",134,25)

local status=label(pages[1],"Status: ready",164,34)
local function stat(s) status.Text="Status: "..tostring(s) end

local function refreshPlayers()
    local names={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp then table.insert(names,p.Name) end
    end
    table.sort(names)
    if names[1] then
        targetBox.Text=names[1]
        _G.TrollTarget=names[1]
        if names[2] then destBox.Text=names[2] else destBox.Text=names[1] end
        _G.TrollTargetDest=destBox.Text
        stat("players refreshed")
    else
        targetBox.Text="---"; destBox.Text="---"
        _G.TrollTarget="---"; _G.TrollTargetDest="---"
        stat("no other players")
    end
end

targetBox.FocusLost:Connect(function() _G.TrollTarget=targetBox.Text end)
destBox.FocusLost:Connect(function() _G.TrollTargetDest=destBox.Text end)
propBox.FocusLost:Connect(function()
    _G.SelectedPropName=propBox.Text
    _G.SelectedPropCategory="Furniture"
end)
countBox.FocusLost:Connect(function()
    _G.BringToiletCount=math.clamp(tonumber(countBox.Text) or 1,1,15)
    countBox.Text=tostring(_G.BringToiletCount)
end)
btn(pages[1],"Refresh Players",205,refreshPlayers)
btn(pages[1],"Stop / Clear Props",239,function()
    _0xH_43c.stop()
    stat("stopped")
end)

-- exact source prop choices
btn(pages[2],"Use Toilet",0,function() _G.SelectedPropName="FurnitureToilet"; _G.SelectedPropCategory="Furniture"; propBox.Text=_G.SelectedPropName end)
btn(pages[2],"Use BeanBag",34,function() _G.SelectedPropName="FurnitureBeanBag"; _G.SelectedPropCategory="Furniture"; propBox.Text=_G.SelectedPropName end)
btn(pages[2],"Use Bleachers",68,function() _G.SelectedPropName="FurnitureBleachers"; _G.SelectedPropCategory="Furniture"; propBox.Text=_G.SelectedPropName end)
btn(pages[2],"Use Silver Throne",102,function() _G.SelectedPropName="FurnitureSilverThrone"; _G.SelectedPropCategory="Furniture"; propBox.Text=_G.SelectedPropName end)
btn(pages[2],"Use Futuristic Large Bed",136,function() _G.SelectedPropName="FuturisticLargeBed"; _G.SelectedPropCategory="Furniture"; propBox.Text=_G.SelectedPropName end)
label(pages[2],"Source prop names are preserved exactly.",170,35)

local function requireTarget()
    local name=targetBox.Text
    if not name or name=="" or name=="---" then stat("select a target first"); return nil end
    local t=Players:FindFirstChild(name)
    if not t then stat("target not found"); return nil end
    _G.TrollTarget=name
    return t
end
local function requireDest()
    local name=destBox.Text
    if not name or name=="" or name=="---" then return nil end
    return Players:FindFirstChild(name)
end
local function start(action, ...)
    local t=requireTarget()
    if not t then return end
    if _0xH_43c.CurrentToggle then _0xH_43c.stop() end
    _0xH_43c.CurrentAction=action
    _0xH_43c.bringPlayer(t, action, ...)
    stat(action.." started")
end

btn(pages[3],"Bring Target To Me <Prop>",0,function() start("Bring") end)
btn(pages[3],"Kill Player <Prop>",34,function() start("Kill") end)
btn(pages[3],"Jail Player <Prop>",68,function() start("Jail") end)
btn(pages[3],"Freeze Player <Prop>",102,function() start("Freeze") end)
btn(pages[3],"Void Choice <Prop>",136,function() start("Cliff") end)
btn(pages[3],"Void Player <Prop>",170,function() start("Exile") end)
btn(pages[3],"Void Glitch Player <Prop>",204,function() start("VoidGlitch") end)
btn(pages[3],"Fly Player <BeanBag>",238,function() start("Fly") end)

btn(pages[4],"Teleport Me To Target",0,function()
    local t=requireTarget(); if not t then return end
    local c=lp.Character; local h=c and c:FindFirstChild("HumanoidRootPart")
    local th=t.Character and t.Character:FindFirstChild("HumanoidRootPart")
    if h and th then h.CFrame=th.CFrame*_CFrameNew(0,0,3); stat("teleported to target") end
end)
btn(pages[4],"Teleport Target To Destination <Prop>",34,function()
    local t=requireTarget(); local d=requireDest()
    if not t or not d then stat("select target + destination") return end
    if _0xH_43c.CurrentToggle then _0xH_43c.stop() end
    _0xH_43c.CurrentAction="Bring"
    _0xH_43c.bringPlayer(t,"Bring",true,d.Name)
    stat("destination action started")
end)
btn(pages[4],"Loop Actions: ON",68,function() _G.AutoLoopTroll=true; stat("loop ON") end)
btn(pages[4],"Loop Actions: OFF",102,function() _G.AutoLoopTroll=false; _0xH_43c.stop(); stat("loop OFF") end)
btn(pages[4],"Clear All Props",136,function()
    local RE=game:GetService("ReplicatedStorage"):FindFirstChild("RE")
    local clr=RE and RE:FindFirstChild("1Clea1rTool1s")
    if clr then pcall(function() clr:FireServer("ClearAllProps") end) end
    stat("all props cleared")
end)

label(pages[6],"SOURCE PROP ENGINE",0,30)
label(pages[6],"PropMaker -> OpenPropMenu -> RequestingPropName",38,30)
label(pages[6],"Tool_PropMake -> WorkspaceCom -> SetCurrentCFrame",76,30)
label(pages[6],"DuplicateProp / ClearAllProps are preserved.",114,30)
label(pages[6],"Direct Prop Actions are on pages 3-4.",152,30)
label(pages[6],"Admin mass actions are on page 5.",190,30)

refreshPlayers()
