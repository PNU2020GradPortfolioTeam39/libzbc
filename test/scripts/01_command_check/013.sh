#!/bin/bash

. ../zbc_test_common_functions.sh

if [ $# -ne 2 -a $# -ne 3 ]; then
  echo "[usage] $0 <target_device> <test_bin_path> [test_log_path]"
  echo "    target_device          : device file. e.g. /dev/sg3"
  echo "    test_bin_path          : binary directory"
  echo "    test_log_path          : [option] output log directory."
  echo "                                      If this option isn't specified, use current directory."
  exit 1
fi

# Store argument
device=${1}
bin_path=${2}

if [ $# -eq 3 ]; then
    log_path=${3}
else
    log_path=`pwd`
fi

# Extract testname
testbase=${0##*/}
testname=${testbase%.*}

# Set file names
log_file="${log_path}/${testname}.log"
zone_info_file="/tmp/{testname}_zone_info.log"

# Delete old log file
rm -f ${log_file}
rm -f ${zone_info_file}

# Set expected error code
expected_sk="Aborted-command"
expected_asc="Insufficient-zone-resources"

# Test print
echo "[TEST][${testname}][SWRZ][WRITE_ZONE][INSUFFICIENT_ZONE_RESOURCES],start"

# Get drive information
zbc_test_get_drive_info

# Get zone information
zbc_test_get_zone_info

# Open zones
zbc_test_open_nr_zones ${max_open}

# Get zone information
zbc_test_get_zone_info

# Search target LBA
zbc_test_search_vals_from_zone_type_and_cond "0x2" "0x1"
target_lba=${target_slba}

# Start testing
sudo ${bin_path}/zbc_test_open_zone -v ${device} ${target_lba} >> ${log_file} 2>&1

# Check result
zbc_test_get_sk_ascq
zbc_test_check_sk_ascq

# Post process
sudo ${bin_path}/zbc_test_reset_write_ptr ${device} -1

rm -f ${zone_info_file}

