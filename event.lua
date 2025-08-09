---------------------------
-- 1) CLICK GUI "Play Temple Trek"
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
            if gui:IsA("TextButton") then
                textContent ..= " " .. (gui.Text or "")
            end
            for _, label in ipairs(gui:GetDescendants()) do
                if label:IsA("TextLabel") then
                    textContent = textContent .. " " .. (label.Text or "")
                end
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
        task.wait(5) -- Chờ 5 giây giữa mỗi lần teleport
    end
end
