(define (domain mars_domain)

    (:requirements :strips :typing)

    (:types
        location locatable - object
        bay rock drill bot - locatable
        rover - bot
        site - location
        soft hard - rock
    )

    (:predicates
        (at ?obj - locatable ?loc - location)
        (drill_picked)
        (empty ?r - rover ?b - bay)
        (is_route ?loc1 - location ?loc2 - location)
        (bay_holding ?r - rover ?b - bay ?rock - rock)
    )

    (:action move
        :parameters (?r - rover ?from - location ?to - location)
        :precondition (and
            (at ?r ?from)
            (is_route ?from ?to)
        )
        :effect (and
            (at ?r ?to)
            (not (at ?r ?from))
        )
    )

    (:action pick-drill
        :parameters (?r - rover ?d - drill ?loc - location)
        :precondition (and
            (at ?r ?loc)
            (at ?d ?loc)
        )
        :effect (and
            (drill_picked)
            (not (at ?d ?loc))
        )
    )

    (:action collect-soft
        :parameters (?r - rover ?rock - soft ?b - bay ?loc - location)
        :precondition (and
            (at ?r ?loc)
            (at ?rock ?loc)
            (empty ?r ?b)
        )
        :effect (and
            (not (at ?rock ?loc))
            (not (empty ?r ?b))
            (bay_holding ?r ?b ?rock)
        )
    )

    (:action collect-hard
        :parameters (?r - rover ?rock - hard ?b - bay ?loc - location)
        :precondition (and
            (at ?r ?loc)
            (at ?rock ?loc)
            (empty ?r ?b)
            (drill_picked)
        )
        :effect (and
            (not (at ?rock ?loc))
            (not (empty ?r ?b))
            (bay_holding ?r ?b ?rock)
        )
    )

    (:action deposit
        :parameters (?r - rover ?b - bay ?rock - rock ?loc - location)
        :precondition (and
            (at ?r ?loc)
            (bay_holding ?r ?b ?rock)
        )
        :effect (and
            (not (bay_holding ?r ?b ?rock))
            (empty ?r ?b)
            (at ?rock ?loc)
        )
    )

)
