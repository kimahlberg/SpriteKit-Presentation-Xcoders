# Bubble up
"An iPhone app that lets your worst performing KPIs bubble up to the top of the screen in a
 fluid and playful manner."

# Usage
- Tap a bubble to bring up a detail view.
- Two finger tap toggles SpriteKit performance statistics display.
- Device orientation affects the bubbles' behavior.
- Shake the device to reload data.


# Files
GameScene.m
- This is the most interesting file for SpriteKit purposes, it handles the bubbles and touch interaction.

GameViewController.m
- Sets up the SpriteKit scene and handles hiding/showing of the detail view.

DataModel.m
- Loads the data from Data.plist and provides it to the GameScene.

KpiModel.m
- Holds information about a KPI (Key Performance Indicator).

KpiDetailViewController.m
- Controller for the detail view.
