%*******************************************************************************
%                                    AETOILE
%*******************************************************************************

/*
Rappels sur l'algorithme
 
- structures de donnees principales = 2 ensembles : P (etat pendants) et Q (etats clos)
- P est dedouble en 2 arbres binaires de recherche equilibres (AVL) : Pf et Pu
 
   Pf est l'ensemble des etats pendants (pending states), ordonnes selon
   f croissante (h croissante en cas d'egalite de f). Il permet de trouver
   rapidement le prochain etat a developper (celui qui a f(U) minimum).
   
   Pu est le meme ensemble mais ordonne lexicographiquement (selon la donnee de
   l'etat). Il permet de retrouver facilement n'importe quel etat pendant

   On gere les 2 ensembles de fa�on synchronisee : chaque fois qu'on modifie
   (ajout ou retrait d'un etat dans Pf) on fait la meme chose dans Pu.

   Q est l'ensemble des etats deja developpes. Comme Pu, il permet de retrouver
   facilement un etat par la donnee de sa situation.
   Q est modelise par un seul arbre binaire de recherche equilibre.

Predicat principal de l'algorithme :

   aetoile(Pf,Pu,Q)

   - reussit si Pf est vide ou bien contient un etat minimum terminal
   - sinon on prend un etat minimum U, on genere chaque successeur S et les valeurs g(S) et h(S)
	 et pour chacun
		si S appartient a Q, on l'oublie
		si S appartient a Ps (etat deja rencontre), on compare
			g(S)+h(S) avec la valeur deja calculee pour f(S)
			si g(S)+h(S) < f(S) on reclasse S dans Pf avec les nouvelles valeurs
				g et f 
			sinon on ne touche pas a Pf
		si S est entierement nouveau on l'insere dans Pf et dans Ps
	- appelle recursivement etoile avec les nouvelles valeurs NewPF, NewPs, NewQs

*/

%*******************************************************************************

:- ['avl.pl'].       % predicats pour gerer des arbres bin. de recherche   
:- ['taquin.pl'].    % predicats definissant le systeme a etudier

%*******pendants*************************************************************

main :-
	% initialisations Pf, Pu et Q 
	initial_state(S0),
	G0 is 0, 
	heuristique(S0,H0),
	F0 is H0 + G0,

	%Creation des differents AVL
	empty(Pf),
	empty(Pu),
	empty(Q),

	%Insertion des differents noeuds
	insert([[F0, H0, G0], S0], Pf, New_Pf),
	insert([S0, [F0, H0, G0], nil, nil], Pu, New_Pu),

	% lancement de Aetoile
	aetoile(New_Pf,New_Pu,Q).

%*******************************************************************************

aetoile(nil,nil,_) :-
	writeln('PAS de SOLUTION : L’ETAT FINAL N’EST PAS ATTEIGNABLE !'),!.

aetoile(Pf, _, Q) :-
	final_state(Fin),
	suppress_min([_, Fin],Pf,_),
	insert([Fin, _, nil, nil],Q,Qn),
	affiche_solution(Fin,Qn),!.

aetoile(Pf, Pu, Q) :-
	nl,print('New aetoile'),nl,
	print('Pf = '),put_flat(Pf),nl,
	print('Pu = '),put_flat(Pu),nl,
	print('Q = '),put_flat(Q),nl,
	% on enlève le nœud de Pf correspondant à l’état U à développer 
	suppress_min([[_,_,G], U],Pf,Pf2),
	%on enlève aussi le nœud frère associé dans Pu
	suppress([U,Cout_U,Pere,A_U],Pu,Pu2),
	print('U = '),print(U),
	insert([U,Cout_U,Pere,A_U], Q, New_Q),
	%développement de U
	expand(S, U, Cout_S, G, A_S),
	% traiter chaque nœud successeur
	print('loop_successor('),print(S),print(') : '),
	loop_successors(S, Q, Pf2, Pu2, New_Pf, New_Pu, U, Cout_S, A_S),
	% U ayant été développé et supprimé de P, il reste à l’insérer le nœud [U,Val,...,..] dans Q
	nl,print('New_Q = '),put_flat(New_Q),nl,
	% Appeler récursivement aetoile avec les nouveaux ensembles Pf_new, Pu_new et Q_new
	aetoile(New_Pf, New_Pu, New_Q).

affiche_solution(S,Q) :-
	print('Solution trouvee! \n'),
	print(S),
	affiche_parents(S,Q).

%cherche les peres recursivement sur Q et les affiche
affiche_parents(S,Q) :-
	belongs([S, _, Pere, Mouv], Q),
	print(Mouv),
	print(Pere),
	affiche_parents(Pere,Q).

	
expand(S, U, [Fs, Hs, Gs], Gu, A) :-
	next_moves(U ,L),
	% déterminer tous les nœuds contenant un état successeur S de la situation U et calculer leur évaluation [Fs, Hs, Gs]
	list_member([A, S], L),
	heuristique(S, Hs),
	Gs is Gu + 1,
	Fs is Gs + Hs,
	nl,print('expand : '),print(S),nl.


loop_successors(S, Q, Pf, Pu, New_Pf, New_Pu, _, _, _, _) :-
	% si S est connu dans Q alors oublier cet état
	belongs([S,_,_,_], Q),
	suppress([_,S], Pf, New_Pf),
	suppress([S,_,_,_], Pu, New_Pu),
	print('S belongs to Q'),nl,!.

loop_successors(S, _, Pf, Pu, New_Pf, New_Pu, U, [Fs,_,_], A) :-
	% si S est connu dans Pu alors garder le terme associé à la meilleure évaluation
	belongs([S,[Fconnu,_,_],_,_], Pu),
	Fconnu > Fs,
	% remplacement du terme
	suppress([_,S], Pf, Temp_Pf),
	suppress([S,_,_,_], Pu, Temp_Pu),
	insert([S,[Fs,_,_],U,A], Temp_Pu, New_Pu),
	insert([[Fs,_,_], U], Temp_Pf, New_Pf),
	print('S belongs to Pu'),nl,!.

loop_successors(S, _, Pf, Pu, New_Pf, New_Pu, U, Cout, A) :-
	% sinon (S est une situation nouvelle) il faut créer un nouveau terme à insérer dans Pu
	insert([S,Cout,U,A], Pu, New_Pu),
	insert([Cout, S], Pf, New_Pf),
	print('insert S to Pu/Pf'),nl.

list_member(X,[X|_]).
list_member(X,[_|TAIL]) :- list_member(X,TAIL).