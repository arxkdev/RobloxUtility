-- Imports
local Players = game:GetService("Players");
local RunService = game:GetService("RunService");
local SoundService = game:GetService("SoundService");
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService");
local Signal = require(script.Signal);
local Spr = require(script.Spr);

local Button = {};
Button.__index = Button;

-- Types
type CachedArguments = {
    [string]: any,
};
type Animation = {
    {
        Name: string,
        AnimationStart: (typeof(Button.new), { [string]: any }) -> nil | CachedArguments,
        AnimationStop: (typeof(Button.new), CachedArguments) -> nil,
    }
};
type SoundSettings = {
    SoundId: number | string,
    [any]: any,
};
-- Constants
local PLAYER = Players.LocalPlayer;

-- Create screengui with frmae
local EFFECTS_SCREEN_GUI = Instance.new("ScreenGui");
EFFECTS_SCREEN_GUI.Name = "EFFECTS_SCREEN_GUI";
EFFECTS_SCREEN_GUI.ResetOnSpawn = false;
EFFECTS_SCREEN_GUI.DisplayOrder = 10;
EFFECTS_SCREEN_GUI.Parent = PLAYER:WaitForChild("PlayerGui");

local EFFECTS_FRAME = Instance.new("Frame");
EFFECTS_FRAME.Name = "EFFECTS_FRAME";
EFFECTS_FRAME.AnchorPoint = Vector2.new(0.5, 0.5);
EFFECTS_FRAME.BackgroundTransparency = 1;
EFFECTS_FRAME.Position = UDim2.new(0.5, 0, 0.5, 0);
EFFECTS_FRAME.Size = UDim2.new(1, 0, 1, 0);
EFFECTS_FRAME.SizeConstraint = Enum.SizeConstraint.RelativeXY;
EFFECTS_FRAME.ZIndex = 100000;
EFFECTS_FRAME.Parent = EFFECTS_SCREEN_GUI;

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
        AnimationStop = function(btn)
            local instance = btn.Instance;
            local uiScale = instance:FindFirstChildOfClass("UIScale");
            if (not uiScale) then
                return;
            end;

            TweenService:Create(uiScale, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                Scale =  1;
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
        AnimationStop = function(btn)
            local instance = btn.Instance;
            local uiScale = instance:FindFirstChildOfClass("UIScale");
            if (not uiScale) then
                return;
            end;

            TweenService:Create(uiScale, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                Scale = 1;
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
        AnimationStop = function(btn)
            local instance = btn.Instance;

            TweenService:Create(instance, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                Rotation = 0;
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
                ImageLabel.ZIndex = 1000001;
                ImageLabel.Image = "rbxassetid://10570814766";
                return ImageLabel;
            end;

            if (not instance:IsDescendantOf(workspace)) then
                local Info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
                local Size = UDim2.new(0.04, 40, 0.08, 40);
                Size = Size + UDim2.new(0, instance.AbsoluteSize.X, 0, instance.AbsoluteSize.Y);

                local RippleClone = CreateRipple();
                RippleClone.Parent = EFFECTS_FRAME;

                local posX = (Position.X - EFFECTS_FRAME.AbsolutePosition.X);
                local posY = (Position.Y - EFFECTS_FRAME.AbsolutePosition.Y);

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
        AnimationStop = function(btn)
            -- Nothing
        end,
    },
    {
        Name = "DARKEN",
        AnimationStart = function(btn, props)
            local instance = btn.Instance;
            local colorBefore = if instance:IsA("ImageButton") then instance.ImageColor3 else instance.BackgroundColor3;

            local function DarkenColor(color)
                local black = Color3.new(0, 0, 0);
                local amount = 0.1;
                local darkColor = color:Lerp(black, amount);
                return darkColor;
            end;

            local newDarkenedColor = if instance:IsA("ImageButton") then DarkenColor(instance.ImageColor3) else DarkenColor(instance.BackgroundColor3);

            local properties;
            if (instance:IsA("ImageButton")) then
                properties = {
                    ImageColor3 = newDarkenedColor;
                };
            else
                properties = {
                    BackgroundColor3 = newDarkenedColor;
                };
            end;

            TweenService:Create(instance, TweenInfo.new(0.25, Enum.EasingStyle.Quint), properties):Play();
            return {colorBefore}; -- Return the original color so we can use it later
        end,
        AnimationStop = function(btn, cachedArguments)
            local instance = btn.Instance;
            if (not cachedArguments) then
                return;
            end;
            local originalColor = cachedArguments[1];

            local properties;
            if (instance:IsA("ImageButton")) then
                properties = {
                    ImageColor3 = originalColor;
                };
            else
                properties = {
                    BackgroundColor3 = originalColor;
                };
            end;

            TweenService:Create(instance, TweenInfo.new(0.25, Enum.EasingStyle.Quint), properties):Play();
        end,
    },
    {
        Name = "SPLASH_PARTICLE",
        AnimationStart = function(btn, props)
            
        end,
        AnimationStop = function(btn)
            
        end
    },
    {
        Name = "UP_SPRING",
        AnimationStart = function(btn, props)
            local instance = btn.Instance;
            local uiScale = instance:FindFirstChildOfClass("UIScale");

            if (not uiScale) then
                uiScale = Instance.new("UIScale");
                uiScale.Parent = instance;
            end;

            Spr.target(uiScale, 0.3, 4, {
                Scale = if props then props.scale else 1.1;
            });
        end,
        AnimationStop = function(btn)
            local instance = btn.Instance;
            local uiScale = instance:FindFirstChildOfClass("UIScale");

            if (not uiScale) then
                return;
            end;

            Spr.stop(uiScale);
            Spr.target(uiScale, 0.3, 4, {
                Scale = 1
            });
        end,
    },
	{
		Name = "SHIFT_GRADIENT",
		AnimationStart = function(btn, props)
			local instance = btn.Instance;
			
			for gradient, subProps in pairs(props) do
				local newOffset = Vector2.new(0, 1) * (subProps.OffsetMultiple or 1);
				
				TweenService:Create(gradient, TweenInfo.new(subProps.TweenTime or 0.15, Enum.EasingStyle.Quint), {Offset = newOffset}):Play();
			end
			
			return props
		end,
		AnimationStop = function(btn, cachedProps)
			local instance = btn.Instance;
			
			for gradient, subProps in pairs(cachedProps) do
				local originalOffset = Vector2.new(0, -0.5) * (subProps.OffsetMultiple or 1)
				
				TweenService:Create(gradient, TweenInfo.new(subProps.TweenTime or 0.15, Enum.EasingStyle.Quint), {Offset = originalOffset}):Play();
			end
		end,
	},
	{
		Name = "SPLASH_PARTICLE",
		AnimationStart = function(btn, props)

		end,
		AnimationStop = function(btn)

		end
	},
   {
		Name = "DOWN_SPRING",
		AnimationStart = function(btn, props)
			local instance = btn.Instance;
			local uiScale = instance:FindFirstChildOfClass("UIScale");

			if (not uiScale) then
				uiScale = Instance.new("UIScale");
				uiScale.Parent = instance;
			end;
			
			local scaleBefore = uiScale.Scale
			
			Spr.target(uiScale, 0.7, 7, {
				Scale = if props then props.scale else 0.9;
			});
			
			return {scaleBefore}
		end,
		AnimationStop = function(btn, cachedArguments)
			local instance = btn.Instance;
			local uiScale = instance:FindFirstChildOfClass("UIScale");
			local scaleBefore = cachedArguments[1]
			
			if (not uiScale) then
				return;
			end;

			Spr.stop(uiScale);
			Spr.target(uiScale, 0.7, 7, {
				Scale = scaleBefore or 1;
			});
		end,
	},
    {
        Name = "TEXT",
        AnimationStart = function(btn, props)
            local instance = btn.Instance;
            local connection

            -- Destroy any existing text label(s)
            for _, OBJECT in pairs(instance:GetChildren()) do
                if (OBJECT.Name == "BUTTON_CREATED_TEXT_LABEL_FRAME") then
                    OBJECT:Destroy();
                end;
            end;

            local frameProperties = props.frameProperties;
            local textProperties = props.textProperties;

            -- Create our frame and text with appropriate properties
            local frame = Instance.new("Frame");
            frame.Name = "BUTTON_CREATED_TEXT_LABEL_FRAME";
            frame.BackgroundTransparency = 1;
            frame.Size = UDim2.new(1, 0, 0.3, 0);
            frame.BackgroundColor3 = Color3.new(0, 0, 0);
            frame.ZIndex = 5;
            for i, v in pairs(frameProperties) do
                frame[i] = v;
            end;
            frame.Parent = instance;

            local text = Instance.new("TextLabel");
            text.Name = "BUTTON_CREATED_TEXT_LABEL";
            text.BackgroundTransparency = 1;
            text.Text = "Set the text..";
            text.TextColor3 = Color3.new(1, 1, 1);
            text.ZIndex = 6;
            text.AnchorPoint = Vector2.new(0.5, 0.5);
            text.Position = UDim2.new(0.5, 0, 0.5, 0);
            text.Size = UDim2.new(0.85, 0, 1, 0);
            text.Font = Enum.Font.SourceSans;
            text.TextScaled = true;
            for i, v in pairs(textProperties) do
                text[i] = v;
            end;
            text.Parent = frame;

            local textSize = TextService:GetTextSize(text.Text, text.TextSize, text.Font, Vector2.new(math.huge, math.huge));
            local textX = textSize.X * 2.5;
            local textY = textSize.Y * 2.5;
            frame.Size = UDim2.fromOffset(textX, textY);

            local uiCorner = Instance.new("UICorner");
            uiCorner.CornerRadius = UDim.new(0, 8);
            uiCorner.Parent = frame;

            local OFFSET_X = 0;
            local OFFSET_Y = -20;

            -- Setup connection to update the position of the frame.
            connection = RunService.RenderStepped:Connect(function()
                local Mouse = PLAYER:GetMouse();

                if (not instance:IsDescendantOf(game)) then
                    connection:Disconnect();
                    return;
                end;

                if (not instance or not instance.Parent) then
                    connection:Disconnect();
                    return;
                end;

                frame.Position = UDim2.new(0, (Mouse.X - instance.AbsolutePosition.X) + OFFSET_X, 0, (Mouse.Y - instance.AbsolutePosition.Y) + OFFSET_Y);
            end);

            return {connection};
        end,
        AnimationStop = function(btn, cachedArguments)
            local instance = btn.Instance;

            if (not cachedArguments) then
                return;
            end;

            -- Disconnect the connection.
            local connection = cachedArguments[1];

            if (connection) then
                connection:Disconnect();
            end;

            -- Destroy the frame(s)
            for _, OBJECT in pairs(instance:GetChildren()) do
                if (OBJECT.Name == "BUTTON_CREATED_TEXT_LABEL_FRAME") then
                    OBJECT:Destroy();
                end;
            end;
        end,
    }
};

-- Helper Functions
function GetAnimation(typeOfAnimation: string): Animation?
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

function Button.new(buttonObject: TextButton | ImageButton, activatedCallback: () -> ()?): typeof(Button)
    local self = setmetatable({}, Button);

    -- Hookup signals
    self.Connections = {};
    self.HoverBegin = Signal.new();
    self.HoverEnded = Signal.new();
    self.HoldBegin = Signal.new();
    self.HoldEnded = Signal.new();
    self.Click = Signal.new();
    self.Sounds = {};
    self.Instance = buttonObject;

    -- Hookup the callback to the button's (activated) event.
    if (activatedCallback) then self.Click:Connect(activatedCallback); end;

    -- Hookup signals to events
    table.insert(self.Connections, buttonObject.MouseEnter:Connect(function()
        task.spawn(self.ValidateSound, self, "HoverBegin");
        self.HoverBegin:Fire();
    end));
    table.insert(self.Connections, buttonObject.MouseLeave:Connect(function()
        task.spawn(self.ValidateSound, self, "HoverEnded");
        self.HoverEnded:Fire();
    end));
    table.insert(self.Connections, buttonObject.MouseButton1Down:Connect(function()
        task.spawn(self.ValidateSound, self, "HoldBegin");
        self.HoldBegin:Fire();
    end));
    table.insert(self.Connections, buttonObject.MouseButton1Up:Connect(function()
        task.spawn(self.ValidateSound, self, "HoldEnded");
        self.HoldEnded:Fire();
    end));
    table.insert(self.Connections, buttonObject.Activated:Connect(function()
        task.spawn(self.ValidateSound, self, "Click");
        self.Click:Fire();
    end));
    
    return self;
end

-- Plays a sound based on the type of animation being played.
function Button:ValidateSound(typeOfAnimation: string)
    if (#self.Sounds == 0) then
        return;
    end;

    for _, sound in self.Sounds do
        if (sound.AnimationType == typeOfAnimation) then
            sound.SoundInstance:Play();
            return;
        end;
    end;
end

-- Adds a hover animation of the animations available.
function Button:AddHoverAnimation(typeOfAnimation: string, properties: {any}): typeof(Button.new) | nil
    local animation = GetAnimation(typeOfAnimation);

    -- Check if there is a valid animation for this type.
    if (not animation) then
        error("Invalid animation type: " .. typeOfAnimation);
        return;
    end;

    -- Save the arguments for the animation so we can use it later.
    local cachedArguments: any;
    self.HoverBegin:Connect(function()
        cachedArguments = animation.AnimationStart(self, properties);
    end);
    self.HoverEnded:Connect(function()
        animation.AnimationStop(self, cachedArguments);
    end);

    return self;
end

-- Adds a hold animation of the animations available.
function Button:AddHoldAnimation(typeOfAnimation: string, properties: {any}): typeof(Button.new) | nil
    local animation = GetAnimation(typeOfAnimation);

    -- Check if there is a valid animation for this type.
    if (not animation) then
        error("Invalid animation type: " .. typeOfAnimation);
        return;
    end;

    local cachedArguments: any;
    self.HoldBegin:Connect(function()
        cachedArguments = animation.AnimationStart(self, properties);
    end);
    self.HoldEnded:Connect(function()
        animation.AnimationStop(self, cachedArguments);
    end);

    return self;
end

-- Adds a click animation of the animations available.
function Button:AddClickAnimation(typeOfAnimation: string, properties: {any}): typeof(Button.new) | nil
    local animation = GetAnimation(typeOfAnimation);

    -- Check if there is a valid animation for this type.
    if (not animation) then
        error("Invalid animation type: " .. typeOfAnimation);
        return;
    end;

    self.Click:Connect(function()
        animation.AnimationStart(self, properties);
    end);

    return self;
end

-- Adds a click delay between clicking.
function Button:AddClickDelay(typeOfAnimation: string): typeof(Button.new) | nil
    -- Add a delay to the click event.
    -- TODO
    return self;
end

-- Sets a sound to a button (if it already exists, will use that one.)
function Button:SetSound(uniqueName:string, typeOfAnimation: string, soundSettings: SoundSettings): typeof(Button.new) | nil
    if (not uniqueName) then
        error("Invalid unique name for sound.");
        return;
    end;

    if (not typeOfAnimation) then
        error("Invalid type of animation for sound.");
        return;
    end;

    if (SoundGroup:FindFirstChild(uniqueName)) then
        table.insert(self.Sounds,{AnimationType = typeOfAnimation, SoundInstance = SoundGroup:FindFirstChild(uniqueName)});
        return self;
    end;

    local Sound = Instance.new("Sound");
    Sound.Name = uniqueName;

    -- Parse the sound id to format it correctly.
    if (type(soundSettings) == "number") then
        soundSettings = {SoundId = soundSettings};
    end;
    if (soundSettings.SoundId) then
        soundSettings.SoundId = "rbxassetid://" .. soundSettings.SoundId;
    end;

    -- Set the sound settings.
    for setting, value in pairs(soundSettings) do
        if (not Sound[setting]) then
            error("Invalid sound setting: " .. setting);
            return;
        end;

        Sound[setting] = value;
    end;

    Sound.Parent = SoundGroup;

    table.insert(self.Sounds, {AnimationType = typeOfAnimation, SoundInstance = Sound});
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
    self.Click:Destroy();
end

return table.freeze(Button);
