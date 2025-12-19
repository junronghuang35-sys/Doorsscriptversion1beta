--[[ 
    DOORS MASTER SCRIPT (Final Version)
    - Ambush Chat: "the Ambush coming!"
    - Rush Chat: "Rush incoming!"
    - Figure: NO Chat (Red ESP Only)
    - ESP Limit: 150 Studs (Anti-Lag)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer

local Config = {
    DoorColor = Color3.fromRGB(0, 255, 100),
    KeyColor = Color3.fromRGB(255, 220, 0),
    BookColor = Color3.fromRGB(0, 160, 255),
    RushColor = Color3.fromRGB(255, 0, 0),
    FigureColor = Color3.fromRGB(255, 0, 0), -- 红色 ESP
    MaxDistance = 150,                       -- 150 studs 限制
    TextSize = 16
}

-- 聊天警报函数
local function alertChat(message)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then channel:SendAsync(message) end
    else
        local event = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if event and event:FindFirstChild("SayMessageRequest") then
            event.SayMessageRequest:FireServer(message, "All")
        end
    end
end

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

local rushFound, ambushFound = false, false

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart

    -- 1. Figure 检测 (无聊天，仅红色 ESP)
    local figure = workspace:FindFirstChild("FigureRagdoll", true) or workspace:FindFirstChild("Figure", true)
    if figure and figure:IsA("Model") then
        applyESP(figure, "🚨 FIGURE", Config.FigureColor)
    end

    -- 2. Rush 检测
    local rush = workspace:FindFirstChild("RushMoving", true) or workspace:FindFirstChild("Rush", true)
    if rush and not rushFound then
        rushFound = true
        alertChat("Rush incoming!")
        applyESP(rush, "⚠️ RUSH", Config.RushColor)
    elseif not rush then
        rushFound = false
    end

    -- 3. Ambush 检测 (自定义聊天语)
    local ambush = workspace:FindFirstChild("AmbushMoving", true) or workspace:FindFirstChild("Ambush", true)
    if ambush and not ambushFound then
        ambushFound = true
        alertChat("the Ambush coming!")
        applyESP(ambush, "💀 AMBUSH", Config.RushColor)
    elseif not ambush then
        ambushFound = false
    end

    -- 4. 150 Studs 优化逻辑 (防卡顿)
    for _, obj in pairs(workspace:GetDescendants()) do
        local bill = obj:FindFirstChild("ObjectESP")
        local high = obj:FindFirstChild("ESPHighlight")
        if bill and high then
            local dist = (obj.Position - root.Position).Magnitude
            if dist > Config.MaxDistance then
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

-- 扫描钥匙、门和书本
task.spawn(function()
    while true do
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "LiveHintBook" or obj.Name == "Book" then
                applyESP(obj, "📘 Book", Config.BookColor)
            elseif obj.Name == "Key" or obj.Name == "LibraryKey" then
                applyESP(obj, "🔑 Key", Config.KeyColor)
            elseif obj.Name == "Door" and obj:IsA("Model") then
                local knob = obj:FindFirstChild("Knob") or obj.PrimaryPart
                if knob then applyESP(knob, "🚪 Door", Config.DoorColor) end
            end
        end
        task.wait(2)
    end
end)

print("Final Doors Script Loaded: All Settings Applied")
