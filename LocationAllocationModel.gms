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

obj1 .. 
                  F1 =e= sum( (j), betaFactor(j)*y(j) ) + sum( (i,k,s), probability(s)*betaCity(i)*y_city(i,k,s) );

obj2 .. 
                  F2 =e= sum( (j), delta(j));

*Constraint (2)

linear0(j) ..
                  y(j) =l= sum( macroCluster(j,k), z(k) );

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
                  y(j) =l= sum( (macroCluster(j,k)), alpha(k)*micro_pop(k) );

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
                  sum( macroCluster(j,k), x(k) ) =g= 1;

allocCap(j, macroCluster(j,k), s) ..
                  sum( i, y_city(i,k,s) ) =l= q(k);

allocInfect(i,j,s) ..
                  sum( macroCluster(j,k), y_city(i,k,s) ) =l= alpha_city(i,s)*population(i);

*deltaVal(i,l,j,s) ..
*                  delta(j) =g= sum( macroCluster(j,k), (y_city(i,k,s)/(alpha_city(i,s)*population(i)))
*                                                      -(y_city(l,k,s)/(alpha_city(l,s)*population(l))) );



Model locationModel / all /;

solve locationModel using mip maximizing F1;















