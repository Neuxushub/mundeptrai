repeat wait() until game:IsLoaded()
local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local webhookURL = "https://discord.com/api/webhooks/1344888992298176543/vYHvnszbbfUaHKj_PHh8ITDVrg6S34I6T6smOGDM6MwXkc-l4vnNwR3wLecnDGmJZ-8F" -- Thay bằng webhook Discord của bạn
local placeID = 8737602449 -- ID của game Pls Donate

local settings = {
    autoChat = true,
    autoClaimStand = true,
    autoServerHop = true,
    serverHopTime = 1800, -- 30 phút (1800 giây)
    chatInterval = 15, -- Số giây giữa mỗi tin nhắn
    minRobuxForRich = 10000 -- Chỉ vào server có người trên 10K Robux
}

-- 📌 Auto Claim Stand
local function claimStand()
    for _, v in pairs(workspace:GetChildren()) do
        if v.Name == "Booth" and not v:FindFirstChild("Owner") then
            firetouchinterest(player.Character.HumanoidRootPart, v.PrimaryPart, 0)
            wait(0.5)
            firetouchinterest(player.Character.HumanoidRootPart, v.PrimaryPart, 1)
            print("✅ Đã chiếm stand thành công!")
            return true
        end
    end
    return false
end

-- 📌 Auto Chat để kêu gọi donate
local function autoChat()
    local messages = {
        "💸 Hỗ trợ mình chút Robux nào! 💖",
        "🙏 Mình đang tiết kiệm Robux, giúp mình nhé!",
        "🎁 Donate để nhận lời cảm ơn lớn!",
        "🔥 Cần Robux để làm content, giúp mình nào!"
    }
    while settings.autoChat do
        local message = messages[math.random(1, #messages)]
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
        wait(settings.chatInterval)
    end
end

-- 📌 Gửi thông báo Discord khi có người donate
local function sendWebhook(amount, donor)
    local data = {
        ["content"] = "**🚀 Bạn vừa nhận được " .. amount .. " Robux từ " .. donor .. "! 🎉**"
    }
    local jsonData = HttpService:JSONEncode(data)
    HttpService:PostAsync(webhookURL, jsonData, Enum.HttpContentType.ApplicationJson)
end

-- 📌 Theo dõi giao dịch donate
local function trackDonations()
    local lastRobux = player.leaderstats.Robux.Value
    while true do
        wait(2)
        local currentRobux = player.leaderstats.Robux.Value
        if currentRobux > lastRobux then
            local amount = currentRobux - lastRobux
            sendWebhook(amount, "Người ẩn danh")
            print("✅ Nhận được " .. amount .. " Robux!")
            lastRobux = currentRobux
        end
    end
end

-- 📌 Kiểm tra xem có người giàu trong server không
local function isRichServer()
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("Donated") then
            local donatedAmount = plr.leaderstats.Donated.Value
            if donatedAmount >= settings.minRobuxForRich then
                return true
            end
        end
    end
    return false
end

-- 📌 Auto Server Hop (chỉ vào server giàu)
local function changeServer()
    while true do
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeID .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, server in ipairs(servers.data) do
            if server.playing < server.maxPlayers then
                TeleportService:TeleportToPlaceInstance(placeID, server.id, player)
                return
            end
        end
        wait(5)
    end
end

-- 📌 Auto Server Hop mỗi 30 phút (chỉ vào server rich)
spawn(function()
    while settings.autoServerHop do
        wait(settings.serverHopTime) -- Chờ 30 phút
        if not isRichServer() then
            print("⏩ Đang tìm server rich hơn...")
            changeServer()
        else
            print("✅ Server hiện tại đã có người giàu, không cần đổi!")
        end
    end
end)

-- Kích hoạt các tính năng
if settings.autoClaimStand then spawn(claimStand) end
if settings.autoChat then spawn(autoChat) end
if webhookURL ~= "" then spawn(trackDonations) end
