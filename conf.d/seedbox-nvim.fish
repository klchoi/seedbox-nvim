function _seedbox-nvim_install -e seedbox-nvim_install
  # install nvim
  dpkg -i https://github.com/neovim/neovim/releases/download/v0.8.1/nvim.appimage
  set -Ux EDITOR nvim
end

function _seedbox-nvim_config -e seedbox-nvim_install -e seedbox-nvim_update
  set -S | while read -L line
    string match -q -r '^\$(?<var>nvim_\w+)' -- $line || continue
    set -l filename ~/.config/(string unescape -n --style=var $var)
    echo '>' $filename
    mkdir -p (path dirname $filename)
    echo $$var | sed -e '/./,$!d' -e:a -e '/^\n*$/{$d;N;ba' -e '}' > $filename
  end

  nvim --headless -c 'autocmd User PackerComplete quitall'
end

function _seedbox-nvim_uninstall -e seedbox-nvim_uninstall
  set -e EDITOR
  rm -rf ~/.config/nvim ~/.local/share/nvim
  dpkg -r nvim
end

set -g nvim_2F_init_2E_lua "
require 'base'
require 'plugins'
"

set -g nvim_2F_lua_2F_base_2E_lua "
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

set -g nvim_2F_lua_2F_plugins_2E_lua "
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
  }
  use { 'RRethy/nvim-treesitter-textsubjects', after = 'nvim-treesitter' }
  use { 'https://gitlab.com/madyanov/svart.nvim', as = 'svart' }
  use 'kylechui/nvim-surround'
  use 'terrortylor/nvim-comment'

  if packer_bootstrap then
    require('packer').sync()
  end
end)
"

set -g nvim_2F_after_2F_plugin_2F_comment_2E_rc_2E_lua "
local status, comment = pcall(require, 'nvim_comment')
if (not status) then return end

comment.setup()
"

set -g nvim_2F_after_2F_plugin_2F_surround_2E_rc_2E_lua "
local status, surround = pcall(require, 'nvim-surround')
if (not status) then return end

surround.setup()
"

set -g nvim_2F_after_2F_plugin_2F_svart_2E_rc_2E_lua "
local status, svart = pcall(require, 'svart')
if (not status) then return end

vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Cmd>Svart<CR>')        -- begin exact search
vim.keymap.set({ 'n', 'x', 'o' }, 'S', '<Cmd>SvartRegex<CR>')   -- begin regex search
vim.keymap.set({ 'n', 'x', 'o' }, 'gs', '<Cmd>SvartRepeat<CR>') -- repeat with last accepted query
"

set -g nvim_2F_after_2F_plugin_2F_treesitter_2E_rc_2E_lua "
local status, treesitter = pcall(require, 'nvim-treesitter.configs')
if (not status) then return end

local is_headless = #vim.api.nvim_list_uis() == 0

treesitter.setup {
  ensure_installed = 'all',
  auto_install = (not is_headless),
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

set -g nvim_2F_after_2F_plugin_2F_treesitter_2D_textsubjects_2E_rc_2E_lua "
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
