"""Smart home energy Bayesian network - shared model definition.

Group: Edipy
    Sarthak Shrivastava   B24CS506
    Potnuru Jagath        B24CS034
    Vidit Shrimali        B24DS038
    Prashant Sati         B24CS035
    Kamalesh Swargam      B24MT011

Everything the notebook needs about the expert network lives here: the state
spaces, the graph structure, the CPTs from the assignment, and small helpers
for building the pgmpy model and reading probabilities out of it.
"""

from itertools import product

import pandas as pd
from pgmpy.factors.discrete import TabularCPD
from pgmpy.inference import VariableElimination
from pgmpy.models import DiscreteBayesianNetwork

STATES = {
    "Weather": ["Hot", "Mild", "Cold"],
    "DayType": ["Weekday", "Weekend"],
    "Occupancy": ["High", "Low"],
    "AC": ["On", "Off"],
    "Load": ["Heavy", "Light"],
    "Energy": ["High", "Low"],
}

PARENTS = {
    "Weather": [],
    "DayType": [],
    "Occupancy": ["DayType"],
    "AC": ["Weather", "Occupancy"],
    "Load": ["Occupancy"],
    "Energy": ["AC", "Load"],
}

# topological order, used for sampling and for the joint factorisation
ORDER = ["Weather", "DayType", "Occupancy", "AC", "Load", "Energy"]


def binary(p, yes, no):
    """The assignment lists one probability per row for the binary nodes."""
    return {yes: p, no: 1 - p}


CPT = {
    "Weather": {(): {"Hot": 0.5, "Mild": 0.3, "Cold": 0.2}},
    "DayType": {(): {"Weekday": 0.7, "Weekend": 0.3}},
    "Occupancy": {
        ("Weekday",): binary(0.45, "High", "Low"),
        ("Weekend",): binary(0.80, "High", "Low"),
    },
    "AC": {
        ("Hot", "High"): binary(0.90, "On", "Off"),
        ("Hot", "Low"): binary(0.60, "On", "Off"),
        ("Mild", "High"): binary(0.40, "On", "Off"),
        ("Mild", "Low"): binary(0.15, "On", "Off"),
        ("Cold", "High"): binary(0.10, "On", "Off"),
        ("Cold", "Low"): binary(0.05, "On", "Off"),
    },
    "Load": {
        ("High",): binary(0.75, "Heavy", "Light"),
        ("Low",): binary(0.35, "Heavy", "Light"),
    },
    "Energy": {
        ("On", "Heavy"): binary(0.92, "High", "Low"),
        ("On", "Light"): binary(0.68, "High", "Low"),
        ("Off", "Heavy"): binary(0.55, "High", "Low"),
        ("Off", "Light"): binary(0.12, "High", "Low"),
    },
}

QUERIES = {
    "Q1": ("Energy", "High", {}),
    "Q2": ("Energy", "High", {"Weather": "Hot"}),
    "Q3": ("Energy", "High", {"DayType": "Weekend"}),
    "Q4": ("Energy", "High", {"Weather": "Cold", "Occupancy": "High"}),
    "Q5": ("Weather", "Hot", {"Energy": "High"}),
    "Q6": ("AC", "On", {"Energy": "High"}),
    "Q7": ("AC", "On", {"Energy": "High", "Load": "Heavy"}),
}

LABELS = {
    "Q1": "P(E=High)",
    "Q2": "P(E=High | W=Hot)",
    "Q3": "P(E=High | D=Weekend)",
    "Q4": "P(E=High | W=Cold, O=High)",
    "Q5": "P(W=Hot | E=High)",
    "Q6": "P(AC=On | E=High)",
    "Q7": "P(AC=On | E=High, L=Heavy)",
}

EDGES = [(parent, child) for child in ORDER for parent in PARENTS[child]]


def make_cpd(var):
    """Turn one entry of CPT into the TabularCPD that pgmpy wants."""
    parents = PARENTS[var]
    configs = list(product(*[STATES[p] for p in parents]))
    rows = [[CPT[var][cfg][state] for cfg in configs] for state in STATES[var]]
    return TabularCPD(
        var,
        len(STATES[var]),
        rows,
        evidence=parents or None,
        evidence_card=[len(STATES[p]) for p in parents] or None,
        state_names={v: STATES[v] for v in [var] + parents},
    )


def build_expert_model():
    model = DiscreteBayesianNetwork(EDGES)
    model.add_cpds(*[make_cpd(var) for var in ORDER])
    return model


def prob(infer, var, state, evidence):
    """P(var = state | evidence) by variable elimination."""
    factor = infer.query([var], evidence=evidence or None, show_progress=False)
    return float(factor.get_value(**{var: state}))


def run_queries(model):
    infer = VariableElimination(model)
    return {name: prob(infer, *QUERIES[name]) for name in QUERIES}


def cpd_frame(cpd):
    """A readable table for a CPD, with columns in the assignment's order.

    Parent values are looked up by name rather than by position, so this works
    unchanged on the CPTs learned from data (pgmpy may order their parents
    differently from PARENTS).
    """
    var = cpd.variable
    parents = PARENTS[var]
    if not parents:
        frame = pd.DataFrame(cpd.get_values(), index=STATES[var], columns=["P"])
    else:
        configs = list(product(*[STATES[p] for p in parents]))
        rows = [
            [cpd.get_value(**{var: state, **dict(zip(parents, cfg))}) for cfg in configs]
            for state in STATES[var]
        ]
        frame = pd.DataFrame(
            rows, index=STATES[var], columns=[", ".join(cfg) for cfg in configs]
        )
        frame.columns.name = ", ".join(parents)
    frame.index.name = var
    return frame.round(4)
