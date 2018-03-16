scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

if get(g:, 'loaded_pydoc_view', 0)
  finish
endif

let g:loaded_pydoc_view = 1

let g:pydoc_view_pydoc_cmd = 'pydoc3.6'


" parameters {{{
let g:pydoc_view_pydoc_cmd = get(g:, 'pydoc_view_pydoc_cmd', 'pydoc')
let g:pydoc_view_pydoc2_cmd = get(g:, 'pydoc_view_pydoc_cmd', 'pydoc')
let g:pydoc_view_pydoc3_cmd = get(g:, 'pydoc_view_pydoc_cmd', 'pydoc3')
let g:pydoc_view_try_vertical = get(g:, 'pydoc_view_direction', 1)
let g:pydoc_view_width = get(g:, 'pydoc_view_width', 65)
" }}}


function! s:view_result(result) "{{{
  if g:pydoc_view_try_vertical && winwidth('.') > g:pydoc_view_width * 2
    exe 'botright ' . g:pydoc_view_width . 'vnew __doc__'
    setlocal winfixwidth
  else
    exe 'aboveleft new __doc__'
    setlocal winfixheight
  endif

  setlocal modifiable
  setlocal nonumber
  setlocal noswapfile
  setlocal nobackup
  setlocal buftype=nofile
  setlocal filetype=pydoc
  setlocal nolist
  setlocal wrap
  setlocal nospell
  setlocal breakindent

  silent put =a:result
  silent execute '0d 1'

  setlocal nomodifiable
  setlocal nomodified
endfunction "}}}
  

function! g:pydoc_view#run(cmd, keyword, mode) "{{{
  let l:cmd = a:cmd . ' '
  if a:mode == 1
    let l:cmd .= '-k ' . a:keyword . ' '
  else
    let l:cmd .= a:keyword . ' '
  endif
  let l:result = system(l:cmd)
  if l:result[0:23] == "No Python documentation "
    echoerr split(l:result, '\n')[0]
    return 1
  endif
  if exists('g:pydoc_view_post_process')
    let l:result = eval(g:pydoc_view_post_process . '(l:result)')
  endif

  silent call s:view_result(l:result)
endfunction "}}}


function! g:pydoc_view#get_current_word() "{{{
  let l:line = getline(".")
  let l:pre = l:line[:col(".") - 1]
  let l:suf = l:line[col("."):]
  let l:word = matchstr(pre, "[A-Za-z0-9_.]*$") . matchstr(suf, "^[A-Za-z0-9_]*")
  return l:word
endfunction "}}}


function! g:pydoc_view#toggle() "{{{
  let s:pydoc_view_bufid = -1
  let s:pydoc_view_closed = 0
  function! s:pydoc_try_close()
    if &filetype == 'pydoc'
      let s:pydoc_view_bufid = bufnr("")
      let s:pydoc_view_closed = 1
      hide
    endif
  endfunction

  noautocmd windo call s:pydoc_try_close()

  if s:pydoc_view_bufid == -1
    silent call s:view_result('')
  elseif s:pydoc_view_closed == 0
    if g:pydoc_view_try_vertical && winwidth('.') > g:pydoc_view_width * 2
      silent exe 'botright ' . g:pydoc_view_width . 'vnew __doc__'
      setlocal winfixwidth
    else
      silent exe 'aboveleft new __doc__'
      setlocal winfixheight
    endif
    noautocmd exec 'buffer ' . s:pydoc_view_bufid
  endif

endfunction "}}}

command! PydocView call g:pydoc_view#run(g:pydoc_view_pydoc_cmd, pydoc_view#get_current_word(), 0)
command! PydocView2 call g:pydoc_view#run(g:pydoc_view_pydoc2_cmd, pydoc_view#get_current_word(), 0)
command! PydocView3 call g:pydoc_view#run(g:pydoc_view_pydoc3_cmd, pydoc_view#get_current_word(), 0)
command! -nargs=1 Pydoc call g:pydoc_view#run(g:pydoc_view_pydoc_cmd, '<args>', 0)
command! -nargs=1 Pydoc2 call g:pydoc_view#run(g:pydoc_view_pydoc2_cmd, '<args>', 0)
command! -nargs=1 Pydoc3 call g:pydoc_view#run(g:pydoc_view_pydoc3_cmd, '<args>', 0)

let &cpo = s:save_cpo
unlet s:save_cpo
