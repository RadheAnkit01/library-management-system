-- Purpose ->
-- Contains all required SQL queries.

-- Must Include 
-- - Join
-- - Nested Query
-- - Aggregate Function
-- - GROUP BY
-- - HAVING

-- ============================================================
-- Library Management System — SQL Queries (PostgreSQL)
-- Covers: JOINs, Subqueries, Aggregates, GROUP BY, HAVING
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- SECTION 1: BASIC RETRIEVAL QUERIES
-- ────────────────────────────────────────────────────────────

-- Q1: List all books with their publisher names
SELECT
    b.book_id,
    b.title,
    b.category,
    b.price,
    p.name  AS publisher_name,
    p.address AS publisher_address
FROM book b
JOIN publisher p ON b.pub_id = p.pub_id
ORDER BY b.title;

-- Q2: List all available copies with their book titles
SELECT
    c.copy_id,
    b.title         AS book_title,
    c.shelf_no,
    c.status,
    c.available
FROM copy c
JOIN book b ON c.book_id = b.book_id
WHERE c.available = TRUE
ORDER BY b.title;

-- Q3: List all authors along with the books they have written
SELECT
    a.author_id,
    a.name       AS author_name,
    b.title      AS book_title,
    b.category,
    b.price
FROM author a
JOIN writes w ON a.author_id = w.author_id
JOIN book   b ON w.book_id   = b.book_id
ORDER BY a.name, b.title;

-- Q4: List all members whose membership is still active
SELECT
    member_id,
    name,
    address,
    memb_date,
    expiry_date
FROM member
WHERE expiry_date >= CURRENT_DATE
ORDER BY expiry_date;

-- ────────────────────────────────────────────────────────────
-- SECTION 2: JOIN QUERIES
-- ────────────────────────────────────────────────────────────

-- Q5: Full issue detail — member, copy, book, and fine info
SELECT
    i.issue_id,
    m.name          AS member_name,
    b.title         AS book_title,
    c.copy_id,
    c.shelf_no,
    i.issue_date,
    i.due_date,
    i.return_date,
    i.fine,
    CASE
        WHEN i.return_date IS NULL THEN 'Not Returned'
        WHEN i.return_date > i.due_date THEN 'Returned Late'
        ELSE 'Returned On Time'
    END AS return_status
FROM issue  i
JOIN member m  ON i.member_id = m.member_id
JOIN copy   c  ON i.copy_id   = c.copy_id
JOIN book   b  ON c.book_id   = b.book_id
ORDER BY i.issue_date DESC;

-- Q6: Books currently issued (not yet returned) with borrower info
SELECT
    b.title       AS book_title,
    m.name        AS borrowed_by,
    i.issue_date,
    i.due_date,
    CURRENT_DATE - i.due_date AS days_overdue
FROM issue  i
JOIN member m ON i.member_id = m.member_id
JOIN copy   c ON i.copy_id   = c.copy_id
JOIN book   b ON c.book_id   = b.book_id
WHERE i.return_date IS NULL
ORDER BY i.due_date;

-- Q7: LEFT JOIN — All books, showing if any copy is currently issued
SELECT
    b.book_id,
    b.title,
    b.category,
    COUNT(c.copy_id) AS total_copies,
    SUM(CASE WHEN c.status = 'Available' THEN 1 ELSE 0 END) AS available_copies,
    SUM(CASE WHEN c.status = 'Issued'    THEN 1 ELSE 0 END) AS issued_copies
FROM book b
LEFT JOIN copy c ON b.book_id = c.book_id
GROUP BY b.book_id, b.title, b.category
ORDER BY b.title;

-- Q8: INNER JOIN — Members who have borrowed at least one book with fine
SELECT DISTINCT
    m.member_id,
    m.name        AS member_name,
    m.address
FROM member m
INNER JOIN issue i ON m.member_id = i.member_id
WHERE i.fine > 0
ORDER BY m.name;

-- Q9: 3-table JOIN — Author → Book → Publisher
SELECT
    a.name        AS author_name,
    b.title       AS book_title,
    p.name        AS publisher_name,
    b.price
FROM author a
JOIN writes    w ON a.author_id = w.author_id
JOIN book      b ON w.book_id   = b.book_id
JOIN publisher p ON b.pub_id    = p.pub_id
ORDER BY a.name, b.title;

-- ────────────────────────────────────────────────────────────
-- SECTION 3: AGGREGATE FUNCTIONS
-- ────────────────────────────────────────────────────────────

-- Q10: Total number of books per category
SELECT
    category,
    COUNT(*)              AS total_books,
    ROUND(AVG(price), 2)  AS avg_price,
    MIN(price)            AS min_price,
    MAX(price)            AS max_price,
    SUM(price)            AS total_value
FROM book
GROUP BY category
ORDER BY total_books DESC;

