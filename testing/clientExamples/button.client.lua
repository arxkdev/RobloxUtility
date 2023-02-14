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
        print("Image button clicked!");
    end)
        :AddHoverAnimation("ROTATE")
        :AddHoverAnimation("UP_SCALE")
        :AddHoverAnimation("DARKEN")
        :AddHoldAnimation("DOWN_SCALE")
        :AddClickAnimation("RIPPLE")
        :SetSound("UI_CLICK", "Click", "rbxassetid://6042053626");
end;