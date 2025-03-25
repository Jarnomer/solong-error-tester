#! /bin/bash

source "$(dirname "$0")/variables.sh"
source "$(dirname "$0")/utils.sh"

run_solong() {
  local title=$1
  local map=$2
  local extra_arg=$3

  # Skip test if not selected
  if [ "$ALL_TESTS" -eq 0 ]; then
    if ! echo "$SELECTED_TESTS" | grep -q "\b$TEST_CURRENT\b"; then
      TEST_CURRENT=$((TEST_CURRENT + 1))
      return
    fi
  fi

  print_test_title "$title"

  ${TIMEOUT_FULL} "${BINPATH}${NAME}" $map $extra_arg >/dev/null 2>"${TEST_LOG}"

  local exit_code=$?
  local exit_ok=0
  local stderr_ok=0
  local msg_ok=0

  exitcode_checker $exit_code
  exit_ok=$?

  stderr_checker
  stderr_ok=$?

  message_checker
  msg_ok=$?

  if [ "$TEST_LEAKS" -eq 1 ] && [ -n "$TIMEOUT_FULL" ]; then
    check_leaks
  else
    printf "${YB}\t\t-${RC}"
  fi

  if [ "$VERBOSE_MESSAGE" -eq 1 ]; then
    verbose_message
  fi

  if [ $exit_ok -eq 0 ] && [ $stderr_ok -eq 0 ] && [ $msg_ok -eq 0 ]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi

  TEST_CURRENT=$((TEST_CURRENT + 1))
}

run_logic_tests() {
  ${ECHO_CMD} '111111
10E0C1
1P0001
111111' >"${TEST_MAP}"

  run_solong "Too few arguments"
  run_solong "Too many arguments" "${TEST_MAP}" "${TEST_MAP}"
  run_solong "Argument is folder" "${TEST_DIR}"
  run_solong "File does not exist" "${MAP_NO_EXT}"

  mv "${TEST_MAP}" "${MAP_NO_EXT}"
  run_solong "No file extension" "${MAP_NO_EXT}"
  mv "${MAP_NO_EXT}" "${TEST_MAP}"

  mv "${TEST_MAP}" .ber
  run_solong "No file name" ".ber"
  mv .ber "${TEST_MAP}"

  mv "${TEST_MAP}" "${MAP_NO_EXT}".berr
  run_solong "Bad file extension" "${MAP_NO_EXT}".berr
  mv "${MAP_NO_EXT}".berr "${TEST_MAP}"

  mv "${TEST_MAP}" "${MAP_NO_EXT}".bber
  run_solong "Bad file extension" "${MAP_NO_EXT}".bber
  mv "${MAP_NO_EXT}".bber "${TEST_MAP}"

  chmod -r "${TEST_MAP}"
  run_solong "No read permission" "${TEST_MAP}"
  chmod +r "${TEST_MAP}"
}

