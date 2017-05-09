take(N, _, Xs) :- N =< 0, !, N =:= 0, Xs = [].
take(_, [], []).
take(N, [X|Xs], [X|Ys]) :- M is N-1, take(M, Xs, Ys).

test([X|Y]):-writeln(X),writeln(Y).
test2(X|Y):-writeln(X),writeln(Y).


list([_|R]):-R==[].