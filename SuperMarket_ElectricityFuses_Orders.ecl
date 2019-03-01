%%% Loading libraries 
:-use_module(library(ic)).
:-use_module(library(ic_global)).
:-use_module(library(ic_edge_finder)). 
:-use_module(library(branch_and_bound)). 
:-lib(ic_global).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Exec1

products([123,782,133,431,521,622,712,228,1229,1120,3111,812,913,5614,
3215]).
categories([2,1,2,3,2,4,5,6,5,7,7,2,4,6,7]).
price([10,10,20,15,20,10,30,40,20,25,13,14,18,20]).



super(P, Cost, LIST):-
	categories(C),
	setof(X,member(X, C),LIST),
	constrain_providers(P,Price,LIST),
	sumlist(Price,Cost),
	bb_min(labeling(Price),Cost,bb_options{strategy:restart}).

constrain_providers([],[],[]).
constrain_providers([PRODUCT|Rest],[PRICE|Costs],[VALUE|LIST]):-
	products(P),
	categories(C),
	price(PR),
	element(I,C,VALUE), %%
	element(I,P,PRODUCT),
	element(I,PR,PRICE),
	constrain_providers(Rest,Costs,LIST).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Exec2

plan_my_day(Time):-
	[Sa,Sb,Sbb,Sc,Scc,Sd]#:: 0 ..inf,
	Sa + 4#=Ea,
	Sb + 1#=Eb,
	Sbb+ 1#=Ebb,
	Sc + 1#=Ec,
	Scc+ 2#=Ecc,
	Sd + 3#=Ed,
	Sbb-Sb#=1,
	Scc#>=Sc+1,
	disjunctive([Sa,Sbb,Sc],[4,1,1]),
	cumulative([Sa,Sb,Scc,Sd],[4,1,2,3],[1000,3500,2000,2500],4500),
	ic_global:maxlist([Ea,Eb,Ebb,Ec,Ecc,Ed],Time),
	bb_min(labeling([Sa,Sb,Sbb,Sc,Scc,Sd]),Time,bb_options{strategy:restart}).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Exec3

order(product(a),24).
order(product(b),16).
order(product(c),19).
order(product(d),22).

workload(product(a),8,3).
workload(product(b),9,5).
workload(product(c),9,3).
workload(product(d),8,4).


times([],[],[],[]).

times([S|Starts],[Sp|Dates],[E|Ends],[Tsum|SUM]):-
	S + Sp #< E,
	Tsum #= E-(S),
	times(Starts,Dates,Ends,SUM).

my_workplan(W,Min):-
	findall(P,workload(P,_,_),Product),
	findall(T,workload(_,T,_),Dates),
	findall(H,workload(_,_,H),Hours),
	findall(D,order(_,D),Deadlines),
	length(Product,N),
	length(S,N), %% My vars
	S #:: [1..31],
	times(S,Dates,Deadlines,SUM),
	cumulative(S,Dates,Hours,8),
	sumlist(SUM,Time),
	bb_min(labeling(S),Time,bb_options{strategy:restart}),
	list_min(S,Min),
	convert(Product,S,W).

convert([],[],[]).

convert([H1|T1],[H2|T2],[start(H1,H2)|T3]):-
	convert(T1,T2,T3).



list_min(LIST,Min):-
	member(Min,LIST),
	not((member(X,LIST),X<Min)).
	

