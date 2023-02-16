-- Deep functions
local function deepCopy(t)
    local copy = {};
    
    for k, v in pairs(t) do
        if (type(v) == "table") then
            v = deepCopy(v);
        end;

        copy[k] = v;
    end;

    return copy;
end

local function deepCompare(t1, t2)
    -- If t1 and t2 are not tables, simply compare them
	if (type(t1) ~= "table" or type(t2) ~= "table") then
		return (t1 == t2);
	end;

	-- If the tables have different lengths, they are not the same
	if (#t1 ~= #t2) then
		return false;
	end;

	-- Compare the elements in the tables
	for k, v1 in pairs(t1) do
		local v2 = t2[k];
		
		if (not deepCompare(v1, v2)) then
			return false;
		end;
	end;

	return true;
end

local function deepMerge(t1, t2)
    local copy = deepCopy(t1);

    for k, v in pairs(t2) do
        if (type(v) == "table" and type(copy[k]) == "table") then
            copy[k] = deepMerge(copy[k], v);
        else
            copy[k] = v;
        end;
    end;

    return copy;
end

local function deepFind(t, value)
    for k, v in pairs(t) do
        if (type(v) == "table") then
            local found = deepFind(v, value);

            if (found) then
                return found;
            end;
        elseif (v == value) then
            return k;
        end;
    end;

    return nil;
end

return {
    deepCopy = deepCopy,
    deepMerge = deepMerge,
    deepCompare = deepCompare,
    deepFind = deepFind
};