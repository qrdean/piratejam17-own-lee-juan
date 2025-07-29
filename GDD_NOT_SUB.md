# Cat-Is-Factory Design Doc
## By qtipbluedog for Pirate Software Jam 17

## Introduction

#### Game Pitch
Only have one type of resource to work with. You are trying to make that resource into a bunch of different things

### Inspirations
My smelly cat
Satisfactory
Factorio
Animal Crossing

### Player Experience
Player start on island and has to make cans of cat food into various different objects. As New buildings/ recipes are unlocked the player has to make those things into a bunch of things.

### Theme 
Only One

### Title
Cat-Is-Factory

### Mechanics
'Mining' from one resource you transport it into another resource.
The puzzle comes from handling the routing of said resources and trading them off.

'Workers' pick up the items from a resource chain and send it off there can only be X number of workers per chain/only pick one at a time 
'Workers' can pick up the output of a transform and go to another transform or drop off zone.
Once you hit a milestone you unlock another set of recipes to use

Some resources are used to build buildings
There is a set number of workers.

Goal is to get a working boat to get off the island with all your cats

### Theme
Island Theme
Could be you were with a plane with a 1000's of cats. 
When you crashed you have a bunch of cats and cat food lying around.
Using the crashed parts you are able to automate the usage of cat food to create different items
Use all these parts to build a boat to get home 

### Recipe Ideas
E.g.
From catfood you crush up the cat food to create sand.
From catfood you feed it to the cats and concrete

Food -> Cat -> Litterbox -> BioFuel

Catfood -> Open -> Food + Catfood can('metal')
Can -> machine -> Ingot
Ingot -> machine -> Iron Plates
Ingot -> machine -> Wires

Concrete -> machine -> Foundation(?)
Catfood + Concrete -> brick
Catfood + Water -> 
Concrete -> blocks

Catfood can configurations
Full
Normal shape with can top open and food out
Lid
Flattened
Cut in two
Cut and straightened into strips 
'Nail' (strips cut in half and shaved down to a point)
Ring (top and bottom cut out)

Catfood configurations
Fuel for cats
Cat throw up (like concrete)
Cat scat (in litterbox) used as biofuel
'Fresh' Water (strainer) used 

'Canopener' can be made out of normal cat food cans uses 1 cat to open cans
input: none
output: empty catfood cans + food

Constructor can be made out of normal cat food cans

Recipes
flattened
input: opened catfood 3
output: 2 flattened
time: 3 sec

straightened
input: flattened 1
output: straight strips 1
2 sec

nails: 
input: straightened strips 1
output: nails 4
3 sec

rings:
input: opened catfood 1
output: ring 1
3 sec

reinforced catfood:
input: nails 12
input: flattened 6
output: reinforced catfood 1
6 sec

catfood rotator:
input: nails 25
input: straightened 5
output: rotator 1
8 sec

motor 
input: 
rotator 1
reinforced 2
output: 1 motor

propeller
input: 
reinforced: 3
rotator 2
output: propeller

Hull: 
input: 
reinforced catfood 50
nails 250

output: hull

Wheel:
input: 
reinforced 5
rings 120
rotator 1

Rutter:
reinforced 20
rotator 2
rings 10

Goal is to create a boat
Boat has:
Motors - 5 - cat + Wheel (cat food cans in a wheel configuration)
Propeller - 2 - cat food cans in a prop shape
Hull - 1 - Boat hull made out of straightened cat food cans
Wheel - 1 - made out of cat food cans 
Rutter - 2 - Straightened cat food can material
