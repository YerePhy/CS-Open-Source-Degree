;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname space-invaders-starter) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/universe)
(require 2htdp/image)

;; Space Invaders


;; Constants:

(define WIDTH  300)
(define HEIGHT 500)
(define BCKG (empty-scene WIDTH HEIGHT))
(define GAME-OVER (place-image (text "GAME OVER" (quotient WIDTH 8) "black") (quotient WIDTH 2) (quotient HEIGHT 2) BCKG))

(define INVADER-X-SPEED 2)  ;speeds (not velocities) in pixels per tick
(define INVADER-Y-SPEED 2)
(define TANK-SPEED 2)
(define MISSILE-SPEED 10)

(define INVADE-RATE 20)
(define INVADER
  (overlay/xy (ellipse 10 15 "outline" "blue")              ;cockpit cover
              -5 6
              (ellipse 20 10 "solid"   "blue")))            ;saucer
(define INVADER-WIDTH (image-width INVADER))
(define INVADER-HEIGHT/2 (quotient INVADER-WIDTH 2))
(define INVADER-WIDTH/2 (quotient (image-width INVADER) 2))

(define TANK
  (overlay/xy (overlay (ellipse 28 8 "solid" "black")       ;tread center
                       (ellipse 30 10 "solid" "green"))     ;tread outline
              5 -14
              (above (rectangle 5 10 "solid" "black")       ;gun
                     (rectangle 20 10 "solid" "black"))))   ;main body
(define TANK-HEIGHT (image-height TANK))
(define TANK-HEIGHT/2 (quotient TANK-HEIGHT 2))
(define TANK-WIDTH/2 (quotient (image-width TANK) 2))

(define MISSILE (ellipse 5 15 "solid" "red"))
(define MISSILE-WIDTH (image-width MISSILE))
(define MISSILE-WIDTH/2 (quotient (image-width MISSILE) 2))
(define MISSILE-HEIGHT (image-height MISSILE))
(define MISSILE-HEIGHT/2 (quotient MISSILE-HEIGHT 2))


;; Data Definitions:

(define-struct game (invaders missiles tank))
;; Game is (make-game  (list of Invader) (list of Missile) Tank)
;; interp. the current state of a space invaders game
;;         with the current invaders, missiles and tank position

;; Game constants defined below Missile data definition

#;
(define (fn-for-game s)
  (... (fn-for-loinvader (game-invaders s))
       (fn-for-lom (game-missiles s))
       (fn-for-tank (game-tank s))))



(define-struct tank (x dir))
;; Tank is (make-tank Number Integer[-1, 1])
;; interp. the tank location is x, HEIGHT - TANK-HEIGHT/2 in screen coordinates
;;         the tank moves TANK-SPEED pixels per clock tick left if dir -1, right if dir 1

(define T0 (make-tank (quotient WIDTH 2) 1))   ;center going right
(define T1 (make-tank 50 1))            ;going right
(define T2 (make-tank 50 -1))           ;going left

#;
(define (fn-for-tank t)
  (... (tank-x t) (tank-dir t)))


(define-struct invader (x y dx))
;; Invader is (make-invader Number Number Number)
;; interp. the invader is at (x, y) in screen coordinates
;;         the invader along x by dx pixels per clock tick

(define I1 (make-invader 150 100 12))           ;not landed, moving right
(define I2 (make-invader 150 HEIGHT -10))       ;exactly landed, moving left
(define I3 (make-invader 150 (+ HEIGHT 10) 10)) ;> landed, moving right


#;
(define (fn-for-invader invader)
  (... (invader-x invader) (invader-y invader) (invader-dx invader)))


(define-struct missile (x y))
;; Missile is (make-missile Number Number)
;; interp. the missile's location is x y in screen coordinates

(define M1 (make-missile 150 300))                       ;not hit U1
(define M2 (make-missile (invader-x I1) (+ (invader-y I1) 10)))  ;exactly hit U1
(define M3 (make-missile (invader-x I1) (+ (invader-y I1)  5)))  ;> hit U1

#;
(define (fn-for-missile m)
  (... (missile-x m) (missile-y m)))



(define G0 (make-game empty empty T0))
(define G1 (make-game empty empty T1))
(define G2 (make-game (list I1) (list M1) T1))
(define G3 (make-game (list I1 I2) (list M1 M2) T1))


;; Functions;


;; Game -> Game
;; start the space invaders game

(define (main s)
  (big-bang s
    (on-tick next-game)
    (to-draw render-game)  
    (stop-when game-over? last-picture)           
    (on-key handle-keys)))


;; Game -> Game
;; produce the next Game state

