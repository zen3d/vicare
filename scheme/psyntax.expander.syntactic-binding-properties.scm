;;;Copyright (c) 2010-2014 Marco Maggi <marco.maggi-ipsu@poste.it>
;;;Copyright (c) 2006, 2007 Abdulaziz Ghuloum and Kent Dybvig
;;;
;;;Permission is hereby granted, free of charge, to any person obtaining
;;;a  copy of  this  software and  associated  documentation files  (the
;;;"Software"), to  deal in the Software  without restriction, including
;;;without limitation  the rights to use, copy,  modify, merge, publish,
;;;distribute, sublicense,  and/or sell copies  of the Software,  and to
;;;permit persons to whom the Software is furnished to do so, subject to
;;;the following conditions:
;;;
;;;The  above  copyright notice  and  this  permission  notice shall  be
;;;included in all copies or substantial portions of the Software.
;;;
;;;THE  SOFTWARE IS  PROVIDED "AS  IS",  WITHOUT WARRANTY  OF ANY  KIND,
;;;EXPRESS OR  IMPLIED, INCLUDING BUT  NOT LIMITED TO THE  WARRANTIES OF
;;;MERCHANTABILITY,    FITNESS   FOR    A    PARTICULAR   PURPOSE    AND
;;;NONINFRINGEMENT.  IN NO EVENT  SHALL THE AUTHORS OR COPYRIGHT HOLDERS
;;;BE LIABLE  FOR ANY CLAIM, DAMAGES  OR OTHER LIABILITY,  WHETHER IN AN
;;;ACTION OF  CONTRACT, TORT  OR OTHERWISE, ARISING  FROM, OUT OF  OR IN
;;;CONNECTION  WITH THE SOFTWARE  OR THE  USE OR  OTHER DEALINGS  IN THE
;;;SOFTWARE.


;;;; identifiers: syntactic binding properties

(define* (syntactic-binding-putprop {id identifier?} {key symbol?} value)
  (putprop (id->label/or-error __who__ id id) key value))

(define* (syntactic-binding-getprop {id identifier?} {key symbol?})
  (getprop (id->label/or-error __who__ id id) key))

(define* (syntactic-binding-remprop {id identifier?} {key symbol?})
  (remprop (id->label/or-error __who__ id id) key))

(define* (syntactic-binding-property-list {id identifier?})
  (property-list (id->label/or-error __who__ id id)))


