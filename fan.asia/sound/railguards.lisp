; fan.asia/sound/railguards.lisp
(defun enforce-railguard (sound-id recent-events)
  (unless (member sound-id recent-events)
    (play-sound sound-id)))
