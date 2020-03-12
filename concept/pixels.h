/*	
 *	This file contains c++ pseudo-code of all classes and object types that was used in program 
 */
#include "factorioapi.h"
#include <string>
#include <map>

using namespace std; 
using namespace factorio;

namespace Pixels {
	enum Colors { red, green, blue, yellow, pink, cyan, white, grey, black, default };

	class global {
		public:
			LuaSurface Surface;
			map<int, Pixel> Pixels;
	};
	
	class Tile {
		public:
			string name;
			LuaPosition position;
	};

	class Pixel {
		public:
			Tile tile;
			LuaEntity diode;
	};
}