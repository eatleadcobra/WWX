local pathToWWX = "C:\\WWX\\"
if DEBUG then
   pathToWWX = "F:\\Games\\WWX\\"
end
assert(loadfile(pathToWWX.."Overrides\\FreeWV2.lua"))()
assert(loadfile(pathToWWX.."Overrides\\RandomNames_FreeWV2.lua"))()