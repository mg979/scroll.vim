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

nnoremap <Plug>(scroll-page-up)    :<c-u>call scroll#page(1, v:count)<cr>
nnoremap <Plug>(scroll-mult-up)    :<c-u>call scroll#mult(1, v:count)<cr>
nnoremap <Plug>(scroll-half-up)    :<c-u>call scroll#half(1, v:count)<cr>
nnoremap <Plug>(scroll-mark-up)    :<c-u>call scroll#mark(1)<cr>
nnoremap <Plug>(scroll-reset-up)   :<c-u>call scroll#reset(1)<cr>

nnoremap <Plug>(scroll-page-down)  :<c-u>call scroll#page(0, v:count)<cr>
nnoremap <Plug>(scroll-mult-down)  :<c-u>call scroll#mult(0, v:count)<cr>
nnoremap <Plug>(scroll-half-down)  :<c-u>call scroll#half(0, v:count)<cr>
nnoremap <Plug>(scroll-mark-down)  :<c-u>call scroll#mark(0)<cr>
nnoremap <Plug>(scroll-reset-down) :<c-u>call scroll#reset(0)<cr>

if !exists('g:scroll_no_mappings')
  " scroll up
  nmap <silent> <PageUp>     <Plug>(scroll-page-up)
  nmap <silent> <c-b>        <Plug>(scroll-mult-up)
  nmap <silent> <c-u>        <Plug>(scroll-half-up)
  nmap <silent> <S-PageUp>   <Plug>(scroll-half-up)

  " scroll down
  nmap <silent> <PageDown>   <Plug>(scroll-page-down)
  nmap <silent> <c-f>        <Plug>(scroll-mult-down)
  nmap <silent> <c-d>        <Plug>(scroll-half-down)
  nmap <silent> <S-PageDown> <Plug>(scroll-half-down)

  " with 'm', mark before moving, so that you can go back with <C-O>
  nmap <silent> m<C-b>       <Plug>(scroll-mark-up)
  nmap <silent> m<C-f>       <Plug>(scroll-mark-down)

  " with 'g', reset scroll values
  nmap <silent> g<C-b>       <Plug>(scroll-reset-up)
  nmap <silent> g<C-f>       <Plug>(scroll-reset-down)
endif