(check-random
 (next-game
  (make-game 
   (list
    (make-invader (quotient WIDTH 2) (quotient HEIGHT 2) INVADER-X-SPEED)
    (make-invader (quotient WIDTH 4) (quotient HEIGHT 4) (- INVADER-X-SPEED)))
   (list
    (make-missile (quotient WIDTH 2) (quotient HEIGHT 2))
    (make-missile (quotient WIDTH 8) (quotient HEIGHT 8)))
   (make-tank (quotient WIDTH 2) (- 1))))
 (make-game
   (list
    (make-invader
     (+ (+ (random (- WIDTH INVADER-WIDTH)) INVADER-WIDTH/2) INVADER-X-SPEED)
     (+ (- INVADER-HEIGHT/2) INVADER-Y-SPEED)
     INVADER-X-SPEED)
    (make-invader
     (+ (quotient WIDTH 4) (- INVADER-X-SPEED))
     (+ (quotient HEIGHT 4) INVADER-Y-SPEED)
     (- INVADER-X-SPEED)))
   (list
    (make-missile (quotient WIDTH 8) (- (quotient HEIGHT 8) MISSILE-SPEED)))
   (make-tank (- (quotient WIDTH 2) TANK-SPEED) (- 1))))
   
(define (next-game g)
  (make-game
   (move-invaders (spawn-invader (flip-dx (filter-dead-invaders (game-invaders g) (game-missiles g)))))
   (move-missiles (filter-out-missiles (filter-deadly-missiles (game-missiles g) (game-invaders g))))
   (move-tank (game-tank g))))

;; <use function composition>


;; Tank -> Tank
;; move Tank in x direction by (* (tank-dir Tank) TANK-SPEED).
;; There are two special cases:
;;    - If (<= (tank-x t) TANK-WIDTH/2) is true, Tank does not moves
;;    - If (>= (tank-x t) (- WIDTH TANK-WIDTH/2)), Tank does not moves
;; FIX: make the tank move when it is at the borders!

;(define (move-tank t) (make-tank TANK-WIDTH/2 1))  ;stub

(check-expect (move-tank
               (make-tank TANK-WIDTH/2 (- 1)))
              (make-tank (+ TANK-WIDTH/2 TANK-SPEED) 1))
(check-expect (move-tank
               (make-tank (- WIDTH TANK-WIDTH/2) 1))
              (make-tank (+ (- WIDTH TANK-WIDTH/2) (- TANK-SPEED)) (- 1)))
(check-expect (move-tank
               (make-tank (quotient WIDTH 2) 1))
              (make-tank (+ (quotient WIDTH 2) (* 1 TANK-SPEED)) 1))
(check-expect (move-tank
               (make-tank (quotient WIDTH 2) (- 1)))
              (make-tank (+ (quotient WIDTH 2) (* (- 1) TANK-SPEED)) (- 1)))
(check-expect (move-tank
               (make-tank (- TANK-WIDTH/2 1) (- 1)))
              (make-tank (+ TANK-WIDTH/2 TANK-SPEED) 1))
(check-expect (move-tank
               (make-tank (+ (- WIDTH TANK-WIDTH/2) 1) 1))
              (make-tank (+ (- WIDTH TANK-WIDTH/2) (- TANK-SPEED)) (- 1)))

(define (move-tank t)
  (cond [(<= (tank-x t) TANK-WIDTH/2) (make-tank (+ TANK-WIDTH/2 TANK-SPEED) 1)]
        [(>= (tank-x t) (- WIDTH TANK-WIDTH/2)) (make-tank (+ (- WIDTH TANK-WIDTH/2) (- TANK-SPEED)) (- 1))]
        [else (make-tank (+ (tank-x t) (* (tank-dir t) TANK-SPEED)) (tank-dir t))]))

;; <use template for Tank>

;; ListOfInvader ListOfMissile -> ListOfInvader
;; remove all the Invader having a common postion x, y
;; with any of the Missile in ListOfMissile
;; CROSS PRODUCT OF TYPE COMMENTS TABLE
;;
;;                                     lom
;;                           empty           (cons Missile LOM)                
;;                                         |
;;     empty                              empty
;; l                         --------------------------------
;; o   (cons Invader LOI)       loi       |    [(invader-dead? lom (first loi)) (filter-dead-invaders (rest loi) lom)]
;; i                                      |    [else (cons (first loi) (filter-dead-invaders (rest loi) lom))]

;(define (filter-dead-invaders loi lom) empty)  ;stub

(check-expect (filter-dead-invaders empty empty) empty)
(check-expect (filter-dead-invaders
               empty
               (list
                (make-missile (quotient WIDTH 4) (quotient HEIGHT 4))
                (make-missile (quotient WIDTH 2) (quotient HEIGHT 2))))
              empty)
(check-expect (filter-dead-invaders
               (list
                (make-invader 0 0 INVADER-X-SPEED)
                (make-invader (quotient WIDTH 2) (quotient HEIGHT 2) (- INVADER-X-SPEED)))
               empty)
              (list
               (make-invader 0 0 INVADER-X-SPEED)
               (make-invader (quotient WIDTH 2) (quotient HEIGHT 2) (- INVADER-X-SPEED))))
(check-expect (filter-dead-invaders
               (list
                (make-invader 0 0 INVADER-X-SPEED)
                (make-invader (quotient WIDTH 2) (quotient HEIGHT 2) (- INVADER-X-SPEED)))
               (list
                (make-missile (quotient WIDTH 4) (quotient HEIGHT 4))
                (make-missile (quotient WIDTH 2) (quotient HEIGHT 2))))
              (list
               (make-invader 0 0 INVADER-X-SPEED)))

