# Symbolica Source-Available License 1.0

**Copyright © 2023–2026 Ruijl Research and Symbolica contributors. All rights reserved.**

Symbolica is source-available software. Use is permitted only as expressly
stated in this License.

This License applies separately to each version of the Software with which it
is provided.

## 1. Definitions

**Software** means Symbolica and all source code, tests, benchmarks, examples,
documentation, comments, build files, and other repository material made
available with it by Ruijl Research. A file that expressly states a different
license is governed by that license.

**Source Materials** means the human-readable form of the Software and its
implementation-specific content.

**Binary Materials** means any object-code, compiled, executable, library,
bytecode, intermediate-representation, or other non-source form of Symbolica,
whether provided by Ruijl Research or produced from the Source Materials,
including shared or static libraries, executables, WebAssembly modules,
compiler intermediate representations, symbol information, and debugging
information.

**Derived Information** means implementation-specific information obtained,
extracted, inferred, reconstructed, summarized, translated, encoded, or
generated from the Source Materials or Binary Materials, or by observing,
tracing, probing, instrumenting, debugging, inspecting memory or runtime state,
profiling, reverse engineering, or otherwise examining the Software or its
behavior for the purpose of discovering implementation-specific information.
Derived Information includes reconstructed source code, pseudocode,
intermediate representations, algorithms, data structures, internal APIs,
heuristics, optimizations, implementation choices, and information describing
them.

Ordinary mathematical or computational output produced through authorized use
of Symbolica is not Derived Information solely because Symbolica produced it.
Information inferred from such output through systematic probing or analysis
for the purpose of discovering implementation-specific information may be
Derived Information.

**Competing Product** means any software, library, service, API, component,
functionality, or other offering that provides, or is intended to provide,
computer-algebra or symbolic-mathematics functionality substantially similar
to or substitutable for Symbolica. An offering or component may be a Competing
Product even if it is free, open source, used internally, written in another
language, or provided through a different interface. Software that merely uses
an authorized Symbolica installation under a separate valid license is not a
Competing Product for that reason alone.

**You** means the individual or legal entity exercising permissions under this
License. If You act for an employer, client, institution, or other
organization, You includes that organization.

## 2. Acceptance and limited permission

By exercising any permission granted under this License, You agree to its
terms.

All permissions granted by this License are conditioned on compliance with its
terms. To the extent this License forms a contract, Sections 3, 4, and 5 also
state contractual obligations independently of the scope of copyright or other
intellectual-property rights.

Subject to this License, You may:

1. inspect and evaluate the Source Materials;
2. make internal copies reasonably necessary to install, build, test, and use
   Symbolica under an applicable Symbolica runtime license;
3. make private modifications solely for Your authorized use of Symbolica;
4. investigate and responsibly report bugs or security issues; and
5. prepare changes for submission to Ruijl Research.

No other permission is granted except as expressly stated in this License.

## 3. Runtime licensing and integration

Each installation, execution, and deployment of Symbolica is governed by the
Symbolica runtime license or written agreement applicable to that use and,
where applicable, the associated plan terms. Information about currently
available runtime licenses and plans is published at
`https://symbolica.io/license/`.

You may link against, statically link, embed, bundle, or include an unmodified
copy of Symbolica as a dependency of another product, including as a Cargo
dependency, and may distribute that product.

Distribution under this Section does not grant or transfer runtime rights.
Before installing or executing Symbolica, each recipient must qualify under
applicable free-use terms, obtain an applicable paid runtime license, or be
covered by a written agreement with Ruijl Research.

With every distribution permitted by this Section, You must provide a complete
copy of this License, preserve all copyright, attribution, provenance, and
license notices, and state in documentation or other notices accompanying the
product that runtime rights are not included or transferred unless a separate
written agreement expressly provides otherwise.

If this License conflicts with a separate written agreement signed by Ruijl
Research and You, the signed agreement controls to the extent of the conflict.
Otherwise, this License governs access to, use of, and distribution of the
Source Materials and Binary Materials, and the applicable runtime terms govern
installation, execution, and deployment.

## 4. Prohibited uses

Except with Ruijl Research's express prior written permission, You may not:

1. distribute, publish, sublicense, mirror, or provide the Source Materials as
   a standalone source distribution or substitute for an official Symbolica
   distribution. This paragraph does not restrict viewing or in-service
   forking expressly authorized to users by the terms of the repository host;
2. distribute a modified version of Symbolica in any form, except by submitting
   changes to Ruijl Research as permitted by Section 2(5);
3. except to the extent reasonably necessary for activities expressly permitted
   by Sections 2(3), 2(4), and 2(5), reverse engineer, disassemble, decompile,
   decode, deobfuscate, lift, translate, reconstruct, instrument, attach a
   debugger to, trace, profile, inspect or dump memory or runtime state, inspect
   internal calls or data flows, or otherwise analyze the Binary Materials or
   running Software for the purpose of recovering or inferring source code,
   intermediate representations, algorithms, data structures, internal APIs,
   heuristics, optimizations, implementation choices, or other
   implementation-specific information, whether manually or using an automated
   tool, artificial-intelligence system, or other intermediary;