-- Q11: Total fine collected per member
SELECT
    m.member_id,
    m.name         AS member_name,
    COUNT(i.issue_id)     AS total_borrows,
    SUM(i.fine)           AS total_fine_paid
FROM member m
LEFT JOIN issue i ON m.member_id = i.member_id
GROUP BY m.member_id, m.name
ORDER BY total_fine_paid DESC NULLS LAST;

-- Q12: Number of books per publisher
SELECT
    p.name         AS publisher_name,
    COUNT(b.book_id) AS book_count,
    SUM(b.price)     AS total_catalog_value
FROM publisher p
LEFT JOIN book b ON p.pub_id = b.pub_id
GROUP BY p.pub_id, p.name
ORDER BY book_count DESC;

-- Q13: Number of books written per author
SELECT
    a.name         AS author_name,
    COUNT(w.book_id) AS books_written
FROM author a
LEFT JOIN writes w ON a.author_id = w.author_id
GROUP BY a.author_id, a.name
ORDER BY books_written DESC;

-- ────────────────────────────────────────────────────────────
-- SECTION 4: GROUP BY AND HAVING
-- ────────────────────────────────────────────────────────────

-- Q14: Publishers who have published more than 2 books
SELECT
    p.name          AS publisher_name,
    COUNT(b.book_id) AS book_count
FROM publisher p
JOIN book b ON p.pub_id = b.pub_id
GROUP BY p.pub_id, p.name
HAVING COUNT(b.book_id) > 2
ORDER BY book_count DESC;

-- Q15: Authors who have co-authored at least 2 books
SELECT
    a.name           AS author_name,
    COUNT(w.book_id)  AS total_books
FROM author a
JOIN writes w ON a.author_id = w.author_id
GROUP BY a.author_id, a.name
HAVING COUNT(w.book_id) >= 2
ORDER BY total_books DESC;

-- Q16: Members who have borrowed more than 3 books
SELECT
    m.name            AS member_name,
    COUNT(i.issue_id)  AS borrow_count,
    SUM(i.fine)        AS total_fines
FROM member m
JOIN issue i ON m.member_id = i.member_id
GROUP BY m.member_id, m.name
HAVING COUNT(i.issue_id) > 3
ORDER BY borrow_count DESC;

-- Q17: Book categories where average price exceeds 300
SELECT
    category,
    COUNT(*)              AS total_books,
    ROUND(AVG(price), 2)  AS avg_price
FROM book
GROUP BY category
HAVING AVG(price) > 300
ORDER BY avg_price DESC;

-- Q18: Members with total fine > 30 (heavy defaulters)
SELECT
    m.name           AS member_name,
    SUM(i.fine)       AS total_fine
FROM member m
JOIN issue i ON m.member_id = i.member_id
GROUP BY m.member_id, m.name
HAVING SUM(i.fine) > 30
ORDER BY total_fine DESC;

-- ────────────────────────────────────────────────────────────
-- SECTION 5: NESTED / SUBQUERIES
-- ────────────────────────────────────────────────────────────

-- Q19: Books more expensive than the average book price
SELECT
    b.title,
    b.category,
    b.price,
    p.name AS publisher_name
FROM book b
JOIN publisher p ON b.pub_id = p.pub_id
WHERE b.price > (SELECT AVG(price) FROM book)
ORDER BY b.price DESC;

-- Q20: Members who have never borrowed a book
SELECT
    member_id,
    name,
    memb_date,
    expiry_date
FROM member
WHERE member_id NOT IN (
    SELECT DISTINCT member_id FROM issue
)
ORDER BY name;

-- Q21: Books that have never been borrowed
SELECT
    b.book_id,
    b.title,
    b.category
FROM book b
WHERE NOT EXISTS (
    SELECT 1
    FROM copy c
    JOIN issue i ON c.copy_id = i.copy_id
    WHERE c.book_id = b.book_id
)
ORDER BY b.title;

-- Q22: Most borrowed book (using subquery)
SELECT
    b.title,
    borrow_count
FROM (
    SELECT
        c.book_id,
        COUNT(i.issue_id) AS borrow_count
    FROM copy  c
    JOIN issue i ON c.copy_id = i.copy_id
    GROUP BY c.book_id
) AS borrow_stats
JOIN book b ON borrow_stats.book_id = b.book_id
WHERE borrow_count = (
    SELECT MAX(cnt)
    FROM (
        SELECT c2.book_id, COUNT(i2.issue_id) AS cnt
        FROM copy  c2
        JOIN issue i2 ON c2.copy_id = i2.copy_id
        GROUP BY c2.book_id
    ) sub
);

-- Q23: Members who borrowed books from the 'Fiction' category
SELECT DISTINCT
    m.name AS member_name
