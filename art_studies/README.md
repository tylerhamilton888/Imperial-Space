# Imperial Space scene art kit

Open this folder’s `project.godot` in Godot 4.7.2 and press **F5**. Use the top tabs or **1–4** to switch studies. In the range, click the breach and fixture buttons to compare the layouts. In Heavy armor, click the weapon pose button or press **V**. **B** swaps the wall painting.

## What you can use

| Study | Reusable artwork |
| --- | --- |
| Imperial Proving Ground | Three numbered range bays, observation booth and gantry on the backdrop. The sliding target, terminal and two registered wall states are independent scenes. |
| Karth Vale, wide view | Civic arsenal, transit station, terraces and canal on the backdrop. Planter, modular stair, wrecked van and transit sign can be placed separately. |
| Cruiser Bridge | Windowed bridge with command dais. Separate holomap, side console, chair, Captain Vale, two unhelmeted Crusader views, seated operator and posted guard. The dialogue panel has editable speaker, portrait, line and reply nodes. |
| Heavy Proving Ground | Four foot-anchored armor studies: cannon ready, reverse cannon view, hammer ready and raised hammer. The range assembly is shared with the Medium study. |

Drag a prop’s `.tscn` from `kits/` into a Godot 2D scene. Its origin is the ground contact. Put it under a Y-sorted node when it needs to pass in front of or behind an actor. Place either wall state at the same position and scale. Copy a kit folder with its textures and scene files together. The `interface/` folder contains nine action icons, a Vale portrait, a shared panel style, combat readouts and a dialogue panel.

The 1280 × 720 studies present movable art and sample interface values. The Heavy set has four static poses. Collision, destructible navigation, crew interactions and combat animation require integration into the game. The five assets in `review/scale/` come from the existing playable arena and provide its scale reference.

Full-resolution painting masters, packing instructions and the four owner-selected reference boards are maintained in the [Imperial Space repository](https://github.com/tylerhamilton888/Imperial-Space).
