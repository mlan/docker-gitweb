FROM 	alpine

LABEL 	maintainer=mlan

# Install gitweb
RUN	apk --no-cache --update add \
	git-gitweb \
	lighttpd

EXPOSE	1234

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/libexec/git-core

WORKDIR /root

RUN	\
	echo testing > test.txt &&\
	git config --global user.email "you@example.com" &&\
	git config --global user.name "Your Name" &&\
	git init &&\
	git add . &&\
	git commit -a -m test

CMD	["git-instaweb"]
