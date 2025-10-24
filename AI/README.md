# EmbedThis Updater - AI Documentation

## Overview

This directory contains structured project documentation to assist Claude Code and developers in understanding and working with the EmbedThis Updater project.

## Directory Structure

```
AI/
├── README.md           # This file
├── context/            # Saved context for in-progress tasks
├── designs/            # Design documentation
│   └── DESIGN.md       # Design index and overview
├── plans/              # Project plans
│   └── PLAN.md         # Current project plan and status
├── procedures/         # Development procedures
│   └── PROCEDURE.md    # Standard operating procedures
├── logs/               # Project logs and changelog
│   └── CHANGELOG.md    # Chronological change history
├── references/         # External references
│   └── REFERENCES.md   # Useful links and resources
└── archive/            # Historical documentation
    ├── designs/        # Archived design documents
    ├── plans/          # Archived plans
    ├── procedures/     # Archived procedures
    └── logs/           # Archived logs
```

## Quick Start

### For Claude Code

When working on the EmbedThis Updater project:

1. **Understanding the project**: Read [designs/DESIGN.md](designs/DESIGN.md)
2. **Current status**: Check [plans/PLAN.md](plans/PLAN.md)
3. **How to build/test**: Refer to [procedures/PROCEDURE.md](procedures/PROCEDURE.md)
4. **Recent changes**: Review [logs/CHANGELOG.md](logs/CHANGELOG.md)
5. **External resources**: Browse [references/REFERENCES.md](references/REFERENCES.md)

### For Developers

1. Start with [../README.md](../README.md) for user-facing documentation
2. Review [../doc/DESIGN.md](../doc/DESIGN.md) for detailed technical design
3. Follow procedures in [procedures/PROCEDURE.md](procedures/PROCEDURE.md)
4. Check [plans/PLAN.md](plans/PLAN.md) for current work items

## Documentation Files

### designs/DESIGN.md

Index and overview of design documentation. Links to the main design document at `doc/DESIGN.md` which contains:
- Architecture overview
- Implementation details for C, JavaScript, and Shell versions
- Security model and considerations
- Protocol specifications
- Testing strategies

### plans/PLAN.md

Current project plan including:
- Project status and recent completions
- Active work items
- Future enhancements (not scheduled)
- Development guidelines
- Success metrics

### procedures/PROCEDURE.md

Standard operating procedures for:
- Building the project
- Running tests
- Formatting code
- Creating git commits
- Updating documentation
- Security reviews
- Release process

### logs/CHANGELOG.md

Chronological record of changes in reverse order:
- Features and improvements
- Bug fixes
- Test additions
- Documentation updates
- Security enhancements

### references/REFERENCES.md

Useful external references:
- Official documentation links
- Related projects
- Technical standards
- Development tools
- Learning resources

## Maintenance Guidelines

### Updating Documentation

After making significant changes to the project:

1. **Update designs/**: Reflect architectural changes
2. **Update plans/**: Update status and current work
3. **Update procedures/**: Document new processes
4. **Update logs/CHANGELOG.md**: Record the change
5. **Update references/**: Add new useful resources

### Archiving Documentation

When documentation becomes obsolete:

1. Move to appropriate `archive/` subdirectory
2. Add date and reason for archival
3. Update index files to remove references
4. Keep for historical context

### Context Directory

The `context/` directory is for:
- Saving work-in-progress context
- Temporary planning documents
- Task-specific notes
- Implementation summaries for completed work

Recent context documents:
- [quiet-mode-implementation.md](context/quiet-mode-implementation.md) - October 2025 quiet mode feature

Clean up context files when tasks are completed or archive when they become historical reference.

## Integration with Main Documentation

This `AI/` directory complements the main project documentation:

- **README.md** (root): User-facing documentation and getting started
- **CLAUDE.md** (root): Claude Code guidance and conventions
- **doc/DESIGN.md**: Detailed technical design document
- **Man page**: Command-line reference

The `AI/` directory provides structured context specifically for AI-assisted development and project management.

## Best Practices

### For Claude Code

1. **Read before acting**: Review relevant documentation before making changes
2. **Update after changes**: Modify documentation to reflect changes
3. **Follow procedures**: Adhere to documented procedures
4. **Track changes**: Update CHANGELOG.md
5. **Maintain consistency**: Keep all documents synchronized

### For Developers

1. **Keep current**: Update documentation as you work
2. **Be specific**: Provide clear, actionable information
3. **Use markdown**: Format documentation properly
4. **Link appropriately**: Cross-reference related documents
5. **Archive old content**: Don't delete, move to archive/

## Version Control

All `AI/` documentation should be:
- Committed to version control
- Updated with code changes
- Reviewed in pull requests
- Kept synchronized across branches

## Security Note

Do not store sensitive information in `AI/` documentation:
- No API keys or tokens
- No passwords or credentials
- No private endpoints
- No proprietary algorithms

Security-sensitive information should be documented in general terms with references to secure storage locations.

## Support

For questions about:
- **Project architecture**: See designs/DESIGN.md
- **Build/test procedures**: See procedures/PROCEDURE.md
- **Current status**: See plans/PLAN.md
- **External resources**: See references/REFERENCES.md

---

Last Updated: 2025-10-15
