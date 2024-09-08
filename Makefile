DOCKER_IMG_NAME=zephyr-project
ZEPHYR_ROOT=/opt/zephyrproject
APP_PATH=${ZEPHYR_ROOT}/zephyr/workshop

run-docker-container:
	docker container run --rm -it --privileged -v ${PWD}:${APP_PATH} -w ${APP_PATH} ${DOCKER_IMG_NAME} bash

build-docker-image:
	docker build -t ${DOCKER_IMG_NAME} --progress tty .
