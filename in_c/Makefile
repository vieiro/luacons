
LUA_DIR=/Users/antonio/Library/LUA/LUA515/

CC=clang
CFLAGS=-g -Wall -fpic
LUA_INSTALLDIR=${LUA_DIR}/share/lua/5.1
LUA_INCLUDE=-I${LUA_DIR}/include
LUA_LFLAGS=-L${LUA_DIR}/lib

LINKER_OPTIONS_OSX=-shared -fpic -undefined dynamic_lookup
LINKER_OPTIONS_UNIX=-shared -fpic -Wl,-soname,cons.so
LINKER_OPTIONS=${LINKER_OPTIONS_OSX}

CONS_HEADERS=cons.h
CONS_SOURCES=cons.c
CONS_OBJS=$(CONS_SOURCES:.c=.o)

.SUFFIXES:.c

.c.o: $(CONS_HEADERS) Makefile
	$(CC) $(CFLAGS) -c $(LUA_INCLUDE) $<

cons.so: $(CONS_OBJS)
	$(CC) $(CONS_OBJS) $(LUA_LFLAGS) ${LINKER_OPTIONS_OSX} -o $@

test: cons.so
	lua test.lua

#install: pglua.so
#	cp pglua.so $(LUA_INSTALLDIR)
#	chown nobody:nobody $(LUA_INSTALLDIR)/pglua.so
#	chmod go-wx $(LUA_INSTALLDIR)/pglua.so

#uninstall:
#	rm -rf $(LUA_INSTALLDIR)/pglua.so

clean:
	rm -rf $(CONS_OBJS) cons.so
