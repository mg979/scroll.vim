" older vim versions are slower for some reason
let s:delay = v:version < 801 ? 5 : 3
let s:DELAY = s:delay
let s:ready = 1

let g:smooth_scroll = get(g:, 'smooth_scroll', 1 )
let g:scroll_smoothness = get(g:, 'scroll_smoothness', 5)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Scrolling by page means that if a count is given, only the last page will be
" scrolled smoothly. It's the normal <C-F> / <C-B> behaviour.

fun! scroll#page(up, count)
  if !s:ready | return scroll#accelerate() | endif
  let n = a:count > 1 ? a:count - 1 : ''
  if n
    exe "normal!" a:up ? n."\<C-B>" : n."\<C-F>"
  endif

  if !g:smooth_scroll
    exe "normal!" a:up ? "\<C-B>" : "\<C-F>"
  elseif a:up | call s:start("scroll#page_up")
  else        | call s:start("scroll#page_down")
  endif
  call scroll#print(1)
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Scrolling by 'half' page is the normal <C-D> / <C-U> behaviour.
" A count will set &scroll accordingly.

fun! scroll#half(up, count)
  if !s:ready | return scroll#accelerate() | endif
  if a:count
    if !exists('s:oldscroll')
      let s:oldscroll = &scroll
    endif
    let &scroll = a:count
  endif

  if !g:smooth_scroll
    exe "normal!" a:up ? "\<C-U>" : "\<C-D>"
  elseif a:up | call s:start("scroll#up")
  else        | call s:start("scroll#down")
  endif

  if a:count | echo "'scroll' set to" &scroll | endif
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Scroll a page, but before doing so, restore &scroll to the default value.

fun! scroll#default(up)
  if !s:ready | return | endif
  if exists('s:oldscroll')
    let &scroll = s:oldscroll
    unlet s:oldscroll
  endif
  if a:up | call s:start("scroll#up")
  else    | call s:start("scroll#down")
  endif
  echo "'scroll' reset to" &scroll
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:can_see_BOF    = { -> line('.') <= winline() }
let s:can_see_EOF    = { -> ( winheight(0) - winline() + line('.') ) >= line('$') }
let s:is_at_bottom   = { -> winline() == winheight(0) - &scrolloff }
let s:is_at_top      = { -> winline() == 1 + &scrolloff }

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! scroll#page_down(t)
  let lns = winheight(0) - 2
  let smoothness = min([lns, g:scroll_smoothness])

  keepjumps normal! L

  for i in range(lns - smoothness)
    if s:can_see_EOF() | return s:reset() | endif
    exe "normal! \<c-e>"
    if i % s:delay == 0
      sleep 10m
      redraw
    endif
  endfor

  for i in range(smoothness)
    if s:can_see_EOF() | return s:reset() | endif

    let time = max([10, i*2])
    call execute("sleep ".time."m")
    exe "normal! \<c-e>"
    redraw
  endfor
  keepjumps normal! H
  return s:reset()
endfun

"------------------------------------------------------------------------------

fun! scroll#page_up(t)
  let lns = winheight(0) - 2
  let smoothness = min([lns, g:scroll_smoothness])

  keepjumps normal! H

  for i in range(lns - smoothness)
    if s:can_see_BOF() | return s:reset() | endif
    exe "normal! \<c-y>"
    if i % s:delay == 0
      sleep 10m
      redraw
    endif
  endfor

  for i in range(smoothness)
    if s:can_see_BOF() | return s:reset() | endif

    let time = max([10, i*2])
    call execute("sleep ".time."m")
    exe "normal! \<c-y>"
    redraw
  endfor
  keepjumps normal! L
  return s:reset()
endfun

"------------------------------------------------------------------------------

