;; libraries.scm --
;;
;;This file is meant  to be included by the build dependencies script,  so it must be
;;in the sources search path.

(define-constant INCLUDE-LIBRARY-BUILD-HIERARCHIES
  '())

(define-constant INCLUDE-LIBRARY-DEPENDENCIES-HIERARCHIES
  '())

(define-constant INCLUDE-INSTALL-RULES
  #t)

;;These are the library files generated by the "configure" script starting from ".in"
;;templates.
;;
(define-constant FROM-TEMPLATES-SOURCE-FILES
  '("lib/vicare/platform/configuration.vicare.sls"
    "lib/vicare/platform/constants.vicare.sls"
    "lib/vicare/platform/errno.vicare.sls"
    "lib/vicare/platform/words.vicare.sls"
    ;;"lib/nausicaa/uri/pathnames.vicare.sls"
    ))

;;These are the  library files generated by some automated  process; for example, the
;;"features"  program  that inspects  the  availability  of host  facilities  through
;;preprocessor constant generated by the GNU Autoconf infrastructure.
;;
(define-constant BUILT-SOURCE-FILES
  '("lib/vicare/platform/features.vicare.sls"))

;;This is the table of libraries to compile.  The table is a list of entries:
;;
;;   (?entry ...)
;;
;;each ?ENTRY having one of the formats:
;;
;;   ((?want-feature ...) ?library-name ...)
;;
;;where: each ?WANT-FEATURE is a symbol  defined in the "configure.ac" template using
;;AM_CONDITIONAL  from the  GNU  Automake infrastructure;  ?LIBRARY-NAME  is an  R6RS
;;library name specification.   If no ?WANT-FEATURE is present: the  libraries are to
;;be always processed.
;;
(define-constant LIBRARIES-SPECS
  '((()
     (vicare platform configuration)
     (vicare platform words)
     (vicare platform errno)
     (vicare platform constants)
     (vicare platform features)
     (vicare platform utilities)

     (vicare unsafe capi)
     (vicare unsafe operations)
     (vicare unsafe unicode)

     (vicare language-extensions cond-expand)
     (vicare language-extensions cond-expand OS-id-features)
     (vicare language-extensions cond-expand helpers)
     (vicare language-extensions cond-expand platform-features)
     (vicare language-extensions cond-expand configuration-features)
     (vicare language-extensions cond-expand registry)

     (vicare arguments validation)
     (vicare arguments general-c-buffers)

     (vicare language-extensions syntaxes)
     (vicare language-extensions amb)
     (vicare language-extensions simple-match)
     (vicare language-extensions keywords)
     (vicare language-extensions sentinels)
     (vicare language-extensions custom-ports)
     (vicare language-extensions variables)
     (vicare language-extensions streams)
     (vicare language-extensions loops)
     (vicare language-extensions ascii-chars)
     (vicare language-extensions comparisons)
     (vicare language-extensions hooks)
     (vicare language-extensions callables)
     (vicare language-extensions define-record-extended)
     (vicare language-extensions c-enumerations)
     (vicare language-extensions identifier-substitutions)
     (vicare language-extensions makers)
     (vicare language-extensions ensure)
     (vicare language-extensions pipelines)
     (vicare language-extensions conditions-and-restarts)
     #;(vicare language-extensions tags)

     (vicare build-tools automake)

     (vicare checks)

     (vicare crypto randomisations low)
     (vicare crypto randomisations)
     (vicare crypto randomisations blum-blum-shub)
     (vicare crypto randomisations borosh)
     (vicare crypto randomisations cmrg)
     (vicare crypto randomisations distributions)
     (vicare crypto randomisations lists)
     (vicare crypto randomisations marsaglia)
     (vicare crypto randomisations mersenne)
     (vicare crypto randomisations strings)
     (vicare crypto randomisations vectors)

     (vicare numerics constants)
     (vicare numerics flonum-parser)
     (vicare numerics flonum-formatter)

     (vicare containers comparators)
     (vicare containers iteration-thunks)
     (vicare containers bytevectors)
     (vicare containers auxiliary-syntaxes)
     (vicare containers weak-hashtables)
     (vicare containers object-properties)
     (vicare containers knuth-morris-pratt)
     (vicare containers bytevector-compounds core)
     (vicare containers bytevector-compounds)
     (vicare containers bytevector-compounds unsafe)
     (vicare containers char-sets)
     (vicare containers char-sets blocks)
     (vicare containers char-sets categories)
     (vicare containers lists stx)
     (vicare containers lists low)
     (vicare containers lists)
     (vicare containers vectors low)
     (vicare containers vectors)
     (vicare containers strings low)
     (vicare containers strings)
     (vicare containers strings rabin-karp)
     (vicare containers levenshtein)
     (vicare containers one-dimension-co)
     (vicare containers one-dimension-cc)
     (vicare containers bytevectors u8)
     (vicare containers bytevectors s8)
     (vicare containers arrays)
     (vicare containers binary-heaps)
     (vicare containers chains)
     (vicare containers chains sort)
     (vicare containers slots)
     (vicare containers deques)
     (vicare containers queues)
     (vicare containers stacks)
     (vicare containers dynamic-arrays)
     (vicare containers dynamic-arrays sort)
     (vicare containers binary-search-trees)
     (vicare containers sets-and-bags)
     (vicare containers ilists)
     (vicare containers ilists comparators)
     (vicare containers ilists quotations)
     (vicare containers ralists)

     (vicare containers istacks)
     (vicare containers istacks ralists)
     (vicare containers istacks dynamic-arrays)
     (vicare containers istacks deques)
     (vicare containers istacks lists)
     (vicare containers istacks chains)
     (vicare containers istacks ilists)
     (vicare containers istacks stacks)

     (vicare containers iqueues)
     (vicare containers iqueues dynamic-arrays)
     (vicare containers iqueues queues)
     (vicare containers iqueues deques)
     (vicare containers iqueues chains)

     (vicare containers ideques)
     (vicare containers ideques dynamic-arrays)
     (vicare containers ideques deques)
     (vicare containers ideques chains)

     (vicare parser-tools silex lexer)
     (vicare parser-tools silex)
     (vicare parser-tools silex utilities)
     (vicare parser-tools unix-pathnames)

     (vicare net channels)

     #| end no conditional |# )

    ((WANT_LIBFFI)
     (vicare ffi)
     (vicare ffi foreign-pointer-wrapper))

    ((WANT_LIBICONV)
     (vicare iconv))

    ((WANT_POSIX)
     (vicare posix)
     (vicare posix pid-files)
     (vicare posix lock-pid-files)
     (vicare posix log-files)
     (vicare posix daemonisations)
     (vicare posix simple-event-loop)
     (vicare posix tcp-server-sockets)
     (vicare posix sendmail)
     (vicare posix mailx)
     (vicare posix curl)
     (vicare posix wget)
     (vicare posix find))

    ((WANT_GLIBC)
     (vicare glibc))

    ((WANT_LIBFFI WANT_POSIX WANT_GLIBC)
     (vicare gcc))

    ((WANT_POSIX WANT_LINUX)
     (vicare linux))

    ((WANT_READLINE)
     (vicare readline))

    (()
     (vicare assembler inspection)
     (vicare parser-logic)

     (vicare irregex)
     (vicare pregexp)
     (vicare getopts)
     (vicare formations))

    ((WANT_SRFI)
     (srfi :0)
     (srfi :1)
     (srfi :2)
     (srfi :6)
     (srfi :8)
     (srfi :9)
     (srfi :11)
     (srfi :13)
     (srfi :14)
     (srfi :16)
     (srfi :19)
     (srfi :23)
     (srfi :25)
;;;(srfi :25 multi-dimensional-arrays arlib)
     (srfi :26)
     (srfi :27)
     (srfi :28)
     (srfi :31)
     (srfi :37)
     (srfi :38)
     (srfi :39)
     (srfi :41)
     (srfi :42)
     (srfi :43)
     (srfi :45)
     (srfi :48)
     (srfi :61)
     (srfi :64)
     (srfi :67)
     (srfi :69)
     (srfi :78)
     (srfi :98)
     (srfi :99)
     ;;We  really   need  all   of  these  for   this  SRFI,   because  the
     ;;implementation is in (srfi :101).
     (srfi :101)
     (srfi :101 random-access-lists)
     (srfi :101 random-access-lists procedures)
     (srfi :101 random-access-lists syntax)
     (srfi :101 random-access-lists equal)
     (srfi :111)
     (srfi :112)
     (srfi :113)
     (srfi :114)
     (srfi :115)
     (srfi :116)
     (srfi :116 comparators)
     (srfi :116 quotations))

    ((WANT_SRFI WANT_POSIX)
     (srfi :106))

    ;; ((WANT_NAUSICAA)
    ;;  (nausicaa language auxiliary-syntaxes)
    ;;  (nausicaa language oopp)
    ;;  (nausicaa language multimethods)
    ;;  (nausicaa language builtins)
    ;;  (nausicaa language conditions)
    ;;  (nausicaa language simple-match)
    ;;  (nausicaa)

    ;;  (nausicaa containers lists)
    ;;  (nausicaa containers vectors)
    ;;  (nausicaa containers strings)
    ;;  (nausicaa containers arrays)
    ;;  (nausicaa containers stacks)
    ;;  (nausicaa containers queues)
    ;;  (nausicaa containers bitvectors)
    ;;  (nausicaa containers iterators)

    ;;  (nausicaa parser-tools source-locations)
    ;;  (nausicaa parser-tools lexical-tokens)
    ;;  (nausicaa parser-tools silex default-error-handler)
    ;;  (nausicaa parser-tools lalr lr-driver)
    ;;  (nausicaa parser-tools lalr glr-driver)
    ;;  (nausicaa parser-tools lalr)

    ;;  (nausicaa parser-tools ip-addresses ipv4-address-lexer)
    ;;  (nausicaa parser-tools ip-addresses ipv4-address-parser)
    ;;  (nausicaa parser-tools ip-addresses ipv6-address-lexer)
    ;;  (nausicaa parser-tools ip-addresses ipv6-address-parser)
    ;;  (nausicaa parser-tools ipv4-addresses)
    ;;  (nausicaa parser-tools ipv6-addresses)
    ;;  (nausicaa parser-tools uri)

    ;;  (nausicaa uri ip)
    ;;  (nausicaa uri)
    ;;  (nausicaa parser-tools uri utilities)
    ;;  (nausicaa uri pathnames abstract)
    ;;  (nausicaa uri pathnames unix)
    ;;  (nausicaa uri pathnames)

    ;;  (nausicaa mehve)

    ;; #| end of nausicaa conditional |# )

    #| end of LIBRARY-SPECS |# ))

;;; end of file
;; Local Variables:
;; mode: vicare
;; End:
