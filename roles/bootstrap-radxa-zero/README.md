# bootstrap-radxa-zero

Takes a freshly imaged Radxa Zero from its vendor image to a board that
resolves on the network, reports its address, and syncs a project directory
from the workstation.

Safe to rerun. The same command covers a fresh board and a converged one.

```bash
ansible-playbook ./playbooks/bootstrap-radxa.yml --ask-become-pass
```

`--ask-become-pass` is needed every run; the password is the vendor default.

## The board keeps the vendor account

No user is created. The board runs as `radxa`, the account the image ships,
which is already in the `sudo` group. On a single-purpose board a second
account buys nothing, and the vendor account is the one you can still log into
when mDNS is broken and you are on a serial console.

The role makes exactly one change to how you log in: it authorises
`~/.ssh/id_rsa.pub` from the workstation. That is all.

**Authentication is left exactly as the base image ships it.** The role does
not edit `sshd_config`, does not lock or change any password, does not disable
password authentication or root login, and does not touch sudo — no
`/etc/sudoers.d` drop-in, which is why every run needs `--ask-become-pass`.
The vendor account and root keep their default passwords and stay usable as a
way back in when mDNS breaks or a key goes missing — which is the whole reason
the board stays on the vendor account in the first place.

An earlier revision of this role locked the vendor password (`harden.yml`,
reverted in `a5c3582`) on the false premise that the workstation key was
already in that account's `authorized_keys` — it was not, it was in the primary
user's, so the task removed the last route in. Do not reintroduce it.

`username` is therefore **not** the board's user here. It stays the
workstation's, and the role reads it from localhost's own host_vars
(`bootstrap_radxa_zero_local_user`) so that the mutagen paths under
`/home/roland` cannot drift onto the board's identity. Keep those two apart
when editing this role.

## The board has two names

A board answers to a different name depending on whether it has been
bootstrapped yet:

| state | mDNS name |
| --- | --- |
| freshly imaged | `radxa.local` (vendor default) |
| after this role | `zero.local` (`inventory_hostname`) |

`preflight.yml` tries the inventory name first, falls back to the vendor name,
and pins `ansible_host` to whichever answered before any task touches the
board. It uses `ssh-keyscan` and deliberately does not authenticate — it only
needs the host to resolve and return a banner, which is true in both states.

Two consequences worth knowing before you edit this:

* The play sets `gather_facts: false`. Facts are gathered by the role, at the
  end of preflight. Gathering them at play level would connect to `zero.local`
  and fail on exactly the run that is meant to create that name.
* `inventory_hostname` is never rewritten. The mutagen sync target and every
  later playbook still use `zero.local`.

On the run that renames the board, avahi is restarted so the new name is on the
wire, and the mutagen ssh check retries
(`bootstrap_radxa_zero_ssh_retries` × `bootstrap_radxa_zero_ssh_delay`) to give
the workstation's resolver time to catch up.

## What it installs

**avahi** — so `zero.local` resolves on the LAN without a DHCP reservation.

**alsa-utils** — `aplay`, `amixer` and `speaker-test`, so the board's audio can
be driven from the shell. The vendor image ships the kernel drivers; this is
only the userspace tooling on top of them.

**nginx** (`--tags nginx`) — a single site on **port 8080**, so
`http://zero.local:8080` loads once the board has been renamed. Plain http on a
high port is deliberate: the board is LAN-only and has no certificate, so
port 80 buys nothing, and leaving it free keeps the Debian package's own
default site out of the way (that site is disabled anyway, via
`bootstrap_radxa_zero_nginx_disable_default`).

The server block matches `server_name _` rather than the mDNS name, because the
board is also reached by bare IP — from the beacon registry, or on exactly the
occasions when mDNS is the broken thing — and a name-matched block would 404
those.

The webroot is `/var/www/zero`, kept separate from the mutagen sync target
(`~/dev`). They have different owners and different lifetimes, and a sync that
deletes a file should not be able to empty the site. Point
`bootstrap_radxa_zero_nginx_root` at `~/dev` if you do want live-synced
content; the worker runs as `www-data`, so the path has to stay
world-readable. A placeholder `index.html` is written **only while the webroot
is empty**, so a rerun never overwrites a real site.

`nginx -t` runs after the symlinks are in place, so a broken server block fails
as itself rather than surfacing later as a failed reload in a handler.

