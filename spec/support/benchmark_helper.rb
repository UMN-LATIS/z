require 'benchmark'

module BenchmarkHelper
  def log(msg)
    result = nil
    time = Benchmark.measure { result = yield }
    puts "⏱️ [BENCHMARK] #{format('%8.6s', time.real)}s | #{msg}"
    result
  end
end

RSpec.configure do |config|
  config.include BenchmarkHelper, type: :feature
end
