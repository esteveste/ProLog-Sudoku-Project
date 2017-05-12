%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Projecto de LP
% Bernardo Esteves - 87633
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
        puzzle_muda_propaga(Puz,Pos,Changed,N_Puz).%substitui no puz final



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
        e_lista_unitario(H_Conteudos),!,%se for unitario, nao procura mais na arvore
        member(A,H_Conteudos),%arranja o nr
        delete(N, A, N_Changed),%removemos a possibilidade do nr
        poss_aux(T_Conteudos,N_Changed,Poss).%vemos se existem mais elementos q pertencem aos 2

poss_aux([H_Conteudos|T_Conteudos],N,Poss):-
        \+ e_lista_unitario(H_Conteudos),%se nao for unitario
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

so_aparece_uma_vez(_,_,[],_):-!.%se chegamos ao fim acaba

so_aparece_uma_vez(Puz,Num,[H_Posicoes|T_Posicoes],H_Posicoes):-
        puzzle_ref(Puz,H_Posicoes,Cont),%vai buscar o el do sudoku
        member(Num,Cont),!,%ve se o nr esta no elemento, e nao ve mais no member
        so_aparece_uma_vez(Puz,Num,T_Posicoes,H_Posicoes).%chama o prox, pois se existir outro elemento com o nr da erro
        
        
        
        
        
        %Cont == Num,!.%Se o Cont tiver apenas o Num,acaba e nao procura mais
        
so_aparece_uma_vez(Puz,Num,[H_Posicoes|T_Posicoes],Pos_Num):-%se nao so tiver o Num,isto e 
        puzzle_ref(Puz,H_Posicoes,Cont),%vai buscar o el do sudoku
        \+ member(Num,Cont),%se nao for membro
        so_aparece_uma_vez(Puz,Num,T_Posicoes,Pos_Num).%ve o prox



%inspecciona_num(Posicoes,Puz,Num,N_Puz) significa que N_Puz é o resultado
%de inspeccionar o grupo cujas posições são Posicoes, para o número Num:
%se Num só ocorrer numa das posições de Posicoes e se o conteúdo dessa posição
%não for uma lista unitária, esse conteúdo é mudado para [Num] e esta mudança é
%propagada;
%caso contrário, Puz = N_Puz.

%Se nao encontramos nenhum nr, igualamos Puz a N_puz
inspecciona_num([],Puz,_,N_Puz):-N_Puz=Puz,!.%tb nao vemos mais ramos

%Caso N_puz ja tava definido,
inspecciona_num([],_,_,_):-!.%retornamos o N_Puz e nao ve mais ramos



%se o elemento for unitario, Podemos evitar propagar desnecessariamente
inspecciona_num([H_Posicoes|T_Posicoes],Puz,Num,N_Puz):-
        puzzle_ref(Puz,H_Posicoes,Cont),%Vamos buscar o el do sudoku
        e_lista_unitario(Cont),!,%se o conteudo for unitario,bloqueia o ramo e
        inspecciona_num(T_Posicoes,Puz,Num,N_Puz).%ve o prox,poupando calcumos desnecessarios


%se o Numero existir na posicao a verificar,e nao for unitario
inspecciona_num([H_Posicoes|T_Posicoes],Puz,Num,N_Puz):-
        puzzle_ref(Puz,H_Posicoes,Cont),%Vamos buscar o el do sudoku
        member(Num,Cont),%se o num esta no Cont
        puzzle_muda_propaga(Puz,H_Posicoes,[Num],N_Puz),%altera o Conteudo da posicao para num, e propaga
        inspecciona_num(T_Posicoes,Puz,Num,N_Puz),!.%verifica o proximo para se ter a certeza q nao existe mais,
        %tem o corte para caso resultar o puzzle_muda_propaga, nao procura a hipotese q queremos q de quando falha

%se o Numero nao for membro do Cont
inspecciona_num([H_Posicoes|T_Posicoes],Puz,Num,N_Puz):-
        puzzle_ref(Puz,H_Posicoes,Cont),%Vamos buscar o el do sudoku
        \+ member(Num,Cont),!,%se o num nao esta no Cont,bloqueia o ramo
        inspecciona_num(T_Posicoes,Puz,Num,N_Puz).%ve o proximo

%se existia outro elemento q continha o num, da erro no puzzle propaga
inspecciona_num(_,Puz,_,Puz).%Retorna Puz



%inspecciona_grupo(Puz,Gr,N_Puz) inspecciona o grupo cujas posições são as da
%lista Gr, do puzzle Puz para cada um dos números possíveis, sendo o resultado o puzzle
%N_Puz.

%inspecciona_grupo(Puz_Changed,[],Puz_Changed).%Quando chegamos ao fim retornamos o puzzle final

inspecciona_grupo(Puz,Gr,N_Puz):-
        numeros(N),%arranjamos todos os numeros a testar
        inspecciona_grupo_nrs(Puz,Gr,N_Puz,N).%testamos o grupo com todos os nrs
        

%funcao aux q chama o inspecciona_num para todos os nrs da lista N

inspecciona_grupo_nrs(Puz,Posicoes,N_Puz,[H_N]):-
        inspecciona_num(Posicoes,Puz,H_N,N_Puz),!.%quando cheagar ao fim faz o ultimo

inspecciona_grupo_nrs(Puz,Posicoes,N_Puz,[H_N|T_N]):-
        inspecciona_num(Posicoes,Puz,H_N,Puz_Changed),%manda o 1 nr
        inspecciona_grupo_nrs(Puz_Changed,Posicoes,N_Puz,T_N).%ve o proximo

