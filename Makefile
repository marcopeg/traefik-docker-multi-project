start: start-traefik start-project1 start-project2
stop: stop-project1 stop-project2 stop-traefik 
restart: stop start

start-project1:
	(cd ./project1 && docker-compose up -d)

stop-project1:
	(cd ./project1 && docker-compose down)

start-project2:
	(cd ./project2 && docker-compose up -d)

stop-project2:
	(cd ./project2 && docker-compose down)

start-traefik:
	(cd ./traefik && docker-compose up -d)

stop-traefik:
	(cd ./traefik && docker-compose down)