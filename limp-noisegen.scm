;; Generates some handy test textures to foo bar around with.
;;   - Levi Perez in GIMP 2.10.18, 2020-02-27

(define (limp-noisegen-solid filename xsize ysize) (let*
  (
    (img (car (gimp-image-new xsize ysize RGB)))
    (lay (car (gimp-layer-new img xsize ysize 0 "limp-noisegen" 100 28)))
    (tileable TRUE)
    (turbulent FALSE)
    (detail-lvl 4)
  )

  (gimp-context-push)
  (gimp-image-insert-layer img lay 0 0)

  (write (string-append "Generating perlin (solid) noise on " filename " ..."))

  (plug-in-solid-noise RUN-NONINTERACTIVE img lay tileable turbulent (rand) detail-lvl 16 16)

  (file-png-save-defaults RUN-NONINTERACTIVE img lay filename filename)

  (gimp-context-pop)
))

