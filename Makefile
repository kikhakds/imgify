# cut is necessary for Cygwin
PLATFORM_OS := $(shell uname | cut -d_ -f1)


#   make BUILD=release
#   make BUILD=debug
BUILD ?= release

#   make BUILD=debug SANITIZE=address,undefined
SANITIZE ?=

#   make BUILD=debug COVERAGE=1
COVERAGE ?=

CC := clang
FUZZ ?= 0

ifeq ($(FUZZ), 1)
	CC := afl-clang-fast
endif

all: bin2png png2bin

clean:
	@rm -rf *.o bin2png png2bin *.gcda *.gcno

CFLAGS += -D_XOPEN_SOURCE=600 -std=c99 -Wall -Wextra
LDFLAGS += -lpng

ifeq ($(PLATFORM_OS), Linux)
	LDFLAGS += -lm # required for sqrt()
endif

ifeq ($(BUILD), debug)
	CFLAGS += -g -O0 -DDEBUG
else ifeq ($(BUILD), release)
	CFLAGS += -O2 -DNDEBUG
else
	$(error Unknown BUILD=$(BUILD); use BUILD=debug or BUILD=release)
endif

ifneq ($(SANITIZE),)
	CFLAGS += -fsanitize=$(SANITIZE) -fno-omit-frame-pointer -g
	LDFLAGS += -fsanitize=$(SANITIZE)
endif

ifeq ($(COVERAGE), 1)
	CFLAGS += --coverage
	LDFLAGS += --coverage
endif

common.o: common.h
	echo $(PLATFORM_OS)
	$(CC) -o $@ -c common.c $(CFLAGS)

imgify.o: imgify.h
	$(CC) -o $@ -c imgify.c $(CFLAGS)

bin2png: common.o imgify.o
	$(CC) -o $@ bin2png.c $^ $(CFLAGS) $(LDFLAGS)

png2bin: common.o imgify.o
	$(CC) -o $@ png2bin.c $^ $(CFLAGS) $(LDFLAGS)
