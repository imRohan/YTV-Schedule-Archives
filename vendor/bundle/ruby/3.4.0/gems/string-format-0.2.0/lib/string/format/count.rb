# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

module String::Format
	UNITS = [nil, "K", "M", "B", "T", "P", "E", "Z", "Y"]
	
	# Format a count into a human-readable string.
	# @parameter value [Numeric] The count to format.
	# @parameter units [Array] The units to use for formatting (default: UNITS).
	# @parameter scale [Numeric] The scaling factor between units (default: 1000).
	# @returns [String] A formatted string representing the count.
	def count(value, units = UNITS, scale: 1000)
		value = value
		index = 0
		limit = units.size - 1
		
		# Handle negative numbers by working with absolute value:
		negative = value < 0
		value = value.abs
		
		while value >= scale and index < limit
			value = value / scale.to_f
			index += 1
		end
		
		result = String.new
		result << "-" if negative
		result << value.round(2).to_s
		result << units[index].to_s if units[index]
		
		return result
	end
	
	module_function :count
end
