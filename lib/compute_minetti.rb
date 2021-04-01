#!/bin/ruby


require_relative 'minetti'

# given i, outputs C_r

if ARGV.length<2 then
  exit(-1)
end

$running = true

$minetti_r = ARGV[1].to_i # set to 0 for original fit, 1 for recreational fit

i = ARGV[0].to_f
print minetti(i),"\n"

