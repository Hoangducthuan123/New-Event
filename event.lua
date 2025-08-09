-- ================== CONFIG ==================
local EXIT_WAIT = 10   -- chờ sau Exit Home (giây)
local POST_DELAY = 5   -- chờ sau mỗi lần bay/tele (giây)
local FLY_SPEED = 100  -- tốc độ bay mặc định (stud/s)

-- Waypoints (bay)
local FLY_POINTS = {
    {pos = Vector3.new(-12007.47, 9529.38, -11910.67), speed = 100},
    {pos = Vector3.new(13.04, 37.35, -1500.01),        speed = 100},
    {pos = Vector3.new(8999.53, 6814.95, 12011.76),    speed = 100},
}

-- Waypoints (teleport)
local TELE_POINTS = {
    Vector3.new(5917.25, 9992.50, 9000.61),
    Vector3.new(5825.16, 9992.50, 8974.40),
    Vector3.new(5742.24, 9992.50, 9019.49),
    Vector3.new(5721.12, 9992.50, 8999.03),
}

-- ================== SERVICES ==================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")

local lp = Players.LocalPlayer

-- ================== HELPERS ==================
local function getHRP()
    local char = lp.Character or lp.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

-- ===== Exit Home clicker =====
local function screenInsetFor(guiObject)
    local sg = guiObject:FindFirstAncestorOfClass("ScreenGui")
    if sg and sg.IgnoreGuiInset then return Vector2.new(0,0) end
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

local function findExitHomeButton()
    local pg = lp:FindFirstChild("PlayerGui")
    if not pg then return nil end
    for _, gui in ipairs(pg:GetDescendants()) do
        if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible then
            local bag = (gui.Name or "")
            if gui:IsA("TextButton") then bag ..= " " .. (gui.Text or "") end
            for _, d in ipairs(gui:GetDescendants()) do
                if d:IsA("TextLabel") then bag = bag .. " " .. (d.Text or "") end
            end
            if bag:lower():find("exit home") then
                return gui
            end
        end
    end
    return nil
end

local function spamExitHomeUntilGone(maxTime)
    local t0 = os.clock()
    while os.clock() - t0 < (maxTime or 8) do
        local btn = findExitHomeButton()
        if not btn then
            print("✅ Exit Home: không còn nút → coi như đã thoát.")
            return true
        end
        clickCenterLower(btn, 50)
        task.wait(0.3)
    end
    print("⚠ Exit Home: hết thời gian click, tiếp tục kịch bản.")
    return false
end

-- ===== Smooth Fly (one system) =====
local flying, targetPos = false, nil
local flySpeed, arriveEps = FLY_SPEED, 3

RunService.Stepped:Connect(function()
    if flying and lp.Character then
        for _, part in ipairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

RunService.Heartbeat:Connect(function(dt)
    if not flying or not targetPos then return end
    local char = lp.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then return end
    local hrp = char.HumanoidRootPart

    local dir = (targetPos - hrp.Position)
    local dist = dir.Magnitude
    if dist > arriveEps then
        local step = dir.Unit * flySpeed * dt
        if step.Magnitude > dist then step = dir end
        hrp.CFrame = hrp.CFrame + step
    else
        flying = false
        print(("✅ Đã tới: (%.2f, %.2f, %.2f)"):format(targetPos.X, targetPos.Y, targetPos.Z))
    end
end)

local function flyTo(pos, speed)
    targetPos = pos
    flySpeed = speed or FLY_SPEED
    flying = true
    while flying do task.wait(0.05) end
    task.wait(POST_DELAY)
end

-- ===== Robust click "Play Temple Trek" =====
local function bagText(btn)
    local s = (btn.Name or "")
    if btn:IsA("TextButton") then s ..= " " .. (btn.Text or "") end
    for _,d in ipairs(btn:GetDescendants()) do
        if d:IsA("TextLabel") then s ..= " " .. (d.Text or "") end
    end
    return s:lower()
end

local function findTempleBtn()
    local pg = lp:FindChild("PlayerGui") or lp:FindFirstChild("PlayerGui")
    if not pg then pg = lp:WaitForChild("PlayerGui", 5) end
    if not pg then return nil end
    for _,g in ipairs(pg:GetDescendants()) do
        if (g:IsA("TextButton") or g:IsA("ImageButton")) and g.Visible and g.Active then
            local t = bagText(g)
            if t:find("temple trek") or t:find("play temple") or t:find("free") then
                return g
            end
        end
    end
    return nil
end

local function insetFor(obj)
    local sg = obj:FindFirstAncestorOfClass("ScreenGui")
    if sg and sg.IgnoreGuiInset then return Vector2.zero end
    return GuiService:GetGuiInset()
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

local function clickTempleTrek()
    local btn = findTempleBtn()
    if not btn then
        warn("⚠ Không tìm thấy nút 'Play Temple Trek'")
        return false
    end
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
    return true
end

-- ================== SEQUENCE ==================

-- 1) Exit Home (spam cho tới khi biến mất), đợi 10s
spamExitHomeUntilGone(10)
task.wait(EXIT_WAIT)

-- 2) Fly 3 điểm (mỗi điểm chờ 5s)
for _, wp in ipairs(FLY_POINTS) do
    flyTo(wp.pos, wp.speed or FLY_SPEED)
end

-- 3) Click GUI "Play Temple Trek"
clickTempleTrek()
task.wait(POST_DELAY)

-- 4) Teleport 4 điểm (mỗi lần chờ 5s)
for _, pos in ipairs(TELE_POINTS) do
    local hrp = getHRP()
    hrp.CFrame = CFrame.new(pos)
    print(("📍 Teleported to: (%.2f, %.2f, %.2f)"):format(pos.X, pos.Y, pos.Z))
    task.wait(POST_DELAY)
end

print("🏁 Hoàn tất: Exit Home → Fly ×3 → Click Temple Trek → Teleport ×4")
