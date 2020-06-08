/*	
 *	This file contains c++ pseudo-code of all classes and object types that was used in program 
 */
#include "factorioapi.h"
#include <string>
#include <list>
#include <map>

using namespace std; 
using namespace factorio;

namespace Pixels {
	enum Colors { red, green, blue, yellow, pink, cyan, white, grey, black, default };

	class global {
		public:
			LuaSurface Surface;
			// Collection of pixels stored by their unique ID and divided by Surface Name
			map<string, map<int, Pixel>> Pixels;
			// List of pending tiles to be updated in next interation. Becomes empty after each time
			list<Tile> Redraw_Queue;
	};
	
	class Tile {
		public:
			string name;
			LuaPosition position;
	};

	class Pixel {
		public:
			int id;
			Tile tile;
			LuaEntity diode;
	};
}