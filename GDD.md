# cat-is-factory design doc
## by qtipbluedog for pirate software jam 17

## introduction

#### game pitch
only have one type of resource to work with. you are trying to make that resource into a bunch of different things

### inspirations
my smelly cat
satisfactory
factorio
animal crossing

### player experience
player start on island and has to make cans of cat food into various different objects. as new buildings/ recipes are unlocked the player has to make those things into a bunch of things.

### platform
web

### development software
raylib - [https://www.raylib.com/index.html]
odin - [https://odin-lang.org/docs/overview/]
blender - [https://www.blender.org/]
studio one - [https://www.presonus.com/pages/studio-one-pro]

### genre
factory sim

### target audience
nerds that like logistics

## concept

### gameplay overview
the player starts off with a limited number of options on what to do. this is to guide the player into how to "transform" objects in the world. as the game goes on logistics will increase.

### theme interpretation
only one resource to work with

### mechanics
'mining' from one resource you transport it into another resource.
the puzzle comes from handling the routing of said resources and trading them off.

'workers' pick up the items from a resource chain and send it off there can only be x number of workers per chain/only pick one at a time 
'workers' can pick up the output of a transform and go to another transform or drop off zone.
once you hit a milestone you unlock another set of recipes to use

some resources are used to build buildings
there is a set number of workers.

goal is to get a working boat to get off the island with all your cats

## art design
went with a simplified color pallette and low poly aesthetic to give off that retro feel.

## audio
simple calm music. simple select button tones

## ui
very basic ui driving the gameplay. all buttons in the game will allow the player to place buildings, add more cat workers, and change their output 

### controls
wasd - move the camera
eq - rotate camera
i - show inventory
k - keyboard shortcuts

### Recipe Ideas
(some of these aren't implemented obviously)
Spoilers for all the recipes in the game
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
