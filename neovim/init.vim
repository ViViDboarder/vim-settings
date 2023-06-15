" Maybe load init.lua
if has('nvim-0.6')
	lua require('init')
else
	set runtimepath+='~/.vim'
	source ~/.vim/autoload/*
	source ~/.vim/init.vim
end
