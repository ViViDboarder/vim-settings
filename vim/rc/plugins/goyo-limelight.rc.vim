" Both these plugins work well together for distraction free editing
Blink 'junegunn/goyo.vim'
Blink 'junegunn/limelight.vim'
let g:goyo_width = 120

command Zen :Goyo

function! s:goyo_enter()
    Limelight
endfunction

function! s:goyo_leave()
    Limelight!
endfunction

augroup zenevents
    autocmd! User GoyoEnter nested call <SID>goyo_enter()
    autocmd! User GoyoLeave nested call <SID>goyo_leave()
augroup end
