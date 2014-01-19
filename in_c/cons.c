/*
 * Lua cons cells as C objects.
 * WARNING: This is an experiment, it does not handle cycles properly.
 * (C) 2014 Antonio Vieiro (antonio@antonioshome.net)
 * MIT License
 */

#include "cons.h"

#include <lualib.h>
#include <lauxlib.h>
#include <stdio.h>
#include <assert.h>

#define VERBOSE 0

const char * CONS_METATABLE_NAME       = "cons_mt";
const char * CONS_INDEX_METATABLE_NAME = "cons_index_mt";

typedef struct cell {
	int car_ref;
	int cdr_ref;
} * cell_t;

/* Forward declarations */
cell_t to_cell(lua_State * L, int index);
static int EXPORT cons_gc(lua_State * L);
static int EXPORT cons_new(lua_State * L);
static int EXPORT cons_set_car(lua_State * L);
static int EXPORT cons_get_car(lua_State * L);
static int EXPORT cons_set_cdr(lua_State * L);
static int EXPORT cons_get_cdr(lua_State * L);

/* Implementation */

cell_t to_cell(lua_State * L, int index)
{
	luaL_checktype(L, index, LUA_TUSERDATA);
	cell_t cell = (cell_t) lua_touserdata(L, index);
	if (cell == NULL) {
		luaL_typerror(L, index, "Expected a cell as argument");
	}
	return cell;
}

static int EXPORT cons_gc(lua_State * L)
{
	cell_t cell = to_cell(L, 1);
	if (cell == NULL) {
		return 0;
	}
#if VERBOSE == 1
	fprintf(stdout, "Garbage collecting cell %p (%d,%d)\n", cell, cell->car_ref, cell->cdr_ref);
#endif
	luaL_unref(L, LUA_REGISTRYINDEX, cell->car_ref);
	luaL_unref(L, LUA_REGISTRYINDEX, cell->cdr_ref);
	return 0;
}


int EXPORT cons_new(lua_State * L)
{
	int nargs = lua_gettop(L);
	if (nargs > 2) {
		luaL_error(L, "Error: at most two arguments expected");
	}
	int cdr_ref = nargs > 1 ? luaL_ref(L, LUA_REGISTRYINDEX) : LUA_NOREF;
	int car_ref = nargs > 0 ? luaL_ref(L, LUA_REGISTRYINDEX) : LUA_NOREF;

	cell_t new_cell = lua_newuserdata(L, sizeof(struct cell));
	if (new_cell == NULL) {
		return 0;
	}
	new_cell->car_ref = car_ref;
	new_cell->cdr_ref = cdr_ref;
	luaL_getmetatable(L, CONS_METATABLE_NAME);
	lua_setmetatable(L, -2);
	return 1;
}

int EXPORT cons_set_car(lua_State * L)
{
	luaL_checkany(L, 2);
	cell_t cell = to_cell(L, 1);
#if VERBOSE == 1
	fprintf(stdout, "Cell %p unreferencing %d\n", cell, cell->car_ref);
#endif
	luaL_unref(L, LUA_REGISTRYINDEX, cell->car_ref);
	cell->car_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	return 0;
}

int EXPORT cons_get_car(lua_State * L)
{
	cell_t cell = to_cell(L, 1);
	lua_rawgeti(L, LUA_REGISTRYINDEX, cell->car_ref);
	return 1;
}

int EXPORT cons_set_cdr(lua_State * L)
{
	luaL_checkany(L, 2);
	cell_t cell = to_cell(L, 1);
#if VERBOSE == 1
	fprintf(stdout, "Cell %p unreferencing %d\n", cell, cell->cdr_ref);
#endif
	luaL_unref(L, LUA_REGISTRYINDEX, cell->cdr_ref);
	cell->cdr_ref = luaL_ref(L, LUA_REGISTRYINDEX);
	return 0;
}

int EXPORT cons_get_cdr(lua_State * L)
{
	cell_t cell = to_cell(L, 1);
	lua_rawgeti(L, LUA_REGISTRYINDEX, cell->cdr_ref);
	return 1;
}



int cons_is_nil(cell_t cell)
{
	return cell->car_ref == LUA_NOREF && cell->cdr_ref == LUA_NOREF;
}

void cons_tostring_recursive(lua_State *L, luaL_Buffer * s, cell_t cell)
{
	if (cons_is_nil(cell)) {
		luaL_addstring(s, "()");
	} else {
		luaL_addchar(s, '(');

		if (cell->car_ref == LUA_NOREF) {
			luaL_addstring(s, "()");
		} else {
			lua_rawgeti(L, LUA_REGISTRYINDEX, cell->car_ref);
			if (!lua_isuserdata(L, -1)) {
				luaL_addvalue(s);
			} else {
				cell_t car = to_cell(L, -1);
				cons_tostring_recursive(L, s, car);
				lua_pop(L, 1);
			}
		}

		if (cell->cdr_ref != LUA_NOREF) {
			luaL_addchar(s, ' ');
			lua_rawgeti(L, LUA_REGISTRYINDEX, cell->cdr_ref);
			if (!lua_isuserdata(L, -1)) {
				luaL_addvalue(s);
			} else {
				cell_t cdr = to_cell(L, -1);
				cons_tostring_recursive(L, s, cdr);
				lua_pop(L, 1);
			}
		}
		luaL_addchar(s, ')');
	}
}

int EXPORT cons_tostring(lua_State * L)
{
	cell_t cell = to_cell(L, 1);
	luaL_Buffer buffer;
	luaL_buffinit(L, &buffer);
	cons_tostring_recursive(L, &buffer, cell);
	luaL_pushresult(&buffer);
	return 1;
}

static const luaL_Reg CONS_METHODS [] = {
	{"car",           cons_get_car},
	{"set_car",       cons_set_car},
	{"cdr",           cons_get_cdr},
	{"set_cdr",       cons_set_cdr},
	{"new",           cons_new},
	{NULL, NULL},
};

LUALIB_API int EXPORT
    luaopen_cons(lua_State * L)
{
	/* Create a new table with methods */
	lua_newtable(L);
	int methodtable = lua_gettop(L);

	luaL_newmetatable(L, CONS_METATABLE_NAME);
	int metatable = lua_gettop(L);

	lua_pushliteral(L, "__metatable");
	lua_pushvalue(L, methodtable);
	lua_settable(L, metatable);

	lua_pushliteral(L, "__index");
	lua_pushvalue(L, methodtable);
	lua_settable(L, metatable);

	lua_pushliteral(L, "__gc");
	lua_pushcfunction(L, cons_gc);
	lua_settable(L, metatable);

	lua_pushliteral(L, "__tostring");
	lua_pushcfunction(L, cons_tostring);
	lua_settable(L, metatable);

	lua_pop(L, 1);

	/* Fill methods */
	luaL_openlib(L, 0, CONS_METHODS, 0);
	return 1;
}
