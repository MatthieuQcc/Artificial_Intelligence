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

%*******************************************************************************

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
	insert([[F0, H0, G0], S0], Pf),
	insert([S0, [F0, H0, G0], nil, nil], Pu),
	
	% lancement de Aetoile

	aetoile(Pf,Pu,Q).

%*******************************************************************************

aetoile(nil,nil,_) :-
	writeln('PAS de SOLUTION : L’ETAT FINAL N’EST PAS ATTEIGNABLE !').

aetoile(Pf, Ps, Qs) :-
	final_state(Fin),
	suppress_min(Fin,Pf,_),
	insert([Fin, _, nil, nil],Qs,Qn),
	affiche_solution(Ps,Qn).

aetoile(Pf, Ps, Qs) :-
	true.   %********
			% A FAIRE
			%********	

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

	
   