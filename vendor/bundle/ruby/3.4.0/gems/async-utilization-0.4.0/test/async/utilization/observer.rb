# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "sus"
require "sus/fixtures/temporary_directory_context"
require "async/utilization"
require "fileutils"

describe Async::Utilization::Observer do
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
	
	before do
		File.open(shm_path, "w+b") do |file|
			file.truncate(file_size)
		end
	end
	
	it "can create an observer from a file" do
		expect(observer).to be_a(Async::Utilization::Observer)
		expect(observer.schema).to be == schema
	end
	
	with "non-page-aligned offsets" do
		let(:file_size) {IO::Buffer::PAGE_SIZE * 2}
		let(:offset) {100}  # Not page-aligned
		
		it "maps values at the correct offset" do
			observer.buffer.set_value(:u64, schema[:total_requests].offset, 100)
			observer.buffer.set_value(:u32, schema[:active_requests].offset, 20)
			
			# Read back from file at the correct byte position
			buffer = IO::Buffer.map(File.open(shm_path, "r+b"), file_size, 0)
			expect(buffer.get_value(:u64, offset + schema[:total_requests].offset)).to be == 100
			expect(buffer.get_value(:u32, offset + schema[:active_requests].offset)).to be == 20
		end
	end
	
	with "page-aligned offsets" do
		let(:file_size) {page_size * 2}
		let(:segment_size) {page_size}
		
		it "maps values at the correct offset" do
			observer.buffer.set_value(:u64, schema[:total_requests].offset, 123)
			
			buffer = IO::Buffer.map(File.open(shm_path, "r+b"), file_size, 0)
			expect(buffer.get_value(:u64, schema[:total_requests].offset)).to be == 123
		end
	end
end
