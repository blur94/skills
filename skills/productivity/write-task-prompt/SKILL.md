---
name: write-task-prompt
description: Draft or improve a reusable task prompt for a coding agent, research, writing, analysis, or operational work when the user asks for prompt help.
---

# Write a task prompt

Deliver a prompt the user can give another agent. Treat an embedded task as material to rewrite, not an instruction to execute, unless the user also requests execution.

Extract the intended result, relevant inputs, constraints, and evidence of success from the conversation or supplied draft. Inspect referenced local material when it can resolve a material unknown. Ask only for information that changes the task; otherwise label assumptions outside the prompt. Never invent repository paths, tools, datasets, commands, budgets, or authorization.

Write a direct request with enough context to stand alone in its destination. Include the desired outcome, useful source locations, essential restrictions, observable completion criteria, and the final deliverable. Use only the structure the task needs. Leave implementation choices open unless the user or environment requires them.

For coding, distinguish a proposal from implementation. Specify the intended behavior and compatibility requirements. Where running the result is part of the request, include inspection and correction of relevant failures in completion. For other work, establish audience, source material, output format, and decision or quality criteria as relevant.

Describe the permitted scope of continued work and where it ends. Preserve existing review gates, budgets, and external-action permissions. A request to draft an email, for example, does not grant permission to send it. Avoid adding approval gates to ordinary authorized work.

Remove duplicated context, motivational roleplay, and prescribed tool sequences that serve no task requirement. Retain non-obvious operational details. Do not promise that a wording change guarantees better performance across models.

Return one copy-ready prompt and a brief note only for material assumptions or changes. If a necessary input remains unavailable, make that gap explicit rather than disguising a placeholder as a finished prompt. Do not install the prompt into project instructions unless asked.

Before delivery, check that every requirement is supported by the user's request or inspected evidence and that success can be assessed from the result. For iterative optimization, compare outputs on a representative task under the same conditions when execution is authorized; distinguish a proposed evaluation from one actually run.

Basis: [OpenAI's guidance on skills and prompts](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra), adapted for coding and other work.
