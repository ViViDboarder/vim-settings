" Set Markdown indent to 2 so single indented text doesn't become 'code'
set shiftwidth=2

" Enable conceal feature
set conceallevel=2

" Enable fenced code blocks
let g:vim_markdown_fenced_languages = ['html', 'python', 'javascript', 'css', 'bash=sh', 'yaml', 'json', 'vim', 'markdown', 'sql', 'ruby', 'php', 'java', 'c', 'cpp', 'rust', 'go', 'typescript', 'jsx', 'tsx', 'graphql', 'dockerfile']

" From https://github.com/preservim/vim-markdown via sheerun/vim-polyglot

" Disable auto list indent
let g:vim_markdown_new_list_item_indent = 0

" Format frontmatter as YAML
let g:vim_markdown_frontmatter = 1
