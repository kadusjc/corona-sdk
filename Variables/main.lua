local x = 10-- Local to the chunk
local i = 1 -- Local to the chunk

while i<=x do
	local x = i --Local to the "do" body
	print(x) --Will print out numbers 1 through 10
	i = i + 1
end	

if i < 20 then
	local x --Local to the "then" body
	x = 20
	print(x + 5) -- 25
else
	print(x) -- This line will never execute since the above "then" body is already true
end
print(x) -- 10
