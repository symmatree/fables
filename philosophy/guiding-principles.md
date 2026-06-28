# Guiding principles -- observer notes

*Provenance: Two conversations, same author, same week. The first
(`2026-06-24-knowledge-architecture`) was explicitly about epistemics -- how to
organize a personal knowledge graph, how to verify claims, how to avoid the
failure mode of a hallucinating assistant. The second
(`2026-06-24-ssh-notebooks`) was a concrete build problem: pick a strategy for a
long-lived SSH development target in a Kubernetes cluster. The principles below
were distilled by two agents working as annotators, then cross-adjudicated. A
principle that appeared in only one domain is marked domain-local and held with
less confidence. The evidential asymmetry is noted throughout: the knowledge
conversation was explicitly about epistemics, so its abstractions were available
to be reached for; the dev conversation was a concrete build problem, so each
principle had to fall out of something it needed to explain. Where the two
converge despite that temperature difference, the convergence is more
trustworthy, not less.*

Citations use short forms: [KB] = `facts/claude-transcripts/2026-06-24-knowledge-architecture/annotated-knowledge-and-verification.md`;
[DEV] = `facts/claude-transcripts/2026-06-24-ssh-notebooks/annotated-interview-across-time.md`;
[CVG] = `facts/claude-transcripts/2026-06-24-ssh-notebooks/convergence-adjudication.md`;
[CNV2] = `facts/claude-transcripts/2026-06-24-knowledge-architecture/convergence-notes.md`;
[DTKT] = `facts/claude-transcripts/2026-06-24-ssh-notebooks/deploy-the-toolkit-into-the-place.md`.
Raw transcripts are at `facts/claude-transcripts/2026-06-24-*/raw-transcript.txt`.

---

## Confirmed -- converged across domains

These appeared in both conversations, arrived by independent derivations, and
survived a formal cross-adjudication pass. Treated as load-bearing.

---

### P1. Preserve the fidelity tier; dispose the derived tier; prove the seam by perturbing across it

The most-converged principle in the pair. Everything else is this wearing a
different hat.

**Claim.** Separate what you are not allowed to edit from what you derive from
it. The preserved tier is never rewritten; falsification, decay, and debugging
happen in the derived tier without cracking the foundation under it. The seam
between tiers is not trustworthy by assertion -- it is trustworthy because you
have perturbed across it and the fidelity tier reconstructed the derived tier
cleanly.

**Evidence.** Stated as the explicit win condition in the knowledge/verification
conversation:

> "Lots of theories were disproven, but we didn't have to revisit our
> characterization of the data to correct things once we understood it better,
> we only had to fill in unknowns that were now known." [KB §2]

Zero retracted observations, many dead theories.

The same principle was re-derived four separate times in the dev-environment
conversation, never once stated as a rule:

- **Pod:** keep the persistent home directory, but `delete pod` to prove the
  box rebuilds from the image.
- **Kernel:** keep the live dataframes in memory, but headless-rerun to prove
  the notebook reproduces top-to-bottom.
- **Notebook-in-git:** keep the committed output (the point-in-time record),
  but scheduled strip-and-rerun to prove it still works.
- **Run artifacts:** keep the frozen metrics beside the model, reconstructable
  from the recipe.

Each is: "preserve the rich state AND separately maintain a process that
re-derives it to catch drift." [DEV Coda]

Earned four times from concrete build problems; not an abstraction reached for,
but one that fell out of things that needed explaining. By the method note in
[CVG] (earned beats available), the four-fold dev re-derivation is the
load-bearing evidence and the knowledge/verification phrasing is a clean gloss.
This is the corrected attribution from open item O1 in [CNV2]: an earlier draft
had it backwards.

The seam proof is also the principle at work on itself: the destroy-and-
reconverge test is the preserved/disposable seam exercised under load. The seam
is not trustworthy because you drew it; it is trustworthy because you perturbed
across it and the fidelity tier reconstructed the derived tier cleanly.

**Limits.**

The seam must be drawn in the right place. Draw it wrong and you either lose
data (the seam was inside the observation tier) or retain garbage (the seam was
inside the inference tier and you preserved a theory-laden rewrite of the data).
The principle specifies the discipline; it does not locate the seam. That is a
human judgment about which tier a given artifact belongs to, and it must be
declared -- the system cannot infer it.