(define (filter-dead-invaders loi lom)
  (cond [(empty? loi) empty]
        [(empty? lom) loi]
        [(invader-dead? lom (first loi)) (filter-dead-invaders (rest loi) lom)]
        [else (cons (first loi) (filter-dead-invaders (rest loi) lom))]))

;; <use template for ListOfInvaders with addtional parameter ListOfMissile>


;; ListOfMissile Invader -> Boolean
;; returns true if the Invader
;; has common position with any
;; Missile in ListOfMissile

;(define (invader-dead? lom i) false)  ;stub

;; Examples for testing invader-dead?:

(check-expect (invader-dead?
               empty
               (make-invader (quotient WIDTH 4) (quotient HEIGHT 4) INVADER-X-SPEED))
              false)
(check-expect (invader-dead?
               (list
                (make-missile 0 0)
                (make-missile (quotient WIDTH 2) (quotient HEIGHT 2)))
               (make-invader (quotient WIDTH 4) (quotient HEIGHT 4) INVADER-X-SPEED))
              false)
(check-expect (invader-dead?
               (list
                (make-missile 0 0)
                (make-missile (quotient WIDTH 2) (quotient HEIGHT 2)))
               (make-invader (quotient WIDTH 2) (quotient HEIGHT 2) INVADER-X-SPEED))
              true)

(define (invader-dead? lom i)
  (cond [(empty? lom) false]
        [(missile-hit-invader? i (first lom)) true]
        [else (invader-dead? (rest lom) i)]))
  
;; <use template for ListOfMissile with additional parameter with type Invader>


;; ListOfInvader -> ListOfInvader
;; change the sign of the velocity
;; of all the Invader in the input
;; ListOfInvader that are in:
;;    - (<= (invader-x Invader) INVADER-WIDTH/2)
;;    - (>= (invader-x Invader) (- WIDTH INVADER-WIDTH/2))

; (define (flip-dx loi) empty)  ;stub

;; Examples for testing flip-dx?:

(check-expect (flip-dx empty) empty)
(check-expect (flip-dx
               (list
                (make-invader 0 (quotient HEIGHT 2) (- INVADER-X-SPEED))
                (make-invader WIDTH (quotient HEIGHT 2) INVADER-X-SPEED)))
              (list
                (make-invader 0 (quotient HEIGHT 2) INVADER-X-SPEED)
                (make-invader WIDTH (quotient HEIGHT 2) (- INVADER-X-SPEED))))
(check-expect (flip-dx
               (list
                (make-invader INVADER-WIDTH/2 (quotient HEIGHT 2) (- INVADER-X-SPEED))
                (make-invader (- WIDTH INVADER-WIDTH/2) (quotient HEIGHT 2) INVADER-X-SPEED)))
              (list
                (make-invader INVADER-WIDTH/2 (quotient HEIGHT 2) INVADER-X-SPEED)
                (make-invader (- WIDTH INVADER-WIDTH/2) (quotient HEIGHT 2) (- INVADER-X-SPEED))))
(check-expect (flip-dx
               (list
                (make-invader (quotient WIDTH 2) (quotient HEIGHT 2) (- INVADER-X-SPEED))))
               (list
                (make-invader (quotient WIDTH 2) (quotient HEIGHT 2) (- INVADER-X-SPEED))))
               
(define (flip-dx loi)
  (cond [(empty? loi) empty]
        [(<= (invader-x (first loi)) INVADER-WIDTH/2)
         (cons
          (make-invader
           (invader-x (first loi))
           (invader-y (first loi))
           INVADER-X-SPEED)
          (flip-dx (rest loi)))]
        [(>= (invader-x (first loi)) (- WIDTH INVADER-WIDTH/2))
         (cons
          (make-invader
           (invader-x (first loi))
           (invader-y (first loi))
           (- INVADER-X-SPEED))
          (flip-dx (rest loi)))]
        [else (cons (first loi) (flip-dx (rest loi)))]))

;; <use template for ListOfInvader>


;; ListOfInvader -> ListOfInvader
;; move all the Invaders in ListOfInvaders:
;;    - By (invader-dx Invader) in the x direction, this can be:
;;          - INVADER-X-SPEED
;;          - (- INVADER-X-SPEED)
;;    - By INVADER-Y-SPEED in y direction
            
; (define (move-invaders loi) empty)  ;stub

(check-expect (move-invaders empty) empty)
(check-expect
 (move-invaders
  (list
   (make-invader (quotient WIDTH 2) (quotient HEIGHT 2) INVADER-X-SPEED)
   (make-invader (quotient WIDTH 4) (quotient HEIGHT 4) (- INVADER-X-SPEED))))
 (list 
  (make-invader
   (+ (quotient WIDTH 2) INVADER-X-SPEED)
   (+ (quotient HEIGHT 2)  INVADER-Y-SPEED)
   INVADER-X-SPEED)
  (make-invader
   (+ (quotient WIDTH 4) (- INVADER-X-SPEED))
   (+ (quotient HEIGHT 4) INVADER-Y-SPEED)
   (- INVADER-X-SPEED))))

