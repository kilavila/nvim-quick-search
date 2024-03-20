if exists('g:loaded_nvim_quick-search') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

command! QuickSearch lua require'nvim-quick-search'.search('brave', 'word', true, true)
command! QuickSearchHelp lua require'nvim-quick-search'.help()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_nvim_quick_search = 1
