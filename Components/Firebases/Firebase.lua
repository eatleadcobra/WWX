--C.O.B.R.A. SYSTEM
--Coordinated Order of Battle and Requisitions Administrator 
Firebase = {
    id = 0,
    coalition = 1,
    fbType = "MORTAR",
    isAssigned = false,
    positions = {
        location = {},
        heading = 0,
        spawnPoints = {
            groups = {},
            truck = {}
        },
    },
    contents = {
        groups = {

        },
        truck = "",
        ammo = 0,
        maxAmmo = 40,
    },
    markups = {
        main = 0,
        range = 0,
        ammoCounter = {
            background = 0,
            ammoAmt = 0
        },
        symbol = {

        },
        groups = {
            backgrounds = {

            },
            fills = {

            },
        },
        firing = {
            circle = 0,
            line = 0,
        }
    }
}
function Firebase:removeGroup(groupName)
    for i = 1, #self.contents.groups do
        if self.contents.groups[i] == groupName then
            table.remove(self.contents.groups, i)
            break
        end
    end
end
function Firebase:expendAmmo(amt)
    self.contents.ammo = self.contents.ammo - amt
end
function Firebase:addAmmo(amt)
    self.contents.ammo = self.contents.ammo + amt
    if self.contents.ammo > self.contents.maxAmmo then
        self.contents.ammo = self.contents.maxAmmo
    end
end
function Firebase:setAmmo(amt)
    self.contents.ammo = amt
    if self.contents.ammo > self.contents.maxAmmo then
        self.contents.ammo = self.contents.maxAmmo
    end
    Firebases.updateAmmoCounter(self)
end
function Firebase:setGuns(amt, type)
    if #self.contents.groups >= amt then
        return
    else
        local neededGuns = amt - #self.contents.groups
        for i = 1, neededGuns do
            Firebases.addGroupToFirebase(self, type)
        end
    end
end
function Firebase:unassign()
    self.assigned = false
end
function Firebase:assign()
    self.assigned = true
end
function Firebase:isAssigned()
    return self.assigned
end
function Firebase:new()
    return Firebase.deepcopy(self)
end

function Firebase.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[Firebase.deepcopy(orig_key)] = Firebase.deepcopy(orig_value)
        end
        setmetatable(copy, Firebase.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end