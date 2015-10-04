#!/usr/bin/make
# Compilation directives for XFer in C
#
# Copyright (c) Greg Cook 2013
#
# Freely redistributable file.  See file LICENSE for details.

# C compiler and flags.  Adjust to taste.
CC = gcc
CFLAGS = -O3 -Wall -fomit-frame-pointer
# Binary optimiser.
STRIP = strip
SFLAGS = --strip-unneeded
# Shell commands
RM = rm

# Target executable
EXE = xfer
# Target objects
TARGETS = first.o linux.o main.o win32.o xfer.o
# Header files
HEADERS = xfer.h
# Pre-compiled executables
BINS = ../bin/i386-linux/xfer ../bin/raspbian/xfer ../bin/win32/xfer.exe

# Optional compilation macros
MACROS =

.PHONY: clean all

all: $(EXE)

$(EXE): $(TARGETS)
	$(CC) $(CFLAGS) -o $@ $+
	-$(STRIP) $(SFLAGS) $@ $@.exe

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) $(MACROS) -c $<

clean:
	-$(RM) $(EXE) $(TARGETS) $(BINS) core
