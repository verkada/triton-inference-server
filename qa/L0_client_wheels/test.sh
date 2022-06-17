#!/bin/bash
# Copyright 2022, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#  * Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#  * Neither the name of NVIDIA CORPORATION nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
# OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# This test validates installation of latest tritonclient on test.pypi.org

# Should be updated whenever the latest wheel version of tritonclient is
# updated in test.pypi.org.
EXPECTED_WHLVERSION="2.22.4"

apt update
apt install -y python3 python3-pip

pip install --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple tritonclient[all]

RET=0

# Check wheel version
matches=`pip list --format freeze | grep "tritonclient==${EXPECTED_WHLVERSION}" | wc -l`
if [ $matches -ne 1 ]; then
    echo -e "Expected wheel \"tritonclient==${EXPECTED_WHLVERSION}\" not found"
    RET=1
fi

set +e

# Check wheel installation
python3 -c """import tritonclient; import tritonclient.grpc; import tritonclient.http; \
          import tritonclient.utils; import tritonclient.grpc.model_config_pb2; \
          import tritonclient.grpc.service_pb2; import tritonclient.grpc.service_pb2_grpc; \
          import tritonclient.utils.shared_memory"""
RET=$(($RET+$?))

set -e

EXECUTABLES="perf_analyzer perf_client"
for l in $EXECUTABLES; do
  if [ $(which -a $l | grep "/usr/local/bin/$l" | wc -l) -ne 1 ]; then
    which -a $l
    echo -e "*** $l executable not installed by tritonclient wheel\n"
    RET=1
  fi
done

if [ $RET -eq 0 ]; then
    echo -e "\n***\n*** Test Passed\n***"
else
    cat $TEST_LOG
    echo -e "\n***\n*** Test FAILED\n***"
fi

exit $RET
