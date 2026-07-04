# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "sus"
require "sus/fixtures/console/captured_logger"
require "sus/fixtures/temporary_directory_context"
require "async/utilization"

describe Async::Utilization::Metric do
	include Sus::Fixtures::Console::CapturedLogger
	include Sus::Fixtures::TemporaryDirectoryContext
	
	let(:shm_path) {File.join(root, "test.shm")}
	let(:schema) do
		Async::Utilization::Schema.build(
			total_requests: :u64,
			active_requests: :u32
		)
	end
	
	let(:page_size) {IO::Buffer::PAGE_SIZE}
	let(:segment_size) {512}
	let(:file_size) {[segment_size, page_size].max}
	let(:offset) {0}
	
	let(:observer) do
		Async::Utilization::Observer.open(schema, shm_path, segment_size, offset)
	end
	
	let(:registry) {Async::Utilization::Registry.new}
	
	before do
		File.open(shm_path, "w+b") do |file|
			file.truncate(file_size)
		end
	end
	
	it "can create a metric from a field name" do
		metric = registry.metric(:total_requests)
		
		expect(metric).to be_a(Async::Utilization::Metric)
		expect(metric.name).to be == :total_requests
	end
	
	it "can increment a metric" do
		registry.observer = observer
		metric = registry.metric(:total_requests)
		
		value = metric.increment
		expect(value).to be == 1
		expect(metric.value).to be == 1
		
		value = metric.increment
		expect(value).to be == 2
		expect(metric.value).to be == 2
	end
	
	it "can decrement a metric" do
		registry.observer = observer
		metric = registry.metric(:total_requests)
		
		metric.increment
		metric.increment
		
		value = metric.decrement
		expect(value).to be == 1
		expect(metric.value).to be == 1
	end
	
	it "can set a metric value" do
		registry.observer = observer
		metric = registry.metric(:total_requests)
		
		metric.set(42)
		expect(metric.value).to be == 42
		
		metric.set(100)
		expect(metric.value).to be == 100
	end
	
	it "can track an operation with auto-decrement" do
		registry.observer = observer
		metric = registry.metric(:active_requests)
		
		metric.track do
			expect(metric.value).to be == 1
		end
		
		expect(metric.value).to be == 0
	end
	
	it "returns the metric value when increment is called" do
		registry.observer = observer
		metric = registry.metric(:total_requests)
		
		result = metric.increment
		expect(result).to be == 1
		expect(result).to be == metric.value
		
		result = metric.increment
		expect(result).to be == 2
		expect(result).to be == metric.value
	end
	
	it "returns the block's return value when track is called" do
		registry.observer = observer
		metric = registry.metric(:active_requests)
		
		# Block returns a string
		result = metric.track do
			"connection_object"
		end
		expect(result).to be == "connection_object"
		expect(metric.value).to be == 0 # Should be decremented after block
		
		# Block returns an integer
		result = metric.track do
			42
		end
		expect(result).to be == 42
		expect(metric.value).to be == 0 # Should be decremented after block
		
		# Block returns nil
		result = metric.track do
			nil
		end
		expect(result).to be == nil
		expect(metric.value).to be == 0 # Should be decremented after block
	end
	
	it "decrements even if track block raises an error" do
		registry.observer = observer
		metric = registry.metric(:active_requests)
		
		begin
			metric.track do
				raise "Test error"
			end
		rescue => error
			expect(error.message).to be == "Test error"
		end
		
		expect(metric.value).to be == 0
	end
	
	it "raises ArgumentError when track is called without a block" do
		metric = registry.metric(:active_requests)
		
		expect do
			metric.track
		end.to raise_exception(ArgumentError, message: be == "block required")
	end
	
	it "writes directly to shared memory when observer is set" do
		metric = registry.metric(:total_requests)
		registry.observer = observer
		
		metric.set(42)
		
		# Read back from file to verify
		buffer = IO::Buffer.map(File.open(shm_path, "r+b"), file_size, 0)
		expect(buffer.get_value(:u64, 0)).to be == 42
	end
	
	it "invalidates cache when observer changes" do
		registry.observer = observer
		metric = registry.metric(:total_requests)
		
		# Set a value - cache should be built
		metric.set(10)
		expect(metric.value).to be == 10
		
		# Create a new observer with different schema
		new_schema = Async::Utilization::Schema.build(
			total_requests: :u64,
			active_requests: :u32
		)
		new_shm_path = File.join(root, "test2.shm")
		File.open(new_shm_path, "w+b"){|f| f.truncate(file_size)}
		new_observer = Async::Utilization::Observer.open(new_schema, new_shm_path, segment_size, 0)
		
		# Change observer - cache should be invalidated
		registry.observer = new_observer
		
		# Set a new value - cache should be rebuilt
		metric.set(20)
		expect(metric.value).to be == 20
		
		# Verify it was written to the new shared memory file
		buffer = IO::Buffer.map(File.open(new_shm_path, "r+b"), file_size, 0)
		expect(buffer.get_value(:u64, 0)).to be == 20
	end
	
	it "works without an observer" do
		metric = registry.metric(:total_requests)
		
		# Should work fine without observer (uses fallback path)
		metric.increment
		expect(metric.value).to be == 1
		
		metric.set(5)
		expect(metric.value).to be == 5
		
		# Set observer and verify it works with fast path
		registry.observer = observer
		metric.set(10)
		expect(metric.value).to be == 10
	end
	
	it "returns the same metric instance for the same field" do
		metric1 = registry.metric(:total_requests)
		metric2 = registry.metric(:total_requests)
		
		expect(metric1).to be == metric2
	end
	
	it "handles write errors gracefully" do
		registry.observer = observer
		metric = registry.metric(:total_requests)
		
		# Set a value first to build the cache
		metric.set(10)
		
		# Create an invalid buffer that will raise an error
		invalid_buffer = Object.new
		def invalid_buffer.set_value(type, offset, value)
			raise IOError, "Buffer error"
		end
		
		metric.instance_variable_set(:@cached_buffer, invalid_buffer)
		
		# Should not raise, but log warning
		metric.set(42)
		expect(metric.value).to be == 42
		
		# Assert that a warning was logged
		expect_console.to have_logged(
			severity: be == :warn,
			subject: be_a(Async::Utilization::Metric),
			message: be == "Failed to write metric value!"
		)
	end
	
	it "clears cache when observer is removed" do
		registry.observer = observer
		metric = registry.metric(:total_requests)
		metric.set(10)
		
		# Remove observer — cache should be cleared
		registry.observer = nil
		
		# Write should not go to the old buffer
		metric.set(99)
		
		buffer = IO::Buffer.map(File.open(shm_path, "r+b"), file_size, 0)
		expect(buffer.get_value(:u64, 0)).to be == 10
		
		# In-memory value is still updated
		expect(metric.value).to be == 99
		
		# Re-attaching observer should sync the current value
		registry.observer = observer
		buffer = IO::Buffer.map(File.open(shm_path, "r+b"), file_size, 0)
		expect(buffer.get_value(:u64, 0)).to be == 99
	end
end
