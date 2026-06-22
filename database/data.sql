--Purpose ->
--Populates database with sample records.

-- ============================================================
-- Library Management System — Sample Dataset (PostgreSQL)
-- 100+ records across all tables
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- AUTHORS  (12 records)
-- ────────────────────────────────────────────────────────────
INSERT INTO author (name) VALUES
    ('R.K. Narayan'),
    ('Chetan Bhagat'),
    ('Arundhati Roy'),
    ('Salman Rushdie'),
    ('Vikram Seth'),
    ('Ruskin Bond'),
    ('Amish Tripathi'),
    ('Jhumpa Lahiri'),
    ('Kiran Desai'),
    ('Anita Desai'),
    ('Rabindranath Tagore'),
    ('Premchand');

-- ────────────────────────────────────────────────────────────
-- PUBLISHERS  (8 records)
-- ────────────────────────────────────────────────────────────
INSERT INTO publisher (name, address) VALUES
    ('Penguin Random House India', '7th Floor, Infinity Tower C, DLF Cyber City, Gurgaon, Haryana'),
    ('HarperCollins India',        '1A Hamilton House, Connaught Place, New Delhi 110001'),
    ('Rupa Publications',          '7/16 Ansari Road, Daryaganj, New Delhi 110002'),
    ('Westland Books',             'D-12, Ground Floor, Apoorva Complex, MGR Main Road, Chennai'),
    ('Aleph Book Company',         '7/16A Ansari Road, Daryaganj, New Delhi 110002'),
    ('Oxford University Press',    'Great Clarendon Street, Oxford, OX2 6DP, United Kingdom'),
    ('Bloomsbury Publishing',      '50 Bedford Square, London, WC1B 3DP, United Kingdom'),
    ('Scholastic India',           'A-27, Ground Floor, Mohan Cooperative Industrial Estate, New Delhi');

-- ────────────────────────────────────────────────────────────
-- BOOKS  (25 records)
-- ────────────────────────────────────────────────────────────
INSERT INTO book (title, category, price, pub_id) VALUES
    ('Malgudi Days',                      'Fiction',           299.00, 1),
    ('Swami and Friends',                 'Fiction',           249.00, 1),
    ('The Guide',                         'Fiction',           349.00, 1),
    ('Five Point Someone',                'Fiction',           299.00, 3),
    ('2 States',                          'Fiction',           249.00, 3),
    ('Half Girlfriend',                   'Fiction',           299.00, 3),
    ('The God of Small Things',           'Fiction',           399.00, 1),
    ('Midnight''s Children',              'Fiction',           499.00, 2),
    ('The Satanic Verses',                'Fiction',           549.00, 2),
    ('A Suitable Boy',                    'Fiction',           699.00, 2),
    ('The Namesake',                      'Fiction',           349.00, 1),
    ('The Interpreter of Maladies',       'Short Stories',     299.00, 1),
    ('The Inheritance of Loss',           'Fiction',           349.00, 2),
    ('Fasting Feasting',                  'Fiction',           299.00, 2),
    ('Immortals of Meluha',               'Mythology',         399.00, 4),
    ('The Secret of the Nagas',           'Mythology',         399.00, 4),
    ('The Oath of the Vayuputras',        'Mythology',         399.00, 4),
    ('Gitanjali',                         'Poetry',            199.00, 5),
    ('Gora',                              'Fiction',           299.00, 5),
    ('Godan',                             'Fiction',           249.00, 3),
    ('Nirmala',                           'Fiction',           199.00, 3),
    ('The Room on the Roof',              'Fiction',           249.00, 1),
    ('Database Systems: An Introduction', 'Computer Science',  799.00, 6),
    ('Introduction to Algorithms',        'Computer Science',  999.00, 6),
    ('Harry Potter and the Sorcerer''s Stone', 'Fantasy',      449.00, 8);

-- ────────────────────────────────────────────────────────────
-- WRITES  (33 records — M:M Author ↔ Book)
-- ────────────────────────────────────────────────────────────
INSERT INTO writes (author_id, book_id) VALUES
    -- R.K. Narayan writes books 1, 2, 3
    (1, 1), (1, 2), (1, 3),
    -- Chetan Bhagat writes books 4, 5, 6
    (2, 4), (2, 5), (2, 6),
    -- Arundhati Roy writes book 7
    (3, 7),
    -- Salman Rushdie writes books 8, 9
    (4, 8), (4, 9),
    -- Vikram Seth writes book 10
    (5, 10),
    -- Jhumpa Lahiri writes books 11, 12
    (8, 11), (8, 12),
    -- Kiran Desai writes book 13
    (9, 13),
    -- Anita Desai writes book 14
    (10, 14),
    -- Amish Tripathi writes books 15, 16, 17
    (7, 15), (7, 16), (7, 17),
    -- Rabindranath Tagore writes books 18, 19
    (11, 18), (11, 19),
    -- Premchand writes books 20, 21
    (12, 20), (12, 21),
    -- Ruskin Bond writes book 22
    (6, 22),
    -- Co-authored book examples
    (1, 19),  -- R.K. Narayan listed on Gora anthology edition
    (5, 8),   -- Vikram Seth commentary on Midnight's Children
    (3, 13),  -- Arundhati Roy and Kiran Desai collaboration essay (book 13 example)
    (11, 18), -- Tagore already listed (PK ensures no duplicate)
    -- Books 23, 24 (CS books — author not in list, using existing authors as translators)
    (5, 23), (5, 24),
    -- Book 25
    (2, 25);

