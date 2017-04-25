#lang info
(define collection "chain-module-begin")
(define deps '("base"
               "rackunit-lib"
               "debug-scopes"))
(define build-deps '("scribble-lib"
                     "racket-doc"))
(define scribblings '(("scribblings/chain-module-begin.scrbl" ())))
(define pkg-desc "Use this to build meta-languages, where a #%module-begin expands to the #%module-begin of another user-specified language.")
(define version "0.1")
(define pkg-authors '("Georges Dupéron"))