%inspecciona(Puz,N_Puz) inspecciona cada um dos grupos do puzzle Puz, para cada
%um dos números possíveis, sendo o resultado o puzzle N_Puz

inspecciona(Puz,N_Puz):-
        grupos(Gr),%arranja o grupo
        percorre_muda_Puz(Puz,inspecciona_grupo,Gr,N_Puz).%percorre cada um dos grupos para o inspeciona grupo

%grupo_correcto(Puz,Nums,Gr), em que Puz é um puzzle, significa que o grupo de
%Puz cujas posições são as da lista Gr está correcto, isto é, que contém todos os números
%da lista Nums, sem repetições.

grupo_correcto(Puz,Nums,Gr):-
        conteudos_posicoes(Puz,Gr,Conteudos),%vamos buscar os elementos no sudoku das posicoes
        flatten(Conteudos,Cont_Flat),%tiramos a lista de listas e metemos os numeros das posicoes numa unica lista
        grupo_correcto_aux(Nums,Cont_Flat).%chama a funcao auxliar com os nrs das posicoes



        
grupo_correcto_aux([],[]):-!.%se chegou ao fim acaba,a Lista Nums tb tem de ser vazia

grupo_correcto_aux(Nums,[H_Cont|T_Cont]):-
        member(H_Cont,Nums),!,%se o numero estiver nos numeros possiveis, nao procura nos outros elementos
        delete(Nums,H_Cont,Nums1),%e apaga esse nr da lista de Nums, de modo a q nao possam existir 2 nrs repetidos
        grupo_correcto_aux(Nums1,T_Cont).%Ve o Prox


%solucao(Puz) significa que o puzzle Puz é uma solução, isto é, que todos os seus grupos
%contêm todos os números possíveis, sem repetições.

solucao(Puz):-
        numeros(N),%arranjamos os numeros possiveis no puzzle
        grupos(Gr),%arranjamos os grupos do puzzle
        solucao_aux(Puz,N,Gr).%vamos varrer cada um dos grupos para o grupo correcto

solucao_aux(_,_,[]):-!.%se chagamos ao fim acaba

solucao_aux(Puz,N,[H_Gr|T_Gr]):-
        grupo_correcto(Puz,N,H_Gr),%ve o grupo
        solucao_aux(Puz,N,T_Gr).%chama o proximo grupo


%resolve(Puz,Sol) significa que o puzzle Sol é (um)a solução do puzzle Puz. Na
%obtenção da solução, deve ser utilizado o algoritmo apresentado na Secção 1: inicializar
%o puzzle, inspeccionar linhas, colunas e blocos, e só então procurar uma solução, tal como
%descrito na Secção 1.4.

resolve(Puz,Sol):-
        inicializa(Puz,Puz_Init),%comecamos por inicializar o puzzle
        resolve_inspeciona(Puz_Init,Puz_Insp),%depois inspecionamos ate nao ser possivel mais
        todas_posicoes(Todas_Posicoes),%vamos buscar todas as posicoes possiveis no sudoku
        resolve_n_unitarios(Puz_Insp,Todas_Posicoes,Sol),%se ainda existiram nao unitarios, vamos tentar substituir por 1 das poss
        solucao(Sol).%ve se e solucao

%%
resolve_n_unitarios(Puz_Insp,[],Puz_Insp):-!.%se chegamos ao fim devolve a lista

resolve_n_unitarios(Puz_Insp,[H_Posicao|_],Sol):-
        puzzle_ref(Puz_Insp, H_Posicao, Cont),%vai buscar o quadrado do sudoku
        \+ e_lista_unitario(Cont),!,%se nao for unitario, nao ve a funcao seguinte
        resolve_n_unitarios_nr(Puz_Insp,H_Posicao,Cont,Sol),!.%e vamos tentar escolher um dos numeros das possibilidades,
        % e se a funcao retornar nao vericamos mais

resolve_n_unitarios(Puz_Insp,[_|T_Posicao],Sol):-
        %caso e unitario
        resolve_n_unitarios(Puz_Insp,T_Posicao,Sol).%ve o seguinte

%%

resolve_n_unitarios_nr(_,_,[],_):-!,false.%se chegamos ao fim devolve falso.

resolve_n_unitarios_nr(Puz,Pos,[H_Cont|_],Sol):-
        puzzle_muda_propaga(Puz,Pos,[H_Cont],Puz_Propaga),%vamos tentar escolher o primeiro, propagar a mudanca
        resolve_inspeciona(Puz_Propaga,Puz_Inspecionado),%depois inspecionamos ate nao ser possivel mais
        todas_posicoes(Todas_Posicoes),%vamos buscar todas as posicoes
        resolve_n_unitarios(Puz_Inspecionado,Todas_Posicoes,Sol),%e vamos ver se existem mais nao unitarios
        solucao(Sol),!.%se chegamos a uma solucao, retorna o valor e bloqueia o ramo

resolve_n_unitarios_nr(Puz,Pos,[_|T_Cont],Sol):-%caso contrario
        resolve_n_unitarios_nr(Puz,Pos,T_Cont,Sol).%tenta o proximo

%%%
resolve_inspeciona(Puz_Init,Puz_Insp):-
        inspecciona(Puz_Init,Puz_Insp),%inspecciona
        Puz_Init == Puz_Insp,!.%se os puzzles sao iguais, retorna o valor e pk ja inspecionou tudo, e bloqueia o ramo


resolve_inspeciona(Puz_Init,N_Puz):-
        inspecciona(Puz_Init,Puz_Insp),%inspecciona, se os puzzles sao differentes
        resolve_inspeciona(Puz_Insp,N_Puz).%chama mais uma vez
