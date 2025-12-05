;; core/world_of_darkwood/combat/lore_asset_expansion.aln.lisp
;; Unified logic script summarizing design decisions for WOD’s Darkwood-derived assets.
(defpackage :wod.darkwood.assets
  (:use :cl))
(in-package :wod.darkwood.assets)

(defstruct asset-gap
  id type severity description recommendation tags)

(defparameter *texture-gaps*
  (list
   (make-asset-gap
    :id :forest_roots_variants
    :type :texture
    :severity :medium
    :description "Redundant root/grass textures from Darkwood-style forests create visual repetition on large, procedural maps."
    :recommendation "Cluster existing variants into semantic sets (rotting, blood-soaked, fungal, ash) and add new horror-focused tiles per biome; expose weights in the map generator so repetition can be tuned per region."
    :tags '(:forest :biome :horror :procedural))
   (make-asset-gap
    :id :building_damage_layers
    :type :texture
    :severity :high
    :description "Static building tiles do not visually reflect progressive barricade decay, infestation, or gore buildup."
    :recommendation "Introduce 3–4 destruction layers per wall/window/floor (intact→cracked→rotting→breached), each with blood/fungus variants, and link them directly to combat and night-event outcomes."
    :tags '(:hideout :siege :gore :stateful))))

(defparameter *ai-gaps*
  (list
   (make-asset-gap
    :id :pathfinding_stall
    :type :ai
    :severity :high
    :description "Enemies can stall on corners, doors, and dense props in Darkwood-like layouts, enabling trivial kiting."
    :recommendation "Augment navmesh with micro-links and 'panic detour' behavior: if an agent fails to progress after N ticks, expand path radius, allow obstacle shoves, and trigger a brief aggression spike rather than idle looping."
    :tags '(:pathfinding :combat :navmesh))
   (make-asset-gap
    :id :pack_logic_absence
    :type :ai
    :severity :medium
    :description "Most creatures behave as isolated agents rather than coordinated packs, which undercuts large-map horror."
    :recommendation "Add pack controllers for dogs/chompers/banshee-type mobs: shared target selection, flanking roles, and morale checks influenced by global forest 'mood' and night events."
    :tags '(:pack-ai :horror-pressure :encounters))))

(defparameter *narrative-gaps*
  (list
   (make-asset-gap
    :id :npc_branching_shallow
    :type :dialogue
    :severity :high
    :description "Certain NPCs exhibit limited branching—few long-term consequences, minimal stateful memory of the player’s sins."
    :recommendation "Model each talkable NPC with a personality vector (trust, superstition, zeal, despair) driven by Slavic/Bloc folklore; gate dialogue, services, and betrayal events behind those drifting values instead of binary flags."
    :tags '(:folklore :personality :trust))
   (make-asset-gap
    :id :cut_content_reintegration
    :type :design
    :severity :medium
    :description "Cut mechanics/items (e.g., marginal weapons, experimental skills) remain unused but are thematically compatible with the setting."
    :recommendation "Re-introduce selected cut content as rare, cursed or prototype variants with explicit narrative cost—unstable guns, blood-price skills, cursed trinkets—rather than simple power creep."
    :tags '(:cut-content :risk-reward :lore))))

(defun classify-wod-priority (gap)
  (ecase (asset-gap-severity gap)
    (:high :must-address-before-beta)
    (:medium :alpha/early-beta-critical)
    (:low :nice-to-have)))

(defun dump-wod-roadmap ()
  (labels ((pp-gap (g)
             (format t "~&[~A] ~A (~A)~%  ~A~%  → ~A~2%"
                     (asset-gap-id g)
                     (asset-gap-type g)
                     (classify-wod-priority g)
                     (asset-gap-description g)
                     (asset-gap-recommendation g))))
    (mapc #'pp-gap *texture-gaps*)
    (mapc #'pp-gap *ai-gaps*)
    (mapc #'pp-gap *narrative-gaps*)))

;; Hook: call (dump-wod-roadmap) from the Darkwood_Command_Terminal to print
;; a structured asset/logic roadmap for the current WOD build.
