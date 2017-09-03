set nocompatible
lang mes C

" Esc timeout on Mac
set timeoutlen=500 ttimeoutlen=10

" Pathogen
filetype off
call pathogen#infect()
call pathogen#helptags()
let python_version_2 = 0
let python_highlight_all = 1
filetype plugin indent on
syntax on

set wildmenu " display all matching files when we tab complete
set list listchars=tab:❯\ ,trail:×
"set list listchars=tab:»·,trail:×

let g:netrw_banner=0 " Remove help info
let g:netrw_altv=1	 " Open split at right
let g:netrw_liststyle=3

set nobackup		  "don't save backup files
set number numberwidth=5
set hlsearch		  "highlight search matches
set ignorecase smartcase
set hidden			  "allow hiding buffers which have modifications
set linebreak		  "break lines, not words
set breakindent		  "break lines while preserving indentation
set showbreak=…		  "prepend ellipsis and 2 spaces at break
set laststatus=2	  "always show status
set backspace=2		  " make backspace work


"default indentation
set smartindent
set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab " use tabs (like 4 spaces)
set textwidth=0 wrapmargin=0 " don't auto wrap
set colorcolumn=80

"default files
set wildignore+=*.o,*.obj,*.pyc,*.pyo

"indent selection
xnoremap <Tab> >gv
xnoremap <S-Tab> <gv

"set sessionoptions=buffers,folds,options ",tabpages,help
"if has('win32') || has('win64')
"	 set directory=~/vimfiles/sessions/swaps/
"	 set viewdir=~/vimfiles/sessions/views/
"	 set undodir=~/vimfiles/sessions/undos/
"	 set viminfo='128,/128,:128,<128,s10,h,n~/vimfiles/sessions/viminfo
"else
"	 set directory=~/.local/share/nvim/swaps/
"	 set viewdir=~/.local/share/nvim/views/
"	 set undodir=~/.local/share/nvim/undos/
"	 set viminfo='128,/128,:128,<128,s10,h,n~/.local/share/nvim/viminfo
"endif


" --- Theme (&config) {{{
set background=dark
set cursorline

colorscheme hybrid
hi CursorLineNR ctermfg=243 ctermbg=none cterm=none
"hi Normal ctermfg=7
"hi SignColumn ctermbg=8 guibg=darkgrey
"hi SpecialKey ctermfg=8 guifg=gray
hi Folded ctermbg=0 cterm=none
"}}}


" --- STATUSLINE {{{
" Find out current buffer's size and output it.
fu! SLFileSize()
	let bytes = getfsize(expand('%:p'))
	if (bytes >= 1024)
		let kbytes = bytes / 1024
	endif
	if (exists('kbytes') && kbytes >= 1000)
		let mbytes = kbytes / 1000
	endif

	if (bytes <= 0)
		return '0'
	endif

	if (exists('mbytes'))
		return mbytes . 'MB'
	elseif (exists('kbytes'))
		return kbytes . 'KB'
	else
		return bytes . 'B'
	endif
endfu

