" Vim syntax file for Apache Velocity templates (.vm). The bos templates are HTML
" underneath, so this layers Velocity directives, references and comments on top
" of the html syntax -- including inside attributes, <style> and <script>.

if exists("b:current_syntax")
  finish
endif

runtime! syntax/html.vim
unlet! b:current_syntax

syn case match

" macro calls: #formatNumber(...), #@bodyMacro(...)
syn match velocityMacro "#@\=\h\w*\ze\s*(" containedin=ALLBUT,velocityComment,velocityBlockComment,velocityDirective

" directives: #if(...), #{else}, #end (defined after macros so #if( wins)
syn match velocityDirective "#{\=\%(if\|elseif\|else\|end\|foreach\|set\|parse\|include\|evaluate\|define\|macro\|break\|stop\)\>}\="
      \ containedin=ALLBUT,velocityComment,velocityBlockComment,velocityMacro

" references: $foo.bar, $!foo, ${foo.bar}, $!{foo}
syn match velocityReference "\$!\=\h\w*\%(\.\h\w*\)*" containedin=ALLBUT,velocityComment,velocityBlockComment
syn match velocityReference "\$!\={[^}]*}" containedin=ALLBUT,velocityComment,velocityBlockComment

" comments: ## line, #* block *#
syn keyword velocityTodo contained TODO FIXME XXX NOTE HACK
syn match   velocityComment "##.*$" contains=velocityTodo containedin=ALLBUT,velocityComment,velocityBlockComment
syn region  velocityBlockComment start="#\*" end="\*#" contains=velocityTodo containedin=ALLBUT,velocityComment,velocityBlockComment

hi def link velocityDirective    Statement
hi def link velocityMacro        Macro
hi def link velocityReference    Identifier
hi def link velocityComment      Comment
hi def link velocityBlockComment Comment
hi def link velocityTodo         Todo

let b:current_syntax = "velocity"
