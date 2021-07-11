Definitions.

Digit = [0-9]
HexDigit = [0-9a-fA-F]
Float = (\+|-)?{Digit}+\.?{Digit}+?((E|e)(\+|-)?{Digit}+)?
FloatNoLeadingZero = (\+|-)?\.{Digit}+((E|e)(\+|-)?{Digit}+)?
HexDigits = 0(x|X){HexDigit}+
DoubleQuoteString     = "(\\\^.|\\.|[^\"])*"
SingleQuoteString     = '(\\\^.|\\.|[^\'])*'
Key  = [a-zA-Z\_\$](\\\^.|\\.|[a-zA-Z0-9\_\$])*

Rules.

{Digit}+ : {token,{number,TokenLine,TokenChars}}.

{Float} :  {token, {number, TokenLine, TokenChars}}.
{FloatNoLeadingZero} :  {token, {number, TokenLine, TokenChars}}.
{HexDigits} : {token, {hex_number, TokenLine, parse_hex(TokenChars)}}.

null : {token, {null, TokenLine, nil}}.
true : {token, {boolean, TokenLine, true}}.
false : {token, {boolean, TokenLine, false}}.

{DoubleQuoteString} : {token, {string, TokenLine, strip_quotes(TokenChars)}}.
{SingleQuoteString} : {token, {string, TokenLine, strip_quotes(TokenChars)}}.
{Key}               : {token, {key, TokenLine, TokenChars}}.

\[ : {token, {open_list, TokenLine}}.
\] : {token, {close_list, TokenLine}}.
\{ : {token, {open_map, TokenLine}}.
\} : {token, {close_map, TokenLine}}.
\, : {token, {sep, TokenLine}}.
\: : {token, {key_value_sep, TokenLine}}.

%% white space
[\s\n\r\t]+           : skip_token.
%% line comment
//[^\n]*               : skip_token.
%% multiline comment
/\*[^(*/)]*\*/         : skip_token.

Erlang code.

strip_quotes(Str) ->
    tl(lists:droplast(Str)).

parse_hex(Str) ->
    list_to_integer(tl(tl(Str)), 16).
