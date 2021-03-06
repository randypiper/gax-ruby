# Copyright 2019, Google LLC
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the
# distribution.
#     * Neither the name of Google LLC nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# 'AS IS' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require "grpc"
require "grpc/google_rpc_status_utils"
require "google/gax/errors"
require "google/protobuf/well_known_types"
# Required in order to deserialize common error detail proto types
require "google/rpc/error_details_pb"

module Google
  module Gax
    class GaxError < StandardError
      def status_details
        return nil.to_a unless cause.is_a? GRPC::BadStatus

        # TODO: The begin and rescue can be removed once BadStatus#to_rpc_status is released.
        begin
          rpc_status = GRPC::GoogleRpcStatusUtils.extract_google_rpc_status cause.to_status
        rescue Google::Protobuf::ParseError
          rpc_status = nil
        end

        return nil.to_a if rpc_status.nil?

        rpc_status.details.map do |detail|
          begin
            detail_type = Google::Protobuf::DescriptorPool.generated_pool.lookup detail.type_name
            detail = detail.unpack detail_type.msgclass if detail_type
            detail
          rescue Google::Protobuf::ParseError
            detail
          end
        end
      end
    end
  end
end
