local pathToWWX = "C:\\WWX\\"
if DEBUG then
   pathToWWX = "F:\\Games\\WWX\\"
end
assert(loadfile(pathToWWX.."Overrides\\Pacific.lua"))()