FROM member m
WHERE m.member_id IN (
    SELECT i.member_id
    FROM issue i
    JOIN copy c ON i.copy_id = c.copy_id
    JOIN book b ON c.book_id = b.book_id
    WHERE b.category = 'Fiction'
)
ORDER BY m.name;

-- Q24: Copies that are overdue (still not returned past due_date)
SELECT
    i.issue_id,
    m.name           AS member_name,
    b.title          AS book_title,
    i.due_date,
    CURRENT_DATE - i.due_date AS days_overdue,
    (CURRENT_DATE - i.due_date) * 5 AS estimated_fine
FROM issue  i
JOIN member m ON i.member_id = m.member_id
JOIN copy   c ON i.copy_id   = c.copy_id
JOIN book   b ON c.book_id   = b.book_id
WHERE i.return_date IS NULL
  AND i.due_date < CURRENT_DATE
ORDER BY days_overdue DESC;

-- Q25: Author who wrote the most expensive book
SELECT
    a.name       AS author_name,
    b.title      AS book_title,
    b.price
FROM author a
JOIN writes w ON a.author_id = w.author_id
JOIN book   b ON w.book_id   = b.book_id
WHERE b.price = (SELECT MAX(price) FROM book);

-- ────────────────────────────────────────────────────────────
-- SECTION 6: UPDATE / DELETE OPERATIONS
-- ────────────────────────────────────────────────────────────

-- Q26: Mark a copy as returned and update its status
UPDATE issue
SET return_date = CURRENT_DATE,
    fine = GREATEST(0, (CURRENT_DATE - due_date) * 5)
WHERE issue_id = 11 AND return_date IS NULL;

UPDATE copy
SET status    = 'Available',
    available = TRUE
WHERE copy_id = (SELECT copy_id FROM issue WHERE issue_id = 11);

-- Q27: Extend membership by 1 year for a specific member
UPDATE member
SET expiry_date = expiry_date + INTERVAL '1 year'
WHERE member_id = 1;

-- Q28: Delete all issue records older than 2 years that have been returned
DELETE FROM issue
WHERE return_date IS NOT NULL
  AND issue_date < CURRENT_DATE - INTERVAL '2 years';

-- Q29: Update book price — apply 10% discount to books priced above 500
UPDATE book
SET price = ROUND(price * 0.90, 2)
WHERE price > 500;

-- Q30: Mark copies as 'Available' if their last issue was returned
UPDATE copy
SET status    = 'Available',
    available = TRUE
WHERE copy_id IN (
    SELECT DISTINCT i.copy_id
    FROM issue i
    WHERE i.return_date IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM issue i2
          WHERE i2.copy_id = i.copy_id
            AND i2.return_date IS NULL
      )
)
AND status = 'Issued';

-- ────────────────────────────────────────────────────────────
-- SECTION 7: ADVANCED / ANALYTICAL QUERIES
-- ────────────────────────────────────────────────────────────

-- Q31: Monthly issue trend — how many books were issued each month
SELECT
    TO_CHAR(issue_date, 'YYYY-MM') AS month,
    COUNT(*)                        AS books_issued,
    SUM(fine)                       AS total_fine_collected
FROM issue
GROUP BY TO_CHAR(issue_date, 'YYYY-MM')
ORDER BY month;

-- Q32: Rank members by number of books borrowed (window function)
SELECT
    m.name           AS member_name,
    COUNT(i.issue_id) AS borrow_count,
    RANK() OVER (ORDER BY COUNT(i.issue_id) DESC) AS borrow_rank
FROM member m
LEFT JOIN issue i ON m.member_id = i.member_id
GROUP BY m.member_id, m.name
ORDER BY borrow_rank;

-- Q33: Books available in library right now (at least 1 available copy)
SELECT
    b.book_id,
    b.title,
    b.category,
    COUNT(c.copy_id) FILTER (WHERE c.available = TRUE) AS available_copies
FROM book b
JOIN copy c ON b.book_id = c.book_id
GROUP BY b.book_id, b.title, b.category
HAVING COUNT(c.copy_id) FILTER (WHERE c.available = TRUE) > 0
ORDER BY b.title;

-- Q34: Running total of fines collected over time
SELECT
    issue_date,
    fine,
    SUM(fine) OVER (ORDER BY issue_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
        AS running_total_fine
FROM issue
WHERE fine > 0
ORDER BY issue_date;

-- Q35: Member activity report — first borrow, last borrow, total borrows
SELECT
    m.name                    AS member_name,
    MIN(i.issue_date)          AS first_borrow,
    MAX(i.issue_date)          AS last_borrow,
    COUNT(i.issue_id)          AS total_borrows,
    COALESCE(SUM(i.fine), 0)   AS total_fine
FROM member m
LEFT JOIN issue i ON m.member_id = i.member_id
GROUP BY m.member_id, m.name
ORDER BY total_borrows DESC;

-- ============================================================
-- End of queries.sql
-- ============================================================