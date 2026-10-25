-- [[ 🚗 ZING LANG THANON: AUTOMATED ONLINE WHITELIST HUB 🚗 ]] --

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- 🔗 ลิงก์ Raw อ่านค่า Whitelist จาก Repository ของคุณ
local WhitelistUrl = "https://raw.githubusercontent.com/jirayuplaypach000-commits/ZLTN-whitelist/main/whitelist.json"

local function CheckOnlineWhitelist()
    local success, response = pcall(function()
        return game:HttpGet(WhitelistUrl)
    end)
    
    if success then
        local data = pcall(function() return HttpService:JSONDecode(response) end) and HttpService:JSONDecode(response)
        if data and data.whitelisted_users then
            for _, id in ipairs(data.whitelisted_users) do
                if tonumber(id) == tonumber(LocalPlayer.UserId) then
                    return true
                end
            end
        end
    end
    return false
end

-- ตรวจสอบสิทธิ์ Whitelist
if not CheckOnlineWhitelist() then
    LocalPlayer:Kick("❌ [ZLTN SECURITY] ไอดีของคุณ (" .. tostring(LocalPlayer.UserId) .. ") ไม่ได้รับอนุญาต! กรุณาลงชื่อรับสคริปต์ใน Discord")
    return
end

print("✅ [AUTH SUCCESS] ยินดีต้อนรับ " .. LocalPlayer.Name)

-- ลบ UI เก่าหากมีอยู่
if CoreGui:FindFirstChild("ZLTN_MasterHub") then
    CoreGui.ZLTN_MasterHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZLTN_MasterHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

----------------------------------------------------------------
-- 🚗 UI ปุ่มลอยมุมบนขวา + ระบบ Smooth Rate (50, 100, 150, 175)
----------------------------------------------------------------
local VehicleSpeedEnabled = false
local TargetSpeedValue = 50
local CurrentSmoothSpeed = 0
local SmoothLevel = 50

-- ปุ่ม RATE [ซ้ายสุด]
local RateBtn = Instance.new("TextButton")
RateBtn.Size = UDim2.new(0, 48, 0, 48)
RateBtn.Position = UDim2.new(1, -285, 0, 17)
RateBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 160)
RateBtn.Text = "RATE\nx50"
RateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RateBtn.TextSize = 10
RateBtn.Font = Enum.Font.GothamBold
RateBtn.ZIndex = 100
RateBtn.Parent = ScreenGui
Instance.new("UICorner", RateBtn).CornerRadius = UDim.new(1, 0)
local RateStroke = Instance.new("UIStroke", RateBtn)
RateStroke.Color = Color3.fromRGB(180, 100, 255)
RateStroke.Thickness = 2

local RateDisplay = Instance.new("TextLabel")
RateDisplay.Size = UDim2.new(0, 52, 0, 18)
RateDisplay.Position = UDim2.new(0, -2, 0, -22)
RateDisplay.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
RateDisplay.Text = "RATE: x50"
RateDisplay.TextColor3 = Color3.fromRGB(200, 150, 255)
RateDisplay.Font = Enum.Font.GothamBold
RateDisplay.TextSize = 9
RateDisplay.ZIndex = 101
RateDisplay.Parent = RateBtn
Instance.new("UICorner", RateDisplay).CornerRadius = UDim.new(0, 4)

-- ปุ่ม - (ลดความเร็ว)
local MinusBtn = Instance.new("TextButton")
MinusBtn.Size = UDim2.new(0, 48, 0, 48)
MinusBtn.Position = UDim2.new(1, -230, 0, 17)
MinusBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 60)
MinusBtn.Text = "-\n10"
MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusBtn.TextSize = 10
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.ZIndex = 100
MinusBtn.Parent = ScreenGui
Instance.new("UICorner", MinusBtn).CornerRadius = UDim.new(1, 0)
local MinusStroke = Instance.new("UIStroke", MinusBtn)
MinusStroke.Color = Color3.fromRGB(255, 80, 100)
MinusStroke.Thickness = 2

-- ปุ่ม + (เพิ่มความเร็ว)
local PlusBtn = Instance.new("TextButton")
PlusBtn.Size = UDim2.new(0, 48, 0, 48)
PlusBtn.Position = UDim2.new(1, -175, 0, 17)
PlusBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 100)
PlusBtn.Text = "+\n10"
PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusBtn.TextSize = 10
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.ZIndex = 100
PlusBtn.Parent = ScreenGui
Instance.new("UICorner", PlusBtn).CornerRadius = UDim.new(1, 0)
local PlusStroke = Instance.new("UIStroke", PlusBtn)
PlusStroke.Color = Color3.fromRGB(80, 255, 150)
PlusStroke.Thickness = 2

