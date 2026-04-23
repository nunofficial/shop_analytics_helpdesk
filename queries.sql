

-- 1.
SELECT * FROM tickets WHERE status != 'Closed' AND priority = 'Urgent';

-- 2. 
SELECT full_name FROM staff WHERE dept_id = 1;

-- 3.
SELECT * FROM tickets WHERE issue_type = 'Wi-Fi Problem';

-- 4.
SELECT ticket_id, issue_type, created_at FROM tickets WHERE created_at < '2024-07-01';

-- 5. 
SELECT * FROM tickets WHERE staff_id IS NULL OR status = 'Open';



-- 6.
SELECT issue_type, COUNT(*) as total FROM tickets GROUP BY issue_type;

-- 7.
SELECT staff_id, COUNT(*) FROM tickets GROUP BY staff_id HAVING COUNT(*) > 45;

-- 8.
SELECT issue_type, COUNT(*) FROM tickets GROUP BY issue_type HAVING COUNT(*) > 180;

-- 9. 
SELECT DATE(created_at), COUNT(*) FROM tickets GROUP BY DATE(created_at) HAVING COUNT(*) > 15;

-- 10.
SELECT priority, AVG(closed_at - created_at) FROM tickets 
WHERE status = 'Closed' GROUP BY priority HAVING AVG(closed_at - created_at) > INTERVAL '24 hours';


-- 11.
SELECT t.ticket_id, s.full_name FROM tickets t JOIN staff s ON t.staff_id = s.staff_id;

-- 12. 
SELECT t.ticket_id, s.full_name, d.name as department 
FROM tickets t 
JOIN staff s ON t.staff_id = s.staff_id 
JOIN departments d ON s.dept_id = d.dept_id;

-- 13. 
SELECT d.name, COUNT(t.ticket_id) 
FROM departments d 
LEFT JOIN staff s ON d.dept_id = s.dept_id 
LEFT JOIN tickets t ON s.staff_id = t.staff_id 
GROUP BY d.name;

-- 14. 
SELECT s.full_name FROM staff s JOIN departments d ON s.dept_id = d.dept_id WHERE d.name = 'Maintenance';

-- 15. 
SELECT t.ticket_id, d.name FROM tickets t JOIN staff s ON t.staff_id = s.staff_id JOIN departments d ON s.dept_id = d.dept_id WHERE t.status = 'Closed';

-- 16.
SELECT s.full_name, d.name FROM staff s JOIN departments d ON s.dept_id = d.dept_id WHERE d.name = 'IT Support';

-- 17.
SELECT d.name, AVG(t.closed_at - t.created_at) 
FROM tickets t 
JOIN staff s ON t.staff_id = s.staff_id 
JOIN departments d ON s.dept_id = d.dept_id 
WHERE t.status = 'Closed' GROUP BY d.name;

-- 18. 
SELECT t.issue_type, s.full_name FROM tickets t JOIN staff s ON t.staff_id = s.staff_id WHERE t.priority = 'High';

-- 19.
SELECT d.name FROM departments d LEFT JOIN staff s ON d.dept_id = s.dept_id LEFT JOIN tickets t ON s.staff_id = t.staff_id WHERE t.ticket_id IS NULL;

-- 20.
SELECT DISTINCT t.issue_type, d.name FROM tickets t JOIN staff s ON t.staff_id = s.staff_id JOIN departments d ON s.dept_id = d.dept_id;

-- 21. 
SELECT staff_id, COUNT(*), RANK() OVER(ORDER BY COUNT(*) DESC) as performance_rank FROM tickets WHERE status = 'Closed' GROUP BY staff_id;

-- 22.
SELECT created_at, COUNT(*) OVER(ORDER BY created_at) as cumulative_tickets FROM tickets;

-- 23. 
SELECT ticket_id, staff_id, ROW_NUMBER() OVER(PARTITION BY staff_id ORDER BY created_at) as staff_ticket_number FROM tickets;

-- 24.
SELECT t.ticket_id, d.name, (t.closed_at - t.created_at) as res_time, 
       AVG(t.closed_at - t.created_at) OVER(PARTITION BY d.name) as dept_avg_time 
FROM tickets t JOIN staff s ON t.staff_id = s.staff_id JOIN departments d ON s.dept_id = d.dept_id WHERE t.status = 'Closed';

-- 25.
SELECT ticket_id, issue_type, d.name, 
       COUNT(*) OVER(PARTITION BY d.name, t.issue_type) * 100.0 / COUNT(*) OVER(PARTITION BY d.name) as type_percentage
FROM tickets t JOIN staff s ON t.staff_id = s.staff_id JOIN departments d ON s.dept_id = d.dept_id;


-- 26.
WITH AvgTime AS (
    SELECT AVG(closed_at - created_at) as global_avg FROM tickets WHERE status = 'Closed'
)
SELECT t.ticket_id, (t.closed_at - t.created_at) FROM tickets t, AvgTime 
WHERE t.status = 'Closed' AND (t.closed_at - t.created_at) < AvgTime.global_avg;

-- 27.
SELECT full_name FROM staff WHERE staff_id IN (
    SELECT staff_id FROM tickets GROUP BY staff_id HAVING COUNT(*) > (SELECT COUNT(*)/20 FROM tickets)
);

-- 28.
WITH WeeklyStats AS (
    SELECT DATE_TRUNC('week', created_at) as week, COUNT(*) as ticket_count FROM tickets GROUP BY 1
)
SELECT * FROM WeeklyStats WHERE ticket_count > 20;

-- 29.
SELECT s.full_name, 
       (SELECT COUNT(*) FROM tickets t WHERE t.staff_id = s.staff_id AND t.status != 'Closed') as open_tickets
FROM staff s;

-- 30.
WITH DeptCounts AS (
    SELECT d.name, COUNT(t.ticket_id) as total FROM departments d 
    JOIN staff s ON d.dept_id = s.dept_id JOIN tickets t ON s.staff_id = t.staff_id GROUP BY d.name
)
SELECT name FROM DeptCounts WHERE total = (SELECT MAX(total) FROM DeptCounts);