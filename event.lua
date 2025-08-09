---------------------------
-- 1) CLICK "PLAY TEMPLE TREK"
---------------------------
local Players = game:GetService("Players")
local VIM = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local function screenInsetFor(guiObject)
    local sg = guiObject:FindFirstAncestorOfClass("ScreenGui")
    if sg and sg.IgnoreGuiInset then return Vector2.new(0, 0) end
    return GuiService:GetGuiInset()
end

local function clickCenter(btn)
    pcall(function() btn:Activate() end)
    local pos, size = btn.AbsolutePosition, btn.AbsoluteSize
    local inset = screenInsetFor(btn)
    local cx = pos.X + size.X/2 + inset.X
    local cy = pos.Y + size.Y/2 + inset.Y
    VIM:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
    VIM:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
end

local function findAndClickPlayTemple()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return false end
    for _, gui in ipairs(pg:GetDescendants()) do
        if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible and gui.Active then
            local textContent = (gui.Name or "")
            if gui:IsA("TextButton") then textContent ..= " " .. (gui.Text or "") end
            for _, label in ipairs(gui:GetDescendants()) do
                if label:IsA("TextLabel") then textContent ..= " " .. (label.Text or "") end
            end
            if textContent:lower():find("play temple trek") then
                clickCenter(gui)
                print("✅ Clicked Play Temple Trek")
                return true
            end
        end
    end
    return false
end

for _ = 1, 6 do
    if findAndClickPlayTemple() then break end
    task.wait(0.4)
end

-- Chờ 5 giây sau khi click
task.wait(5)

---------------------------
-- 2) TELEPORT 4 TỌA ĐỘ
---------------------------
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function teleportTo(pos)
    local hrp = getHRP()
    hrp.CFrame = CFrame.new(pos)
    print(("📍 Teleported to: (%.2f, %.2f, %.2f)"):format(pos.X,pos.Y,pos.Z))
    task.wait(5)
end

teleportTo(Vector3.new(5917.25, 9992.50, 9000.61))
teleportTo(Vector3.new(5825.16, 9992.50, 8974.40))
teleportTo(Vector3.new(5742.24, 9992.50, 9019.49))
teleportTo(Vector3.new(5721.12, 9992.50, 8999.03))

---------------------------
-- 3) BAY MƯỢT + NOCLIP (SAU TELE)
---------------------------
local flying, targetPos = false, nil
local flySpeed, arriveEps = 100, 3

-- Noclip chỉ khi đang bay
RunService.Stepped:Connect(function()
    if flying and player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- Di chuyển mượt
RunService.Heartbeat:Connect(function(dt)
    if not flying or not targetPos then return end
    local char = player.Character
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

local function flyTo(pos, speed, postDelay)
    targetPos = pos
    flySpeed = speed or 100
    flying = true
    while flying do task.wait(0.05) end
    task.wait(postDelay or 5)
end

-- Lịch bay sau teleport (điểm 5699 bay nhanh hơn)
flyTo(Vector3.new(-12007.47, 9529.38, -11910.67), 100, 5)
flyTo(Vector3.new(13.04, 37.35, -1500.01), 100, 5)
flyTo(Vector3.new(8999.53, 6814.95, 12011.76), 100, 5)
flyTo(Vector3.new(5699.40, 9994.35, 8999.00), 200, 5)

print("🏁 Hoàn tất: Click GUI → Teleport → Fly")
