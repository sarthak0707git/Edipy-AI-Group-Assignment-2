# AI (CSL304) - Group Assignment 2

**Group: Edipy**

| Name | Roll No |
|---|---|
| Sarthak Shrivastava | B24CS506 |
| Potnuru Jagath | B24CS034 |
| Vidit Shrimali | B24DS038 |
| Prashant Sati | B24CS035 |
| Kamalesh Swargam | B24MT011 |

## Contents

### Q1 - Smart Home Energy Consumption (Bayesian Networks)
- `smart_home_energy.ipynb` - Parts A to E, run top to bottom
- `bn.py` - network structure, CPTs and helper functions
- `network.png`, `error_vs_size.png` - generated figures
- `screenshots/` - outputs for each part, numbered in order

Needs `pgmpy` 1.1 or newer (uses `pgmpy.parameter_estimator`), plus `networkx`,
`pandas` and `matplotlib`.

### Q2 - Mars Rover Sample Collection (PDDL)
- `Domain.pddl`, `Problem.pddl`, `Problem_extended.pddl`
- `gbfs-normal.txt`, `a-star-normal.txt`, `gbfs-extended.txt`, `a-star-extended.txt` - planner output
- `Report.pdf` - plans, search statistics and the plan analysis

Planner: Fast Downward. Satisficing run uses greedy best-first search with FF;
optimal run uses A* with LM-cut.

### Q3 - Royal Archive Access (Resolution Refutation)
- `royal_archive_access.pl` - Steps 1 to 8, from predicate logic through to resolution
- `proof_output.png` - screenshot of the derivation of the empty clause

Run with:

    swipl -g run_proof -t halt royal_archive_access.pl
