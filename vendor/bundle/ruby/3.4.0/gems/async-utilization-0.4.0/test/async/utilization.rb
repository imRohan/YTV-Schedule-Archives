# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "sus"
require "async/utilization"

describe Async::Utilization do
	it "has a version number" do
		expect(Async::Utilization::VERSION).to be =~ /\d+\.\d+\.\d+/
	end
end
