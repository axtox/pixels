#include <factorioapi>
using namespace factorio;

enum Colors : string { "red", "green", "blue", "yellow", "pink", "cyan", "white", "grey", "black", "default" }

struct Position {
	int x;
	int y;
}

///<summary>
///	Class for tile defining. It stores original tile name for 
///	tile recover on entity destroyed and new tile that will appar under lamp coordinates.
///</summary>
class LampTile {
	public:
		Position position;	//position of tile
		string color;	//name of color from color enum
		string original_tile_name;	//name of original tile protype
		string new_tile_name; //name of new tile protype based on color and old tile name
		LampTile(Position position, string color, string original_tile_name) {
			this.position = position;
			this.color = color;
			this.original_tile_name = original_tile_name;
			this.new_tile_name = "lamp-" + old_tile_name + "-map-" + color_name;
		}
}

///<summary>
/// Lamp entity is used for iteratie tiles that 
///	lamp stands on and update colors using circuit network on lamp object
///</summary>
class ColoredLampEntity {
	public:
		factorio::LuaEntity entity;
		LampTile tile;
		ColoredLampEntity(factorio::LuaEntity entity, LampTile tile) {
			this.entity = entity
			this.tile = LampTile
		}
}