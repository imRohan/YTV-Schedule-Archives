# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

module Async
	module Utilization
		# Defines a schema for shared memory serialization.
		#
		# The schema defines the layout and types for serializing utilization
		# metrics to shared memory. It's only needed when using Observer for
		# shared memory storage - the Registry itself doesn't require a schema.
		#
		# @example Assign a schema to an observer:
		# 	schema = Async::Utilization::Schema.build(
		# 		total_requests: :u64,
		# 		active_requests: :u32,
		# 	)
		# 	
		# 	registry = Async::Utilization::Registry.new
		# 	observer = Async::Utilization::Observer.open(schema, "/path/to/shm", 4096, 0)
		# 	registry.observer = observer
		class Schema
			# Represents a field in the schema with its name, type, and offset.
			Field = Data.define(:name, :type, :offset)
			
			# Build a schema from raw fields.
			#
			# Factory method that takes a hash of field names to types and creates
			# Field instances with calculated offsets.
			#
			# @parameter fields [Hash] Hash mapping field names to IO::Buffer type symbols (:u32, :u64, :i32, :i64, :f32, :f64).
			# @returns [Schema] A new schema instance.
			def self.build(fields)
				field_instances = []
				offset = 0
				
				fields.each do |key, type|
					field_instances << Field.new(name: key.to_sym, type: type, offset: offset)
					offset += IO::Buffer.size_of(type)
				end
				
				new(field_instances)
			end
			
			# Initialize a new schema.
			#
			# @parameter fields [Array<Field>] Array of Field instances.
			def initialize(fields)
				@fields = fields.freeze
				
				# Build an offsets cache mapping field names to Field objects for fast lookup
				@offsets = {}
				@fields.each do |field|
					@offsets[field.name] = field
				end
				@offsets.freeze
			end
			
			# @attribute [Array<Field>] The fields in this schema.
			attr :fields
			
			# Get field information for a given field.
			#
			# @parameter field [Symbol] The field name to look up.
			# @returns [Field] Field object containing name, type and offset, or nil if field not found.
			def [](field)
				@offsets[field.to_sym]
			end
			
			# Convert schema to array format for shared memory.
			#
			# @returns [Array] Array of [key, type, offset] tuples.
			def to_a
				@fields.map do |field|
					[field.name, field.type, field.offset]
				end
			end
		end
	end
end
