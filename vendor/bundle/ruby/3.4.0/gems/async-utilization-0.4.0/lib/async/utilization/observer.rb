# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require_relative "schema"

module Async
	module Utilization
		# Shared memory observer for utilization metrics.
		#
		# Writes metrics to shared memory using a schema to define the
		# serialization layout. The schema is required to know how to
		# serialize values efficiently.
		class Observer
			# Open a shared memory observer from a file.
			#
			# Maps the shared memory file and creates an Observer instance.
			# The file descriptor is closed after mapping - the memory mapping
			# persists independently on Unix/Linux systems.
			#
			# Note: mmap requires page-aligned offsets and sizes. This method handles
			# non-page-aligned offsets by mapping from the nearest page boundary
			# and adjusting field offsets accordingly.
			#
			# @parameter schema [Schema] The schema defining field types and layout.
			# @parameter path [String] Path to the shared memory file.
			# @parameter size [Integer] Size of the shared memory region to map.
			# @parameter offset [Integer] Offset into the shared memory buffer.
			# @returns [Observer] A new Observer instance.
			def self.open(schema, path, size, offset)
				page_size = IO::Buffer::PAGE_SIZE
				
				# Round offset down to nearest page boundary:
				page_aligned_offset = (offset / page_size) * page_size
				offset_adjustment = offset - page_aligned_offset
				
				# Calculate how many pages we need to cover the segment:
				segment_end = offset + size
				page_aligned_end = ((segment_end + page_size - 1) / page_size) * page_size
				
				# Ensure we map at least one full page:
				map_size = [page_aligned_end - page_aligned_offset, page_size].max
				
				buffer = File.open(path, "r+b") do |file|
					mapped_buffer = IO::Buffer.map(file, map_size, page_aligned_offset)
					
					# If we had to adjust the offset, create a view into the buffer:
					if offset_adjustment > 0 || map_size > size
						mapped_buffer.slice(offset_adjustment, size)
					else
						mapped_buffer
					end
				end
				
				new(schema, buffer)
			end
			
			# Initialize a new shared memory observer.
			#
			# @parameter schema [Schema] The schema defining field types and layout.
			# @parameter buffer [IO::Buffer] The mapped buffer for shared memory.
			def initialize(schema, buffer)
				@schema = schema
				@buffer = buffer
			end
			
			# @attribute [Schema] The schema used for serialization.
			attr :schema
			
			# @attribute [IO::Buffer] The mapped buffer for shared memory.
			attr :buffer
		end
	end
end
