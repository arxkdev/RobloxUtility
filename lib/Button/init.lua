-- Imports
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService");
local Signal = require(script.Signal);

local Button = {};
Button.__index = Button;

-- Types
type Animation = {
    Name: string,
    OnHoverBegin: (btn: typeof(Button.new), props: { any }) -> ()?,
    OnHoverEnded: (btn: typeof(Button.new), props: { any }) -> ()?,
    OnHoldBegin: (btn: typeof(Button.new), props: { any }) -> ()?,
    OnHoldEnded: (btn: typeof(Button.new), props: { any }) -> ()?,
};
type Button = typeof(Button.new(nil, nil));

-- Constants
local PLAYER = Players.LocalPlayer;
local ANIMATIONS: Animation = {
    {
        Name = "DOWN_SCALE",
        AnimationStart = function(btn, props)
            local instance = btn.Instance;
            local uiScale = instance:FindFirstChildOfClass("UIScale");
            if (not uiScale) then
                uiScale = Instance.new("UIScale");
                uiScale.Parent = instance;
            end;

            TweenService:Create(uiScale, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                Scale = if props then props.scale else 0.9;
            }):Play();
        end,
        AnimationStop = function(btn, props)
            local instance = btn.Instance;
            local uiScale = instance:FindFirstChildOfClass("UIScale");
            if (not uiScale) then
                return;
            end;

            TweenService:Create(uiScale, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                Scale = if props then props.scale else 1;
            }):Play();
        end,
    },
    {
        Name = "UP_SCALE",
        AnimationStart = function(btn, props)
            local instance = btn.Instance;
            local uiScale = instance:FindFirstChildOfClass("UIScale");
            if (not uiScale) then
                uiScale = Instance.new("UIScale");
                uiScale.Parent = instance;
            end;

            TweenService:Create(uiScale, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                Scale = if props then props.scale else 1.1;
            }):Play();
        end,
        AnimationStop = function(btn, props)
            local instance = btn.Instance;
            local uiScale = instance:FindFirstChildOfClass("UIScale");
            if (not uiScale) then
                return;
            end;

            TweenService:Create(uiScale, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                Scale = if props then props.scale else 1;
            }):Play();
        end,
    },
    {
        Name = "ROTATE",
        AnimationStart = function(btn, props)
            local instance = btn.Instance;

            TweenService:Create(instance, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                Rotation = if props then props.rotation else 5;
            }):Play();
        end,
        AnimationStop = function(btn, props)
            local instance = btn.Instance;

            TweenService:Create(instance, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                Rotation = if props then props.rotation else 0;
            }):Play();
        end,
    },
    {
        Name = "RIPPLE",
        AnimationStart = function(btn, props)
            local instance = btn.Instance;
            local Position = PLAYER:GetMouse();

            local function CreateRipple()
                local ImageLabel = Instance.new("ImageLabel");
                ImageLabel.Name = "ButtonRipple";
                ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5);
                ImageLabel.BackgroundTransparency = 1;
                ImageLabel.Size = UDim2.new(0.064, 40, 0.08, 40);
                ImageLabel.SizeConstraint = Enum.SizeConstraint.RelativeXY;
                ImageLabel.ZIndex = 210;
                ImageLabel.Image = "rbxassetid://10570814766";
                return ImageLabel;
            end;
		
            if (not instance:IsDescendantOf(workspace)) then
                local Info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
                local Size = UDim2.new(0.04, 40, 0.08, 40);
                Size = Size + UDim2.new(0, instance.AbsoluteSize.X, 0, instance.AbsoluteSize.Y);

                local RippleClone = CreateRipple();
                RippleClone.Parent = instance;

                local posX = (Position.X - instance.AbsolutePosition.X);
                local posY = (Position.Y - instance.AbsolutePosition.Y);

                RippleClone.Position = UDim2.new(0, posX, 0, posY);
                RippleClone.Size = UDim2.new(0, 0, 0, 0);

                local Tween = TweenService:Create(RippleClone, Info, {
                    Size = Size,
                    ImageTransparency = 1
                });
                Tween:Play();
                Tween.Completed:Wait();
                RippleClone:Destroy();
            end;
        end,
    }
};

-- Helper Functions
function GetAnimation(typeOfAnimation: string): Animation | nil
    for _, animation in ANIMATIONS do
        if (animation.Name == typeOfAnimation) then
            return animation;
        end;
    end;

    return nil;
end

