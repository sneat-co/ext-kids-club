# ext-kids-club

Public **extension-definition repo** for the `kidsclub` extension, following the
[`ext-<id>` repo-naming convention](https://github.com/sneat-co/sneat-specs/blob/main/standards/repo-naming.md).

It holds the **frozen wire shapes** other repos need in order to *talk to*
Kids Club — the TypeSpec source of truth and the matching Go DTOs. It
contains **no** Kids Club implementation; that lives in
[`sneat-co/kids-club`](https://github.com/sneat-co/kids-club).

## Layout

```
ext-kids-club/
├── typespec/           # api4kidsclub.tsp — source of truth for the wire shape
└── backend/            # Go module github.com/sneat-co/ext-kids-club/backend
    └── dto4kidsclub/   # package dto4kidsclub — the frozen request/response DTOs
└── frontend/           # Nx-built @sneat/extension-kidsclub-contract package
```

No emitters are configured — the `.tsp` file and the Go package are
hand-kept in sync (same convention as `eventius/typespec` and the
`sneat-go/typespec` directory).

## Discovery

Tagged `sneat-extension-definition` (with legacy `sneat-extension-contract`
during migration) — see all extension-definition repos at
[`github.com/sneat-co?q=topic:sneat-extension-definition`](https://github.com/orgs/sneat-co/repositories?q=topic%3Asneat-extension-definition).

## Status

Prototype scaffold — DTOs cover the four v1 endpoints (create club, public
club read, submit registration, operator roster read). See backstage
`docs/superpowers/specs/2026-07-02-kids-club-prototype-design.md`.
