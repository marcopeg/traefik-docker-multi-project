start: start-proxy start-project1 start-project2
stop: stop-project1 stop-project2 stop-proxy 

start-project1:
	(cd ./project1 && docker-compose up -d)

stop-project1:
	(cd ./project1 && docker-compose down)

start-project2:
	(cd ./project2 && docker-compose up -d)

stop-project2:
	(cd ./project2 && docker-compose down)

start-proxy:
	(cd ./proxy && docker-compose up -d)

stop-proxy:
	(cd ./proxy && docker-compose down)