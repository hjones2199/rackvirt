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
           with-open-vir)
  
  (define-ffi-definer define-libvirt
    (ffi-lib "libvirt_driver_interface"))
  
  (define-libvirt virConnectOpen (_fun _string -> _pointer))
  (define-libvirt virConnectClose (_fun _pointer -> _int))
  (define-libvirt virConnectGetHostname (_fun _pointer -> _string))
  (define-libvirt virConnectGetCapabilities (_fun _pointer -> _string))
  (define-libvirt virConnectGetType (_fun _pointer -> _string))
  (define-libvirt virConnectGetURI (_fun _pointer -> _string))
  (define-libvirt virConnectIsSecure (_fun _pointer -> _int))

  (define-syntax-rule (with-open-vir (var uri) exprs ...)
    (let ([var (virConnectOpen uri)])
      exprs ...
      (virConnectClose uri))))

;; (module+ test
;;   (require (submod ".." capi))
;;   (let ([default-host (virConnectOpen "")])
;;     (check-equal? (virConnectGetHostname default-host) (system "hostname -f"))))

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
            (if (equal? (virConnectIsSecure x) 1) "is" "is not"))))
