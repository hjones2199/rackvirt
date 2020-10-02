#!/usr/bin/env racket

#lang racket
(require ffi/unsafe ffi/unsafe/define xml rackunit)

(module+ capi
  (provide virConnectOpen
           virConnectClose
           virConnectGetHostname
           virConnectGetCapabilities
           virConnectGetType
           virConnectGetURI
           virConnectIsSecure
           virDomainDefineXML
           virDomainCreate
           with-open-vir)
  
  (define-ffi-definer define-virtiface
    (ffi-lib "/usr/lib/libvirt.so"))
  
  (define-virtiface virConnectOpen (_fun _string -> _pointer))
  (define-virtiface virConnectClose (_fun _pointer -> _int))
  (define-virtiface virConnectGetHostname (_fun _pointer -> _string))
  (define-virtiface virConnectGetCapabilities (_fun _pointer -> _string))
  (define-virtiface virConnectGetType (_fun _pointer -> _string))
  (define-virtiface virConnectGetURI (_fun _pointer -> _string))
  (define-virtiface virConnectIsSecure (_fun _pointer -> _int))
  (define-virtiface virDomainDefineXML (_fun _pointer _string -> _pointer))
  (define-virtiface virDomainCreate (_fun _pointer -> _int))

  (define-syntax-rule (with-open-vir (var uri) exprs ...)
    (let* ([var (virConnectOpen uri)] [ans (begin exprs ...)])
      (virConnectClose var)
      ans)))

(define domain-xexpr
  `(domain
    ((type "kvm"))
    (name ,(symbol->string (gensym)))
    (memory
     ((unit "GiB"))
     "2")
    (vcpu
     ((placement "static"))
     "1")
    (clock ((offset "utc")))
    (os
     (type
      ((arch "x86_64"))
      "hvm")
     (boot ((dev "hd"))))))

(module+ main
  (require (submod ".." capi))

  (define (serialize-capabilities hostptr)
    (string->xexpr (virConnectGetCapabilities hostptr)))
  
  (with-open-vir (x "")
    (printf "Hostname: ~a~%" (virConnectGetHostname x))
    (printf "Capabilities: ~%~a~%" (serialize-capabilities x))
    (printf "Connection Type: ~a~%" (virConnectGetType x))
    (printf "Connection URI: ~a~%" (virConnectGetURI x))
    (printf "Connection ~a secure~%"
            (if (equal? (virConnectIsSecure x) 1) "is" "is not"))
    (printf "~a~%" (xexpr->string domain-xexpr))))
