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
RUN echo "**** Update package manager ****" \
        && sed -i 's/^NoProgressBar/#NoProgressBar/g' /etc/pacman.conf \
        && echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf \
    && \
    echo

# Update locale
RUN echo "**** Configure locals ****" \
        && echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen \
        && locale-gen \
    && \
    echo
ENV \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:fr \
    LC_ALL=en_US.UTF-8

# Re-install certificates
RUN echo "**** Install certificates ****" \
	    && pacman -Syu --noconfirm --needed \
            ca-certificates \
    && \
    echo "**** Section cleanup ****" \
	    && pacman -Scc --noconfirm \
    && \
    echo

# Install core packages
RUN echo "**** Install tools ****" \
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

RUN echo "**** Install python ****" \
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
RUN echo "**** Install supervisor ****" \
	    && pacman -Syu --noconfirm --needed \
            supervisor \
    && \
    echo "**** Section cleanup ****" \
	    && pacman -Scc --noconfirm \
    && \
    echo

# Install mesa requirements
RUN echo "**** Install mesa and vulkan requirements ****" \
	    && pacman -Syu --noconfirm --needed \
            glu \
            libva-mesa-driver \
            mesa-utils \
            mesa-vdpau \
            opencl-mesa \
            pciutils \
            vulkan-mesa-layers \
    && \
    echo "**** Section cleanup ****" \
	    && pacman -Scc --noconfirm \
    && \
    echo

RUN \
    echo "**** Install X Server requirements ****" \
	    && pacman -Syu --noconfirm --needed \
            avahi \
            dbus \
            lib32-fontconfig \
            ttf-liberation \
            x11vnc \
            xorg \
            xorg-apps \
            xorg-font-util \
            xorg-fonts-misc \
            xorg-fonts-type1 \
            xorg-server \
            xorg-server-xephyr \
            xorg-server-xvfb \
            xorg-xauth \
            xorg-xbacklight \
            xorg-xhost \
            xorg-xinit \
            xorg-xinput \
            xorg-xkill \
            xorg-xprop \
            xorg-xrandr \
            xorg-xsetroot \
            xorg-xwininfo \
    && \
    echo "**** Section cleanup ****" \
	    && pacman -Scc --noconfirm \
    && \
    echo

# Install audio requirements
RUN echo "**** Install audio requirements ****" \
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
RUN echo "**** Install desktop environment ****" \
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
RUN echo "**** Install Chromium ****" \
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
ARG NOVNC_VERSION=1.2.0
RUN \
    echo "**** Fetch noVNC ****" \
        && cd /tmp \
        && wget -O /tmp/novnc.tar.gz https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.tar.gz \
    && \
    echo "**** Extract noVNC ****" \
        && cd /tmp \
        && tar -xvf /tmp/novnc.tar.gz \
    && \
    echo "**** Configure noVNC ****" \
        && cd /tmp/noVNC-${NOVNC_VERSION} \
        && sed -i 's/credentials: { password: password } });/credentials: { password: password },\n                           wsProtocols: ["'"binary"'"] });/g' app/ui.js \
        && mkdir -p /opt \
        && rm -rf /opt/noVNC \
        && cd /opt \
        && mv -f /tmp/noVNC-${NOVNC_VERSION} /opt/noVNC \
        && cd /opt/noVNC \
        && ln -s vnc.html index.html \
        && chmod -R 755 /opt/noVNC \
    && \
    echo "**** Modify noVNC title ****" \
        && sed -i '/    document.title =/c\    document.title = "Steam Headless - noVNC";' \
            /opt/noVNC/app/ui.js \
    && \
    echo "**** Section cleanup ****" \
        && rm -rf \
            /tmp/noVNC* \
            /tmp/novnc.tar.gz

# Install Nginx
RUN echo "**** Install Nginx ****" \
	    && pacman -Syu --noconfirm --needed \
            nginx \
    && \
    echo "**** Section cleanup ****" \
	    && pacman -Scc --noconfirm \
    && \
    echo

# Configure default user and set env
ENV \
    USER="default" \
    USER_PASSWORD="password" \
    USER_HOME="/home/default" \
    TZ="Pacific/Auckland" \
    USER_LOCALES="en_US.UTF-8 UTF-8"

RUN echo "**** Configure default user '${USER}' ****" \
        && mkdir -p \
            ${USER_HOME} \
        && useradd -d ${USER_HOME} -s /bin/bash ${USER} \
        && chown -R ${USER} \
            ${USER_HOME} \
        && echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Add FS overlay
COPY ./config/xstartup /${USER_HOME}/.vnc/
#COPY ./start.sh /
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