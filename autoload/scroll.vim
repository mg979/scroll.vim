"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Scrolling by page means that if a count is given, only the last page will be
" scrolled smoothly. It's the normal <C-F> / <C-B> behaviour.

fun! scroll#page(up, count)
  let n = a:count > 1 ? a:count - 1 : ''
  if n
    exe "normal!" a:up ? n."\<C-B>" : n."\<C-F>"
  endif
  if g:smooth_scroll
    let old_scroll = &scroll
    let &scroll = g:default_scroll
    if a:up | call s:scroll_up(1)
    else    | call s:scroll_down(1)
    endif
    let &scroll = old_scroll
  else
    exe "normal!" a:up ? "\<C-B>" : "\<C-F>"
  endif
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Scrolling by 'half' page is the normal <C-D> / <C-U> behaviour. A count will
" set &scroll accordingly.

fun! scroll#half(up, count)
  if a:count | let &scroll = a:count | endif

  if !g:smooth_scroll
    exe "normal!" a:up ? "\<C-U>" : "\<C-D>"
  elseif a:up | call s:scroll_up(0)
  else        | call s:scroll_down(0)
  endif

  if a:count | echo "'scroll' set to" &scroll | endif
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Scroll a page, but before doing so, set a mark.

fun! scroll#mark(up)
  k`
  if a:up | call s:scroll_up(1)
  else    | call s:scroll_down(1)
  endif
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Scroll a page, but before doing so, restore &scroll and multiplier to the
" default values.

fun! scroll#reset(up)
  let &scroll = g:default_scroll
  let s:mult = 1
  if a:up | call s:scroll_up(1)
  else    | call s:scroll_down(1)
  endif
  echo "'scroll' reset to" &scroll
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Uses the same function to scroll by half page, but sets a multiplier.
" This allows faster scrolling with a custom mapping.

let s:mult = 1

fun! scroll#mult(up, count)
  let s:mult = a:count > 0 ? a:count : s:mult
  if !g:smooth_scroll
    let n = a:count > 0 ? a:count : ''
    exe "normal!" a:up ? n."\<C-B>" : n."\<C-F>"
  else
    if a:up | call s:scroll_up(1)
    else    | call s:scroll_down(1)
    endif
  endif
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Default Vim behaviour:
"
"   [count]<C-D>  scrolls &scroll lines down, sets &scroll to [count]
"   [count]<C-U>  scrolls &scroll lines up, sets &scroll to [count]
"   [count]<C-F>  scrolls [count] pages down
"   [count]<C-B>  scrolls [count] pages up
"   <PageDown>    same as <C-F>
"   <PageUp>      same as <C-B>

" Default with this plugin:
"
"   [count]<C-D>  same as in vim
"   [count]<C-U>  same as in vim
"   [count]<C-F>  scrolls (&scroll * mult) lines down, sets mult to [count]
"   [count]<C-B>  scrolls (&scroll * mult) lines up, sets mult to [count]
"   <PageDown>    same as in vim
"   <PageUp>      same as in vim
"   g<C-F>        resets &scroll and mult, then does <C-F>
"   g<C-B>        resets &scroll and mult, then does <C-B>
"   m<C-F>        sets ` mark, then does <C-F>
"   m<C-B>        sets ` mark, then does <C-B>

" The biggest difference concerns the behaviour of <C-F> / <C-B>.
" To scroll we're using gj/gk: it helps when wrap is off, and cursor is moved
" anyway.
"
" Sometimes we fast-forward the cursor without scrolling, because there's no
" need to do it 'smoothly'. In this case we keep track of the 'eaten' lines
" with the variable 'adjust': because we can't shorten the loop, we're going
" to get back those lines at the end of the loop.

let s:can_see_BOF    = { -> line('.') <= winline() }
let s:can_see_EOF    = { -> ( winheight(0) - winline() + line('.') ) >= line('$') }
let s:is_at_bottom   = { -> winline() == winheight(0) - &scrolloff }
let s:is_at_top      = { -> winline() == 1 + &scrolloff }

fun! s:scroll_up(page)
  " scroll fast, only slow down near the end
  let lns = a:page ? &window : &scroll
  let smoothness = min([lns, g:scroll_smoothness])

  " scroll fast until scroll_smoothness threshold, smooth a bit every now and then
  let delay_while_fast_scroll = min([smoothness, 10])."m"
  for i in range(lns - smoothness)
    if s:can_see_BOF()
      exe "normal! " . ( lns - i ) . "gk"
      return s:center(a:page)
    endif
    normal! gk
    " delay kicks in every 2 (half page) or 3 (full page)
    if s:is_at_top() && i % (2 + a:page) == 0
      exe "sleep" delay_while_fast_scroll
      redraw
    endif
  endfor

  " then, slow down near the end
  for i in range(smoothness)
    let remaining_lines = smoothness - i

    if s:can_see_BOF()
      exe "normal! " . remaining_lines . "gk"
      return s:center(a:page)
    endif

    " the cursor is still far from the upper border, just jump above
    if !s:is_at_top()
      normal! gk
    else
      let time = max([10, i*2])
      exe "sleep" time . "m"
      normal! gk
      redraw
    endif
  endfor
  call s:center(a:page)
endf

"------------------------------------------------------------------------------

fun! s:scroll_down(page)
  " scroll fast, only slow down near the end
  let lns = a:page ? &window : &scroll
  let smoothness = min([lns, g:scroll_smoothness])

  " scroll fast until scroll_smoothness threshold, smooth a bit every now and then
  let delay_while_fast_scroll = min([smoothness, 10])."m"
  for i in range(lns - smoothness)
    if s:can_see_EOF()
      exe "normal! " . ( lns - i ) . "gj"
      return s:center(a:page)
    endif
    normal! gj
    " delay kicks in every 2 (half page) or 3 (full page)
    if s:is_at_bottom() && i % (2 + a:page) == 0
      exe "sleep" delay_while_fast_scroll
      redraw
    endif
  endfor

  " then, slow down near the end
  for i in range(smoothness)
    let remaining_lines = smoothness - i

    if s:can_see_EOF()
      exe "normal! " . remaining_lines . "gj"
      return s:center(a:page)
    endif
    " the cursor is still far from the bottom, just jump below
    if !s:is_at_bottom()
      normal! gj
    else
      let time = max([10, i*2])
      exe "sleep" time . "m"
      normal! gj
      redraw
    endif
  endfor
  call s:center(a:page)
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

fun! s:center(page)
  """Center and print the current page.
  if get(g:, 'scroll_center_after', 0)
    normal! z.
  endif
  if a:page
    let one = &window
    let current = ( line('.') / one ) + 1
    let total = ( line("$") / one ) + 1
    echo "Page" current . '/' . total
  endif
endfun

"------------------------------------------------------------------------------

fun! s:to_top(page)
  if a:page
    normal! H
  endif
endfun

"------------------------------------------------------------------------------

fun! s:to_bottom(page)
  if a:page
    normal! L
  endif
endfun

