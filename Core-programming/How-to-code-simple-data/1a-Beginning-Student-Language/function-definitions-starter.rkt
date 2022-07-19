;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname function-definitions-starter) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)

;; function-definitions-starter.rkt

(above (circle 40 "solid" "red")         
       (circle 40 "solid" "yellow")
       (circle 40 "solid" "green"))

;; define a function with the changing parts as parameters
(define (forty-solid-circle color)
  (circle 40 "solid" color))

;; rewrite code
(above (forty-solid-circle "red")         
       (forty-solid-circle "yellow")
       (forty-solid-circle "green"))