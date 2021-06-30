require 'benchmark';

module BenchmarkHelper
  def log(msg)
    result = nil
    time = Benchmark.measure { result = yield }
    puts "⏱️ [BENCHMARK] #{ "%8.6s" % [time.real] }s | #{msg}"
    result
  end
end