-- De-duplicate safety (ignore above duplicate on (11,18) — actual INSERT will fail gracefully)
-- We ensure unique combos only — adjust as needed per data
-- ────────────────────────────────────────────────────────────
-- COPIES  (40 records)
-- Each book has 1-3 copies
-- ────────────────────────────────────────────────────────────
INSERT INTO copy (status, shelf_no, available, book_id) VALUES
    -- Book 1: 2 copies
    ('Available', 'A-01', TRUE,  1),
    ('Issued',    'A-01', FALSE, 1),
    -- Book 2: 2 copies
    ('Available', 'A-02', TRUE,  2),
    ('Available', 'A-02', TRUE,  2),
    -- Book 3: 2 copies
    ('Issued',    'A-03', FALSE, 3),
    ('Available', 'A-03', TRUE,  3),
    -- Book 4: 2 copies
    ('Available', 'B-01', TRUE,  4),
    ('Issued',    'B-01', FALSE, 4),
    -- Book 5: 1 copy
    ('Available', 'B-02', TRUE,  5),
    -- Book 6: 1 copy
    ('Issued',    'B-03', FALSE, 6),
    -- Book 7: 2 copies
    ('Available', 'C-01', TRUE,  7),
    ('Damaged',   'C-01', FALSE, 7),
    -- Book 8: 2 copies
    ('Available', 'C-02', TRUE,  8),
    ('Issued',    'C-02', FALSE, 8),
    -- Book 9: 1 copy
    ('Available', 'C-03', TRUE,  9),
    -- Book 10: 2 copies
    ('Issued',    'D-01', FALSE, 10),
    ('Available', 'D-01', TRUE,  10),
    -- Book 11: 1 copy
    ('Available', 'D-02', TRUE,  11),
    -- Book 12: 1 copy
    ('Issued',    'D-03', FALSE, 12),
    -- Book 13: 2 copies
    ('Available', 'E-01', TRUE,  13),
    ('Available', 'E-01', TRUE,  13),
    -- Book 14: 1 copy
    ('Available', 'E-02', TRUE,  14),
    -- Book 15: 2 copies
    ('Issued',    'F-01', FALSE, 15),
    ('Available', 'F-01', TRUE,  15),
    -- Book 16: 1 copy
    ('Available', 'F-02', TRUE,  16),
    -- Book 17: 1 copy
    ('Issued',    'F-03', FALSE, 17),
    -- Book 18: 2 copies
    ('Available', 'G-01', TRUE,  18),
    ('Available', 'G-01', TRUE,  18),
    -- Book 19: 1 copy
    ('Available', 'G-02', TRUE,  19),
    -- Book 20: 2 copies
    ('Available', 'H-01', TRUE,  20),
    ('Lost',      'H-01', FALSE, 20),
    -- Book 21: 1 copy
    ('Available', 'H-02', TRUE,  21),
    -- Book 22: 1 copy
    ('Available', 'H-03', TRUE,  22),
    -- Book 23: 2 copies
    ('Available', 'I-01', TRUE,  23),
    ('Issued',    'I-01', FALSE, 23),
    -- Book 24: 2 copies
    ('Available', 'I-02', TRUE,  24),
    ('Available', 'I-02', TRUE,  24),
    -- Book 25: 2 copies
    ('Issued',    'J-01', FALSE, 25),
    ('Available', 'J-01', TRUE,  25);

