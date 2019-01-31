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
let g:smooth_scroll = !exists('g:smooth_scroll') || !g:smooth_scroll
let g:default_scroll = &scroll

command! -count -bang SmoothScroll call scroll#cmd(<bang>0, <count>)

if !exists('g:scroll_smoothness')
  let g:scroll_smoothness = 5
endif

nnoremap <Plug>scroll_page_up    :<c-u>call scroll#page(1, v:count)<cr>
nnoremap <Plug>scroll_half_up    :<c-u>call scroll#half(1, v:count)<cr>
nnoremap <Plug>scroll_mark_up    :<c-u>call scroll#mark(1)<cr>
nnoremap <Plug>scroll_reset_up   :<c-u>call scroll#reset(1)<cr>

nnoremap <Plug>scroll_page_down  :<c-u>call scroll#page(0, v:count)<cr>
nnoremap <Plug>scroll_half_down  :<c-u>call scroll#half(0, v:count)<cr>
nnoremap <Plug>scroll_mark_down  :<c-u>call scroll#mark(0)<cr>
nnoremap <Plug>scroll_reset_down :<c-u>call scroll#reset(0)<cr>

if !exists('g:scroll_no_mappings')
  " scroll up
  nmap <silent> <PageUp>     <Plug>scroll_page_up
  nmap <silent> <c-b>        <Plug>scroll_page_up
  nmap <silent> <c-u>        <Plug>scroll_half_up

  " scroll down
  nmap <silent> <PageDown>   <Plug>scroll_page_down
  nmap <silent> <c-f>        <Plug>scroll_page_down
  nmap <silent> <c-d>        <Plug>scroll_half_down

  " with 'm', mark before moving, so that you can go back with <C-O>
  nmap <silent> m<C-b>       <Plug>scroll_mark_up
  nmap <silent> m<C-f>       <Plug>scroll_mark_down

  " with 'g', reset scroll values
  nmap <silent> g<C-b>       <Plug>scroll_reset_up
  nmap <silent> g<C-f>       <Plug>scroll_reset_down
endif
