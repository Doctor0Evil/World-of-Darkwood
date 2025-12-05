;; File: /Engine/Debug/WOD_PhysicsDebugPipeline.lisp
;; Purpose: Unified ALN-style logic spec for WOD debug palette, material adapter,
;;          physics ring buffer, and IDE-agent integration hooks.

(defpackage :wod.debug
  (:use :cl))

(in-package :wod.debug)

;; Core constants
(defparameter +wod-max-palette-entries+ 256)
(defparameter +wod-max-entities+ 4096)
(defparameter +wod-max-frames-logged+ 4096)

;; Logical enums (must mirror BlitzMax constants one-to-one)
(defparameter +mat-empty+      0)
(defparameter +mat-wall+       1)
(defparameter +mat-obstacle+   2)
(defparameter +mat-player+     3)
(defparameter +mat-enemy+      4)
(defparameter +mat-projectile+ 5)

;; Palette entry record
(defstruct wod-color-rgba
  (r 0 :type (unsigned-byte 8))
  (g 0 :type (unsigned-byte 8))
  (b 0 :type (unsigned-byte 8))
  (a 0 :type (unsigned-byte 8)))

;; Global palette (logical model – BlitzMax array mirrors this)
(defparameter *wod-palette*
  (make-array +wod-max-palette-entries+
              :element-type 'wod-color-rgba
              :initial-element (make-wod-color-rgba)))

(defun wod-init-default-palette ()
  "Initialize canonical debug palette for physics/material visualization."
  ;; 0: empty / background (fully transparent)
  (setf (aref *wod-palette* 0)
        (make-wod-color-rgba :r 0 :g 0 :b 0 :a 0))
  ;; 1: solid wall (dark grey)
  (setf (aref *wod-palette* 1)
        (make-wod-color-rgba :r 80 :g 80 :b 80 :a 255))
  ;; 2: obstacle (earthy brown)
  (setf (aref *wod-palette* 2)
        (make-wod-color-rgba :r 120 :g 80 :b 40 :a 255))
  ;; 3: player (sickly green highlight)
  (setf (aref *wod-palette* 3)
        (make-wod-color-rgba :r 40 :g 200 :b 40 :a 255))
  ;; 4: enemy (threat red)
  (setf (aref *wod-palette* 4)
        (make-wod-color-rgba :r 200 :g 40 :b 40 :a 255))
  ;; 5: projectile / thrown object (harsh yellow)
  (setf (aref *wod-palette* 5)
        (make-wod-color-rgba :r 240 :g 220 :b 80 :a 255))
  ;; 250: debug magenta for unknown materials
  (setf (aref *wod-palette* 250)
        (make-wod-color-rgba :r 255 :g 0 :b 255 :a 255))
  t)

(defun wod-material->palette-index (mat-id)
  "Map canonical material ID to 8-bit palette index; 250 = debug magenta."
  (ecase mat-id
    (0 0)
    (1 1)
    (2 2)
    (3 3)
    (4 4)
    (5 5)
    (otherwise 250)))

;; Physics sample record (logical mirror of BlitzMax Type WODPhysicsSample)
(defstruct wod-physics-sample
  (timestamp-s   0.0 :type double-float)
  (frame-number  0   :type fixnum)
  (entity-id     -1  :type fixnum)
  (pos-x-m       0.0 :type single-float)
  (pos-y-m       0.0 :type single-float)
  (vel-x-mps     0.0 :type single-float)
  (vel-y-mps     0.0 :type single-float)
  (force-x-n     0.0 :type single-float)
  (force-y-n     0.0 :type single-float)
  (mass-kg       0.0 :type single-float)
  (collision-flag 0  :type fixnum)
  (impulse-ns    0.0 :type single-float))

;; 2D ring buffer: [frame-slot][entity-index]
(defparameter *wod-physics-ring*
  (make-array (list +wod-max-frames-logged+ +wod-max-entities+)
              :element-type 'wod-physics-sample))

(defparameter *wod-physics-frame-counter* 0)
(defparameter *wod-physics-fixed-dt-s* (/ 1.0d0 60.0d0))

(defun wod-begin-physics-frame (now-s)
  "Prepare the ring-buffer slot for the current physics frame.
IDE agents may zero or tag the frame-slot here for clean logging contexts."
  (declare (ignore now-s))
  (mod *wod-physics-frame-counter* +wod-max-frames-logged+))

(defun wod-record-entity-sample
       (now-s ent-index ent-id
        px py vx vy fx fy m collided j-ns)
  "Record a dense physics sample for given logical entity index in the current frame."
  (let* ((slot (mod *wod-physics-frame-counter* +wod-max-frames-logged+))
         (sample (aref *wod-physics-ring* slot ent-index)))
    (setf (wod-physics-sample-timestamp-s sample) now-s
          (wod-physics-sample-frame-number sample) *wod-physics-frame-counter*
          (wod-physics-sample-entity-id sample) ent-id
          (wod-physics-sample-pos-x-m sample) px
          (wod-physics-sample-pos-y-m sample) py
          (wod-physics-sample-vel-x-mps sample) vx
          (wod-physics-sample-vel-y-mps sample) vy
          (wod-physics-sample-force-x-n sample) fx
          (wod-physics-sample-force-y-n sample) fy
          (wod-physics-sample-mass-kg sample) m
          (wod-physics-sample-collision-flag sample) collided
          (wod-physics-sample-impulse-ns sample) j-ns)
    sample))

(defun wod-end-physics-frame ()
  "Advance physics frame counter, wrapping the ring buffer."
  (incf *wod-physics-frame-counter*)
  (mod *wod-physics-frame-counter* +wod-max-frames-logged+))

(defun wod-dump-material-layer->indexed-pixmap
       (pix-width pix-height tile-buffer &key (material-fn #'identity))
  "Logical mirror of WOD_DumpMaterialLayerToPixmap.
Returns a (simple-array (unsigned-byte 8) (*)) of palette indices
suitable for export / PNG encoding and cross-checking against physics samples.
`tile-buffer` is a function (x y) -> mat-id or a 1D vector if material-fn is identity."
  (let ((out (make-array (* pix-width pix-height)
                         :element-type '(unsigned-byte 8))))
    (dotimes (y pix-height)
      (dotimes (x pix-width)
        (let* ((idx (+ (* y pix-width) x))
               (mat-id (funcall material-fn tile-buffer idx x y))
               (pal (wod-material->palette-index mat-id)))
          (setf (aref out idx) pal))))
    out))
