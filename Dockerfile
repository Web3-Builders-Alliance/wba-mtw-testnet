# docker build . -t wba-chain:latest
# docker run --rm -it wba-chain /bin/sh

FROM archlinux

# install packages
RUN pacman -Sy --noconfirm go 
RUN pacman -Sy --noconfirm archlinux-keyring 
RUN pacman -Sy --noconfirm make gcc base jq git

# set working directory
WORKDIR /app

# copy the current directory contents into the container at /usr/src/app
COPY . .

ENV PATH "$PATH:/root/go/bin"

EXPOSE 26656 26657 1317 9090

RUN make install

# TODO: future do this, but fix wasmvm issue qwith libwasmvm.so
# FROM golang:1.18-alpine3.16 AS go-builder

# RUN set -eux

# RUN apk add --no-cache ca-certificates git build-base linux-headers

# WORKDIR /code
# COPY . /code/

# # See https://github.com/CosmWasm/wasmvm/releases
# ADD https://github.com/CosmWasm/wasmvm/releases/download/v1.0.0/libwasmvm_muslc.aarch64.a /lib/libwasmvm_muslc.aarch64.a
# ADD https://github.com/CosmWasm/wasmvm/releases/download/v1.0.0/libwasmvm_muslc.x86_64.a /lib/libwasmvm_muslc.x86_64.a
# RUN sha256sum /lib/libwasmvm_muslc.aarch64.a | grep 7d2239e9f25e96d0d4daba982ce92367aacf0cbd95d2facb8442268f2b1cc1fc
# RUN sha256sum /lib/libwasmvm_muslc.x86_64.a | grep f6282df732a13dec836cda1f399dd874b1e3163504dbd9607c6af915b2740479
# # Copy the library you want to the final location that will be found by the linker flag `-lwasmvm_muslc`
# RUN cp "/lib/libwasmvm_muslc.$(uname -m).a" /lib/libwasmvm_muslc.a

# # Install WBAd binary
# RUN echo "Installing WBA binary"
# RUN make build

# #-------------------------------------------
# FROM golang:1.18-alpine3.16

# RUN apk add --no-cache bash py3-pip jq curl
# RUN pip install toml-cli

# WORKDIR /

# COPY --from=go-builder /code/bin/wbad /usr/bin/wbad
# COPY --from=go-builder /code/bin/wbad /


# # rest server
# EXPOSE 1317
# # tendermint rpc
# EXPOSE 26657
# # p2p address
# EXPOSE 26656
# # gRPC address
# EXPOSE 9090

# # wrong ENTRYPOINT can lead to executable not running
# ENTRYPOINT ["/bin/bash", "-c"]