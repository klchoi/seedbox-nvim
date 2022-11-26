function _seedbox-nvim_install -e seedbox-nvim_install
  # install nvim
  dpkg -i https://github.com/neovim/neovim/releases/download/v0.8.1/nvim.appimage
  set -U EDITOR nvim
  
  # install packer
  git clone --depth 1 https://github.com/wbthomason/packer.nvim \
    ~/.local/share/nvim/site/pack/packer/start/packer.nvim
end

function _seedbox-nvim_config -e seedbox-nvim_install -e seedbox-nvim_update

  set -l nvim_2F_init_2E_lua "
require 'base'
require 'plugins'
"

  set -l nvim_2F_lua_2F_base_2E_lua "
vim.cmd('autocmd!')

vim.scriptencoding = 'utf-8'
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'

vim.wo.number = true
vim.wo.relativenumber = true

vim.opt.title = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.hlsearch = true
vim.opt.backup = false
vim.opt.showcmd = true
vim.opt.cmdheight = 1
vim.opt.laststatus = 2
vim.opt.expandtab = true
vim.opt.scrolloff = 10
vim.opt.shell = 'fish'
vim.opt.backupskip = { '/tmp/*', '/private/tmp/*' }
vim.opt.inccommand = 'split'
vim.opt.ignorecase = true -- Case insensitive searching UNLESS /C or capital in search
vim.opt.smarttab = true
vim.opt.breakindent = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.wrap = false -- No Wrap lines
vim.opt.backspace = { 'start', 'eol', 'indent' }
vim.opt.path:append { '**' } -- Finding files - Search down into subfolders
vim.opt.wildignore:append { '*/node_modules/*' }
vim.opt.swapfile = false

-- Undercurl
vim.cmd([[ let &t_Cs = '\e[4:3m' ]])
vim.cmd([[ let &t_Ce = '\e[4:0m' ]])

-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd('InsertLeave', {
  pattern = '*',
  command = 'set nopaste'
})

-- Add asterisks in block comments
vim.opt.formatoptions:append { 'r' }
"
  set -l nvim_2F_lua_2F_plugins_2E_lua "
local status, packer = pcall(require, 'packer')
if (not status) then
  print('Packer is not installed')
  return
end

vim.cmd [[ packadd packer.nvim ]]

packer.startup(function(use)
  use 'wbthomason/packer.nvim'
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'RRethy/nvim-treesitter-textsubjects'
  use { 'https://gitlab.com/madyanov/svart.nvim', as = 'svart' }
  use 'kylechui/nvim-surround'
  use 'terrortylor/nvim-comment'
end)
"

  set -l nvim_2F_after_2F_plugin_2F_comment_2E_rc_2E_lua "
local status, comment = pcall(require, 'nvim_comment')
if (not status) then return end

comment.setup()
"

  set -l nvim_2F_after_2F_plugin_2F_surround_2E_rc_2E_lua "
local status, surround = pcall(require, 'nvim-surround')
if (not status) then return end

surround.setup()
"

  set -l nvim_2F_after_2F_plugin_2F_svart_2E_rc_2E_lua "
local status, svart = pcall(require, 'svart')
if (not status) then return end

vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Cmd>Svart<CR>')        -- begin exact search
vim.keymap.set({ 'n', 'x', 'o' }, 'S', '<Cmd>SvartRegex<CR>')   -- begin regex search
vim.keymap.set({ 'n', 'x', 'o' }, 'gs', '<Cmd>SvartRepeat<CR>') -- repeat with last accepted query
"

  set -l nvim_2F_after_2F_plugin_2F_treesitter_2E_rc_2E_lua "
local status, treesitter = pcall(require, 'nvim-treesitter.configs')
if (not status) then return end

treesitter.setup {
  ensure_installed = 'all',
  auto_install = true,
  highlight = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
  },
  indent = {
    enable = true,
  }
}
"

  set -l nvim_2F_after_2F_plugin_2F_treesitter_2D_textsubjects_2E_rc_2E_lua "
local status, treesitter = pcall(require, 'nvim-treesitter.configs')
if (not status) then return end

treesitter.setup {
  textsubjects = {
    enable = true,
    prev_selection = ',',
    keymaps = {
      ['.'] = 'textsubjects-smart',
      [';'] = 'textsubjects-container-outer',
      ['i;'] = 'textsubjects-container-inner',
    }
  }
}
"

  set -S | while read -L line
    string match -q -r '^\$(?<var>nvim_\w+)' -- $line || continue
    set -l filename ~/.config/(string unescape -n --style=var $var)
    echo '>' $filename
    mkdir -p (path dirname $filename)
    echo $$var | sed -i -e '/./,$!d' -e:a -e '/^\n*$/{$d;N;ba' -e '}' > $filename
  end
end
