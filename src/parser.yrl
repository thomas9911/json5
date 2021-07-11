Nonterminals term factor seq_items key_value_items key_index key_value.
Terminals number hex_number open_list close_list open_map close_map null boolean string key sep key_value_sep.
Rootsymbol term.

term -> factor : '$1'.

factor -> open_list close_list : {list, line('$1'), []}.
factor -> open_list seq_items close_list : {list, line('$1'), '$2'}.
factor -> open_map close_map : {map, line('$1'), []}.
factor -> open_map key_value_items close_map : {map, line('$1'), '$2'}.

factor -> number : '$1'.
factor -> string : '$1'.
factor -> null : '$1'.
factor -> boolean : '$1'.
factor -> hex_number: '$1'.

seq_items -> term : ['$1'].
seq_items -> term sep : ['$1'].
seq_items -> term sep seq_items : ['$1'|'$3'].
key_value_items -> key_value : ['$1'].
key_value_items -> key_value sep : ['$1'].
key_value_items -> key_value sep key_value_items : ['$1'|'$3'].
key_value -> key_index key_value_sep term : {'$1', '$3'}.

key_index -> key : '$1'.
key_index -> string : '$1'.

Erlang code.

line(T) when is_tuple(T) -> element(2, T);
line([H|_T]) -> element(2, H);
line(T) -> ct:print("WAT ~p", [T]).
