/* Purpose ->
Contains database views.


Examples 

CREATE VIEW ActiveMembers AS
SELECT
member_id,
COUNT(*) AS total_books
FROM Borrow_Transaction
GROUP BY member_id;

Usage:
SELECT * FROM ActiveMembers;
*/
