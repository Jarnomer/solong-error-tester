#! /bin/bash

R="\033[0;31m" # Red
G="\033[0;32m" # Green
Y="\033[0;33m" # yellow
B="\033[0;34m" # Blue
P="\033[0;35m" # Purple
C="\033[0;36m" # Cyan

RB="\033[1;31m" # Bold
GB="\033[1;32m"
YB="\033[1;33m"
BB="\033[1;34m"
PB="\033[1;35m"
CB="\033[1;36m"

RC="\033[0m" # Reset Color
FLL="========================="
FLLTITLE="========================"

RM="rm -rf"
ECHO="echo -n"
NAME=so_long
BINPATH=./
MAP=test_map.ber
NOEXT=test_map_no_ext
RES=.checker.tmp

TEST_CURRENT=1

TIMEOUT_FULL=""
TIMEOUT_CMD=$(which timeout)
TIMEOUT_SEC=2

if [ -n "$TIMEOUT_CMD" ]; then
  TIMEOUT_FULL="$TIMEOUT_CMD $TIMEOUT_SEC"
fi

VALGRIND_FULL=""
VALGRIND_CMD=$(which valgrind)
VALGRIND_FLAGS="--leak-check=full \
  --show-leak-kinds=all \
  --track-fds=yes"

if [ -n "$VALGRIND_CMD" ]; then
  VALGRIND_FULL="$VALGRIND_CMD $VALGRIND_FLAGS"
fi

print_test_title() {
  printf "\n${BB}TEST ${TEST_CURRENT}:${RC} ${C}$1${RC}    \t"
  TEST_CURRENT=$((TEST_CURRENT + 1))
}

print_main_title() {
  printf "\033c" #clear terminal

  printf "${P}${FLLTITLE}${FLLTITLE}${FLLTITLE}${FLLTITLE}${RC}\n"
  printf "${CB}SOLONG:  \tERROR HANDLING TESTER${RC}\n\n"
  printf "${BB}EXITCODE:\t${RC}Exit code is not zero, indicating error\n"
  printf "${BB}STDERR:  \t${RC}Error message was written to stderr\n"
  printf "${BB}MESSAGE: \t${RC}Error included 'Error' and your message\n\n"
  printf "TEST\tDESCRIPTIONS\t\tEXITCODE\tSTDERR\t\tMESSAGE\t\tLEAKS\n"
  printf "${P}${FLLTITLE}${FLLTITLE}${FLLTITLE}${FLLTITLE}${RC}"
}

print_summary() {
  printf "\n${P}${FLLTITLE}${FLLTITLE}${FLLTITLE}${FLLTITLE}${RC}"
  printf "${GB}\nALL TESTS FINISHED!\n\n${RC}"
}

setup_tests() {
#   kill_process
  touch ${MAP}
}

cleanup() {
  ${RM} ${MAP} ${RES} ${NOEXT}*
#   kill_process
}

kill_process() {
  local pid=$(pgrep -f "${NAME}")

  if [ -n "$pid" ]; then
    kill -9 $pid >/dev/null 2>&1
    return 0
  fi
  return 1
}

check_requirements() {
  if [ -z "$TIMEOUT_FULL" ]; then
    printf "${YB}WARNING:${RC} ${C}'timeout'${RC} not available.\n"
  fi
  if [ -z "$VALGRIND_FULL" ]; then
    printf "${YB}WARNING:${RC} ${C}'valgrind'${RC} not available.\n"
  fi
}

check_leaks() {
  local has_leaks=0
  local open_fds=0

  base_cmd=$(echo "${NAME}" | sed "s|$TIMEOUT_FULL ||")
  valgrind_cmd="$VALGRIND_FULL --log-file=/dev/stdout $base_cmd"

  leak_output=$(eval "$valgrind_cmd" 2>/dev/null)

  open_fds=$(echo "$leak_output" | grep -A 1 "FILE DESCRIPTORS" |
    grep -o '[0-9]\+ open' | grep -o '[0-9]\+' | sort -nr | head -1)

  definitely_lost=$(echo "$leak_output" |
    grep -o 'definitely lost: [0-9,]\+ bytes' | grep -o '[0-9,]\+')
  indirectly_lost=$(echo "$leak_output" |
    grep -o 'indirectly lost: [0-9,]\+ bytes' | grep -o '[0-9,]\+')

  if [[ -n "$definitely_lost" && "$definitely_lost" != "0" ]] ||
    [[ -n "$indirectly_lost" && "$indirectly_lost" != "0" ]] ||
    { [ -n "$open_fds" ] && [ "$open_fds" -gt 3 ]; }; then
    has_leaks=1
  fi

  if [ $has_leaks -eq 0 ]; then
    printf "${GB}\t\t[OK]${RC}"
  else
    printf "${RB}\t\t[KO]${RC}"
  fi
}

