match(output(O,L), @match_output(O)):- output(O,L), not reserved(_, O).

% Remove the previous output
hide(output(O,L)):-output(O,L).

% Add the match output
#show output(F, L):match(output(O,L),F).


#include "show-encoding-extension.lp".
