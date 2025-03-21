#! /bin/bash

R="\033[0;31m" # Red
G="\033[0;32m" # Green
Y="\033[0;33m" # Yellow
B="\033[0;34m" # Blue
P="\033[0;35m" # Purple
C="\033[0;36m" # Cyan

RB="\033[1;31m" # Bold Red
GB="\033[1;32m" # Bold Green
YB="\033[1;33m" # Bold Yellow
BB="\033[1;34m" # Bold Blue
PB="\033[1;35m" # Bold Purple
CB="\033[1;36m" # Bold Cyan

RC="\033[0m" # Reset Color

FLLTITLE="======================"

RM_CMD="rm -rf"
ECHO_CMD="echo -n"
NAME=so_long
BINPATH=./
TEST_DIR=test_tmp_dir
TEST_MAP=test_map.ber
MAP_NO_EXT=test_map
TEST_LOG=so_long_test.log

TESTS_PASSED=0
TESTS_FAILED=0
TEST_CURRENT=1

ALL_TESTS=1
SELECTED_TESTS=""

VERBOSE_MESSAGE=0
TEST_LEAKS=0

TIMEOUT_FULL=""
TIMEOUT_CMD=$(which timeout)
TIMEOUT_SEC=0.3

if [ -n "$TIMEOUT_CMD" ]; then
  TIMEOUT_FULL="$TIMEOUT_CMD $TIMEOUT_SEC"
fi

VALGRIND_FULL=""
VALGRIND_CMD=$(which valgrind)
VALGRIND_OPTS="--leak-check=full \
  --show-leak-kinds=all \
  --track-fds=yes"

if [ -n "$VALGRIND_CMD" ]; then
  VALGRIND_FULL="$VALGRIND_CMD $VALGRIND_OPTS"
fi
