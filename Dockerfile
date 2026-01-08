FROM archlinux:latest

RUN  pacman -Syu --noconfirm &&  pacman -S --noconfirm git vim  neovim curl zsh sudo wget openssh

RUN useradd -m -G wheel -s /bin/bash devuser && \
    echo "devuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set the working directory
WORKDIR /home/devuser

# Switch to the non-root user
USER devuser

# Set default command to bash
CMD ["/bin/zsh"]
