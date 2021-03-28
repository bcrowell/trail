#!/bin/ruby


require 'json'
require 'csv'

require_relative "lib/routes"

def die(s)
  print s,"\n"
  exit(-1)
end

d = {}
File.open('matches.json','r') { |f|
  d = JSON.parse(f.gets(nil))
}

# {"albert allen":{"wilson":1.4861111111111112,"baldy":1.8894444444444445},"amelie joffrin":{"wilson":1.4519444444444445,"baldy":1.9194444444444443},

course_horiz,course_cf,course_gain = get_route_data("data/routes.csv")

# print header for csv file
course_horiz.keys.sort.each { |race|
  print ",#{race}"
}
print "\n"

d.keys.sort.each { |who|
  times = d[who]
  p = []
  course_horiz.keys.sort.each { |race|
    if not times.has_key?(race) then
      p.push('')
      next 
    end    
    cf = course_cf[race]
    horiz = course_horiz[race]
    energy = (horiz/26.2)/(1-cf/100.0) # energy expenditure in units of marathons
    t = times[race]
    power = energy/(t/2.0) # energy in units of kipchoges: power expended to run a marathon in 2 hours
    #print "  #{race} #{t} #{horiz} #{cf} #{energy}        power=#{power}\n"
    #print "  #{race} power=#{power}\n"
    p.push(sprintf("%5.3f",power))
  }
  print "#{who},#{p.join(',')}\n"
}
