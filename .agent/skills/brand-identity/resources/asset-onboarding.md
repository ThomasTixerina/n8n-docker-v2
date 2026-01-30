---
name: onboarding-brand-assets
description: Instructions for checking, processing, and integrating new brand assets (PDFs, Images) into the brand-identity skill.
---

# Brand Asset Onboarding Instructions

Use this guide when the user wants to provide new visual references (PDFs of websites, images of specialized designs) to update the `brand-identity` skill.

## 1. File Formats & Locations

To ensure the AI agents can read your design references effectively, please follow these formats:

### Images (Logos, UI Screenshots, Mockups)
*   **Format**: `.png` or `.jpg` (High contrast preferred).
*   **Location**: Place them in `.agent/skills/brand-identity/resources/images/`.
*   **Naming**: Use descriptive kebab-case names, e.g., `landing-page-inspiration.png`, `logo-primary.png`.

### PDFs (Website Exports, Brand Guidelines)
*   **Format**: Standard `.pdf` (Text selectable is best, but visual scans work too).
*   **Location**: Place them in `.agent/skills/brand-identity/resources/references/`.
*   **Naming**: e.g., `competitor-analysis.pdf`, `moodboard-v1.pdf`.

## 2. Process for Updating the Skill

Once you have placed the files in the directories above, tell me:
> *"He subido nuevos assets en resources. Por favor actualiza los tokens de diseño."*

I will then perform the following steps:

1.  **Analyze Visuals**: I will look at the new images/PDFs to extract:
    *   Primary and Secondary Colors (Hex Codes).
    *   Typography styles (Header vs Body fonts).
    *   Layout patterns (Spacing, Radii).
2.  **Update `design-tokens.json`**: I will insert these new values into your machine-readable token file.
3.  **Refine `voice-tone.md`**: If the PDFs contain copy, I will analyze the writing style and update the voice guidelines.

## 3. Checklist for User
Copy this checklist to track your uploads:

- [ ] Create folder: `.agent/skills/brand-identity/resources/images/`
- [ ] Create folder: `.agent/skills/brand-identity/resources/references/`
- [ ] **Upload Image 1**: (e.g., `hero-section-style.png`) -> `.../images/`
- [ ] **Upload PDF 1**: (e.g., `clean-medical-design.pdf`) -> `.../references/`
- [ ] **Notify Agent**: Tell me to "Ingerir y actualizar identidad de marca".
