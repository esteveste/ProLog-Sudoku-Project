%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Projecto de LP
% Bernardo Esteves - 87633
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- include('SUDOKU').

%---------------------------------------------------------------------
% tira_num_aux(Num,Puz,Pos,N_Puz) significa que N_Puz e o puzzle resultante de
% tirar o numero Num da posicao Pos do puzzle Puz.
% Pos -> (L,C)
%---------------------------------------------------------------------

tira_num_aux(Num,Puz,Pos,N_Puz):-
        puzzle_ref(Puz, Pos, Cont),%vai buscar o quadrado do sudoku
        delete(Cont, Num, Changed),%tira as possibilidades do Num do quadrado
        puzzle_muda_propaga(Puz,Pos,Changed,N_Puz).%substitui no puz final

%---------------------------------------------------------------------
% tira_num(Num,Puz,Posicoes,N_Puz) significa que N_Puz e o puzzle resultante de
% tirar o numero Num de todas as posicoes em Posicoes do puzzle Puz.
%
%---------------------------------------------------------------------

tira_num(Num,Puz,Posicoes,N_Puz):-
        percorre_muda_Puz(Puz,tira_num_aux(Num),Posicoes,N_Puz).

%---------------------------------------------------------------------
%puzzle_muda_propaga(Puz, Pos, Cont, N_Puz) faz o mesmo que o predicado
%puzzle_muda/4, mas, no caso de Cont ser uma lista unitaria, propaga a mudanca, isto
%e, retira o numero em Cont de todas as posicoes relacionadas com Pos, isto e, todas as
%posicoes na mesma linha, coluna ou bloco.
%---------------------------------------------------------------------

puzzle_muda_propaga(Puz,Pos,Cont,Puz):-
        puzzle_ref(Puz,Pos,Cont1),%verifica se o elemento a substituir
        Cont == Cont1,!.%e igual se for nao substitui

puzzle_muda_propaga(Puz, Pos, [Cont], N_Puz):-!,%visto q e unitario, bloqueia o ramo,
        puzzle_muda(Puz, Pos, [Cont], Puz_Muda),%altera o local do puz por Cont
        posicoes_relacionadas(Pos,PosRel),%arranja as posicoes relacionadas a Pos
        tira_num(Cont,Puz_Muda,PosRel,N_Puz).
        


puzzle_muda_propaga(Puz,Pos,Cont,N_Puz):-
        %se o conteudo nao for unitario nao propaga
        puzzle_muda(Puz,Pos,Cont,N_Puz).%muda

%ve se lista e unitaria
e_lista_unitario([_|T]):-
        T == [].

%---------------------------------------------------------------------
%possibilidades(Pos,Puz,Poss) significa que Poss e a lista de numeros possiveis
%para a posicao Pos, do puzzle Puz. Nota: este predicado apenas deve ser usado para
%posicoes cujo conteudo nao e uma sequencia unitaria
%---------------------------------------------------------------------

possibilidades(Pos,Puz,Poss):-
        numeros(N),%lista de nr possiveis nrs no sudoku
        posicoes_relacionadas(Pos,PosRel),%arranja as pos relacionadas
        conteudos_posicoes(Puz,PosRel,Conteudos),%arranja os elementos do sudoku relacionadas com a posicao 
        poss_aux(Conteudos,N,Poss).%vai calcular as possibilidades

poss_aux([[]|T_Conteudos],N,Poss):-!,%caso a lista for vazia, nao procura mais ramos
        poss_aux(T_Conteudos,N,Poss).%ve o proximo
poss_aux([],N,N):-!.%se chegamos ao fim, retorna e n ve mais
poss_aux([H_Conteudos|T_Conteudos],N,Poss):-
        e_lista_unitario(H_Conteudos),!,%se for unitario, nao procura mais na arvore
        member(A,H_Conteudos),%arranja o nr
        delete(N, A, N_Changed),%removemos a possibilidade do nr
        poss_aux(T_Conteudos,N_Changed,Poss).%vemos se existem mais elementos q pertencem aos 2

poss_aux([H_Conteudos|T_Conteudos],N,Poss):-
        \+ e_lista_unitario(H_Conteudos),%se nao for unitario
        poss_aux(T_Conteudos,N,Poss).%ve o prox

%---------------------------------------------------------------------
%inicializa_aux(Puz,Pos,N_Puz) significa que N_Puz e o puzzle resultante de colocar
%na posicao Pos do puzzle Puz a lista com os numeros possiveis para essa posicao.
%Note que, se o conteudo da posicao Pos de Puz ja for uma lista unitaria, nada e alterado.
%---------------------------------------------------------------------

inicializa_aux(Puz,Pos,Puz):-
        puzzle_ref(Puz,Pos,Cont),%vai buscar o elemento
        e_lista_unitario(Cont),!.%se for unitario, nao muda

inicializa_aux(Puz,Pos,N_Puz):-%se o local a alterar nao for unitario
        possibilidades(Pos,Puz,Poss),%ve a possibilidade
        puzzle_muda_propaga(Puz,Pos,Poss,N_Puz).%muda e propaga caso for unitario
