/*
 * Lua cons cells as C objects.
 * WARNING: This is an experiment, it does not handle cycles properly.
 * (C) 2014 Antonio Vieiro (antonio@antonioshome.net)
 * MIT License
 */
#ifndef _CONS_LUA_H
#define _CONS_LUA_H

#ifdef WIN32
#define EXPORT __declspec(dllexport)
#else
#define EXPORT
#endif /* WIN32 */

#include <lua.h>

extern int EXPORT luaopen_cons(lua_State *L);

#endif /* ifndef _CONS_LUA_H */
