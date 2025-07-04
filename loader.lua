-- loader.lua
-- UI Toggle Panel + Aimbot + Hitbox Expander + Kill Aura

-- ▼ SETTINGS ▼
getgenv().FOV = 120
getgenv().TargetPart = "Head"
getgenv().HitboxSize = Vector3.new(8, 8, 8)
getgenv().Transparency = 0.5
getgenv().AuraRange = 13
getgenv().AuraDelay = 0.2

-- ▼ STATES ▼
getgenv().AimbotOn = true
getgenv().HitboxOn = true
getgenv().KillAuraOn = true

-- ▼ SERVICES ▼
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ▼ CREATE UI ▼
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Position = UDim2.new(0, 20, 0, 80)
Frame.Size = UDim2.new(0, 160, 0, 150)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local function createButton(name, yOffset, defaultText, callback)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = UDim2.new(0, 5, 0, yOffset)
    btn.Text = defaultText
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ▼ BUTTONS ▼
local AimbotBtn = createButton("Aimbot", 5, "Aimbot: ON", function()
    AimbotOn = not AimbotOn
    AimbotBtn.Text = "Aimbot: " .. (AimbotOn and "ON" or "OFF")
end)

local HitboxBtn = createButton("Hitbox", 50, "Hitbox: ON", function()
    HitboxOn = not HitboxOn
    HitboxBtn.Text = "Hitbox: " .. (HitboxOn and "ON" or "OFF")
end)

local AuraBtn = createButton("KillAura", 95, "KillAura: ON", function()
    KillAuraOn = not KillAuraOn
    AuraBtn.Text = "KillAura: " .. (KillAuraOn and "ON" or "OFF")
end)

-- ▼ FOV CIRCLE ▼
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = true
fovCircle.Radius = FOV
fovCircle.Color = Color3.fromRGB(0, 255, 0)
fovCircle.Thickness = 1
fovCircle.Filled = false
fovCircle.Transparency = 0.4

-- ▼ HITBOX EXPAND ▼
function ExpandHitboxes()
    for _, plr in ipairs(Players:GetPlayers()) do
        if HitboxOn and plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(TargetPart) then
            local part = plr.Character[TargetPart]
            if part:IsA("BasePart") then
                part.Size = HitboxSize
                part.Transparency = Transparency
                part.Material = Enum.Material.ForceField
                part.BrickColor = BrickColor.new("Bright red")
                part.CanCollide = false
            end
        end
    end
end

-- ▼ GET CLOSEST ▼
function GetClosestTarget()
    local closest, shortest = nil, FOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(TargetPart) and plr.Character:FindFirstChild("Humanoid") then
            if plr.Character.Humanoid.Health > 0 then
                local part = plr.Character[TargetPart]
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < shortest then
                        closest = part
                        shortest = dist
                    end
                end
            end
        end
    end
    return closest
end

-- ▼ KILL AURA ▼
function MeleeKillAura()
    if not KillAuraOn then return end
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if root and (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= AuraRange then
                tool:Activate()
            end
        end
    end
end

-- ▼ RUN THREADS ▼
task.spawn(function()
    while task.wait(0.1) do
        if HitboxOn then pcall(ExpandHitboxes) end
    end
end)

task.spawn(function()
    while task.wait(AuraDelay) do
        pcall(MeleeKillAura)
    end
end)

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    if AimbotOn then
        local target = GetClosestTarget()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

print("✅ UI Aimbot/Hitbox/KillAura loaded.")