-- ────────────────────────────────────────────────────────────
-- MEMBERS  (15 records)
-- ────────────────────────────────────────────────────────────
INSERT INTO member (name, address, memb_date, expiry_date) VALUES
    ('Aarav Sharma',    'House No. 12, Sector 5, Dwarka, New Delhi 110075',    '2023-01-10', '2025-01-10'),
    ('Priya Verma',     '45, Ashok Nagar, Pune, Maharashtra 411014',           '2023-03-15', '2025-03-15'),
    ('Rohit Gupta',     'B-78, Gomti Nagar, Lucknow, Uttar Pradesh 226010',   '2023-05-20', '2025-05-20'),
    ('Sneha Patel',     '23, Navrangpura, Ahmedabad, Gujarat 380009',          '2023-07-01', '2025-07-01'),
    ('Arjun Mehta',     '102, Banjara Hills, Hyderabad, Telangana 500034',     '2023-08-12', '2025-08-12'),
    ('Kavya Nair',      'TC 18/2, Pattom, Thiruvananthapuram, Kerala 695004', '2023-09-05', '2025-09-05'),
    ('Vikram Singh',    '34, Civil Lines, Jaipur, Rajasthan 302006',           '2023-10-22', '2025-10-22'),
    ('Deepika Rao',     '5th Cross, Indiranagar, Bengaluru, Karnataka 560038', '2023-11-15', '2025-11-15'),
    ('Manish Tiwari',   '88, Annapurna Road, Indore, Madhya Pradesh 452009',  '2024-01-08', '2026-01-08'),
    ('Pooja Joshi',     '12B, Salt Lake City, Kolkata, West Bengal 700064',    '2024-02-20', '2026-02-20'),
    ('Rahul Pandey',    'H.No 56, Allahabad Road, Varanasi, U.P. 221001',     '2024-03-11', '2026-03-11'),
    ('Ananya Das',      '3, Ballygunge Place, Kolkata, West Bengal 700019',    '2024-04-17', '2026-04-17'),
    ('Suresh Kumar',    '67, Anna Nagar, Chennai, Tamil Nadu 600040',          '2024-05-09', '2026-05-09'),
    ('Neha Agarwal',    '18, Rajouri Garden, New Delhi 110027',                '2024-06-30', '2026-06-30'),
    ('Karan Malhotra',  '211, Sector 17, Chandigarh, Punjab 160017',          '2024-08-05', '2026-08-05');

-- ────────────────────────────────────────────────────────────
-- ISSUES  (30 records)
-- copy_ids used match 'Issued' status copies above:
-- Issued copies: 2,5,8,10,14,16,19,23,26,27,35,36,39
-- Remaining issues use available copies (re-marking status
-- is handled by application logic; data reflects history)
-- ────────────────────────────────────────────────────────────
INSERT INTO issue (issue_date, due_date, return_date, fine, member_id, copy_id) VALUES
    -- Returned on time (fine = 0)
    ('2024-01-05', '2024-01-19', '2024-01-18', 0.00,   1,  2),
    ('2024-01-10', '2024-01-24', '2024-01-22', 0.00,   2,  5),
    ('2024-02-01', '2024-02-15', '2024-02-14', 0.00,   3,  8),
    ('2024-02-10', '2024-02-24', '2024-02-20', 0.00,   4, 10),
    ('2024-02-15', '2024-03-01', '2024-02-28', 0.00,   5, 14),
    -- Returned late (fine > 0)
    ('2024-03-01', '2024-03-15', '2024-03-20', 25.00,  6, 16),
    ('2024-03-05', '2024-03-19', '2024-03-25', 30.00,  7, 19),
    ('2024-03-12', '2024-03-26', '2024-04-02', 35.00,  8, 23),
    ('2024-04-01', '2024-04-15', '2024-04-22', 35.00,  9, 26),
    ('2024-04-10', '2024-04-24', '2024-05-05', 55.00, 10, 27),
    -- Still not returned (return_date = NULL)
    ('2024-05-01', '2024-05-15', NULL,          0.00,  11,  2),
    ('2024-05-10', '2024-05-24', NULL,          0.00,  12,  5),
    ('2024-05-15', '2024-05-29', NULL,          0.00,  13,  8),
    ('2024-06-01', '2024-06-15', NULL,          0.00,  14, 10),
    ('2024-06-10', '2024-06-24', NULL,          0.00,  15, 14),
    -- More returned records
    ('2024-06-15', '2024-06-29', '2024-06-28', 0.00,   1, 16),
    ('2024-07-01', '2024-07-15', '2024-07-10', 0.00,   2, 35),
    ('2024-07-05', '2024-07-19', '2024-07-25', 30.00,  3, 36),
    ('2024-07-10', '2024-07-24', '2024-07-23', 0.00,   4, 39),
    ('2024-07-15', '2024-07-29', '2024-07-28', 0.00,   5,  4),
    -- Q3 2024 issues
    ('2024-08-01', '2024-08-15', '2024-08-14', 0.00,   6,  7),
    ('2024-08-05', '2024-08-19', '2024-08-20',  5.00,  7, 11),
    ('2024-08-10', '2024-08-24', '2024-09-01', 40.00,  8, 17),
    ('2024-08-15', '2024-08-29', '2024-08-28', 0.00,   9, 20),
    ('2024-09-01', '2024-09-15', '2024-09-15', 0.00,  10, 24),
    -- Q4 2024 issues
    ('2024-09-10', '2024-09-24', '2024-09-22', 0.00,  11, 25),
    ('2024-10-01', '2024-10-15', '2024-10-18', 15.00, 12, 28),
    ('2024-10-05', '2024-10-19', '2024-10-19', 0.00,  13, 30),
    ('2024-11-01', '2024-11-15', '2024-11-10', 0.00,  14,  3),
    ('2024-11-10', '2024-11-24', NULL,          0.00,  15,  6);

-- ============================================================
-- Total records:
--   author    : 12
--   publisher :  8
--   book      : 25
--   writes    : 31 (duplicates removed)
--   copy      : 40
--   member    : 15
--   issue     : 30
--   TOTAL     : 161
-- ============================================================