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
    call s:scroll(a:up, 2)
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
  else
    call s:scroll(a:up, 1)
  endif

  if a:count | echo "'scroll' set to" &scroll | endif
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Scroll a page, but before doing so, set a mark.

fun! scroll#mark(up)
  k`
  call s:scroll(a:up, 2)
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Scroll a page, but before doing so, restore &scroll and multiplier to the
" default values.

fun! scroll#reset(up)
  let &scroll = g:default_scroll
  let s:mult = 2
  call s:scroll(a:up, 2)
  echo "'scroll' reset to" &scroll
endfun

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Uses the same function to scroll by half page, but sets a multiplier.
" This allows faster scrolling with a custom mapping.

let s:mult = 2

fun! scroll#mult(up, count)
  let s:mult = a:count > 0 ? a:count : s:mult
  if !g:smooth_scroll
    let n = a:count > 0 ? a:count : ''
    exe "normal!" a:up ? n."\<C-B>" : n."\<C-F>"
  else
    call s:scroll(a:up, s:mult)
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

fun! s:scroll(up, mult)
  let cmd = a:up ? "gk" : "gj"
  let lns = &scroll * a:mult
  let adjust = 0
  for i in range(lns)
    let remaining_lines = ( lns - i )
    if a:up
      if ( line('.') - winline() ) <= 0
        " can see the top of the file, don't scroll, just move the cursor
        exe "normal! " . remaining_lines . "gk"
        let adjust -= remaining_lines
        break
      endif
    elseif ( winheight(0) - winline() + line('.') ) >= line('$')
      " can see the end of the file, don't scroll, just move the cursor
      exe "normal! " . remaining_lines . "gj"
      let adjust -= remaining_lines
      break
    endif
    if a:up
      " the cursor is still far from the upper border, are we going to move it
      " one line at a time, even 'smoothly'? No, just jump above
      if winline() > ( &scrolloff + 1 )
        let adjust = winline() - &scrolloff - 1
        exe "normal! ".adjust."gk"
      endif
    else
      " same here, but going down
      if winline() < ( winheight(0) - &scrolloff )
        let adjust = winheight(0) - &scrolloff - winline()
        exe "normal! ".adjust."gj"
      endif
    endif
    " scroll fast, only slow down near the end
    let slow = g:scroll_smoothness - remaining_lines
    if ( slow > 0 ) && ( slow < g:scroll_smoothness )
      exe "sleep " . slow . "m"
    elseif slow % (1 + a:mult) == 0
      sleep 1m
    endif
    execute "normal! " . cmd
    redraw
  endfor
  " if we have 'fast-forwarded' the cursor, we must take back what it's been taken
  if adjust > 0
    exe "normal! " . adjust . (a:up ? "gj" : "gk")
    redraw
  endif
endf

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
