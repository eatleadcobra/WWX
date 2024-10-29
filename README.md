# List of required zones to create a mission:
## Spawning Zones
These zones are all required in the mission for frontline units, artillery, AAA, and depots to spawn.


DFS.spawnNames = {
[1] = {

    frontline = "RedSpawn-Front-",
    artillery = "RedSpawn-Art-",
    depot = "Red-FrontDepot-",
    reardepot = "Red-RearDepot-",
    aa = "Red-AA-",
    convoy = "Red-Convoy-",
    pirate = "RedPirateShip",
    deliver = 'Red-Front-Deliver-',
    pirateSupplyDrawing = "Red-PirateCounter",
},
[2] = {

    frontline = "BlueSpawn-Front-",
    artillery = "BlueSpawn-Art-",
    depot = "Blue-FrontDepot-",
    reardepot = "Blue-RearDepot-",
    aa = "Blue-AA-",
    convoy = "Blue-Convoy-",
    pirate = "BluePirateShip",
    deliver = 'Blue-Front-Deliver-',
    pirateSupplyDrawing = "Blue-PirateCounter",
}
}

Certain zones require multiples being made with a different number appended on the end. In the case of rear depots, two numbers are required to denote which subdepot zone is part of the main rear depot. e.g. `Red-RearDepot-1-1 and Red-RearDepot-1-2`. The total number of each zone needed is defined in the mission variables in DFS.status. The counts are as follows (current value in parentheses):
` 
- frontline = DFS.status.frontSpawnTotal (12)
- artillery = DFS.status.artSpawnTotal (4)
- anti air = DFS.status.aaSpawnTotal (8)
- front depots = DFS.status.fdSpawnTotal (4)
- rear depots (the main location from which truck convoys depart) = DFS.status.rdSpawnTotal (1)
- number of sub depots in a rear depot  = DFS.status.rdSpawnSubDepots (2)
## Campaign Status Drawing Zones

Each team needs four zones placed to anchor the displays for health and front and rear supplies. 

Example for red team. Blue team should be the same but with "Blue" in place of "Red":

"Red-Healthbar", -- should be near the frontline to display team health

"Red-FrontCounter", -- should be near the front depots, displays front depot supplies

"Red-RearCounter", -- should be near the rear depot, displays rear depot supplies

"Red-PirateCounter", -- should be near the pirate depot, displays pirate depot supplies

These zone names are defined in DFS.spawnNames
## Cargo Zones
These zones are required in the mission for cargo pick up and drop off, shipping, and truck convoys to work correctly.


- "Red/Blue-Front-Deliver-" (one for each front depot, this is the point where the truck convoy is considered arrived at the depot so it should be on a road near the depot)
- "Red/Blue-Rear-Deliver" (one at the rear depot, this is where the boats are considered arrived, so should be in a port in deep enough water near the rear depot)
- "Red/Blue-Pickup-RD", (the area near the rear depot where cargo can be picked up)
- "Red/Blue-Pickup-Sea", (the oil rig aread where cargo can be picked up at sea)
- "Red/BluePiratePickup" (the pickup for each teams pirate base where stolen cargo is dropped off)
- "Red/BluePirateDeliver" (the drop off zone for pirate boats at the pirate depots. Should be in the water)

## Required unit templates:
Most required groups that are used as templates for dynamically spawning and respawning are found in DFS.groupNames. For the mission to work there must be a group with the correct name present in the mission for each team. Red-Frontline-1", "Blue-AA", etc. All of these templates should be set to Late Activation.:

frontline = {


    [1] = 'Red/Blue-Frontline-1', -- level one frontline troops, worst quality

    [2] = 'Red/Blue-Frontline-2',

    [3] = 'Red/Blue-Frontline-3',

    [4] = 'Red/Blue-Frontline-4', -- tank group
    artillery = "Red/Blue-Art",

}

battleship = "Red/Blue-Battleship",

depot = "Red/Blue-Depot",

aa = "Red/Blue-AA",

strike = "Red/Blue-Strike",

ambush = "Red/Blue-Ambush",

convoy = {
    
    [1] = "Red/Blue-Fuel-Convoy-", -- convoy units must be pre-placed with follow road type waypoints from the rear depot to each front depot. 
    e.g to create the blue fuel convoy to front depot 4 you need the following group in the mission with a waypoint to depot 4 and the group set to late activiation "Blue-Fuel-Convoy-1-4" 
    
    [2] = "Red/Blue-Ammo-Convoy-",
    
    [3] = "Red/Blue-Equipment-Convoy-",
}

Shipping:
Each team needs four different cargo ship templates and four armed escort templates to go with them. 

-- this is the initial shipping convoy that starts at the beginning of the mission. It should be placed halfway between the normal starting distance and the delivery zone
Red/Blue-ShipConvoy-Init
Red/Blue-ShipEscort-Init 

-- these should be placed at the far ends of the shipping zone and set to travel to the delivery zone
Red/Blue-ShipConvoy-1 through 3
Red/Blue-ShipEscort-1 through 3 

Bombers: 
Two bomber groups should be made for each team, set up to bomb the rear depot.
"Red/Blue Bombers-1" and "Red/Blue Bombers-2"

CAP:
One CAP group should be created for each team, set to orbit over the rear depot.
"Red/Blue-CAP"

Submarines: 
Each submarine should have 14 zones created around the perimiter of the enemy shipping zone. The format is {coalitionId}-sub-{start or end}-number. Corresponding start and end zones should have the same number and be placed in such a way that going from start to end takes the submarine through the shipping zone. An example for the red team submarine would be "1-sub-start-3" and "1-sub-end-3". There should be a start and end for 1 through 7 for 14 total zones for each team.

Ambushes:

Each team requires a group ("Red-Ambush" and "Blue-Ambush") to spawn along convoy routes. This should be a small group comprised of infantry and RPG with a truck in the group for resupply. 

In addition to the units, ambushes also require trigger zones along the ENEMY convoy routes to mark potential spawn points.(blue team ambush zones are placed along red convoy routes) Theres should be 8 ambush zones for each convoy route for a total of 32 zones per coalition.
naming format: {coalition}-{rear depot (should be 1)}-{destination depot}-ambush-{count (1-8)}
Example of a blue team ambush along the route to red front depot 3: 2-1-3-ambush-3
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