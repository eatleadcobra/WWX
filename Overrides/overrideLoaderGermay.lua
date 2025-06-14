local pathToWWX = "C:\\WWX\\"
if DEBUG then
   pathToWWX = "F:\\Games\\WWX\\"
end
assert(loadfile(pathToWWX.."Overrides\\GermanyCW.lua"))()
assert(loadfile(pathToWWX.."Overrides\\RandomNames_Germany70.lua"))()