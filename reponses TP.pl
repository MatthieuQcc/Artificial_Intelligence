initial_state([ [b, h, c],       % C'EST L'EXEMPLE PRIS EN COURS
                [a, f, d],       % 
                [g,vide,e] ]).

final_state([[a, b,  c],
             [h,vide, d],
             [g, f,  e]]).

est_bien_place(P) :- initial_state(Grille), nth1(L,Grille,LigneIni), nth1(C,LigneIni,P), final_state(GrilleFin), nth1(L,GrilleFin,Ligne), nth1(C,Ligne,P).

next_moves(G) :- findall([M,N], rule(M,1,G,N), L).

