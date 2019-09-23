## scroll.vim


A smooth scroll plugin. After scrolling, cursor should end up exactly where it
would end without plugin, also keeping the same viewport position. It should
scroll exactly in the same way, but smoothly.

It will respect your 'scroll' and 'scrolloff' settings. Moreover, keeping the
keys pressed won't block vim, it will stop scrolling soon after you release
the keys.




### Mappings

Unless *g:scroll_no_mappings* is set to 1, these are the default mappings and
plugs:

|key|effect|plug|
|-|-|-|
|`<C-F>`                |scroll one page up          |`<Plug>scroll_page_down` |
|`<C-B>`                |,,              down        |`<Plug>scroll_page_up` |
|`<C-U>`                |scroll half-page up         |`<Plug>scroll_half_up` |
|`<C-D>`                |,,               down       |`<Plug>scroll_half_down` |
|`zz`                   |center page                 |`<Plug>scroll_center` |
|`z<CR>`                |top of page                 |`<Plug>scroll_top` |


If a `count` is given, the first `count-1` (half-)pages are scrolled much
faster that the last one.



### Settings

|       |default|           |
|-|-|-|
|*g:smooth_scroll*| 1 | set to 0 to disable smooth scroll |
|*g:scroll_smoothness*| 5 | higher is smoother (slower), not recommended above 15 |
|*g:scroll_no_mappings*| 0 | don't set default mappings |
|*g:scroll_print_current_page*| 0 | print the current page of document after page up/down |