4. use the Software, Source Materials, Binary Materials, or Derived Information
   as a reference implementation, behavioral oracle, development blueprint, or
   other development input for the competing functionality of a Competing
   Product, including to select, design, implement, port, improve, repair, test,
   validate, benchmark, document, maintain, or optimize any computer-algebra or
   symbolic-mathematics algorithm, architecture, data structure, internal API,
   heuristic, optimization, test, or feature;
5. create or use any plan, roadmap, gap analysis, specification, prompt,
   ticket, dataset, test suite, benchmark, output comparison, or other
   intermediate material informed by the Software, Source Materials, Binary
   Materials, or Derived Information to develop or improve the competing
   functionality of a Competing Product;
6. cause or permit any employee, contractor, contributor, clean-room team,
   automated tool, artificial-intelligence system, or other intermediary to
   perform an act that You may not perform directly under this License;
7. bypass, disable, interfere with, or circumvent license checks, license keys,
   access controls, usage limits, core limits, instance limits, or other
   technical restrictions;
8. remove or obscure copyright, license, attribution, or provenance notices;
   or
9. use Symbolica names, marks, or branding in a manner that suggests
   endorsement or authorization.

Nothing in this Section prohibits independent development that does not use
the Source Materials, Binary Materials, or Derived Information, or use the
Software as a development input, and nothing in this License restricts any
right that applicable law does not permit to be restricted.

## 5. Artificial intelligence, machine learning, and text and data mining

Except with Ruijl Research's express prior written permission, You may not use
the Source Materials, Binary Materials, or Derived Information to:

1. train, pre-train, fine-tune, continue training, align, distill, or otherwise
   develop an artificial-intelligence or machine-learning model;
2. create or augment a training corpus, dataset, synthetic dataset, benchmark,
   evaluation set, embedding collection, vector database, retrieval index, or
   retrieval-augmented-generation system;
3. use an artificial-intelligence or machine-learning system to analyze,
   reverse engineer, disassemble, decompile, decode, deobfuscate, reconstruct,
   instrument, trace, profile, inspect or dump memory or runtime state, explain,
   summarize, or otherwise recover or infer implementation-specific
   information from the Source Materials, Binary Materials, or running
   Software;
4. submit Source Materials, Binary Materials, or Derived Information to a
   service if, under the applicable terms or settings, the service may use or
   retain them for training, model improvement unrelated to Your authorized
   use, unrelated analysis, or disclosure to another party.

You may use an AI coding assistant solely to make changes otherwise permitted
by Section 2, provided that, under the applicable terms and settings, the
provider is not permitted to use or retain the Source Materials or Binary
Materials for training or unrelated purposes and the use does not assist a
Competing Product. This exception does not permit an act prohibited by Section
4 except to the extent that Section 4 itself expressly permits that act.

Ruijl Research expressly reserves all rights for text and data mining,
including under Article 4(3) of Directive (EU) 2019/790 and corresponding
laws.

## 6. Ownership and reserved rights

The Software is licensed, not sold. Ruijl Research and other applicable rights
holders retain their respective copyright, patent, and other rights in the
Software. Ruijl Research retains its trademark rights in the Symbolica names
and branding.

No patent or trademark license is granted.

## 7. Termination and no waiver

Permissions under this License terminate automatically upon breach. After
termination, You must immediately stop the affected use and delete copies made
under this License that are in Your possession or control, except where
retention is required by law. Ruijl Research may reinstate permissions in
writing.

Failure or delay in enforcing a term is not a waiver. Termination does not
affect any accrued right, claim, or remedy.

Sections 4 and 5 survive termination with respect to Source Materials, Binary
Materials, and Derived Information obtained before termination. Sections 6,
7, 8, and 9 also survive termination.

## 8. Warranty and liability

To the maximum extent permitted by law, the Software is provided **"as is"**
and **"as available,"** without warranty or condition of any kind, express,
implied, or statutory.

To the maximum extent permitted by law, Ruijl Research is not liable for any
direct, indirect, incidental, special, consequential, exemplary, or punitive
damages, or for loss of profits, revenue, data, goodwill, business, or
opportunity, arising from the Software or this License.

Where liability cannot be excluded, aggregate liability is limited to the
amount paid directly to Ruijl Research for Symbolica during the twelve months
preceding the event giving rise to the claim.

Nothing in this Section excludes or limits liability to the extent that such
exclusion or limitation is prohibited by applicable law.

## 9. Governing law

This License is governed by Swiss law, excluding its conflict-of-law rules and
the United Nations Convention on Contracts for the International Sale of
Goods.

Subject to mandatory law, the courts of the Canton of Zug, Switzerland, have
exclusive jurisdiction.

If a provision is unenforceable, it will be enforced to the maximum extent
permitted, and the remaining provisions remain effective.

## 10. Separate permission

Requests for permissions or arrangements beyond those granted by this License,
including special commercial, academic, OEM, redistribution, or source-use
permissions, may be sent to `license@symbolica.io`.
