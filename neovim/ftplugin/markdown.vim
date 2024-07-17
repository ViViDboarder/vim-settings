" Set Markdown indent to 2 so single indented text doesn't become 'code'
set shiftwidth=2

" From plasticboy/vim-markdown via sheerun/vim-polyglot
let g:vim_markdown_new_list_item_indent = 0

" Format frontmatter as YAML
let g:vim_markdown_frontmatter = 1

call textobj#sentence#init()
