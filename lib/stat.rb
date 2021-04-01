def stats(x)
  a = [median_value(x),mean_abs_value(x),sd_value(x)]
  a.push(kurtosis_value(x,a[1],a[2]))
  return a
end

def mean_abs_value(x)
  return (x.map {|u| u.abs}.sum)/x.length
end

def mean_value(x)
  return (x.sum)/x.length
end

def mean_abs_dev_value(a)
  # mean absolute difference from the mean
  # ... this behaves well when tails are fat and there's plenty of data, but produces weird results with small n
  mean = mean_value(a)
  return mean_abs_value(a.map {|u| (u-mean)})
end

def median_abs_dev_value(a)
  # median absolute difference from the median
  # ... this behaves well when tails are fat and there's plenty of data, but produces weird results with small n
  med = median_value(x)
  return median_value(x.map {|u| (u-med).abs})
end

def median_value(x) # https://stackoverflow.com/a/14859546
  return nil if x.empty?
  sorted = x.sort
  len = sorted.length
  (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
end

def kurtosis_value(a,mean,sd)
  # https://en.wikipedia.org/wiki/Kurtosis
  n = a.length
  if n<2 then return nil end
  s = 0.0
  a.each { |x|
    s = s+((x-mean)/sd)**4
  }
  return s/n
end

def sd_value(a)
  # standard deviation
  n = a.length
  if n<2 then return nil end
  s = 0.0
  a.each { |x|
    s = s+x
  }
  mean = s/n
  s = 0.0
  a.each { |x|
    diff = x-mean
    s = s+diff*diff
  }
  sd = Math.sqrt(s/(n-1))
  return sd
  # median absolute difference from the median
  # ... this behaves well when tails are fat and there's plenty of data, but produces weird results with small n
  #med = median_value(x)
  #return median_value(x.map {|u| (u-med).abs})
end

def random_normal()
  n = 100
  s = 0.0
  1.upto(n) { |i|
    s = s + rand()
  }
  return (s-0.5*n)*Math::sqrt(12.0)/n
end

def random_student(nu)
  # https://stats.stackexchange.com/a/70270/122182
  # Tested that it seems to give the right mean of the absolute value for nu=2, and also that it gives a good QQ plot.
  s = 0
  1.upto(nu) {
    s = s+random_normal()**2
  }
  return random_normal()/Math::sqrt(s/nu)
end