**ip-beacon client** (`--tags beacon`) — a script, service and timer fetched
from the registry at `bootstrap_radxa_zero_beacon_registry_url`, which report
the board's current address on boot and on a timer. Note this is *not* first
contact: reaching the board over ssh at all already required an address it had
reported, or mDNS. The beacon is what you fall back on when the board moves to
a network where mDNS does not reach you.

The client is always fetched from the running registry and never vendored. A
copy taken from a git clone arrives with `@@BASE_URL@@` unsubstituted; a copy
taken from the registry is correct today and silently stale tomorrow. The role
asserts the URL is `https://` with no leftover placeholder.

**mutagen remote dev** (`--tags remote-dev`) — a two-way-resolved sync between
`~/projects/zero` on the workstation and `~/dev` on the board. The contents of
the local directory land directly in `~/dev`, with no per-project subfolder.

Mutagen runs on the *workstation*, not the board, so this half of the role is
delegated to localhost throughout:

* installs the mutagen binary and its agent bundle into `~/.local/bin`, picking
  the archive from the workstation's architecture rather than the board's
* runs the daemon under a `systemd --user` unit. `mutagen daemon register` no
  longer exists in 0.18 — the subcommand is gone and the binary just prints
  help and exits 0 — so a user unit running the hidden `daemon run` is the
  equivalent. Any stray ad-hoc daemon is stopped first, since it holds a lock
  the unit cannot take.
* creates the sync session if it does not already exist, then flushes it so the
  initial copy completes before the play ends

Mutagen shells out to the `ssh` binary as the workstation user, so ansible's
own connection settings do not apply to it. The key must be loaded and the host
key already accepted, which is what the reachability check ahead of it enforces.

## Variables

The ones worth overriding. See `defaults/main.yml` for the rest.

| variable | default | |
| --- | --- | --- |
| `bootstrap_radxa_zero_board_user` | `radxa` | the account on the board |
| `bootstrap_radxa_zero_hostname` | `zero` | short hostname set on the board |
| `bootstrap_radxa_zero_vendor_hostname` | `radxa.local` | what a fresh board answers to |
| `bootstrap_radxa_zero_pubkey` | `~/.ssh/id_rsa.pub` | key authorised on the board |
| `bootstrap_radxa_zero_project` | `zero` | names both the local dir and the sync session |
| `bootstrap_radxa_zero_nginx_port` | `8080` | port the site listens on |
| `bootstrap_radxa_zero_nginx_root` | `/var/www/zero` | webroot on the board |
| `bootstrap_radxa_zero_beacon_registry_url` | `https://beacon.wirecrop.net` | must be https |
| `bootstrap_radxa_zero_sync_mode` | `two-way-resolved` | mutagen sync mode |

Renaming the board means changing `bootstrap_radxa_zero_hostname`, the
`[radxa]` entry in `inventory/hosts.ini`, and the matching `host_vars` file
together — they are the same name in three places.

## Troubleshooting

**"Cannot reach zero.local or radxa.local on port 22"** — preflight found
nothing, and stopped before changing anything. Check the board is powered and
on the network, that one of the names resolves (`getent hosts zero.local`), and
that the beacon registry agrees with the address you expect.

**`Permission denied (publickey,password)` on "Gather facts about the board"**
— preflight passed, so the board is up and the name resolved; this is purely
authentication. That task is simply the first one in the role that connects to
the board at all, everything before it being delegated to localhost, so it is
where any auth gap surfaces. The board has no key for the vendor account yet:

```bash
ssh-copy-id radxa@zero.local   # vendor default password
```

Then rerun. This is the expected state for a board bootstrapped by an older
revision of this role, which installed the key for the primary user instead.

**The play reaches the board but mutagen cannot** — ansible authenticated and
mutagen could not. Usually an unloaded key or an unaccepted host key under the
new name: `ssh radxa@zero.local` once by hand and accept it.

**`zero.local:8080` does not load** — check in this order: the site is
enabled (`ls /etc/nginx/sites-enabled/`), nginx is up (`systemctl status
nginx`), and it is actually listening (`ss -lntp | grep 8080`). If nginx is
running and listening but the browser hangs, the name is the problem, not the
server — try the board's IP on the same port.

**A second Radxa board** — `radxa.local` collides on mDNS while both are
unbootstrapped. Bootstrap them one at a time, or give the second one a
different `bootstrap_radxa_zero_hostname`.
