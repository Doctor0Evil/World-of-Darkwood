; fan.asia/sound/dynamic-process.lisp
(defun ai-dynamic-audio (user-action stress env-factor)
  (let ((effect (cond ((> stress 80) "distorted-voice") ((> env-factor 70) "binaural-pulse") (t "none"))))
    (apply-audio-effect effect)))
