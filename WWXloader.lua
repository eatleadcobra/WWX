local pathToWWX = "C:\\WWX\\"
if DEBUG then
   pathToWWX = "F:\\Games\\WWX\\"
end
env.info("Start loading WWX...", false)
env.info("Loading Utils", false)
assert(loadfile(pathToWWX.."Utils\\mist_WWXMinimum.lua"))()
assert(loadfile(pathToWWX.."Utils\\df_utils.lua"))()
assert(loadfile(pathToWWX.."Utils\\utils.lua"))()
assert(loadfile(pathToWWX.."Utils\\drawingTools.lua"))()
assert(loadfile(pathToWWX.."Utils\\WWEvents.lua"))()
--spawning
assert(loadfile(pathToWWX.."Utils\\Spawning\\Funcs.lua"))()
assert(loadfile(pathToWWX.."Utils\\Spawning\\Values.lua"))()
assert(loadfile(pathToWWX.."Utils\\Spawning\\Templates.lua"))()
env.info("Loading Components", false)
--firebases
assert(loadfile(pathToWWX.."Components\\Firebases\\FirebaseGroups.lua"))()
assert(loadfile(pathToWWX.."Components\\Firebases\\Firebase.lua"))()
--subs
assert(loadfile(pathToWWX.."Components\\Subs\\SubControl.lua"))()
assert(loadfile(pathToWWX.."Components\\Subs\\SubTools.lua"))()
--standalone components
assert(loadfile(pathToWWX.."Components\\Torpedo.lua"))()
assert(loadfile(pathToWWX.."Components\\Sonobuoy.lua"))()
assert(loadfile(pathToWWX.."Components\\VisiBuoy.lua"))()
assert(loadfile(pathToWWX.."Components\\DepthCharge.lua"))()
assert(loadfile(pathToWWX.."Components\\Landmine.lua"))()
assert(loadfile(pathToWWX.."Components\\RocketTrackerFirebases.lua"))()
assert(loadfile(pathToWWX.."Components\\BullsBot.lua"))()
assert(loadfile(pathToWWX.."Components\\FastRope.lua"))()
assert(loadfile(pathToWWX.."Components\\CasBot.lua"))()
assert(loadfile(pathToWWX.."Components\\CODAR.lua"))()
assert(loadfile(pathToWWX.."Components\\MAD.lua"))()
assert(loadfile(pathToWWX.."Components\\CSARBot.lua"))()
assert(loadfile(pathToWWX.."Components\\RandomNames.lua"))()
assert(loadfile(pathToWWX.."Components\\Recon.lua"))()
env.info("Loading Plugins", false)
-- "plugins" here are like wrappers or translation layers between the component and the specific mission requirements of WWX
assert(loadfile(pathToWWX.."Plugins\\DF_firebases.lua"))()
assert(loadfile(pathToWWX.."Plugins\\DF_submarines.lua"))()
env.info("Loading main")
assert(loadfile(pathToWWX.."DF_Cauc.lua"))()
--Things that need to load after DF_Cauc (main file) because it access global vars defined in that file
assert(loadfile(pathToWWX.."WWXFactoryTracker.lua"))()
assert(loadfile(pathToWWX.."Plugins\\DF_recon.lua"))()
assert(loadfile(pathToWWX.."Plugins\\DF_cargo.lua"))()
env.info("Finished loading WWX")
