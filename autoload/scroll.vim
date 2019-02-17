let s:delay = version < 801 ? 5 : 3
let g:smooth_scroll = get( g:, 'smooth_scroll', 1 )
let g:scroll_smoothness = exists('g:scroll_smoothness') ? g:scroll_smoothness : 5

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Scrolling by page means that if a count is given, only the last page will be
" scrolled smoothly. It's the normal <C-F> / <C-B> behaviour.

fun! scroll#page(up, count)
  let n = a:count > 1 ? a:count - 1 : ''
  if n
    exe "normal!" a:up ? n."\<C-B>" : n."\<C-F>"
  endif

  if !g:smooth_scroll
    exe "normal!" a:up ? "\<C-B>" : "\<C-F>"
  elseif a:up | call s:scroll_page_up()
  else        | call s:scroll_page_down()
  endif
  call s:center(1)
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Scrolling by 'half' page is the normal <C-D> / <C-U> behaviour. A count will
" set &scroll accordingly.

fun! scroll#half(up, count)
  if a:count | let &scroll = a:count | endif

  if !g:smooth_scroll
    exe "normal!" a:up ? "\<C-U>" : "\<C-D>"
  elseif a:up | call s:scroll_up()
  else        | call s:scroll_down()
  endif

  call s:center()
  if a:count | echo "'scroll' set to" &scroll | endif
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Scroll a page, but before doing so, restore &scroll to the default value.

fun! scroll#reset(up)
  set scroll=0
  if a:up | call s:scroll_up()
  else    | call s:scroll_down()
  endif
  call s:center()
  echo "'scroll' reset to" &scroll
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:can_see_BOF    = { -> line('.') <= winline() }
let s:can_see_EOF    = { -> ( winheight(0) - winline() + line('.') ) >= line('$') }
let s:is_at_bottom   = { -> winline() == winheight(0) - &scrolloff }
let s:is_at_top      = { -> winline() == 1 + &scrolloff }

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:scroll_page_down()
  let lns = &window
  let smoothness = min([lns, g:scroll_smoothness])

  normal! L

  for i in range(lns - smoothness)
    if s:can_see_EOF() | return | endif
    exe "normal! \<c-e>"
    if i % s:delay == 0
      sleep 10m
      redraw
    endif
  endfor

  for i in range(smoothness)
    if s:can_see_EOF()
      return
    endif

    let time = max([10, i*2])
    call execute("sleep ".time."m")
    exe "normal! \<c-e>"
    redraw
  endfor
  normal! H
endfun

"------------------------------------------------------------------------------

fun! s:scroll_page_up()
  let lns = &window
  let smoothness = min([lns, g:scroll_smoothness])

  normal! H

  for i in range(lns - smoothness)
    if s:can_see_BOF() | return | endif
    exe "normal! \<c-y>"
    if i % s:delay == 0
      sleep 10m
      redraw
    endif
  endfor

  for i in range(smoothness)
    if s:can_see_BOF()
      return
    endif

    let time = max([10, i*2])
    call execute("sleep ".time."m")
    exe "normal! \<c-y>"
    redraw
  endfor
  normal! L
endfun

"------------------------------------------------------------------------------

fun! s:scroll_up()
  " scroll fast, only slow down near the end
  let lns = &scroll
  let smoothness = min([lns, g:scroll_smoothness])
  let delay_while_fast_scroll = min([smoothness, 10])."m"

  " scroll fast until scroll_smoothness threshold, smooth a bit every now and then
  for i in range(lns - smoothness)
    if s:can_see_BOF()
      exe "normal! " . ( lns - i ) . "gk0"
      return
    endif
    normal! gk0
    " delay kicks in every 2 (half page) or 3 (full page)
    if s:is_at_top() && i % s:delay == 0
      exe "sleep" delay_while_fast_scroll
      redraw
    endif
  endfor

  " slow down near the end
  for i in range(smoothness)
    let remaining_lines = smoothness - i

    if s:can_see_BOF()
      exe "normal! " . remaining_lines . "gk0"
      return
    endif

    " the cursor is still far from the upper border, just jump above
    if !s:is_at_top()
      normal! gk0
    else
      let time = max([10, i*2])
      exe "sleep" time . "m"
      normal! gk0
      redraw
    endif
  endfor
endf

"------------------------------------------------------------------------------

fun! s:scroll_down()
  " scroll fast, only slow down near the end
  let lns = &scroll
  let smoothness = min([lns, g:scroll_smoothness])
  let delay_while_fast_scroll = min([smoothness, 10])."m"

  " scroll fast until scroll_smoothness threshold, smooth a bit every now and then
  for i in range(lns - smoothness)
    if s:can_see_EOF()
      exe "normal! " . ( lns - i ) . "gj0"
      return
    endif
    normal! gj0
    if s:is_at_bottom() && i % s:delay == 0
      exe "sleep" delay_while_fast_scroll
      redraw
    endif
  endfor

  " slow down near the end
  for i in range(smoothness)
    let remaining_lines = smoothness - i

    if s:can_see_EOF()
      exe "normal! " . remaining_lines . "gj0"
      return
    endif
    " the cursor is still far from the bottom, just jump below
    if !s:is_at_bottom()
      normal! gj0
    else
      let time = max([10, i*2])
      exe "sleep" time . "m"
      normal! gj0
      redraw
    endif
  endfor
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! scroll#cmd(bang, count)
  let text = []
  if a:bang
    let g:smooth_scroll = !g:smooth_scroll
  endif
  if a:count > 0
    let g:scroll_smoothness = a:count
  endif
  if g:smooth_scroll
    echo "Smooth scroll is enabled. Smoothness is" g:scroll_smoothness."."
  else
    echo "Smooth scroll is disabled."
  endif
endfun

"------------------------------------------------------------------------------

fun! s:center(...)
  """Center and print the current page.
  if get(g:, 'scroll_center_after', 0)
    normal! z.
  endif
  if a:0
    let one = &window
    let current = ( line('.') / one ) + 1
    let total = ( line("$") / one ) + 1
    echo "Page" current . '/' . total
  endif
endfun