The `authoritative vs. reconstructable` distinction [KB §2, design-intent §6]:
a health-check notebook that *captures* live system state produces an
authoritative output (the raw capture is the only copy of that observation,
never deletable). The same notebook's *analysis* of that capture is
reconstructable (re-runnable from the immutable raw). Confuse the two, GC the
raw capture, and you have deleted an irreplaceable observation. The principle
says "default to keep"; the corollary is that the tier assignment must be
declared, not inferred.

A mis-shelving caught during adjudication: an earlier draft filed "recipe is
source of truth, running environment is disposable" under the
*make-the-easy-path-correct* heading [CNV2]. That was wrong. The easy-path
property (re-deriving is cheap) is a consequence of putting authority in the
preserved tier, not the cause. "Deploy the toolkit into the place" [DTKT] is
this principle applied to environments, not the other way around.

---

### P2. Make the easy path correct -- via an enforcement generator

**Claim.** The target is not willpower-based compliance. It is arranging things
so the lazy act *is* the correct act. Two mechanisms, not one:

- **Channeling:** make the correct path the only low-energy slot, so error has
  nowhere comfortable to land. Works by attraction.
- **Attrition:** make the wrong path genuinely lossy, so it self-punishes over
  time. Works by erosion.

Neither domain had both. Together they are two engines for one equilibrium.

**Evidence.** The channeling mechanism:

> "No coercive system, just making it easy to be lazy in a good rather than bad
> way." [KB §1]

The annotator's gloss on the same exchange, which is the mechanism stated as a
rule:

> "You arranged things so the lazy act and the valuable act were the same act.
> [...] Three appearances of one idea: don't fight the gradient, bend it."
> [KB §1]

On making a document structure do what instruction cannot:

> "I think the doc structure helped it pattern match into compliance instead of
> trying to throw in the most likely conclusion. [...] I definitely held the
> line and cursed a lot, but [...]" [KB §1]

The annotator's note: when you can't make a model hold an epistemic stance
through instruction, you can sometimes make the *document it writes into* hold
it. A "Confirmed / Disproven" scaffold gives the seize-on-a-detail reflex a
low-status place to park a hypothesis instead of promoting it to a conclusion.
The structure is a more attractive low-energy path than an open field.

On sycophancy and seize-on-a-detail as the same failure, redirected by
structure:

> "The flip side of 'I will latch onto this detail' is 'you are so clever this
> all makes perfect sense' regardless of payload. But here that converges on
> 'wow you're so right, we don't know that yet do we' instead of reinforcing my
> theory." [KB §3]

You don't argue the model out of flattery; you remove the place flattery would
go.

The attrition mechanism, from the dev side:

> "The lossiness isn't a flaw to be mitigated; it's the mechanism that keeps
> pets from forming." [DTKT]

> "Destroy the place and re-converge it. If you lost something that mattered,
> that something was supposed to be in the recipe or in version control, and the
> friction of losing it is the signal telling you so." [DTKT]

**Efficacy.** The channeling form has a meta-application: a story is a
channeling structure; a rule is an instruction the model acknowledges and routes
around. This explains why a worked example outperforms an instruction sheet for
steering an LLM's epistemic behavior [CNV2 §A2]. The principle applies to
prompting and document design, not only to information architecture.

**Limits.**

The escape hatch must remain open. If the system ever demands a well-formed
name, parent, and fields before you can save a thought, you start keeping a
shadow notes-app the graph never sees:

> "At the limit I'll make a file called temp.txt and check it in, but that's
> not a good pattern [...] reducing it to a 'filesystem with delusions of
> grandeur' makes it harder to hide stuff in shadow files, but also means we
> don't have to deal with truly unnamed content." [KB §1]

`temp.txt`-checked-in is described as bad as a *pattern* but essential as a
*floor*. An enforcement mechanism that offers no floor exits pressure instead of
channeling it. The path of least resistance must always terminate inside the
system.

Channeling has its own failure mode: a template pointed at *completeness*
produces filler; a template pointed at *honesty-of-shape* compels real
admission. The old design-doc "Regulatory impact: N/A" is coercive-completeness
-- compulsion aimed at the wrong attractor, producing volume without thought
[CNV2 §F]. The mechanism is sound; the question is always "which attractor."