(define (move-invaders loi)
  (cond [(empty? loi) empty]
          [else
           (cons
            (make-invader
             (+ (invader-x (first loi)) (invader-dx (first loi)))
             (+ (invader-y (first loi)) INVADER-Y-SPEED)
             (invader-dx (first loi))) 
            (move-invaders (rest loi)))]))

;; <use template for ListOfInvader>


;; ListOfMissile ListOfInvader -> ListOfMissile
;; remove the Missile having a common postion x, y
;; with any of the Invader in ListOfInvader
;; CROSS PRODUCT OF TYPE COMMENTS TABLE
;;
;;                                                loi 
;;                                   empty                (cons Invader LOI)                
;;                                                |
;;     empty                                     empty
;; l                         ---------------------------------------------
;; o   (cons Missile LOM)                         |       [(has-hit? loi (first lom)) (filter-deadly-missiles (rest lom) loi)]
;; m                                 lom          |       [else (cons (first lom) (filter-deadly-missiles (rest lom) loi))]

 
;(define (filter-deadly-missiles lom loi) empty)  ;stub


(check-expect (filter-deadly-missiles empty empty) empty)
(check-expect (filter-deadly-missiles
               empty
               (list
                (make-missile 0 0)
                (make-missile (quotient WIDTH 2) (quotient HEIGHT 2))))
              empty)
(check-expect
 (filter-deadly-missiles
  (list
   (make-missile 0 0)
   (make-missile (quotient WIDTH 2) (quotient HEIGHT 2)))
  empty)
 (list
  (make-missile 0 0)
  (make-missile (quotient WIDTH 2) (quotient HEIGHT 2))))
(check-expect (filter-deadly-missiles
               (list
                (make-missile 0 0)
                (make-missile (quotient WIDTH 2) (quotient HEIGHT 2)))
               (list
                (make-invader (quotient WIDTH 4) (quotient HEIGHT 4) INVADER-X-SPEED)
                (make-invader (quotient WIDTH 2) (quotient HEIGHT 2) (- INVADER-X-SPEED))))
              (list (make-missile 0 0)))

(define (filter-deadly-missiles lom loi)
  (cond [(empty? lom) empty]
        [(empty? loi) lom]
        [(has-hit? loi (first lom)) (filter-deadly-missiles (rest lom) loi)]
        [else (cons (first lom) (filter-deadly-missiles (rest lom) loi))]))


;; ListOfInvader Missile -> Boolean
;; returns true if the Missile
;; has common position with any
;; Invader in ListOfInvader

;(define (has-hit? loi m) false)  ;stub

(check-expect (has-hit?
               empty
               (make-missile (quotient WIDTH 4) (quotient HEIGHT 4)))
              false)
(check-expect (has-hit?
               (list
                (make-invader 0 0 INVADER-X-SPEED)
                (make-invader (quotient WIDTH 2) (quotient HEIGHT 2) INVADER-X-SPEED))
               (make-missile (quotient WIDTH 4) (quotient HEIGHT 4)))
              false)
(check-expect (has-hit?
               (list
                (make-invader 0 0 INVADER-X-SPEED)
                (make-invader (quotient WIDTH 2) (quotient HEIGHT 2) INVADER-X-SPEED))
               (make-missile (quotient WIDTH 2) (quotient HEIGHT 2))) true)

(define (has-hit? loi m)
  (cond [(empty? loi) false]
        [(missile-hit-invader? (first loi) m) true]
        [else (has-hit? (rest loi) m)]))

;; <use template for ListOfInvader with an addition parameter with type Missile>


;; Invader Missile -> Boolean
;; Returns true if:
;;(and
;; (and
;;  (>= (missile-x Missile) (- (invader-x Invader) (+ INVADER-WIDTH/2 MISSILE-WIDTH/2)))
;;  (<= (missile-x Missile) (+ (invader-x Invader) (+ INVADER-WIDTH/2 MISSILE-WIDTH/2))))
;; (and
;;  (>= (missile-y Missile) (- (invader-y Invader) (+ INVADER-HEIGHT/2 MISSILE-HEIGHT/2)))
;;  (<= (missile-y Missile) (+ (invader-y Invader) (+ INVADER-HEIGHT/2 MISSILE-HEIGHT/2)))))
;; I.e. if the Missile is in the hit-box of the invader

;(define (missile-hit-invader? i m) false)  ;stub

(check-expect
 (missile-hit-invader?
  (make-invader
   (quotient WIDTH 2)
   (quotient HEIGHT 2)
   INVADER-X-SPEED)
  (make-missile
   (- (quotient WIDTH 2) (+ INVADER-WIDTH/2 MISSILE-WIDTH/2 1))
   (quotient HEIGHT 2)))
 false)
(check-expect
 (missile-hit-invader?
  (make-invader
   (quotient WIDTH 2)
   (quotient HEIGHT 2)
   INVADER-X-SPEED)
  (make-missile
   (- (quotient WIDTH 2) (+ INVADER-WIDTH/2 MISSILE-WIDTH/2))
   (quotient HEIGHT 2)))
 true)
