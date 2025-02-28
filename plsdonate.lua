repeat wait() until game:IsLoaded()
local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local webhookURL = "https://discord.com/api/webhooks/1344888992298176543/vYHvnszbbfUaHKj_PHh8ITDVrg6S34I6T6smOGDM6MwXkc-l4vnNwR3wLecnDGmJZ-8F" -- Webhook của bạn

local settings = {
    autoChat = true,
    autoClaimStand = true,
    autoServerHop = true,
    serverHopTime = 1800, -- Đổi server sau 30 phút
    chatInterval = 15, -- Thời gian giữa mỗi tin nhắn (giây)
    minRobuxForRich = 10000 -- Chỉ vào server có người đã donate 10K+ Robux
}

-- 📌 Danh sách câu chat bằng tiếng Anh (100% tự nhiên)
local messages = {
    "💸 Help me reach my Robux goal! Any donation is appreciated! 💖",
    "🔥 Support my dream with a small donation! 🙏",
    "🎁 Every donation makes my day! Can you help me out? 😊",
    "💰 Even 1 Robux means a lot! Thank you so much! 🎉",
    "🌟 Looking for kind souls to donate! Every bit counts! ❤️",
    "🎮 I love creating content! Support me with a small donation! 💕",
    "🚀 Donate and I will give you a big shoutout! Thank you! 🙌",
    "🎉 Want to be my hero today? Even a little helps a lot! 😊",
    "💖 I appreciate every donation, no matter how small! Thank you!",
    "🔥 Be awesome today! Support me with Robux and make my day! 💸",
    "🎁 Donating is free kindness! Help me reach my goal! 😊",
    "🚀 Every Robux you give pushes me closer to my dream! 🎯",
    "🙏 Help a fellow Robloxian out! Any donation means the world to me! 💖",
    "🎉 Just a small donation can brighten my day! Help me out! 😊",
    "🔥 You are amazing! Donate and I will be super grateful! 🙌",
    "💰 Be a legend today! Even 2 Robux makes a difference! 💖",
    "🎮 I am saving up for game passes! Help me reach my goal! 🚀",
    "🌟 Want to make someone’s day? Donate and spread positivity! 💕",
    "💸 Looking for generous people! Every donation helps a lot! 🙏",
    "🎉 Thanks in advance for any support! You are the best! 💖"
}

-- 📌 Auto Claim Stand
local function claimStand()
    for _, v in pairs(workspace:GetChildren()) do
        if v.Name == "Booth" and not v:FindFirstChild("Owner") then
            firetouchinterest(player.Character.HumanoidRootPart, v.PrimaryPart, 0)
            wait(0.5)
            firetouchinterest(player.Character.HumanoidRootPart, v.PrimaryPart, 1)
            print("✅ Stand claimed successfully!")
            return true
        end
    end
    return false
end

-- 📌 Auto Chat để kêu gọi donate
local function autoChat()
    while settings.autoChat do
        local message = messages[math.random(1, #messages)]
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
        wait(settings.chatInterval)
    end
end

-- 📌 Gửi thông báo Discord khi có người donate
local function sendWebhook(amount, donor)
    local data = {
        ["content"] = "**🚀 You just received " .. amount .. " Robux from " .. donor .. "! 🎉**"
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
            sendWebhook(amount, "Anonymous Donor")
            print("✅ Received " .. amount .. " Robux!")
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
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/8737602449/servers/Public?sortOrder=Asc&limit=100"))
        for _, server in ipairs(servers.data) do
            if server.playing < server.maxPlayers then
                TeleportService:TeleportToPlaceInstance(8737602449, server.id, player)
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
            print("⏩ Searching for a richer server...")
            changeServer()
        else
            print("✅ Current server has rich players, no need to switch!")
        end
    end
end)

-- Kích hoạt các tính năng
if settings.autoClaimStand then spawn(claimStand) end
if settings.autoChat then spawn(autoChat) end
if webhookURL ~= "" then spawn(trackDonations) end
