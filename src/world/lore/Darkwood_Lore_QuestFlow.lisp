;; ======================================================================
;; WOD – Darkwood Lore Integration: Quest, Dialogue, Endings
;; File: src/world/lore/Darkwood_Lore_QuestFlow.lisp
;; ======================================================================

(defpackage :wod.lore.core
  (:use :cl))
(in-package :wod.lore.core)

;; ---------- Core Lore Flags ----------
(defparameter *lore-flags*
  '(:met-doctor nil
    :read-doctor-notes nil
    :met-trader nil
    :saw-roots-apartment-vision nil
    :burned-strange-tree nil
    :joined-forest nil
    :villagers-hostile nil
    :plague-explained nil))

(defun set-flag (key &optional (value t))
  (setf (getf *lore-flags* key) value))

(defun flag? (key) (getf *lore-flags* key))

;; ---------- Quest Nodes ----------
(defun q-meet-doctor ()
  '(:id :q-meet-doctor
    :title "The Doctor in the Woods"
    :steps (:track-footprints :enter-hideout :confront-doctor)
    :rewards (:info-doctor :map-fragment)
    :effects ((set-flag :met-doctor)
              (set-flag :villagers-hostile))))

(defun q-trader-dreams ()
  '(:id :q-trader-dreams
    :title "The Trader’s Warnings"
    :steps (:nightmare-cutscene :dialogue-trader :accept-forest-truth)
    :rewards (:info-forest :strange-key)
    :effects ((set-flag :met-trader)
              (set-flag :saw-roots-apartment-vision))))

(defun q-plague-notes ()
  '(:id :q-plague-notes
    :title "Rot in the Roots"
    :steps (:search-lab :collect-notes :survive-night-event)
    :rewards (:info-plague :craft-plague-antidote)
    :effects ((set-flag :read-doctor-notes)
              (set-flag :plague-explained))))

(defun q-strange-tree-ending ()
  '(:id :q-strange-tree-ending
    :title "The Talking Tree"
    :steps (:reach-heart-of-forest :decide-burn-or-join)
    :rewards (:ending-branch)
    :effects ((lambda (choice)
                (ecase choice
                  (:burn (set-flag :burned-strange-tree))
                  (:join (set-flag :joined-forest)))))))

;; ---------- Dialogue Dispatch ----------
(defun dialogue-villager (trust plague-knowledge)
  (cond
    ((and (< trust 0.3) (not plague-knowledge))
     "Outsider. Stay away. Forest’s already in our blood.")
    ((and (>= trust 0.3) (not plague-knowledge))
     "You’ve seen the bodies, haven’t you? They don’t stay human for long.")
    ((and (>= trust 0.3) plague-knowledge)
     "So you read the Doctor’s scribbles too. The forest’s infection isn’t a sickness… it’s a decision.")
    (t
     "Doors stay locked at night. That’s all you need to know.")))

(defun dialogue-savage-echo (player-class moral-band)
  (declare (ignore player-class))
  (ecase moral-band
    (:benevolent "The forest doesn’t want your mercy. It wants your bones.")
    (:neutral    "You wander. We rot. Same road, different pace.")
    (:malevolent "You smell like us already. Come closer.")))

(defun epilogue-text ()
  (cond
    ((flag? :burned-strange-tree)
     "The fire climbs, but the roots do not burn. When you wake, wallpaper hides bark, and the city hum masks a heartbeat under concrete.")
    ((flag? :joined-forest)
     "You stop fighting. The forest closes over you like a second skin. Footsteps vanish. Voices become roots.")
    (t
     "You stagger at the edge of the treeline, never quite leaving. Every road bends back into the dark.")))

;; ---------- Main Lore Integration Entry ----------
(defun run-lore-beat (event context)
  (case event
    (:enter-village
     (let ((trust (getf context :village-trust 0.1))
           (plague-knowledge (flag? :plague-explained)))
       (format t "~&[VILLAGER] ~A~%"
               (dialogue-villager trust plague-knowledge))))
    (:meet-savage
     (format t "~&[SAVAGE] ~A~%"
             (dialogue-savage-echo
              (getf context :class :rotkin)
              (getf context :moral-band :neutral))))
    (:trigger-epilogue
     (format t "~&[EPILOGUE] ~A~%" (epilogue-text)))
    (t
     (format t "~&[LORE-ENGINE] Unknown event ~A~%" event))))

;; ======================================================================
;; END FILE
;; ======================================================================
