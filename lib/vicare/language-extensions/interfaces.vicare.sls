;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Vicare Scheme
;;;Contents: interfaces for record-types
;;;Date: Sat Jun 25, 2016
;;;
;;;Abstract
;;;
;;;	Interfaces  are  collections  of  method  signatures  that  record-types  can
;;;	implement to expose a common API.
;;;
;;;Copyright (C) 2016 Marco Maggi <marco.maggi-ipsu@poste.it>
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
(library (vicare language-extensions interfaces (0 4 2016 6 25))
  (options typed-language)
  (export define-interface
	  method case-method method/overload
	  method-prototype
	  this)
  (import (vicare)
    (prefix (only (vicare expander) #;(psyntax system $all)
		  make-interface-type-spec
		  type-annotation->object-type-spec
		  object-type-spec.type-annotation
		  <closure-type-spec>
		  <syntactic-identifier>)
	    expander::)
    (only (vicare system type-descriptors)
	  <interface-type-descr>
	  make-interface-type-descr))

  (define-auxiliary-syntaxes method-prototype)

  (define-fluid-syntax this
    (lambda (stx)
      (syntax-violation 'this "invalid use of auxiliary syntax" stx #f)))


(define-syntax define-interface
  (internal-body
    (define-constant __module_who__ 'define-interface)

    (define-constant CLAUSE-SPEC*
      (syntax-clauses-validate-specs
       (list
	;;KEYWORD MIN-OCCUR MAX-OCCUR MIN-ARGS MAX-ARGS MUTUALLY-INCLUSIVE MUTUALLY-EXCLUSIVE
	(new <syntax-clause-spec> #'method-prototype		0 +inf.0 2 2 '() '())
	(new <syntax-clause-spec> #'method			0 +inf.0 2 +inf.0 '() '())
	(new <syntax-clause-spec> #'case-method			0 +inf.0 2 +inf.0 '() '())
	(new <syntax-clause-spec> #'method/overload		0 +inf.0 2 +inf.0 '() '())
	#| end of LIST |# )))

    (define-record-type <parsing-results>
      (fields
	(immutable	type-name)
		;Syntactic identifier representing the name of this interface.
	(mutable	definitions)
		;Proper  list of  syntax objects  representing definition  forms that
		;must go in the output of this macro.
	(mutable	methods-table)
		;An  alist having:  as  keys syntactic  identifiers representing  the
		;method names;  as values  syntactic identifier  bound to  the method
		;implementation  functions.  This  alist  holds one  value for  every
		;method, either implemented  by this interface or  implemented by the
		;object type that implements this interface.
	(mutable	prototype-methods-table)
		;Alist  having:  as  keys  syntactic  identifiers  representing  this
		;interface's  prototyped   method  names;  as  values   instances  of
		;"<closure-type-spec>"  representing   the  type  signature   of  the
		;prototyped methods.   The prototyped methods must  be implemented by
		;the object-types that implement this interface.
	#| end of FIELDS |# )

      (protocol
	(lambda (make-record)
	  (lambda (type-name.id)
	    (make-record type-name.id '() '() '()))))

      (constructor-signature
	(lambda (expander::<syntactic-identifier>) => (<parsing-results>)))

      (method (definitions-push! {results <parsing-results>} definition.stx)
	(.definitions results (cons definition.stx (.definitions results))))

      (method (methods-table-push! {results		<parsing-results>}
				   {method-name.id	expander::<syntactic-identifier>}
				   {method-procname.id	expander::<syntactic-identifier>})
	(.methods-table results `((,method-name.id . ,method-procname.id) . ,(.methods-table results))))

      (method (methods-table-alist {results <parsing-results>})
	;;Return  a syntax  object  representing an  expression  which, expanded  and
	;;evaluated, returns  an alist  having: as  keys symbols  representing method
	;;names; as values  syntactic identifiers bound to  the method implementation
	;;functions.
	;;
	#`(list #,@(map (lambda (entry)
			  (let ((method-name.id		(car entry))
				(method-procname.id	(cdr entry)))
			    #`(cons (quote #,method-name.id) (syntax #,method-procname.id))))
		     (.methods-table results))))

      (method (methods-retriever {results <parsing-results>})
	;;Return  a syntax  object  representing an  expression  which, expanded  and
	;;evaluated, returns the method retriever function.
	;;
	#`(lambda (method-name.sym)
	    (case method-name.sym
	      #,@(map (lambda (entry)
			(let ((method-name.id		(car entry))
			      (method-procname.id	(cdr entry)))
			  #`((#,method-name.id) #,method-procname.id)))
		   (.methods-table results))
	      (else #f))))

      (method (prototype-methods-table-push! {results		<parsing-results>}
					     {method-name.id	expander::<syntactic-identifier>}
					     {signature.ots	expander::<closure-type-spec>})
	(.prototype-methods-table results (cons (cons method-name.id signature.ots)
						(.prototype-methods-table results))))

      #| end of DEFINE-RECORD-TYPE |# )

;;; --------------------------------------------------------------------

    (define (main input-form.stx synner)
      (syntax-case input-form.stx ()
	((_ ?type-name . ?clauses)
	 (begin
	   (unless (identifier? #'?type-name)
	     (synner "expected identifier as interface type name" #'?type-name))
	   (receive-and-return (out)
	       (%build-output (%parse-clauses #'?type-name #'?clauses synner))
	     (syntax->datum out))))

	(_
	 (synner "invalid DEFINE-INTERFACE syntax use"))))

    (define ({%parse-clauses <parsing-results>} {type-name.id expander::<syntactic-identifier>} clauses.stx synner)
      (syntax-clauses-fold-specs
	  (lambda ({results <parsing-results>} {clause-spec <syntax-clause-spec>} args)
	    (combine results clause-spec args synner))
	(new <parsing-results> type-name.id)
	CLAUSE-SPEC*
	(syntax-clauses-unwrap clauses.stx synner)
	synner))

    (define (%build-output {results <parsing-results>})
      (with-syntax
	  ((TYPE-NAME			(.type-name			results))
	   (TYPE-DESCRIPTOR		(identifier-suffix (.type-name results) "-type-descriptor"))
	   (PROTOTYPE-METHODS-TABLE	(.prototype-methods-table	results))
	   (METHODS-TABLE-ALIST		(.methods-table-alist		results))
	   (METHODS-RETRIEVER		(.methods-retriever		results))
	   ((DEFINITION ...)		(.definitions			results)))
	#'(module (TYPE-NAME)
	    (define/typed {TYPE-DESCRIPTOR <interface-type-descr>}
	      (make-interface-type-descr (quote TYPE-NAME) METHODS-RETRIEVER))
	    (define-syntax TYPE-NAME
	      (expander::make-interface-type-spec (syntax TYPE-NAME) (syntax TYPE-DESCRIPTOR)
						  (quote PROTOTYPE-METHODS-TABLE)
						  METHODS-TABLE-ALIST))
	    DEFINITION ...)))

;;; --------------------------------------------------------------------

    (define (combine {results <parsing-results>} {clause-spec <syntax-clause-spec>} args synner)
      ((case-identifiers (.keyword clause-spec)
	 ((method)			%process-clause/method)
	 ((case-method)			%process-clause/case-method)
	 ((method/overload)		%process-clause/method-overload)
	 ((method-prototype)		%process-clause/method-prototype)
	 (else
	  (assertion-violation __module_who__ "invalid clause spec" clause-spec)))
       results args synner))

;;; --------------------------------------------------------------------

    (module (%process-clause/method-prototype)

      (define (%process-clause/method-prototype {results <parsing-results>} args synner)
	;;This clause can be present multiple times.  Each input clause must have the
	;;format:
	;;
	;;   (method-prototype ?name ?signature)
	;;
	;;and we expect ARGS to have the format:
	;;
	;;   #(#(?name ?signature) ...)
	;;
	(vector-fold-left (lambda (results arg)
			    (%process-method-prototype-spec results arg synner))
	  results args))

      (define (%process-method-prototype-spec {results <parsing-results>} arg synner)
	;;We expect ARG to have the format:
	;;
	;;   #((?name ?signature))
	;;
	;;Update results with the result of parsing.
	;;
	(syntax-case arg ()
	  (#(?method-name ?signature)
	   (identifier? #'?method-name)
	   (let ((signature.ots		(expander::type-annotation->object-type-spec #'?signature))
		 (method-procname.id	(identifier-record-field-accessor (.type-name results) #'?method-name)))
	     (.definitions-push!             results #`(define/std (#,method-procname.id subject . args)
							 (apply method-call-late-binding (quote ?method-name) subject args)))
	     (.methods-table-push!           results #'?method-name method-procname.id)
	     (.prototype-methods-table-push! results #'?method-name signature.ots)
	     results))

	  (#(?stuff ...)
	   (synner "invalid METHOD-PROTOTYPE specification" #'(method-prototype ?stuff ...)))))

      #| end of module: %PROCESS-CLAUSE/METHOD-PROTOTYPE |# )

;;; --------------------------------------------------------------------

    (module (%process-clause/method)

      (define (%process-clause/method {results <parsing-results>} args synner)
	;;This clause can be present multiple times.  Each input clause must have the
	;;format:
	;;
	;;   (method (?who . ?formals) . ?body)
	;;
	;;and we expect ARGS to have the format:
	;;
	;;   #((?who . ?formals) . ?body)
	;;
	(vector-fold-left (lambda (results arg)
			    (%process-method-spec results arg synner))
	  results args))

      (define (%process-method-spec {results <parsing-results>} arg synner)
	;;The METHOD  clause can be present  multiple times.  Each input  clause must
	;;have the format:
	;;
	;;   (method (?who . ?formals) . ?body)
	;;
	;;and we expect ARGS to have the format:
	;;
	;;   #((?who . ?formals) . ?body)
	;;
	(syntax-case arg ()
	  (#((?who . ?formals) ?body0 ?body ...)
	   (receive (method-name.id method-procname.id method-who.stx)
	       (%parse-method-who results #'?who synner)
	     (.definitions-push!   results #`(define/checked (#,method-who.stx {subject #,(.type-name results)} . ?formals)
					       (fluid-let-syntax ((this (identifier-syntax subject)))
						 ?body0 ?body ...)))
	     (.methods-table-push! results method-name.id method-procname.id)
	     results))
	  (#(?stuff ...)
	   (synner "invalid METHOD specification" #'(method ?stuff ...)))))

      #| end of module: %PROCESS-CLAUSE/METHOD-PROTOTYPE |# )

;;; --------------------------------------------------------------------

    (module (%process-clause/case-method)

      (define (%process-clause/case-method {results <parsing-results>} args synner)
	;;This clause can be present multiple times.  Each input clause must have the
	;;format:
	;;
	;;   (case-method ?who . ?case-method-clauses)
	;;
	;;and we expect ARGS to have the format:
	;;
	;;   #(#(?who ?case-method-clause0 ?case-method-clause ...) ...)
	;;
	(vector-fold-left (lambda (results arg)
			    (%process-case-method-spec results arg synner))
	  results args))

      (define (%process-case-method-spec {results <parsing-results>} arg synner)
	;;We expect the ARG argument to have the format:
	;;
	;;   #(?who ?case-method-clause0 ?case-method-clause ...)
	;;
	(syntax-case arg ()
	  (#(?who ?case-method-clause0 ?case-method-clause ...)
	   (let* ((method-name.id	#'?who)
		  (method-procname.id	(identifier-record-field-accessor (.type-name results) #'?who))
		  (clause*.stx		(map (lambda (clause.stx)
					       (%add-this-to-clause-formals results clause.stx synner))
					  (syntax->list #'(?case-method-clause0 ?case-method-clause ...)))))
	     (.definitions-push!	results #`(case-define/checked #,method-procname.id . #,clause*.stx))
	     (.methods-table-push!	results method-name.id method-procname.id)
	     results))

	  (#(?stuff ...)
	   (synner "invalid CASE-METHOD specification" #'(case-method ?stuff ...)))))

      (define (%add-this-to-clause-formals {results <parsing-results>} clause.stx synner)
	(syntax-case clause.stx (brace)
	  ((((brace ?underscore . ?rv-types) . ?formals) ?body0 ?body ...)
	   (%underscore-id? #'?underscore)
	   #`(({?underscore . ?rv-types} {subject #,(.type-name results)} . ?formals)
	      (fluid-let-syntax ((this (identifier-syntax subject)))
		?body0 ?body ...)))

	  ((?formals ?body0 ?body ...)
	   #`(({subject #,(.type-name results)} . ?formals)
	      (fluid-let-syntax ((this (identifier-syntax subject)))
		?body0 ?body ...)))
	  (_
	   (synner "invalid CASE-METHOD clause syntax" clause.stx))))

      (define (%underscore-id? stx)
	(and (identifier? stx)
	     (eq? '_ (syntax->datum stx))))

      #| end of module: %PROCESS-CASE-METHOD-SPEC |# )

;;; --------------------------------------------------------------------

    (module (%process-clause/method-overload)

      (define (%process-clause/method-overload {results <parsing-results>} args synner)
	;;This clause can be present multiple times.  Each input clause must have the
	;;format:
	;;
	;;   (method/overload (?who . ?formals) . ?body)
	;;
	;;and we expect ARGS to have the format:
	;;
	;;   #(#((?who . ?formals) . ?body) ...)
	;;
	(vector-fold-left (lambda (results arg)
			    (%process-method-overload-spec results arg synner))
	  results args))

      (define (%process-method-overload-spec {results <parsing-results>} arg synner)
	;;We expect the ARG argument to have the format:
	;;
	;;   #((?who . ?formals) . ?body)
	;;
	(syntax-case arg ()
	  (#((?who . ?formals) ?body0 ?body ...)
	   (receive (method-name.id method-procname.id method-who.stx)
	       (%parse-method-who results #'?who synner)
	     (.definitions-push!   results #`(define/overload (#,method-who.stx {subject #,(.type-name results)} . ?formals)
					       (fluid-let-syntax ((this (identifier-syntax subject)))
						 ?body0 ?body ...)))
	     (.methods-table-push! results method-name.id method-procname.id)
	     results))

	  (#(?stuff ...)
	   (synner "invalid METHOD/OVERLOAD specification" #'(method/overload ?stuff ...)))))

      #| end of module: %PROCESS-CLAUSE/METHOD-OVERLOAD |# )

;;; --------------------------------------------------------------------

    (define (%parse-method-who {results <parsing-results>} who.stx synner)
      (syntax-case who.stx (brace)
	(?method-name
	 (identifier? #'?method-name)
	 (let ((method-procname.id (identifier-record-field-accessor (.type-name results) #'?method-name)))
	   (values #'?method-name method-procname.id method-procname.id)))
	((brace ?method-name . ?rv-types)
	 (identifier? #'?method-name)
	 (let ((method-procname.id (identifier-record-field-accessor (.type-name results) #'?method-name)))
	   (values #'?method-name method-procname.id #`(brace #,method-procname.id . ?rv-types))))
	(_
	 (synner "invalid method name specification" who.stx))))

;;; --------------------------------------------------------------------

    (lambda (input-form.stx)
      (case-define synner
	((message)
	 (syntax-violation __module_who__ message input-form.stx #f))
	((message subform)
	 (syntax-violation __module_who__ message input-form.stx subform)))
      (main input-form.stx synner))))


;;;; done

#| end of library |# )

;;; end of file