run_map_tests() {
  ${ECHO_CMD} '' >"${TEST_MAP}"
  run_solong "Map is empty" "${TEST_MAP}"

  ${ECHO_CMD} '
' >"${TEST_MAP}"
  run_solong "Map has empty line" "${TEST_MAP}"

  ${ECHO_CMD} '111111

10E0C1
1P0001
111111' >"${TEST_MAP}"
  run_solong "Map has empty line" "${TEST_MAP}"

  ${ECHO_CMD} '111111
10E0C1
1P0001
111111
' >"${TEST_MAP}"
  run_solong "Map has empty line" "${TEST_MAP}"

  ${ECHO_CMD} '1111
10E0C1
1P0001
111111' >"${TEST_MAP}"
  run_solong "Map not rectangle" "${TEST_MAP}"

  ${ECHO_CMD} '111111
10E0C1
1P01
111111' >"${TEST_MAP}"
  run_solong "Map not rectangle" "${TEST_MAP}"

  ${ECHO_CMD} '111111
10E0C1
1P0011
1111' >"${TEST_MAP}"
  run_solong "Map not rectangle" "${TEST_MAP}"

  ${ECHO_CMD} '1111E1
1000C1
1P0011
111111' >"${TEST_MAP}"
  run_solong "No closed walls" "${TEST_MAP}"

  ${ECHO_CMD} '111111
1E00C1
00010P
111111' >"${TEST_MAP}"
  run_solong "No closed walls" "${TEST_MAP}"

  ${ECHO_CMD} '111111
10E0C1
1P0111
111110' >"${TEST_MAP}"
  run_solong "No closed walls" "${TEST_MAP}"

  ${ECHO_CMD} '111111
10E001
1P0011
111111' >"${TEST_MAP}"
  run_solong "Map has no pickups" "${TEST_MAP}"

  ${ECHO_CMD} '111111
10E0C1
100011
111111' >"${TEST_MAP}"
  run_solong "Map has no player" "${TEST_MAP}"

  ${ECHO_CMD} '111111
10E0C1
1P00P1
111111' >"${TEST_MAP}"
  run_solong "Too many players" "${TEST_MAP}"

  ${ECHO_CMD} '111111
1000C1
10P001
111111' >"${TEST_MAP}"
  run_solong "Map has no exit" "${TEST_MAP}"

  ${ECHO_CMD} '111111
10E0C1
1P00E1
111111' >"${TEST_MAP}"
  run_solong "Too many exits" "${TEST_MAP}"

  ${ECHO_CMD} '111111
10E0C1
1P00K1
111111' >"${TEST_MAP}"
  run_solong "Invalid character" "${TEST_MAP}"

  ${ECHO_CMD} '111111
10E0C1
1P0001
11111G' >"${TEST_MAP}"
  run_solong "Invalid character" "${TEST_MAP}"

  ${ECHO_CMD} '1111111111111111111111111111111111
1E0010000000000C00000C000000000001
1001010100100000101001000000010101
1010010010101010001001000000010111
11P000000C00C0000000000000000010C1
1111111111111111111111111111111111' >"${TEST_MAP}"
  run_solong "No valid path" "${TEST_MAP}"

  ${ECHO_CMD} '1111111111111111111111111111111111
1000000000000000100000000000000001
1000000C000000001000000C0000000001
1000000000000000100000000000000001
1000P00000000000100000000000000E01
1111111111111111111111111111111111' >"${TEST_MAP}"
  run_solong "No valid path" "${TEST_MAP}"

  ${ECHO_CMD} '1111111111111111111111111111111111
100000000000000E000000000000000001
1000000000000000000000000000000001
1111111111111111111111111111111111
1000000000000000000000000000000001
1000000000000000000000000000C00001
1000000000000000C0000000000P000001
1111111111111111111111111111111111' >"${TEST_MAP}"
  run_solong "No valid path" "${TEST_MAP}"

  ${ECHO_CMD} '1111111111111111111111111111111111
1000010001000010000000000000000001
10E1000100011101111111111000011101
111111111110000011001C000000101001
1000P00000000000000000111000110011
1111111111111111111111111111111111' >"${TEST_MAP}"
  run_solong "No valid path" "${TEST_MAP}"
}

parse_arguments() {
  local count=31

  while [[ $# -gt 0 ]]; do
    case $1 in
    -t | --test)
      if [ -n "$2" ] && [[ $2 != -* ]]; then
        if [[ "$2" =~ ^[0-9]+$ ]] && [ "$2" -gt 0 ] && [ "$2" -le "$count" ]; then
          SELECTED_TESTS="$SELECTED_TESTS $2"
          ALL_TESTS=0
        else
          printf "${RB}Error:${RC} Invalid test number: ${YB}%s${RC}\n" "$2"
          printf "${GB}Valid:${RC} Test numbers: ${GB}1${RC} and ${GB}%s${RC}\n" "$count"
          exit 1
        fi
        shift 2
      else
        printf "${RB}Error:${RC} Argument ${YB}<TEST_ID>${RC} is missing\n"
        exit 1
      fi
      ;;
    -v | --verbose)
      VERBOSE_MESSAGE=1
      shift
      ;;
    -l | --leaks)
      TEST_LEAKS=1
      shift
      ;;
    -e | --extra)
      TEST_EXTRA=1
      shift
      ;;
    -h | --help)
      print_usage
      exit 0
      ;;
    *)
      printf "${RB}Error:${RC} Unknown option %s\n" "$1"
      print_usage
      exit 1
      ;;
    esac
  done
}

trap handle_ctrlc SIGINT

parse_arguments "$@"

if ! [ -f "$NAME" ]; then
  printf "\n${CB}INFO: ${RC}Binary ${YB}<$NAME>${RC} not found...\n"
  printf "\n${CB}INFO: ${RC}Running ${GB}Makefile${RC}...\n"
  make >/dev/null
fi

trap handle_ctrlc SIGINT

if [ -f "$NAME" ]; then
  if [ $TEST_EXTRA -eq 1 ]; then
    printf "${CB}INFO:${RC} Running extra tests...\n\n"
    run_extra_tests
  else
    check_requirements
    print_main_title
    setup_test_files
    run_logic_tests
    run_map_tests
    print_summary
    cleanup
  fi
fi
