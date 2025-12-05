; fan.asia/sound/fx.lisp
(defpackage horror-fx
  (:use :cl)
  (defun trigger-scare-sound (event-id)
    (case event-id
      (:jump-scare (play-sound "loud-stinger.wav"))
      (:tension-build (play-sound "creaking-floorboards.mp3"))
      (:npc-approach (play-sound "shadow-whispers.ogg"))
      (t (play-sound "ambient-creep.wav")))))
