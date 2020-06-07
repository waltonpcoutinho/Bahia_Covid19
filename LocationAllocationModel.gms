$include Parameters.gms

Set objIdx / 1*2 /;

Binary Variables

   x(k)          'Binary variable to indicate whether POD k is established at micro-region k'
;

Positive Variables

   q(k)               'Capacity of POD k'
   y(j)               'Number of served people in meso-region j'
   y_city(i,k,s)      'Number of people from municipality i served by POD k in scenario s (people)'
   delta(j)           'Relative inequity associated with meso-region j'
   z(k)               'Auxiliary variable'
;

Free Variables

   F(objIdx)     'The value of the objective function'
   F1
   F2
;

Equations

   obj1          'Objective function'
   obj2          'Objective function'
   linear0       'Linearisation of NL constraint'
   linear1       'Linearisation of NL constraint'
   linear2       'Linearisation of NL constraint'
   linear3       'Linearisation of NL constraint'
   infection     'Number of infected people'
   maxCapacity   'Maximum capacity of POD k'
   minCapacity   'Minimum capacity of POD k'
   budgetCons    'Budget constraint'
   facility      'Constraint on number of open facilities'
   allocCap      'Capacity constraint of allocation model'
   allocInfect   'Number of infected people by constraint'
*   deltaVal      'Value of the inequity var'
;

*'Set lower and upper bounds'
y.up(j) = macro_pop(j);
y_city.up(i,k,s)$(not(cityCluster(k,i))) = 0;

*'Create model'
obj1 ..
                  F1 =e= sum( (j), betaFactor(j)*y(j) ) + sum( (i,k,s), probability(s)*betaCity(i)*y_city(i,k,s) );

obj2 ..
                  F2 =e= sum( (j), delta(j));

*Constraint (2)

linear0(j) ..
                  y(j) =l= sum( k$(microCluster(j,k)), z(k) );

*Constraint (10)

linear1(k) ..
                  z(k) =l= q(k);

*Constraint (11)

linear2(k) ..
                  z(k) =l= maximumC(k)*x(k);

*Constraint (12)

linear3(k) ..
                  z(k) =g= q(k) - minimumC(k)*(1 - x(k));

*Constraint (3)

infection(j) ..
                  y(j) =l= sum( k$(microCluster(j,k)), micro_pop(k) );

*Constraint (4)

maxCapacity(k) ..
                  q(k) =l= maximumC(k)*x(k);

*Constraint (5)

minCapacity(k) ..
                  q(k) =g= minimumC(k)*x(k);

*Constraint (6)

budgetCons ..
                  sum( k, q(k) ) =l= Budget;

*Constraint (7)

facility(j) ..
                  sum( k$(microCluster(j,k)), x(k) ) =g= 1;

*Constraint (9)

allocCap(k, j, s)$(microCluster(j,k)) ..
                  sum( cityCluster(k2,i)$(microCluster(j,k2)), y_city(i,k,s) ) =l= q(k);

*Constraint (10)

allocInfect(i, j, s)$(macroCluster(j,i)) ..
                  sum( k$(microCluster(j,k)), y_city(i,k,s) ) =l= alpha_city(i,s)*population(i);

*Constraint (11)

*deltaVal(i, l, j, s) ..
*                  delta(j) =g= sum( microCluster(j,k), (y_city(i,k,s)/(alpha_city(i,s)*population(i)))
*                                                      -(y_city(l,k,s)/(alpha_city(l,s)*population(l))) );



Model locationModel / all /;

option limrow = 1000;
solve locationModel using mip maximizing F1;


********************************************************************************************
*'Export solution using GDX utilities'
********************************************************************************************

*'First unload to GDX file (occurs during execution phase)'
execute_unload "solution.gdx" , x, q, y, y_city, delta;

*'Export data to excel files'
execute 'gdxxrw.exe solution.gdx var=x.l rng=Facilities!'
execute 'gdxxrw.exe solution.gdx var=q.l rng=Capacity!'
execute 'gdxxrw.exe solution.gdx var=y.l rng=Served_macro!'
execute 'gdxxrw.exe solution.gdx var=y_city.l rng=Served_city!'
execute 'gdxxrw.exe solution.gdx var=delta.l rng=Inequity!'