Attrition requires that the lossy layer is *genuinely* lossy and that the
pressure to promote is *felt* before the work is lost. If the ephemeral layer
quietly persists because the pod was never recycled, pets form without the
feedback loop firing. The mechanism assumes someone is paying the reset cost
periodically [DTKT, "Constant vigilance"].

---

### P3. Own where you're the best solver; rent where you're not -- and mind the ownership tax

**Claim.** The question is not "own vs. overlay" as a slogan. It is whether
*you* or an available upstream solves the hard problem better. Own the layer
whose hard problem you solve better than any available upstream. Rent the layer
whose hard problem someone else solves better. The cost of the wrong choice is
not the specialization; it is the permanent frictional tax of owning a bespoke
thing instead of making a few surgical interventions in someone else's tested
lifecycle.

**Evidence.** The case for renting, from the dev conversation:

> "You're fooling yourself if you think you can own the docker root and not
> regret it. All you need is one thoughtless project that thinks the same way
> and you're hosed. [...] Need to do something with a GPU? Well, AMD or Nvidia,
> both want to own that docker root, and both tend to assume you actually have
> hardware, so you can end up with three working variants right there." [DEV §1]

The clean TCO statement, on JupyterHub:

> "I'm absolutely confident I could recreate the entire jupyterhub stack from
> first principles, but writing and maintaining a remote access layer isn't my
> hobby and it is in fact theirs, so it's nice to let them keep it. [...] The
> cost of specialized solutions isn't the specialization, it's the constant
> frictional cost of now owning a bespoke thing." [DEV §5]

The case for owning -- and the counter-example that kills "always overlay" as a
general principle:

> "I think canonical stable id is impossible unless you become a slave to your
> own tooling [...] 'just give everything a uuid' just dodges the problem [...]
> identity becomes a resolver over lazy-good human names, not a key." [KB §5]

> "Let the file system be the lowest common denominator!" [KB §5]

The filesystem substrate was owned deliberately to stay free of imposed schemas.
Opposite stance, same person, one conversation apart.

**Efficacy.** The convergence is trustworthy because the *same rule produces
opposite outputs* in the two domains:

- GPU userspace / BLAS compatibility: vendors solve this better and hold the
  leverage. Rent.
- "What does this mean to me": you are the best solver by construction, because
  the value is your private judgment and no upstream ontology carries it. Own.

A principle that produces opposite actions in opposite situations is more
credible than one that produces the same action everywhere -- the latter is
usually a slogan that hasn't met a hard case [CVG §2].

**Limits.**

The scientific-stack base is the worked example of renting being the disciplined
choice:

> "It's actually quite hard to install scipy and numpy and ipython in a mutually
> tolerant stack, since they overlap on a number of underlying libraries, which
> IIRC are not necessarily all managed via separate apt packages or anything
> that obvious. So we might preserve this as the actual image we run [...] even
> if we weren't under jupyterhub." [DEV §6]

"Own it from scratch" feels disciplined but is often the less reproducible
choice, because it makes you re-solve hard problems a maintained base already
solved.

⚠ Error caught in conversation [DEV §5]: "you're single-user, so JupyterHub's
multi-user spawning machinery buys you little; drop it." Wrong twice. It
conflated how many security principals (one) with how many environment instances
(many -- tasks, agents, experiments). The multi-user namespace is reusable as a
persistence-key scheme without inventing one, independent of user count.
Evaluate on TCO and competence gradient, not on structural elegance.

---

### P4. Pets vs. hostage-takers -- erase the uniqueness you didn't choose; cherish the uniqueness that carries the value

**Claim.** "Cattle not pets" conflates two kinds of irreplaceable: the *pet*
(unique *is* the payload -- a thesis, a hand-captured observation, a bespoke
tool -- cherish it) and the *hostage-taker* (unique because you failed to make
it reproducible -- dissolve it). The move is not "eliminate uniqueness." It is:
erase the uniqueness you didn't choose; cherish the uniqueness that carries the
value. Some layer must hold the value or the disposability apparatus has nothing
to serve.

**Evidence.**

