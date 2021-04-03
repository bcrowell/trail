#!/bin/ruby

require 'json'

def die(s)
  $stderr.print s,"\n"
  exit(-1)
end

def output_record(row)
  row['name'].gsub!(/\s+$/,'') # get rid of trailing whitespace
  row['name'].gsub!(/^\s+/,'') # get rid of leading whitespace
  row['name'].gsub!(/(\w+)/) {$1.capitalize}
  row['time'].gsub!(/:(\d\d)(\d)/) {":#{$1}.#{$2}"}
  if not sanity_check_time(row['time']) then die("time fails sanity check, #{row}") end
  if row['address']=~/^\s+$/ then row['address']='' end # address is only whitespace, make it null string
  return JSON.generate(row)
end

def sanity_check_time(s)
  if not syntax_check_time(s) then return false end
  t = parse_time(s)
  if t<0.5 then return false end
  return true
end

def syntax_check_time(s)
  if s=~/(\d{1,2}):(\d\d):(\d\d(\.\d+)?)/ then
    return true
  end
  if s=~/(\d\d):(\d\d(\.\d+)?)/ then
    return true
  end
  return false
end

def parse_time(s) # to hours
  if s=~/(\d+):(\d+):(\d+)/ then
    return $1.to_f+($2.to_f+($3.to_f)/60.0)/60.0
  end
  if s=~/(\d+):(\d+)/ then
    return ($1.to_f+($2.to_f)/60.0)/60.0
  end
  return nil
end

if ARGV.length<1 then 
  print "provide format on command line\n"
  exit(-1)
end

format = ARGV[0]

lines_per_person = -1
if format=='athlinks' then # wilson, broken arrow
  lines_per_person = 9
end
if format=='runsignup' then # irvine half
  lines_per_person = 5
end
if format=='baldy' || format=='ultrasignup' || format=='agoura' || format=='into_the_wild1' || format=='into_the_wild2' || format=='revel' then
  lines_per_person = 1
end
if lines_per_person==-1 then die("unrecognized format") end

table = []
accum = []
$stdin.each_line { |line|
  if line=~/^#/ then next end
  line.gsub!(/.*Claim$/,'') # sometimes has garbage chars on front
  if format=='runsignup' and line.length>30 and accum.length==3 then accum.unshift('') end # people who have claimed with their icon have a missing line
  accum = accum.push(line.strip)
  if accum.length==lines_per_person then
    table = table.push(accum)
    accum = []
  end
}

if format=='athlinks' then
  table.each { |person|
    crap0,name,about,crap1,crap2,crap3,crap4,crap5,time = person
    # MICHAEL EASTBURN;M 29Bib 1Porter Ranch, CA, USA;1:04:38
    # time fails sanity check, {"name"=>"Antonius Gunawan", "time"=>"", "sex"=>"NOT SPECIFIED", "age"=>"36", "bib"=>"6559", "address"=>"Pasadena, CA, USA"}
    if about=~/(M|F|NOT SPECIFIED)\s*(\d*)Bib\s+(\d+)(.*)/ then
      sex,age,bib,address = $1,$2,$3,$4
    else
      print "couldn't parse about=#{about}, person=#{person}\n"
      # couldn't parse about=133, person=["THOMAS HARDY", "M 54Bib 123CA, USA", "133", "110", "14", "11:44", "MIN/MI", "1:40:57", ""]
      exit(-1)
    end
    row = {'name'=>name,'time'=>time,'sex'=>sex,'age'=>age,'bib'=>bib,'address'=>address}
    print output_record(row),"\n"
  }
end

if format=='runsignup' then
  # 1	
  # B
  # Blake
  # Fonda
  #	Lodi	CA	1148	M	1:11:40	1:11:40	21	1	M 18-24	5:28
  # time fails sanity check, {"name"=>"Jake Cruzen", "time"=>"14", "sex"=>"1:31:30", "age"=>"M 13-17", "bib"=>"1:31:32", "address"=>"1800 M"}
  #                         1800    M       1:31:32 1:31:30 16      14      M 13-17 6:59

  table.each { |person|
    first = person[2]
    last = person[3]
    stuff = person[4]
    # first=Blake last=Fonda stuff=Lodi	CA	1148	M	1:11:40	1:11:40	21	1	M 18-24	5:28
    # ... tab delimited
    a = stuff.split(/\t/)
    # ["Lodi", "CA", "1148", "M", "1:11:40", "1:11:40", "21", "1", "M 18-24", "5:28"]
    1.upto(2) { |i|
      if a.length<10 then a = a.unshift('') end
    }
    town,state,bib,sex,crap,time,age = a
    address = "#{town} #{state}"
    name = "#{first} #{last}"
    row = {'name'=>name,'time'=>time,'sex'=>sex,'age'=>age,'bib'=>bib,'address'=>address}
    print output_record(row),"\n"
  }