fun! scroll#up(t)
  " scroll fast, only slow down near the end
  let lns = &scroll
  let smoothness = min([lns, g:scroll_smoothness])
  let delay_while_fast_scroll = max([smoothness, 5])."m"

  " scroll fast until scroll_smoothness threshold, smooth a bit every now and then
  for i in range(lns - smoothness)
    if s:can_see_BOF()
      exe "normal! " . ( lns - i ) . "gk^"
      return s:reset()
    endif
    if s:can_see_EOF()
      exe "normal! \<c-y>"
    elseif s:is_at_bottom()
      exe "normal! gk\<c-y>"
    else
      exe "normal! \<c-y>gk"
    endif
    if i % s:delay == 0
      exe "sleep" delay_while_fast_scroll
      redraw
    endif
  endfor

  " slow down near the end
  for i in range(smoothness)
    let remaining_lines = smoothness - i

    if s:can_see_BOF()
      exe "normal! " . remaining_lines . "\<c-y>gk^"
      return s:reset()
    endif

    let time = max([10, i*2])
    exe "sleep" time . "m"
    if s:is_at_bottom()
      exe "normal! gk\<c-y>"
    else
      exe "normal! \<c-y>gk"
    endif
    redraw
  endfor
  exe "normal! ^"
  return s:reset()
endf

"------------------------------------------------------------------------------

fun! scroll#down(t)
  " scroll fast, only slow down near the end
  let lns = &scroll
  let smoothness = min([lns, g:scroll_smoothness])
  let delay_while_fast_scroll = max([smoothness, 5])."m"

  " scroll fast until scroll_smoothness threshold, smooth a bit every now and then
  for i in range(lns - smoothness)
    if s:can_see_EOF()
      exe "normal! " . ( lns - i ) . "gj^"
      return s:reset()
    endif
    if s:is_at_bottom()
      exe "normal! gj^"
    else
      exe "normal! gj^\<c-e>"
    endif
    if i % s:delay == 0
      exe "sleep" delay_while_fast_scroll
      redraw
    endif
  endfor

  " slow down near the end
  for i in range(smoothness)
    let remaining_lines = smoothness - i

    if s:can_see_EOF()
      exe "normal! " . remaining_lines . "gj^"
      return s:reset()
    endif
    let time = max([10, i*2])
    exe "sleep" time . "m"
    if s:is_at_top()
      exe "normal! gj\<c-e>"
    elseif s:is_at_bottom()
      exe "normal! gj^"
    else
      exe "normal! gj\<c-e>"
    endif
    redraw
  endfor
  exe "normal! ^"
  return s:reset()
endfun

"------------------------------------------------------------------------------

fun! scroll#zcr()
  let lns = winline() - &scrolloff - 1
  if lns <= 0
    return
  endif
  let smoothness = min([lns, g:scroll_smoothness])

  for i in range(lns - smoothness)
    if winline() <= &scrolloff
      return s:reset()
    endif
    exe "normal! \<c-e>"
    if i % s:delay == 0
      sleep 10m
      redraw
    endif
  endfor

  for i in range(smoothness)
    if winline() <= &scrolloff
      return s:reset()
    endif
    let time = max([10, i*2])
    call execute("sleep ".time."m")
    exe "normal! \<c-e>"
    redraw
  endfor
  return s:reset()
endfun

"------------------------------------------------------------------------------

fun! scroll#zz()
  let lns = winheight(0)/2 - winline()
  if !lns
    return
  elseif lns < 0
    let lns = lns * -1
    let cmd = "\<c-e>"
  else
    let cmd = "\<c-y>"
  endif
  let smoothness = min([lns, g:scroll_smoothness])

  for i in range(lns - smoothness)
    if winline() <= &scrolloff
      return s:reset()
    endif
    exe "normal!" cmd
    if i % s:delay == 0
      sleep 10m
      redraw
    endif
  endfor

  for i in range(smoothness)
    if winline() <= &scrolloff
      return s:reset()
    endif
    let time = max([10, i*2])
    call execute("sleep ".time."m")
    exe "normal!" cmd
    redraw
  endfor
  return s:reset()
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

fun! scroll#print(...)
  """Print the current page.
  if a:0 && !get(g:, 'scroll_print_current_page', 0) | return | endif
  let one = winheight(0)
  let current = ( line('.') / one ) + 1
  let total = ( line("$") / one ) + 1
  let string = current . '/' . total
  if a:0 | redraw | echo "Page" string | endif
  return string
endfun

"------------------------------------------------------------------------------

fun! scroll#accelerate() abort
  if s:delay < 10
    let s:delay += 1
  endif
endfun

"------------------------------------------------------------------------------

fun! s:start(fun) abort
  let s:ready = 0
  call timer_start(10, a:fun)
endfun

"------------------------------------------------------------------------------

fun! s:reset(...) abort
  let s:delay = s:DELAY
  let s:ready = 1
  silent! doautocmd <nomodeline> CursorHold
endfun

