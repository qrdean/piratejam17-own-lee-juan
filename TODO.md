## Automation Gameplay

~The ability to place objects on the ground~ basics handled
~~Have a resource entity, with a position and collision we can detect~~

~~The ability to click context menus that allow you to do things~~

~~Have workers that transport these items between places. Need pathfinding between two points.~~

Update entities to work off of actual building types instead of model 'shapes'

Add Resource entity that can be built on by the canopener building. This building is free to start with but then costs 5 cans after?

Automation constructor
[x] Timer in Recipe to check for when a product is made
[x] Add highlighting to travel components when on the output menu
[x] Cap on inputs and outputs
[x] Delete Structures - needs more testing but basics seem to function
[] ability to balance the inputs into other similar inputs
[] Colors for recipes? This might need to be shader based? Or maybe I can change the albdeo of the material like in Godot? Testing is needed
[] Add a fuel/electricity component with fuel
[] Think about ability to limit constructor output lines based on recipe,right now hardcoded to 8
[] Disable Output Targeting button based on number of current workers e.g. 0 workers enable button 1. 1 workers enable button 2 and so on.
[] Add ability to let workers go from a spot

Upgrade system
[] Need to add a system to track milestone progress and unlock different systems. (probably do this system later once we have basics working)
[] Need a turn in spot. As we upgrade the tech to the boat tech we will need to update to more recipes

Add a storage box 'workers' can pull from

Bugs

### Worker instructions
Workers can have instructions. 
old??
Click building. Has a number of output worker slots (more outputs gives more slots)
Buildings outputs can connect to another building, creating a path
e.g. Building a has output x Building b has input x click (a) -> select output x connect building b.

Worker has an receive and dropoff building selection. Set these via the context menu and it will build a path between the two

Have a transform entity that allows the user to select a recipe to transform the item into something else
Collector Box. Ships off to somewhere else

Grid System

(might not do this could be too much)
- The resource has to be "transformed" literally in 3D space in-order for it to be accepted into certain machines
- Lets say we have cubes or something, we slice the cube in half. Then have to rotate the cube in place for it to do something.

## Art Design Themes?
Island Theme'd?

