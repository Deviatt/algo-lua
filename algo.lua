local __def = function(obj, name, x) obj[name], obj[name:lower()] = x, x end
local loadop = function(op, isunary) return load(string.format("local x,y=...return %s%s%s", isunary and "" or "x", op, isunary and "x" or "y")) end
local rawset, rawget, bit = rawset, rawget, bit or bit32
local BITSET do
	local blsh, brsh, band, bor, bnot do
		if (bit) then
			blsh, brsh, band, bor, bnot = bit.lshift, bit.rshift, bit.band, bit.bor, bit.bnot
		else
			blsh, brsh, band, bor, bnot = loadop "<<", loadop ">>", loadop "&", loadop "|", loadop("~", true)
		end
	end

	local index = {}
	local bset = function(bits, idx, n) rawset(bits, 0, bor(band(rawget(bits, 0), bnot(blsh(1, idx - 1))), blsh(n, idx - 1))) end
	__def(index, "Set", bset)
	__def(index, "Put", function(bits, n) rawset(bits, 0, n) end)
	__def(index, "Get", function(bits) return rawget(bits, 0) end)
	__def(index, "Fetch", function(bits, idx, n) return band(brsh(rawget(bits, 0), idx - 1), blsh(1, n or 1) - 1) end)
	__def(index, "Test", function(bits, idx) return band(rawget(bits, 0), blsh(1, idx - 1)) ~= 0 end)
	__def(index, "Count", function(bits)
		local n, c = rawget(bits, 0), 0
		if (n == 0) then return 0 end

		::jmp::
		n, c = band(n, n - 1), c + 1
		if (n ~= 0) then goto jmp end

		return c
	end)

	local type, gsub = type, string.gsub
	local dec2bin do
		local convtab, strfmt = {["0"] = "000", ["1"] = "001", ["2"] = "010", ["3"] = "011", ["4"] = "100", ["5"] = "101", ["6"] = "110", ["7"] = "111"}, string.format
		dec2bin = math.IntToBin or function(n)
			return gsub(strfmt("%o", n), ".", convtab)
		end
	end

	BITSET = {
		__newindex = bset,
		__index = function(bits, idx)
			return type(idx) == "number" and band(brsh(rawget(bits, 0), idx - 1), 1) or rawget(index, idx)
		end,
		__tostring = function(bits)
			return (gsub(dec2bin(rawget(bits, 0)), "^0+", ""))
		end
	}
end

local STACK do
	local index = {}
	__def(index, "Push", function(stack, x)
		local idx = rawget(stack, 0) + 1
		rawset(stack, idx, x)
		rawset(stack, 0, idx)
		return idx
	end)
	local insert = table.insert
	__def(index, "Pop", function(stack, amount)
		local idx, out = rawget(stack, 0)
		if (idx == 0 or idx == nil) then return end
		if (amount) then
			out = {}
			::jmp::
			insert(out, rawget(stack, idx))
			rawset(stack, idx, nil)
			idx, amount = idx - 1, amount - 1
			if (bor(amount, idx) ~= 0) then goto jmp end
			rawset(stack, 0, idx)
		else
			out = rawget(stack, idx)
			rawset(stack, idx, nil)
			rawset(stack, 0, idx - 1)
		end

		return out
	end)
	__def(index, "Peek", function(stack) return rawget(stack, rawget(stack, 0)) end)

	STACK = {
		__index = index,
		__len = function(stack) return rawget(stack, 0) end
	}
end

local QUEUE do
	local bxor = bit and bit.bxor or loadop "~"
	local index = {}
	__def(index, "Push",  function(queue, x)
		local idx = rawget(queue, 0) + 1
		rawset(queue, idx, x)
		rawset(queue, 0, idx)
		return idx
	end)
	__def(index, "Pop",  function(queue)
		local x = rawget(queue, 1)
		if (x == nil) then return end
		local len, i = rawget(queue, 0), 2
		::jmp::
		rawset(queue, i - 1, rawget(queue, i))
		if (i <= len) then i = i + 1 goto jmp end
		rawset(queue, 0, len - 1)
		return x
	end)

	QUEUE = {
		__index = index,
		__len = function(queue) return rawget(queue, 0) end
	}
end

local function __fn(meta) return function() return setmetatable({[0] = 0}, meta) end end
local mod = {}
__def(mod, "BitSet", __fn(BITSET))
__def(mod, "Stack", __fn(STACK))
__def(mod, "Queue", __fn(QUEUE))
return mod