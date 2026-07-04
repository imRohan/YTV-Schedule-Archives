# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require_relative "utilization/version"
require_relative "utilization/schema"
require_relative "utilization/namespace"
require_relative "utilization/registry"
require_relative "utilization/observer"
require_relative "utilization/metric"

# @namespace
module Async
	# Provides high-performance utilization metrics for Async services using shared memory.
	#
	# This module provides a convenient interface for tracking utilization metrics
	# that can be synchronized to shared memory for inter-process communication.
	# Registries should be explicitly created and passed to components that need them.
	#
	# See the {file:guides/getting-started/readme.md Getting Started} guide for usage examples.
	module Utilization
	end
end
