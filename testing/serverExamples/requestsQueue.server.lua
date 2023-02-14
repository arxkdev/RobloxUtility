local HttpService = game:GetService("HttpService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local Lib = ReplicatedStorage:WaitForChild("lib");
local RequestsQueue = require(Lib:WaitForChild("RequestsQueue"));

local newQueue = RequestsQueue();

local function testFunction1(resolve, reject)
	if (1 == 1) then
		print("Resolved 1==1");
		resolve();
	end;

	reject();
end
local function testFunction2(resolve, reject)
	if (1 ~= 1) then
		print("Resolved 1~=1?");
		resolve();
	end;

	reject();
end

-- These 2 would be pushed and resolved
newQueue.push(testFunction1);
newQueue.push(testFunction1);
-- These 2 would be pushed and rejected 5 times before they stop trying
newQueue.push(testFunction2);
newQueue.push(testFunction2);

-- API Example
-- https://random-data-api.com/documentation
-- An example of how to use the RequestsQueue with an API
-- Usually if you use GetAsync, sometimes it will fail to get the data, this will retry 5 times before it stops trying, and pushes the next item in the queue
local RANDOM_DATA_API_BASE_URL = "https://random-data-api.com/api/v2/";

local function DoSomethingWithData(Data)
    local DecodedData = HttpService:JSONDecode(Data);
    local User1 = DecodedData[1];
    local User2 = DecodedData[2];

    print(`User1 FirstName: {User1.first_name}, LastName: {User1.last_name}`);
    print(`User2 FirstName: {User2.first_name}, LastName: {User2.last_name}`);
end

local function Fetch(resolve, reject)
    local UserSize = 2;

    local Success, Data = pcall(function()
        return HttpService:GetAsync(RANDOM_DATA_API_BASE_URL .. `users?size={UserSize}&is_xml=true`);
    end);

    if (Success) then
        print("Success");
        -- Do something with data
        DoSomethingWithData(Data);
        resolve();
    else
        print("Failed");
        reject();
    end;
end
newQueue.push(Fetch);