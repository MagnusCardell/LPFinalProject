
:- use_module(library(socket)).

server :-
  server(1025).

server(PortNumber) :-
  setup_call_cleanup(tcp_socket(S), (true; fail), tcp_close_socket(S)),
  tcp_bind(S, PortNumber),
  tcp_listen(S, 5),
  server_loop(S).

server_loop(S) :-
  tcp_accept(S, S1, From),
  writeln(From),
  setup_call_cleanup(tcp_open_socket(S1, In, Out), 
    server_operation(In, Out, From, S1),
    (writeln('closing...'),
    close(In),
    close(Out))), !,
  server_loop(S).

server_operation(_In, _Out, From, S1).
server_operation(In, Out, From, S1) :-
  \+at_end_of_stream(In),
  read_pending_input(In, Codes, []),  %RECEIVING INPUT HERE
  in_and_out_format(Codes, Result, From, S1),   %external
  format(Out, "~s", [Result]),
  flush_output(Out),
  server_operation(In, Out, From, S1).

send(From, S, Message) :-
  udp_socket(S),
  udp_send(S, Message, Host:Port, []),
  tcp_close_socket(S).