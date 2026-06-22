-- Purpose ->
-- Contains database views.

--Purpose ->
--Contains database views.

-- ============================================================
-- Library Management System — Views (PostgreSQL)
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- VIEW 1: vw_book_details
-- Complete book information including author(s) and publisher
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_book_details AS
SELECT
    b.book_id,
    b.title,
    b.category,
    b.price,
    STRING_AGG(a.name, ', ' ORDER BY a.name) AS authors,
    p.name  AS publisher_name,
    p.address AS publisher_address
FROM book b
JOIN publisher p ON b.pub_id    = p.pub_id
JOIN writes   w ON b.book_id    = w.book_id
JOIN author   a ON w.author_id  = a.author_id
GROUP BY b.book_id, b.title, b.category, b.price,
         p.name, p.address;

-- Usage:
-- SELECT * FROM vw_book_details WHERE category = 'Fiction';

-- ────────────────────────────────────────────────────────────
-- VIEW 2: vw_available_books
-- Books that have at least one available copy right now
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_available_books AS
SELECT
    b.book_id,
    b.title,
    b.category,
    b.price,
    COUNT(c.copy_id)                                 AS total_copies,
    COUNT(c.copy_id) FILTER (WHERE c.available)      AS available_copies,
    MIN(c.shelf_no)                                  AS shelf_location
FROM book b
JOIN copy c ON b.book_id = c.book_id
GROUP BY b.book_id, b.title, b.category, b.price
HAVING COUNT(c.copy_id) FILTER (WHERE c.available) > 0;

-- Usage:
-- SELECT * FROM vw_available_books ORDER BY title;

-- ────────────────────────────────────────────────────────────
-- VIEW 3: vw_active_issues
-- All currently active (unreturned) issue records
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_active_issues AS
SELECT
    i.issue_id,
    m.name                       AS member_name,
    m.address                    AS member_address,
    b.title                      AS book_title,
    b.category,
    c.copy_id,
    c.shelf_no,
    i.issue_date,
    i.due_date,
    CURRENT_DATE - i.due_date    AS days_overdue,
    CASE
        WHEN CURRENT_DATE > i.due_date
        THEN (CURRENT_DATE - i.due_date) * 5
        ELSE 0
    END                          AS estimated_fine
FROM issue  i
JOIN member m ON i.member_id = m.member_id
JOIN copy   c ON i.copy_id   = c.copy_id
JOIN book   b ON c.book_id   = b.book_id
WHERE i.return_date IS NULL;

-- Usage:
-- SELECT * FROM vw_active_issues WHERE days_overdue > 0;

-- ────────────────────────────────────────────────────────────
-- VIEW 4: vw_member_history
-- Complete borrowing history per member
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_member_history AS
SELECT
    m.member_id,
    m.name           AS member_name,
    m.expiry_date,
    CASE
        WHEN m.expiry_date >= CURRENT_DATE THEN 'Active'
        ELSE 'Expired'
    END              AS membership_status,
    b.title          AS book_title,
    i.issue_date,
    i.due_date,
    i.return_date,
    CASE
        WHEN i.return_date IS NULL            THEN 'Not Returned'
        WHEN i.return_date <= i.due_date      THEN 'On Time'
        ELSE 'Late'
    END              AS return_status,
    i.fine
FROM member m
LEFT JOIN issue i ON m.member_id = i.member_id
LEFT JOIN copy  c ON i.copy_id   = c.copy_id
LEFT JOIN book  b ON c.book_id   = b.book_id;

-- Usage:
-- SELECT * FROM vw_member_history WHERE member_name = 'Aarav Sharma';

-- ────────────────────────────────────────────────────────────
-- VIEW 5: vw_overdue_books
-- Books that are overdue (past due_date, not yet returned)
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_overdue_books AS
SELECT
    i.issue_id,
    m.name                      AS member_name,
    b.title                     AS book_title,
    c.copy_id,
    i.issue_date,
    i.due_date,
    CURRENT_DATE - i.due_date   AS days_overdue,
    (CURRENT_DATE - i.due_date) * 5 AS fine_accrued
FROM issue  i
JOIN member m ON i.member_id = m.member_id
JOIN copy   c ON i.copy_id   = c.copy_id
JOIN book   b ON c.book_id   = b.book_id
WHERE i.return_date IS NULL
  AND i.due_date < CURRENT_DATE
ORDER BY days_overdue DESC;

-- Usage:
-- SELECT * FROM vw_overdue_books;

-- ────────────────────────────────────────────────────────────
-- VIEW 6: vw_publisher_catalog
-- Publisher with their book count and category breakdown
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_publisher_catalog AS
SELECT
    p.pub_id,
    p.name           AS publisher_name,
    p.address,
    COUNT(b.book_id)  AS total_books,
    STRING_AGG(DISTINCT b.category, ', ') AS categories,
    ROUND(AVG(b.price), 2) AS avg_book_price,
    SUM(b.price)      AS catalog_value
FROM publisher p
LEFT JOIN book b ON p.pub_id = b.pub_id
GROUP BY p.pub_id, p.name, p.address;

-- Usage:
-- SELECT * FROM vw_publisher_catalog ORDER BY total_books DESC;

-- ────────────────────────────────────────────────────────────
-- VIEW 7: vw_fine_summary
-- Summary of fines per member
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_fine_summary AS
SELECT
    m.member_id,
    m.name           AS member_name,
    COUNT(i.issue_id)            AS total_borrows,
    COUNT(i.issue_id) FILTER (WHERE i.fine > 0) AS late_returns,
    COALESCE(SUM(i.fine), 0)     AS total_fine_paid,
    COALESCE(MAX(i.fine), 0)     AS max_single_fine
FROM member m
LEFT JOIN issue i ON m.member_id = i.member_id
GROUP BY m.member_id, m.name
ORDER BY total_fine_paid DESC;

-- Usage:
-- SELECT * FROM vw_fine_summary WHERE total_fine_paid > 0;

-- ────────────────────────────────────────────────────────────
-- VIEW 8: vw_copy_status_summary
-- Per-book summary of copy statuses
-- ────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_copy_status_summary AS
SELECT
    b.book_id,
    b.title,
    b.category,
    COUNT(c.copy_id)                                          AS total_copies,
    COUNT(c.copy_id) FILTER (WHERE c.status = 'Available')   AS available,
    COUNT(c.copy_id) FILTER (WHERE c.status = 'Issued')      AS issued,
    COUNT(c.copy_id) FILTER (WHERE c.status = 'Damaged')     AS damaged,
    COUNT(c.copy_id) FILTER (WHERE c.status = 'Lost')        AS lost
FROM book b
LEFT JOIN copy c ON b.book_id = c.book_id
GROUP BY b.book_id, b.title, b.category;

-- Usage:
-- SELECT * FROM vw_copy_status_summary WHERE issued > 0;

-- ============================================================
-- End of views.sql
-- ============================================================