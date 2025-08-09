local Players = game:GetService("Players")
local VIM = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local player = Players.LocalPlayer

local function screenInsetFor(guiObject)
    local sg = guiObject:FindFirstAncestorOfClass("ScreenGui")
    if sg and sg.IgnoreGuiInset then
        return Vector2.new(0, 0)
    end
    return GuiService:GetGuiInset()
end

local function clickCenterLower(btn, offsetY)
    pcall(function() btn:Activate() end)
    local pos, size = btn.AbsolutePosition, btn.AbsoluteSize
    local inset = screenInsetFor(btn)
    local cx = pos.X + size.X/2 + inset.X
    local cy = pos.Y + size.Y/2 + inset.Y + (offsetY or 0)
    VIM:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
    VIM:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
end

local function clickExitHomeGUI()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return false end
    for _, gui in ipairs(pg:GetDescendants()) do
        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
            local bag = (gui.Name or "")
            if gui:IsA("TextButton") then bag ..= " " .. (gui.Text or "") end
            for _, d in ipairs(gui:GetDescendants()) do
                if d:IsA("TextLabel") then
                    bag = bag .. " " .. (d.Text or "")
                end
            end
            if bag:lower():find("exit home") then
                clickCenterLower(gui, 50)
                print("✅ Clicked Exit Home")
                return true
            end
        end
    end
    return false
end

-- Lặp click liên tục đến khi thành công
while not clickExitHomeGUI() do
    task.wait(0.4)
end

-- Chờ 10 giây sau Exit Home
task.wait(20)

------------------------------------
-- 2) BAY TUẦN TỰ 3 TỌA ĐỘ         --
------------------------------------
local function flyTo(targetPos, speed)
    local flying = true
    local RunService = game:GetService("RunService")

    local stepConn = RunService.Stepped:Connect(function()
        if flying and player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)

    local hbConn = RunService.Heartbeat:Connect(function(dt)
        if not flying then return end
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local direction = (targetPos - hrp.Position)
            local distance = direction.Magnitude
            if distance > 3 then
                local move = direction.Unit * speed * dt
                if move.Magnitude > distance then
                    move = direction
                end
                hrp.CFrame = hrp.CFrame + move
            else
                flying = false
            end
        end
    end)

    -- Chờ tới khi bay xong
    repeat task.wait() until not flying
    stepConn:Disconnect()
    hbConn:Disconnect()
    print("✅ Đã tới tọa độ bay:", targetPos)
    task.wait(20) -- chờ 5 giây trước khi bay tiếp
end

-- Danh sách điểm bay
local flyPoints = {
    Vector3.new(-12007.47, 9529.38, -11910.67),
    Vector3.new(13.04, 37.35, -1500.01),
    Vector3.new(8999.53, 6814.95, 12011.76),
}

for _, pos in ipairs(flyPoints) do
    flyTo(pos, 100)
end

------------------------------------
-- 3) CLICK GUI PLAY TEMPLE TREK  --
------------------------------------
local function bagText(btn)
    local s = (btn.Name or "")
    if btn:IsA("TextButton") then s ..= " " .. (btn.Text or "") end
    for _,d in ipairs(btn:GetDescendants()) do
        if d:IsA("TextLabel") then s ..= " " .. (d.Text or "") end
    end
    return s:lower()
end

local function insetFor(obj)
    local sg = obj:FindFirstAncestorOfClass("ScreenGui")
    if sg and sg.IgnoreGuiInset then return Vector2.zero end
    return GuiService:GetGuiInset()
end

local function findBtn()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return end
    for _,g in ipairs(pg:GetDescendants()) do
        if (g:IsA("TextButton") or g:IsA("ImageButton")) and g.Visible and g.Active then
            local t = bagText(g)
            if t:find("temple trek") or t:find("play temple") or t:find("free") then
                return g
            end
        end
    end
end

local function clickPointsOn(btn)
    local pos, size = btn.AbsolutePosition, btn.AbsoluteSize
    local inset = insetFor(btn)
    local cx, cy = pos.X + size.X/2 + inset.X, pos.Y + size.Y/2 + inset.Y
    return {
        Vector2.new(cx, cy),
        Vector2.new(cx, cy + 10),
        Vector2.new(cx, cy + 18),
        Vector2.new(cx - size.X*0.25, cy + 8),
        Vector2.new(cx + size.X*0.25, cy + 8),
    }
end

local function fireMouseAt(btn, p)
    VIM:SendMouseButtonEvent(p.X, p.Y, 0, true, btn, 0)
    VIM:SendMouseButtonEvent(p.X, p.Y, 0, false, btn, 0)
end

local function fireTouchAt(btn, p)
    VIM:SendTouchEvent(p.X, p.Y, 1, true, btn)
    VIM:SendTouchEvent(p.X, p.Y, 1, false, btn)
end

local function robustClick(btn)
    task.wait(1)
    for _=1,3 do pcall(function() btn:Activate() end) task.wait(0.05) end
    local pts = clickPointsOn(btn)
    local t0 = os.clock()
    while os.clock() - t0 < 1.5 do
        for _,p in ipairs(pts) do
            fireMouseAt(btn, p)
            fireTouchAt(btn, p)
            task.wait(0.06)
        end
    end
    print("✅ Đã click 'Play Temple Trek'")
end

local btn = findBtn()
if btn then
    robustClick(btn)
else
    warn("⚠ Không tìm thấy nút 'Play Temple Trek'")
end

------------------------------------
-- 4) TELEPORT TUẦN TỰ 4 TỌA ĐỘ   --
------------------------------------
local function teleportTo(pos)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(pos)
    print("📍 Teleported to:", pos)
    task.wait(5) -- chờ 5 giây trước khi teleport tiếp
end

local teleportPoints = {
    Vector3.new(5917.25, 9992.50, 9000.61),
    Vector3.new(5825.16, 9992.50, 8974.40),
    Vector3.new(5742.24, 9992.50, 9019.49),
    Vector3.new(5721.12, 9992.50, 8999.03),
}

for _, pos in ipairs(teleportPoints) do
    teleportTo(pos)
end


