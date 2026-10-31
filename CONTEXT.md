# CONTEXT.md — what the task is and why (from the organizers' docs, fetched 2026-10-31)

Read order for a new session: CLAUDE.md -> NOTES.md (live state) -> this file (background). RESULTS.md has the numbers.
Sources: onboarding doc (2PACX-1vQIKF-...) and Option 1 doc (2PACX-1vQP-...), both linked in CLAUDE.md. The Option 1 text below is a
paraphrase by the fetch tool, not verbatim; re-read the doc if exact wording matters.

## Who / what
- Kent Ridge HPC = NUS SoC student HPC team; they enter student cluster competitions (SC, ISC, ASC): build/tune a cluster in a 42U rack
  under a power budget; most work is system-level (OS, network, compilers/flags, benchmark settings, process placement). Benchmarks: HPL, HPCG, NAMD...
- Joining: weekly meetings, self-directed learning, possible overseas travel in a break. Try-out = self-starters; Ethan picked **Option 1: HPL software benchmarking**.
- The task is deliberately open-ended: "shows how you approach problems"; organizers withheld some details on purpose; don't spend excessive time.

## Option 1 rules (organizers' wording, condensed)
1. SoC Compute Cluster only. 2. CPU only: only `xcn*`, never `xgp*`.
3. **At least 2 and at most 4 nodes** (login node doesn't count). CLAUDE.md only states the max; the minimum of 2 matters: 1-node runs are not a valid final result.
4. Submit: code, the `hpl.dat` used, written report.
- Code: email .zip/.tar.gz to ccris@comp.nus.edu.sg AND srirams@comp.nus.edu.sg. They copy it to a SoC login node, extract, run `make` then `make run`.
  **The output of `make run` is the final score.**
- Report: PDF attached to the same email; concise; how the score was achieved and what was learned (guiding questions, not exhaustive); optional
  resume/short bio.
- Evaluation: the `make run` HPL result, plus the problem-solving process shown in the report.

## What we found that shapes the answer (2026-10-30/31)
- QOS `normal` caps a user at cpu=256 running => 2 full xcni nodes (128 CPUs each). So **2 nodes is both the minimum allowed and the most we can
  actually run**; `make run` defaults to NODES=2. Organizers' accounts likely have the same cap (a 4-node default would pend forever).
- Everything else (cluster access by manual relay, own Open MPI + BLIS build, tuned 1-node config 16 ranks x 4 threads, NB=384) is in NOTES.md.

## Still open
- Final N for 2 nodes: 231,552 at NB=384 (0.80 x RAM) planned, not run. Tuning at N=65280 first (NOTES.md step B).
- Whether `make` can download tarballs on the organizers' login node (NOTES.md section 6).
- Report (PDF) and bio: Ethan supplies/edits; he sends the email himself.
