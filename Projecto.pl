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


%puzzle_muda_propaga(Puz, Pos, Cont, N_Puz) faz o mesmo que o predicado
%puzzle_muda/4, mas, no caso de Cont ser uma lista unitária, propaga a mudança, isto
%é, retira o número em Cont de todas as posições relacionadas com Pos, isto é, todas as
%posições na mesma linha, coluna ou bloco.



puzzle_muda_propaga(Puz, (L,C), [Cont], N_Puz):-
        e_lista_unitario([Cont]),!,%verifica se Cont e unitario nao verifica mais hipoteses
        puzzle_muda(Puz, (L,C), [Cont], Puz_Muda),%altera o local do puz por Cont
        posicoes_relacionadas((L,C),PosRel),%arranja as posicoes relacionadas a Pos
        tira_num(Cont,Puz_Muda,PosRel,Puz_Tira),
        puzzle_muda_propaga_aux(PosRel,Puz_Tira,N_Puz).
        


puzzle_muda_propaga(Puz,(L,C),Cont,N_Puz):-
        \+ e_lista_unitario(Cont),%se o resto dos argumentos nao for vazio, ent n e unitario
        puzzle_muda(Puz,(L,C),Cont,N_Puz).

%auxiliar para ver onde propagar
puzzle_muda_propaga_aux([],Puz,Puz):-!.%se chegou ao fim ent o puz final e o do tira

puzzle_muda_propaga_aux([H_PosRel|_],Puz,N_Puz):-
        puzzle_ref(Puz,H_PosRel,[Cont]),%arranja o elemento onde mudamos
        e_lista_unitario([Cont]),!,%se for unitario, e nao ve o prox
        puzzle_muda_propaga(Puz,H_PosRel,[],N_Puz).%executa o muda propaga

puzzle_muda_propaga_aux([H_PosRel|T_PosRel],Puz,N_Puz):-
        puzzle_ref(Puz,H_PosRel,[Cont]),%arranja o elemento onde mudamos
        \+ e_lista_unitario([Cont]),%se nao for unitario
        puzzle_muda_propaga_aux(T_PosRel,Puz,N_Puz).%ve o prox


%ve se lista e unitaria
e_lista_unitario([_|T]):-
        T == [].