message_checker() {
  error_message=$(head -1 <${RES})
  line_count=$(wc -l <${RES})
  local checker=0

  if [[ $error_message == *"Error"* ]]; then
    checker=$((checker + 1))
  fi
  if [ $line_count -eq 2 ]; then
    checker=$((checker + 1))
  fi
  if [ $checker -eq 2 ]; then
    printf "${GB}\t\t[OK]${RC}"
  else
    printf "${RB}\t\t[KO]${RC}"
  fi
}

stderr_checker() {
  if [ ! -s "${RES}" ]; then
    printf "${RB}\t\t[KO]${RC}"
  else
    printf "${GB}\t\t[OK]${RC}"
  fi
}

exitcode_checker() {
  local exit_code=$1

  if [ $exit_code -eq 139 ]; then
    printf "${YB}[SEGV]${RC}"
  elif [ $exit_code -eq 0 ]; then
    printf "${RB}[KO]${RC}"
  else
    printf "${GB}[OK]${RC}"
  fi
}

run_solong() {
  ${BINPATH}${NAME} ${MAP} >/dev/null 2>${RES}
  exitcode_checker $?
  stderr_checker
  message_checker
  check_leaks
}

run_logic_tests() {
  ${ECHO} '111111
10E0C1
1P0001
111111' >${MAP}

  print_test_title "Too few arguments"
  ${BINPATH}${NAME} >/dev/null 2>${RES}
  exitcode_checker $?
  stderr_checker
  message_checker

  print_test_title "Too many arguments"
  ${BINPATH}${NAME} ${MAP} ${MAP} >/dev/null 2>${RES}
  exitcode_checker $?
  stderr_checker
  message_checker

  print_test_title "Argument is folder"
  ${BINPATH}${NAME} libft >/dev/null 2>${RES}
  exitcode_checker $?
  stderr_checker
  message_checker

  print_test_title "File does not exist"
  ${BINPATH}${NAME} ${NOEXT} >/dev/null 2>${RES}
  exitcode_checker $?
  stderr_checker
  message_checker

  print_test_title "No file extension"
  mv ${MAP} ${NOEXT}
  ${BINPATH}${NAME} ${NOEXT} >/dev/null 2>${RES}
  exitcode_checker $?
  stderr_checker
  message_checker
  mv ${NOEXT} ${MAP}

  print_test_title "No file name"
  mv ${MAP} .ber
  ${BINPATH}${NAME} .ber >/dev/null 2>${RES}
  exitcode_checker $?
  stderr_checker
  message_checker
  mv .ber ${MAP}

  print_test_title "Bad file extension"
  mv ${MAP} ${NOEXT}.berr
  ${BINPATH}${NAME} ${NOEXT}.berr >/dev/null 2>${RES}
  exitcode_checker $?
  stderr_checker
  message_checker
  mv ${NOEXT}.berr ${MAP}

  print_test_title "Bad file extension"
  mv ${MAP} ${NOEXT}.bber
  ${BINPATH}${NAME} ${NOEXT}.bber >/dev/null 2>${RES}
  exitcode_checker $?
  stderr_checker
  message_checker
  mv ${NOEXT}.bber ${MAP}

  chmod -r ${MAP}
  print_test_title "No read permission"
  run_solong
  chmod +r ${MAP}
}