-- Create music group for button sounds to be played in.
local SoundGroup = Instance.new("SoundGroup");
SoundGroup.Name = "Button_SoundGroup";
SoundGroup.Parent = SoundService;

function Button.new(buttonObject: TextButton | ImageButton, activatedCallback: () -> ()): typeof(Button)
    local self = setmetatable({}, Button);

    -- Hookup signals
    self.Connections = {};
    self.HoverBegin = Signal.new();
    self.HoverEnded = Signal.new();
    self.HoldBegin = Signal.new();
    self.HoldEnded = Signal.new();
    self.Click = Signal.new();
    self.Sound = {
        AnimationType = "",
        SoundInstance = nil
    };
    self.Instance = buttonObject;

    -- Hookup the callback to the button's (activated) event.
    table.insert(self.Connections, buttonObject.Activated:Connect(activatedCallback));

    -- Hookup signals to events
    table.insert(self.Connections, buttonObject.MouseEnter:Connect(function()
        task.spawn(self.PlaySound, self, "HoverBegin");
        self.HoverBegin:Fire();
    end));
    table.insert(self.Connections, buttonObject.MouseLeave:Connect(function()
        task.spawn(self.PlaySound, self, "HoverEnded");
        self.HoverEnded:Fire();
    end));
    table.insert(self.Connections, buttonObject.MouseButton1Down:Connect(function()
        task.spawn(self.PlaySound, self, "HoldBegin");
        self.HoldBegin:Fire();
    end));
    table.insert(self.Connections, buttonObject.MouseButton1Up:Connect(function()
        task.spawn(self.PlaySound, self, "HoldEnded");
        self.HoldEnded:Fire();
    end));
    table.insert(self.Connections, buttonObject.MouseButton1Click:Connect(function()
        task.spawn(self.PlaySound, self, "Click");
        self.Click:Fire();
    end));
    
    return self;
end

-- Plays a sound based on the type of animatio being played.
function Button:PlaySound(typeOfAnimation: string): Button
    if (self.Sound.SoundInstance == nil) then
        return;
    end;

    if (self.Sound.AnimationType ~= typeOfAnimation) then
        return;
    end;

    local sound = self.Sound.SoundInstance;
    sound:Play();
end

-- Adds a hover animation of the animations available.
function Button:AddHoverAnimation(typeOfAnimation: string): Button
    local animation = GetAnimation(typeOfAnimation);

    self.HoverBegin:Connect(function()
        animation.AnimationStart(self);
    end);
    self.HoverEnded:Connect(function()
        animation.AnimationStop(self);
    end);

    return self;
end

-- Adds a hold animation of the animations available.
function Button:AddHoldAnimation(typeOfAnimation: string): Button
    local animation = GetAnimation(typeOfAnimation);

    self.HoldBegin:Connect(function()
        animation.AnimationStart(self);
    end);
    self.HoldEnded:Connect(function()
        animation.AnimationStop(self);
    end);

    return self;
end

-- Adds a click animation of the animations available.
function Button:AddClickAnimation(typeOfAnimation: string): Button
    local animation = GetAnimation(typeOfAnimation);

    self.Click:Connect(function()
        animation.AnimationStart(self);
    end);

    return self;
end

-- Adds a click delay between clicking.
function Button:AddClickDelay(typeOfAnimation: string): Button
    -- Add a delay to the click event.
    -- TODO
    return self;
end

-- Sets a sound to a button (if it already exists, will use that one.)
function Button:SetSound(uniqueName:string, typeOfAnimation: string, soundId: string): Button
    if (SoundGroup:FindFirstChild(uniqueName)) then
        self.Sound = {
            AnimationType = typeOfAnimation,
            SoundInstance = SoundGroup:FindFirstChild(uniqueName)
        };
        return self;
    end;

    local Sound = Instance.new("Sound");
    Sound.SoundId = soundId;
    Sound.Name = uniqueName;
    Sound.Parent = SoundGroup;

    self.Sound = {
        AnimationType = typeOfAnimation,
        SoundInstance = Sound
    };
    return self;
end

-- Destroys the button.
function Button:Destroy(): Button
    -- Destroy connections
    for _, connection in ipairs(self.Connections) do
        connection:Disconnect();
    end;

    -- Destroy signals
    self.HoverBegin:Destroy();
    self.HoverEnded:Destroy();
    self.HoldBegin:Destroy();
    self.HoldEnded:Destroy();
    self.Click:Destroy();
end

return table.freeze(Button);