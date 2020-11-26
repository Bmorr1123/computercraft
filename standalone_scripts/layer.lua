volume_width = arg[1]
volume_height = arg[2]
volume_depth = arg[3]
volume = arg[1] * arg[2] * arg[3]

location_x = arg[4]
location_y = arg[5]
location_z = arg[6]
heading = arg[7]

parentId = arg[8]
parentProtocol = arg[9]

rednet.open("right")

function goToLocation(x, y, z, toDig)
    toDig = toDig or false
    current_location = vector.new(gps.locate())
    print(current_location)
end

directions = {"north", "east", "south", "west"}

myName = os.getComputerLabel()
if myName == nil then
    myName = os.computerID()
end
os.setComputerLabel(tostring(myName))
print("I am turtle", myName)
for i = 1, 16 do
    term.write("-")
end
print()
print("Told to mine a "..volume_width.."x"..volume_height.."x"..volume_depth.." area ("..volume.." blocks^3)")
print("At ("..location_x..", "..location_y..", "..location_z..")")
print("Currently facing "..directions[heading + 1])
