local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager") -- Dùng API nội bộ

-- Tọa độ
local firstPos = Vector3.new(-589.57958984375, 35.797767639160156, -1668.39501953125)
local secondPos = Vector3.new(12015.556640625, 9927.240234375, 5950.45068359375)

-- Cờ kiểm soát
local cannonDetected = false

-- ✅ Auto click thực sự (bấm giữa màn hình)
local function simulateAutoClick(duration)
    duration = tonumber(duration) or 5
    local start = tick()
    local screenCenterX = workspace.CurrentCamera.ViewportSize.X / 2
    local screenCenterY = workspace.CurrentCamera.ViewportSize.Y / 2

    while tick() - start < duration do
        VirtualInputManager:SendMouseButtonEvent(screenCenterX, screenCenterY, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(screenCenterX, screenCenterY, 0, false, game, 0)
        task.wait(0.05)
    end
end

-- Lặp teleport về vị trí chờ đầu tiên mỗi 15 giây nếu chưa vào minigame
task.spawn(function()
    while true do
        if not cannonDetected then
            hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Parent then
                if not player.Character.PrimaryPart then
                    player.Character.PrimaryPart = hrp
                end
                player.Character:SetPrimaryPartCFrame(CFrame.new(firstPos))
                print("📍 Teleport giữ vị trí 1")
            end
        end
        task.wait(15)
    end
end)

-- Theo dõi khi "Cannon" xuất hiện để thực hiện teleport + auto click
Workspace.DescendantAdded:Connect(function(obj)
    if obj.Name == "Cannon" and not cannonDetected then
        cannonDetected = true
        print("🎯 Phát hiện Cannon → Teleport lần 2")

        hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Parent then
            if not player.Character.PrimaryPart then
                player.Character.PrimaryPart = hrp
            end
            player.Character:SetPrimaryPartCFrame(CFrame.new(secondPos))
            print("🚀 Đã teleport đến vị trí 2")
        else
            warn("❌ Không tìm thấy HRP để teleport!")
        end

        simulateAutoClick(110) -- click liên tục trong 70s

        -- ⏳ Reset lại sau 90s cho vòng sau
        task.delay(130, function()
            print("🔁 Reset lại để bắt đầu vòng mới")
            cannonDetected = false
        end)
    end
end)
