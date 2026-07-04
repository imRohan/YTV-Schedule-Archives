# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

module String::Format
	# Convert a string to `snake_case`.
	# @parameter string [String] The string to convert.
	# @returns [String] A snake_cased string.
	def snake_case(string)
		string = string.gsub("::", "")
		string.gsub!(/(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])/, "_")
		string.downcase!
		string.sub!(/^_+/, "")
		
		return string
	end
	
	module_function :snake_case
end
