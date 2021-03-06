-define(sm, service_manager).
-record(sm_started, {pid, name, state}).
-record(sm_stopped, {event, reason, from}).
-record(sm_register_provider, {provider_name, pid}).
-record(sm_state, {pid, name, state}).
-record(sm_received_msg, {msg}).
