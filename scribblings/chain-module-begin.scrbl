#lang scribble/manual
@require[@for-label[chain-module-begin
                    racket/base]]

@title{Chaining module languages}
@author[@author+email["Suzanne Soy" "racket@suzanne.soy"]]

@defmodule[chain-module-begin]

This package is experimental. Later versions may break backward-compatibility.

@defform[(chain-module-begin lang . body)]{
 This macro is intended to be used as the result of a @racket[#%module-begin]
 macro. It chain-calls the @racket[#%module-begin] of @racket[lang]. This makes
 it possible for a @racket[#%module-begin] to perform some changes on its body,
 and then chain-call the @racket[#%module-begin] of a user-specified language.

 As an example here is the definition for a no-op language, which simply takes a
 (possibly improper) list of languages to chain, and calls the next one:

 @racketblock[
 (module the-meta-lang racket/base
   (provide (rename-out [new-#%module-begin #%module-begin]))

   (require chain-module-begin
            (for-syntax racket/base
                        syntax/parse))

   (define-syntax (new-#%module-begin stx)
     (syntax-parse stx
       [(_ {~or next-lang:id (next-lang:id . chain₊)} . body)
        (define maybe-chain₊ (if (attribute chain₊)
                                 `(,#'chain₊)
                                 '()))
        (define new-form `(,#'chain-module-begin ,#'next-lang ,@maybe-chain₊
                                                 . ,(transform-body #'body)))
        (datum->syntax stx new-form stx stx)]))

   (define-for-syntax (transform-body body)
     (code:comment "identity transformation:")
     body))]

 This language could then be used as follows:

 @racketblock[
 (module b the-meta-lang typed/racket
   (define x : Number 123))]

 Given two other meta-language built in the same way and provided by
 @racketid[meta-two] and @racketid[meta-three], it would be possible
 to chain the three languages as follows:

 @racketblock[
 (module b the-lang (meta-two meta-three . typed/racket)
   (define x : Number 123))]
 
 The @racket[chain-module-begin] macro produces the following syntax:

 @racketblock[(#%plain-module-begin
               (require lang)
               (continue . internal-args))]

 where @racket[(continue . _internal-args)] fully expands
 @racket[(#%module-begin . body)], where @racket[#%module-begin] is the one
 provided by @racket[lang], and produces the following syntax:

 @racketblock[(begin . _expanded-body)]

 An extra scope is added to the whole @racket[(begin . _expanded-body)] form,
 so that a @racket[#%require] form within the @racket[_expanded-body] may
 shadow bindings provided by @racket[lang], just as @racket[require] forms
 normally have the possibility to shadow bindings provided by the @(hash-lang)
 language.}