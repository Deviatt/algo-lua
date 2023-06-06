# Simple STL library for Lua
**algo** - Simple and useful tool for development using some containers. **algo** implements 3 container types (stack, bitset, queue), each of them's a table modification and doesn't change it's original properties.

**algo** also supports LuaJIT (GMod compatibility) and Lua 5.2+
## API
### BitSet
```
bitset:put(int) -> puts int into bitset to work with its bits
bitset:set(index, bit) -> sets a specific bit
bitset:get(index) -> reads a specific bit from int or read the full number
bitset:fetch(index, n) -> read bits from a specific position
bitset:test(index) -> checks if a bit is set
bitset:count() -> сounts the number of bits set

bitset[index] -> alias bitset:get(index)
bitset[index] = bit -> alias bitset:set(index, bit)
tostring(bitset) -> converts int to a binary string
```
### Stack
```
stack:push(x) -> pushes an element onto the stack
stack:pop(n) -> pops n elements from the stack
stack:peek() -> reads an element from the top of the stack

#stack -> stack size
```
### Queue
```
queue:push(x) -> pushes an element to the end of the queue
queue:pop() -> pops an element from the front of the queue

#queue -> queue size
```
## Usage
**algo** also supports CamelCase for the GMod naming convention.

BitSet
```lua
local algo = require "algo"
local charFlags = algo.bitset() -- Character flags

FL_ALIVE = 1 -- first index on bitset
FL_ONGROUND = 2 -- second index on bitset
FL_GOD = 3 -- third index on bitset

charFlags:set(FL_ALIVE, 1)
-- or
charFlags[FL_ALIVE] = 1

print(charFlags:test(FL_ALIVE), charFlags:test(FL_ONGROUND)) -- true, false
-- or
print(charFlags[FL_ALIVE] == 1, charFlags[FL_ONGROUND] == 1) -- true, false

charFlags:set(FL_ONGROUND, 3)
print(charFlags:test(FL_GOD), charFlags:test(FL_ONGROUND)) -- true, true
print(charFlags) -- 111
```
Stack
```lua
local algo = require "algo"
local stack = algo.stack()
stack:push(512)
stack:push(1024)
stack:push(2048)

print(#stack, stack:pop()) -- 3, 2048
local multi = stack:pop(2)
print(#stack, multi[1], multi[2]) -- 0, 1024, 512
```
Queue
```lua
local algo = require "algo"
local queue = algo.queue()
queue:push(512)
queue:push(1024)
queue:push(2048)

print(#queue, queue:pop(), queue:pop(), queue:pop()) -- 3, 512, 1024, 2048
```