fu! SLGitBranch()
	if exists('*fugitive#statusline')
		return substitute(fugitive#statusline(), '\c\v\[?GIT\(([a-z0-9\-_\./:]+)\)\]?', ':\1', 'g')
	else
		return ''
	endif
endfu

" now set it up to change the status line based on mode
fu! SLUpdateColor(mode)
	if a:mode == 'i'
		hi sl_mode ctermbg=2 guibg=#094afe
		hi sl_minor ctermfg=0 ctermbg=243
	elseif a:mode == 'r'
		hi sl_mode ctermbg=9 guibg=#094afe
		hi sl_minor ctermfg=0 ctermbg=243
	elseif a:mode == 'v'
		hi sl_mode ctermbg=13 guibg=#094afe
		hi sl_minor ctermfg=0 ctermbg=243
	else
		hi sl_mode ctermbg=4 guibg=#094afe
		hi sl_minor ctermfg=0 ctermbg=243
	endif
	return ''
endfu

"defaults
hi StatusLine ctermfg=0 ctermbg=243 guibg=DarkGrey guifg=White
hi StatusLineNC ctermfg=8 ctermbg=0 guibg=DarkGrey guifg=Black
hi sl_mode ctermfg=15 guifg=#ffffff  guibg=#094afe
set lazyredraw "required by this function
set laststatus=2
hi sl_branch ctermfg=11 ctermbg=8
hi sl_minor ctermfg=0 ctermbg=243


set stl=
set stl+=%{SLUpdateColor(mode())}%#sl_mode#\ %{toupper(mode())}
set stl+=\ %*
set stl+=%#sl_minor#\ %n:
set stl+=\ %<%#sl_file#%F%*
set stl+=%#sl_minor#%{&mod?'*':''}
set stl+=%#sl_branch#%{SLGitBranch()}%*
set stl+=%#sl_minor#
set stl+=\ %h%r(%{SLFileSize()})
if exists('ALEGetStatusLine()')
	set stl+=%{ALEGetStatusLine()}
endif
set stl+=\ ❯\ %{&ft!=''?&ft:'No-FT'}
set stl+=%{(&fenc!='utf-8'&&&fenc!='')?'\ \ >\ '.&fenc:''}
set stl+=%{(&ff!='unix'&&&ff!='')?'\ \ >\ '.&ff:''}
set stl+=%*
set stl+=\ %=
" Symbols
"set stl+={%{synIDattr(synID(line('.'),col('.'),1),'name')}}
"set stl+=\ \%w(%b,0x%B)
set stl+=\ %#sl_minor#%c%*
set stl+=\ (%l\ of\ %L)\ %P\ 
" endSTATUSLINE }}}


" --- Leader {{{
let mapleader="," "set leader

" Toggle
nmap <leader>tp :setl paste!<CR>
nmap <leader>ts :setl spell!<CR>
nmap <Leader>tz :call ZenMode()<CR>
nmap <Leader>tt :TagbarToggle<CR>

" Reindent file
nmap <leader>fi mzgg=G`z

let b:zenmode = 0
fu! ZenMode()
	if b:zenmode
		let b:zenmode = 0
		Goyo!
	else
		let b:zenmode = 1
		Goyo
	endif
endfu

fu! s:goyo_enter()
	silent !tmux set status off
	silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
	"set noshowmode
	"set noshowcmd
	set scrolloff=99
	set list!
	Limelight
	let b:quitting = 0
	let b:quitting_bang = 0
	autocmd QuitPre <buffer> let b:quitting = 1
	cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!
endfunction

fu! s:goyo_leave()
	silent !tmux set status on
	silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
	"set showmode
	"set showcmd
	set scrolloff=5
	set list listchars=tab:❯\ ,trail:×
	Limelight!
	if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
		if b:quitting_bang
			qa!
		else
			qa
		endif
	endif
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()


" Append modeline after last line in buffer.
" Use substitute() instead of printf() to handle '%%s' modeline in LaTeX files.
function! AppendModeline()
	let l:modeline = printf(" vim: set ts=%d sw=%d tw=%d %set :", &tabstop, &shiftwidth, &textwidth, &expandtab ? '' : 'no')
	let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
	call append(line("$"), l:modeline)
endfunction
nnoremap <silent> <Leader>ml :call AppendModeline()<CR>

map <silent><leader>v :tabnew $MYVIMRC<CR>
map <silent><leader>e :tabnew $MYVIMRC<CR>
if has('gui')
	map <silent><leader>u :call UpdateConfig()<CR>
else
	map <silent><leader>u :source $MYVIMRC<CR>
endif
"}}}


" --- Folding {{{
set foldtext=SimpleFoldText()
fu! SimpleFoldText()
	let nl = v:foldend - v:foldstart + 1
	let foldline = substitute(getline(v:foldstart), "^ *", "", 1)
	let nextline = substitute(getline(v:foldstart + 1), "^ *", "", 1)
	let txt = '+ ' .  foldline . repeat(' ', winwidth(0))
	let info = ' ' . nl . ' lines '
	let num_w = getwinvar(0, '&number') * getwinvar(0, '&numberwidth')
	let fold_w = getwinvar(0, '&foldcolumn')
	let txt = strpart(txt, 0, winwidth(0) - strlen(info) - num_w - fold_w - 2)
	return txt . info
endfu
"}}}


" --- Helpers {{{
fun! ReadGitIgnore()
	let filename = '.gitignore'
	if filereadable(filename)
		let igstring = ''
		for oline in readfile(filename)
			let line = substitute(oline, '\s|\n|\r', '', "g")
			if line =~ '^#' | con | endif
			if line == '' | con  | endif
			if line =~ '^!' | con  | endif
			if line =~ '/$' | let igstring .= "," . line . "*" | con | endif
			let igstring .= "," . line
		endfor
		let execstring = "set wildignore=".substitute(igstring, '^,', '', "g")
		execute execstring
	else
		echo "Can't find '" . filename . "' at current path."
	endif
endf

ino <C-A> <C-O>yiW<End>=<C-R>=<C-R>0<CR>


if !exists("*UpdateConfig")
	fu! UpdateConfig()
		:source $MYVIMRC
		if has('gui')
			:source $MYGVIMRC
		endif
	endf
endif

if has('autocmd')
	" auto reload config after save
	au! BufWritePost init.vim :call UpdateConfig()

	au! FileType svn,*commit*,*.txt,*.md :setl spell spelllang=en,ru
	au! BufWinEnter,FileType help :setl cc=0

	" auto store/restore views
	au! BufWinLeave ?* mkview
	au! BufWinEnter ?* silent loadview

	" Change date on pl scripts (irssi)
	"au! BufWrite *.pl %s/changed\s=> '.*/="changed => '" . strftime("%c") . "',"/e
endif
"}}}


" Plugins

" Goyo {{{
let g:goyo_height=92
let g:goyo_width=99
"}}}

" TagBar {{{
let g:tagbar_width = 18
let g:tagbar_zoomwidth = 0
let g:tagbar_autoclose = 1
let g:tagbar_autofocus = 1
let g:tagbar_compact = 1
let g:tagbar_show_visibility = 1
let g:tagbar_iconchars = ['+', '-']
" }}}
