# Nested CTE to determine good and bad salesmen
WITH total_items AS (
  SELECT salesman_id, 
          city_id, 
          SUM(amount_earned) AS earned_amt,
          SUM(items_sold) AS total_items_sold
  FROM daily_sales ds
  JOIN salesman s
  ON ds.salesman_id = s.id
  JOIN city c
  ON s.city_id = c.id
  GROUP BY salesman_id, city_id
  ), 
  
  city_average AS (
    SELECT city_id, 
            AVG(earned_amt) AS city_avg_earned
    FROM total_items
    GROUP BY city_id
    ),
  
  comparison AS (
  SELECT ca.city_id, 
          salesman_id, 
          earned_amt, 
          city_avg_earned,
          total_items_sold
  FROM city_average ca
  JOIN total_items ti
  ON ca.city_id = ti.city_id
  ORDER BY city_id
    )
    
SELECT CASE WHEN earned_amt > city_avg_earned THEN 'Good'
        ELSE 'Bad' 
        END AS label,
        AVG(total_items_sold) AS average
FROM comparison
GROUP BY label


# Show maximum average hours spent on a project with the client id
WITH h20 AS (
  SELECT project_id, COUNT(DISTINCT employee_id) AS no_of_emp, SUM(hours_spent) AS total_hours
  FROM allocation
  GROUP BY 1
  HAVING SUM(hours_spent) > 20
  ),
  
  project_client AS (
    SELECT client_id, AVG(no_of_emp) AS avg_emp_num FROM h20
    JOIN project p
    ON p.id = h20.project_id
    GROUP BY 1
    )
    
    SELECT avg_emp_num AS maximal_average, client_id FROM project_client
    WHERE avg_emp_num = (
      SELECT MAX(avg_emp_num)
      FROM project_client
      )