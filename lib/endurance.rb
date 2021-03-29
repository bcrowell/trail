def endurance_corr_1(e,beta,dc)
  # e = energy requirement in equivalent miles
  # beta = factor by which fat metabolism is slower than carb metabolism
  # dc = critical distance at which carbs would run out
  # returns a correction to the predicted time
  if e<dc then
    return 1.0
  else
    return (1-(1-beta)*dc/e)/beta
  end
end

def endurance_corr_2(e,beta,dc)
  # like endurance_corr_1, but smoothed by averaging speed from e to 2e
  # Convert to dimensionless variables:
  x = e/((1-beta)*dc)
  # Let y=v/(v_max beta).
  # Then y=x/(x-1) in non-smoothed version.
  # Indefinite integral of this is ln(x-1)+x.
  # Let ys = average of y from e to 2e.
  x0 = 1/(1-beta)
  if x<=x0/2.0 then
    ys=1/beta
  end
  if x>=x0 then
    ys = 1+(1.0/x)*Math.log((2*x-1)/(x-1))
  end
  if x>x0/2.0 and x<x0 then
    ys = (1.0/beta-1.0)*x0/x-1.0/beta+2+(1.0/x)*Math.log((2*x-1)/(x0-1))
  end
  return 1/(beta*ys)
end

