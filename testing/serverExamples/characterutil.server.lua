local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

local Lib = ReplicatedStorage:WaitForChild("lib");
local CharacterUtil = require(Lib:WaitForChild("CharacterUtil"));

Players.PlayerAdded:Connect(function(player)
    local character = CharacterUtil.GetCharacterFromPlayer(player);
    print(character:GetFullName());

    local humanoid = CharacterUtil.GetHumanoidFromCharacter(character);
    print(humanoid:GetFullName());

    local humanoidRootPart = CharacterUtil.GetHumanoidRootPartFromCharacter(character);
    print(humanoidRootPart:GetFullName());
end);