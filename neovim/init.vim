" Maybe load init.lua
if has('nvim-0.5')
	lua require('init')
else
	" set runtimepath-='~/.local/share/nvim/site/pack/packer/**'
	" set runtimepath='~/.vim'
	set runtimepath+='~/.vim"
	source ~/.vim/init.vim
end
