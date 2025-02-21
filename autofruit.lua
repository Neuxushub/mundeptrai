repeat wait() until game:IsLoaded()
local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

local settings = {
    autoCollectFruit = true,
    autoAttackFactory = true,
    autoChangeServer = true,
    attackInterval = 0.1
}

-- 📌 Tự động spam chuột trái để tấn công
local function spamClick()
    while settings.autoAttackFactory do
        VirtualUser:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        wait(0.05) -- Tăng tốc độ đánh
    end
end

-- 📌 Tự động nhặt Trái Ác Quỷ trên bản đồ
local function collectFruits()
    while settings.autoCollectFruit do
        local found = false
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
                found = true
                player.Character.HumanoidRootPart.CFrame = obj.Handle.CFrame
                wait(0.5)
                firetouchinterest(player.Character.HumanoidRootPart, obj.Handle, 0)
                firetouchinterest(player.Character.HumanoidRootPart, obj.Handle, 1)
            end
        end
        if not found and settings.autoChangeServer then
            changeServer()
        end
        wait(2)
    end
end

-- 📌 Kiểm tra Factory có mở không
local function isFactoryOpen()
    local factory = workspace:FindFirstChild("Factory")
    return factory and factory:FindFirstChild("Humanoid") and factory.Humanoid.Health > 0
end

-- 📌 Auto đánh Factory
local function attackFactory()
    while settings.autoAttackFactory do
        if isFactoryOpen() then
            spawn(spamClick) -- Bắt đầu spam chuột trái
            repeat
                ReplicatedStorage.Remotes.CommF_:FireServer("Attack")
                wait(settings.attackInterval)
            until not isFactoryOpen()
        elseif settings.autoChangeServer then
            changeServer()
        end
        wait(5)
    end
end

-- 📌 Đổi server nếu không có Factory hoặc TAQ
function changeServer()
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/2753915549/servers/Public?sortOrder=Asc&limit=100"))
    for _, server in ipairs(servers.data) do
        if server.playing < server.maxPlayers then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, player)
            return
        end
    end
end

-- Kích hoạt các chức năng
spawn(collectFruits)
spawn(attackFactory)
