#! /bin/bash

source "$(dirname "$0")/variables.sh"

print_test_title() {
  printf "\n${BB}${TEST_CURRENT}${RC}\t${C}$1${RC}    \t"
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
  printf "\n${P}${FLLTITLE}${FLLTITLE}${FLLTITLE}${FLLTITLE}${RC}\n\n"
  printf "${BB}Tests passed:${RC} ${GB}$TESTS_PASSED${RC}\n"
  printf "${BB}Tests failed:${RC} ${RB}$TESTS_FAILED${RC}\n\n"

  if [ $TESTS_FAILED -eq 0 ]; then
    printf "${GB}All tests passed!${RC}\n"
  else
    printf "Failed ${RB}$TESTS_FAILED${RC} tests!${RC}\n"
  fi
}

print_usage() {
  printf "\n${CB}Usage:${RC} %s ${GB}[OPTIONS]${RC}\n\n" "$0"
  printf "${GB}Options:${RC}\n"
  printf "  ${GB}-t${RC}, ${G}--test ID  ${P}Run specific test by ID${RC}\n"
  printf "  ${GB}-v${RC}, ${G}--verbose  ${P}Verbose error messages${RC}\n"
  printf "  ${GB}-l${RC}, ${G}--leaks    ${P}Test leaks with valgrind${RC}\n"
  printf "  ${GB}-h${RC}, ${G}--help     ${P}Show this help message${RC}\n\n"
}

setup_test_files() {
  touch ${TEST_MAP}
  mkdir ${TEST_DIR}
}

cleanup() {
  ${RM_CMD} ${TEST_DIR} ${TEST_MAP} ${TEST_LOG} ${MAP_NO_EXT}*
}

handle_ctrlc() {
  printf "\n\n${RB}Test interrupted by user.${RC}\n"
  cleanup
  exit 1
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

  base_cmd=$(echo "${BINPATH}${NAME}" | sed "s|$TIMEOUT_FULL ||")
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

  return $has_leaks
}

message_checker() {
  error_message=$(head -1 <${TEST_LOG})
  line_count=$(wc -l <${TEST_LOG})
  local checker=0

  if [[ $error_message == *"Error"* ]]; then
    checker=$((checker + 1))
  fi
  if [ $line_count -eq 2 ]; then
    checker=$((checker + 1))
  fi
  if [ $checker -eq 2 ]; then
    printf "${GB}\t\t[OK]${RC}"
    return 0
  else
    printf "${RB}\t\t[KO]${RC}"
    return 1
  fi
}

stderr_checker() {
  if [ ! -s "${TEST_LOG}" ]; then
    printf "${RB}\t\t[KO]${RC}"
    return 1
  else
    printf "${GB}\t\t[OK]${RC}"
    return 0
  fi
}

exitcode_checker() {
  if [ $1 -eq 139 ]; then
    printf "${YB}[SEGV]${RC}"
    return 1
  elif [ $1 -eq 0 ]; then
    printf "${RB}[KO]${RC}"
    return 1
  else
    printf "${GB}[OK]${RC}"
    return 0
  fi
}

verbose_message() {
  error=$(head -1 <${TEST_LOG})
  message=$(tail -n +2 ${TEST_LOG})

  printf "\n${BB}MESSAGE:${RC} $error ${RC}| $message ${RC}\n"
}
