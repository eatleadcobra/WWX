# Load order and overrides
## To run the script correctly you need two "doscriptfile" actions defined in the mission. I find these work best set to "MissionStart"
- First load your override file that defines the specific mission configuration
- Then load the main WWXloaderloader to load the rest of the scripts.

## Overrides file
- Each mission should have an overrides file created (see ./Overrides for examples for a few missions) to define the parameters of the mission and what features are enabled or disabled in a mission. The overrides file is also where the platoons and companies are defined.

# List of required zones to create a mission:
## Battle Positions
The front line is now defined with several zones called "battle positions" that units will fight to capture. You can have any number of BPs between 1 and 20 (this is set in DF_battlecontroller.lua in ./Plugins). The zones are named "BP-1", "BP-2", etc.

## Spawning Zones
These zones are all required in the mission for frontline units, artillery, and depots to spawn.

DFS.spawnNames = {
[1] = {

    frontline = "RedSpawn-Front-",
    artillery = "RedSpawn-Art-",
    depot = "Red-FrontDepot-",
    reardepot = "Red-RearDepot-",
    convoy = "Red-Convoy-",
    pirate = "RedPirateShip", -- only required with PIRACY
    deliver = 'Red-Front-Deliver-',
    pirateSupplyDrawing = "Red-PirateCounter",
},
[2] = {

    frontline = "BlueSpawn-Front-",
    artillery = "BlueSpawn-Art-",
    depot = "Blue-FrontDepot-",
    reardepot = "Blue-RearDepot-",
    convoy = "Blue-Convoy-",
    pirate = "BluePirateShip", -- only required with PIRACY
    deliver = 'Blue-Front-Deliver-',
    pirateSupplyDrawing = "Blue-PirateCounter",
}
}

Certain zones require multiples being made with a different number appended on the end. In the case of rear depots, two numbers are required to denote which subdepot zone is part of the main rear depot. e.g. `Red-RearDepot-1-1 and Red-RearDepot-1-2`. The total number of each zone needed is defined in the mission variables in DFS.status. The counts are as follows (current value in parentheses):
` 
- frontline = DFS.status.frontSpawnTotal (12)
- artillery = DFS.status.artSpawnTotal (4)
- front depots = DFS.status.fdSpawnTotal (4)
- rear depots (the main location from which truck convoys depart) = DFS.status.rdSpawnTotal (1)
- number of sub depots in a rear depot  = DFS.status.rdSpawnSubDepots (2)
## Campaign Status Drawing Zones

Each team needs four zones placed to anchor the displays for front and rear supplies. 

Example for red team. Blue team should be the same but with "Blue" in place of "Red":

"Red-FrontCounter", -- should be near the front depots, displays front depot supplies

"Red-RearCounter", -- should be near the rear depot, displays rear depot supplies

"Red-PirateCounter", -- should be near the pirate depot, displays pirate depot supplies only required with PIRACY

These zone names are defined in DFS.spawnNames
## Cargo Zones
These zones are required in the mission for cargo pick up and drop off, shipping, and truck convoys to work correctly.


- "Red/Blue-Front-Deliver-" (one for each front depot, this is the point where the truck convoy is considered arrived at the depot so it should be on a road near the depot)
- "Red/Blue-Rear-Deliver" (one at the rear depot, this is where the boats are considered arrived, so should be in a port in deep enough water near the rear depot)
- "Red/Blue-Pickup-RD", (the area near the rear depot where cargo can be picked up)
- "Red/Blue-Pickup-Sea", (the oil rig aread where cargo can be picked up at sea)
- "Red/BluePiratePickup" (the pickup for each teams pirate base where stolen cargo is dropped off) -- only required with PIRACY
- "Red/BluePirateDeliver" (the drop off zone for pirate boats at the pirate depots. Should be in the water)
- "{coalitionNum}-shipzone-SW" and "{coalitionNum}-shipzone-NE" are two zones used to define the corners of the rectangle where cargo ships spawn.
- "{coaltionNum}-shiproute-X" are as many zones as needed to define a route of waypoints for ships to take from anywhere in the spawn zone into the delivery zone.

## Required unit templates:
All group spawning templates besides depots, bombers, and CAP are now defined in the overrides file. For depots to spawn correctly, you must create a template group for each team for MIST to copy.:

depot = "Red/Blue-Depot",

Bombers: -- only required with BOMBERS

Two bomber groups should be made for each team, set up to bomb the rear depot.
"Red/Blue Bombers-1" and "Red/Blue Bombers-2"

CAP: -- only required with CAP
One CAP group should be created for each team, set to orbit over the rear depot.
"Red/Blue-CAP"

Submarines:  -- only required with SUBS
Each submarine should have 14 zones created around the perimiter of the enemy shipping zone. The format is {coalitionId}-sub-{start or end}-number. Corresponding start and end zones should have the same number and be placed in such a way that going from start to end takes the submarine through the shipping zone. An example for the red team submarine would be "1-sub-start-3" and "1-sub-end-3". There should be a start and end for 1 through 7 for 14 total zones for each team.

## List of optional additional zones and units for other components:
### Bulls Bot
#### Units
There should be a truck unit created with a group name matching each entry in the radioUnits table in BullsBot.lua. The unit needs to have a frequency set. This is the frequency that the bulls message will be transmitted over.
example for blue: "BlueBulls-1". 
#### Zones
No zones required.
### CSAR Bot
#### Units
Each coalition requires a TACAN group "TCN-1" for red, "TCN-2" for blue. And a rescue group. This should be a single infantryman names "SOS-1" for red and "SOS-2" for blue.
#### Zones
Each team requires a zone placed on the map for the stack area, the rescue area (where infantry spawns to be rescued), and the hospital area where the troop is delivered. 
Example for red:

stack zone = "RedCsarStack"

CSAR pickup area = "RedCsarZone"

hospital area (should be over a helipad at a hospital) = "Red Forward Field Hospital"

For blue team, simply swap out "Red" with "Blue"

### CAS Bot
#### Units
No units required.
#### Zones
Each team requires a zone created with the name "RedCas" or "BlueCas" where players will stack up to await assignment.