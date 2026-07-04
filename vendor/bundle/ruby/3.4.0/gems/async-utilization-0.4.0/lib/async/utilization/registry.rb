# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "console"
require_relative "namespace"

module Async
	module Utilization
		# Registry for emitting utilization metrics.
		#
		# The registry tracks values directly and notifies a registered observer
		# when values change. The observer (like Observer) can write to its backend.
		#
		# Registries should be explicitly created and passed to components that need them.
		# In service contexts, registries are typically created via the evaluator and
		# shared across components within the same service instance.
		#
		# When an observer is added, it is immediately notified of all current values
		# so it can sync its state. When values change, the observer is notified.
		#
		# @example Create a registry and emit metrics:
		# 	registry = Async::Utilization::Registry.new
		# 	
		# 	total_requests = registry.metric(:total_requests)
		# 	total_requests.increment
		# 	
		# 	active_requests = registry.metric(:active_requests)
		# 	active_requests.track do
		# 		# Handle request - auto-decrements when block completes
		# 	end
		# 	
		# 	# Add shared memory observer when supervisor connects
		# 	# Observer will be notified of all current values automatically
		# 	schema = Async::Utilization::Schema.build(
		# 		total_requests: :u64,
		# 		active_requests: :u32
		# 	)
		# 	observer = Async::Utilization::Observer.open(schema, "/path/to/shm", 4096, 0)
		# 	registry.observer = observer
		class Registry
			# Initialize a new registry.
			def initialize
				@observer = nil
				@metrics = {}
				
				@guard = Mutex.new
			end
			
			# @attribute [Object | Nil] The registered observer.
			attr :observer
			
			# Get the current values for all metrics.
			#
			# @returns [Hash] Hash mapping field names to their current values.
			def values
				@metrics.transform_values do |metric|
					metric.value
				end
			end
			
			# Set the observer for the registry.
			#
			# When an observer is set, all cached metrics are updated so they write
			# directly to the observer's buffer. The observer must expose `schema`
			# and `buffer` attributes.
			#
			# @parameter observer [Observer | Nil] The observer to set.
			def observer=(observer)
				@guard.synchronize do
					@observer = observer
					
					# Invalidate all cached metrics with new observer (or nil)
					@metrics.each_value do |metric|
						metric.observer = observer
					end
					
					# Console.info(self, "Observer assigned", observer: observer, metric_count: @metrics.size)
				end
			end
			
			# Get a cached metric reference for a field.
			#
			# Returns a {Metric} instance that caches all details needed for fast writes.
			# Metrics are cached per field and invalidated when the observer changes.
			#
			# @parameter field [Symbol] The field name to get a metric for.
			# @returns [Metric] A metric instance for the given field.
			def metric(field)
				field = field.to_sym
				
				@guard.synchronize do
					@metrics[field] ||= Metric.for(field, @observer)
				end
			end
			
			# Get a namespace view of this registry.
			#
			# @parameter name [Symbol] The namespace name.
			# @returns [Namespace] A registry-like namespace view.
			def namespace(name)
				Namespace.new(self, name)
			end
		end
	end
end
