local Promise = require(script.Promise);
local CharacterUtil = {};

local function cWarn(...)
    warn("[CharacterUtil]", ...);
end

local function cPrint(...)
    print("[CharacterUtil]", ...);
end

local function WaitForObject(parent, name)
    return Promise.new(function(resolve, reject)
        local object = parent:FindFirstChild(name);
        if object then
            resolve(object);
        else
            local objectAddedConnection;
            objectAddedConnection = parent.ChildAdded:Connect(function(child)
                if (child.Name == name) then
                    objectAddedConnection:Disconnect();
                    resolve(child);
                end;
            end);
        end;
    end);
end

local function WaitForCharacter(player)
    return Promise.new(function(resolve, reject)
        local character = player.Character;
        if character then
            resolve(character);
        else
            local characterAddedConnection;
            characterAddedConnection = player.CharacterAdded:Connect(function(newCharacter)
                characterAddedConnection:Disconnect();
                resolve(newCharacter);
            end);
        end;
    end);
end

function CharacterUtil.GetCharacterFromPlayer(player)
    -- Automatically waits for the character to be added to the player
    if (player.Character) then
        return player.Character;
    end;

    local Success, Character = WaitForCharacter(player):await();
    if (not Success) then
        cWarn("CharacterUtil.GetCharacterFromPlayer", "Failed to get character from player", player);
        return nil;
    end;

    return Character;
end

function CharacterUtil.GetHumanoidFromCharacter(character)
    if (character:FindFirstChild("Humanoid")) then
        return character.Humanoid;
    end;

    -- Automatically waits for the humanoid to be added to the character
    local Success, Humanoid = WaitForObject(character, "Humanoid"):await();
    if (not Success) then
        cWarn("CharacterUtil.GetHumanoidFromCharacter", "Failed to get humanoid from character", character);
        return nil;
    end;

    return Humanoid;
end

function CharacterUtil.GetHumanoidRootPartFromCharacter(character)
    if (character:FindFirstChild("HumanoidRootPart")) then
        return character.HumanoidRootPart;
    end;

    -- Automatically waits for the humanoid root part to be added to the character
    local Success, HumanoidRootPart = WaitForObject(character, "HumanoidRootPart"):await();
    if (not Success) then
        cWarn("CharacterUtil.GetHumanoidRootPartFromCharacter", "Failed to get humanoid root part from character", character);
        return nil;
    end;

    return HumanoidRootPart;
end

function CharacterUtil.GetHumanoidFromPlayer(player)
    local Character = CharacterUtil.GetCharacterFromPlayer(player);
    if (not Character) then
        cWarn("CharacterUtil.GetHumanoidFromPlayer", "Failed to get character from player", player);
        return nil;
    end;

    return CharacterUtil.GetHumanoidFromCharacter(Character);
end

function CharacterUtil.GetHumanoidRootPartFromPlayer(player)
    local Character = CharacterUtil.GetCharacterFromPlayer(player);
    if (not Character) then
        cWarn("CharacterUtil.GetHumanoidRootPartFromPlayer", "Failed to get character from player", player);
        return nil;
    end;

    return CharacterUtil.GetHumanoidRootPartFromCharacter(Character);
end

return table.freeze(CharacterUtil);