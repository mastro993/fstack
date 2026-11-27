from jobs.log import log


def run(payouts, transfer):
    log('info', 'payout run starting')
    total = 0
    for payout in payouts:
        try:
            transfer(payout["account"], payout["cents"])
        except ValueError as error:
            log(
                "error",
                f"payout {payout['id']} rejected: {error}",
            )
            continue
        total += payout["cents"]
    if total == 0:
        log('warn', 'no payouts sent')
    log('info', f'payout run done: {total} cents')
    return total
