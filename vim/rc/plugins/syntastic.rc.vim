if exists('loaded_syntastic')
    let g:syntastic_html_tidy_ignore_errors = [
        \ 'proprietary attribute "ng-show"',
        \ 'proprietary attribute "ng-controller"',
        \ 'proprietary attribute "ng-repeat"',
        \ 'proprietary attribute "ng-app"',
        \ 'proprietary attribute "ng-click"'
        \ ]
    let g:syntastic_python_checkers = ['flake8']
    let g:syntastic_python_flake8_args='--max-line-length=80'
    " let g:syntastic_python_checkers = ['pep8']
    " " let g:syntastic_python_pep8_args='--ignore=E501'
    " " let g:syntastic_python_checkers = ['jshint']
    " " let g:syntastic_javascript_jshint_args='--ignore=E501'
endif
