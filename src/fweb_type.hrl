
-type handler() :: {atom(), atom()}.
-type method() :: get | post | delete | put.
-record(handler, {name::atom(), mapping::atom()}).

-type interceptor() :: {atom(), atom()}.
-record(interceptor, {name::atom(), path::atom()}).

-type cache() :: {term(), term()}.
-record(cache, {k, v}).