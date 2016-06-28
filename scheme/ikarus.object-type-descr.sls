;;; -*- coding: utf-8-unix -*-
;;;
;;;Part of: Vicare Scheme
;;;Contents: object type descriptors
;;;Date: Thu Jun  2, 2016
;;;
;;;Abstract
;;;
;;;
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
(library (ikarus.object-type-descr)
  (export

    <descriptors-signature>-rtd			<descriptors-signature>-rcd
    make-descriptors-signature			descriptors-signature?
    descriptors-signature.object-type-descrs
    descriptors-signature=?
    descriptors-signature.super-and-sub?
    descriptors-signature.match-formals-against-operands

    <lambda-descriptors>-rtd			<lambda-descriptors>-rcd
    make-lambda-descriptors			lambda-descriptors?
    lambda-descriptors.retvals			lambda-descriptors.argvals
    lambda-descriptors=?
    lambda-descriptors.super-and-sub?
    lambda-descriptors.match-formals-against-operands
    select-most-specific-lambda-descriptors

    <case-lambda-descriptors>-rtd		<case-lambda-descriptors>-rcd
    make-case-lambda-descriptors		case-lambda-descriptors?
    case-lambda-descriptors.clause-signature*
    case-lambda-descriptors=?
    case-lambda-descriptors.super-and-sub?
    case-lambda-descriptors.match-formals-against-operands

;;; --------------------------------------------------------------------

    <compound-condition-type-descr>-rtd		<compound-condition-type-descr>-rcd
    make-compound-condition-type-descr		compound-condition-type-descr?
    compound-condition-type-descr.component-des*

    <hashtable-type-descr>-rtd			<hashtable-type-descr>-rcd
    make-hashtable-type-descr			hashtable-type-descr?
    hashtable-type-descr.key-des		hashtable-type-descr.val-des

    <alist-type-descr>-rtd			<alist-type-descr>-rcd
    make-alist-type-descr			alist-type-descr?
    alist-type-descr.key-des			alist-type-descr.val-des

    <enumeration-type-descr>-rtd		<enumeration-type-descr>-rcd
    make-enumeration-type-descr			enumeration-type-descr?
    enumeration-type-descr.symbol*

    <closure-type-descr>-rtd			<closure-type-descr>-rcd
    make-closure-type-descr			closure-type-descr?
    closure-type-descr.signature
    closure-type-descr.super-and-sub?
    closure-type-descr.match-formals-against-operands

;;; --------------------------------------------------------------------

    <pair-type-descr>-rtd			<pair-type-descr>-rcd
    make-pair-type-descr			pair-type-descr?
    pair-type-descr.car-des			pair-type-descr.cdr-des

    <pair-of-type-descr>-rtd			<pair-of-type-descr>-rcd
    make-pair-of-type-descr			pair-of-type-descr?
    pair-of-type-descr.item-des

    <list-type-descr>-rtd			<list-type-descr>-rcd
    make-list-type-descr			make-null-or-list-type-descr
    list-type-descr?
    list-type-descr.item-des*			list-type-descr.length
    list-type-descr.car				list-type-descr.cdr

    <list-of-type-descr>-rtd			<list-of-type-descr>-rcd
    make-list-of-type-descr			list-of-type-descr?
    list-of-type-descr.item-des

    <vector-type-descr>-rtd			<vector-type-descr>-rcd
    make-vector-type-descr			vector-type-descr?
    vector-type-descr.item-des*

    <vector-of-type-descr>-rtd			<vector-of-type-descr>-rcd
    make-vector-of-type-descr			vector-of-type-descr?
    vector-of-type-descr.item-des

;;; --------------------------------------------------------------------

    <ancestor-of-type-descr>-rtd		<ancestor-of-type-descr>-rcd
    make-ancestor-of-type-descr			ancestor-of-type-descr?
    ancestor-of-type-descr.item-des		ancestor-of-type-descr.ancestor-des*

    <interface-type-descr>-rtd			<interface-type-descr>-rcd
    make-interface-type-descr			interface-type-descr?
    interface-type-descr.type-name		interface-type-descr.method-retriever

;;; --------------------------------------------------------------------

    <union-type-descr>-rtd			<union-type-descr>-rcd
    make-union-type-descr			union-type-descr?
    union-type-descr.item-des*

    <intersection-type-descr>-rtd		<intersection-type-descr>-rcd
    make-intersection-type-descr		intersection-type-descr?
    intersection-type-descr.item-des*

    <complement-type-descr>-rtd			<complement-type-descr>-rcd
    make-complement-type-descr			complement-type-descr?
    complement-type-descr.item-des

;;; --------------------------------------------------------------------

    type-descriptor-of
    object-type-descr=?
    object-type-descr.parent
    object-type-descr.ancestor-des*
    object-type-descr.matching-super-and-sub?
    object-type-descr.compatible-super-and-sub?
    object-type-descr.matching-formal-and-operand

    #| end of EXPORTS |# )
  (import (except (vicare)
		  ratnum-positive?
		  ratnum-negative?
		  exact-compnum?
		  zero-compnum?
		  zero-cflonum?)
    (only (ikarus.core-type-descr)
	  core-type-descriptor?
	  core-type-descriptor=?
	  core-type-descriptor.uids-list
	  core-type-descriptor.parent
	  core-type-descriptor.ancestor-des*
	  core-type-descriptor.parent-and-child?
	  ;;;
	  <void>-ctd				<top>-ctd			<bottom>-ctd
	  <true>-ctd				<false>-ctd
	  <char>-ctd				<keyword>-ctd			<symbol>-ctd
	  <procedure>-ctd			<struct>-ctd			<record>-ctd
	  <positive-fixnum>-ctd			<negative-fixnum>-ctd		<zero-fixnum>-ctd     <fixnum>-ctd
	  <positive-flonum>-ctd			<negative-flonum>-ctd
	  <positive-zero-flonum>-ctd		<negative-zero-flonum>-ctd	<flonum>-ctd
	  <positive-ratnum>-ctd			<negative-ratnum>-ctd		<ratnum>-ctd
	  <positive-bignum>-ctd			<negative-bignum>-ctd		<bignum>-ctd
	  <exact-compnum>-ctd			<zero-compnum>-ctd		<non-zero-inexact-compnum>-ctd
	  <zero-cflonum>-ctd			<non-zero-cflonum>-ctd
	  <empty-string>-ctd			<nestring>-ctd
	  <null>-ctd				<nelist>-ctd			<list>-ctd	      <pair>-ctd
	  <empty-vector>-ctd			<nevector>-ctd			<vector>-ctd
	  <empty-bytevector>-ctd		<nebytevector>-ctd
	  <condition>-ctd			<compound-condition>-ctd
	  <hashtable>-ctd)
    (only (ikarus records procedural)
	  $rtd-subtype?)
    ;;FIXME To be removed at the next  boot image rotation.  (Marco Maggi; Fri Jun 3,
    ;;2016)
    (only (ikarus ratnums)
	  ratnum-positive?
	  ratnum-negative?)
    ;;FIXME To be removed at the next  boot image rotation.  (Marco Maggi; Fri Jun 3,
    ;;2016)
    (only (ikarus numerics complex-numbers)
	  exact-compnum?
	  zero-compnum?
	  zero-cflonum?))


;;;; helpers

(define (%list-of-single-item? obj)
  (and (pair? obj)
       (null? (cdr obj))))

(define (simple-condition-type-descr? des)
  (and (record-type-descriptor? des)
       ($simple-condition-type-descr? des)))

(define ($simple-condition-type-descr? des)
  ($rtd-subtype? des (record-type-descriptor &condition)))

;;; --------------------------------------------------------------------

(define (object-type-descr.list-type-descr? object.des)
  (or (<list>-ctd? object.des)
      (<null>-ctd? object.des)
      (<nelist>-ctd? object.des)
      (list-type-descr? object.des)
      (list-of-type-descr? object.des)
      (and (pair-type-descr? object.des)
	   (object-type-descr.list-type-descr? (pair-type-descr.cdr-des object.des)))
      (and (pair-of-type-descr? object.des)
	   (object-type-descr.list-type-descr? (pair-of-type-descr.item-des object.des)))))

(define (record-type-descriptor=? rtd1 rtd2)
  (eq? (record-type-uid rtd1)
       (record-type-uid rtd2)))

;;; --------------------------------------------------------------------

(define-syntax cond-with-predicates
  (syntax-rules (else)
    ((_ ?expr (?pred . ?body) ... (else . ?else-body))
     (let ((X ?expr))
       (cond ((?pred X) . ?body)
	     ...
	     (else . ?else-body))))
    ((_ ?expr (?pred . ?body) ...)
     (let ((X ?expr))
       (cond ((?pred X) . ?body)
	     ...)))
    ))

(define-syntax or-with-predicates
  (syntax-rules ()
    ((_ ?expr ?pred ...)
     (let ((X ?expr))
       (or (?pred X) ...)))
    ))

(define-syntax define-type-descriptor-predicate
  (lambda (stx)
    (syntax-case stx ()
      ((_ ?descr)
       (identifier? #'?descr)
       (with-syntax ((WHO (identifier-suffix #'?descr "?")))
	 #'(define (WHO obj)
	     (and (core-type-descriptor? obj)
		  (eq? (car (core-type-descriptor.uids-list obj))
		       (car (core-type-descriptor.uids-list ?descr)))))))
      )))

(define-syntax case-descriptor
  (syntax-rules (else
		 core-type-descriptor? record-type-descriptor? struct-type-descriptor?
		 list-type-descr? list-of-type-descr? vector-type-descr? vector-of-type-descr?
		 pair-type-descr? pair-of-type-descr? compound-condition-type-descr? enumeration-type-descr?
		 closure-type-descr?
		 hashtable-type-descr? union-type-descr? intersection-type-descr? complement-type-descr?
		 ancestor-of-type-descr?)
    ((_ ?expr
	(core-type-descriptor?		. ?body-core)
	(record-type-descriptor?	. ?body-record)
	(struct-type-descriptor?	. ?body-struct)
	(list-type-descr?		. ?body-list)
	(list-of-type-descr?		. ?body-list-of)
	(vector-type-descr?		. ?body-vector)
	(vector-of-type-descr?		. ?body-vector-of)
	(pair-type-descr?		. ?body-pair)
	(pair-of-type-descr?		. ?body-pair-of)
	(compound-condition-type-descr?	. ?body-compound-condition)
	(enumeration-type-descr?	. ?body-enumeration)
	(closure-type-descr?		. ?body-closure)
	(hashtable-type-descr?		. ?body-hashtable)
	(union-type-descr?		. ?body-union)
	(intersection-type-descr?	. ?body-intersection)
	(complement-type-descr?		. ?body-complement)
	(ancestor-of-type-descr?	. ?body-ancestor-of)
	(else				. ?body-else))
     (let ((des ?expr))
       (cond
	((core-type-descriptor? des)		. ?body-core)
	((record-type-descriptor? des)		. ?body-record)
	((struct-type-descriptor? des)		. ?body-struct)
	((list-type-descr? des)			. ?body-list)
	((list-of-type-descr? des)		. ?body-list-of)
	((vector-type-descr? des)		. ?body-vector)
	((vector-of-type-descr? des)		. ?body-vector-of)
	((pair-type-descr? des)			. ?body-pair)
	((pair-of-type-descr? des)		. ?body-pair-of)
	((compound-condition-type-descr? des)	. ?body-compound-condition)
	((enumeration-type-descr? des)		. ?body-enumeration)
	((closure-type-descr? des)		. ?body-closure)
	((hashtable-type-descr? des)		. ?body-hashtable)
	((union-type-descr? des)		. ?body-union)
	((intersection-type-descr? des)		. ?body-intersection)
	((complement-type-descr? des)		. ?body-complement)
	((ancestor-of-type-descr? des)		. ?body-ancestor-of)
	(else					. ?body-else))))
    ))

;;; --------------------------------------------------------------------

(define-type-descriptor-predicate <bottom>-ctd)
(define-type-descriptor-predicate <void>-ctd)
(define-type-descriptor-predicate <top>-ctd)
(define-type-descriptor-predicate <symbol>-ctd)

(define-type-descriptor-predicate <list>-ctd)
(define-type-descriptor-predicate <nelist>-ctd)
(define-type-descriptor-predicate <null>-ctd)

(define-type-descriptor-predicate <vector>-ctd)
(define-type-descriptor-predicate <nevector>-ctd)
(define-type-descriptor-predicate <empty-vector>-ctd)

(define-type-descriptor-predicate <pair>-ctd)
(define-type-descriptor-predicate <procedure>-ctd)

(define-type-descriptor-predicate <struct>-ctd)
(define-type-descriptor-predicate <record>-ctd)

(define-type-descriptor-predicate <hashtable>-ctd)
(define-type-descriptor-predicate <condition>-ctd)
(define-type-descriptor-predicate <compound-condition>-ctd)


;;;; include files

(include "ikarus.object-type-descr.descriptors-signatures.sls"	#t)


;;;; compound type descriptors: compound condition-object types

(define-record-type (<compound-condition-type-descr> make-compound-condition-type-descr compound-condition-type-descr?)
  (nongenerative vicare:type-descriptors:<compound-condition-type-descr>)
  (sealed #t)
  (fields
    (immutable	component-des*		compound-condition-type-descr.component-des*)
		;A list of instances of "<record-type-descr>" describing the types of
		;component condition objects.
    (mutable	memoised-length)
    #| end of FIELDS |# )
  (protocol
    (lambda (make-record)
      (lambda (component*.des)
	(make-record component*.des #f))))
  #| end of DEFINE-RECORD-TYPE |# )

(define <compound-condition-type-descr>-rtd
  (record-type-descriptor <compound-condition-type-descr>))

(define <compound-condition-type-descr>-rcd
  (record-constructor-descriptor <compound-condition-type-descr>))

;;; --------------------------------------------------------------------

(define* (compound-condition-type-descr.exists {compound-condition.des compound-condition-type-descr?} {proc procedure?})
  (exists proc (compound-condition-type-descr.component-des* compound-condition.des)))

(define* (compound-condition-type-descr.for-all {compound-condition.des compound-condition-type-descr?} {proc procedure?})
  (for-all proc (compound-condition-type-descr.component-des* compound-condition.des)))

(define* (compound-condition-type-descr.length {des compound-condition-type-descr?})
  (or (<compound-condition-type-descr>-memoised-length des)
      (receive-and-return (len)
	  (length (compound-condition-type-descr.component-des* des))
	(<compound-condition-type-descr>-memoised-length-set! des len))))

(define* (compound-condition-type-descr=? {des1 compound-condition-type-descr?}
					  {des2 compound-condition-type-descr?})
  ;;Return true  if the two compound  conditions have the same  components, otherwise
  ;;return false.
  ;;
  (and (= (compound-condition-type-descr.length des1)
	  (compound-condition-type-descr.length des2))
       (let super-loop ((component1*.des (compound-condition-type-descr.component-des* des1))
			(component2*.des (compound-condition-type-descr.component-des* des2)))
	 (if (pair? component1*.des)
	     (let sub-loop ((component2*.des	component2*.des)
			    (leftover2*.des	'()))
	       (if (pair? component2*.des)
		   (if (condition-object-component-descriptor=? (car component1*.des) (car component2*.des))
		       ;;We discard this component2.
		       (super-loop (cdr component1*.des) (append (cdr component2*.des) leftover2*.des))
		     ;;We add this component2 to the leftovers.
		     (sub-loop (cdr component2*.des) (cons (car component2*.des) leftover2*.des)))
		 ;;There are more component2, but no more component1.
		 #f))
	   ;;There are no more component1: are there more component2?
	   (null? component2*.des)))))

(define (condition-object-component-descriptor=? obj1 obj2)
  ;;A compound condition-object's component is either:
  ;;
  ;;1. A record-type descriptor ("&condition-rtd" or one of its sub-types).
  ;;
  ;;2. The core type descriptor "<condition>".  Currently disabled.
  ;;
  ;;3. The core type descriptor "<compound-condition>".  Currently disabled.
  ;;
  (cond-with-predicates obj1
    (record-type-descriptor?
     (and (record-type-descriptor? obj2)
	  (record-type-descriptor=? obj1 obj2)))

    ;; (<condition>-ctd?
    ;;  (<condition>-ctd? obj2))

    ;; (<compound-condition>-ctd?
    ;;  (<compound-condition>-ctd? obj2))

    (else #f)))


;;;; compound type descriptors: symbols enumeration

(define-record-type (<enumeration-type-descr> make-enumeration-type-descr enumeration-type-descr?)
  (nongenerative vicare:type-descriptors:<enumeration-type-descr>)
  (sealed #t)
  (fields
    (immutable	symbol*			enumeration-type-descr.symbol*)
    (mutable	memoised-length)
    #| end of FIELDS |# )
  (protocol
    (lambda (make-record)
      (lambda (symbol*)
	(make-record symbol* #f))))
  #| end of DEFINE-RECORD-TYPE |# )

(define <enumeration-type-descr>-rtd
  (record-type-descriptor <enumeration-type-descr>))

(define <enumeration-type-descr>-rcd
  (record-constructor-descriptor <enumeration-type-descr>))

;;; --------------------------------------------------------------------

(define* (enumeration-type-descr.member? {des enumeration-type-descr?} {sym symbol?})
  (and (memq sym (enumeration-type-descr.symbol* des))
       #t))

(define* (enumeration-type-descr.length {des enumeration-type-descr?})
  (or (<enumeration-type-descr>-memoised-length des)
      (receive-and-return (len)
	  (length (enumeration-type-descr.symbol* des))
	(<enumeration-type-descr>-memoised-length-set! des len))))

(define* (enumeration-type-descr=? {des1 enumeration-type-descr?}
				   {des2 enumeration-type-descr?})
  ;;Return  true if  the two  enumerations have  the same  symbols, otherwise  return
  ;;false.
  ;;
  (and (= (enumeration-type-descr.length des1)
	  (enumeration-type-descr.length des2))
       (let super-loop ((symbol1* (enumeration-type-descr.symbol* des1))
			(symbol2* (enumeration-type-descr.symbol* des2)))
	 (if (pair? symbol1*)
	     (let sub-loop ((symbol2*	symbol2*)
			    (leftover2*	'()))
	       (if (pair? symbol2*)
		   (if (eq? (car symbol1*) (car symbol2*))
		       ;;We discard this symbol2.
		       (super-loop (cdr symbol1*) (append (cdr symbol2*) leftover2*))
		     ;;We add this symbol2 to the leftovers.
		     (sub-loop (cdr symbol2*) (cons (car symbol2*) leftover2*)))
		 ;;There are more symbol2, but no more symbol1.
		 #f))
	   ;;There are no more symbol1: are there more symbol2?
	   (null? symbol2*)))))

(define* (enumeration-type-descr.for-all {des enumeration-type-descr?} {proc procedure?})
  (and (for-all proc (enumeration-type-descr.symbol* des))
       #t))


;;;; compound type descriptors: closure

(define-record-type (<closure-type-descr> make-closure-type-descr closure-type-descr?)
  (nongenerative vicare:type-descriptors:<closure-type-descr>)
  (sealed #t)
  (fields
    (immutable signature	closure-type-descr.signature)
		;An  instance of  "<case-lambda-descriptors>"  representing the  type
		;signatures of the clauses.
    #| end of FIELDS |# )
  (protocol
    (lambda (make-record)
      (lambda* ({signature case-lambda-descriptors?})
	(make-record signature)))))

(define <closure-type-descr>-rtd
  (record-type-descriptor <closure-type-descr>))

(define <closure-type-descr>-rcd
  (record-constructor-descriptor <closure-type-descr>))

;;; --------------------------------------------------------------------

(define* (closure-type-descr=? {D1 closure-type-descr?} {D2 closure-type-descr?})
  (case-lambda-descriptors=? (closure-type-descr.signature D1)
			     (closure-type-descr.signature D2)))

(define* (closure-type-descr.super-and-sub? {D1 closure-type-descr?} {D2 closure-type-descr?})
  ;;Compare two  closure type  descriptors to  determine if  they are  super-type and
  ;;sub-type.  Return a boolean, true if they are super and sub.  For every clause in
  ;;the super there must be a matching clause in the sub.
  ;;
  (case-lambda-descriptors.super-and-sub? (closure-type-descr.signature D1)
					  (closure-type-descr.signature D2)))

(define* (closure-type-descr.match-formals-against-operands {D1 closure-type-descr?} {operands.des descriptors-signature?})
  ;;Compare formals'  and operands' type  signatures to  determine if a  closure type
  ;;descriptor  matches  the  operands.   Return one  of  the  symbols:  exact-match,
  ;;possible-match, no-match.
  ;;
  (case-lambda-descriptors.match-formals-against-operands (closure-type-descr.signature D1) operands.des))


;;;; compound type descriptors: hashtables

(define-record-type (<hashtable-type-descr> make-hashtable-type-descr hashtable-type-descr?)
  (nongenerative vicare:type-descriptors:<hashtable-type-descr>)
  (sealed #t)
  (fields
    (immutable key-des			hashtable-type-descr.key-des)
		;An instance of "<object-type-descr>" describing the type of keys.
    (immutable val-des			hashtable-type-descr.val-des)
		;An instance of "<object-type-descr>" describing the type of values.
    #| end of FIELDS |# ))

(define <hashtable-type-descr>-rtd
  (record-type-descriptor <hashtable-type-descr>))

(define <hashtable-type-descr>-rcd
  (record-constructor-descriptor <hashtable-type-descr>))


;;;; compound type descriptors: pairs

(define-record-type (<pair-type-descr> make-pair-type-descr pair-type-descr?)
  (nongenerative vicare:type-descriptors:<pair-type-descr>)
  (sealed #t)
  (fields
    (immutable car-des		pair-type-descr.car-des)
    (immutable cdr-des		pair-type-descr.cdr-des)
    #| end of FIELDS |# ))

(define <pair-type-descr>-rtd
  (record-type-descriptor <pair-type-descr>))

(define <pair-type-descr>-rcd
  (record-constructor-descriptor <pair-type-descr>))

(define (pair-type-descr?/list des)
  (and (pair-type-descr? des)
       (object-type-descr.list-type-descr? (pair-type-descr.cdr-des des))))


;;;; compound type descriptors: pairs of

(define-record-type (<pair-of-type-descr> make-pair-of-type-descr pair-of-type-descr?)
  (nongenerative vicare:type-descriptors:<pair-of-type-descr>)
  (sealed #t)
  (fields
    (immutable item-des		pair-of-type-descr.item-des)
    #| end of FIELDS |# ))

(define <pair-of-type-descr>-rtd
  (record-type-descriptor <pair-of-type-descr>))

(define <pair-of-type-descr>-rcd
  (record-constructor-descriptor <pair-of-type-descr>))

;;; --------------------------------------------------------------------

(define (pair-of-type-descr?/list des)
  (and (pair-of-type-descr? des)
       (object-type-descr.list-type-descr? (pair-of-type-descr.item-des des))))


;;;; compound type descriptors: lists

(define-record-type (<list-type-descr> make-list-type-descr list-type-descr?)
  (nongenerative vicare:type-descriptors:<list-type-descr>)
  (sealed #t)
  (fields
    (immutable	item-des*		list-type-descr.item-des*)
    (mutable	memoised-length)
    #| end of FIELDS |# )
  (protocol
    (lambda (make-record)
      (define* (make-list-type-descr {item*.des pair?})
	(make-record item*.des #f))
      make-list-type-descr)))

(define <list-type-descr>-rtd
  (record-type-descriptor <list-type-descr>))

(define <list-type-descr>-rcd
  (record-constructor-descriptor <list-type-descr>))

;;; --------------------------------------------------------------------

(define (make-null-or-list-type-descr item*.des)
  (if (pair? item*.des)
      (make-list-type-descr item*.des)
    <null>-ctd))

(define* (list-type-descr.length {des list-type-descr?})
  (or (<list-type-descr>-memoised-length des)
      (receive-and-return (len)
	  (length (list-type-descr.item-des* des))
	(<list-type-descr>-memoised-length-set! des len))))

(define* (list-type-descr.list-of-single-item? {list.des list-type-descr?})
  (= 1 (list-type-descr.length list.des)))

(define* (list-type-descr.exists {des list-type-descr?} {proc procedure?})
  (exists proc (list-type-descr.item-des* des)))

(define* (list-type-descr.for-all {des list-type-descr?} {proc procedure?})
  (for-all proc (list-type-descr.item-des* des)))

(define* (list-type-descr.car {des list-type-descr?})
  (car (list-type-descr.item-des* des)))

(define* (list-type-descr.cdr {des list-type-descr?})
  (make-null-or-list-type-descr (cdr (list-type-descr.item-des* des))))


;;;; compound type descriptors: lists of

(define-record-type (<list-of-type-descr> make-list-of-type-descr list-of-type-descr?)
  (nongenerative vicare:type-descriptors:<list-of-type-descr>)
  (fields
    (immutable item-des		list-of-type-descr.item-des)
    #| end of FIELDS |# ))

(define <list-of-type-descr>-rtd
  (record-type-descriptor <list-of-type-descr>))

(define <list-of-type-descr>-rcd
  (record-constructor-descriptor <list-of-type-descr>))

;;; --------------------------------------------------------------------
;;; compound type descriptors: alists

(define-record-type (<alist-type-descr> make-alist-type-descr alist-type-descr?)
  (nongenerative vicare:type-descriptors:<alist-type-descr>)
  (parent <list-of-type-descr>)
  (sealed #t)
  (fields
    (immutable key-des			alist-type-descr.key-des)
		;An instance of "<object-type-descr>" describing the type of keys.
    (immutable val-des			alist-type-descr.val-des)
		;An instance of "<object-type-descr>" describing the type of values.
    #| end of FIELDS |# )
  (protocol
    (lambda (make-list-of-type-descr)
      (lambda (key-des val-des)
	((make-list-of-type-descr (make-pair-type-descr key-des val-des)) key-des val-des))))
  #| end of DEFINE-RECORD-TYPE |# )

(define <alist-type-descr>-rtd
  (record-type-descriptor <alist-type-descr>))

(define <alist-type-descr>-rcd
  (record-constructor-descriptor <alist-type-descr>))


;;;; compound type descriptors: vectors

(define-record-type (<vector-type-descr> %make-vector-type-descr vector-type-descr?)
  (nongenerative vicare:type-descriptors:<vector-type-descr>)
  (sealed #t)
  (fields
    (immutable	item-des*		vector-type-descr.item-des*)
    (mutable	memoised-length)
    #| end of FIELDS |# )
  (protocol
    (lambda (make-record)
      (lambda (item*.des)
	(make-record item*.des #f)))))

(define (make-vector-type-descr item*.des)
  (if (null? item*.des)
      <empty-vector>-ctd
    (%make-vector-type-descr item*.des)))

(define <vector-type-descr>-rtd
  (record-type-descriptor <vector-type-descr>))

(define <vector-type-descr>-rcd
  (record-constructor-descriptor <vector-type-descr>))

;;; --------------------------------------------------------------------

(define* (vector-type-descr.length {des vector-type-descr?})
  (or (<vector-type-descr>-memoised-length des)
      (receive-and-return (len)
	  (length (vector-type-descr.item-des* des))
	(<vector-type-descr>-memoised-length-set! des len))))

(define* (vector-type-descr.exists {des vector-type-descr?} {proc procedure?})
  (exists proc (vector-type-descr.item-des* des)))

(define* (vector-type-descr.for-all {des vector-type-descr?} {proc procedure?})
  (for-all proc (vector-type-descr.item-des* des)))


;;;; compound type descriptors: vectors of

(define-record-type (<vector-of-type-descr> make-vector-of-type-descr vector-of-type-descr?)
  (nongenerative vicare:type-descriptors:<vector-of-type-descr>)
  (sealed #t)
  (fields
    (immutable item-des		vector-of-type-descr.item-des)
    #| end of FIELDS |# ))

(define <vector-of-type-descr>-rtd
  (record-type-descriptor <vector-of-type-descr>))

(define <vector-of-type-descr>-rcd
  (record-constructor-descriptor <vector-of-type-descr>))


;;;; compound type descriptors: union

(define-record-type (<union-type-descr> %make-union-type-descr union-type-descr?)
  (nongenerative vicare:type-descriptors:<union-type-descr>)
  (sealed #t)
  (fields
    (immutable	item-des*	union-type-descr.item-des*)
    (mutable	memoised-length)
    #| end of FIELDS |# )
  (protocol
    (lambda (make-record)
      (lambda (item*.des)
	(make-record item*.des #f))))
  #| end of DEFINE-RECORD-TYPE |# )

(define (make-union-type-descr item*.des)
  (if (%list-of-single-item? item*.des)
      (car item*.des)
    (%make-union-type-descr item*.des)))

(define <union-type-descr>-rtd
  (record-type-descriptor <union-type-descr>))

(define <union-type-descr>-rcd
  (record-constructor-descriptor <union-type-descr>))

;;; --------------------------------------------------------------------

(define (union-type-descr.exists union.des proc)
  (exists proc (union-type-descr.item-des* union.des)))

(define (union-type-descr.for-all union.des proc)
  (for-all proc (union-type-descr.item-des* union.des)))

(define* (union-type-descr.length {des union-type-descr?})
  (or (<union-type-descr>-memoised-length des)
      (receive-and-return (len)
	  (length (union-type-descr.item-des* des))
	(<union-type-descr>-memoised-length-set! des len))))

(define* (union-type-descr=? {des1 union-type-descr?} {des2 union-type-descr?})
  ;;Return true if the two unions have the same components, otherwise return false.
  ;;
  (and (= (union-type-descr.length des1)
	  (union-type-descr.length des2))
       (let super-loop ((item1*.des (union-type-descr.item-des* des1))
			(item2*.des (union-type-descr.item-des* des2)))
	 (if (pair? item1*.des)
	     (let sub-loop ((item2*.des		item2*.des)
			    (leftover2*.des	'()))
	       (if (pair? item2*.des)
		   (if (object-type-descr=? (car item1*.des) (car item2*.des))
		       ;;We discard this item2.
		       (super-loop (cdr item1*.des) (append (cdr item2*.des) leftover2*.des))
		     ;;We add this item2 to the leftovers.
		     (sub-loop (cdr item2*.des) (cons (car item2*.des) leftover2*.des)))
		 ;;There are more item2, but no more item1.
		 #f))
	   ;;There are no more item1: are there more item2?
	   (null? item2*.des)))))


;;;; compound type descriptors: intersection

(define-record-type (<intersection-type-descr> %make-intersection-type-descr intersection-type-descr?)
  (nongenerative vicare:type-descriptors:<intersection-type-descr>)
  (sealed #t)
  (fields
    (immutable	item-des*	intersection-type-descr.item-des*)
    (mutable	memoised-length)
    #| end of FIELDS |# )
  (protocol
    (lambda (make-record)
      (lambda (item*.des)
	(make-record item*.des #f))))
  #| end of DEFINE-RECORD-TYPE |# )

(define (make-intersection-type-descr item*.des)
  (if (%list-of-single-item? item*.des)
      (car item*.des)
    (%make-intersection-type-descr item*.des)))

(define <intersection-type-descr>-rtd
  (record-type-descriptor <intersection-type-descr>))

(define <intersection-type-descr>-rcd
  (record-constructor-descriptor <intersection-type-descr>))

;;; --------------------------------------------------------------------

(define (intersection-type-descr.exists intersection.des proc)
  (exists proc (intersection-type-descr.item-des* intersection.des)))

(define (intersection-type-descr.for-all intersection.des proc)
  (for-all proc (intersection-type-descr.item-des* intersection.des)))

(define* (intersection-type-descr.length {des intersection-type-descr?})
  (or (<intersection-type-descr>-memoised-length des)
      (receive-and-return (len)
	  (length (intersection-type-descr.item-des* des))
	(<intersection-type-descr>-memoised-length-set! des len))))

(define* (intersection-type-descr=? {des1 intersection-type-descr?} {des2 intersection-type-descr?})
  ;;Return true if the two intersections have the same components, otherwise return false.
  ;;
  (and (= (intersection-type-descr.length des1)
	  (intersection-type-descr.length des2))
       (let super-loop ((item1*.des (intersection-type-descr.item-des* des1))
			(item2*.des (intersection-type-descr.item-des* des2)))
	 (if (pair? item1*.des)
	     (let sub-loop ((item2*.des	item2*.des)
			    (leftover2*.des	'()))
	       (if (pair? item2*.des)
		   (if (object-type-descr=? (car item1*.des) (car item2*.des))
		       ;;We discard this item2.
		       (super-loop (cdr item1*.des) (append (cdr item2*.des) leftover2*.des))
		     ;;We add this item2 to the leftovers.
		     (sub-loop (cdr item2*.des) (cons (car item2*.des) leftover2*.des)))
		 ;;There are more item2, but no more item1.
		 #f))
	   ;;There are no more item1: are there more item2?
	   (null? item2*.des)))))


;;;; compound type descriptors: complement

(define-record-type (<complement-type-descr> make-complement-type-descr complement-type-descr?)
  (nongenerative vicare:type-descriptors:<complement-type-descr>)
  (sealed #t)
  (fields
    (immutable item-des		complement-type-descr.item-des)
    #| end of FIELDS |# ))

(define <complement-type-descr>-rtd
  (record-type-descriptor <complement-type-descr>))

(define <complement-type-descr>-rcd
  (record-constructor-descriptor <complement-type-descr>))


;;;; compound type descriptors: ancestor-of

(define-record-type (<ancestor-of-type-descr> make-ancestor-of-type-descr ancestor-of-type-descr?)
  (nongenerative vicare:type-descriptors:<ancestor-of-type-descr>)
  (sealed #t)
  (fields
    (immutable item-des		ancestor-of-type-descr.item-des)
    (immutable ancestor-des*	ancestor-of-type-descr.ancestor-des*)
    #| end of FIELDS |# )
  (protocol
    (lambda (make-record)
      (lambda (object.des)
	(make-record object.des (object-type-descr.ancestor-des* object.des))))))

(define <ancestor-of-type-descr>-rtd
  (record-type-descriptor <ancestor-of-type-descr>))

(define <ancestor-of-type-descr>-rcd
  (record-constructor-descriptor <ancestor-of-type-descr>))

;;; --------------------------------------------------------------------

(define* (ancestor-of-type-descr.exists {ancestor-of.des ancestor-of-type-descr?} {proc procedure?})
  (exists  proc (ancestor-of-type-descr.ancestor-des* ancestor-of.des)))

(define* (ancestor-of-type-descr.for-all {ancestor-of.des ancestor-of-type-descr?} {proc procedure?})
  ;;We want to return false if the item in the ANCESTOR-OF is "<top>".
  ;;
  (let ((ancestor*.des (ancestor-of-type-descr.ancestor-des* ancestor-of.des)))
    (and (pair? ancestor*.des)
	 (for-all proc ancestor*.des))))


;;;; compound type descriptors: interfaces

(define-record-type (<interface-type-descr> make-interface-type-descr interface-type-descr?)
  (nongenerative vicare:type-descriptors:<interface-type-descr>)
  (sealed #t)
  (fields
    (immutable type-name		interface-type-descr.type-name)
		;A symbol representing the name of this interface type.
    (immutable method-retriever		interface-type-descr.method-retriever)
		;A function that retrieves  method implementation functions given the
		;name of a method as symbol.
    #| end of FIELDS |# )
  (protocol
    (lambda (make-record)
      (define* (make-interface-type-descr {type-name symbol?} {method-retriever procedure?})
	(make-record type-name method-retriever))
      make-interface-type-descr))
  #| end of DEFINE-RECORD-TYPE |# )

(define <interface-type-descr>-rtd
  (record-type-descriptor <interface-type-descr>))

(define <interface-type-descr>-rcd
  (record-constructor-descriptor <interface-type-descr>))


;;;; object-type descriptors: facilities

(module (object-type-descr=?
	 object-type-descr.parent
	 object-type-descr.ancestor-des*
	 object-type-descr.matching-super-and-sub?
	 object-type-descr.compatible-super-and-sub?
	 object-type-descr.matching-formal-and-operand)

  (include "ikarus.object-type-descr.facilities.scm"	#t)

  #| end of module |# )


;;;; descriptor of objects

(define (type-descriptor-of obj)
  ;;Recursive function.  Build and return  an object type descriptor representing the
  ;;type of obj.
  ;;
  ;;We use a hashtable to detect circular structures in OBJ; we put in here pairs and
  ;;vectors.
  (define table (make-eq-hashtable))
  (let recur ((obj obj))
    (cond ((boolean? obj)		(cond (obj
					       <true>-ctd)
					      (else
					       <false>-ctd)))
	  ((char?    obj)		<char>-ctd)
	  ((symbol?  obj)		(make-enumeration-type-descr (list obj)))
	  ((keyword? obj)		<keyword>-ctd)
	  ((procedure? obj)		<procedure>-ctd)

	  ((fixnum?  obj)		(cond ((fxpositive? obj)
					       <positive-fixnum>-ctd)
					      ((fxnegative? obj)
					       <negative-fixnum>-ctd)
					      ((fxzero? obj)
					       <zero-fixnum>-ctd)
					      (else
					       ;;This should never happen.
					       <fixnum>-ctd)))

	  ((flonum?  obj)		(cond ((flpositive? obj)
					       <positive-flonum>-ctd)
					      ((flnegative? obj)
					       <negative-flonum>-ctd)
					      ((flzero?/positive obj)
					       <positive-zero-flonum>-ctd)
					      ((flzero?/negative obj)
					       <negative-zero-flonum>-ctd)
					      (else
					       ;;This  happens  when  the  flonum  is
					       ;;not-a-number.
					       <flonum>-ctd)))

	  ((ratnum?  obj)		(cond ((ratnum-positive? obj)
					       <positive-ratnum>-ctd)
					      ((ratnum-negative? obj)
					       <negative-ratnum>-ctd)
					      (else
					       ;;This should never happen.
					       <ratnum>-ctd)))
	  ((bignum?  obj)		(cond ((bignum-positive? obj)
					       <positive-bignum>-ctd)
					      ((bignum-negative? obj)
					       <negative-bignum>-ctd)
					      (else
					       ;;This should never happen.
					       <bignum>-ctd)))
	  ((compnum? obj)		(cond ((exact-compnum? obj)
					       <exact-compnum>-ctd)
					      ((zero-compnum? obj)
					       <zero-compnum>-ctd)
					      (else
					       <non-zero-inexact-compnum>-ctd)))
	  ((cflonum? obj)		(cond ((zero-cflonum? obj)
					       <zero-cflonum>-ctd)
					      (else
					       <non-zero-cflonum>-ctd)))

	  ((string?  obj)		(cond ((string-empty? obj)
					       <empty-string>-ctd)
					      (else
					       <nestring>-ctd)))

	  ((null? obj)			<null>-ctd)

	  ((list? obj)			(if (hashtable-ref table obj #f)
					    <nelist>-ctd
					  (begin
					    (let pair-recur ((P obj))
					      (when (pair? P)
						(hashtable-set! table P #t)
						(pair-recur (cdr P))))
					    (make-null-or-list-type-descr (map recur obj)))))

	  ((pair? obj)			(if (hashtable-ref table obj #f)
					    <pair>-ctd
					  (begin
					    (hashtable-set! table obj #t)
					    (make-pair-type-descr (recur (car obj))
								  (recur (cdr obj))))))

	  ((vector?  obj)		(cond ((vector-empty? obj)
					       <empty-vector>-ctd)
					      (else
					       (if (hashtable-ref table obj #f)
						   <nevector>-ctd
						 (begin
						   (hashtable-set! table obj #t)
						   (make-vector-type-descr (map recur (vector->list obj))))))))

	  ((bytevector? obj)		(cond ((bytevector-empty? obj)
					       <empty-bytevector>-ctd)
					      (else
					       <nebytevector>-ctd)))

	  ((simple-condition? obj)	(record-rtd obj))
	  ((condition? obj)		(make-compound-condition-type-descr (map record-rtd (simple-conditions obj))))
	  ((record? obj)		(record-rtd obj))
	  ((record-type-descriptor? obj) (struct-std obj))

	  ((hashtable? obj)		<hashtable>-ctd)
	  ((struct-type-descriptor? obj) <struct>-ctd)
	  ((struct? obj)		(struct-std obj))

	  ((void-object? obj)		<void>-ctd)
	  (else				<top>-ctd))))


;;;; done

#| end of library |# )

;;; end of file
;; Local Variables:
;; mode: vicare
;; End: