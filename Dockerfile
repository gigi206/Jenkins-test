FROM debian:jessie
MAINTAINER Ghislain LE MEUR <my.email@gmail.com>
RUN apt-get update && \
	apt-get -yq install libx11-6 libxt6 libice6 libsm6 libglib2.0-0 libglib2.0-0 libpango-1.0-0 libglib2.0-0 libgdk-pixbuf2.0-0 libgtk2.0-0 libgtk2.0-0 liblua5.1-0
ADD vim.tgz /usr/local/
