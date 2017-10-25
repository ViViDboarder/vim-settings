Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install' }
Plug 'junegunn/fzf.vim'
let g:fzf_command_prefix = 'FZF'
" Jump to existing window if possible
let g:fzf_buffers_jump = 1
" Override key commands
let g:fzf_action = {
      \ 'ctrl-t': 'tab split',
      \ 'ctrl-s': 'split',
      \ 'ctrl-v': 'vsplit' }

" Ctrl-T to launch standard file search
nnoremap <C-t> :FZF<CR>

" Leader Commands

" Find buffers
nnoremap <leader>b :FZFBuffers<CR>
" Find text in files
nnoremap <leader>f :FZFAg<CR>
" Find tags
nnoremap <leader>r :FZFTags<CR>
" Find buffer tags
nnoremap <leader>t :FZFBTags<CR>
" Find git history for buffer
nnoremap <leader>g :FZFBCommits<CR>
