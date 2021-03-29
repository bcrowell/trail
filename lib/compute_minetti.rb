#!/bin/ruby


require_relative 'minetti'

# given i, outputs C_r

if ARGV.length<1 then
  exit(-1)
end

$running = true


i = ARGV[0].to_f
print minetti(i),"\n"

