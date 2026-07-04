# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

module String::Format
	# Convert a string to title case.
	# @parameter string [String] The string to convert.
	# @returns [String] A title-cased string.
	def title_case(string)
		string = string.gsub(/(^|[ \-_])(.)/){" " + $2.upcase}
		string.strip!
		
		return string
	end
	
	module_function :title_case
end