(check-expect
 (missile-hit-invader?
  (make-invader
   (quotient WIDTH 2)
   (quotient HEIGHT 2)
   INVADER-X-SPEED)
  (make-missile
   (quotient WIDTH 2)
   (quotient HEIGHT 2)))
 true)
(check-expect
 (missile-hit-invader?
  (make-invader
   (quotient WIDTH 2)
   (quotient HEIGHT 2)
   INVADER-X-SPEED)
  (make-missile
   (+ (quotient WIDTH 2) (+ INVADER-WIDTH/2 MISSILE-WIDTH/2))
   (quotient HEIGHT 2)))
 true)
(check-expect
 (missile-hit-invader?
  (make-invader
   (quotient WIDTH 2)
   (quotient HEIGHT 2)
   INVADER-X-SPEED)
  (make-missile
   (+ (quotient WIDTH 2) (+ INVADER-WIDTH/2 MISSILE-WIDTH/2 1))
   (quotient HEIGHT 2)))
 false)
(check-expect
 (missile-hit-invader?
  (make-invader
   (quotient WIDTH 2)
   (quotient HEIGHT 2)
   INVADER-X-SPEED)
  (make-missile
   (quotient WIDTH 2)
   (- (quotient HEIGHT 2) (+ INVADER-HEIGHT/2 MISSILE-HEIGHT/2 1))))
 false)
(check-expect
 (missile-hit-invader?
  (make-invader
   (quotient WIDTH 2)
   (quotient HEIGHT 2)
   INVADER-X-SPEED)
  (make-missile
   (quotient WIDTH 2)
   (- (quotient HEIGHT 2) (+ INVADER-HEIGHT/2 MISSILE-HEIGHT/2))))
 true)
(check-expect
 (missile-hit-invader?
  (make-invader
   (quotient WIDTH 2)
   (quotient HEIGHT 2)
   INVADER-X-SPEED)
  (make-missile
   (quotient WIDTH 2)
   (+ (quotient HEIGHT 2) (+ INVADER-HEIGHT/2 MISSILE-HEIGHT/2))))
 true)
(check-expect
 (missile-hit-invader?
  (make-invader
   (quotient WIDTH 2)
   (quotient HEIGHT 2)
   INVADER-X-SPEED)
  (make-missile
   (quotient WIDTH 2)
   (+ (quotient HEIGHT 2) (+ INVADER-HEIGHT/2 MISSILE-HEIGHT/2 1))))
 false)

(define (missile-hit-invader? i m)
  (and
   (<= (abs (- (missile-x m) (invader-x i))) (+ INVADER-WIDTH/2 MISSILE-WIDTH/2))
   (<= (abs (- (missile-y m) (invader-y i))) (+ INVADER-HEIGHT/2 MISSILE-HEIGHT/2))))

;; <use template for Invader with additional parameter type Missile>


;; ListOfMissile -> ListOfMissile
;; remove Missile in ListOfMissile that are near the top border, i.e,:
;;    - (>= (missile-y Missile) MISSILE-HEIGHT/2)

;(define (filter-out-missiles lom) empty)  ;stub

(check-expect (filter-out-missiles empty) empty)
(check-expect (filter-out-missiles
               (list
                (make-missile (quotient WIDTH 2) (quotient HEIGHT 2))
                (make-missile (quotient WIDTH 2) MISSILE-HEIGHT/2)))
              (list
               (make-missile (quotient WIDTH 2) (quotient HEIGHT 2))))
(check-expect (filter-out-missiles
               (list
                (make-missile (quotient WIDTH 2) (- MISSILE-HEIGHT/2 1))))
              empty)

(define (filter-out-missiles lom)
  (cond [(empty? lom) empty]
        [(>= MISSILE-HEIGHT/2 (missile-y (first lom)))
         (filter-out-missiles (rest lom))]
        [else (cons (first lom) (filter-out-missiles (rest lom)))]))

;; <use template for ListOfMissile>
  

;; ListOfMissile -> ListOfMissile
;; move all the Missile in ListOfMissile:
;;    - (missile-y Missile) -> (+ (missile-y Missile) MISSILE-SPEED)
;;    - (missile-x Missile) -> (missile-x Missile) (constant)

(check-expect (move-missiles empty) empty)
(check-expect (move-missiles
               (list
                (make-missile (quotient WIDTH 2) (quotient HEIGHT 2))
                (make-missile (quotient WIDTH 4) (quotient HEIGHT 4))))
              (list 
               (make-missile
                (quotient WIDTH 2)
                (- (quotient HEIGHT 2)  MISSILE-SPEED))
               (make-missile
                (quotient WIDTH 4) 
                (- (quotient HEIGHT 4) MISSILE-SPEED))))

(define (move-missiles lom)
  (cond [(empty? lom) empty]
          [else
           (cons
            (make-missile
             (missile-x (first lom))
             (- (missile-y (first lom)) MISSILE-SPEED)) 
            (move-missiles (rest lom)))]))

;; <use template for ListOfMissile>


;; ListOfInvader -> ListOfInvader
;; generates an invader at the following
;; coordinates:
;;    - x: (+ (random (- WIDTH INVADER-WIDTH)) INVADER-WIDTH/2)
;;    - y: (- INVADER-HEIGHT/2)