end

if format=='baldy' then
  # Place   Name    City    Bib No  Age     Gender  Age Group       Chip Time       Gun Time        Pace
  # 1       LUCAS MATISON   Altadena CA     261     21      M       1/12:19-24      1:09:30         1:09:30         9:56/M
  # 2 	DAVID WALTON 		445 	29 	M 	1/20:25-29 	1:12:20 	1:12:20 	10:20/M
  table.each { |person|
    x = person[0]
    x.gsub!(/[^\w\d \/:\t]/,'')
    a = x.split(/\t/)
    place,name,address,bib,age,sex,crap0,time = a
    row = {'name'=>name,'time'=>time,'sex'=>sex,'age'=>age,'bib'=>bib,'address'=>address}
    print output_record(row),"\n"
  }
end

if format=='ultrasignup' then
  # results 1       David   Sinclair        Flagstaff       AZ      25      M       1       49:44   98.41
  table.each { |person|
    x = person[0]
    x.gsub!(/[^\w\d \/:\t]/,'')
    a = x.split(/\t/)
    crap,place,first,last,town,state,age,sex,gp,time,crap = a
    name = "#{first} #{last}"
    address = "#{town} #{state}"
    row = {'name'=>name,'time'=>time,'sex'=>sex,'age'=>age,'address'=>address}
    print output_record(row),"\n"
  }
end

if format=='agoura' then
  # 2171    MATTHEW GLYNN   AGOURA HILLS    01:22:10        06:16 min/mile  Sumac   CHESEBRO 1/2 MARATHON   1       42      1       M       1
  # 2777 	MATTHEW GULDEN 	MURRAY 	01:23:51 	06:24 min/mile 		CHESEBRO 1/2 MARATHON 	2 	31 	1 	M 	2
  # delimited by space+tab
  table.each { |person|
    x = person[0]
    x.gsub!(/[^\w\d \/:\t]/,'')
    a = x.split(/\s*\t/)
    if a.length==12 then a.delete_at(5) end # e.g., matthew glynn has "Sumac"; these are names of clubs
    bib,name,address,time,crap1,crap2,crap3,age,crap4,sex,crap5 = a
    row = {'name'=>name,'time'=>time,'sex'=>sex,'age'=>age,'address'=>address}
    print output_record(row),"\n"
  }
end

if format=='into_the_wild1' then
  # 1 	Branden Bollweg 	402 	30 	1 M 25-34 	1:37:29.2
  # delimited by space+tab
  table.each { |person|
    x = person[0]
    x.gsub!(/[^\w\d \/:\t]/,'')
    a = x.split(/\s*\t/)
    place,name,bib,age,stuff,time = a
    sex = ''
    if stuff=~/([MF])/ then sex=$1 end
    row = {'name'=>name,'time'=>time,'sex'=>sex,'age'=>age}
    print output_record(row),"\n"
  }
end

if format=='revel' then
  # 9 or 10 columns:
  # 1 	1 M 		3853 	Martinez 	Tony 	M 	28 	1:08:22 	5:13
  # 15 	1 F 		4440 	Castaneda 	Maria R 	F 	32 	1:23:18 	6:21
  # ["15", "1 F", "4440", "Castaneda", "Maria R", "F", "32", "1:23:18", "6:21"]
  # ["733", "294 M", "40 M5054", "3260", "Castaneda", "Sergio", "M", "51", "2:12:34", "10:07"]
  # delimited by space+tab
  table.each { |person|
    x = person[0]
    x.gsub!(/[^\w\d \/:\t]/,'')
    a = x.split(/\s*\t/)
    if a.length==10 then a.delete_at(2) end # delete place_age if present
    place,place_gender,bib,last,first,sex,age,time,crap = a
    row = {'name'=>"#{first} #{last}",'time'=>time,'sex'=>sex,'age'=>age}
    print output_record(row),"\n"
  }
end

if format=='into_the_wild2' then
  # 1                     Frank Ross           53      23 1 OA, M 16-24*       1:40:01.0
  # 1            Matthieu Gancedo       225      34      1:OA Male     1:45:05.2        *
  # delimited by whitespace
  # {"name":"Frank Ross","time":null,"sex":"","age":"23 1 OA M 1624     "}
  table.each { |person|
    x = person[0]
    x.gsub!(/[^\w\d \/:\t]/,'')
    if x=~/^(\d+)\s+([^\d]+)(\d+)\s+(\d+)\s+(.*)\s{4,}([\d:\.]+)\s*\*?$/ then
      place,name,bib,age,stuff,time = $1,$2,$3,$4,$5,$6
      sex = ''
      if stuff=~/([MF])/ then sex=$1 end
      row = {'name'=>name,'time'=>time,'sex'=>sex,'age'=>age}
      print output_record(row),"\n"
    else
      die("error processing line #{x}")
    end
  }
end

