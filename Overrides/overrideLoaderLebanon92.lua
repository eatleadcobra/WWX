local pathToWWX = "C:\\WWX\\"
if DEBUG then
   pathToWWX = "F:\\Games\\WWX\\"
end
assert(loadfile(pathToWWX.."Overrides\\Lebanon92.lua"))()
assert(loadfile(pathToWWX.."Overrides\\RandomNames_Lebanon92.lua"))()