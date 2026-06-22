-- Purpose ->
-- Creates the database structure.

-- ============================================================
-- Library Management System — PostgreSQL Schema
-- Project  : DBMS Capstone Project
-- Team     : Ankit Raj (Leader), Ayush Ranjan, Salaih Hasan,
--            Chitra Jha, Priyanshu Patel, Hemant Nanda
-- ============================================================

-- Drop existing tables in reverse dependency order
DROP TABLE IF EXISTS issue   CASCADE;
DROP TABLE IF EXISTS copy    CASCADE;
DROP TABLE IF EXISTS writes  CASCADE;
DROP TABLE IF EXISTS book    CASCADE;
DROP TABLE IF EXISTS publisher CASCADE;
DROP TABLE IF EXISTS author  CASCADE;
DROP TABLE IF EXISTS member  CASCADE;

-- ────────────────────────────────────────────────────────────
-- 1. AUTHOR
-- ────────────────────────────────────────────────────────────
CREATE TABLE author (
    author_id  SERIAL        PRIMARY KEY,
    name       VARCHAR(100)  NOT NULL
);

-- ────────────────────────────────────────────────────────────
-- 2. PUBLISHER
-- ────────────────────────────────────────────────────────────
CREATE TABLE publisher (
    pub_id   SERIAL        PRIMARY KEY,
    name     VARCHAR(150)  NOT NULL,
    address  TEXT          NOT NULL
);

-- ────────────────────────────────────────────────────────────
-- 3. BOOK
-- ────────────────────────────────────────────────────────────
CREATE TABLE book (
    book_id   SERIAL          PRIMARY KEY,
    title     VARCHAR(255)    NOT NULL,
    category  VARCHAR(100)    NOT NULL,
    price     NUMERIC(10, 2)  NOT NULL CHECK (price >= 0),
    pub_id    INT             NOT NULL,
    CONSTRAINT fk_book_publisher FOREIGN KEY (pub_id)
        REFERENCES publisher (pub_id) ON DELETE RESTRICT
);

-- ────────────────────────────────────────────────────────────
-- 4. WRITES  (M:M junction — Author ↔ Book)
-- ────────────────────────────────────────────────────────────
CREATE TABLE writes (
    author_id  INT  NOT NULL,
    book_id    INT  NOT NULL,
    PRIMARY KEY (author_id, book_id),
    CONSTRAINT fk_writes_author FOREIGN KEY (author_id)
        REFERENCES author (author_id) ON DELETE CASCADE,
    CONSTRAINT fk_writes_book FOREIGN KEY (book_id)
        REFERENCES book (book_id) ON DELETE CASCADE
);

-- ────────────────────────────────────────────────────────────
-- 5. COPY  (Physical copies of a book)
-- ────────────────────────────────────────────────────────────
CREATE TABLE copy (
    copy_id   SERIAL       PRIMARY KEY,
    status    VARCHAR(20)  NOT NULL DEFAULT 'Available'
                CHECK (status IN ('Available', 'Issued', 'Damaged', 'Lost')),
    shelf_no  VARCHAR(20)  NOT NULL,
    available BOOLEAN      NOT NULL DEFAULT TRUE,
    book_id   INT          NOT NULL,
    CONSTRAINT fk_copy_book FOREIGN KEY (book_id)
        REFERENCES book (book_id) ON DELETE RESTRICT
);

-- ────────────────────────────────────────────────────────────
-- 6. MEMBER
-- ────────────────────────────────────────────────────────────
CREATE TABLE member (
    member_id   SERIAL        PRIMARY KEY,
    name        VARCHAR(100)  NOT NULL,
    address     TEXT          NOT NULL,
    memb_date   DATE          NOT NULL DEFAULT CURRENT_DATE,
    expiry_date DATE          NOT NULL,
    CONSTRAINT chk_dates CHECK (expiry_date > memb_date)
);

-- ────────────────────────────────────────────────────────────
-- 7. ISSUE  (Borrow transaction — Member ↔ Copy)
-- ────────────────────────────────────────────────────────────
CREATE TABLE issue (
    issue_id    SERIAL          PRIMARY KEY,
    issue_date  DATE            NOT NULL DEFAULT CURRENT_DATE,
    due_date    DATE            NOT NULL,
    return_date DATE,
    fine        NUMERIC(8, 2)   NOT NULL DEFAULT 0.00 CHECK (fine >= 0),
    member_id   INT             NOT NULL,
    copy_id     INT             NOT NULL,
    CONSTRAINT fk_issue_member FOREIGN KEY (member_id)
        REFERENCES member (member_id) ON DELETE RESTRICT,
    CONSTRAINT fk_issue_copy FOREIGN KEY (copy_id)
        REFERENCES copy (copy_id) ON DELETE RESTRICT,
    CONSTRAINT chk_due_date CHECK (due_date > issue_date),
    CONSTRAINT chk_return_date CHECK (
        return_date IS NULL OR return_date >= issue_date
    )
);
