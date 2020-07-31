#define HIDE __attribute__ ((visibility ("hidden")))

#include <iostream>
#include <string>
#include <sstream>
#include <string>
#include <vector>
#include <algorithm>
#include <functional>
#include <iterator>

extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "lobject.h"
#include "lstring.h"
#include "lfunc.h"
#include "ldo.h"
#include "lopcodes.h"
#include "lstring.h"
}

HIDE static const char kBytecodeMagic[] = "RSB1";
HIDE static const unsigned int kBytecodeHashSeed = 42;
HIDE static const unsigned int kBytecodeHashMultiplier = 41;

HIDE enum BytecodeConstantType
{
	Constant_Nil,
	Constant_Bool,
	Constant_Number,
	Constant_String,
	Constant_Method,
	Constant_Global,
};

HIDE class LuauSerializer {
public:
	HIDE static std::string writeClosure(lua_State* L);
	HIDE static int readClosure(lua_State* L, const char* chunkname, const char* source, size_t len);
};
