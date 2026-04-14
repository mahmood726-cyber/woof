---
name: muelitpersoan-review
description: Multi-Evidence Lightweight Personal Assistant Review for TruthCert data pipelines. Use when evaluating open-access datasets, validating proof-carrying numbers, or performing E156 micro-paper audits.
---

# Muelitpersoan Review (TruthCert Edition)

This skill provides a specialized workflow for auditing "muelitpersoan" (Multi-Evidence Lightweight Personal) reviews of evidence-based data pipelines.

## Audit Workflow

1. **Verify Source Integrity**:
   - Ensure the dataset is strictly Open Access (OA).
   - Check if the source locator (URL/DOI) is provided and accessible.
   - Use `python` or `R` to verify file hashes if provided.

2. **TruthCert Calculation Audit**:
   - Manually verify the logic used to derive "proof-carrying" numbers.
   - Example: If a mortality rate is reported, check that `count(deaths) / count(total_records)` is calculated correctly and consistently.

3. **E156 Sentence Check**:
   - Confirm the micro-paper draft contains exactly 7 sentences.
   - Ensure the total word count is 156 or fewer.

## Script Usage

Use the provided scripts to automate validation tasks:
- `validate_oa.py`: Check if a dataset URI points to a known OA repository.
- `check_paper_stats.py`: Count sentences and words in E156 drafts.

## Protocol Standards

- **Fail-closed**: If a single number cannot be traced to its source with 100% certainty, the review MUST fail.
- **No secrets**: Any API keys or private tokens found during the review must be reported for immediate redaction.
