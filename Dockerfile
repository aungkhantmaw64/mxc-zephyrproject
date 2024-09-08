FROM debian:bookworm-slim

RUN apt-get update --fix-missing && apt-get install -y --no-install-recommends git cmake \
    ninja-build gperf ccache dfu-util device-tree-compiler wget \
    python3-dev python3-pip python3-setuptools python3-tk python3-wheel python3-venv \
    xz-utils file make gcc gcc-multilib g++-multilib libsdl2-dev libmagic1 minicom xxd usbutils

ENV ZEPHYR_ROOT=/opt/zephyrproject
ENV APP_PATH=${ZEPHYR_ROOT}/zephyr/apps

RUN python3 -m venv ${ZEPHYR_ROOT}/.venv && \
    . ${ZEPHYR_ROOT}/.venv/bin/activate && \
    pip install west && \
    west init ${ZEPHYR_ROOT} && \
    cd ${ZEPHYR_ROOT} && west update && west zephyr-export && \
    pip install -r ${ZEPHYR_ROOT}/zephyr/scripts/requirements.txt

RUN wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.5/zephyr-sdk-0.16.5_linux-x86_64.tar.xz

RUN wget -O - https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.5/sha256.sum | shasum --check --ignore-missing && \
    tar -xvf zephyr-sdk-0.16.5_linux-x86_64.tar.xz && rm -rf zephyr-sdk-0.16.5_linux-x86_64.tar.xz

RUN cd zephyr-sdk-0.16.5 && yes | ./setup.sh

RUN wget https://github.com/NordicSemiconductor/nrf-udev/releases/download/v1.0.1/nrf-udev_1.0.1-all.deb

RUN apt-get install -y udev && dpkg -i nrf-udev_1.0.1-all.deb

RUN wget https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/desktop-software/nrf-command-line-tools/sw/versions-10-x-x/10-24-2/nrf-command-line-tools_10.24.2_amd64.deb

RUN /lib/systemd/systemd-udevd --daemon && dpkg -i nrf-command-line-tools_10.24.2_amd64.deb && \
    apt install -y /opt/nrf-command-line-tools/share/JLink_Linux_V794e_x86_64.deb --fix-broken

WORKDIR ${APP_PATH}

COPY ./entrypoint.sh .

RUN chmod +x ./entrypoint.sh

ENTRYPOINT [ "./entrypoint.sh" ]
