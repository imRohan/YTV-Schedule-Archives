# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "sus"
require "async/utilization"

describe Async::Utilization::Namespace do
	let(:registry) {Async::Utilization::Registry.new}
	let(:namespace) {registry.namespace(:socket_accept)}
	
	it "uses namespaced metric names" do
		metric = namespace.metric(:acquired_count)
		
		expect(metric).to be_a(Async::Utilization::Metric)
		expect(metric.name).to be == :socket_accept_acquired_count
		
		metric.set(2)
		expect(registry.values).to have_keys(socket_accept_acquired_count: be == 2)
	end
	
	it "returns the same metric instance for the same namespaced field" do
		metric1 = namespace.metric(:waiting_count)
		metric2 = namespace.metric(:waiting_count)
		
		expect(metric1).to be == metric2
	end
	
	it "supports nested namespaces" do
		metric = namespace.namespace(:long_task).metric(:waiting_count)
		
		expect(metric.name).to be == :socket_accept_long_task_waiting_count
		
		metric.increment
		expect(registry.values).to have_keys(socket_accept_long_task_waiting_count: be == 1)
	end
	
	it "writes namespaced metrics to an observer" do
		schema = Async::Utilization::Schema.build(socket_accept_acquired_count: :u64)
		buffer = IO::Buffer.new(8)
		
		observer = Object.new
		observer.define_singleton_method(:schema){schema}
		observer.define_singleton_method(:buffer){buffer}
		
		registry.observer = observer
		
		namespace.metric(:acquired_count).set(5)
		
		expect(buffer.get_value(:u64, 0)).to be == 5
	end
end
