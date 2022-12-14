ARG VERSION

FROM archlinux/archlinux
LABEL MAINTAINER="Gunnm92"

ENV noVNC_version=1.2.0
ENV websockify_version=0.9.0

# Local debug
# COPY ./mirrorlist /etc/pacman.d/mirrorlist 
# COPY ./websockify-${websockify_version}.tar.gz /websockify.tar.gz
# COPY ./noVNC-${noVNC_version}.tar.gz /noVNC.tar.gz

# Update package repos
RUN \
    echo "**** Update package manager ****" \
        && sed -i 's/^NoProgressBar/#NoProgressBar/g' /etc/pacman.conf \
        && echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf \
    && \
    echo

# Update locale
RUN \
    echo "**** Configure locals ****" \
        && echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen \
        && locale-gen \
    && \
    echo
ENV \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:fr \
    LC_ALL=en_US.UTF-8

# Re-install certificates
RUN \
    echo "**** Install certificates ****" \
	    && pacman -Syu --noconfirm --needed \
            ca-certificates \
    && \
    echo "**** Section cleanup ****" \
	    && pacman -Scc --noconfirm \
    && \
    echo

# Install core packages
RUN \
    echo "**** Install tools ****" \
	    && pacman -Syu --noconfirm --needed \
            bash \
            bash-completion \
            curl \
            git \
            less \
            man-db \
            nano \
            inetutils \
            pkg-config \
            rsync \
            screen \
            sudo \
            unzip \
            vim \
            wget \
            xz \
            tigervnc 

RUN \
    echo "**** Install python ****" \
	    && pacman -Syu --noconfirm --needed \
            python \
            python-numpy \
            python-pip \
            python-setuptools \
    && \
    echo "**** Section cleanup ****" \
	    && pacman -Scc --noconfirm \
    && \
    echo

# Install supervisor
RUN \
    echo "**** Install supervisor ****" \
	    && pacman -Syu --noconfirm --needed \
            supervisor \
    && \
    echo "**** Section cleanup ****" \
	    && pacman -Scc --noconfirm \
    && \
    echo

# Install X Server requirements
RUN \
    echo "**** Install X Server requirements ****" \
	    && pacman -Syu --noconfirm --needed \
            xorg-server \
    && \
    echo "**** Section cleanup ****" \
	    && pacman -Scc --noconfirm \
    && \
    echo

# Install audio requirements
RUN \
    echo "**** Install audio requirements ****" \
	    && pacman -Syu --noconfirm --needed \
            pulseaudio \
    && \
    echo "**** Section cleanup ****" \
	    && pacman -Scc --noconfirm \
    && \
    echo

# # Install Steam
# RUN \
#     echo "**** Install steam ****" \
# 	    && pacman -Syu --noconfirm --needed \
#             lib32-vulkan-icd-loader
#             steam \
#             vulkan-icd-loader \
#     && \
#     echo "**** Section cleanup ****" \
# 	    && pacman -Scc --noconfirm \
#     && \
#     echo

    
# Install desktop environment
RUN \
     echo "**** Install desktop environment ****" \
 	    && pacman -Syu --noconfirm --needed \
             kde-system-meta \
             konsole \
             plasma-desktop \
     && \
     echo "**** Section cleanup ****" \
 	    && pacman -Scc --noconfirm \
     && \
     echo

# Install Chromium
RUN \
    echo "**** Install Chromium ****" \
	    && pacman -Syu --noconfirm --needed \
            chromium \
    && \
    echo "**** Section cleanup ****" \
	    && pacman -Scc --noconfirm \
    && \
    echo

# TODO Append to tools
#RUN \
#    echo "**** Install flatpak support ****" \
#	    && pacman -Syu --noconfirm --needed \
#            patch \
#    && \
#    echo "**** Section cleanup ****" \
#	    && pacman -Scc --noconfirm \
#    && \
#    echo

# Install noVNC
RUN	wget https://github.com/novnc/websockify/archive/v${websockify_version}.tar.gz -O /websockify.tar.gz \
	&& tar -xvf /websockify.tar.gz -C / \
	&& cd /websockify-${websockify_version} \
	&& python setup.py install \
	&& cd / && rm -r /websockify.tar.gz /websockify-${websockify_version} \
	&& wget https://github.com/novnc/noVNC/archive/v${noVNC_version}.tar.gz -O /noVNC.tar.gz \
	&& tar -xvf /noVNC.tar.gz -C / \
	&& cd /noVNC-${noVNC_version} \
	&& ln -s vnc.html index.html \
	&& rm /noVNC.tar.gz

# Configure default user and set env
ENV \
    USER="default" \
    USER_PASSWORD="password" \
    USER_HOME="/home/default" \
    TZ="Pacific/Auckland" \
    USER_LOCALES="en_US.UTF-8 UTF-8"

RUN \
    echo "**** Configure default user '${USER}' ****" \
        && mkdir -p \
            ${USER_HOME} \
        && useradd -d ${USER_HOME} -s /bin/bash ${USER} \
        && chown -R ${USER} \
            ${USER_HOME} \
        && echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Add FS overlay
COPY ./config/xstartup /root/.vnc/
COPY ./start.sh /
COPY overlay /

# Set display environment variables
ENV \
    DISPLAY_CDEPTH="24" \
    DISPLAY_DPI="96" \
    DISPLAY_REFRESH="60" \
    DISPLAY_SIZEH="800" \
    DISPLAY_SIZEW="1280" \
    DISPLAY_VIDEO_PORT="DFP" \
    DISPLAY=":55" \
    NVIDIA_DRIVER_CAPABILITIES="all" \
    NVIDIA_VISIBLE_DEVICES="all"

# Set container configuration environment variables
ENV \
    MODE="primary" \
    ENABLE_VNC_AUDIO="false" \
    WEB_UI_MODE="vnc"

# Configure required ports
ENV \
    PORT_NOVNC_WEB="6080"

# Expose the required ports
EXPOSE 5900 6080

# Set entrypoint
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

#RUN chmod +x start.sh

#WORKDIR /root

#ENTRYPOINT [ "/start.sh" ]