;(define (spawn-invader loi) empty)  ;stub

(check-expect
 (spawn-invader
  (list
   (make-invader
   (quotient WIDTH 2)
   (- INVADER-HEIGHT/2)
   INVADER-X-SPEED)))
 (list
  (make-invader
   (quotient WIDTH 2)
   (- INVADER-HEIGHT/2)
   INVADER-X-SPEED)))

(check-random
 (spawn-invader
  (list
   (make-invader
    (quotient WIDTH 4)
    (+ INVADE-RATE 1)
    INVADER-X-SPEED)))
  (list
   (make-invader
    (+ (random (- WIDTH INVADER-WIDTH)) INVADER-WIDTH/2)
    (- INVADER-HEIGHT/2)
    (- INVADER-X-SPEED))
   (make-invader
    (quotient WIDTH 4)
    (+ INVADE-RATE 1)
    INVADER-X-SPEED)))

(define (spawn-invader loi)
  (cond [(empty? loi)
         (cons
          (make-invader
          (+ (random (- WIDTH INVADER-WIDTH)) INVADER-WIDTH/2)
          (- INVADER-HEIGHT/2)
          INVADER-X-SPEED)
          loi)]
        [(>= (invader-y (first loi)) INVADE-RATE)
         (cons
          (make-invader
          (+ (random (- WIDTH INVADER-WIDTH)) INVADER-WIDTH/2)
          (- INVADER-HEIGHT/2)
          (- (invader-dx (first loi))))
          loi)]
        [else loi]))

;; Game -> Image
;; render all the elements in the game

;(define (render-game g) (make-game empty empty (make-tank 0 1)))  ;stub

(check-expect
 (render-game
  (make-game
   (list
    (make-invader (quotient WIDTH 4) (quotient HEIGHT 4) INVADER-X-SPEED) 
    (make-invader (quotient WIDTH 5) (quotient HEIGHT 5) (- INVADER-X-SPEED)))
   (list
    (make-missile (quotient WIDTH 2) (quotient HEIGHT 2))
    (make-missile (quotient WIDTH 4) (quotient HEIGHT 2)))
   (make-tank (quotient WIDTH 2) 1)))
 (place-image
  INVADER (quotient WIDTH 4) (quotient HEIGHT 4)
  (place-image
   INVADER (quotient WIDTH 5) (quotient HEIGHT 5) 
   (place-image
    MISSILE (quotient WIDTH 2) (quotient HEIGHT 2)
    (place-image
     MISSILE (quotient WIDTH 4) (quotient HEIGHT 2)
     (place-image
      TANK (quotient WIDTH 2) (- HEIGHT TANK-HEIGHT/2) BCKG))))))
 
(define (render-game g)
  (render-missiles
   (game-missiles g)
   (render-invaders (game-invaders g)
                    (render-tank (game-tank g) BCKG))))

;; <use function compostion>


;; ListOfMissile Image -> Image
;; place all Missile in ListOfMissile into Image

;(define (render-missiles lom i) empty-image)  ;stub

(check-expect (render-missiles empty BCKG) BCKG)
(check-expect
 (render-missiles
  (list
    (make-missile (quotient WIDTH 2) (quotient HEIGHT 2))
    (make-missile (quotient WIDTH 4) (quotient HEIGHT 2)))
  BCKG)
 (place-image
    MISSILE (quotient WIDTH 2) (quotient HEIGHT 2)
    (place-image
     MISSILE (quotient WIDTH 4) (quotient HEIGHT 2)
     BCKG)))


(define (render-missiles lom i)
  (cond [(empty? lom) i]
        [else (place-image
               MISSILE
               (missile-x (first lom))
               (missile-y (first lom))
               (render-missiles (rest lom) i))]))

;; <use template for ListOfMissile with addtional parameter of type Image>


;; ListOfInvader Image -> Image
;; place all Invader in ListOfInvader into Image

;(define (render-invaders loi i) empty-image)  ;stub

(check-expect (render-invaders empty BCKG) BCKG)
(check-expect
 (render-invaders
  (list
    (make-invader (quotient WIDTH 2) (quotient HEIGHT 2) INVADER-X-SPEED)
    (make-invader (quotient WIDTH 4) (quotient HEIGHT 2) (- INVADER-X-SPEED)))
  BCKG)
 (place-image
    INVADER (quotient WIDTH 2) (quotient HEIGHT 2)
    (place-image
     INVADER (quotient WIDTH 4) (quotient HEIGHT 2)
     BCKG)))

(define (render-invaders loi i)
  (cond [(empty? loi) i]
        [else (place-image
               INVADER
               (invader-x (first loi))
               (invader-y (first loi))
               (render-invaders (rest loi) i))]))

;; <use template for ListOfInvader with addtional parameter of type Image>


;; Tank Image -> Image
;; place Tank into Image at:
;;    - x coordinate: (tank-x Tank)
;;    - y coordinate: (- HEIGHT TANK-HEIGHT/2)

;(define (render-tank t i) empty-image)  ;stub

