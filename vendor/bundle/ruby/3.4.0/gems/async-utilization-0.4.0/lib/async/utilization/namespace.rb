# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

module Async
	module Utilization
		# A registry-like view that prefixes metric names.
		#
		# Namespaces let components use generic metric names while applications decide
		# how those names are composed in the shared registry.
		class Namespace
			# Initialize a new namespace.
			#
			# @parameter registry [Registry] The underlying registry.
			# @parameter name [Symbol] The namespace name.
			def initialize(registry, name)
				@registry = registry
				@name = name.to_sym
			end
			
			# @attribute [Registry] The underlying registry.
			attr :registry
			
			# @attribute [Symbol] The namespace name.
			attr :name
			
			# Get a metric in this namespace.
			#
			# @parameter name [Symbol] The metric name.
			# @returns [Metric] A metric instance for the namespaced field.
			def metric(name)
				@registry.metric(metric_name(name))
			end
			
			# Get a nested namespace.
			#
			# @parameter name [Symbol] The nested namespace name.
			# @returns [Namespace] A namespace view with the composed name.
			def namespace(name)
				self.class.new(@registry, metric_name(name))
			end
			
			private
			
			def metric_name(name)
				:"#{@name}_#{name}"
			end
		end
	end
end
