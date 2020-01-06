" remove all autocmds to prevent dupes during sourcing
"autocmd!


" put the current filename in the title
set title


" don't tell me where I am, I probably know
set noshowmode
" but do tell me about two-line changes
set report=1


" case isn't important in searches
set ignorecase
" except when it is
set smartcase
" see it live today!
set incsearch
" and show the others too
set hlsearch
" toggle search highlighting
noremap <silent> <F5> :let &hlsearch =! &hlsearch<CR>


" I like my tabs to be two spaces
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set shiftround

nmap <silent> TS :se ts=2 sts=2 sw=2 et<CR>
nmap <silent> TR :se ts=4 sts=4 sw=4 et<CR>
nmap <silent> TT :se ts=4 sts=4 sw=4 noet<CR>
nmap <silent> TC :se ts=8 sts=4 sw=4 noet<CR>

" write the file if I'm moving around and it changed
set autowrite
" save and sync every ten keys
"set updatecount=10
"set swapsync=fsync


" something like the default status line, with git magic
"set statusline=%{fugitive#statusline()}\ %f\ %h%m%r\ %<%(%{Tlist_Get_Tag_Prototype_By_Line()}%)\ %=%-14.(%l,%c%V%)\ %P
" I like the status line, even if this is the only window
set laststatus=2

" I do lotsa macro thing
set lazyredraw

" indent
set autoindent
" with magic curlies
set smartindent
" and non-magic hashes
inoremap # X<C-H>#
" and magical keywords
" !!! these should be different for different filetypes
set cinwords=if,elsif,else,unless,while,until,for,foreach

" long lines are great
set textwidth=0

" wrap comments [c], add comment leaders [ro], allow comment formatting with
" gq [q], don't break long lines [l]
set formatoptions=croql

" for extra perlishness. the double ones are the future, apparently
set matchpairs+=<:>


" braindead in most places
set backspace=indent,start,eol


" if the current split is full expanded, make all splits equal, otherwise
" expand the current one
function! ToggleSplitMaxEven()
    let min_height = -1
    let max_height = -1

    let last_window = winnr("$")

    let window = 1
    while window <= last_window
        let height = winheight(window)

        if min_height == -1 || min_height < height
            let min_height = height
        endif

        if max_height == -1 || max_height > height
            let max_height = height
        endif

        let window = window + 1
    endwhile

    let difference = max_height - min_height
    if difference < 0
        let difference = -difference
    endif

    if difference <= 1
        resize
    else
        execute ":normal \<C-W>="
    endif
endfunction

nmap <silent> <TAB><CR>      :call ToggleSplitMaxEven()<CR>

nmap <silent> <TAB><Up>      <C-W>k
nmap <silent> <TAB><Down>    <C-W>j
nmap <silent> <TAB><Left>    <C-W>k:resize<CR>
nmap <silent> <TAB><Right>   <C-W>j:resize<CR>
nmap <silent> <TAB><TAB>     :sp<CR>
nmap          <TAB><Space>   :split 

" make collapsed splits tiny, just a status bar
set winminheight=0


" turn all the completion options on
set wildmode=list:longest,full

" complete where appropriate in insert mode, otherwise tab
function! TabOrCompletion()
    let col = col('.') - 1
    if !col || getline('.')[col-1] !~ '\k'
        return "\<TAB>"
    else
        return "\<C-N>"
    endif
endfunction
inoremap <silent> <TAB> <C-R>=TabOrCompletion()<CR>


" follow tags in a new split
"noremap <F7> :sp<CR><C-]>

nmap <silent> <F7> :TagbarToggle<CR>

let g:tagbar_type_rust = {
    \ 'ctagstype' : 'rust',
    \ 'kinds' : [
        \'T:types,type definitions',
        \'f:functions,function definitions',
        \'g:enum,enumeration names',
        \'s:structure names',
        \'m:modules,module names',
        \'c:consts,static constants',
        \'t:traits,traits',
        \'i:impls,trait implementations',
    \]
\}


" reformat a paragraph
" !!! needs some tweaks eg hangling list indents, mail quoting
noremap <F8> gqip


" look for a xterm-256color definition in a rather bruteforce way
" this works because I only use 256 colour xterms
if &t_Co != 256 && &term == "xterm"
    set term=xterm-256color
    if &t_Co == ""
        set term=xterm
    endif
endif

" load a nice colour scheme if we can
"if &t_Co == 256
    "colorscheme inkpot
"    colorscheme zenburn
"endif

" some basics. note the grey - I don't want everything exploded
"highlight  Normal            ctermfg=7
"highlight  Comment           ctermfg=4  cterm=bold
"highlight  Constant          ctermfg=6  cterm=bold
"highlight  Identifier        ctermfg=7
"highlight  Statement         ctermfg=2  cterm=bold
"highlight  PreProc           ctermfg=3  cterm=bold
"highlight  Type              ctermfg=1  cterm=bold
"highlight  Special           ctermfg=7  cterm=bold

" perl sub names
"highlight  perlFunctionName  ctermfg=red

" colour pod embedded in perl files
" let perl_include_pod = 1

" colours are go
syntax enable

" *.asm should use nasm syntax modes
let asmsyntax = "nasm"

" these functions override certain settings based on file type, and are called
" by the autocmds below
function! FiletypeText()
    " wrap everything [t], wrap comments [c], allow formatting [q]
    set formatoptions=tcq
    " don't do magical indenting
    set nosmartindent
    " reasonable width for text
    set textwidth=78
