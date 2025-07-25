## Automation Gameplay

~The ability to place objects on the ground basics handled~
~Have a resource entity, with a position and collision we can detect~
~The ability to click context menus that allow you to do things~
~Have workers that transport these items between places. Need pathfinding between two points.~
~Have a transform entity that allows the user to select a recipe to transform the item into something else~
~Worker has an receive and dropoff building selection. Set these via the context menu and it will build a path between the two~

Add Resource entity that can be built on by the canopener building. This building is free to start with but then costs 5 cans after?

Automation constructor
[x] Timer in Recipe to check for when a product is made
[x] Add highlighting to travel components when on the output menu
[x] Cap on inputs and outputs
[x] Delete Structures - needs more testing but basics seem to function
[x] Colors for recipes? This might need to be shader based? Or maybe I can change the albdeo of the material like in Godot? Testing is needed
[x] Start worker at 'origin' building 
[] Disable Output Targeting button based on number of current workers e.g. 0 workers enable button 1. 1 workers enable button 2 and so on.
[] ability to balance the inputs into other similar inputs
[] Add a fuel/electricity component with fuel
[] Think about ability to limit constructor output lines based on recipe,right now hardcoded to 8
[] Add ability to let workers go from a spot
[] Collector/Research Box. To handle upgrading Ships off to somewhere else
[] Need a transport system to get across the water

Upgrade system
[x] Need to add a system to track milestone progress and unlock different systems. (probably do this system later once we have basics working)
[x] Need a turn in spot. As we upgrade the tech to the boat tech we will need to update to more recipes

Display
[x] Need to display recipe requirements and time to construct per minute
[] Clearer indication on which places a building is hooked up to currently
[x] Update entities to work off of actual building types instead of model 'shapes'

[x] Add Terrain Heightmap
[x] Add Water Shaders
[] blocking between terrain and water

[] Add a storage box 'workers' can pull from - Hook this up to a UI so we can see what we have currently and can 'put' x number of items into machines/drop off zones.

Bugs

### Worker instructions
Buildings outputs can connect to another building, creating a path
e.g. Building a has output x Building b has input x click (a) -> select output x connect building b.

Grid System

## Art Design Themes?
Island Theme'd?

