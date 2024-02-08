#! /bin/bash

R="\033[0;31m"	# Red
G="\033[0;32m"	# Green
Y="\033[0;33m"	# yellow
B="\033[0;34m"	# Blue
P="\033[0;35m"	# Purple
C="\033[0;36m"	# Cyan

RB="\033[1;31m"	# Bold
GB="\033[1;32m"
YB="\033[1;33m"
BB="\033[1;34m"
PB="\033[1;35m"
CB="\033[1;36m"

RC="\033[0m" 	# Reset Color
FLL="========================="
FLLTITLE="========================"

print_title() {
	printf "\n${BB}TEST $1:${RC} ${C}$2${RC}    \t"
	CNTR=$((CNTR+1))
}

print_main_title() {
	printf "\033c" #clear terminal
	printf "${P}${FLLTITLE}${FLLTITLE}${FLLTITLE}${RC}
${CB}SOLONG:  \tERROR HANDLING TESTER${RC}\n
${BB}EXITCODE:\t${RC}Tests that exitcode is not zero, indicating error\n
${BB}STDERR:  \t${RC}Tests that error message was written to stderr\n
${BB}MESSAGE: \t${RC}Tests that error message included 'Error' and
\t\twas followed by your explicit error message\n
${RB}NOTE:    \t${RC}${Y}Invalid argument count can be handled in many ways${RC}\n
TEST\tDESC\t\t\tEXITCODE\tSTDERR\t\tMESSAGE
${P}${FLLTITLE}${FLLTITLE}${FLLTITLE}${RC}"
}

message_checker() {
	MSG=$(head -1 < ${RES})
	CNT=$(wc -l < ${RES})
	CHK=0
	if [[ $MSG == *"$ERR"* ]]; then
		CHK=$((CHK+1))
	fi
	if [ $CNT -gt 1 ]; then
		CHK=$((CHK+1))
	fi
	if [ $CHK -eq 2 ]; then
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
	if [ $1 -eq 139 ]; then
		printf "${YB}[SEGV]${RC}"
	elif [ $1 -eq 0 ]; then
		printf "${RB}[KO]${RC}"
	else
		printf "${GB}[OK]${RC}"
	fi
}

run_solong() {
	${BINPATH}${NAME} ${MAP} > /dev/null 2> ${RES}
	exitcode_checker $?
	stderr_checker
	message_checker
}

CNTR=1
ERR=Error
RM="rm -rf"
ECHO="echo -n"
NAME=so_long
BINPATH=./
MAP=test_map.ber
NOEXT=test_map_no_ext
RES=.checker.tmp

if [ -f "$NAME" ]; then
	touch ${MAP}
	print_main_title
else
	printf "${RB}ERROR: ${RC}${Y}binary <$NAME> not found${RC}"
	${RM} ${MAP} ${RES}
	exit
fi

${ECHO} '111111
10E0C1
1P0001
111111' > ${MAP}

print_title ${CNTR} "Too few arguments"
${BINPATH}${NAME} > /dev/null 2> ${RES}
exitcode_checker $?
stderr_checker
message_checker

print_title ${CNTR} "Too many arguments"
${BINPATH}${NAME} ${MAP} ${MAP} > /dev/null 2> ${RES}
exitcode_checker $?
stderr_checker
message_checker

print_title ${CNTR} "Argument is folder"
${BINPATH}${NAME} libft > /dev/null 2> ${RES}
exitcode_checker $?
stderr_checker
message_checker

print_title ${CNTR} "File does not exist"
${BINPATH}${NAME} ${NOEXT} > /dev/null 2> ${RES}
exitcode_checker $?
stderr_checker
message_checker

print_title ${CNTR} "No file extension"
mv ${MAP} ${NOEXT}
${BINPATH}${NAME} ${NOEXT} > /dev/null 2> ${RES}
exitcode_checker $?
stderr_checker
message_checker
mv ${NOEXT} ${MAP}

print_title ${CNTR} "Bad file extension"
mv ${MAP} ${NOEXT}.berr
${BINPATH}${NAME} ${NOEXT}.berr > /dev/null 2> ${RES}
exitcode_checker $?
stderr_checker
message_checker
mv ${NOEXT}.berr ${MAP}