;;;; identifiers: unsafe variants API
;;
;;With the function SET-IDENTIFIER-UNSAFE-VARIANT! and the syntax UNSAFE
;;we allow the  user to select an  unsafe variant of a  function or (why
;;not?)  macro.
;;
;;The unsafe  variant of  a function  is a  function that  (not strictly
;;speaking) neither  validates its arguments  nor its return  value.  As
;;example, the function:
;;
;;   (define* ((string-ref-fx fixnum?) (str string?) (idx fixnum?))
;;     ($char->fixnum ($string-ref str idx)))
;;
;;can be split into:
;;
;;   (define* ((string-ref-fx fixnum?) (str string?) (idx fixnum?))
;;     ($string-ref-fx str idx))
;;
;;   (define ($string-ref-fx str idx)
;;     ($char->fixnum ($string-ref str idx)))
;;
;;where  $STRING-REF-FX  is the  unsafe  variant  of STRING-REF-FX;  the
;;unsafe variants  API allows us to  register this fact, for  use by the
;;expander, as follows:
;;
;;   (begin-for-syntax
;;     (set-identifier-unsafe-variant! #'string-ref-fx
;;       #'$string-ref-fx))
;;
;;so, having imported  the binding STRING-REF-FX, we can  use its unsafe
;;variant as follows:
;;
;;   ((unsafe string-ref-fx) "ciao" 2)
;;
;;without actually importing the binding $STRING-REF-FX.
;;
;;We  use  syntactic  binding  properties  to  implement  this  feature:
;;SET-IDENTIFIER-UNSAFE-VARIANT!   puts  a  property  in  the  syntactic
;;binding, which is later retrieved  by the UNSAFE syntax.  The property
;;value  must  be a  syntax  object  representing an  expression  which,
;;expanded and evaluated, returns the unsafe variant.
;;
;;When specifying  the unsafe variant  of a  function we should  build a
;;syntax  object   representing  an   expression  which,   expanded  and
;;evaluated, returns a  proper function; so that it can  be used in both
;;the expressions:
;;
;;  ((unsafe fx+) 1 2)
;;  (map (unsafe fx+) '(1 2) '(3 4))
;;
;;so for FX+ we should do:
;;
;;  (begin-for-syntax
;;    (set-identifier-unsafe-variant! #'fx+
;;      #'(lambda (a b) ($fx+ a b))))
;;
;;because $FX+ is not a function, rather it is a primitive operation.
;;

(define-constant *UNSAFE-VARIANT-COOKIE*
  'vicare:expander:unsafe-variant)

(define* (set-identifier-unsafe-variant! {safe-id identifier?} {unsafe-expr-stx <stx>?})
  (if (syntactic-binding-getprop safe-id *UNSAFE-VARIANT-COOKIE*)
      (syntax-violation __who__
	"unsafe variant already defined" safe-id unsafe-expr-stx)
    (syntactic-binding-putprop safe-id *UNSAFE-VARIANT-COOKIE* unsafe-expr-stx)))


;;;; identifiers: predicates axiliary functions API
;;
;;Predicate functions, both type  predicates and generic predicates, are
;;used to  validate procedure  arguments and  their return  values.  The
;;predicates  auxiliary  functions API  assumes  that  it is  useful  to
;;associate to certain predicate procedures:
;;
;;*  A procedure  that validates  a tuple  of values  and when  failing:
;;  raises     an    exception     with     condition    object     type
;;  &procedure-argument-violation.
;;
;;*  A procedure  that validates  a tuple  of values  and when  failing:
;;  raises     an    exception     with     condition    object     type
;;  &expression-return-value-violation.
;;
;;Such auxiliary functions are  made available through syntactic binding
;;properties  by  just importing  in  the  current lexical  contour  the
;;identifier bound to the predicate function.
;;
;;As example, we  can associate a procedure  argument auxiliary function
;;to LIST? as follows:
;;
;;   (define (list-procedure-argument who obj)
;;     (if (list? obj)
;;         obj
;;       (procedure-argument-violation who
;;         "expected list object as argument" obj)))
;;
;;   (begin-for-syntax
;;     (set-predicate-procedure-argument-validation! #'list?
;;       #'list-procedure-argument?))
;;
;;   ((predicate-procedure-argument-validation list?) 'hey '(1 2 3))
;;   => (1 2 3)
;;
;;   ((predicate-procedure-argument-validation list?) 'hey '#(1 2 3))
;;   error--> &procedure-argument-violation
;;
;;and we  can associate a return  value auxiliary function to  LIST?  as
;;follows:
;;
;;   (define (list-return-value? who obj)
;;     (if (list? obj)
;;         obj
;;       (expression-return-value-violation who
;;         "expected list object as argument" obj)))
;;
;;   (begin-for-syntax
;;     (set-predicate-return-value-validation! #'list?
;;       #'list-return-value?))
;;
;;    ((predicate-return-value-validation list?) 'hey '(1 2 3))
;;    => (1 2 3)
;;
;;    ((predicate-return-value-validation list?) 'hey '#(1 2 3))
;;    error--> &expression-return-value-violation
;;

(define-constant *PREDICATE-PROCEDURE-ARGUMENT-VALIDATION-COOKIE*
  'vicare:expander:predicate-procedure-argument-validation)

(define-constant *PREDICATE-RETURN-VALUE-VALIDATION-COOKIE*
  'vicare:expander:predicate-return-value-validation)

(define* (set-predicate-procedure-argument-validation! {pred-id identifier?} {validation-stx <stx>?})
  (if (syntactic-binding-getprop pred-id *PREDICATE-PROCEDURE-ARGUMENT-VALIDATION-COOKIE*)
      (syntax-violation __who__
	"predicate procedure argument validation already defined"
	pred-id validation-stx)
    (syntactic-binding-putprop pred-id *PREDICATE-PROCEDURE-ARGUMENT-VALIDATION-COOKIE*
			       validation-stx)))

(define* (set-predicate-return-value-validation! {pred-id identifier?} {validation-stx <stx>?})
  (if (syntactic-binding-getprop pred-id  *PREDICATE-RETURN-VALUE-VALIDATION-COOKIE*)
      (syntax-violation __who__
	"predicate procedure argument validation already defined"
	pred-id validation-stx)
    (syntactic-binding-putprop pred-id *PREDICATE-RETURN-VALUE-VALIDATION-COOKIE*
			       validation-stx)))



;;;; done

;;; end of file
;; Local Variables:
;; mode: vicare
;; End: