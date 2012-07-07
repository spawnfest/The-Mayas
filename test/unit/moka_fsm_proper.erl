%%% @doc fsm test for moka

-module(moka_fsm_proper).

-behaviour(proper_fsm).

-define(PROPER_NO_IMPORTS, true).
-include_lib("proper/include/proper.hrl").

-record(state, {
          moka :: moka:moka()
         }).

%%% FSM Callbacks
-export([initial_state/0, initial_state_data/0, weight/3, precondition/4,
         postcondition/5, next_state_data/5]).

%%% properties
-export([prop_moka_fsm/0]).

%%% FSM States
-export([new/1, defined/1]).

%%% Transitions
-export([]).

%%%===================================================================
%%% FSM Callbacks
%%%===================================================================

initial_state() -> new.

initial_state_data() -> #state{moka = moka:new(origin_module())}.

weight(_,_,_) -> 1.

precondition(_,_,_,_) -> true.


%% Fall through to false to avoid false positives due to matching errors
postcondition(_,_,_,_,_) ->
    false.

next_state_data(_From, _Target, State, _Call, _Res) -> State.

%%%===================================================================
%%% States
%%%===================================================================
new(#state{moka = Moka}) ->
    [{defined, {call, moka, mock, [Moka, dest_module(), funct(), foo]}}].

defined(_) ->
    [{defined, {call, learnerl, get_quiz, []}}].

%%%===================================================================
%%% Generators
%%%===================================================================

funct() ->
    Mod = dest_module(),
    proper_types:elements([Fun || {Fun, _Arity } <- Mod:module_info(exports)]).

%%%===================================================================
%%% Transitions
%%%===================================================================

%%%===================================================================
%%% Properties
%%%===================================================================
prop_moka_fsm() ->
    ?FORALL(
       Cmds, proper_fsm:commands(?MODULE),
       ?TRAPEXIT(
          begin
              Moka = moka:new(to_mock_module),
              {H, S, R} =
                  proper_fsm:run_commands(?MODULE, Cmds, [{moka, Moka}]),

              ?WHENFAIL(report_error(H, S, R), R =:= ok)
          end)).

%%%===================================================================
%%% Auxiliary functions
%%%===================================================================

report_error(H, S, R) ->
    io:format("History: ~p\nState: ~p\nRes: ~p\n",[H,S,R]).

origin_module() -> moka_test_origin_module.

dest_module() -> moka_test_dest_module.