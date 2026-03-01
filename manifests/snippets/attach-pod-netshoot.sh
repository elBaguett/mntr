kubectl debug -it smtp-b467d7b68-ntksh -n mntr --image=nicolaka/netshoot --target smtp
# или если нет debug, временно добавь в deployment ещё один контейнер с shell'ем