(check-expect
 (render-tank
  (make-tank (quotient WIDTH 2) 1)
  BCKG)
 (place-image
  TANK
  (quotient WIDTH 2)
  (- HEIGHT TANK-HEIGHT/2)
  BCKG))

(define (render-tank t i)
  (place-image
   TANK
   (tank-x t)
   (- HEIGHT TANK-HEIGHT/2)
   i))


;; Game KeyEvent -> Game
;; There are three cases:
;;     - KeyEvent is "left", then the dir of (game-tank Game) is set to (- 1)
;;     - KeyEvent is "right", then the dir of (game-tank Game) is set to 1
;;     - KeyEvent is " ", then the (game-tank Game) shoots a Missile

;(define (handle-keys g ke) (make-game empty empty (make-tank 0 1)))  ;stub

(check-expect
 (handle-keys
  (make-game empty empty (make-tank (quotient WIDTH 2) 1))
  "left")
 (make-game empty empty (make-tank (quotient WIDTH 2) (- 1))))
(check-expect
 (handle-keys
  (make-game empty empty (make-tank (quotient WIDTH 2) (- 1)))
  "left")
 (make-game empty empty (make-tank (quotient WIDTH 2) (- 1))))
(check-expect
 (handle-keys
  (make-game empty empty (make-tank (quotient WIDTH 2) (- 1)))
  "right")
 (make-game empty empty (make-tank (quotient WIDTH 2) 1)))
(check-expect
 (handle-keys
  (make-game empty empty (make-tank (quotient WIDTH 2) 1))
  "right")
 (make-game empty empty (make-tank (quotient WIDTH 2) 1)))
(check-expect
 (handle-keys
  (make-game
   empty
   (list
    (make-missile (quotient WIDTH 4) (quotient HEIGHT 4)))
   (make-tank (quotient WIDTH 2) 1))
  " ")
 (make-game
   empty
   (list
    (make-missile (quotient WIDTH 2) (- HEIGHT ( + MISSILE-HEIGHT/2 TANK-HEIGHT)))
    (make-missile (quotient WIDTH 4) (quotient HEIGHT 4)))
   (make-tank (quotient WIDTH 2) 1)))
(check-expect
 (handle-keys
  (make-game
   empty
   empty
   (make-tank (quotient WIDTH 2) 1))
  "a")
 (make-game
   empty
   empty
   (make-tank (quotient WIDTH 2) 1)))

(define (handle-keys g ke)
  (cond [(key=? ke " ")
         (make-game
          (game-invaders g)
          (cons
           (make-missile
            (tank-x (game-tank g))
            (- HEIGHT ( + MISSILE-HEIGHT/2 TANK-HEIGHT)))
           (game-missiles g))
          (game-tank g))]
        [(key=? ke "right")
         (make-game
          (game-invaders g)
          (game-missiles g)
          (make-tank (tank-x (game-tank g)) 1))]
        [(key=? ke "left")
         (make-game
          (game-invaders g)
          (game-missiles g)
          (make-tank (tank-x (game-tank g)) (- 1)))]
        [else g]))

;; <use template for Key handler>


;; Game -> Boolean
;; returns true if any Invader in (game-invaders Game)
;; is in one of the following two locations:
;;    - x: Any, y: (- HEIGHT INVADER-HEIGHT/2) or more (touching the bottom of the scene) 
;;    - x: (tank-x (game-tank Tank)), y: (- HEIGHT (+ TANK-HEIGHT MISSILE-HEIGHT/2)) or more (touching the Tank)
;; Otherwise returns false

;(define (game-over? g) false)  ;stub

(check-expect
 (game-over?
  (make-game
   (list
    (make-invader (quotient WIDTH 4) (quotient HEIGHT 4) INVADER-X-SPEED)
    (make-invader (quotient WIDTH 2) (- HEIGHT INVADER-HEIGHT/2) (- INVADER-X-SPEED)))
   empty
   (make-tank (quotient WIDTH 2) 1)))
  true)
(check-expect
 (game-over?
  (make-game
   (list
    (make-invader (quotient WIDTH 4) (quotient HEIGHT 4) INVADER-X-SPEED)
    (make-invader (quotient WIDTH 2) (- HEIGHT (+ TANK-HEIGHT MISSILE-HEIGHT/2)) (- INVADER-X-SPEED)))
   empty
   (make-tank (quotient WIDTH 2) 1)))
  true)
(check-expect
 (game-over?
  (make-game
   (list
    (make-invader (quotient WIDTH 2) (quotient HEIGHT 2) INVADER-X-SPEED)
    (make-invader (quotient WIDTH 4)  (- (- HEIGHT (+ TANK-HEIGHT MISSILE-HEIGHT/2)) 1) (- INVADER-X-SPEED)))
   empty
   (make-tank (quotient WIDTH 2) 1)))
  false)
(check-expect
 (game-over?
  (make-game
   (list
    (make-invader (quotient WIDTH 2) (quotient HEIGHT 2) INVADER-X-SPEED)
    (make-invader (quotient WIDTH 4)  (- (- HEIGHT INVADER-HEIGHT/2) 1) (- INVADER-X-SPEED)))
   empty
   (make-tank (quotient WIDTH 2) 1)))
  false)

