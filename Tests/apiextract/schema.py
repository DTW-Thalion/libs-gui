"""The one document shape shared by both baselines and every later stage."""
import json
from datetime import date

BASELINES = ("openstep", "apple")
KINDS = ("class", "instance")


def validate_reference(doc):
    problems = []
    if doc.get("baseline") not in BASELINES:
        problems.append(f"baseline must be one of {BASELINES}")
    for key in ("source", "generated"):
        if not doc.get(key):
            problems.append(f"missing {key}")
    classes = doc.get("classes")
    if not isinstance(classes, dict):
        return problems + ["classes must be an object"]
    for name, entry in classes.items():
        methods = entry.get("methods")
        if not isinstance(methods, list):
            problems.append(f"{name}: methods must be a list")
            continue
        for m in methods:
            if not m.get("selector"):
                problems.append(f"{name}: empty selector")
            if m.get("kind") not in KINDS:
                problems.append(f"{name}.{m.get('selector')}: kind must be one of {KINDS}")
            for key in ("introduced", "deprecated", "origin"):
                if key not in m:
                    problems.append(f"{name}.{m.get('selector')}: missing {key}")
    return problems


def save_reference(path, baseline, source, classes):
    doc = {
        "baseline": baseline,
        "source": source,
        "generated": date.today().isoformat(),
        "classes": classes,
    }
    problems = validate_reference(doc)
    if problems:
        raise ValueError(f"refusing to save an invalid reference: {problems[:5]}")
    with open(path, "w") as f:
        json.dump(doc, f, indent=1, sort_keys=True)


def load_reference(path):
    with open(path) as f:
        return json.load(f)
