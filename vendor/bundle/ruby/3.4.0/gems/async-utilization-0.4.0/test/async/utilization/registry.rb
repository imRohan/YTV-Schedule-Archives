# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "sus"
require "async/utilization"

describe Async::Utilization::Registry do
	let(:registry) {Async::Utilization::Registry.new}
	let(:test_field_metric) {registry.metric(:test_field)}
	
	it "can increment a value" do
		value = test_field_metric.increment
		expect(value).to be == 1
		expect(registry.values[:test_field]).to be == 1
	end
	
	it "can increment multiple times" do
		test_field_metric.increment
		test_field_metric.increment
		test_field_metric.increment
		
		expect(registry.values[:test_field]).to be == 3
	end
	
	it "can decrement a value" do
		test_field_metric.increment
		test_field_metric.increment
		
		value = test_field_metric.decrement
		expect(value).to be == 1
		expect(registry.values[:test_field]).to be == 1
	end
	
	it "can set a value directly" do
		test_field_metric.set(42)
		expect(registry.values[:test_field]).to be == 42
	end
	
	it "can track an operation with auto-decrement" do
		test_field_metric.track do
			expect(registry.values[:test_field]).to be == 1
		end
		
		expect(registry.values[:test_field]).to be == 0
	end
	
	it "decrements even if track block raises an error" do
		begin
			test_field_metric.track do
				raise "Error!"
			end
		rescue
		end
		
		expect(registry.values[:test_field]).to be == 0
	end
	
	it "notifies observer when values change" do
		schema = Async::Utilization::Schema.build(test_field: :u64)
		buffer = IO::Buffer.new(8)
		
		observer = Object.new
		observer.define_singleton_method(:schema){schema}
		observer.define_singleton_method(:buffer){buffer}
		
		test_field_metric.set(5)
		registry.observer = observer
		
		# Buffer should be synced with the existing value on observer assignment
		expect(buffer.get_value(:u64, 0)).to be == 5
		
		test_field_metric.increment
		
		# Buffer should reflect the incremented value
		expect(buffer.get_value(:u64, 0)).to be == 6
	end
	
	it "uses metric method for fast path" do
		registry.metric(:module_test).increment
		registry.metric(:module_test).increment
		
		expect(registry.values).to have_keys(module_test: be == 2)
	end
	
	it "can create a namespace" do
		namespace = registry.namespace(:socket_accept)
		
		expect(namespace).to be_a(Async::Utilization::Namespace)
		expect(namespace.registry).to be == registry
		expect(namespace.name).to be == :socket_accept
	end
	
	it "can use metric for decrement" do
		registry.metric(:module_decrement_test).increment
		registry.metric(:module_decrement_test).increment
		registry.metric(:module_decrement_test).decrement
		
		expect(registry.values).to have_keys(module_decrement_test: be == 1)
	end
	
	it "can use metric for set" do
		registry.metric(:module_set_test).set(99)
		
		expect(registry.values).to have_keys(module_set_test: be == 99)
	end
	
	it "wires up existing metrics when observer is assigned" do
		schema = Async::Utilization::Schema.build(test_field: :u64)
		buffer = IO::Buffer.new(8)
		observer = Object.new
		observer.define_singleton_method(:schema){schema}
		observer.define_singleton_method(:buffer){buffer}
		
		test_field_metric.set(7)
		registry.observer = observer
		
		expect(buffer.get_value(:u64, 0)).to be == 7
	end
	
	it "stops writing to buffer when observer is removed" do
		schema = Async::Utilization::Schema.build(test_field: :u64)
		buffer = IO::Buffer.new(8)
		observer = Object.new
		observer.define_singleton_method(:schema){schema}
		observer.define_singleton_method(:buffer){buffer}
		
		registry.observer = observer
		test_field_metric.set(5)
		expect(buffer.get_value(:u64, 0)).to be == 5
		
		registry.observer = nil
		test_field_metric.set(99)
		
		# Buffer unchanged, in-memory value updated
		expect(buffer.get_value(:u64, 0)).to be == 5
		expect(registry.values[:test_field]).to be == 99
	end
end
