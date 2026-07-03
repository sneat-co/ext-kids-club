import "@typespec/http";

using Http;

/**
 * Kids Club HTTP/JSON API.
 *
 * Kids Club is a prototype Sneat extension: an event operator opens a
 * drop-in kids club for an occasion (venue + a v1 waiver text), publishes a
 * public club page, and parents register their children against it. The
 * operator then reviews a roster of registrations for the club.
 *
 * This is the **frozen wire contract** between the Go backend
 * (`kids-club/backend`) and the frontend — no emitters are configured, the
 * `.tsp` is the source of truth for the wire shape only; both sides
 * hand-implement matching types (same convention as `eventius/typespec` and
 * the `sneat-go/typespec` directory). The matching Go DTOs live in
 * `../backend/dto4kidsclub/dto.go`.
 *
 * Source: backstage `docs/superpowers/specs/2026-07-02-kids-club-prototype-design.md`.
 *
 * Auth: club creation and the roster read require
 * `Authorization: Bearer <token>` and caller membership of `{spaceID}` (the
 * operator's business space). The public club page needs NO auth. Registration
 * submit also REQUIRES `Authorization: Bearer <token>` — the parent must be
 * signed in; their UID is recorded as the consenting guardian.
 */
@service(#{ title: "Kids Club API" })
@route("/v0/api4kidsclub")
namespace Api4Kidsclub;

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

/** POST body to create a club within the operator's space. */
model CreateClubRequest {
  title: string;

  /** Free-text venue type, e.g. "hotel", "jump zone". */
  venue?: string;

  /**
   * The club's v1 waiver text shown to parents at registration. Required —
   * registration records acceptance of it.
   */
  consentText: string;
}

/** Identifies the new club so the UI can navigate to it. */
model CreateClubResponse {
  id: string;

  /** Site-relative public club page path, e.g. "/club/abc". */
  publicPath: string;
}

/** The unauthenticated public projection of a club. */
model ClubPublic {
  id: string;
  title: string;
  venue?: string;
  consentVersion: string;
  consentText: string;
}

/** One child in a registration. */
model Child {
  name: string;
  birthYear: int32;

  /** "f" | "m" | "" (unspecified). */
  gender?: string;
  allergies?: string;
}

/** Records acceptance of the club waiver. */
model ConsentAcceptance {
  version: string;
  acceptedAt: utcDateTime;
  byUID: string;
}

/**
 * Body to submit children to a club. `acceptedConsentVersion` MUST equal the
 * club's current `consentVersion`; the server stamps `acceptedAt` and
 * `byUID` on the resulting `ConsentAcceptance`.
 */
model RegistrationRequest {
  children: Child[];
  emergencyContactName: string;
  emergencyContactPhone: string;
  pickups?: string[];
  acceptedConsentVersion: string;
}

/** Identifies the new registration. */
model RegistrationResponse {
  id: string;
}

/** One registration row in the operator's roster. */
model RosterEntry {
  id: string;
  children: Child[];
  emergencyContactName: string;
  emergencyContactPhone: string;
  pickups?: string[];
  consent: ConsentAcceptance;
  createdAt: utcDateTime;
}

// ---------------------------------------------------------------------------
// Operations
// ---------------------------------------------------------------------------

@tag("clubs")
interface Clubs {
  /**
   * Create a club within `{spaceID}`. Caller MUST be a member of the space
   * (the operator). Returns the new club's id and public path.
   */
  @post
  @route("/spaces/{spaceID}/clubs")
  @useAuth(BearerAuth)
  createClub(@path spaceID: string, @body body: CreateClubRequest): {
    @statusCode statusCode: 201;
    @body club: CreateClubResponse;
  };

  /** Fetch the public projection of a club. No auth required. */
  @get
  @route("/clubs/{clubID}")
  getClubPublic(@path clubID: string): ClubPublic;
}

@tag("registrations")
interface Registrations {
  /**
   * Submit children to a club's registration list. Auth REQUIRED — the
   * parent must be signed in (`Authorization: Bearer <token>`); the server
   * stamps the caller's uid as `byUID` on the resulting `ConsentAcceptance`.
   */
  @post
  @route("/clubs/{clubID}/registrations")
  @useAuth(BearerAuth)
  createRegistration(@path clubID: string, @body body: RegistrationRequest): {
    @statusCode statusCode: 201;
    @body registration: RegistrationResponse;
  };

  /**
   * List all registrations for a club (operator roster view). Caller MUST
   * be a member of `{spaceID}`.
   */
  @get
  @route("/spaces/{spaceID}/clubs/{clubID}/registrations")
  @useAuth(BearerAuth)
  listRegistrations(@path spaceID: string, @path clubID: string): RosterEntry[];
}