> "Pets ARE important when the pet is 'your thesis' or 'your weirdly bespoke
> cad program'. Less so when they're 'a random server that I can't replace
> easily'. The first truly ARE pets and should be treated as such; the latter
> is more like a hostage taker." [KB §7]

The governing caveat over the entire set:

> "You can't drive value and uniqueness and particularity out of EVERYWHERE
> because it has to live somewhere, it's where the light gets in and all that
> shit. [...] some layer MUST be worth your time or what are we even doing
> here?" [KB §7]

Disposability as a means, not an end:

> "You make the servers interchangeable *so you can afford to make the thesis
> irreplaceable.*" [KB §7]

Disposability everywhere is nihilism with a runbook.

**Efficacy.** The convergence has the trustworthy shape: same model, opposite
optimization pressure. The dev-host durable layer is mostly hostage-takers
(minimize it). The KB durable layer is mostly genuine pets (protect it). Same
model, opposite output, because the inputs differ. A principle producing opposite
actions from the same structure is more credible than one producing the same
action everywhere [CVG §4].

The correction to the dev conversation's own model: the dev-pod's durable-work
layer (PVC with git trees, session logs, in-flight work) is not interchangeable,
and the entire three-tier model exists to protect it. Re-sorting into "uniqueness
is the value, protect it" vs. "uniqueness is un-eliminated un-reproducibility,
dissolve it" makes the model more coherent, not more permissive [CVG §4].

**Limits.**

The caveat does not license lazy non-reproducibility. Calling something a "pet"
to avoid writing a recipe is the failure mode. The discriminator is not sentiment
("I like this one") but whether the uniqueness was *chosen* because the value
lives there, or *accumulated* because the re-derive work was never done. A thesis
is a pet by construction; a random server that "just kind of grew this way" is a
hostage-taker wearing a pet's costume.

The claim that some layer must be worth your time "or what are we even doing
here" is directionally correct but does not specify *where* in the stack the
valuable layer sits. That judgment is domain-specific and not resolvable by this
principle alone.

---

### P5. Active perturbation beats passive resemblance -- in two distinct forms

**Claim.** Passive checks (range, trend, resemblance) are forgeable by
coincidence. Active perturbation -- inject a cause, confirm the right effect --
is not. A test that has never been observed to *fail* under the condition it
claims to detect proves nothing about that sensitivity. This principle has two
sub-forms that catch different failure classes:

- **Differential perturbation** (motor-cup form): perturb *one* referent and
  confirm *only it* moves. Catches mislabels and confounds. Un-fakeable because
  a counterfeit would have to anticipate which referent you'd perturb.
- **Global perturbation** (cold-rebuild form): perturb *everything* and confirm
  the property survives. Catches un-reproducibility. The destroy-and-reconverge
  test is global perturbation aimed at the tier seam itself.

These should not be collapsed -- they catch different failure classes [CNV2 O2].

**Evidence.** The differential form, on verifying a telemetry label:

> "My idea about cupping my hand around a motor was not as an independent sense
> of the temperature but rather as an active intervention which should
> selectively raise the temps on one motor and one motor only, which is a
> differential signal that would be almost impossible to fake." [KB §6]

The canary / sentinel form:

> "It's exactly what Loki does with sentinel jobs that send probe logs from each
> host to confirm that the host to collection path is working. [...] 'responds
> to stimulus as expected,' which you could handwave as like a step toward
> system identification in a control theory sense." [KB §6]

The fail-first form:

> "Always making sure your new unit test fails before you fix the bug you just
> found. [...] If you're adding a package of alerts, trigger at least one of
> them once." [KB §6]

The global form, from the dev diagnostic questions:

> "If this place vanished right now, how long until I have an equivalent one?
> If the answer involves remembering things I did by hand, I'm keeping a pet."
> [DTKT]

**The proxy trap -- the deepest version of this principle:**

> "The correlation holds except in the one situation where you actually need it
> to, if you rely on measuring through proxies. [...] I think it's possible
> that d term oscillation would look like that correlation breaking down."
> [KB §6]

A proxy works by a correlation that holds in the normal regime. Faults are
abnormal-regime events. So the proxy is most likely to fail in exactly the
regime you built it to monitor. Faithful right up to the failure it exists to
catch, then blind. Validate a proxy in the fault regime, never in normal
operation where it is guaranteed to pass.

