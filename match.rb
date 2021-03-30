#!/bin/ruby

# Compile a list of all runners who ran more than one course in the dataset.
# If they ran the same course more than once, use their best time.
# Write an output json file containing times in decimal hours.

require 'json'

def die(s)
  print s,"\n"
  exit(-1)
end

def filename_to_race(filename)
  if filename=~/baldy/ then return 'baldy' end
  if filename=~/wilson/ then return 'wilson' end
  if filename=~/pasadena/ then return 'pasadena' end
  if filename=~/broken_arrow/ then return 'broken_arrow' end
  if filename=~/flagstaff/ then return 'flagstaff' end
  if filename=~/chesebro/ then return 'chesebro' end
  if filename=~/into_the_wild/ then return 'into_the_wild' end
  if filename=~/griffith_park_30k/ then return 'griffith_park_30k' end
  if filename=~/big_bear/ then return 'big_bear' end
  if filename=~/canyon_city/ then return 'canyon_city' end
  die("error parsing filename, #{filename}")
end

def ignore_filename(filename)
  return filename=~/path\.json/ || filename_to_race(filename)=='flagstaff'
  # path.json is output from kcals; I don't have route info for flagstaff
end

def parse_time(s,debug) # to hours
  t = parse_time_x(s)
  if t<0.5 then die("time is less than 30 min, #{s} -> #{t}, #{debug}") end
  return t
end

def parse_time_x(s) # to hours
  if s=~/(\d+):(\d+):(\d+)/ then
    return $1.to_f+($2.to_f+($3.to_f)/60.0)/60.0
  end
  if s=~/(\d+):(\d+)/ then
    return ($1.to_f+($2.to_f)/60.0)/60.0
  end
  return nil
end

all_names = {}
Dir.glob( 'data/times/*.json').each { |filename|
  if ignore_filename(filename) then next end
  names = []
  File.open(filename,'r') { |f|
    f.each_line { |line|
      row = JSON.parse(line) # {'name'=>name,'time'=>time,'sex'=>sex,'age'=>age,'bib'=>bib,'address'=>address}
      names.push(row['name'])
    }
  }
  all_names[filename] = names.sort
}

matched_names = {}
all_names.each_pair { |filename,names|
  $stderr.print "#{filename}\n"
  all_names.each_pair { |filename2,names2|
    if filename>=filename2 then next end
    names.each { |a|
      names2.each { |b|
        if a.nil? then die("nil name, #{filename}") end
        if b.nil? then die("nil name, #{filename2}") end
        if a.downcase==b.downcase then 
          #print "matched #{a} between #{filename} and #{filename2}\n"
          matched_names[a.downcase] = 1
        else
          #print "unequal: #{a}, #{b}\n"
        end
      }
    }
  }
}

final_data = {}
matched_names.keys.sort.each { |who|
  races = {}
  Dir.glob( 'data/times/*.json').each { |filename|
    if ignore_filename(filename) then next end
    File.open(filename,'r') { |f|
      f.each_line { |line|
        row = JSON.parse(line) # {'name'=>name,'time'=>time,'sex'=>sex,'age'=>age,'bib'=>bib,'address'=>address}
        if row['name'].downcase==who then
          t = parse_time(row['time'],"#{filename} #{who} #{row}")
          if t.nil? then die("error parsing time #{row['time']} for #{who}, #{filename_to_race(filename)}") end
          r = filename_to_race(filename)
          if races.has_key?(r) then
            if t<races[r] then races[r] = t end # take that person's fastest time on that course
          else
            races[r] = t
          end
        end
      }
    }
  }
  if races.keys.length>1 then
    final_data[who] = races
  end
}

print JSON.pretty_generate(final_data),"\n"


