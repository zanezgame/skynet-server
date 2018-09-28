CC ?= gcc

SHARED := -fPIC --shared

LUA_CLIB_PATH ?= luaclib

SKYNET_BUILD_PATH ?= ./3rd/skynet

CFLAGS = -g -O2 -Wall -I$(LUA_INC) 

LUA_STATICLIB := ./3rd/skynet/3rd/lua/liblua.a
LUA_LIB ?= $(LUA_STATICLIB)
LUA_INC ?= ./3rd/skynet/3rd/lua

LUA_CLIB =  websocketnetpack

all	:  $(LUA_CLIB_PATH)/websocketnetpack.so

$(LUA_CLIB_PATH) :
	mkdir $(LUA_CLIB_PATH)

$(LUA_CLIB_PATH)/websocketnetpack.so : lualib-src/lua-websocketnetpack.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) -I$(SKYNET_BUILD_PATH)/skynet-src $^ -o $@

clean :
	rm -f $(LUA_CLIB_PATH)/*.so