The same failure appears in a social domain instance:

> "Equity is well aligned with formal practice here -- a lot of interventions
> would be specifically having the effect of changing that correlation, so you
> can't lean on it if it's not independent." [KB §6]

A zip-code-as-IQ proxy works via embedded systemic structure. An equity
intervention's purpose is to decouple outcome from zip code -- so the proxy
misreads success as no-change precisely when the intervention works. Measure the
construct directly when your intervention may change the coupling.

**Cadence.** Perturbation should track the rate at which the binding can
change, not the rate of use:

> "I'm not going to actually hold a randomly chosen motor in my hand each
> morning [...] maybe I should every hundred hours or something, just to see if
> it all still repeats with updated versions and used hardware." [KB §6]

Perturb on change events (firmware/hardware swaps) plus slow periodic re-confirm
to catch unannounced drift -- incoming-lot inspection plus periodic assay, for
the same reason QA does both.

**Stopping condition.** "Test until fear turns into boredom" is the right rule
for when active perturbation can be relaxed -- indexed to actual uncertainty,
not a coverage number. But the second clause is load-bearing:

> "I heard 'test until fear turns into boredom' and it's a good principle as
> long as you have enough fear including epistemic risks like 'what if I'm
> misinterpreting what seems to mean "temperature"'." [KB §6]

The second clause is what the ESC mislabel cost. Mechanical fears announce
themselves as fears; semantic fears do not. The fix is a standing list of
epistemic checks -- "am I sure what this means? am I sure this source is
independent? am I sure absence is signal?" -- that always get a turn before
boredom is declared, because they are exactly the ones that don't feel like
they need a turn.

**Limits.** The limit stated as a rule:

> "The framework doesn't demand you perturb everything always; it demands you
> not fool yourself that a passive green is doing a job only active perturbation
> can do." [KB §6]

---

## Strong but domain-local or less independently tested

These are real principles with good evidence in one domain, but either did not
independently emerge in the other, or have not yet been formally adjudicated as
converged.

---

### P6. There is no raw observation -- the seam runs through the label

**Claim.** The dangerous inference is the one disguised as a reading. The seam
between observation and inference does not run between the data and the
conclusion; it runs through the act of *naming* what the data is. Recording a
number as a measurement of something already applies a model of the instrument.

**Evidence.**

> "You never really know where the observation stops and interpretation begins.
> [...] I read an esc temp as being a motor temp, on the logic that a 4-in-1
> has one esc and this was producing 4 signals so maybe it DID have a way to
> sense that. It turns out [...] they're just esc temps [...] I thought,
> briefly, that I had demonstrated the motors weren't micro-chattering [...]
> my very objective observation was actually a very flawed conclusion." [KB §2a]

The two audits that should be run on any source: (a) is the source behaving like
a real instance of itself -- range, trend, units? (b) does the label *mean* what
I am binding it to? The motor story: audit (a) was done correctly; audit (b) was
skipped.

The corrected stance:

