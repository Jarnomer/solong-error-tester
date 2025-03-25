#!/bin/bash

test_makefile_rules() {
  local title="Makefile"

  make all >/dev/null || {
    printf "${YB}$title:${RC} ${RB}KO${RC} - Could not run make all\n"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return
  }

  ls "${NAME}" &>/dev/null || {
    printf "${YB}$title:${RC} ${RB}KO${RC} - Executable not found after make all\n"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return
  }

  make clean >/dev/null || {
    printf "${YB}$title:${RC} ${RB}KO${RC} - Could not run make clean\n"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return
  }

  ls "${NAME}" &>/dev/null || {
    printf "${YB}$title:${RC} ${RB}KO${RC} - Executable not found after make clean\n"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return
  }

  make fclean >/dev/null || {
    printf "${YB}$title:${RC} ${RB}KO${RC} - Could not run make make fclean\n"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return
  }

  ls "${NAME}" &>/dev/null && {
    printf "${YB}$title:${RC} ${RB}KO${RC} - Executable found after make fclean\n"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return
  }

  make re >/dev/null || {
    printf "${YB}$title:${RC} ${RB}KO${RC} - Could not run make re\n"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return
  }

  ls "${NAME}" &>/dev/null || {
    printf "${YB}$title:${RC} ${RB}KO${RC} - Executable not found after make re\n"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return
  }

  if [ "$(check_bonus_rule)" -eq 0 ]; then
    make bonus >/dev/null || {
      printf "${YB}Bonus rule:${RC} ${RB}KO${RC} - Could not run make bonus\n"
      TESTS_FAILED=$((TESTS_FAILED + 1))
      return
    }
  fi

  printf "${BB}$title:${RC} ${GB}OK${RC}\n"
  TESTS_PASSED=$((TESTS_PASSED + 1))
}

test_norminette_check() {
  local title="Norminette"

  if ! command -v norminette >/dev/null 2>&1; then
    printf "${BB}$title:${RC} ${Y}Skipped${RC} - 'norminette' not available\n"
    return
  fi

  sources=$(find . -type f \( -name "*.c" -o -name "*.h" \) | grep -v "mlx")
  norminette "$sources" &>/dev/null

  if [ $? -eq 0 ]; then
    printf "${BB}$title:${RC} ${GB}OK${RC}\n"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    printf "${YB}$title:${RC} ${RB}KO${RC}\n"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

run_extra_tests() {
  test_norminette_check
  test_makefile_rules
  cleanup
}
