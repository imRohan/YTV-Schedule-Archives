# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "sus"
require "async/utilization"

describe Async::Utilization::Schema do
	it "can build a schema from fields" do
		schema = Async::Utilization::Schema.build(
			total_requests: :u64,
			active_requests: :u32
		)
		
		expect(schema).to be_a(Async::Utilization::Schema)
		expect(schema.fields.size).to be == 2
	end
	
	it "calculates offsets correctly" do
		schema = Async::Utilization::Schema.build(
			total_requests: :u64,
			active_requests: :u32
		)
		
		field1 = schema[:total_requests]
		field2 = schema[:active_requests]
		
		expect(field1).to be_a(Async::Utilization::Schema::Field)
		expect(field1.name).to be == :total_requests
		expect(field1.type).to be == :u64
		expect(field1.offset).to be == 0
		
		expect(field2).to be_a(Async::Utilization::Schema::Field)
		expect(field2.name).to be == :active_requests
		expect(field2.type).to be == :u32
		expect(field2.offset).to be == 8  # u64 is 8 bytes
	end
	
	it "can convert to array format" do
		schema = Async::Utilization::Schema.build(
			total_requests: :u64,
			active_requests: :u32
		)
		
		array = schema.to_a
		expect(array).to be == [
			[:total_requests, :u64, 0],
			[:active_requests, :u32, 8]
		]
	end
	
	it "returns nil for unknown fields" do
		schema = Async::Utilization::Schema.build(
			total_requests: :u64
		)
		
		expect(schema[:unknown_field]).to be_nil
	end
end
