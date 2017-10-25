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

" Override BTags to attempt to include gotags as well
command! -bang -nargs=* FZFBTags
  \  if &filetype == 'go'
  \|   call fzf#vim#buffer_tags(<q-args>, printf('gotags -silent -sort %s | sed /^!_TAG_/d', shellescape(expand('%'))), <bang>0)
  \| else
  \|   call fzf#vim#buffer_tags(<q-args>, <bang>0)
  \| endif

" If no CtrlP, use FZF bindings
if !exists('g:ctrlp_in_use')
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
endif