%---------------------------------------------------------------------
%inicializa(Puz,N_Puz) significa que N_Puz e o puzzle resultante de inicializar o
%puzzle Puz.
%---------------------------------------------------------------------

inicializa(Puz,N_Puz):-
        todas_posicoes(Todas_Posicoes),
        percorre_muda_Puz(Puz,inicializa_aux,Todas_Posicoes,N_Puz).

%---------------------------------------------------------------------
%so_aparece_uma_vez(Puz,Num,Posicoes,Pos_Num) significa que o numero Num
%so aparece numa das posicoes da lista Posicoes do puzzle Puz, e que essa posicao e
%Pos_Num.
%---------------------------------------------------------------------

so_aparece_uma_vez(_,_,[],_):-!.%se chegamos ao fim acaba

so_aparece_uma_vez(Puz,Num,[H_Posicoes|T_Posicoes],H_Posicoes):-
        puzzle_ref(Puz,H_Posicoes,Cont),%vai buscar o el do sudoku
        member(Num,Cont),!,%ve se o nr esta no elemento, e nao ve mais no member
        so_aparece_uma_vez(Puz,Num,T_Posicoes,H_Posicoes).%chama o prox com o output ja definido, pois se existir outro elemento com o nr da erro
        
so_aparece_uma_vez(Puz,Num,[H_Posicoes|T_Posicoes],Pos_Num):-%se nao contiver o nr
        puzzle_ref(Puz,H_Posicoes,Cont),%vai buscar o el do sudoku
        \+ member(Num,Cont),%se nao for membro
        so_aparece_uma_vez(Puz,Num,T_Posicoes,Pos_Num).%ve o prox

%---------------------------------------------------------------------
%inspecciona_num(Posicoes,Puz,Num,N_Puz) significa que N_Puz e o resultado
%de inspeccionar o grupo cujas posicoes sao Posicoes, para o numero Num:
%se Num so ocorrer numa das posicoes de Posicoes e se o conteudo dessa posicao
%nao for uma lista unitaria, esse conteudo e mudado para [Num] e esta mudanca e
%propagada;
%caso contrario, Puz = N_Puz.
%---------------------------------------------------------------------

inspecciona_num(Posicoes,Puz,Num,N_Puz):-
        so_aparece_uma_vez(Puz,Num,Posicoes,Pos_Num),!,%se o numero so aparece uma vez no grupo,obtemos a posicao,bloqueamos o ramo
        puzzle_muda_propaga(Puz,Pos_Num,[Num],N_Puz).%e propagamos o nr

inspecciona_num(_,Puz,_,Puz).%Caso contrario devolvemos o Puz

%---------------------------------------------------------------------
%inspecciona_grupo(Puz,Gr,N_Puz) inspecciona o grupo cujas posicoes sao as da
%lista Gr, do puzzle Puz para cada um dos numeros possiveis, sendo o resultado o puzzle
%N_Puz.
%---------------------------------------------------------------------

inspecciona_grupo(Puz,Gr,N_Puz):-
        numeros(N),%arranjamos todos os numeros a testar
        inspecciona_grupo_nrs(Puz,Gr,N_Puz,N).%testamos o grupo com todos os nrs
        
%funcao aux q chama o inspecciona_num para todos os nrs da lista N

inspecciona_grupo_nrs(Puz,Posicoes,N_Puz,[H_N]):-
        inspecciona_num(Posicoes,Puz,H_N,N_Puz),!.%quando cheagar ao fim faz o ultimo

inspecciona_grupo_nrs(Puz,Posicoes,N_Puz,[H_N|T_N]):-
        inspecciona_num(Posicoes,Puz,H_N,Puz_Changed),%manda o 1 nr
        inspecciona_grupo_nrs(Puz_Changed,Posicoes,N_Puz,T_N).%ve o proximo

%---------------------------------------------------------------------
%inspecciona(Puz,N_Puz) inspecciona cada um dos grupos do puzzle Puz, para cada
%um dos numeros possiveis, sendo o resultado o puzzle N_Puz
%---------------------------------------------------------------------

inspecciona(Puz,N_Puz):-
        grupos(Gr),%arranja o grupo
        percorre_muda_Puz(Puz,inspecciona_grupo,Gr,N_Puz).%percorre cada um dos grupos para o inspeciona grupo

%---------------------------------------------------------------------
%grupo_correcto(Puz,Nums,Gr), em que Puz e um puzzle, significa que o grupo de
%Puz cujas posicoes sao as da lista Gr esta correcto, isto e, que contem todos os numeros
%da lista Nums, sem repeticoes.
%---------------------------------------------------------------------

grupo_correcto(Puz,Nums,Gr):-
        conteudos_posicoes(Puz,Gr,Conteudos),%vamos buscar os elementos no sudoku das posicoes
        flatten(Conteudos,Cont_Flat),%tiramos a lista de listas e metemos os numeros das posicoes numa unica lista
        grupo_correcto_aux(Nums,Cont_Flat).%chama a funcao auxliar com os nrs das posicoes