> "I think the takeaway is NOT trust nothing [...] solipsism is never a good
> look after high school. [...] you have priors about the relative objectiveness
> and independence of various sources, and that usually works well (mimir is
> independent of the system under test [...] returning a time series not a 'low'
> or 'higher than I'd like' judgement [...] not specialized for my task so it
> can't be doing anything weird other than the relabels I know about)." [KB §2a]

"All observation is theory-laden" does not imply "trust nothing." It implies
calibrated source-trust, which is itself a checkable skill. The priors named --
independence from the system under test, no collusive-failure incentive,
returns-raw-not-judged, not-specialized-for-the-task -- are a good-enough
approximation of objectivity.

> "Similarly I DID confirm that the temps reported were in a reasonable range
> for a Celsius temperature, climbed as the flight went on; [...] I should have
> kept an explicit asterisk on the semantic assignment to that label string."
> [KB §2a]

Plausible shape ≠ correct meaning. Flag single-source semantic bindings as
provisional until an independent channel confirms. The asterisk is the fix.

**Status.** Domain-local to the knowledge/verification conversation. The dev
conversation has a cousin (the importance of preserving opensfm/ directories to
enable later re-analysis of photogrammetry data) but this principle has not been
independently derived from a concrete build failure in the dev domain.

---

### P7. Two modes -- and knowing which you're in

**Claim.** The heavy investigation apparatus earns its weight only under slow or
confounded feedback with a seductive-but-wrong story available. The tell is the
feedback loop, not the difficulty. Deploying the investigation ceremony in
hurdle-clearing mode is cargo cult; failing to deploy it in the appropriate mode
is how theories calcify.

**Evidence.** On the default mode:

> "For the most part it's been more of a traveling pattern: mostly clearing
> hurdles and moving on to the next, rather than sitting and stewing in a mess
> of unsatisfactory data." [KB §3]

The Gemini failure named precisely:

> "Talking our way from one equilibrium to another [...] without either crisply
> addressing the known data, nor nailing down the diagnostic (versus trying to
> leap ahead to a fix)." [KB §3]

The confirmed/disproven structure removes the smooth manifold the conversation
used to slide along.

A third mode, exploration, defended as legitimate:

> "Sometimes you need to taste an idea and see how it sits [...] this kind of
> open ended exploration can help you remember the lightness and elegance, even
> though it doesn't make it inherently correct." [KB §3]

Exploration's output is appetite, not truth. The danger is not the tasting; it
is filing the taste as a verdict. The corrective, from the same exchange:
"you don't run a brainstorm through a code review." [KB §3]

The same structure was independently derived from a concrete decision about
notebook interfaces [DEV §12]:

> "The two paths are the two modes you already believe in: the live kernel is
> the working/iteration surface -- preserve namespace, re-run one cell,
> dataframes intact -- and the headless render is the validation/export surface
> -- fresh kernel, top-to-bottom, proves it runs clean. That split isn't a
> compromise between the two paths, it's the same two-mode structure you've
> reached for at every other layer of this system." [DEV §12]

Mode one (live kernel / exploration) preserves expensive state and enables
rapid iteration. Mode two (headless render / falsification) starts cold and
proves the work survives a fresh start. The headless render is the notebook
equivalent of blowing away the pod: if the notebook only works because of
hidden out-of-order kernel state, the cold run catches it. Neither mode is
a degraded version of the other; each catches what the other cannot.

**Status.** Partially converged. The live-kernel/headless-render distinction
above was derived independently in the dev domain from a concrete interface
choice (preserve dataframes vs. prove clean reproducibility), without the KB
conversation's explicit two-modes framing being available. A third candidate
-- "when a question turns empirical, stop arguing and build the cheap isolated
test" [DEV §11] -- has not been formally adjudicated.

---

### P8. Signal vs. actor -- the layer you reason from must not also act

**Claim.** A monitoring layer that also acts cannot be trusted as ground truth.
When assumption failures are correlated (one expired cert fails a hundred
guards), an investigate-on-failure design responds to the highest-stakes moment
by spawning a swarm that all rediscover the same root cause. The guard captures
more detail on failure; it takes zero action. Enforce with structure (identity,
RBAC, document-shape), not runtime vigilance, because vigilance doesn't scale
and breaks the moment attention lapses.

**Evidence.**

> "Anything more would be like the unit test launching a fix-me flow, it's both
> inappropriate and too low for visibility. Maybe a cert expired and everyone is
> failing, it would make such a mess of incident response if that spawned a
> million little agents." [KB §4]

On scoping agents by identity rather than by vigilance:

> "[It would be nice to bake privilege scoping] into the agent rather than
> trying to restrict it while still having my own admin powers under the hood."
> [DEV §8]

The resolution: run the agent as a separate lesser principal that never had the
dangerous power. Nothing to "hold back" -- there is no shared identity to
partition.

> "You move the human-in-the-loop from 'approve each kubectl' to 'approve the
> identity definition in review' -- the approval happens at the speed of
> provisioning, not the speed of execution, and after that the floor holds
> itself." [DEV §16]

Approval that rests on cred scope is safe to auto-approve; approval that rests
on someone watching is vigilance, and vigilance doesn't sleep. The goal is to
push every auto-approve onto the first model and eliminate the second.

The same shape appears in: inference-must-not-rewrite-observation; the override
that flags but does not overwrite; the groomer that flags dead links, does not
fix them [KB §4]. The layer you reason from must not be the layer that acts.

**Status.** Converges at a high level (no-actor layers / scope-by-identity) but
the signal/actor framing is richest in the KB conversation and was not
independently re-derived from a concrete build failure in the dev conversation.
Rated partial convergence.

---

## Proposed for the editing room floor

These are proposals from the transcripts that are not yet mature enough to be
confirmed principles, are too implementation-specific, have not been
independently converged, or lack predictive power beyond what the confirmed
principles already supply.

**Templates as channeling structures [CNV2 §F].** A rich proposal: old
design-doc templates failed by aiming compulsion at completeness; a good
template aims it at honesty-of-shape. Non-valenced comparative positioning
("position X against its nearest alternatives") is a concrete improvement over
pros/cons templates. The reasoning is sound and the specific critique of
pros/cons is sharp (pros/cons evaluates one option in isolation, smuggling in the
premise that goodness can be read off a thing; it is also valenced, which is the
exact channel catastrophizing travels down). However, this is one layer of
application of P2 rather than an independent principle, and the specifics about
motivated-reasoning limits and external cross-checks require more time to
develop. Leave for a separate doc when the template is actually built and tested.

**"Don't put a boundary through the actor's hands" [DEV §7].** The SSH
observation that an agent is most effective when filesystem, shell, and working
tree are all local to it -- one hop, no seam through its hands. Sound but
underdeveloped, and not cross-domain. Interesting enough to keep watching.

**Premature reification [KB §2b].** The observation that useful *ways of
thinking* harden prematurely into first-class *mechanisms* that haven't earned
the weight. Caught mid-conversation as an error in the annotator's own work:
"I took a useful way of thinking -- placement should be computed from declared
facts, not chosen per-directory -- and hardened it into a first-class mechanism
it hadn't earned, when the real v1 is an enum with two cases." Real, but lives
in the verification domain's relationship to its own analysis. Has not been
independently converged in the dev domain, and resisting that merge is an
instance of the principle itself. Keep as a named failure mode for the KB
context; do not promote.

**The full notebook/provenance tooling comparison** (`comparison-placement-schemes.md`,
`design-intent.md`). Good design docs -- point-to-point configs, computed layout
functions, Sumatra-shaped provenance layers, papermill. These instantiate the
confirmed principles rather than being principles themselves. Stay in the
knowledge-architecture session documents; do not promote to philosophy.

**Idiosyncratic cost structure as a solvability unlock [KB §5, and broader].**
The KB observation was: "I don't need to catalog everything about everything. I
need, at most, to catalog the relevant to me parts of the relevant to me items."
Single-reader / single-namer scope deletes the adversarial-consensus machinery
entirely -- not a cheaper Wikipedia, a different problem class.

That is one instance of a broader diagnostic pattern: the conventional solution's
anxiety about a problem is evidence about cost structure, and that evidence points
either way. If a standard approach is very worried about something you're not
worried about, you are either underestimating the problem or your use case
genuinely doesn't require the thing being protected. Noticing the mismatch is the
start of the analysis, not the conclusion.

The pattern runs in two directions:

**Identifying slack you already have.** When you can solve a problem cheaply that
others cannot, look at what the conventional solution is anxious about and check
whether your actual use cases exercise that constraint. If they don't, design for
not-having-it. The Google GFS case: POSIX random-access semantics exist to manage
a cost (local disk, arbitrary seek, single writer) that Google's workloads --
appending proto logs to a file tail, precomputing immutable shards -- genuinely
didn't exercise. Dropping the semantics wasn't motivated reasoning; it was a
correct reading of what the use cases actually needed. If instead the log package
had kept a live header at byte 0 (constantly seeking back to rewrite it), that
constraint would have been real and couldn't be wished away.

**Constructing slack you don't yet have.** When you can't solve a problem at your
constraints, review the "obvious" requirements and ask which ones could be relaxed
through reworking the use case rather than improving the solution. In the header
example: you can't afford random writes, but maybe the header can be reconstructed
at read time from the appended records, or written to a separate cheap file. If
so, you've adapted the use case to genuinely not need the constraint -- not
rationalized it away, but actually removed it. That adaptation is real work, but
usually cheaper than a problem you cannot solve at your price/performance/time.

No special guard against motivated reasoning is required: if you drop a property
your use case actually needs, the result can't serve the purpose, so it doesn't
help. The correction is empirical, not introspective. If the log constantly
updates the header and you drop random-write support, the log package breaks --
that's the signal, not a prior audit of whether your reasoning was honest.

Homelab is the everyday version: you accept failure modes (downtime, manual
recovery, idiosyncratic UX) that production cannot accept because other people are
affected. The constraint other-people-are-affected is genuinely absent; it doesn't
need to be constructed. That absence collapses a tier of cost and changes what is
solvable, without any rationalization required.

The pattern already appears implicitly in confirmed principles. In P2: the lazy-
good-names channeling only works because Seth's naming habits are coherent -- a
shared repo with multiple contributors loses the idiosyncratic property, and the
"lazy act is the correct act" no longer holds. In P3: "own where you're the best
solver" often means "own where you have an idiosyncratic cost advantage." Google
owns GFS not because they are the best filesystem engineers but because they are
the only ones with that specific cost structure.

Not promoted: the pattern is real and the examples are good, but it arrived and
was refined in this same session -- the "not promoted" principles went through
cross-domain adjudication and counter-example testing before landing where they
are. This one hasn't. Revisit when it has been tested against more cases,
particularly ones where the constraint turned out not to be relaxable, to
calibrate where the pattern fires correctly versus where it flatters a bad
decision.

---

## Disproven proposals

These were proposed in the transcripts and explicitly killed, either by a
counter-example or by the convergence adjudication.

**"Always overlay" / "always rent the base."** Killed by the KB
counter-example: the knowledge-graph substrate was owned deliberately to stay
free of imposed schemas. The surviving rule is P3. [CVG §2]

**"Cattle not pets" as a complete principle.** Weakened -- not wrong but
incomplete. The slogan hadn't met the hard case of the dev-pod's own PVC.
Corrected to P4. [CVG §4]

**"Single-user means drop the multi-user machinery."** ⚠ Error caught in the
dev conversation [DEV §5]. Conflated how many security principals with how many
environment instances. The multi-user namespace is reusable as a
persistence-key scheme without inventing one, independent of user count. The
error came from evaluating architecture on elegance instead of TCO.

**"Own the base from scratch."** ⚠ Error averted mid-conversation [DEV §6].
Feels disciplined but is often the less reproducible choice, because it makes
you re-solve hard problems a maintained base already solved. The scientific-stack
base (BLAS/LAPACK/Fortran ABI compatibility across scipy/numpy) is the concrete
case. Renting the hard base is the disciplined move when the base's problem is
one you would do worse at.

**"Rendered notebooks should bot-PR back into the repo."** ⚠ Error (own,
caught) [DEV §10]. Conflated source-and-intent (notebook, code, config --
repo-appropriate) with rendered outputs (executed PDFs -- object-storage-
appropriate, placed beside the run artifacts they belong to). "Put each thing at
the layer where it belongs, and don't let a convenience smear it across layers."
The payload goes where payloads go; a small text pointer is what is repo-worthy.

---

## Appendix: "Interpreting anecdote"

> "I once had Gemini pause for a long time with the text being 'Interpreting
> anecdote' and my friends were GREATLY amused." [KB Appendix]

Kept for posterity because it is the honest job title for this whole document.
The testimony communicates by analogy -- the motor-cup, the rain starting, the
cornering ants of half-remembered Feynman, "disposability everywhere is nihilism
with a runbook." The analogies are the data. A principle abstracted away from
the experience that earned it is a platitude. The scar tissue stays on purpose:
it is what marks these as earned rather than apple pie. The silliness is
load-bearing; it keeps the document from getting reverent about its own hard-won
wisdom, which is the one way a thing like this curdles.

There is a test for which parts are real:

> "Did it cost you something to learn? [...] Those are scar tissue, and scar
> tissue is never apple pie even when it phrases like it, because the phrasing
> is the compression of something that was expensive and non-obvious when you
> were inside it. The parts that are actually just pie are the ones you can't
> attach a scar to -- and notice you didn't generate many of those; nearly every
> principle here arrived attached to a specific failure." [KB, "is any of this
> just apple pie?"]

The test is self-applying: if a reader finds a principle here that arrived with
no scar attached, that is the candidate to promote to the editing room floor.
