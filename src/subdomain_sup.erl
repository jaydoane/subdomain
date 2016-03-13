%%%-------------------------------------------------------------------
%% @doc subdomain top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module('subdomain_sup').

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    {ok, { {one_for_one, 0, 1}, [
        {
            nitrogen_sup,
            {nitrogen_sup, start_link, []},
            permanent,
            infinity,
            supervisor,
            [nitrogen_sup]
        },
        {
            tcp_server_app,
            {tcp_server_app, start, [ignore, ignore]},
            permanent,
            infinity,
            supervisor,
            [tcp_server_app]
        }
    ]}}.

%%====================================================================
%% Internal functions
%%====================================================================