(define (game-over? g)
  (cond [(any-invader-bottom? (game-invaders g)) true]
        [(any-invader-tank? (game-invaders g) (tank-x (game-tank g))) true]
        [else false]))


;; ListOfInvader -> Bolean
;; returns true if and invader is at:
;;    x: Any
;;    y: (- HEIGHT INVADER-HEIGHT/2) or more
;; I.e., touching the bottom of the scene

;(define (any-invader-bottom? loi) false)  ;stub

(check-expect (any-invader-bottom? empty) false)
(check-expect
 (any-invader-bottom?
  (list
    (make-invader (quotient WIDTH 4) (quotient HEIGHT 4) INVADER-X-SPEED)
    (make-invader (quotient WIDTH 2) (- HEIGHT INVADER-HEIGHT/2) (- INVADER-X-SPEED))))
 true)
(check-expect
 (any-invader-bottom?
  (list
    (make-invader (quotient WIDTH 4) (quotient HEIGHT 4) INVADER-X-SPEED)
    (make-invader (quotient WIDTH 2) (+ (- HEIGHT INVADER-HEIGHT/2) 1) (- INVADER-X-SPEED))))
 true)
(check-expect
 (any-invader-bottom?
  (list
    (make-invader (quotient WIDTH 4) (quotient HEIGHT 4) INVADER-X-SPEED)
    (make-invader (quotient WIDTH 2) (- (- HEIGHT INVADER-HEIGHT/2) 1) (- INVADER-X-SPEED))))
 false)

(define (any-invader-bottom? loi)
  (cond [(empty? loi) false]
        [(>= (invader-y (first loi)) (- HEIGHT INVADER-HEIGHT/2)) true]
        [else (any-invader-bottom? (rest loi))]))


;; ListOfInvader Integer -> Bolean
;; returns true if and invader is at:
;;    x: Integer
;;    y: (- HEIGHT (+ TANK-HEIGHT MISSILE-HEIGHT/2)) or more
;; I.e., touching the Tank at Integer  

;(define (any-invader-tank? loi x) false)  ;stub

(check-expect (any-invader-tank? empty 0) false)
(check-expect
 (any-invader-tank?
  (list
    (make-invader (quotient WIDTH 4) (quotient HEIGHT 4) INVADER-X-SPEED)
    (make-invader (quotient WIDTH 2) (- HEIGHT (+ TANK-HEIGHT INVADER-HEIGHT/2)) (- INVADER-X-SPEED)))
  (quotient WIDTH 2))
 true)
(check-expect
 (any-invader-tank?
  (list
    (make-invader (quotient WIDTH 4) (quotient HEIGHT 4) INVADER-X-SPEED)
    (make-invader (quotient WIDTH 2) (- HEIGHT (+ TANK-HEIGHT INVADER-HEIGHT/2)) (- INVADER-X-SPEED)))
  (quotient WIDTH 4))
 false)
(check-expect
 (any-invader-tank?
  (list
    (make-invader (quotient WIDTH 4) (quotient HEIGHT 4) INVADER-X-SPEED)
    (make-invader (quotient WIDTH 2) (+ (- HEIGHT (+ TANK-HEIGHT MISSILE-HEIGHT/2)) 1) (- INVADER-X-SPEED)))
  (quotient WIDTH 2))
 true)
(check-expect
 (any-invader-tank?
  (list
    (make-invader (quotient WIDTH 4) (quotient HEIGHT 4) INVADER-X-SPEED)
    (make-invader (quotient WIDTH 2) (+ (- HEIGHT (+ TANK-HEIGHT MISSILE-HEIGHT/2)) 1) (- INVADER-X-SPEED)))
  (quotient WIDTH 5))
 false)
(check-expect
 (any-invader-tank?
  (list
    (make-invader (quotient WIDTH 4) (quotient HEIGHT 4) INVADER-X-SPEED)
    (make-invader (quotient WIDTH 2) (- (- HEIGHT (+ TANK-HEIGHT INVADER-HEIGHT/2)) 1) (- INVADER-X-SPEED)))
  (quotient WIDTH 2))
 false)
(check-expect
 (any-invader-tank?
  (list
    (make-invader (quotient WIDTH 4) (quotient HEIGHT 4) INVADER-X-SPEED)
    (make-invader (quotient WIDTH 2) (- (- HEIGHT (+ TANK-HEIGHT INVADER-HEIGHT/2)) 1) (- INVADER-X-SPEED)))
  (quotient WIDTH 5))
 false)

(define (any-invader-tank? loi x)
  (cond [(empty? loi) false]
        [(and
          (>= (invader-y (first loi)) (- HEIGHT (+ TANK-HEIGHT INVADER-HEIGHT/2)))
          (equal? (invader-x (first loi)) x))
          true]
        [else (any-invader-tank? (rest loi) x)]))

;; <use template for ListOfInvader with additional parameter of type Integer>


;; Game -> Image
;; pops GAME-OVER

;(define (last-picture g) empty-image)  ;stub

(check-expect (last-picture (make-game empty empty (make-tank 0 1))) GAME-OVER)

(define (last-picture g) GAME-OVER)

;; < use template for Game>



(main G0)