-- Imports
local MarketplaceService = game:GetService("MarketplaceService");
local Promise = require(script.Promise);

-- Start
local StoreUtil = {};

-- Helper function to get the info
local function GetInfo(id: number, infoType: Enum.InfoType)
    -- Return a retrying promise
    return Promise.new(function(resolve, reject)
        local success, product = pcall(function()
            return MarketplaceService:GetProductInfo(id, infoType);
        end);
        if (success) then
            resolve(product);
        else
            reject(product);
        end;
    end);
end

-- Handle the processing of the data
function StoreUtil:GetProductInfo(infoType: Enum.InfoType, ids: {number})
    local promises = {};

    for _, productId in pairs(ids) do
        table.insert(promises, Promise.retry(function()
            return GetInfo(productId, infoType);
        end, 10));
    end;

    return Promise.all(promises);
end

-- So we can do something like this:
StoreUtil:GetProductInfo(Enum.InfoType.GamePass, {28403080, 28403080, 28403080}):andThen(function(gamepassInfo)
    print(gamepassInfo);
end):catch(function(err)
    warn(err);
end);

return StoreUtil;