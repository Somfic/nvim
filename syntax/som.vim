" Vim syntax file for som, ported from som/editors/vscode/syntaxes/som.tmLanguage.json.
" The som LSP's semantic tokens refine this once the server attaches.

if exists("b:current_syntax")
  finish
endif

" comments
syn keyword somTodo contained TODO FIXME XXX NOTE HACK

" keyword.control
syn keyword somConditional if else match
syn keyword somRepeat      loop while for
syn keyword somStatement   break continue return
syn keyword somInclude     use
syn keyword somKeywordOp   in as

" keyword.other
syn keyword somKeyword     fn prop impl mod extern pub
syn keyword somStorage     let mut out
syn keyword somStructure   struct enum trait type
syn keyword somSelf        self

" constant.language
syn keyword somBoolean     true false
syn keyword somConstant    none

" types
syn keyword somType        i8 i16 i32 i64 i128 isize u8 u16 u32 u64 u128 usize f32 f64 bool char string cstr
syn match   somConstName   "\<[A-Z][A-Z0-9_]\+\>"
syn keyword somSelfType    Self
syn match   somBuiltin     "@\h\w*"

" definitions: the name after fn/prop, and after struct/enum/trait
syn match   somFuncName    "\%(\<\%(fn\|prop\)\s\+\)\@<=\h\w*"
syn match   somTypeName    "\%(\<\%(struct\|enum\|trait\)\s\+\)\@<=\h\w*"

" numbers
syn match   somNumber      "\<\%(0x[0-9a-fA-F_]\+\|0b[01_]\+\|\d[0-9_]*\)\>"
syn match   somFloat       "\<\d*\.\d\+\>"

" operators: later rules win at the same position, so multi-char forms come after
syn match   somOperator    "[+\-*/=!<>&|]"
syn match   somOperator    "==\|!=\|<=\|>=\|&&\|||"
syn match   somArrow       "->\|=>"
" raw pointer type after -> or :
syn match   somPointer     "\%(->\s\?\|:\s\?\)\@<=\*"

" comments come after the operators so `//` isn't two `/`
syn match   somComment "//.*$" contains=somTodo,@Spell

" strings, with escapes and {code} interpolation
syn cluster somCode contains=somComment,somConditional,somRepeat,somStatement,somInclude,somKeywordOp,somKeyword,somStorage,somStructure,somSelf,somBoolean,somConstant,somType,somConstName,somSelfType,somBuiltin,somFuncName,somTypeName,somNumber,somFloat,somOperator,somArrow,somString,somBraces
syn region  somBraces      start="{" end="}" contained transparent contains=@somCode
syn region  somInterp      matchgroup=somInterpDelim start="{" end="}" contained contains=@somCode
syn match   somEscape      "\\\%(x\x\{2}\|u{\x\{1,6}}\|.\)" contained
syn match   somEscape      "{{\|}}" contained
syn region  somString      start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=somEscape,somInterp,@Spell

hi def link somTodo        Todo
hi def link somComment     Comment
hi def link somConditional Conditional
hi def link somRepeat      Repeat
hi def link somStatement   Statement
hi def link somInclude     Include
hi def link somKeywordOp   Keyword
hi def link somKeyword     Keyword
hi def link somStorage     StorageClass
hi def link somStructure   Structure
hi def link somSelf        Special
hi def link somBoolean     Boolean
hi def link somConstant    Constant
hi def link somType        Type
hi def link somConstName   Constant
hi def link somSelfType    Type
hi def link somBuiltin     Macro
hi def link somPointer     Type
hi def link somFuncName    Function
hi def link somTypeName    Type
hi def link somNumber      Number
hi def link somFloat       Float
hi def link somOperator    Operator
hi def link somArrow       Operator
hi def link somInterpDelim Special
hi def link somEscape      SpecialChar
hi def link somString      String

let b:current_syntax = "som"
