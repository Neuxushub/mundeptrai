local workspace = game.Workspace
local lighting = game:GetService("Lighting")

-- 1. Làm tất cả vật thể trong Workspace vô hình nhưng vẫn giữ hitbox
for _, obj in pairs(workspace:GetDescendants()) do
    if obj:IsA("BasePart") then
        obj.Transparency = 1 -- Làm vật thể vô hình
        obj.Material = Enum.Material.SmoothPlastic -- Giảm chi tiết vật liệu
        obj.CastShadow = false -- Tắt đổ bóng
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj:Destroy() -- Xóa decal & texture để giảm lag
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
        obj:Destroy() -- Xóa hiệu ứng hạt, ánh sáng, vệt sáng
    elseif obj:IsA("Sound") then
        obj:Destroy() -- Xóa tất cả âm thanh
    end
end

-- 2. Xóa toàn bộ hiệu ứng ánh sáng
lighting.GlobalShadows = false
lighting.Brightness = 1
lighting.Ambient = Color3.fromRGB(255, 255, 255)
lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
lighting.FogEnd = 1000000 -- Tắt sương mù
lighting.Technology = Enum.Technology.Compatibility -- Giảm tải hiệu ứng ánh sáng

-- 3. Xóa nước (nếu có) để giảm lag
if workspace:FindFirstChildOfClass("Terrain") then
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    terrain:Clear() -- Xóa địa hình nước
end

-- 4. Giữ lại UI nhưng ẩn tất cả mô hình 3D
local player = game.Players.LocalPlayer
player.CharacterAdded:Connect(function(character)
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.Transparency = 1 -- Làm nhân vật vô hình nhưng vẫn có hitbox
        end
    end
end)