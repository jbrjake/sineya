# Academic Foundations

Research citations backing the recommendations in this skill. Read when deciding between competing approaches and needing empirical evidence, or when designing evaluation criteria for skill quality.

---

## Instruction Compliance

**Testable constraints produce effect size d = −7.84**
"Prompt Strategies for Style Control in Multi-Turn LLM Code Generation" (Nov 2025, arxiv 2511.13972). Compared multiple prompting strategies. Imperative directives with testable conditions produced the strongest compliance. Models tend toward verbosity under weak constraint.

**Persuasion techniques double compliance from 33% to 72%**
Meincke et al. (2025). Tested seven Cialdini persuasion principles across 28,000 LLM conversations. Authority, commitment/consistency, and scarcity framing were most effective (p < .001).

**~150–200 instruction ceiling with linear decay**
Jaroslawicz et al. (2025). Frontier models follow approximately 150–200 instructions before compliance drops. Smaller models show exponential decay. System prompts consume ~50 slots.

**Positive framing cuts violations ~50%**
Practitioner testing by @docat0209 (DEV Community, 2026). Flipping 10 negative rules to positive equivalents halved violation rates.

**Recursive self-reference prevents rule forgetting**
@SiddhantKCode (DEV Community, 2026). Adding "display all N rules at start of every response" inside a numbered rule list creates a persistence loop. Without it, rules forgotten by turn 4–5. With it, rules persist indefinitely. ~50–100 extra tokens/response. Confirmed across Claude, GPT, Gemini.

---

## Context Window and Positioning

**Effective window is drastically smaller than advertised**
"Maximum Effective Context Window" (Sep 2025, arxiv 2509.21361). Some top models failed with as few as 100 tokens in context. Most showed severe degradation by 1,000 tokens.

**Positional biases shift dynamically with fill ratio**
"Positional Biases Shift as Inputs Approach Context Window Limits" (Aug 2025, arxiv 2508.07479). At low fill: primacy bias dominates. As window fills: recency bias strengthens. Middle instructions always weakest. Quantitative measures: LiMi, PriMi, ReCi.

**Token cost grows quadratically with conversation turns**
"More with Less" (ICSE 2026, arxiv 2510.16786). History replay causes quadratic growth. Dynamic turn-limiting strategies reduce costs 12–24% with comparable solve rates.

**60% context utilization is the practical maximum**
Community convergence. Quality degradation starts at 20–40% fill. Fresh sessions burn ~20K tokens on system prompt + tools + CLAUDE.md.

---

## Structured Output vs Reasoning

**Structured formats degrade reasoning up to 40%**
"Let Me Speak Freely? A Study on the Impact of Format Restrictions on Performance of Large Language Models" (EMNLP 2024 Industry Track, arxiv 2408.02442). JSON, XML, YAML constraints significantly hurt reasoning. Classification tasks improved. Performance varied up to 40% by template.

**Format impact is real, not measurement artifact**
"Quantifying the Impact of Structured Output Format on Large Language Models through Causal Inference" (Sep 2025, arxiv 2509.21791). Used causal inference to confirm format restrictions causally degrade reasoning, resolving conflicting prior results.

**Practical rule:** Use structured formats for control flow/classification. Use freeform prose for reasoning/analysis.

---

## Multi-Agent Orchestration

**Multi-agent achieves 100% actionable rate vs 1.7% single-agent**
Drammeh, "Multi-Agent LLM Orchestration Achieves Deterministic, High-Quality Decision Support" (Nov 2025, arxiv 2511.15755). 348 controlled trials. 80x improvement in action specificity. 140x improvement in solution correctness. Similar latency (~40s).

**Shared-blackboard orchestration with counterexample repair**
MACOG (Oct 2025, arxiv 2510.03902). 8 specialized agents, finite-state orchestrator, grammar-constrained decoding. LLM-judge scores from 64.15 to 87.52 on IaC tasks. Counterexample-guided repair loops outperform description-only feedback.

**Conditional section loading and tool restriction**
OpenDev (March 2026, arxiv 2603.05344). From a production terminal coding agent. Behavioral instructions as independent files with predicates. Sharing all tools caused "context pollution and role confusion." Explicit stop conditions with anti-loop instructions.

**Graph-structured interactions outperform trees**
Puppeteer paradigm (May 2025, arxiv 2505.19591). RL-trained orchestration naturally evolves from tree to graph structures — cyclic, compact, reduced cost. Skills should allow cycles (retry, review-and-revise), not force linear pipelines.

---

## Self-Correction and Verification

**Naive self-correction can degrade performance**
"Can LLMs Correct Themselves?" (CorrectBench, Oct 2025, arxiv 2510.16062). Only reasoning LLMs with integrated verification showed consistent improvement. Prompting-based self-correction unreliable.

**Prompting-based methods don't transfer to production**
"Self-Correcting Code Generation Using Small Language Models" (May 2025, arxiv 2505.23060). Methods demonstrated on proprietary LLMs do not transfer well without strong external feedback.

**Formal verification catches 83% correct, 92% incorrect**
Astrogator (July 2025, arxiv 2507.13290). Formal Query Language for user intent specification. Principle: formal specs before verification.

**Practical rule:** Every verification step must use external evidence (compiler, tests, linter). Self-review without external signal is unreliable.

---

## Reasoning Scaffolds

**Chain of Draft: ~5 words per step, comparable quality**
"Chain of Draft" (Feb 2025, arxiv 2502.18600). Limits each reasoning step to ~5 words. Comparable or better performance to full CoT with dramatically fewer tokens.

**Overthinking degrades code generation**
"Uncertainty-Guided Chain-of-Thought" (March 2025, arxiv 2503.15341). Excessive reasoning steps hurt. Selective CoT only when uncertainty is high.

**Matrix of Thought: 14.4% of baseline reasoning time**
"Chain or tree? Re-evaluating complex reasoning" (Sep 2025, arxiv 2509.03918). Explores horizontal and vertical dimensions simultaneously. Eliminates redundancy via column-cell communication.

**Practical rule:** Reasoning scaffolds should be conditional — match depth to task complexity. Simple tasks: skip. Complex tasks: ultrathink. Uncertain tasks: cap at 3 deliberation cycles.

---

## Meta-Prompting and Skill Evolution

**Recursive Meta Prompting reduces token requirements**
Zhang et al. (updated 2025, arxiv 2311.11482). Uses type theory to map tasks to structured prompts. LLMs autonomously generate new prompts recursively.

**Evolutionary optimization outperforms manual engineering**
DEEVO (June 2025, arxiv 2506.00178). Multi-agent debate as fitness function. Outperforms manual prompt engineering without ground truth feedback.

**Model-specific meta-prompting: up to 19% improvement**
MPCO (Aug 2025, arxiv 2508.01443). Automatically generates prompts optimized for specific models. 96% of top optimizations from meaningful edits. Any LLM can serve as meta-prompter.

**Practical rule:** Skills should be evolvable. Include evaluation criteria and pressure tests that enable automated refinement, not just static text. Use the skill-creator's optimization loop to evolve descriptions for triggering accuracy.

---

## Knowledge Gap Analysis

**44.6% of prompts in ineffective conversations contain knowledge gaps**
"Towards Detecting Prompt Knowledge Gaps" (Jan 2025, arxiv 2501.11709). 433 developer-ChatGPT conversations. Four gap types: Missing Context (12.3%), Missing Specifications (15.8%), Multiple Context (8.1%), Unclear Instructions (8.4%). Effective conversations: only 12.6% gap rate.

**Practical rule:** Audit every skill section for all four gap types. Any gap is a compliance failure waiting to happen.