local SpeedDisplay = Instance.new("TextLabel")
SpeedDisplay.Size = UDim2.new(0, 52, 0, 18)
SpeedDisplay.Position = UDim2.new(0, -2, 0, -22)
SpeedDisplay.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
SpeedDisplay.Text = "SPD: 50"
SpeedDisplay.TextColor3 = Color3.fromRGB(0, 230, 255)
SpeedDisplay.Font = Enum.Font.GothamBold
SpeedDisplay.TextSize = 9
SpeedDisplay.ZIndex = 101
SpeedDisplay.Parent = PlusBtn
Instance.new("UICorner", SpeedDisplay).CornerRadius = UDim.new(0, 4)

-- ปุ่ม 🚗 ON/OFF [ขวาสุด]
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 52, 0, 52)
ToggleBtn.Position = UDim2.new(1, -115, 0, 15)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
ToggleBtn.Text = "🚗\nOFF"
ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
ToggleBtn.TextSize = 10
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.ZIndex = 100
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = Color3.fromRGB(0, 230, 255)
ToggleStroke.Thickness = 2

----------------------------------------------------------------
-- Event Control & Engine
----------------------------------------------------------------
local function UpdateDisplay()
    SpeedDisplay.Text = "SPD: " .. tostring(TargetSpeedValue)
    RateDisplay.Text = "RATE: x" .. tostring(SmoothLevel)
    RateBtn.Text = "RATE\nx" .. tostring(SmoothLevel)
end

local presetRates = {50, 100, 150, 175}
local currentPresetIdx = 1

RateBtn.MouseButton1Click:Connect(function()
    currentPresetIdx = (currentPresetIdx % #presetRates) + 1
    SmoothLevel = presetRates[currentPresetIdx]
    UpdateDisplay()
end)

MinusBtn.MouseButton1Click:Connect(function()
    TargetSpeedValue = math.clamp(TargetSpeedValue - 10, 1, 500)
    UpdateDisplay()
end)

PlusBtn.MouseButton1Click:Connect(function`()
    TargetSpeedValue = math.clamp(TargetSpeedValue + 10, 1, 500)
    UpdateDisplay()
end)

ToggleBtn.MouseButton1Click:Connect(function()
    VehicleSpeedEnabled = not VehicleSpeedEnabled
    if VehicleSpeedEnabled then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        ToggleBtn.Text = "🚗\nON"
        ToggleStroke.Color = Color3.fromRGB(0, 255, 128)
    else
        VehicleSpeedEnabled = false
        CurrentSmoothSpeed = 0
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
        ToggleBtn.Text = "🚗\nOFF"
        ToggleStroke.Color = Color3.fromRGB(0, 230, 255)
    end
end)

RunService.Heartbeat:Connect(function(dt)
    if VehicleSpeedEnabled then
        local lerpFactor = math.clamp((3.0 / SmoothLevel) * dt * 4, 0.00005, 1)
        CurrentSmoothSpeed = CurrentSmoothSpeed + (TargetSpeedValue - CurrentSmoothSpeed) * lerpFactor

        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.SeatPart then
                local seat = hum.SeatPart
                local vehicleModel = seat:FindFirstAncestorOfClass("Model") or seat.Parent
                local primaryPart = (vehicleModel:IsA("Model") and vehicleModel.PrimaryPart) or seat

                if primaryPart then
                    local forwardVector = primaryPart.CFrame.LookVector
                    local currentVel = primaryPart.AssemblyLinearVelocity
                    
                    if currentVel.Magnitude > 2 then
                        primaryPart.AssemblyLinearVelocity = Vector3.new(
                            forwardVector.X * CurrentSmoothSpeed * 2.5,
                            currentVel.Y,
                            forwardVector.Z * CurrentSmoothSpeed * 2.5
                        )
                    end
                end
            end
        end
    else
        if CurrentSmoothSpeed > 0.5 then
            CurrentSmoothSpeed = CurrentSmoothSpeed + (0 - CurrentSmoothSpeed) * math.clamp(dt * 2, 0, 1)
        else
            CurrentSmoothSpeed = 0
        end
    end
end)