print_title ${CNTR} "Bad file extension"
mv ${MAP} ${NOEXT}.bber
${BINPATH}${NAME} ${NOEXT}.bber > /dev/null 2> ${RES}
exitcode_checker $?
stderr_checker
message_checker
mv ${NOEXT}.bber ${MAP}

chmod -r ${MAP}
print_title ${CNTR} "No read permission"
run_solong
chmod +r ${MAP}

print_title ${CNTR} "Map is empty"
${ECHO} '' > ${MAP}
run_solong


print_title ${CNTR} "Map has empty line"
${ECHO} '
' > ${MAP}
run_solong

print_title ${CNTR} "Map has empty line"
${ECHO} '111111

10E0C1
1P0001
111111' > ${MAP}
run_solong

print_title ${CNTR} "Map has empty line"
${ECHO} '111111
10E0C1
1P0001
111111
' > ${MAP}
run_solong

print_title ${CNTR} "Map not rectangle"
${ECHO} '1111
10E0C1
1P0001
111111' > ${MAP}
run_solong

print_title ${CNTR} "Map not rectangle"
${ECHO} '111111
10E0C1
1P01
111111' > ${MAP}
run_solong

print_title ${CNTR} "Map not rectangle"
${ECHO} '111111
10E0C1
1P0011
1111' > ${MAP}
run_solong

print_title ${CNTR} "No closed walls"
${ECHO} '1111E1
1000C1
1P0011
111111' > ${MAP}
run_solong

print_title ${CNTR} "No closed walls"
${ECHO} '111111
1E00C1
00010P
111111' > ${MAP}
run_solong

print_title ${CNTR} "No closed walls"
${ECHO} '111111
10E0C1
1P0111
111110' > ${MAP}
run_solong

print_title ${CNTR} "Map has no pickups"
${ECHO} '111111
10E001
1P0011
111111' > ${MAP}
run_solong

print_title ${CNTR} "Map has no player"
${ECHO} '111111
10E0C1
100011
111111' > ${MAP}
run_solong

print_title ${CNTR} "Too many players"
${ECHO} '111111
10E0C1
1P00P1
111111' > ${MAP}
run_solong

print_title ${CNTR} "Map has no exit"
${ECHO} '111111
1000C1
10P001
111111' > ${MAP}
run_solong

print_title ${CNTR} "Too many exits"
${ECHO} '111111
10E0C1
1P00E1
111111' > ${MAP}
run_solong

print_title ${CNTR} "Invalid character"
${ECHO} '111111
10E0C1
1P00K1
111111' > ${MAP}
run_solong

print_title ${CNTR} "Invalid character"
${ECHO} '111111
10E0C1
1P0001
11111G' > ${MAP}
run_solong

print_title ${CNTR} "No valid path"
${ECHO} '1111111111111111111111111111111111
1E0010000000000C00000C000000000001
1001010100100000101001000000010101
1010010010101010001001000000010111
11P000000C00C0000000000000000010C1
1111111111111111111111111111111111' > ${MAP}
run_solong

print_title ${CNTR} "No valid path"
${ECHO} '1111111111111111111111111111111111
1000000000000000100000000000000001
1000000C000000001000000C0000000001
1000000000000000100000000000000001
1000P00000000000100000000000000E01
1111111111111111111111111111111111' > ${MAP}
run_solong

print_title ${CNTR} "No valid path"
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
1111111111111111111111111111111111' > ${MAP}
run_solong

print_title ${CNTR} "No valid path"
${ECHO} '1111111111111111111111111111111111
1000010001000000000000000000000001
10E1000100011101111111111000011101
11111111111000001100100000001C1001
1000P00000000000000000111000110011
1111111111111111111111111111111111' > ${MAP}
run_solong

print_title ${CNTR} "No valid path"
${ECHO} '1111111111111111111111111111111111
1000P000000000000E0000C00000000011
1111111111111111111111111111111111' > ${MAP}
run_solong

${RM} ${MAP} ${RES}
printf "\n${P}${FLLTITLE}${FLLTITLE}${FLLTITLE}${RC}"
printf "${GB}\nALL TESTS FINISHED!\n\n${RC}"
