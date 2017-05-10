%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Projecto de LP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- include('SUDOKU').

%---------------------------------------------------------------------
% tira_num_aux(Num,Puz,Pos,N_Puz) significa que N_Puz é o puzzle resultante de
% tirar o número Num da posição Pos do puzzle Puz.
% Pos -> (L,C)
%---------------------------------------------------------------------
tira_num_aux(Num,Puz,Pos,N_Puz):-
        puzzle_ref(Puz, Pos, Cont),%vai buscar o quadrado do sudoku
        delete(Cont, Num, Changed),%tira as possibilidades do Num do quadrado
        puzzle_muda_propaga(Puz,Pos, Changed, N_Puz).%substitui no puz final



%---------------------------------------------------------------------
% tira_num(Num,Puz,Posicoes,N_Puz) significa que N_Puz é o puzzle resultante de
% tirar o número Num de todas as posições em Posicoes do puzzle Puz.
%
%---------------------------------------------------------------------

tira_num(Num,Puz,Posicoes,N_Puz):-
        percorre_muda_Puz(Puz,tira_num_aux(Num),Posicoes,N_Puz).


%puzzle_muda_propaga(Puz, Pos, Cont, N_Puz) faz o mesmo que o predicado
%puzzle_muda/4, mas, no caso de Cont ser uma lista unitária, propaga a mudança, isto
%é, retira o número em Cont de todas as posições relacionadas com Pos, isto é, todas as
%posições na mesma linha, coluna ou bloco.


%base
puzzle_muda_propaga(Puz,Pos,Cont,Puz):-
        puzzle_ref(Puz,Pos,Cont1),%verifica se o elemento a substituir
        Cont == Cont1,!.%e igual se for nao substitui

puzzle_muda_propaga(Puz, Pos, [Cont], N_Puz):-
        %e_lista_unitario([Cont]),!,%verifica se Cont e unitario nao verifica mais hipoteses
        !,puzzle_muda(Puz, Pos, [Cont], Puz_Muda),%altera o local do puz por Cont
        posicoes_relacionadas(Pos,PosRel),%arranja as posicoes relacionadas a Pos
        tira_num(Cont,Puz_Muda,PosRel,N_Puz).
        


puzzle_muda_propaga(Puz,Pos,Cont,N_Puz):-
        %\+ e_lista_unitario(Cont),%se o resto dos argumentos nao for vazio, ent n e unitario
        puzzle_muda(Puz,Pos,Cont,N_Puz).%muda



%ve se lista e unitaria
e_lista_unitario([_|T]):-
        T == [].


%possibilidades(Pos,Puz,Poss) significa que Poss é a lista de números possíveis
%para a posição Pos, do puzzle Puz. Nota: este predicado apenas deve ser usado para
%posições cujo conteúdo não é uma sequência unitária

possibilidades(Pos,Puz,Poss):-
        numeros(N),%lista de nr possiveis nrs no sudoku
        posicoes_relacionadas(Pos,PosRel),%arranja as pos relacionadas
        conteudos_posicoes(Puz,PosRel,Conteudos),%arranja os elementos do sudoku relacionadas com a posicao 
        poss_aux(Conteudos,N,Poss).%vai calcular as possibilidades

poss_aux([[]|T_Conteudos],N,Poss):-!,%caso a lista for vazia, nao procura mais ramos
        poss_aux(T_Conteudos,N,Poss).%ve o proximo
poss_aux([],N,N):-!.%se chegamos ao fim, retorna e n ve mais
poss_aux([H_Conteudos|T_Conteudos],N,Poss):-
        member(A,H_Conteudos),%se o nr pertence a  H_N
        member(A,N),!,%e a Numeros, nao procuramos mais hipoteses e
        delete(N, A, N_Changed),%removemos a possibilidade
        poss_aux([H_Conteudos|T_Conteudos],N_Changed,Poss).%vemos se existem mais elementos q pertencem aos 2

poss_aux([H_Conteudos|T_Conteudos],N,Poss):-
        member(A,H_Conteudos),%se o numero de H_Cont
        \+ member(A,N),!,%nao ta em N,pk ja tiramos a poss,nao ve mais hipoteses nos members
        poss_aux(T_Conteudos,N,Poss).%ve o prox


%inicializa_aux(Puz,Pos,N_Puz) significa que N_Puz é o puzzle resultante de colocar
%na posição Pos do puzzle Puz a lista com os números possíveis para essa posição.
%Note que, se o conteúdo da posição Pos de Puz já for uma lista unitária, nada é alterado.

inicializa_aux(Puz,Pos,Puz):-
        puzzle_ref(Puz,Pos,Cont),%vai buscar o elemento
        e_lista_unitario(Cont),!.%se for unitario, nao muda

inicializa_aux(Puz,Pos,N_Puz):-%se o local a alterar nao for unitario
        possibilidades(Pos,Puz,Poss),%ve a possibilidade
        puzzle_muda_propaga(Puz,Pos,Poss,N_Puz).%muda e propaga caso for unitario

%inicializa(Puz,N_Puz) significa que N_Puz é o puzzle resultante de inicializar o
%puzzle Puz.

inicializa(Puz,N_Puz):-
        todas_posicoes(Todas_Posicoes),
        percorre_muda_Puz(Puz,inicializa_aux,Todas_Posicoes,N_Puz).

%so_aparece_uma_vez(Puz,Num,Posicoes,Pos_Num) significa que o número Num
%só aparece numa das posições da lista Posicoes do puzzle Puz, e que essa posição é
%Pos_Num.


so_aparece_uma_vez(Puz,Num,[H_Posicoes|_],H_Posicoes):-
        puzzle_ref(Puz,H_Posicoes,[Cont]),%vai buscar o el do sudoku
        Cont == Num,!.%Se o Cont tiver apenas o Num,acaba e nao procura mais
        %so_aparece_uma_vez(Puz,Num,T_Posicoes,T_Pos_Num).%nao procura mais e mete a posicao e ve o prox

so_aparece_uma_vez(Puz,Num,[_|T_Posicoes],Pos_Num):-%se nao so tiver o Num
        so_aparece_uma_vez(Puz,Num,T_Posicoes,Pos_Num).%ve o prox


