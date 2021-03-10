#! /bin/bash

# Preconditions:
#		- 'make' has already been run
# 	-	This script is executed with root privileges
# 	- memory, cpuacct, pids controllers are already mounted at
# 		/sys/fs/cgroup/memory, /sys/fs/cgroup/cpuacct, /sys/fs/cgroup/pids
# 	- Working directory is the top level directory of this project
# 	- uid and gid value of 1000 exists and does not have root privileges

CG_MEMORY="/sys/fs/cgroup/memory/sb"
CG_CPUACCT="/sys/fs/cgroup/cpuacct/sb"
CG_PIDS="/sys/fs/cgroup/pids/sb"
JAIL_PATH="jail"
EXECT_PATH="rogue.out"
IN_FILE="in.txt"
OUT_FILE="out.txt"
WHITELIST="wl.txt"
USE_UID="1000"
USE_GID="1000"

TLD=$(pwd)
INCLUDES_DIR="$TLD/includes"
SRC_DIR="$TLD/src"
INTGR_TESTS_DIR="$TLD/tests/integration_tests"

DELIM="\n================================================================\n"

mkdir $CG_MEMORY $CG_CPUACCT $CG_PIDS

pids_events=1
if [ ! -f $CG_PIDS/pids.events ]; then
	pids_events=0
fi

err_cnt=0
tot_tests=0
printf $DELIM
for d in $INTGR_TESTS_DIR/*/; do
	test_name=$(basename $d)

	if [ $pids_events -eq 0 ]; then
		if [[ $test_name == "nle"* ]]; then
			continue
		fi
	fi

	printf "\nRunning test: $test_name\n"
	cd $d

	mkdir $JAIL_PATH
	gcc --static rogue.c -o $JAIL_PATH/$EXECT_PATH
	printf "\n----------------Output of sandbox begins here-------------------\n\n"
	$TLD/bin/sandbox $(cat res_limits.txt) $CG_MEMORY $CG_CPUACCT $CG_PIDS $JAIL_PATH $EXECT_PATH $IN_FILE $OUT_FILE $WHITELIST $USE_UID $USE_GID
	ret=$?
	printf "\n----------------Output of sandbox ends here----------------------\n\n"

	printf "Checking return value of sandbox\n"
	err=0
	correct_ret=$(cat correct_ret.txt)
	if [ $ret -ne $correct_ret ]; then
		err=1
		printf "$d: error: $ret != $correct_ret\n"
	fi

	printf "Checking if output of rogue executable is as expected\n"
	diff correct_out.txt out.txt
	if [ $? -ne 0 ]; then
		err=1
		printf "$test_name: error: incorrect output\n"
	fi
	err_cnt=$((err_cnt + err))
	tot_tests=$((tot_tests + 1))

	rm jail/rogue.out out.txt
	rm -r jail
	printf $DELIM
done

rmdir $CG_MEMORY $CG_CPUACCT $CG_PIDS

if [ $err_cnt -eq 0 ]; then
	printf "All tests passed\n"
	exit 0
else
	printf "$err_cnt test(s) out of $tot_tests failed\n"
	exit 1
fi