from jobs import log


def run(contacts, crm):
    log.log("info", f"syncing {len(contacts)} contacts")
    created = updated = 0
    for contact in contacts:
        existing = crm.find(contact["email"])
        if existing is None:
            crm.create(contact)
            created += 1
        elif existing != contact:
            crm.update(contact)
            updated += 1
    log.log("info", f"crm sync done: {created} created, {updated} updated")
    if created + updated == 0:
        log.log("debug", "crm already up to date")
    return created, updated
