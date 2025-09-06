modality(thtc, op, 3, (set(eq,assign),linear_temp_cons_atom,linear_temp_cons_atom)).


modality(thtc, eq, 2, (linear_temp_cons_atom,linear_temp_cons_atom)).%derived
% modality(thtc, diff, 2, (linear_temp_cons_atom,linear_temp_cons_atom)).
% modality(thtc, lt, 2, (linear_temp_cons_atom,linear_temp_cons_atom)).
% modality(thtc, leq, 2, (linear_temp_cons_atom,linear_temp_cons_atom)).
modality(thtc_assign, assign, 2, (simple_tel,linear_temp_cons_atom)). %Derived

% We would need to limit this to a sum of two things since the poling is not on atoms
% and we can't recursively go inside the sum without leaving the same rule
% we would need some chaining for that
modality(linear_temp_cons_atom, sum, 2, (m,m)).
modality(linear_temp_cons_atom, simple_tel).%derived
modality(linear_temp_cons_atom, atom).%derived

modality(m, mul, 2, (num,simple_tel)).
modality(m, simple_tel). %derived
modality(m, atom). %derived

modality(simple_tel, next, 2, (num,atom)).
modality(simple_tel, next, 1, (atom)). %Derived
modality(simple_tel, atom). %Derived




occurrence(thtc, body;head).
occurrence(thtc_assign, head).
