local pathToWWX = "C:\\WWX\\"
if DEBUG then
   pathToWWX = "F:\\Games\\WWX\\"
end
assert(loadfile(pathToWWX.."Overrides\\SyriaCW.lua"))()
assert(loadfile(pathToWWX.."Overrides\\RandomNames_Golan.lua"))()