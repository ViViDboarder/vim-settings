let g:argwrap_tail_comma = 1
let g:ale_fix_on_save = 1
" Disable some vim-go settings when Ale is installed
if exists('g:ale_fixers')
  let g:go_def_mapping_enabled = 0
  let g:go_version_warning = 0
  let g:go_fmt_autosave = 0
  let g:go_imports_autosave = 0
end
