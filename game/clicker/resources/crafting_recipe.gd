class_name CraftingRecipe
extends MyNamedResource
## CraftingRecipe — stub for future crafting system.
## Drop .tres files into game/clicker/registries/recipes/ to register new recipes.

@export var ingredients: Dictionary  # item name -> int count
@export var result_item: String
@export var result_count: int = 1
