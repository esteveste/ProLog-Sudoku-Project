%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Projecto de LP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- include('SUDOKU').

%---------------------------------------------------------------------
% tira_num_aux(Num,Puz,Pos,N_Puz) significa que N_Puz é o puzzle resultante de
% tirar o número Num da posição Pos do puzzle Puz.
% Pos -> (L,C)
%---------------------------------------------------------------------
tira_num_aux(Num,Puz,(L,C),N_Puz):-
        puzzle_ref(Puz, (L, C), Cont),%vai buscar o quadrado do sudoku
        delete(Cont, Num, Changed),%tira as possibilidades do Num do quadrado
        puzzle_muda(Puz, (L,C), Changed, N_Puz).%substitui no puz final



%---------------------------------------------------------------------
% tira_num(Num,Puz,Posicoes,N_Puz) significa que N_Puz é o puzzle resultante de
% tirar o número Num de todas as posições em Posicoes do puzzle Puz.
%
%---------------------------------------------------------------------

tira_num(Num,Puz,Posicoes,N_Puz):- percorre_muda_Puz(Puz,tira_num_aux(Num),Posicoes,N_Puz).
