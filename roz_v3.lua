-- ROZ V3 Simple Speed Hack Script
game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 120
-- ROZ V3 Antilag Script | Game Locked: Strongest Battlegrounds
if game.PlaceId == 11349125039 then
    -- Antilag Boost
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Texture") or v:IsA("Decal") or v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Explosion") then
            v:Destroy()
        end
    end

    local lighting = game:GetService("Lighting")
    lighting.FogEnd = 100000
    lighting.FogStart = 0
    lighting.GlobalShadows = false
    lighting.Brightness = 0
else
    warn("ROZ V3 Antilag: Not Strongest Battlegrounds — script inactive.")
end
