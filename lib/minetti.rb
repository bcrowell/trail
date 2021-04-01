def minetti(i)
  # cost of running or walking, in J/kg.m
  if $running then
    a,b,c,d,p = [26.073730183424228, 0.031038121935618928, 1.3809948743424785, -0.06547207947176657, 2.181405714691871]
    if $minetti_r==1 and i<0 then p=1.66; d=0.01520 end
    # ... "recreational" value of Minetti parameters; shifts min of function up and to the right
    #    For a given value of p, d has t be changed to d=F/a-b^(1/p) in order to keep C(0), the cost of flat running, equal to F.
    #    If changing this here, change it in kcals's physiology.rb as well.
  else
    a,b,c,d,p = [22.911633035337864, 0.02621471025436344, 1.3154310892336223, -0.08317260964525384, 2.208584834633906]
  end
  cost = (a*((i**p+b)**(1/p)+i/c+d)).abs
  if $minetti_r==1 then
    # "recreational" version
    cutoff_i = -0.03
    if i<cutoff_i then cost=[cost,minetti(cutoff_i)].max end
  end
  return cost
end
# Five-parameter fit to the following data:
#   c is minimized at imin, and has the correct value cmin there (see comments in i_to_iota())
#   slopes at +-infty are minetti's values: sp=9.8/0.218; sm=9.8/-1.062 for running, 
#                                           sp=9.8/0.243; sm=9.8/-1.215 for walking
#   match minetti's value at i=0.0
# original analytic work, with p=2 and slightly different values of sp and sm:
#    calc -e "x0=-0.181355; y0=1.781269; sp=9.8/.23; sm=9.8/-1.2; a=(sp-sm)/2; c=a/[(sp+sm)/2]; b=x0^2(c^2-1); d=(1/a)*{y0-a*[sqrt(x0^2+b)+x0/c]}; a(1-1/c)"
#    a = 25.3876811594203
#    c = 1.47422680412371
#    b = 0.0385908791280687
#    d = -0.0741786448190981
# I then optimized the parameters further, including p, numerically, to fit the above criteria.
# Also checked that it agrees well with the polynomial for a reasonable range of i values.
