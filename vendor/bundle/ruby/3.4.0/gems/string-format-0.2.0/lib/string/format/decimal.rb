# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

module String::Format
	# Format a numeric value as a decimal with specified precision.
	# @parameter value [Numeric] The numeric value to format.
	# @parameter precision [Integer] Number of decimal places (default: 2).
	# @returns [String] A formatted decimal string.
	def decimal(value, precision: 2)
		value.round(precision).to_s
	end
	
	module_function :decimal
end
