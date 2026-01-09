FROM archlinux:latest

RUN  pacman -Syu --noconfirm &&  pacman -S --noconfirm sudo curl git vim  neovim zsh wget openssh \
      bat btop zoxide eza tmux base-devel bw jq \
    clang cmake gdb valgrind less mesa libglvnd glu \
    libx11 libxrandr libxinerama libxcursor libxi \
    libxcomposite libxdamage libxext libxfixes \
    libxrender libxkbcommon xorgproto

RUN useradd -m -G wheel -s /bin/bash devuser && \
    echo "devuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set the working directory
WORKDIR /home/devuser

# Switch to the non-root user
USER devuser
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

RUN git clone https://github.com/girts521/dotfiles.git
RUN ln -sf ~/dotfiles/.zshrc ~/.zshrc
RUN mkdir .config
RUN ln -sf ~/dotfiles/.config/nvim ~/.config/nvim
RUN ln -sf ~/dotfiles/.gitconfig ~/.gitconfig

# Set default command to bash
CMD ["/bin/zsh"]
