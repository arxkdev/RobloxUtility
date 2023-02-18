local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Lib = ReplicatedStorage:WaitForChild("lib");
local Button = require(Lib:WaitForChild("Button"));
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui");
local MainUI = PlayerGui:WaitForChild("MainUI");

-- Register our image button
for _, Object in MainUI.Buttons:GetChildren() do
    if (not Object:IsA("GuiObject")) then
        continue;
    end;

    local btn = Object:FindFirstChildOfClass("ImageButton") or Object:FindFirstChildOfClass("TextButton");
    local clickSoundSettings = {
        SoundId = 6042053626;
        Volume = 0.2;
        Pitch = 1;
    };
    local hoverSoundSettings = {
        SoundId = 718616853;
        Volume = 0.2;
        Pitch = 1.1;
    }
    
    Button.new(btn, function()
        -- Completely optional callback
        print("Image button clicked!");
    end)
        :AddHoverAnimation("ROTATE")
        -- :AddHoverAnimation("UP_SCALE")
        :AddHoverAnimation("UP_SPRING")
        :AddHoverAnimation("DARKEN") -- AutoButtonColor only works on TextButtons, so for this imagebutton we need to manually darken it
        -- :AddHoldAnimation("DOWN_SCALE")
        :AddHoldAnimation("DOWN_SPRING")
        :AddClickAnimation("RIPPLE")
        :AddHoverAnimation("TEXT", {
            frameProperties = {
                BackgroundTransparency = 0;
                BackgroundColor3 = Color3.fromRGB(0, 0, 0);
            };
            textProperties = {
                Text = "Edit this text!";
                Font = Enum.Font.SourceSansBold;
            };
        })
        :SetSound("UI_CLICK", "Click", clickSoundSettings)
        :SetSound("UI_HOVER", "HoverBegin", hoverSoundSettings);

    -- That button will now have:
    -- 1. A ripple animation when clicked
    -- 2. A down scale animation when held (not anymore)
    -- 3. A darken animation when hovered
    -- 4. A up scale animation when hovered (not anymore)
    -- 5. A rotate animation when hovered
    -- 6. A click sound when clicked
    -- 7. A spring animation when hovered
    -- 8. A spring animation when held
end;