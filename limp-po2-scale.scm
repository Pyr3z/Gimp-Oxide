;; Scales an image with good interpolation upwards towards the nearest Po2 in
;; terms of dimensions. Use me from the command line.
;;   - Levi Perez in GIMP 2.10.18, 2020-02-25

(define (po2-ceil in-scalar)
  (pow 2 (ceiling (/ (log in-scalar) (log 2))))
)

(define (po2-floor in-scalar)
  (pow 2 (floor (/ (log in-scalar) (log 2))))
)

(define (po2-mid in-scalar)
  (pow 2 (round (/ (log in-scalar) (log 2))))
)


(define (force-get in-forced)
  (lambda (i) (cons in-forced i))
)


(define (limp-po2-scale rounding squaring filelist) (let*
  (
    (po2-func (cond ((= rounding 2) po2-mid)
                    ((= rounding 1) po2-floor)
                     (else          po2-ceil)
    ))
    (height-getter (cond ((= squaring 0) gimp-image-height)
                         ((= squaring 2) gimp-image-height)
                         ((= squaring 1) gimp-image-width)
                          (else          (force-get squaring))
    ))
    (width-getter  (cond ((= squaring 0) gimp-image-width)
                         ((= squaring 2) gimp-image-height)
                         ((= squaring 1) gimp-image-width)
                          (else          (force-get squaring))
    ))
  )

  ;; Let's fuckin do it.

  ;; (gimp-context-push)
  ;; (gimp-context-set-interpolation INTERPOLATION-NOHALO)

  (while (not (null? filelist)) (let*
    (
      (file   (car filelist))
      (image  (car (gimp-file-load RUN-NONINTERACTIVE file file)))
      (drawbl (car (gimp-image-get-active-layer image)))
      (width  (po2-func (car (width-getter  image))))
      (height (po2-func (car (height-getter image))))
    )

    (write "  -->  ") (write file) (write "  <--") (newline)

    (gimp-image-scale image width height)
    (gimp-file-save RUN-NONINTERACTIVE image drawbl file file)
    (gimp-image-delete image)
    (set! filelist (cdr filelist))
  ))

  ;; (gimp-context-pop)
))
