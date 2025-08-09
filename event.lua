---------------------------
-- 1) EXIT HOME CLICKER  --
---------------------------
local Players = game:GetService("Players")
local VIM = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local POST_DELAY = 5 -- ⏳ đợi sau mỗi TP/Fly
local EXIT_DELAY = 10 -- ⏳ đợi sau Exit Home

local function screenInsetFor(guiObject)
    local sg = guiObject:FindFirstAncestorOfClass("ScreenGui")
    if sg and sg.IgnoreGuiInset then return Vector2.new(0, 0) end
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
                if d:IsA("TextLabel") then bag = bag .. " " .. (d.Text or "") end
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

-- Lặp click Exit Home 3 lần (có thể đổi số lần)
for i = 1, 3 do
    clickExitHomeGUI()
    task.wait(0.4)
end

-- Chờ 10 giây sau khi exit home xong
task.wait(EXIT_DELAY)

------------------------------------
-- 2) TELEPORT LIÊN TIẾP 4 TỌA ĐỘ  --
------------------------------------
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function teleportTo(pos)
    local hrp = getHRP()
    hrp.CFrame = CFrame.new(pos)
    print(("📍 Teleported to: (%.2f, %.2f, %.2f)"):format(pos.X,pos.Y,pos.Z))
    task.wait(POST_DELAY) -- đợi 5 giây
end

teleportTo(Vector3.new(5917.25, 9992.50, 9000.61))
teleportTo(Vector3.new(5825.16, 9992.50, 8974.40))
teleportTo(Vector3.new(5742.24, 9992.50, 9019.49))
teleportTo(Vector3.new(5721.12, 9992.50, 8999.03))

--------------------------------
-- 3) & 4) FLY MƯỢT + NOCLIP  --
--------------------------------
local flying, targetPos = false, nil
local flySpeed, arriveEps = 100, 3

-- Noclip khi đang bay
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

-- Gọi hàm này sẽ chờ tới nơi, rồi đợi thêm 5s
local function flyTo(pos, speed)
    targetPos = pos
    flySpeed = speed or 100
    flying = true
    while flying do task.wait(0.05) end
    task.wait(POST_DELAY)
end

-- 3) Bay tới 5699… (nhanh hơn)
flyTo(Vector3.new(5699.40, 9994.35, 8999.00), 200)

-- 4) Bay 3 tọa độ còn lại
flyTo(Vector3.new(-12007.47, 9529.38, -11910.67), 100)
flyTo(Vector3.new(13.04, 37.35, -1500.01), 100)
flyTo(Vector3.new(8999.53, 6814.95, 12011.76), 100)
