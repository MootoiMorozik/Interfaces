local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESP_UI"
screenGui.ResetOnSpawn = false

pcall(function()
    screenGui.Parent = CoreGui
end)

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 100)
mainFrame.Position = UDim2.new(0, 10, 1, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.BackgroundTransparency = 0.1
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleESP"
toggleButton.Text = "ESP: OFF"
toggleButton.Size = UDim2.new(1, -20, 0, 35)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.Gotham
toggleButton.TextSize = 18
toggleButton.Parent = mainFrame

local toggleCorner = Instance.new
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = toggleButton

local chancesLabel = Instance.new("TextLabel")
chancesLabel.Name = "ChancesLabel"
chancesLabel.Text = "Шанс убийцы: ?%\nШанс шерифа: ?%"
chancesLabel.Size = UDim2.new(1, -20, 0, 45)
chancesLabel.Position = UDim2.new(0, 10, 0, 50)
chancesLabel.BackgroundTransparency = 1
chancesLabel.TextColor3 = Color3.new(1, 1, 1)
chancesLabel.TextXAlignment = Enum.TextXAlignment.Left
chancesLabel.TextYAlignment = Enum.TextYAlignment.Top
chancesLabel.Font = Enum.Font.Gotham
chancesLabel.TextSize = 16
chancesLabel.Parent = mainFrame

local espEnabled = false
local currentESP = {}

local function createESP(player, role)
    if player.Character and player.Character:FindFirstChild("Head") and not currentESP[player] then
        local billboard = Instance.new("BillboardGui", player.Character.Head)
        billboard.Name = "ESP_Billboard"
        billboard.Size = UDim2.new(0, 100, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true

        local textLabel = Instance.new("TextLabel", billboard)
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = (role == "Murderer") and Color3.new(1, 0, 0) or Color3.new(0, 0, 1)
        textLabel.Text = role
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 14

        currentESP[player] = billboard
    end
end

local function clearESP()
    for player, gui in pairs(currentESP) do
        if gui and gui.Parent then
            gui:Destroy()
        end
    end
    currentESP = {}
end

local function updateESP()
    clearESP()

    for _, player in ipairs(Players:GetPlayers()) do
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            if backpack:FindFirstChild("Knife") then
                createESP(player, "Murderer")
            elseif backpack:FindFirstChild("Gun") then
                createESP(player, "Sheriff")
            end
        end
    end
end

local function updateChances()
    local stats = localPlayer:FindFirstChild("MM2_Stats")
    if stats then
        local murdererChance = stats:FindFirstChild("MurdererChance")
        local sheriffChance = stats:FindFirstChild("SheriffChance")

        chancesLabel.Text = string.format("Шанс убийцы: %s%%\nШанс шерифа: %s%%",
            murdererChance and murdererChance.Value or "?",
            sheriffChance and sheriffChance.Value or "?"
        )
    end
end

toggleButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    toggleButton.Text = espEnabled and "ESP: ON" or "ESP: OFF"

    if espEnabled then
        updateESP()
    else
        clearESP()
    end
end)

RunService.RenderStepped:Connect(function()
    if espEnabled then
        pcall(updateESP)
    end
    pcall(updateChances)
end)