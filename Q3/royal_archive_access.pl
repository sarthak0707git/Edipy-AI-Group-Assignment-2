% Problem 3 - Royal Archive Access Verification
% Goal: prove that Mira is trusted using resolution refutation
%
% Group: Edipy
%   Sarthak Shrivastava   B24CS506
%   Potnuru Jagath        B24CS034
%   Vidit Shrimali        B24DS038
%   Prashant Sati         B24CS035
%   Kamalesh Swargam      B24MT011
%
% Run with:  swipl -g run_proof -t halt royal_archive_access.pl
%
% Predicates:
%   archivist(X)              - X is an archivist
%   verifies(X, R)            - X verifies record R
%   trusted(X)                - X is trusted
%   has_access(X, R)          - X has access to record R
%   sealed(R)                 - record R is sealed
%   permitted_to_inspect(X,R) - X is allowed to inspect R
%   inspects(X, R)            - X inspects record R
%   finds_hidden_mark(X, R)   - X finds a hidden mark in R
%   stored_in_archive(R)      - R is stored in the royal archive
%
% Constants: mira, scroll_7
% Variables: X, R (and X1, R1, X2 ... after standardizing)


% Step 1 - predicate logic
% 1. forall X,R: archivist(X) and verifies(X,R) -> trusted(X)
% 2. forall X,R: trusted(X) and has_access(X,R) and sealed(R) -> permitted_to_inspect(X,R)
% 3. forall X,R: inspects(X,R) and finds_hidden_mark(X,R) -> verifies(X,R)
% 4. forall R: stored_in_archive(R) -> sealed(R)
% 5. stored_in_archive(scroll_7)
% 6. has_access(mira, scroll_7)
% 7. inspects(mira, scroll_7) and finds_hidden_mark(mira, scroll_7)
% 8. archivist(mira)

trusted(X) :- archivist(X), verifies(X, _R).
permitted_to_inspect(X, R) :- trusted(X), has_access(X, R), sealed(R).
verifies(X, R) :- inspects(X, R), finds_hidden_mark(X, R).
sealed(R) :- stored_in_archive(R).

stored_in_archive(scroll_7).
has_access(mira, scroll_7).
inspects(mira, scroll_7).
finds_hidden_mark(mira, scroll_7).
archivist(mira).


% Step 2 - negate goal
% goal is trusted(mira), so we add not trusted(mira)
negated_goal([not(trusted(mira))]).


% Step 3 - implication removal
% A -> B becomes not A or B
remove_implications(
    implies(and(archivist(X), verifies(X, R)), trusted(X)),
    or(not(and(archivist(X), verifies(X, R))), trusted(X))
).

remove_implications(
    implies(and(trusted(X), and(has_access(X, R), sealed(R))), permitted_to_inspect(X, R)),
    or(not(and(trusted(X), and(has_access(X, R), sealed(R)))), permitted_to_inspect(X, R))
).

remove_implications(
    implies(and(inspects(X, R), finds_hidden_mark(X, R)), verifies(X, R)),
    or(not(and(inspects(X, R), finds_hidden_mark(X, R))), verifies(X, R))
).

remove_implications(
    implies(stored_in_archive(R), sealed(R)),
    or(not(stored_in_archive(R)), sealed(R))
).


% Step 4 - move negation inward
% not (A and B) becomes not A or not B
neg_inward(1, [not(archivist(X)), not(verifies(X, _R)), trusted(X)]).
neg_inward(2, [not(trusted(X)), not(has_access(X, R)), not(sealed(R)), permitted_to_inspect(X, R)]).
neg_inward(3, [not(inspects(X, R)), not(finds_hidden_mark(X, R)), verifies(X, R)]).
neg_inward(4, [not(stored_in_archive(R)), sealed(R)]).


% Step 5 - standardising
% every rule gets its own variable names
stded(1, [not(archivist(X1)), not(verifies(X1, _R1)), trusted(X1)]).
stded(2, [not(trusted(X2)), not(has_access(X2, R2)), not(sealed(R2)), permitted_to_inspect(X2, R2)]).
stded(3, [not(inspects(X3, R3)), not(finds_hidden_mark(X3, R3)), verifies(X3, R3)]).
stded(4, [not(stored_in_archive(R4)), sealed(R4)]).


% Step 6 - skolemization
% there is no "there exists", only "for all", so nothing to do
skolemization(none).


% Step 7 - CNF
cnf(1, [not(archivist(X1)), not(verifies(X1, _R1)), trusted(X1)]).
cnf(2, [not(trusted(X2)), not(has_access(X2, R2)), not(sealed(R2)), permitted_to_inspect(X2, R2)]).
cnf(3, [not(inspects(X3, R3)), not(finds_hidden_mark(X3, R3)), verifies(X3, R3)]).
cnf(4, [not(stored_in_archive(R4)), sealed(R4)]).
cnf(5, [stored_in_archive(scroll_7)]).
cnf(6, [has_access(mira, scroll_7)]).
cnf(7, [inspects(mira, scroll_7)]).
cnf(8, [finds_hidden_mark(mira, scroll_7)]).
cnf(9, [archivist(mira)]).
cnf(10, [not(trusted(mira))]).


% Step 8 - Resolution
opp(P, not(P)).
opp(not(P), P).

resolve(A, B, R) :-
    select(X, A, A1),
    select(Y, B, B1),
    opp(X, Y),
    append(A1, B1, C),
    sort(C, R).

run_proof :-
    cnf(1, C1),
    cnf(2, C2),
    cnf(3, C3),
    cnf(4, C4),
    cnf(5, C5),
    cnf(6, C6),
    cnf(7, C7),
    cnf(8, C8),
    cnf(9, C9),
    cnf(10, C10),

    write('C1 = '), write(C1), nl,
    write('C2 = '), write(C2), nl,
    write('C3 = '), write(C3), nl,
    write('C4 = '), write(C4), nl,
    write('C5 = '), write(C5), nl,
    write('C6 = '), write(C6), nl,
    write('C7 = '), write(C7), nl,
    write('C8 = '), write(C8), nl,
    write('C9 = '), write(C9), nl,
    write('C10 = '), write(C10), nl, nl,

    % C2, C4, C5, C6 are not needed for this proof

    % not trusted(mira) with rule 1
    resolve(C10, C1, R1),
    write('Step 1 (C10 + C1): '), write(R1), nl,

    % mira is an archivist
    resolve(R1, C9, R2),
    write('Step 2 (R1 + C9): '), write(R2), nl,

    % verifies comes from rule 3
    resolve(R2, C3, R3),
    write('Step 3 (R2 + C3): '), write(R3), nl,

    % mira inspects scroll_7
    resolve(R3, C7, R4),
    write('Step 4 (R3 + C7): '), write(R4), nl,

    % mira finds a hidden mark in scroll_7
    resolve(R4, C8, R5),
    write('Step 5 (R4 + C8): '), write(R5), nl,

    R5 = [],
    write('Empty clause derived.'), nl,
    write('Mira is trusted.'), nl.
