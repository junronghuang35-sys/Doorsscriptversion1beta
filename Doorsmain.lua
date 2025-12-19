--[[ 
    DOORS MASTER SCRIPT (Updated)
    - ESP Limit: 150 Studs (Anti-Lag)
    - Figure ESP: Red Highlight
    - Anti-Lag: Auto-hides distant objects
    - Full Light: Removed
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer

local Config = {
    DoorColor = Color3.fromRGB(0, 255, 100),
    KeyColor = Color3.fromRGB(255, 220, 0),
    BookColor = Color3.fromRGB(0, 160, 255),
    RushColor = Color3.fromRGB(255, 0, 0),    -- Entity Alert Color
    FigureColor = Color3.fromRGB(255, 0, 0),  -- Figure ESP Color (Red)
    MaxDistance = 150,                        -- Anti-lag limit
    TextSize = 16
}

local function applyESP(object, name, color)
    if not object:FindFirstChild("ObjectESP") then
        local bill = Instance.new("BillboardGui")
        bill.Name = "ObjectESP"
        bill.AlwaysOnTop = true
        bill.Size = UDim2.new(0, 100, 0, 50)
        bill.StudsOffset = Vector3.new(0, 2, 0)
        bill.Adornee = object
        
        local label = Instance.new("TextLabel")
        label.Name = "DistanceLabel"
        label.Parent = bill
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Text = name
        label.TextColor3 = color
        label.TextStrokeTransparency = 0
        label.TextSize = Config.TextSize
        label.Font = Enum.Font.SourceSansBold
        
        local h = Instance.new("Highlight")
        h.Name = "ESPHighlight"
        h.FillColor = color
        h.FillTransparency = 0.5
        h.OutlineColor = Color3.new(1, 1, 1)
        h.Parent = object
        bill.Parent = object
    end
end

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart

    for _, obj in pairs(workspace:GetDescendants()) do
        -- 1. Figure ESP (Red Highlight)
        if obj.Name == "FigureRagdoll" or (obj.Name == "Figure" and obj:IsA("Model")) then
            applyESP(obj, "🚨 FIGURE", Config.FigureColor)
        end

        -- 2. Rush/Ambush Detection
        if obj.Name == "RushMoving" or obj.Name == "AmbushMoving" then
            applyESP(obj, "⚠️ ENTITY", Config.RushColor)
        end

        -- 3. 150 Studs Distance & Lag Prevention
        local bill = obj:FindFirstChild("ObjectESP")
        local high = obj:FindFirstChild("ESPHighlight")
        if bill and high then
            local dist = (obj.Position - root.Position).Magnitude
            if dist > Config.MaxDistance then
                -- Hide distant items to prevent lag
                bill.Enabled = false
                high.Enabled = false
            else
                bill.Enabled = true
                high.Enabled = true
                local baseName = bill.DistanceLabel.Text:split(" [")[1]
                bill.DistanceLabel.Text = baseName .. " [" .. math.floor(dist) .. "m]"
            end
        end
    end
end)

task.spawn(function()
    while true do
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "LiveHintBook" or obj.Name == "Book" then
                applyESP(obj, "📘 Book", Config.BookColor)
            elseif obj.Name == "Key" or obj.Name == "LibraryKey" then
                applyESP(obj, "🔑 Key", Config.KeyColor)
            elseif obj.Name == "Door" and obj:IsA("Model") then
                local knob = obj:FindFirstChild("Knob") or obj.PrimaryPart
                if knob then 
                    applyESP(knob, "🚪 Door", Config.DoorColor) 
                end
            end
        end
        task.wait(2)
    end
end)

print("Doors Script with Figure ESP Loaded")
