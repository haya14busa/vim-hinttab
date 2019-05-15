let s:Hint = vital#hinttab#import('HitAHint.Hint')
let s:Dict = vital#hinttab#import('Data.Dict')

let s:keys = map(range(char2nr('a'),char2nr('z')), 'nr2char(v:val)')
let s:tabnr2label = {}
let s:label2tabnr = {}

function! hinttab#move() abort
  if tabpagenr('$') ==# 1
    return
  endif
  let save_tabline = &tabline
  set tabline=%!hinttab#tabline()
  try
    redraw
    echo 'SELECT tab label: '
    let selected = nr2char(getchar())
    if has_key(s:label2tabnr, selected)
      let nr = s:label2tabnr[selected]
      execute nr . 'tabnext'
    endif
  finally
    let &tabline = save_tabline
  endtry
endfunction

function! s:tabpage_label(n) abort
  let bufnrs = tabpagebuflist(a:n)
  let curbufnr = bufnrs[tabpagewinnr(a:n) - 1]
  let fname = pathshorten(bufname(curbufnr))[-15:]
  if fname ==# ''
    let fname = '[No Name]'
  endif
  let hi = a:n is tabpagenr() ? '%#TabLineSel#' : '%#TabLine#'
  let label = '[' . get(s:tabnr2label, a:n, 'INVALID') . ']'
  let text = printf('%%#ErrorMsg#%s%s', label, hi) . fname
  return printf('%%%dT%s%s%%T%%#TabLineFill#', a:n, hi, text)
endfunction

function! hinttab#tabline() abort
  let tabpagenrs = range(1, tabpagenr('$'))
  let s:label2tabnr = s:Hint.create(tabpagenrs, s:keys)
  let s:tabnr2label = s:Dict.swap(s:label2tabnr)
  let titles = map(copy(tabpagenrs), 's:tabpage_label(v:val)')
  let sep = '|'
  let tabpages = join(titles, sep) . sep . '%#TabLineFill#%T'
  return tabpages
endfunction


