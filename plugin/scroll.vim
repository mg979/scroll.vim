" ========================================================================///
" Description: smooth scroll for vim
" Mantainer:   Gianmaria Bajo <mg1979.git@gmail.com>
" License:     The MIT License
" Modified:    lun 21 gennaio 2019 22:04:24
" ========================================================================///

if exists("g:loaded_scroll")
  finish
endif

let g:loaded_scroll = 1

command! -count -bang SmoothScroll call scroll#cmd(<bang>0, <count>)

nnoremap <Plug>scroll_page_up    :<c-u>call scroll#page(1, v:count)<cr>
nnoremap <Plug>scroll_half_up    :<c-u>call scroll#half(1, v:count)<cr>
nnoremap <Plug>scroll_reset_up   :<c-u>call scroll#reset(1)<cr>

nnoremap <Plug>scroll_page_down  :<c-u>call scroll#page(0, v:count)<cr>
nnoremap <Plug>scroll_half_down  :<c-u>call scroll#half(0, v:count)<cr>
nnoremap <Plug>scroll_reset_down :<c-u>call scroll#reset(0)<cr>

if !exists('g:scroll_no_mappings')
  " scroll page
  nmap <silent> <PageUp>     <Plug>scroll_page_up
  nmap <silent> <PageDown>   <Plug>scroll_page_down
  nmap <silent> <c-b>        <Plug>scroll_page_up
  nmap <silent> <c-f>        <Plug>scroll_page_down

  " scroll half
  nmap <silent> <c-u>        <Plug>scroll_half_up
  nmap <silent> <c-d>        <Plug>scroll_half_down

  " with 'g', also reset &scroll
  nmap <silent> g<C-u>       <Plug>scroll_reset_up
  nmap <silent> g<C-d>       <Plug>scroll_reset_down
endif
