local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

local Lib = ReplicatedStorage:WaitForChild("lib");
local DeepUtil = require(Lib:WaitForChild("DeepUtil"));