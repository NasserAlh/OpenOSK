# Status board

OpenOSK has a one-page status board for whoever signs work off: what the repository's documents
currently prove, what is still unproven, and the one thing waiting on a decision. It is generated
from the controlled documents named in `.claude/gate-board.json` (the change log, the contributing
rules, `docs/feature-parity.md`, `docs/architecture.md`, `docs/testing.md` and
`docs/VERIFICATION.md`) and from a live run of the core tests.

The board is a rendering, never a source of truth. If it disagrees with a document in this
repository, the document is right and the board is stale. A decision, defect or test result that
exists only on the board does not exist; put it in the documents first, then refresh.

## Where it is

The board is a private page on claude.ai. Its address is not kept in this public repository: it
lives in the git-ignored `.claude/gate-board.local.json` next to the tracked config, and in the
artifact gallery of the account that published it (`/artifacts` in Claude Code, or
claude.ai/code/artifacts). A clone without that local file can rebuild the board but must not
publish a second one; recover the address first.

## Refreshing it

Saying "refresh the gate board" (or "refresh the status board") in Claude Code rebuilds the page
from the documents at the current commit and republishes it to the same address. Refresh:

- after a test pass, whether it passed or failed;
- after a change note, a ruling or a correction to one of the source documents;
- after a merge to main;
- before handing the project to someone else;
- when returning to the repository after a long gap.

The header names the commit the board was built from. A board older than the newest commit that
touched code describes a state that may no longer hold.
