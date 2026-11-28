def summarize(entries):
    """Hours per project, largest first, and the total."""
    per_project = {}
    for entry in entries:
        per_project[entry.project] = per_project.get(entry.project, 0) + entry.hours
    rows = sorted(per_project.items(), key=lambda item: (-item[1], item[0]))
    return {"projects": rows, "total": sum(hours for _, hours in rows)}
