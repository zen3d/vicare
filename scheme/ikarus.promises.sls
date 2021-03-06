;;;Ikarus Scheme -- A compiler for R6RS Scheme.
;;;Copyright (C) 2006,2007,2008  Abdulaziz Ghuloum
;;;Modified by Marco Maggi <marco.maggi-ipsu@poste.it>
;;;
;;;This program is free software: you can  redistribute it and/or modify it under the
;;;terms  of the  GNU General  Public  License version  3  as published  by the  Free
;;;Software Foundation.
;;;
;;;This program is  distributed in the hope  that it will be useful,  but WITHOUT ANY
;;;WARRANTY; without  even the implied warranty  of MERCHANTABILITY or FITNESS  FOR A
;;;PARTICULAR PURPOSE.  See the GNU General Public License for more details.
;;;
;;;You should have received a copy of  the GNU General Public License along with this
;;;program.  If not, see <http://www.gnu.org/licenses/>.


#!vicare
(library (ikarus promises)
  (export
    make-promise
    promise?
    force)
  (import (except (vicare)
		  force
		  make-promise
		  promise?)
    (vicare system structs))


(define-struct (promise %make-promise promise?)
  (proc results))

(define* (make-promise {proc procedure?})
  (%make-promise proc #f))

(define* (force {P promise?})
  (if ($promise-results P)
      (apply values ($promise-results P))
    (call-with-values
	($promise-proc P)
      (lambda args
	(if ($promise-results P)
	    (apply values ($promise-results P))
	  (begin
	    ($set-promise-results! P args)
	    (apply values args)))))))


;;;; done

#| end of library |# )

;;; end of file
