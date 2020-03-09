#!/bin/bash
#
# SPDX-License-Identifier: BSD-2-Clause
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# This file is part of libzbc.
#
# Copyright (C) 2009-2014, HGST, Inc. All rights reserved.
# Copyright (C) 2016, Western Digital. All rights reserved.

. scripts/zbc_test_lib.sh

zbc_test_init $0 "WRITE sequential zone boundary violation" $*

# Set expected error code
expected_sk="Illegal-request"
expected_asc="Write-boundary-violation"

# Get drive information
zbc_test_get_device_info

if [ ${device_model} = "Host-aware" ]; then
    zone_type="0x3"
else
    zone_type="0x2"
fi

# Get zone information
zbc_test_get_zone_info

# Search target LBA
zbc_test_get_target_zone_from_type_and_cond ${zone_type} "${ZC_EMPTY}"

# Start testing
nio=$(( (target_size / lblk_per_pblk) - 1))
zbc_test_run ${bin_path}/zbc_test_write_zone -v -n ${nio} ${device} ${target_slba} ${lblk_per_pblk}
if [ $? -eq 0 ]; then
    target_lba=$(( target_slba + nio * lblk_per_pblk ))
    zbc_test_run ${bin_path}/zbc_test_write_zone -v ${device} ${target_lba} $((lblk_per_pblk * 2))
fi

# Check result
zbc_test_get_sk_ascq

if [ ${device_model} = "Host-aware" ]; then
    zbc_test_check_no_sk_ascq
else
    zbc_test_check_sk_ascq
fi

# Post process
rm -f ${zone_info_file}

