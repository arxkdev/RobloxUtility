local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Lib = ReplicatedStorage:WaitForChild("lib");
local Button = require(Lib:WaitForChild("Button"));
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui");
local MainUI = PlayerGui:WaitForChild("MainUI");

-- Register our image button
for _, v in MainUI.Buttons:GetChildren() do
    if (not v:IsA("GuiObject")) then
        continue;
    end;

    local btn = v:FindFirstChildOfClass("ImageButton") or v:FindFirstChildOfClass("TextButton");

    Button.new(btn, function()
        -- Completely optional callback
        print("Image button clicked!");
    end)
        :AddHoverAnimation("ROTATE")
        :AddHoverAnimation("UP_SCALE")
        :AddHoverAnimation("DARKEN")
        :AddHoldAnimation("DOWN_SCALE")
        :AddClickAnimation("RIPPLE")
        :SetSound("UI_CLICK", "Click", "rbxassetid://6042053626");

    -- That button will now have:
    -- 1. A ripple animation when clicked
    -- 2. A down scale animation when held
    -- 3. A darken animation when hovered
    -- 4. A up scale animation when hovered
    -- 5. A rotate animation when hovered
    -- 6. A click sound when clicked
end;