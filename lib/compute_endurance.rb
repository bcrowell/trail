#!/bin/ruby


require_relative 'endurance'

# given d and dc, outputs kappa

if ARGV.length<2 then
  exit(-1)
end

d = ARGV[0].to_f
dc = ARGV[1].to_f
print 1.0/endurance_corr_2(d,0.4,dc),"\n"

