;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Vicare Scheme
;;;Contents: tests for the compiler internals
;;;Date: Fri Sep 19, 2014
;;;
;;;Abstract
;;;
;;;	Test the compiler pass "introduce unsafe primrefs".
;;;
;;;Copyright (C) 2014 Marco Maggi <marco.maggi-ipsu@poste.it>
;;;
;;;This program is free software: you can  redistribute it and/or modify it under the
;;;terms  of  the GNU  General  Public  License as  published  by  the Free  Software
;;;Foundation,  either version  3  of the  License,  or (at  your  option) any  later
;;;version.
;;;
;;;This program is  distributed in the hope  that it will be useful,  but WITHOUT ANY
;;;WARRANTY; without  even the implied warranty  of MERCHANTABILITY or FITNESS  FOR A
;;;PARTICULAR PURPOSE.  See the GNU General Public License for more details.
;;;
;;;You should have received a copy of  the GNU General Public License along with this
;;;program.  If not, see <http://www.gnu.org/licenses/>.
;;;


#!vicare
(import (vicare)
  (vicare checks)
  (prefix (vicare system $compiler)
	  compiler.))

(check-set-mode! 'report-failed)
(check-display "*** testing Vicare compiler pass: unsafe primrefs introduction\n")

(compiler.$descriptive-labels #t)

#;(debug-print-enabled? #t)


;;;; helpers

(define (gensyms->symbols sexp)
  (cond ((pair? sexp)
	 (cons (gensyms->symbols (car sexp))
	       (gensyms->symbols (cdr sexp))))
	((vector? sexp)
	 (vector-map gensyms->symbols sexp))
	((gensym? sexp)
	 (string->symbol (symbol->string sexp)))
	(else sexp)))

;;; --------------------------------------------------------------------
;;; expansion helpers

(define-constant THE-ENVIRONMENT
  (environment '(vicare)))

(define (%expand standard-language-form)
  (receive (code libs)
      (expand-form-to-core-language standard-language-form THE-ENVIRONMENT)
    code))

(define (%expand-library standard-language-form)
  (cdr (assq 'invoke-code (expand-library->sexp standard-language-form))))

(define (%make-annotated-form form)
  (let* ((form.str (receive (port extract)
		       (open-string-output-port)
		     (unwind-protect
			 (begin
			   (display form port)
			   (extract))
		       (close-port port))))
	 (port     (open-string-input-port form.str)))
    (unwind-protect
	(get-annotated-datum port)
      (close-port port))))

;;; --------------------------------------------------------------------

(define (%core-type-inference core-language-form)
  (let* ((D (compiler.$recordize core-language-form))
	 (D (compiler.$optimize-direct-calls D))
	 (D (compiler.$optimize-letrec D))
	 ;;Source optimisation is skipped here to  make it easier to write meaningful
	 ;;code for debugging and inspection.
	 #;(D (compiler.$source-optimize D))
	 (D (compiler.$rewrite-references-and-assignments D))
	 (D (compiler.$core-type-inference D))
	 (S (compiler.$unparse-recordized-code/sexp D)))
    S))

(define (%introduce-unsafe-primrefs core-language-form)
  (let* ((D (compiler.$recordize core-language-form))
	 (D (compiler.$optimize-direct-calls D))
	 (D (compiler.$optimize-letrec D))
	 ;;Source optimisation is skipped here to  make it easier to write meaningful
	 ;;code for debugging and inspection.
	 #;(D (compiler.$source-optimize D))
	 (D (compiler.$rewrite-references-and-assignments D))
	 (D (compiler.$core-type-inference D))
	 (D (compiler.$introduce-unsafe-primrefs D))
	 (S (compiler.$unparse-recordized-code/sexp D)))
    S))

(define-syntax doit
  (syntax-rules ()
    ((_ ?core-language-form ?expected-result)
     (check
	 (%introduce-unsafe-primrefs (quasiquote ?core-language-form))
       => (quasiquote ?expected-result)))
    ))

(define-syntax doit*
  (syntax-rules ()
    ((_ ?standard-language-form ?expected-result)
     ;;We want the ?STANDARD-LANGUAGE-FORM to appear  in the output of CHECK when a
     ;;test fails.
     (doit ,(%expand (quasiquote ?standard-language-form))
	   ?expected-result))
    ))

(define-syntax libdoit*
  (syntax-rules ()
    ((_ ?standard-language-form ?expected-result/basic)
     (doit ,(%expand-library (quasiquote ?standard-language-form)) ?expected-result/basic))
    ))

;;; --------------------------------------------------------------------

(define-syntax check-arity-error
  (syntax-rules ()
    ((_ ?form)
     (check
	 (guard (E ((compiler.compile-time-arity-error? E)
		    #t)
		   (else E))
	   (%introduce-unsafe-primrefs (quasiquote ?form)))
       => #t))
    ))

(define-syntax check-operand-core-type-error
  (syntax-rules ()
    ((_ ?form)
     (check
	 (guard (E ((compiler.compile-time-operand-core-type-error? E)
		    #t)
		   (else E))
	   (%introduce-unsafe-primrefs (quasiquote ?form)))
       => #t))
    ))


(parametrise ((check-test-name	'fixnums))

  ;; (doit ((primitive fx+) '1 '2)
  ;; 	(funcall (primref $fx+/overflow)
  ;; 	  (known (constant 1)
  ;; 		 (T:fixnum T:positive T:non-false T:exact T:number T:immediate T:object))
  ;; 	  (known (constant 2)
  ;; 		 (T:fixnum T:positive T:non-false T:exact T:number T:immediate T:object))))

  #t)


(parametrise ((check-test-name	'arithmetics))

  ;;Two fixnum operands: successful replacement.
  (doit ((primitive +) '1 '2)
  	(funcall (primref $add-fixnum-fixnum)
  	  (known (constant 1)
  		 (T:fixnum T:positive T:non-false T:exact T:number T:immediate T:object))
  	  (known (constant 2)
  		 (T:fixnum T:positive T:non-false T:exact T:number T:immediate T:object))))

  ;;Fixnum, flonum operands: successful replacement.
  (doit ((primitive +) '1 '2.2)
	(funcall (primref $add-fixnum-flonum)
	  (known (constant 1)
		 (T:fixnum T:positive T:non-false T:exact T:number T:immediate T:object))
	  (known (constant 2.2)
		 (T:flonum T:positive T:non-false T:nonimmediate T:inexact T:number T:object))))

  ;;Flonum, fixnum operands: successful replacement.
  (doit ((primitive +) '1.1 '2)
	(funcall (primref $add-flonum-fixnum)
	  (known (constant 1.1)
		 (T:flonum T:positive T:non-false T:nonimmediate T:inexact T:number T:object))
	  (known (constant 2)
		 (T:fixnum T:positive T:non-false T:exact T:number T:immediate T:object))))

  ;;Flonum, flonum operands: successful replacement.
  (doit ((primitive +) '1.1 '2.2)
	(funcall (primref $add-flonum-flonum)
	  (known (constant 1.1)
		 (T:flonum T:positive T:non-false T:nonimmediate T:inexact T:number T:object))
	  (known (constant 2.2)
		 (T:flonum T:positive T:non-false T:nonimmediate T:inexact T:number T:object))))

  ;;No replacement for "+" when there are more than 2 operands.
  (doit ((primitive +) '1 '2 '3)
  	(funcall (primref +)
  	  (known (constant 1)
  		 (T:fixnum T:positive T:non-false T:exact T:number T:immediate T:object))
  	  (known (constant 2)
  		 (T:fixnum T:positive T:non-false T:exact T:number T:immediate T:object))
  	  (known (constant 3)
  		 (T:fixnum T:positive T:non-false T:exact T:number T:immediate T:object))))

  #t)


(parametrise ((check-test-name	'pairs))

  (doit ((primitive car) '(1 . 2))
	(funcall (primref $car)
	  (known (constant (1 . 2))
		 (T:pair T:non-false T:nonimmediate T:object))))

  (check-arity-error
   ((primitive car) '(1 . 2) '3))

  (check-operand-core-type-error
   ((primitive car) '123))

;;; --------------------------------------------------------------------

  (doit ((primitive cdr) '(1 . 2))
	(funcall (primref $cdr)
	  (known (constant (1 . 2))
		 (T:pair T:non-false T:nonimmediate T:object))))

  #t)


(parametrise ((check-test-name	'symbols))

  (doit ((primitive putprop) 'a 'b '1)
	(funcall (primref $putprop)
	  (known (constant a) (T:symbol T:non-false T:nonimmediate T:object))
	  (known (constant b) (T:symbol T:non-false T:nonimmediate T:object))
	  (known (constant 1) (T:fixnum T:positive T:non-false T:exact T:number T:immediate T:object))))

  (doit ((primitive remprop) 'a 'b)
	(funcall (primref $remprop)
	  (known (constant a) (T:symbol T:non-false T:nonimmediate T:object))
	  (known (constant b) (T:symbol T:non-false T:nonimmediate T:object))))

  (doit ((primitive getprop) 'a 'b)
	(funcall (primref $getprop)
	  (known (constant a) (T:symbol T:non-false T:nonimmediate T:object))
	  (known (constant b) (T:symbol T:non-false T:nonimmediate T:object))))

  (doit ((primitive property-list) 'a)
	(funcall (primref $property-list)
	  (known (constant a) (T:symbol T:non-false T:nonimmediate T:object))))

  #t)


;;;; done

(check-report)

;;; end of file
;; Local Variables:
;; eval: (put 'bind			'scheme-indent-function 1)
;; eval: (put 'fix			'scheme-indent-function 1)
;; eval: (put 'recbind			'scheme-indent-function 1)
;; eval: (put 'rec*bind			'scheme-indent-function 1)
;; eval: (put 'seq			'scheme-indent-function 0)
;; eval: (put 'conditional		'scheme-indent-function 2)
;; eval: (put 'funcall			'scheme-indent-function 1)
;; eval: (put 'library-letrec*		'scheme-indent-function 1)
;; eval: (put 'shortcut			'scheme-indent-function 1)
;; End: