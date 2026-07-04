# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

module Async
	module Utilization
		# A cached metric reference that avoids hash lookups on the fast path.
		#
		# This class caches all the details needed to write directly to shared memory,
		# including the buffer, offset, and type. When the observer changes, the cache
		# is invalidated and rebuilt on the next access.
		class Metric
			# Create a new metric for the given field and observer.
			#
			# @parameter field [Symbol] The field name for this metric.
			# @parameter observer [Observer | Nil] The observer to associate with this metric.
			# @returns [Metric] A new metric instance.
			def self.for(field, observer)
				self.new(field).tap do |metric|
					metric.observer = observer
				end
			end
			
			# Initialize a new metric.
			#
			# @parameter name [Symbol] The field name for this metric.
			def initialize(name)
				@name = name.to_sym
				@value = 0
				
				@observer = nil
				@cached_field = nil
				@cached_buffer = nil
				@guard = Mutex.new
			end
			
			# @attribute [Symbol] The field name for this metric.
			attr :name
			
			# Get the current in-memory metric value.
			#
			# @returns [Numeric] The last value written to this metric.
			def value
				@guard.synchronize do
					@value
				end
			end
			
			# Set the observer and rebuild cache.
			#
			# This is called when the registry assigns a new observer (or removes it).
			# The cache is invalidated and then immediately recomputed so that the
			# fast write path doesn't need to re-check the observer on the first write.
			#
			# @parameter observer [Observer | Nil] The new observer (or nil).
			def observer=(observer)
				@guard.synchronize do
					@observer = observer
					
					if @observer
						if field = @observer.schema[@name]
							if buffer = @observer.buffer
								@cached_field = field
								@cached_buffer = buffer
								
								return write_direct(@value)
							end
						end
					end
					
					@cached_field = nil
					@cached_buffer = nil
				end
			end
			
			# Increment the metric value.
			#
			# @returns [Integer] The new value of the field.
			def increment
				@guard.synchronize do
					@value += 1
					write_direct(@value)
				end
				
				@value
			end
			
			# Track an operation: increment before the block, decrement after it completes.
			#
			# Returns the block's return value. Use for active/count metrics that should
			# reflect the number of operations currently in progress.
			#
			# @yield The operation to track.
			# @returns [Object] The block's return value.
			def track(&block)
				raise ArgumentError, "block required" unless block_given?
				
				increment
				begin
					yield
				ensure
					decrement
				end
			end
			
			# Decrement the metric value.
			#
			# Uses the fast path (direct buffer write) when cache is valid and observer is available.
			#
			# @returns [Integer] The new value of the field.
			def decrement
				@guard.synchronize do
					@value -= 1
					write_direct(@value)
				end
				
				@value
			end
			
			# Set the metric value.
			#
			# Uses the fast path (direct buffer write) when cache is valid and observer is available.
			#
			# @parameter value [Numeric] The value to set.
			def set(value)
				@guard.synchronize do
					@value = value
					write_direct(@value)
				end
			end
			
			protected
			
			# Write directly to the cached buffer if available.
			#
			# This is the fast path that avoids hash lookups. Always ensures cache is valid
			# first. If there's no observer or buffer, silently does nothing.
			#
			# @parameter value [Numeric] The value to write.
			# @returns [Boolean] Whether the write succeeded.
			def write_direct(value)
				if @cached_buffer
					@cached_buffer.set_value(@cached_field.type, @cached_field.offset, value)
				end
				
				return true
			rescue => error
				Console.warn(self, "Failed to write metric value!", metric: {name: @name, value: value}, exception: error)
				
				return false
			end
		end
	end
end
