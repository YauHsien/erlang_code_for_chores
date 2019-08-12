-module(permutations).
-compile(export_all).
-export([all_permutations/1,
	 next_permutation/1,
	 next_permutation/2,
	 next_permutations/3,
	 print_permutations/1]).

%% The following implentation will cause eheap_alloc when the length
%% of the input list is long.
-spec all_permutations([any()]) -> [list()].
all_permutations(List) ->
    List_ = lists:reverse(List),
    lists:foldl(
        fun(A, C) ->
	       all_insertion_cases(C, A)
	end,
	[],
	List_
    ).

-spec all_insertion_cases([list()], any()) -> [list()].
all_insertion_cases([], Term) ->
    [[Term]];
all_insertion_cases(List, Term) ->
    lists:append(
        lists:map(
	    fun(List_) ->
	        all_insertion_cases_(List_, Term)
	    end,
	    List
	)
    ).

-spec all_insertion_cases_([any()], any()) -> [[any()]].
all_insertion_cases_(List, Term) ->
    L = erlang:length(List),
    lists:foldl(
        fun(A, {0,[{_,_,S}|C]}) ->
	       [[A|S]|C];
	   (A, {N,[{P,_,S}|C_]}) ->
	       [H|P_] = lists:reverse(P),
	       {N-1, [{lists:reverse(P_),A,[H|S]},P++[A|S]|C_]}
	end,
	{L, [{List,Term,[]}]},
	lists:duplicate(L+1, Term)
    ).

next_permutation(List) ->
    {ReversedTrailingSeq, RestReversed} = split(lists:reverse(List), []),
    case RestReversed of
	[] ->
	    eop;
	[H|T] ->
	    NextElm = lists:min(lists:filter(
				  fun(X) -> X > H end,
				  ReversedTrailingSeq)),
	    lists:reverse([NextElm|T])
		++ lists:reverse(lists:filter(
				   fun(X) -> X < H end,
				   ReversedTrailingSeq--[NextElm]))
		++ [H|lists:reverse(lists:filter(
				      fun(X) -> X > H end,
				      ReversedTrailingSeq--[NextElm]))]
	end.

next_permutation(_, eop) -> eop;
next_permutation(0, List) -> List;
next_permutation(N, List) when N > 0 ->
    next_permutation(N-1, next_permutation(List)). 

next_permutations(0, _List, Acc) ->
    lists:reverse(Acc);
next_permutations(N, List, Acc) when N > 0 ->
    NextPerm = next_permutation(List),
    next_permutations(N-1, NextPerm, [NextPerm|Acc]).

print_permutations(eop) ->
    ok;
print_permutations(List) ->
    io:fwrite("~p~n", [List]),
    print_permutations(next_permutation(List)).

%% My Splitting Function:
%% - Take ascending leading sequence of a list, until the first non-ascending
%%   element met.
%% - After splitting it returns a pair of lists, where the leading sequence,
%%   put at the first place of the pair, is in reversed form.
split([], Acc) -> {Acc, []};
split([_]=List, []=_Acc) -> {[], List};
split([X|_]=List, [Y|_]=Acc) when X =< Y -> {Acc, List};
split([X|List], Acc) -> split(List, [X|Acc]).
