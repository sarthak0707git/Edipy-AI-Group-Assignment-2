(define (problem mars_problem)
    (:domain mars_domain)
    (:objects
        rover - rover
        drill1 - drill
        rock1 rock2 rock4 - soft
        rock3 rock5 - hard
        bay1 bay2 - bay
        base siteA siteB siteC siteD siteE siteF - location
    )

    (:init
        (at rover base)
        (at drill1 siteE)
        (at rock1 siteA)
        (at rock2 siteB)
        (at rock3 siteC)
        (at rock4 siteD)
        (at rock5 siteF)
        (empty rover bay1)
        (empty rover bay2)

        (is_route base siteA)
        (is_route siteA base)
        (is_route base siteB)
        (is_route siteB base)
        (is_route siteA siteC)
        (is_route siteC siteA)
        (is_route siteB siteD)
        (is_route siteD siteB)
        (is_route siteC siteE)
        (is_route siteE siteC)
        (is_route siteD siteE)
        (is_route siteE siteD)
        (is_route siteE siteF)
        (is_route siteF siteE)
        (is_route siteC siteD)
    )

    (:goal
        (and
            (at rock1 base)
            (at rock2 base)
            (at rock3 base)
            (at rock4 base)
            (at rock5 base)
            (at rover base)
            (empty rover bay1)
            (empty rover bay2)
        )
    )
)
