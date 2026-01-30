# Implementation Plan: Iterative MiConsul Modernization & n8n Integration

This plan follows an iterative approach to modernize the MiConsul platform and integrate it with n8n, focusing on one module at a time for better interactivity and rapid feedback.

## Phase 1: Loyalty Workflow (Fidelización)
- **Goal**: Successfully trigger a loyalty event from the PHP app to n8n and send an automated message.
- [ ] **Task 1.1**: Fix n8n Trigger configuration for "Fidelización: Pacientes Nuevos".
    - Address the "Missing Table" error identified in n8n.
    - Verify connection to the remote MySQL database.
- [ ] **Task 1.2**: Implement PHP Webhook Trigger.
    - Identify the specific legacy PHP file responsible for new sales.
    - Insert a call to the new `Webhook::trigger()` helper.
- [ ] **Task 1.3**: Testing & Validation.
    - Simulate a sale in the legacy system.
    - Verify the n8n workflow receives the data and processes the "First Sale" logic.

## Phase 2: Data Accessibility (Internal API)
- **Goal**: Allow n8n to query complex data securely from the legacy database.
- [ ] **Task 2.1**: Refine `api/n8n.php`.
    - Add specific SQL queries for patient history and doctor availability.
- [ ] **Task 2.2**: Integration Test.
    - Use n8n to pull a list of daily sales via the API.

## Phase 3: Robustness & Security
- **Goal**: Finalize Phase 2 of the modernization plan (Sanitization & Variables).
- [ ] **Task 3.1**: Monitor Logs.
    - Check for any PHP errors related to the new PDO connection or sanitization.
- [ ] **Task 3.2**: Variable Cleanup.
    - Ensure all secrets are moved to the `.env` file on the server.

---
**Status**: Currently starting Task 1.1.
