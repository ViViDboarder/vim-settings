" Both these plugins work well together for distraction free editing
Plug 'junegunn/goyo.vim', { 'on': 'Goyo' }
Plug 'junegunn/limelight.vim', { 'on': 'Limelight' }

let g:goyo_width = 120

" Enables Zen mode (Goyo + Limelight)
command -bang Zen call <SID>zen_mode(<bang>0)
let g:zen_mode = 0
function s:zen_mode(bang)
    if !g:zen_mode
        Goyo
        if !a:bang
            Limelight
        endif
        let g:zen_mode = 1
    else
        Goyo!
        Limelight!
        let g:zen_mode = 0
    endif
endfunction

" Enables prose mode
command -bang Prose call <SID>prose_mode(<bang>0)
let g:prose_mode = 0
function s:prose_mode(bang)
    if !g:prose_mode
        Goyo

        setlocal formatoptions=ant
        setlocal textwidth=80
        setlocal wrapmargin=0

        if !a:bang
            Limelight
        endif
        let g:prose_mode = 1
    else
        Goyo!
        Limelight!
        let g:prose_mode = 0
    endif
endfunction


function! s:goyo_enter()
    " Limelight
endfunction
function! s:goyo_leave()
    " Limelight!
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()
