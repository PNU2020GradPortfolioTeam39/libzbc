#!/bin/bash
#
# SPDX-License-Identifier: BSD-2-Clause
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# This file is part of libzbc.
#
# Copyright (C) 2018, Western Digital. All rights reserved.

. scripts/zbc_test_lib.sh

zone_cond_1=IOPENL
zone_cond_2=FULL

zbc_test_init $0 "WRITE cross-zone ${zone_cond_1}->${zone_cond_2} starting above Write Pointer" $*

# Get drive information
zbc_test_get_device_info

# Get a pair of zones
zbc_test_get_wp_zone_tuple_cond_or_NA ${zone_cond_1} ${zone_cond_2}

if [[ ${target_type} == @(${ZT_DISALLOW_WRITE_XZONE}) ]]; then
    expected_sk="Illegal-request"
    expected_asc="Write-boundary-violation"   		# write cross-zone
    if [[ ${target_type} == @(${ZT_DISALLOW_WRITE_GT_WP}) ]]; then
	alt_expected_sk="Illegal-request"
	alt_expected_asc="Unaligned-write-command"	# write starting above WP
    fi
elif [[ ${target_type} == @(${ZT_DISALLOW_WRITE_GT_WP}) ]]; then
    expected_sk="Illegal-request"
    expected_asc="Unaligned-write-command"		# write starting above WP
fi

# Compute the last LBA of the first zone
target_lba=$(( ${target_slba} + ${target_size} - ${lblk_per_pblk} ))

# Start testing
# Write across the zone boundary starting above the WP of the first zone
zbc_test_run ${bin_path}/zbc_test_write_zone -v ${device} ${target_lba} $(( ${lblk_per_pblk} * 2 ))

# Check result
zbc_test_get_sk_ascq
if [[ ${target_type} != @(${ZT_DISALLOW_WRITE_GT_WP}|${ZT_DISALLOW_WRITE_XZONE}) ]]; then
    zbc_test_check_no_sk_ascq "zone_type=${target_type}"
else
    zbc_test_check_sk_ascq "zone_type=${target_type}"
fi

# Post process
rm -f ${zone_info_file}
