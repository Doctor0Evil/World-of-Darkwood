; fan.asia/testing/sound-devcycle.lisp
(defun test-audio-sequence (scene-id)
  (dolist (effect (scene-effects scene-id))
    (trigger-scare-sound effect)
    (sleep 1.0)))