run_map_tests() {
  print_test_title "Map is empty"
  ${ECHO} '' >${MAP}
  run_solong

  print_test_title "Map has empty line"
  ${ECHO} '
' >${MAP}
  run_solong

  print_test_title "Map has empty line"
  ${ECHO} '111111

10E0C1
1P0001
111111' >${MAP}
  run_solong

  print_test_title "Map has empty line"
  ${ECHO} '111111
10E0C1
1P0001
111111
' >${MAP}
  run_solong

  print_test_title "Map not rectangle"
  ${ECHO} '1111
10E0C1
1P0001
111111' >${MAP}
  run_solong

  print_test_title "Map not rectangle"
  ${ECHO} '111111
10E0C1
1P01
111111' >${MAP}
  run_solong

  print_test_title "Map not rectangle"
  ${ECHO} '111111
10E0C1
1P0011
1111' >${MAP}
  run_solong

  print_test_title "No closed walls"
  ${ECHO} '1111E1
1000C1
1P0011
111111' >${MAP}
  run_solong

  print_test_title "No closed walls"
  ${ECHO} '111111
1E00C1
00010P
111111' >${MAP}
  run_solong

  print_test_title "No closed walls"
  ${ECHO} '111111
10E0C1
1P0111
111110' >${MAP}
  run_solong

  print_test_title "Map has no pickups"
  ${ECHO} '111111
10E001
1P0011
111111' >${MAP}
  run_solong

  print_test_title "Map has no player"
  ${ECHO} '111111
10E0C1
100011
111111' >${MAP}
  run_solong

  print_test_title "Too many players"
  ${ECHO} '111111
10E0C1
1P00P1
111111' >${MAP}
  run_solong

  print_test_title "Map has no exit"
  ${ECHO} '111111
1000C1
10P001
111111' >${MAP}
  run_solong

  print_test_title "Too many exits"
  ${ECHO} '111111
10E0C1
1P00E1
111111' >${MAP}
  run_solong

  print_test_title "Invalid character"
  ${ECHO} '111111
10E0C1
1P00K1
111111' >${MAP}
  run_solong

  print_test_title "Invalid character"
  ${ECHO} '111111
10E0C1
1P0001
11111G' >${MAP}
  run_solong

  print_test_title "No valid path"
  ${ECHO} '1111111111111111111111111111111111
1E0010000000000C00000C000000000001
1001010100100000101001000000010101
1010010010101010001001000000010111
11P000000C00C0000000000000000010C1
1111111111111111111111111111111111' >${MAP}
  run_solong

  print_test_title "No valid path"
  ${ECHO} '1111111111111111111111111111111111
1000000000000000100000000000000001
1000000C000000001000000C0000000001
1000000000000000100000000000000001
1000P00000000000100000000000000E01
1111111111111111111111111111111111' >${MAP}
  run_solong

  print_test_title "No valid path"
  ${ECHO} '1111111111111111111111111111111111
1000000000000000000000000000000001
100000000000000E000000000000000001
1000000000000000000000000000000001
1000000000000000000000000000000001
1111111111111111111111111111111111
1000000000000000000000000000000001
1000000000000000000000000000000001
1000000000000000000000000000000001
1000000000000000000000000000C00001
1000000000000000C0000000000P000001
1000000000000000000000000000000001
1000000000000000000000000000000001
1111111111111111111111111111111111' >${MAP}
  run_solong

  print_test_title "No valid path"
  ${ECHO} '1111111111111111111111111111111111
1000010001000000000000000000000001
10E1000100011101111111111000011101
11111111111000001100100000001C1001
1000P00000000000000000111000110011
1111111111111111111111111111111111' >${MAP}
  run_solong

  print_test_title "No valid path"
  ${ECHO} '1111111111111111111111111111111111
1000P000000000000E0000C00000000011
1111111111111111111111111111111111' >${MAP}
  run_solong
}

if ! [ -f "$NAME" ]; then
  printf "\n${CB}INFO: ${RC}Binary ${YB}<$NAME>${RC} not found...\n"
  printf "\n${CB}INFO: ${RC}Running ${GB}Makefile${RC}...\n"
  make >/dev/null
fi

if [ -f "$NAME" ]; then
  check_requirements
  print_main_title
  setup_tests
  run_logic_tests
  run_map_tests
  print_summary
#   kill_process
  cleanup
fi
