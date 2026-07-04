# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

module String::Format
	# Format a ratio as "current/total" with human-readable counts.
	# @parameter current [Numeric] The current value.
	# @parameter total [Numeric] The total value.
	# @returns [String] A formatted ratio string.
	def ratio(current, total)
		"#{count(current)}/#{count(total)}"
	end
	
	module_function :ratio
end
