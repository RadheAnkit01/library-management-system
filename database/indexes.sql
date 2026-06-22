-- Purpose ->
-- Improve query performance.

-- ============================================================
-- Library Management System — Indexes (PostgreSQL)
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- BOOK indexes
-- ────────────────────────────────────────────────────────────

-- Faster search by book title (full-text or LIKE queries)
CREATE INDEX idx_book_title
    ON book (title);

-- Filter / group books by category
CREATE INDEX idx_book_category
    ON book (category);

-- Join optimization: book → publisher
CREATE INDEX idx_book_pub_id
    ON book (pub_id);

-- ────────────────────────────────────────────────────────────
-- WRITES index
-- ────────────────────────────────────────────────────────────

-- Lookup all books written by a given author
CREATE INDEX idx_writes_author_id
    ON writes (author_id);

-- Lookup all authors of a given book
CREATE INDEX idx_writes_book_id
    ON writes (book_id);

-- ────────────────────────────────────────────────────────────
-- COPY indexes
-- ────────────────────────────────────────────────────────────

-- Find all copies of a specific book
CREATE INDEX idx_copy_book_id
    ON copy (book_id);

-- Filter copies by availability status
CREATE INDEX idx_copy_status
    ON copy (status);

-- Filter available copies
CREATE INDEX idx_copy_available
    ON copy (available);

-- ────────────────────────────────────────────────────────────
-- MEMBER indexes
-- ────────────────────────────────────────────────────────────

-- Search members by name
CREATE INDEX idx_member_name
    ON member (name);

-- Filter expired / active memberships
CREATE INDEX idx_member_expiry
    ON member (expiry_date);

-- ────────────────────────────────────────────────────────────
-- ISSUE indexes
-- ────────────────────────────────────────────────────────────

-- All issues for a given member
CREATE INDEX idx_issue_member_id
    ON issue (member_id);

-- All issues against a specific copy
CREATE INDEX idx_issue_copy_id
    ON issue (copy_id);

-- Overdue detection: filter by due_date where not yet returned
CREATE INDEX idx_issue_due_date
    ON issue (due_date)
    WHERE return_date IS NULL;

-- Fine analysis
CREATE INDEX idx_issue_fine
    ON issue (fine)
    WHERE fine > 0;

-- Date-range queries on issue_date
CREATE INDEX idx_issue_date
    ON issue (issue_date);

-- ============================================================
-- End of indexes.sql
-- ============================================================