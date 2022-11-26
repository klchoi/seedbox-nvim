function _seedbox-nvim_install -e seebox-nvim_install
  # install nvim
  dpkg -i https://github.com/neovim/neovim/releases/download/v0.8.1/nvim.appimage
  set -U EDITOR nvim
  
  # install packer
  git clone --depth 1 https://github.com/wbthomason/packer.nvim \
    ~/.local/share/nvim/site/pack/packer/start/packer.nvim

  seedbox-nvim-config
end
