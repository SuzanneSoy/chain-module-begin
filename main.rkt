#lang racket/base

(provide chain-module-begin)

(require (for-syntax racket/base
                     syntax/parse
                     debug-scopes/named-scopes/exptime))

(define-syntax continue
  (syntax-parser
    [(_ whole-ctx lang lang-modbeg . body)
     #:with ({~literal #%plain-module-begin} . expanded-body)
     (local-expand (datum->syntax #'whole-ctx
                                  `(,#'lang-modbeg . ,#'body)
                                  #'whole-ctx)
                   'module-begin
                   '())
     (define new-scope (make-module-like-named-scope
                        (format "nested-lang-~a" (syntax-e #'lang))))
     (new-scope #`(begin . expanded-body))]))

(define-syntax chain-module-begin
  (syntax-parser
    [{~and whole (_ lang . body)}
     #:with lang-modbeg (datum->syntax #'lang '#%module-begin #'lang)
     #:with whole-ctx (datum->syntax #'whole 'ctx #'whole)
     #'(#%plain-module-begin
        (require lang)
        (continue whole-ctx lang lang-modbeg . body))]))