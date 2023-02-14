-- Imports
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService");
local Signal = require(script.Signal);

local Button = {};
Button.__index = Button;

-- Constants
local ANIMATIONS = {
    {
        Name = "DOWN_SCALE",
        OnHoldBegin = function(btn, props)
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
        OnHoldEnded = function(btn, props)
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
        Name = "UI_SCALE",
        OnHoverBegin = function(btn, props)
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
        OnHoverEnded = function(btn, props)
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
        OnHoverBegin = function(btn, props)
            local instance = btn.Instance;

            TweenService:Create(instance, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                Rotation = if props then props.rotation else 5;
            }):Play();
        end,
        OnHoverEnded = function(btn, props)
            local instance = btn.Instance;

            TweenService:Create(instance, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                Rotation = if props then props.rotation else 0;
            }):Play();
        end,
    }
};

-- Helper Functions
function GetAnimation(typeOfAnimation: string)
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

function Button.new(buttonObject: TextButton | ImageButton, activatedCallback: () -> ())
    local self = setmetatable({}, Button);

    -- Hookup signals
    self.Connections = {};
    self.HoverBegin = Signal.new();
    self.HoverEnded = Signal.new();
    self.HoldBegin = Signal.new();
    self.HoldEnded = Signal.new();
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
    end));
    
    return self;
end

-- Plays a sound based on the type of animatio being played.
function Button:PlaySound(typeOfAnimation: string)
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
function Button:AddHoverAnimation(typeOfAnimation: string)
    local animation = GetAnimation(typeOfAnimation);

    self.HoverBegin:Connect(function()
        animation.OnHoverBegin(self);
    end);
    self.HoverEnded:Connect(function()
        animation.OnHoverEnded(self);
    end);

    return self;
end

-- Adds a hold animation of the animations available.
function Button:AddHoldAnimation(typeOfAnimation: string)
    local animation = GetAnimation(typeOfAnimation);

    self.HoldBegin:Connect(function()
        animation.OnHoldBegin(self);
    end);
    self.HoldEnded:Connect(function()
        animation.OnHoldEnded(self);
    end);

    return self;
end

-- Adds a click delay between clicking.
function Button:AddClickDelay(typeOfAnimation: string)
    -- Add a delay to the click event.

    return self;
end

-- Sets a sound to a button (if it already exists, will use that one.)
function Button:SetSound(uniqueName:string, typeOfAnimation: string, soundId: string)
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
function Button:Destroy()
    -- Destroy connections
    for _, connection in ipairs(self.Connections) do
        connection:Disconnect();
    end;

    -- Destroy signals
    self.HoverBegin:Destroy();
    self.HoverEnded:Destroy();
    self.HoldBegin:Destroy();
    self.HoldEnded:Destroy();
end

return table.freeze(Button);