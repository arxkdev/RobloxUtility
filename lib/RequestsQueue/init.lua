local Promise = require(script.Promise);

local function createQueue()
	local queue = { };
	local running = false;

	local function processQueue()
		if (running or #queue == 0) then
			return ;
		end;

		running = true;

		local item = table.remove(queue, 1);
		Promise.new(function(resolve, reject)
			item.fn(resolve, reject);
		end)
		:andThen(function(val)
			running = false;
			processQueue();
		end)
		:catch(function()
			-- let it get rejected 5 times before it doesnt try anymore
			if (item.rejected <= 5) then
				item.rejected = item.rejected + 1;
				table.insert(queue, item);
			end;

			running = false;
			processQueue();
		end);
	end;

	return {
		q = queue,
		push = function(fn)
			local item = { fn = fn, rejected = 0 };
			table.insert(queue, item);
			processQueue();
		end,
	};
end

return createQueue;