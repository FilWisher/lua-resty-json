#################################################################
#
#      Binaries we are going to build, and its source code
#
#################################################################
#
SRC := mempool.c scaner.c parse_array.c parse_hashtab.c parser.c
OBJ := $(SRC:.c=.o)

DEMO := demo
C_SO_NAME := libljson.so

#################################################################
#
#       Compile and link flags
#
#################################################################
#
CFLAGS := -Wall -O3 -flto -g -MMD -fPIC -fvisibility=hidden #-DDEBUG

#################################################################
#
#       Installtion flags
#
#################################################################
#
PREFIX := /usr/local
LUA_VERSION = 5.1
SO_TARGET_DIR := $(PREFIX)/lib/lua/$(LUA_VERSION)
LUA_TARGET_DIR := $(PREFIX)/share/lua/$(LUA_VERSION)/

#################################################################
#
#       Make recipes
#
#################################################################
#
.PHONY = all test clean install

all : $(C_SO_NAME) $(DEMO)

-include dep.txt

${OBJ} : %.o : %.c
	$(CC) $(CFLAGS) -DBUILDING_SO -c $<

${C_SO_NAME} : ${OBJ}
	$(CC) $(CFLAGS) -DBUILDING_SO $^ -shared -o $@
	cat *.d > dep.txt

demo : ${C_SO_NAME} demo.o
	$(CC) $(CFLAGS) -Wl,-rpath=./ demo.o -L. -lljson -o $@

test :
	$(MAKE) -C tests

clean:; rm -f *.o *.so a.out *.d dep.txt

install:
	install -D -m 755 $(C_SO_NAME) $(DESTDIR)/$(SO_TARGET_DIR)/$(C_SO_NAME)
	install -D -m 664 json_decoder.lua  $(DESTDIR)/$(LUA_TARGET_DIR)/json_decoder.lua
