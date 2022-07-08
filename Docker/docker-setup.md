## Running

1. set xhost so that the docker container can connect to X Window Server

        $ xhost +local:root

2. Run nvidia-docker with appropriate command line parameters

        $ docker run --rm --gpus all -e QT_X11_NO_MITSHM=1 -e DISPLAY=$DISPLAY -e NVIDIA_DRIVER_CAPABILITIES=all -v /tmp/.X11-unix:/tmp/.X11-unix:rw -it nvidia/cuda:11.0-base

To mount a directory to docker pass in the environment variable below

        docker run -v /host/directory:/container/directory