let s:plugin_path = resolve(expand('<sfile>:p:h:h'))

function! s:ToggleQfWindow(usages_count)
  if a:usages_count > 0
    let this_window = winnr()
    copen
    execute this_window . "wincmd w"
  else
    cclose
  endif
endfunction

function! estoolbox#FindFileUsages()
  let current_file = fnamemodify(expand('%'), ":~:.")
  echo "Searching for usages of ".current_file
  let find_cmd = s:plugin_path.'/bin/find-file-usage.sh '.current_file.' .'
  let usages = systemlist(find_cmd)

  call setqflist([], 'r', {
        \ "title": "usages of ".current_file,
        \ "efm": '%f:%l %m',
        \"lines": usages
        \})
  let usages_count = len(usages)
  redraw | echo "Found ".usages_count." usages."

  call s:ToggleQfWindow(usages_count)
endfunction
