#!/bin/bash

test_makefile_rules() {
  local title="Makefile"

  make all > /dev/null || {
    printf "${YB}$title:${RC} ${RB}KO${RC} - Could not run make all\n"
    return
  }

  ls "${NAME}" &> /dev/null || {
    printf "${YB}$title:${RC} ${RB}KO${RC} - Executable not found after make all\n"
    return
  }

  make clean > /dev/null || {
    printf "${YB}$title:${RC} ${RB}KO${RC} - Could not run make clean\n"
    return
  }

  ls "${NAME}" &> /dev/null || {
    printf "${YB}$title:${RC} ${RB}KO${RC} - Executable not found after make clean\n"
    return
  }

  make fclean > /dev/null || {
    printf "${YB}$title:${RC} ${RB}KO${RC} - Could not run make make fclean\n"
    return
  }

  ls "${NAME}" &> /dev/null && {
    printf "${YB}$title:${RC} ${RB}KO${RC} - Executable found after make fclean\n"
    return
  }

  make re > /dev/null || {
    printf "${YB}$title:${RC} ${RB}KO${RC} - Could not run make re\n"
    return
  }

  ls "${NAME}" &> /dev/null || {
    printf "${YB}$title:${RC} ${RB}KO${RC} - Executable not found after make re\n"
    return
  }

  if [ "$(check_bonus_rule)" -eq 0 ]; then
    make bonus > /dev/null || {
      printf "${YB}Bonus rule:${RC} ${RB}KO${RC} - Could not run make bonus\n"
      return
    }
  fi

  printf "${BB}$title:${RC} ${GB}OK${RC}\n"
}

test_norminette_check() {
  local title="Norminette"

  if ! command -v norminette > /dev/null 2>&1; then
    printf "${BB}$title:${RC} ${Y}Skipped${RC} - 'norminette' not available\n"
    return
  fi

  norminette &> /dev/null
  if [ $? -eq 0 ]; then
    printf "${BB}$title:${RC} ${GB}OK${RC}\n"
  else
    printf "${YB}$title:${RC} ${RB}KO${RC}\n"
  fi
}

run_extra_tests() {
  test_norminette_check
  test_makefile_rules
}