endfunction

function! FiletypeMail()
    " mail is like text
    call FiletypeText()
    " but not as wide
    set textwidth=72
endfunction

function! FiletypeMake()
    " makefiles care about tabs
    set noexpandtab
endfunction

function! FiletypeAsm()
    " semicolon is a comment
    set comments+=b:;
endfunction

function! FiletypeAvr()
    " semicolon is a comment
    set comments+=b:;
endfunction


" do by-filetype config
autocmd Filetype text   call FiletypeText()
autocmd Filetype mail   call FiletypeMail()
autocmd Filetype make   call FiletypeMake()
autocmd Filetype asm    call FiletypeAsm()
autocmd Filetype avr    call FiletypeAvr()

" other extensions that I use
autocmd BufRead,BufNewFile *.phtml,*.epl,*.em,*.ev,*.ec,*.et,*.psgi setlocal filetype=perl

" don't complete from included files, since the perl autoincluder is
" extremely greedy and takes forever to do its work
autocmd FileType perl set complete-=i

command! SetGLSLFileType call SetGLSLFileType()
function! SetGLSLFileType()
  for item in getline(1,10)
    if item =~ "#version 400"
      execute ':set filetype=glsl400'
      break
    endif
    if item =~ "#version 330"
      execute ':set filetype=glsl330'
      break
    endif
    execute ':set filetype=glsl'
  endfor
endfunction

au BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl SetGLSLFileType

" default to text
"if &filetype == ""
"    setfiletype text
"endif

" reset filetype when leaving insert mode (in case we changed #!)
"if version >= 700
"    autocmd InsertLeave * filetype detect
"endif

" enter makes magic happen
function! CRMagic()
    " leaving line 1, reset filetype (maybe we changed #!)
    if line(".") == 1
        filetype detect
    endif
    " still want a real enter character
    return "\<CR>"
endfunction
inoremap <silent> <CR> <C-R>=CRMagic()<CR>


" do double-angles
"inoremap <<< <C-V>171
"inoremap >>> <C-V>187


" do the a build, open quickfix
nmap <silent> M :silent make -j9<CR><C-l>
autocmd QuickFixCmdPost [^l]* nested copen
autocmd QuickFixCmdPost    l* nested lopen


"function! PasteToPasteBin()
"    let text = getreg('"')
"    if strlen(text) == 0
"        echo "Nothing to paste."
"        return
"    endif
"    echo "Pasting..." system("curl -s -w '%{redirect_url}' --data-urlencode code2@- -d format=text -d paste=Send -d expiry=d -d parent_pid= -d poster= http://pastebin.mozilla.org", getreg('"'))
"endfunction
"nmap <silent> <TAB><TAB> :call PasteToPasteBin()<CR>

let Tlist_Process_File_Always = 1

" Highlight trailing whitespace in red
highlight TrailingWS ctermbg=174
let m = matchadd("TrailingWS", "[ \t]\\+$")

set listchars=tab:>-
set list

" The new XXX
iabbr --r -- robn, <C-R>=strftime("%Y-%m-%d")<CR>


" Airline extensions

let g:airline_powerline_fonts = 0

" Show git branch name
let g:airline#extensions#branch#enabled = 1

" Show tags
let g:airline#extensions#tagbar = 1
" Show function signatures
let g:airline#extensions#tagbar#flags = 's'


" Vundle
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

let g:vundle_default_git_proto = 'git'

" let Vundle manage Vundle
Plugin 'VundleVim/Vundle.vim'

" Bundles
"Plugin 'tpope/vim-fugitive'
Plugin 'rust-lang/rust.vim'
Plugin 'mileszs/ack.vim'
Plugin 'vim-perl/vim-perl'
"Plugin 'pjcj/vim-hl-var'
Plugin 'cespare/vim-toml'
"Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'
Plugin 'vim-airline/vim-airline'
Plugin 'majutsushi/tagbar'
"Plugin 'tomasr/molokai'
Plugin 'edkolev/promptline.vim'
"Plugin 'altercation/vim-colors-solarized'
"Plugin 'w0ng/vim-hybrid'
Plugin 'nanotech/jellybeans.vim'
"Plugin 'c9s/perlomni.vim'
Plugin 'udalov/kotlin-vim'
Plugin 'arrufat/vala.vim'

call vundle#end()
filetype plugin indent on
" end Vundle

" Use ag for ack
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

" Promptline
" :PromptlineSnapshot! ~/.bash_prompt

let g:promptline_theme = 'powerlineclone'
let g:promptline_powerline_symbols = 0
let g:promptline_symbols = {
    \ 'left'       : '',
    \ 'left_alt'   : '',
    \ 'dir_sep'    : ' / ',
    \ 'truncation' : '…',
    \ 'vcs_branch' : '',
    \ 'space'      : ' '}
let g:promptline_preset = {
    \'a' : [ promptline#slices#host() ],
    \'b' : [ promptline#slices#user() ],
    \'c' : [ promptline#slices#cwd() ],
    \'x' : [ promptline#slices#vcs_branch(), promptline#slices#git_status() ],
    \'warn' : [ promptline#slices#last_exit_code() ],
    \'z' : [ '\$' ],
    \'options': {
      \'left_sections' : [ 'a', 'b' ],
      \'right_sections' : [ 'c' ],
      \'left_only_sections' : [ 'a', 'b', 'c', 'x', 'warn', 'z' ]}}


set background=dark
colorscheme jellybeans
