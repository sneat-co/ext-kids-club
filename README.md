# kids-club-contract

Public **contract surface** for the `kidsclub` extension, following the
[`<id>-contract` repo-naming convention](https://github.com/sneat-co/sneat-specs/blob/main/standards/repo-naming.md).

It holds the **frozen wire shapes** other repos need in order to *talk to*
Kids Club — the TypeSpec source of truth and the matching Go DTOs. It
contains **no** Kids Club implementation; that lives in
[`sneat-co/kids-club`](https://github.com/sneat-co/kids-club).

## Layout

```
kids-club-contract/
├── typespec/           # api4kidsclub.tsp — source of truth for the wire shape
└── backend/            # Go module github.com/sneat-co/kids-club-contract/backend
    └── dto4kidsclub/   # package dto4kidsclub — the frozen request/response DTOs
```

No emitters are configured — the `.tsp` file and the Go package are
hand-kept in sync (same convention as `eventius/typespec` and the
`sneat-go/typespec` directory).

## Discovery

Tagged `sneat-extension-contract` — see all contract repos at
[`github.com/sneat-co?q=topic:sneat-extension-contract`](https://github.com/orgs/sneat-co/repositories?q=topic%3Asneat-extension-contract).

## Status

Prototype scaffold — DTOs cover the four v1 endpoints (create club, public
club read, submit registration, operator roster read). See backstage
`docs/superpowers/specs/2026-07-02-kids-club-prototype-design.md`.