grupo_correcto_aux([],[]):-!.%se chegou ao fim acaba,a Lista Nums tb tem de ser vazia

grupo_correcto_aux(Nums,[H_Cont|T_Cont]):-
        member(H_Cont,Nums),!,%se o numero estiver nos numeros possiveis, nao procura nos outros elementos
        delete(Nums,H_Cont,Nums1),%e apaga esse nr da lista de Nums, de modo a q nao possam existir 2 nrs repetidos
        grupo_correcto_aux(Nums1,T_Cont).%Ve o Prox

%---------------------------------------------------------------------
%solucao(Puz) significa que o puzzle Puz e uma solucao, isto e, que todos os seus grupos
%contem todos os numeros possiveis, sem repeticoes.
%---------------------------------------------------------------------

solucao(Puz):-
        numeros(N),%arranjamos os numeros possiveis no puzzle
        grupos(Gr),%arranjamos os grupos do puzzle
        solucao_aux(Puz,N,Gr).%vamos varrer cada um dos grupos para o grupo correcto

solucao_aux(_,_,[]):-!.%se chagamos ao fim acaba

solucao_aux(Puz,N,[H_Gr|T_Gr]):-
        grupo_correcto(Puz,N,H_Gr),%ve o grupo
        solucao_aux(Puz,N,T_Gr).%chama o proximo grupo

%---------------------------------------------------------------------
%resolve(Puz,Sol) significa que o puzzle Sol e (um)a solucao do puzzle Puz. Na
%obtencao da solucao, deve ser utilizado o algoritmo apresentado na Seccao 1: inicializar
%o puzzle, inspeccionar linhas, colunas e blocos, e so entao procurar uma solucao, tal como
%descrito na Seccao 1.4.
%---------------------------------------------------------------------

resolve(Puz,Sol):-
        inicializa(Puz,Puz_Init),%comecamos por inicializar o puzzle
        resolve_inspeciona(Puz_Init,Puz_Insp),%depois inspecionamos ate nao ser possivel mais
        todas_posicoes(Todas_Posicoes),%vamos buscar todas as posicoes possiveis no sudoku
        resolve_n_unitarios(Puz_Insp,Todas_Posicoes,Sol),%se ainda existiram nao unitarios, vamos tentar substituir por 1 das poss
        solucao(Sol).%ve se e solucao

%funcao auxiliar do resolve q vai usar a funcao inspecciona ate nao ser mais possivel inspecionar
resolve_inspeciona(Puz_Init,Puz_Insp):-
        inspecciona(Puz_Init,Puz_Insp),%inspecciona
        Puz_Init == Puz_Insp,!.%se os puzzles sao iguais, retorna o valor e pk ja inspecionou tudo, e bloqueia o ramo


resolve_inspeciona(Puz_Init,N_Puz):-
        inspecciona(Puz_Init,Puz_Insp),%inspecciona, se os puzzles sao differentes
        resolve_inspeciona(Puz_Insp,N_Puz).%chama mais uma vez

%funcao auxiliar do resolve q vai tentar escolher uma das possibilidades nao resolvidas e propagar
resolve_n_unitarios(Puz_Insp,[],Puz_Insp):-!.%se chegamos ao fim devolve a lista

resolve_n_unitarios(Puz_Insp,[H_Posicao|_],Sol):-
        puzzle_ref(Puz_Insp, H_Posicao, Cont),%vai buscar o quadrado do sudoku
        \+ e_lista_unitario(Cont),!,%se nao for unitario, nao ve a funcao seguinte
        resolve_n_unitarios_nr(Puz_Insp,H_Posicao,Cont,Sol),!.%e vamos tentar escolher um dos numeros das possibilidades,
        % e se a funcao retornar nao vericamos mais

resolve_n_unitarios(Puz_Insp,[_|T_Posicao],Sol):-
        %caso e unitario
        resolve_n_unitarios(Puz_Insp,T_Posicao,Sol).%ve o seguinte

%funcao q auxilia a funcao auxiliar, para obter os numeros das possibilidades e propagar

resolve_n_unitarios_nr(_,_,[],_):-!,false.%se chegamos ao fim devolve falso.

resolve_n_unitarios_nr(Puz,Pos,[H_Cont|_],Sol):-
        puzzle_muda_propaga(Puz,Pos,[H_Cont],Puz_Propaga),%vamos tentar escolher o primeiro, propagar a mudanca
        resolve_inspeciona(Puz_Propaga,Puz_Inspecionado),%depois inspecionamos ate nao ser possivel mais
        todas_posicoes(Todas_Posicoes),%vamos buscar todas as posicoes
        resolve_n_unitarios(Puz_Inspecionado,Todas_Posicoes,Sol),%e vamos ver se existem mais nao unitarios
        solucao(Sol),!.%se chegamos a uma solucao, retorna o valor e bloqueia o ramo

resolve_n_unitarios_nr(Puz,Pos,[_|T_Cont],Sol):-%caso contrario
        resolve_n_unitarios_nr(Puz,Pos,T_Cont,Sol).%tenta o proximo

