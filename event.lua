---------------------------
-- 1) EXIT HOME CLICKER  --
---------------------------
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

for _ = 1, 6 do
    if clickExitHomeGUI() then break end
    task.wait(0.4)
end

-- Chờ 5 giây sau Exit Home
task.wait(5)

------------------------------------
-- 2) TELEPORT LIÊN TIẾP 4 TỌA ĐỘ  --
------------------------------------
local hrp = player.Character and player.Character:WaitForChild("HumanoidRootPart")

local teleportPoints = {
    Vector3.new(5917.25, 9992.50, 9000.61),
    Vector3.new(5825.16, 9992.50, 8974.40),
    Vector3.new(5742.24, 9992.50, 9019.49),
    Vector3.new(5721.12, 9992.50, 8999.03),
}

for _, pos in ipairs(teleportPoints) do
    if hrp and hrp.Parent then
        hrp.CFrame = CFrame.new(pos)
        print("📍 Teleported to:", pos)
        task.wait(0.5)
    end
end

---------------------------
-- 3) BAY MƯỢT 5699…      --
---------------------------
local function flyTo(targetPos, speed)
    local flying = true
    local RunService = game:GetService("RunService")
    RunService.Stepped:Connect(function()
        if flying and player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
    RunService.Heartbeat:Connect(function(dt)
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
                print("✅ Đã tới tọa độ!", targetPos)
            end
        end
    end)
end

flyTo(Vector3.new(5699.40, 9994.35, 8999.00), 200)

---------------------------
-- 4) BAY MƯỢT 3 TỌA ĐỘ   --
---------------------------
task.wait(2) -- đợi tí cho bay trước xong

local flyPoints = {
    Vector3.new(-12007.47, 9529.38, -11910.67),
    Vector3.new(13.04, 37.35, -1500.01),
    Vector3.new(8999.53, 6814.95, 12011.76),
}

for _, pos in ipairs(flyPoints) do
    flyTo(pos, 100)
    task.wait(2)
end
