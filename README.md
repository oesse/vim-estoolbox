# vim-estoolbox
Vim plugin to work efficiently with Javascript

This plugin is just getting started and its features will be expanded.

### Features
 * search for source files that include a Javascript file
 * more to come...

### Requirements
This plugin is powered by a bash script. This implies some requirements:
  * *nix like environment
  * bash, sed, grep, cut
  * optional: ripgrep (rg) or the silver searcher (ag) for fast search :)
              the script will fall back to grep which works but is very slow in comparison

### Usage
Add your favorite binding to your `.vimrc` or `ftplugin/javascript.vim` file, e.g.
```vim
" .vimrc
augroup JsMaps
  autocmd!
  autocmd FileType javascript nmap <buffer> <leader>fu <Plug>(estoolbox-find-file-usages)
augroup END

" ftplugin/javascript.vim
nmap <buffer> <leader>fu <Plug>(estoolbox-find-file-usages)
```

Use your binding to populate the quickfixlist with all files that use the file in your current buffer.

